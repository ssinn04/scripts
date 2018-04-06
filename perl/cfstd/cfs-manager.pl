#!/usr/bin/perl -w


#
# Create DR gC properties database
#
use strict;
use warnings;
use DBI;
use Getopt::Long;
use Pod::Usage;
use Data::Dumper;


# Define some values
# Files
my $dbfile="<dbname>";

# database and statement handles
my $dbh;
my $sthSearchDB;

# Declare some variables
my $datacenter;
my $environment;
my $hostname;
my $node;
my $activegroup="E2";
my $verbose;
my $HostList;

my @row;
my $row;

# if the database doesn't exist, create it
if ( -e "$dbfile" ) {
  # do nothing
  } else {
  print "I can't find database $dbfile.";
  pod2usage(2); 
  }


# Add POD here
=pod

=head1 NAME cfs-manager.pl

=head1 SYNOPSIS This script will query the CFS/TD database and return the hostnames.

=item -d --datacenter dc1 dc2 dc3 dc7 are all viable choices

Default: All

=item -e --environment

Default: All

=item -n --node

Default: All

=head2 AUTHOR
Spencer J Sinn <ssinn@digitalriver.com>

=cut

# Configure options
Getopt::Long::Configure ( 'auto_help', 'bundling' );
GetOptions (
# datacenter environment user
  'd|datacenter=s'         => \$datacenter,
  'e|environment=s'        => \$environment,
  'h|hostname=s'           => \$hostname,
  'n|node=s'               => \$node,
  'a|activegroup=s'        => \$activegroup,
  'v|verbose'              => \$verbose,
) or warn pod2usage(2);


# Assign a 'value' to each switch
unless ($datacenter) {
  $datacenter="dc2"
};
  
# Connect to database

$dbh = DBI->connect(
  "dbi:SQLite:dbname=$dbfile",
  "",
  "",
  { RaiseError => 1 },
  ) or die "Cannot connect: $DBI::errstr";

# Build query based on switches
$sthSearchDB=$dbh->prepare("
  SELECT hostname
  FROM   nodeprops
  WHERE  datacenter         = ?
  AND    environment        = ?
  AND    node               = ?
  AND    activegroup        = ?
  ");


# Query database
$sthSearchDB->execute($datacenter, $environment, $node, $activegroup);

print Dumper "$sthSearchDB";

# Subroutines
while ( @row = $sthSearchDB->fetchrow_arrayref() ) {
  print "\n$row\n";
}

#
# Configuration Database
#

__END__
