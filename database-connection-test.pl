#!/usr/bin/perl -w

use strict;
use warnings;
use DBI;


# Define some values
my $dbname="cfsprd11";
my $dbhost="cfsdbprd022001.c022.digitalriverws.net";
my $dbport="1580";
my $dbuser="cfsuser1";
my $dbpassword="69d5a5a4dfe54be1df8592078de921bc";

# Declare some variables
my $sthSearchNodeprops;
my $query="SELECT dummy FROM dual; ";
my $sthSearchDB;
my @row;
my $row;



# Connect
my $dbh = DBI->connect(
      "dbi:Oracle:dbname=$dbname:$dbhost:$dbport",
      "$dbuser",
      "$dbpassword",
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
    print "$row[0]\n";
  }

# Does this record exist?

__END__
