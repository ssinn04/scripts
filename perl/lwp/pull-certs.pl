#!/usr/bin/perl -w

use strict;
use warnings;

# Include our local CA bundle
#$ENV{HTTPS_CA_FILE} = "/etc/pki/ca-trust/extracted/pem/tls-ca-bundle.pem";
#$ENV{HTTPS_CA_FILE} = "/etc/pki/ca-trust/extracted/openssl/ca-bundle.trust.crt";

use Data::Dumper;
use Getopt::Long;
use Pod::Usage;

use Net::SSL;
use Net::SSL::ExpireDate;

use LWP;
use LWP::Simple;
use LWP::UserAgent;
use LWP::Protocol::https;

use Mozilla::CA;
use URI::URL;

use Tie::File;

# OPTIONS variables
my $hostname;
my $hostfile;
my $outfile;
my $help;
my $verbose;

my @uri;
my $uri_host;

my $date="fubar";

=pod

=head1 NAME

=head1 SYNOPSIS

This is used to retrieve the host certificates from a user-defined group of hosts.

=head2 OPTIONS

=over

=item B<-t,  --target=<hostname>>          - The target hostname

=item B<-H,  --hostfile=<file.txt>>        - File containing the FQDNs to scan

=item B<-o,  --outfile=<outfile.txt>>      - File to print results

=item B<-v,  --verbose>                    - Print more information

=item B<-h,  --help>                       - Print this cruft

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

my $ua = LWP::UserAgent->new(
  ssl_opts => { SSL_ca_path     => '/etc/ssl/certs',
                verify_hostname => 0,
              },
  );
if ($verbose) {
  print Dumper($ua);
};

my $request = HTTP::Request->new(HEAD => 'https://'.$hostname);
if ($verbose) {
  print Dumper($request);
};

my $response = $ua->request($request);
print $response->content, "\n";
if ($verbose) {
  print Dumper($response);
};

my $ed = Net::SSL::ExpireDate->new( https => $hostname );
if (defined $ed->expire_date) {
  $date = $ed->expire_date;
  if ($verbose) {
    print Dumper($ed);
    print Dumper($date);
  };
};

print "           Site: ", $response->header('Client-SSL-Cert-Subject'), "\n";
print "Cert. Authority: ", $response->header('Client-SSL-Cert-Issuer'), "\n";
print "         Cipher: ", $response->header('Client-SSL-Cipher'), "\n";
print "           Date: ", $date, "\n";

__END__
