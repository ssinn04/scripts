#!/usr/bin/perl -w

use strict;
use warnings;

use Data::Dumper;
use Getopt::Long;

use LWP;
use LWP::Simple;
use LWP::UserAgent;
use URI::URL;

use Tie::File;

my $hostfile;
my $outfile;
my $help;
my $verbose;

my @uri;
my $uri_host;

Getopt::Long::Configure ( 'auto_help', 'bundling' );
GetOptions (
  'H|hostfile'   => \$hostfile,
  'o|outfile'    => \$outfile,
  'h|help'       => \$help,
  'v|verbose'    => \$verbose,
) or warn pod2usage(2);

# help
if ( $help ) {
  pod2usage(2);
  exit
}

unless ($hostfile) {
  $hostfile="host.txt";
  };

unless ($outfile) {
  $outfile="response.txt";
  };

our $hostname = shift or die "Syntax: $0 hostname\n";
if ($verbose) {
  print Dumper("Hostname:    ".$hostname);
};
our $ua = LWP::UserAgent->new(ssl_opts => { verify_hostname => 0}, );
if ($verbose) {
  print Dumper($ua);
};
our $req = HTTP::Request->new(HEAD => "https://$hostname");
if ($verbose) {
  print Dumper($req);
};
our $resp = $ua->request($req);
if ($verbose) {
  print Dumper($resp);
};

print "           Site: ", $resp->header('Client-SSL-Cert-Subject'), "\n";
print "Cert. Authority: ", $resp->header('Client-SSL-Cert-Issuer'), "\n";
print "         Cipher: ", $resp->header('Client-SSL-Cipher'), "\n";

__END__
