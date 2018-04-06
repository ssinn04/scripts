#!/usr/bin/perl -w

use strict;
use warnings;
use DBI;
use Digest::MD5 qw(md5_hex);
use Digest::SHA qw(sha1_hex sha256_hex);
use Getopt::Long;

# Declare some variables
my @array;
my $length;
my $randline;
my $num_field;
my @delim_array;
my $delim;
my $field1;
my $field2;
my $field3;


# Define some values
my $words = 'words.txt';
my $dict = 'dict.txt';
my $i=0;
my $linecount=0;

# scrap this section
open(DICT, $dict)
	or die $!;
@array = <DICT>;
chomp(@array);
close(DICT);

# Use some SQL to get the number of rows.
# Get the linecount from $dict
open(COUNT, "< $dict")
	or die $!;
while(<COUNT>) {
	$linecount++;
}
close(COUNT);
	
# Keep this
# Random number, 1-3
my $rand3 = int(rand(3)+1);
&random_int;
my $delim_rand = int(rand(8));

# Rewrite this to use a SELECT statement to graab fieldN
if ($rand3 == 1) {
	&random_field;
	$field1=$array[$randline];
	&random_field;
	$field2=$array[$randline];
	&random_int;
	$field3=$num_field;
	} elsif ($rand3 == 2) {
	&random_field;
	$field1=uc($array[$randline]);
	&random_int;
	$field2=$num_field;
	&random_field;
	$field3=$array[$randline];
	} elsif ($rand3 == 3) {
	&random_field;
	$field1=$array[$randline];
	&random_field;
	$field2=uc($array[$randline]);
	&random_int;
	$field3=$num_field;
}

# Keep this
@delim_array = ( "-", ":", "_", "+", "=", '$', "@", "%", "!" );
$delim = $delim_array[$delim_rand];

my $password="$field1$delim$field2$delim$field3";
print "\nPlain:\t".$password."\n";
print "MD5:\t", md5_hex("$password"), "\n";
print "SHA1:\t", sha1_hex("$password"), "\n";
print "SHA256:\t", sha256_hex("$password"), "\n";

# rewrite this to generate a random number based on the number of rows in the database
sub random_field {
	# Random number, based on line count
	$randline = int(rand($linecount));
	$randline;
}

# Keep this
sub random_int {
	# Random number, 001 to 999
	$num_field = int(rand(99)+1);
	$num_field = sprintf("%03d", $num_field);
}

__END__

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
