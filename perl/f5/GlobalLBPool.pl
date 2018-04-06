#!/usr/bin/perl
 
#use SOAP::Lite + trace => qw(method debug);
use SOAP::Lite;
use MIME::Base64;
use Math::BigInt;
 
use lib '/home/ssinn/lib/';

BEGIN { push (@INC, ".."); }
use iControlTypeCast;
 
#----------------------------------------------------------------------------
# Validate Arguments
#----------------------------------------------------------------------------
my $sHost = $ARGV[0];
my $sPort = $ARGV[1];
my $sUID = $ARGV[2];
my $sPWD = $ARGV[3];
my $sPool = $ARGV[4];
my $sEnable = $ARGV[5];
my $sProtocol = "https";
 
 
if ( ("80" eq $sPort) or ("8080" eq $sPort) )
{
  $sProtocol = "http";
}
 
if ( ($sHost eq "") or ($sPort eq "") or ($sUID eq "") or ($sPWD eq "") )
{
  &usage();
}
 
sub usage()
{
  my ($sCmd) = @_;
  print "Usage: GlobalLBPool.pl host port uid pwd pool [enable|disable]\n";
  exit();
}
 
#----------------------------------------------------------------------------
# Transport Information
#----------------------------------------------------------------------------
sub SOAP::Transport::HTTP::Client::get_basic_credentials-->
{
  return "$sUID" => "$sPWD";
}
 
$Pool = SOAP::Lite
  -> uri('urn<!--:iControl:GlobalLB/Pool')-->
  -> proxy("$sProtocol://$sHost:$sPort/iControl/iControlPortal.cgi");
eval { $Pool->transport->http_request->header
(
  'Authorization' => 
    'Basic ' . MIME::Base64::encode("$sUID:$sPWD", '')-->
); };
 
if ( $sPool eq "" )
{
  &GetPoolList();
}
else
{
  if ( $sEnable eq "" )
  {
    &GetPoolState($sPool);
  }
  else
  {
    &SetPoolState($sPool, $sEnable);
  }
}
 
sub GetPoolList()
{
  $soapResponse = $Pool->get_list();
  &checkResponse($soapResponse);
  @pools = @{$soapResponse->result};
  foreach $pool (@pools)
  {
    print "$pool\n";
  }
}
 
#----------------------------------------------------------------------------
# GetPoolState
#----------------------------------------------------------------------------
sub GetPoolState()
{
  my ($pool) = (@_);
  $soapResponse = $Pool->get_enabled_state(
    SOAP::Data->name(pool_names => [$pool])
  );
  &checkResponse($soapResponse);
  @states = @{$soapResponse->result};
  foreach $state (@states)
  {
    print "$state\n";
  }
  
}
 
sub SetPoolState()
{
  my($pool, $state) = (@_);
  
  print " Setting pool '$pool' to state '$state'\n";
  
  if ( $state eq "enabled" )
  {
    $state = "STATE_ENABLED";
  }
  else
  {
    $state = "STATE_DISABLED";
  }
  
  my @gtmPools;
  push @gtmPools, $pool;
#  push @gtmPools, "gtm_pool_2";
  
  my @gtmEnabled;
  push @gtmEnabled, $state;
#  push @gtmEnabled, $state;
  
  $soapResponse = $Pool->set_enabled_state(
    SOAP::Data->name(pool_names => [@gtmPools]),
    SOAP::Data->name(states => [@gtmEnabled])
  );
  &checkResponse($soapResponse);
  &GetPoolState($pool);
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
