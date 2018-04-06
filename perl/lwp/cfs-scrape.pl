#!/usr/bin/perl -w

use strict;
use warnings;

use Pod::Usage;
use Getopt::Long;

use LWP;
use LWP::Simple;
use LWP::UserAgent;
use URI::URL;

use FileHandle;
use Tie::File;

my $pidfile = "cfs-scrape.pid";
my $hostfile="cfs-hosts.txt";
my $statusfile="status.txt";
my @uri;
my $uri_host;
my $verbose;
my $timestamp="foo";

# mostly crap
my $instancename;
my $datacenter;
my $activegroup;
my $environment;
my $node;
my $help;


Getopt::Long::Configure ( 'auto_help', 'bundling' );
GetOptions (
  'i|instancename=s'  => \$instancename,
  'H|hostfile=s'      => \$hostfile,
  's|statusfile=s'    => \$statusfile,
  'd|datacenter=s'    => \$datacenter,
  'g|activegroup=s'   => \$activegroup,
  'e|environment=s'   => \$environment,
  'n|node=s'          => \$node,
  'h|help'            => \$help,
  'v|verbose'         => \$verbose,
) or warn pod2usage(2);

# help
if ( $help) {
  pod2usage(2);
  exit
}

# Sanity tests
# Check for a PID file
if ( -e $pidfile) {
  exit;
} else {
  open(PID, ">$pidfile");
  close(PID);
}

open(CLEAR, ">$statusfile");
close(CLEAR);

# Check for a hostfile
tie @uri, 'Tie::File', $hostfile
  or die "Couldn't open $hostfile: $!";

foreach (@uri) {
  $uri_host=url($_);
  if ($verbose) { print "\nuri host:\t$uri_host\n" };
  my $browser = LWP::UserAgent->new();

  my $response = $browser->get(
    '$uri_host')
    or die "Error: $!";

# open the statusfile for writing
open(STATUS, ">>$statusfile")
  or die "Couldn't open $statusfile for writing::$!";
  
  # Parse the content to verification string
  my $content = get($uri_host);

  if ($content =~ m/<Active>TRUE<\/Active>/i) {
    if ($verbose) { print "$uri_host\tActive\n" };
    print STATUS "<tr><td>$uri_host</td><td><img src=\"images/green.gif\"/></td><td>$timestamp</td></tr>"."\n";
    } else {
    print STATUS "<tr><td>$uri_host</td><td><img src=\"images/red.gif\"/></td><td>$timestamp</td></tr>"."\n";
    }
  close(STATUS);
  if ($verbose) { print $content };
}

# Cleanup
unlink $pidfile
  or die "Couldn't unlink $pidfile: $!";

__END__

=pod
=head1 NAME

=head1 SYNOPSIS


=head2 OPTIONS

=over

=item H<-H,  --hostfile      - Declare a hostfile

=back

=head2 AUTHOR

Spencer J Sinn <ssinn@digitalriver.com>

=cut
