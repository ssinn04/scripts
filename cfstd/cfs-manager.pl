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
my $dbfile="./cfstd.db";

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

#
# Dropsies
#

####

if ($FIRSTRUN == 0){

  $dbh->do ("DROP TABLE host") || die $dbh->errstr;
  $dbh->do ("DROP TABLE instance") || die $dbh->errstr;
  $dbh->do ("DROP TABLE instancehost_rel") || die $dbh->errstr;

  $dbh->do( "DROP TABLE gcobject_type" ) || die $dbh->errstr;
  $dbh->do( "DROP TABLE gcobject" ) || die $dbh->errstr;
  $dbh->do( "DROP TABLE gcobject_entitydata" ) || die $dbh->errstr;
  $dbh->do( "DROP TABLE gcobjentity_rel" ) || die $dbh->errstr;
  $dbh->do( "DROP TABLE gcobjectobject_rel" ) || die $dbh->errstr;

  $dbh->do( "DROP TABLE gcobjecttrees" ) || die $dbh->errstr;

  $dbh->do( "DROP TABLE gcobjectinstance_rel" ) || die $dbh->errstr;

  $dbh->do ("DROP TABLE propertylist") || die $dbh->errstr;
  $dbh->do ("DROP TABLE propertyvals" ) || die $dbh->errstr;
  $dbh->do ("DROP TABLE propertyobject_rel" ) || die $dbh->errstr;

  $dbh->do ("DROP TABLE passwdproperty_list" ) || die $dbh->errstr;

  $dbh->do ("DROP TABLE propertyvals_template_list") || die $dbh->errstr;

  $dbh->do ("DROP TABLE dbdetails") || die $dbh->errstr;

  $dbh->do ("DROP TABLE dotnet_to_gc_map")  || die $dbh->errstr;

  $dbh->do ("DROP TABLE auditlog") || die $dbh->errstr;

}

####

#
# Create
#
$dbh->do( qq( CREATE TABLE host ( hostname VARCHAR(128),
                                  fqdn VARCHAR(1024),
                                  dc VARCHAR(32),
                                  OS VARCHAR(64),
                                  cpuarch VARCHAR(64),
                                  notes VARCHAR(1024),
                                  host_id INT ) ) ) || die $dbh->errstr;
$dbh->do( "CREATE TABLE instance ( instancename VARCHAR(128),
                                   hostname VARCHAR(128),
                                   stackrole VARCHAR(64),
                                   instance_id INT,
                                   unixuid INT,
                                   unixgid INT )" ) || die $dbh->errstr;
$dbh->do( "CREATE TABLE instancehost_rel (host_id INT,
                                          instance_id INT)" ) || die $dbh->errstr;

$dbh->do( "CREATE TABLE gcobject_type ( typename VARCHAR(128),
                                        type_id INT,
                                        hierarchypos INT )" ) || die $dbh->errstr;

$dbh->do( "CREATE TABLE gcobject ( objectname VARCHAR(256),
                                   shortname VARCHAR(64),
                                   object_type INT,
                                   object_id INT)" ) || die $dbh->errstr;
$dbh->do( "CREATE TABLE gcobject_entitydata ( entityname VARCHAR(256),
                                              entityvalue VARCHAR(1024),
                                              entity_id INT )" ) || die $dbh->errstr;
$dbh->do( "CREATE TABLE gcobjentity_rel ( object_id INT,
                                          entity_id INT)" ) || die $dbh->errstr;
$dbh->do( "CREATE TABLE gcobjectobject_rel ( parent_id INT,
                                             child_id INT,
                                             tree_id INT,
                                             create_date DATE)" ) || die $dbh->errstr;

$dbh->do( "CREATE TABLE gcobjectinstance_rel ( object_id INT,
                                               instance_id INT)" ) || die $dbh->errstr;

$dbh->do( "CREATE TABLE gcobjecttrees (treename VARCHAR(64),
                                       tree_id INT )" ) || die $dbh->errstr;

#
# So, we'd have gcobject types including STAGE, TIER, ACTIVEGROUP, DATACENTER, POOL.
#
# gcobjects would include stage objects called prd, sys, etc.
#
# It would also include multiple 'e1' objects, 'children' of the various stage objects...
#

$dbh->do( "CREATE TABLE propertylist ( propertyname VARCHAR(256),
                                       property_id INT )" ) || die $dbh->errstr;
$dbh->do( "CREATE TABLE propertyvals ( propertyname VARCHAR(256),
                                       property_id INT,
                                       propertyval VARCHAR(2048),
                                       propertyval_id INT)" ) || die $dbh->errstr;
$dbh->do( "CREATE TABLE propertyobject_rel ( object_id INT,
                                             propertyval_id INT,
                                             create_date DATE )") || die $dbh->errstr;

$dbh->do( "CREATE TABLE passwdproperty_list ( property_id INT)") || die $dbh->errstr;

$dbh->do ("CREATE TABLE propertyvals_template_list ( propertyval_id INT )") || die $dbh->errstr;

$dbh->do( "CREATE TABLE dbdetails ( dbname VARCHAR(2048),
                                    dbtype VARCHAR(32),
                                    cxnstring VARCHAR(2048),
                                    dbsid VARCHAR(128),
                                    dbservicename VARCHAR(128),
                                    dbhost VARCHAR(1024),
                                    db_id INT)" ) || die $dbh->errstr;

$dbh->do( "CREATE TABLE dotnet_to_gc_map ( dotnethost VARCHAR (2048),
                                           dotnetport INT,
                                           gchost VARCHAR (2048),
                                           gcport INT)" ) || die $dbh->errstr;

$dbh->do( "CREATE TABLE auditlog ( logdate DATE,
                                   username VARCHAR(1024),
                                   message VARCHAR(2048),
                                   action VARCHAR(10),
                                   subject VARCHAR(1024),
                                   object VARCHAR (1024))" ) || die $dbh->errstr;

$dbh->disconnect;



my $anend = `/bin/date`;

chomp ($astart);
chomp ($anend);

print ("\n\n" . $0 . "\n");
print ("Started:    " . $astart . "\n");
print ("Ended:      " . $anend . "\n\n");

#
# EOF
#


