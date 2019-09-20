#!/usr/bin/perl -w

use DateTime qw();
my $dt = DateTime->now->strftime('%m%d%Y%H%M%S');
print "\n$dt\n";
