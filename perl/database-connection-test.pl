#!/usr/bin/perl -w

use strict;
use warnings;
use DBI;


# Define some values
my $dbname="<dbname>";
my $dbhost="<dbhost>";
my $dbport="<dbport>";
my $dbuser="<dbuser>";
my $dbpassword="<dbpassword>";

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
