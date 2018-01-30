#!/usr/bin/perl -w

# This prints out a random 8-character alphanumeric string.
# It can easily be modified to create longer or shorter strings,
# upper-case only, lower-case only, or to include punctuation.

use warnings;
use strict;

my @chars = ("A".."Z", "a".."z", "0".."9");
my $string;
$string .= $chars[rand @chars] for 1..8;

print "String = $string\n";

__END__
