#!/usr/bin/perl -w

use strict;
use warnings;

use Getopt::Long;

use LWP;
use LWP::Simple;
use LWP::UserAgent;
use URI::URL;

use Tie::File;

# declarations
my $hostfile;
my @uri;
my $uri_host;
my $verbose;
my $result;

# definitions
my @akamai_domain=( "<fqdn01>",
                    "<fqdn02>",
                    "<fqdn03>",
                    "<fqdn04>" );

GetOptions (
  'h|hostfile'   => \$hostfile,
  'v|verbose'    => \$verbose
);

unless($hostfile) {
  $hostfile="host.txt";
};

tie @uri, 'Tie::File', $hostfile
  or die "Couldn't open $hostfile: $!";

foreach (@uri) {
  $uri_host=url($_);
  if ($verbose) { print "\nuri host:\t$uri_host\n" };
  my $browser = LWP::UserAgent->new();

  my $response = $browser->get(
    '$uri_host')
    or die "Error: $!";
  
  my $content=get($uri_host);
  if ($verbose) { print $content };

  foreach (@akamai_domain) {
    print "\n$_\n";
    $result =~ m/$_/;
    print "\n$result\n";
  }
}

__END__
