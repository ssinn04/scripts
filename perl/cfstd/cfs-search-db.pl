#!/usr/bin/perl -w

use strict;
use warnings;
use Pod::Usage;
use Getopt::Long;
use DBI;


# Define some values
my $dbfile="<dbname>";

# Declare some variables
my $auto;
my $batch;
my $instancename="all";
my $hostname;
my $stagename="all";
my $datacenter="all";
my $activegroup="all";
my $environment="all";
my $node;
my $sthSearchNodeprops;
my $Qinstancename;
my $Qhostname;
my $Qstagename;
my $Qdatacenter;
my $Qactivegroup;
my $Qenvironment;
my $Qnode;
my $query="SELECT hostname, instancename FROM nodeprops ";
my $verb;
my $sthSearchDB;
my @row;
my $row;

=pod

=head1 NAME

=head1 SYNOPSIS

This is used to search the system database. It requires at least the datacenter, which can have tha value 'all'. 

=head2 OPTIONS

=over

=item B<-A,  --auto>          - Not implemented yet

=item B<-B,  --batch>         - Not implemented yet

=item B<-i,  --instancename>  - cfsapp01, cfsapp02, dnspxapp, etc

=item B<-h,  --hostname>      - The FQDN of the system. Everything keys off this

=item B<-s,  --stagename>     - dev, prd, int, sys, all

=item B<-d,  --datacenter>    - The datacenter (dc1, dc2, c031, dc7, etc) of the system

=item B<-g,  --activegroup>   - The E1 or E2 instance of this system

=item B<-e,  --environment>   - dev, prd, int, sys, all

=back

=head2 AUTHOR

Spencer J Sinn <ssinn@digitalriver.com>

=cut

Getopt::Long::Configure ( 'auto_help', 'bundling' );
GetOptions (
  'A|auto'            => \$auto,
  'B|batch'           => \$batch,
  'i|instancename=s'  => \$instancename,
  'h|hostname=s'      => \$hostname,
  's|stagename=s'     => \$stagename,
  'd|datacenter=s'    => \$datacenter,
  'g|activegroup=s'   => \$activegroup,
  'e|environment=s'   => \$environment,
  'n|node=s'          => \$node,
) or warn pod2usage(2);


# get datacenter
if ( $datacenter eq "all" ) {
  $Qdatacenter = "";
} else {
  if ( $verb ) {
    $verb="AND";
  } else {
    $verb="WHERE";
  };
  $Qdatacenter = " $verb datacenter = '$datacenter' ";
};

# get instancename
if ( $instancename eq "all" ) {
  $Qinstancename = "";
} else {
  if ( $verb ) {
    $verb="AND";
  } else {
    $verb="WHERE";
  };
  $Qinstancename = "$verb instancename = '$instancename' ";
};

# get stagename w hints
if ( $stagename eq "all" ) {
  $Qstagename = "";
} else {
  if ( $verb ) {
    $verb="AND";
  } else {
    $verb="WHERE";
  };
  $Qstagename = " $verb stagename = '$stagename' ";
};

# get activegroup
if ( $activegroup eq "all" ) {
  $Qactivegroup = "";
} else {
  $activegroup = uc$activegroup;
  if ( $verb ) {
    $verb="AND";
  } else {
    $verb="WHERE";
  };
  $Qactivegroup = " $verb activegroup = '$activegroup' ";
};

# get environment
if ( $environment eq "all" ) {
  $Qenvironment = "";
} else {
  if ( $verb ) {
    $verb="AND";
  } else {
    $verb="WHERE";
  };
  $Qenvironment = " $verb environment = '$environment' ";
};

# get node
if ( $node ) {
  print "Enter the node ie blah:";
  chomp ($node=<STDIN>);
};

# Build the query
$query = $query.$Qdatacenter.$Qstagename.$Qactivegroup.$Qenvironment.$Qinstancename;
print "query = $query\n";

# get propname
# get propvalue

# Batch

# Connect
my $dbh = DBI->connect(
      "dbi:SQLite:dbname=$dbfile",
      "",
      "",
      { RaiseError => 1 },
      ) or die "Cannot connect: $DBI::errstr";

# Build query based on switches
$sthSearchDB=$dbh->prepare("
  $query
  ");

# Query database
$sthSearchDB->execute();

# Subroutines
while ( @row = $sthSearchDB->fetchrow_array() ) {
  print "$row[1]\@$row[0]\n";
}

# Does this record exist?

__END__
