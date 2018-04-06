#!/usr/bin/perl -w

use strict;
use warnings;
use DBI;

# Declare some variables
my $words="words.txt";

# Defines

# Sanity tests

# Do we have the words.txt file?
if ( ! -e $words ) {
	print "$words not found: $!";
}

# Does the database already exist?
my $database = "pwdb.db";
if ( -e $database ) {
	# Do something
	# What do we do if the database already exists?
}

# Create a new database
my $dbh = DBI->connect(
		"DBI:SQLite:$database",
		"",
		"",
		{RaiseError => 1},
		) or die "Unable to connect: $DBI::errstr";

my $CreatePWdb = $dbh->prepare("
	CREATE TABLE dictwords
		(key int
		,value char(250))"
		);
$CreatePWdb->execute();

# Iterate through words.txt
# For each word, add word to the database as a value to
# an incremental numeric key
open(INFILE, "$words")
	or die "Couldn't open $words: $!";
my $i=1;
while (<INFILE>) {
	my $sth = $dbh->prepare("
		INSERT INTO dictwords(key,value) VALUES (?, ?)");
	$sth->execute($i, $_);
	$i++;
}
__END__
