#!/usr/bin/perl -w

use strict;
use warnings;

use Data::Dumper;
use Getopt::Long;
use Pod::Usage;

use LWP;
use LWP::Simple;
use LWP::UserAgent;
use URI::URL;

use Tie::File;

my $hostname;
my $hostfile;
my $outfile;
my $help;
my $verbose;

my @uri;
my $uri_host;

=pod

=head1 NAME

=head1 SYNOPSIS

This is used to retrieve the host certificates from a user-defined group of hosts.

=head2 OPTIONS

=over

=item B<-H,  --hostfile=<file.txt>>     - File containing the FQDNs to scan

=item B<-o,  --outfilei=<outfile.txt>>      - File to print results

=item B<-v,  --verbose>      - Print more information

=item B<-h,  --help>         - Print this cruft

=back

=head2 AUTHOR

Spencer J Sinn <spencer.sinn@gmail.com>

=cut


Getopt::Long::Configure ( 'auto_help', 'bundling' );

GetOptions (
  't|target=s'     => \$hostname,
  'H|hostfile=s'   => \$hostfile,
  'o|outfile=s'    => \$outfile,
  'h|help'         => \$help,
  'v|verbose'      => \$verbose,
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

# If $hostname isn't called or defined, default to $hostfile
# If $hostfile doesn't exist or is unreadle, exit with some error.
# Create an option to test the validity of the hostname before connecting
# Create an 'its alive' option before connecting

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
