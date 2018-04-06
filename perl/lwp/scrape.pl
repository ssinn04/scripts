#!/usr/bin/perl -w

use strict;
use warnings;

use Getopt::Long;

use LWP;
use LWP::Simple;
use LWP::UserAgent;
use URI::URL;

use Tie::File;

my $hostfile="host.txt";
my @uri;
my $uri_host;
my $verbose;

GetOptions (
  'v|verbose'    => \$verbose
);

tie @uri, 'Tie::File', $hostfile
  or die "Couldn't open $hostfile: $!";

foreach (@uri) {
  $uri_host=url($_);
  print "\nuri host:\t$uri_host\n";
  my $browser = LWP::UserAgent->new();

  my $response = $browser->get(
    '$uri_host')
    or die "Error: $!";
  
  my $content=get($uri_host);
  if ($verbose) { print $content };
}

__END__
