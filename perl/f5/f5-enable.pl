#!/usr/bin/perl

#use SOAP::Lite + trace => qw(method debug);
use SOAP::Lite;
use MIME::Base64;

#----------------------------------------------------------------------------
# Validate Arguments
#----------------------------------------------------------------------------
my $sHost = $ARGV[0];
my $sUID = $ARGV[1];
my $sPWD = $ARGV[2];
my $sNodePort = $ARGV[3];
my $sEnable = $ARGV[4];
my $sProtocol = "https";
my $sPort = 443;

if ( ($sHost eq "") or ($sUID eq "") or ($sPWD eq "") )
{
	die ("Usage: NodeServer.pl host uid pwd [[node_port] [enable|disable]]\n");
}

#----------------------------------------------------------------------------
# support for custom enum types
#----------------------------------------------------------------------------
sub SOAP::Deserializer::typecast
{
	my ($self, $value, $name, $attrs, $children, $type) = @_;
	my $retval = undef;
	if ( "{urn:iControl}LocalLB.AvailabilityStatus" == $type )
	{
		$retval = $value;
	}
	return $retval;
}

#----------------------------------------------------------------------------
# Transport Information
#----------------------------------------------------------------------------
sub SOAP::Transport::HTTP::Client::get_basic_credentials
{
	return "$sUID" => "$sPWD";
}

$Pool = SOAP::Lite
	-> uri('urn:iControl:LocalLB/Pool')
	-> proxy("$sProtocol://$sHost:$sPort/iControl/iControlPortal.cgi");
eval { $Pool->transport->http_request->header
(
	'Authorization' => 
		'Basic ' . MIME::Base64::encode("$sUID:$sPWD", '')
); };

$PoolMember = SOAP::Lite
	-> uri('urn:iControl:LocalLB/PoolMember')
	-> proxy("$sProtocol://$sHost:$sPort/iControl/iControlPortal.cgi");
eval { $PoolMember->transport->http_request->header
(
	'Authorization' => 
		'Basic ' . MIME::Base64::encode("$sUID:$sPWD", '')
); };


