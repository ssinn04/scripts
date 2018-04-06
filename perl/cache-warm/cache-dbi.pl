#!/usr/bin/perl -w

use warnings;
use strict;
use Pod::Usage;
use Getopt::Long;
use Tie::File;
use LWP;
use LWP::Simple;
use LWP::UserAgent;
use URI::URL;
use DBI;
use FileHandle;

# Declare some variables
## DB variables
### We should be using a read-only account to retrieve information from the
### database
### ie the firechief account
my $dbhost;
my $datasource="dbi:Oracle:host=<hostname>;port=<port>;sid=<sid>";
my $db_username="<username>";
my $db_password="<password>";
my @row;

## Relating to the input and output files used by this script
my $infile;
my $outfile;

## Relating to the hosts for which we are requesting information and the URIs
## which we will be using to warm the cache.
my $number_of_uri;
my $host;
my $pool;
my $pod;
my %active_hosts;
my @host;

## Relating to the URI to use when warming the cache
my @uri_list;
my $uri_to_get;
my $store;
my $content;

## Relating to the functioning of this script
my $help;
my $verbose;

# Defines

# Configure our options
Getopt::Long::Configure ( 'auto_help', 'bundling' );
GetOptions (
  'i|infile=s'         => \$infile,
  'o|outfile=s'        => \$outfile,
  'n|number_of_uri=i'  => \$$number_of_uri,
  's|store=s'          => \$store,
  'h|help'             => \$help,
  'v|verbose'          => \$verbose,
) or warn pod2usage(2);

# If the user doesn't assign values through the provided options,
# assign some sane default values.
unless ( $number_of_uri ) {
  $number_of_uri=10;
};
unless ( $infile ) {
  $infile="infile.txt"
};
unless ( $outfile ) {
  $outfile="outfile.txt"
};

# Sanity testing
# We need a test that will dump pod2usage
if ( ! -e $infile ) {
  pod2usage(2);
  warn "Couldn't open $infile: $!"
};

# Connect to the database or die
if ($verbose) { print "\ndatasource:\t$datasource\ndb_username:\t$db_username\ndb_password:\t$db_password\n" };
my $dbh = DBI->connect(
      "$datasource",
      "$db_username",
      "$db_password"
      ) or die "Couldn't connect: " . $DBI::errstr;

# Retrieve hosts from gccmdb using pacific.pl
# tie to the file, $infile, which contains our hosts
if ($verbose) { print "\nInfile: $infile\n" };
tie @host, 'Tie::File', $infile
  or die "Couldn't open $infile: $!";

# Retrieve, from active $host, the top $number_of_uri requests
# Build the query here. We will execute it alter.
my $sth = $dbh->prepare("
    SELECT
       URL, 
       COUNT(*) AS url_count
    FROM
        sit_page_hit
    WHERE
        creation_date >= ( SYSDATE - 1/24 )
    AND URL LIKE '%<searchstring>%'
    GROUP BY URL
    ORDER BY
      url_count DESC
") or warn "Couldn't prepare statement: " . $DBI::errstr;

foreach $host (@host) {
  if ($verbose) { print "\nHost: $host\n" };
  ########################################################
  # Query the database for the top $number_of_uri at $host
  ########################################################
  $sth->execute();
  if ($verbose) { print "\nOutfile: $outfile\n" };
  while ( @row=$sth->fetchrow_array ) {
    # Write the query output to LOGFILE
    open (FH_OUT, ">>$outfile");
    if ($verbose) { print "\nRow:\t@row\n" };
    print FH_OUT "@row\n";
  }
}



__END__

=pod

=head1 NAME

=over

B<cache-warm.pl> - Find some URIs for some active hosts and use them to warm the cache of some inactive hosts.

=back

=head1 SYNOPSIS

 This script should take  3 arguments. The top N URIs used on the relative
active server, the location of an infile and the potential location for an
outfile. The infile would currently be created by pacific.pl. 

=item -n  --number-of-uri

=item -i  --infile

=item -o  --outfile

=head2 OPTIONS

Command examples

=over

=item -i  --infile

EXAMPLE

-i <infile>

--infile <infile>

--infile=<infile>

=back
=over

=item -o  --outfile

EXAMPLE

-o <outfile>

--outfile <outfile>

--outfile=<outfile>

=back

=over
=item -n  --number-of-uri
=back

B<cache-warm.pl> -i foo -o bar -n 10

B<cache-warm.pl> --infile foo --outfile bar --number-of-uri 10

B<cache-warm.pl> --infile=foo --outfile=bar --number-of-uri=10

=over
Retrieves the top 10 most requested URIs for he hosts listed in foo and writes those URIs to bar
=back

=head3 AUTHOR

Spencer J Sinn <ssinn@digitalriver.com>

=cut
