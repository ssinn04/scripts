#!/usr/bin/perl -w

use strict;
use warnings;

use Getopt::Long;
use Tie::File;

my $infile="outfile.txt";
my $line;
my @uri_list;
my @uri_to_split;
my $uri_to_grab;

tie @uri_list, 'Tie::File', $infile
  or die "Couldn't open $infile: $!";

# print out the array. We only need the first field.
foreach $line (@uri_list) {
  @uri_to_split = split(/\s+/, $line);
  $uri_to_grab = $uri_to_split[0];
  print "$uri_to_grab"."\n";
}

# We need to grab the top N lines.
# Some of the lines have the same number N occurences
# We should be greedy in grabbing those