#----------------------------------------------------------------------------
# sub ListPoolsAndMembers
#----------------------------------------------------------------------------
sub ListPoolsAndMembers()
{
	my ($node_addr_port) = (@_);
	my ($node_addr, $node_port) = split(/:/, $node_addr_port, 2);

	my @pool_list = &getPoolList();
	my @object_status_lists = &getObjectStatusLists(@pool_list);
	

	
	# Loop over pools
	for $i (0 .. $#pool_list)
	{
		$bFound = 0;
		$pool = @pool_list[$i];
		
		if ( "" == $node_addr )
		{
			# if no node given, print out full list
			print "Pool $pool\n";
			foreach $status (@{@object_status_lists[$i]})
			{
				$member  = $status->{"member"};
				$addr = $member->{"address"};
				$port = $member->{"port"};
				
				$ostat = $status->{"object_status"};
				$astat = $ostat->{"availability_status"};
				$estat = $ostat->{"enabled_status"};
				
				print "        $addr:$port ($astat, $estat)\n";
			}
			#print "\n";
		}
		else
		{
			# else, only print out where matches are found.
			foreach $status (@{@object_status_lists[$i]})
			{
				if ( !$bFound )
				{
					$member  = $status->{"member"};
					$addr = $member->{"address"};
					$port = $member->{"port"};

					$ostat = $status->{"object_status"};
					$astat = $ostat->{"availability_status"};
					$estat = $ostat->{"enabled_status"};

					if ( ($node_addr eq $addr) && ($node_port eq $port) )
					{
						$bFound = 1;
					}
				}
			}
			if ( $bFound )
			{
				print "Pool $pool : $node_addr:$node_port ($astat, $estat)\n";
			}
		}
	}
}

#----------------------------------------------------------------------------
# sub setNodeServer
#----------------------------------------------------------------------------
sub SetNodeServer()
{
	my ($node_addr_port, $state) = (@_);
	my ($node_addr, $node_port) = split(/:/, $node_addr_port, 2);
	my @pool_list = &findPoolsFromMember($node_addr_port);
	my $member = { address => $node_addr, port => $node_port };
	my $ENABLED_STATE = "STATE_ENABLED";
	
	if ( $state eq "disable" )
	{
		$ENABLED_STATE = "STATE_DISABLED";
	}
	
	my $MemberMonitorState  = { member => $member, monitor_state => $ENABLED_STATE };
	my @MemberMonitorStateList;
	push @MemberMonitorStateList, $MemberMonitorState;
	
	my @MemberMonitorStateLists;
	for $i (0 .. $#pool_list)
	{
		push @MemberMonitorStateLists, [@MemberMonitorStateList];
	}
	
	# Make call to set_monitor_state 
	$soapResponse = $PoolMember->set_monitor_state(
		SOAP::Data->name(pool_names => [@pool_list]),
		SOAP::Data->name(monitor_states => [@MemberMonitorStateLists])
	);
	&checkResponse($soapResponse);
	
	print "Node Server $node_addr_port set to $ENABLED_STATE in pools: ";
	foreach $pool (@pool_list)
	{
		print "$pool, ";
	}
	print "\n";
}


#----------------------------------------------------------------------------
# sub getPoolList
#----------------------------------------------------------------------------
sub getPoolList()
{
	# Get the list of pools
	$soapResponse = $Pool->get_list();
	&checkResponse($soapResponse);
	my @pool_list = @{$soapResponse->result};
	
	return @pool_list;
}

#----------------------------------------------------------------------------
# sub getMemberLists
#----------------------------------------------------------------------------
sub getMemberLists()
{
	my (@pool_list) = (@_);
	
	# Get the list of pool members for all the pools
	$soapResponse = $Pool->get_member
	(
		SOAP::Data->name(pool_names => [@pool_list])
	);
	&checkResponse($soapResponse);
	@member_lists = @{$soapResponse->result};
	
	return @member_lists;
}

#----------------------------------------------------------------------------
# sub getObjectStatus
#----------------------------------------------------------------------------
sub getObjectStatusLists()
{
	my (@pool_list) = (@_);
	
	# Get the list of pool members for all the pools
	$soapResponse = $PoolMember->get_object_status
	(
		SOAP::Data->name(pool_names => [@pool_list])
	);
	&checkResponse($soapResponse);
	@object_status_lists = @{$soapResponse->result};
	
	return @object_status_lists;
}

#----------------------------------------------------------------------------
# sub findPoolsFromMember
#----------------------------------------------------------------------------
sub findPoolsFromMember()
{
	my ($node_addr_port) = (@_);
	my ($node_addr, $node_port) = split(/:/, $node_addr_port, 2);
	my @pool_match_list;
	
	my @pool_list = &getPoolList();
	my @member_lists = &getMemberLists(@pool_list);

	for $i (0 .. $#pool_list)
	{
		$pool = @pool_list[$i];
		foreach $member (@{@member_lists[$i]})
		{
			$addr = $member->{"address"};
			$port = $member->{"port"};
			
			if ( ($node_addr eq $addr) && ($node_port eq $port) )
			{
				push @pool_match_list, $pool;
			}
		}
	}
	return @pool_match_list;
}

#----------------------------------------------------------------------------
# checkResponse
#----------------------------------------------------------------------------
sub checkResponse()
{
	my ($soapResponse) = (@_);
	if ( $soapResponse->fault )
	{
		print $soapResponse->faultcode, " ", $soapResponse->faultstring, "\n";
		exit();
	}
}

#----------------------------------------------------------------------------
# main app logic
#----------------------------------------------------------------------------
if ( ($sNodePort ne "") && ($sEnable ne "") )
{
	&SetNodeServer($sNodePort, $sEnable)
}
else
{
	&ListPoolsAndMembers($sNodePort)
}
