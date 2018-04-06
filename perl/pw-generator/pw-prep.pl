#!/usr/bin/perl -w

use strict;
use warnings;
use Pod::Usage;
use Getopt::Long;
use DBI;
use Data::Dumper;
use Env;

######
=pod

=head1 SYNOPSIS

pw-prep.pl
This program can generally be run without any options. By default, it
creates a password comprised of 2 4-character length dictionary words, 3
digits and 2 matching non-alphanumeric delimiters. This makes the default
minimum password length 4+4+3+2, or 13 characters. Its a good idea to edit
the dictionary file (Default: dict.txt) after its creation, as some words
may be inappropriate to handout to users.

=item -i, --input      Input file. This is wehre aspell places your seed dictionary

Default: words.txt

=item -l, --length      Minimum length of words to add to the dictionary

Default: 4 characters

=item -o, --output      Output file

Default: dict.txt

=cut
######

# Declare some variables
my $words;
my $excludes;
my $dict;
my $wordlength;
my @dict_array;
my $length;
my $randline;
my $num_field;
my $field1;
my $field2;
my $field3;
my $aspell="/usr/bin/aspell"; # Edit accordingly

Getopt::Long::Configure ( 'auto_help', 'bundling' );
GetOptions (
  'i|input=s'  =>	\$ENV{'input'},
  'l|length=i' =>	\$ENV{'wordlength'},
  'o|output=s' =>	\$ENV{'output'},
) or die;

# Define some values
# If these aren't defined by the user at runtime, use the defaults
unless ($ENV{'input'}) {
	$words = "words.txt";
	}
	else {
	$words = $ENV{'input'}
	}
unless ($ENV{'wordlength'}) {
	$wordlength = 4;
	}
	else {
	$wordlength = $ENV{'wordlength'}
	}
unless ($ENV{'output'}) {
	$dict = 'dict.txt';
	}
	else {
	$dict = $ENV{'output'}
	}

my $i=0;
my $linecount=0;

## if our words.txt file exists, zero it out
if ( ! -e $aspell ) {
	die "Couldn't find aspell.\n";
	}
system ("$aspell dump master > $words");

# If our dict.txt file exists, zero it out
if (-e $dict) {
	open(ZERO, ">$dict")
		or die $!;
}
close(ZERO);

open(INFO, $words)
	or die $!;
@dict_array = <INFO>;
chomp(@dict_array);

while($dict_array[$i]) {
	$dict_array[$i] =~ s/\'//;
	$length=length($dict_array[$i]);
	if ($dict_array[$i] =~ m/\W/) {
		$i++;
	} elsif ( $length >= $wordlength ) {
	open(DICT, ">>$dict")
		or die $!;	
	print DICT $dict_array[$i]."\n"
		or die $!;
	$i++;
	}
	else {
	$i++;
	}
}
close(INFO);
close(DICT);

__END__

# TODO
Create a file of excluded words.
Use the excluded words to tidy the words.txt file

Create a subroutine to write the words to an sqlite database.

my $database = "pwdb.db";
my $dbh = DBI->connect(
		"DBI:SQLite:$database",
		"",
		"",
		{RaiseError => 1},
		) or die "Unable to connect: $DBI::errstr;

my $CreatePWdb=$dbh->prepare("
	CREATE TABLE dictwords
		(key int
		,value char(250))"
		);
$CreatePWdb->execute();
