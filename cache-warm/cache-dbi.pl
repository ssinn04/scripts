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
my $datasource="dbi:Oracle:host=dc2db41.dc2.digitalriver.com;port=1584;sid=ordprd22";
my $db_username="firechief";
my $db_password="spotdog21";
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
    AND URL LIKE '%microsoft%'
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

#sitpagehit v importer
#sitpagehit allows us to collect the most active URLs at the pod level. importer doesn't allow this.
#* Ask a DBA to create a query to grab the top N URIs from HOST
#
#We need to collect the Host header from the top N 
#We need to hit that URL at the webcache layer
#Servers should be receiving cache from the top of the pool
#
#What information do we need to collect to create a 'pre-cache'?
#* We need to collect the Host header for the top N URIs being accessed on the
#* active host. 
#
#What information needs to be in the cache?
#
#What format is most effective for storing the 'pre-cache'?
#* We will store the pre-cache in a flat text file which will be read by the
#* pre-caching program at runtime.
#
#Where will the information for the 'pre-cache' be stored?
#* we will store the pre-cache information in flat text files in a subdirectory
#* of the current working directory.
#
#Active v inactive?

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

CLEAR BREAKS
CLEAR COMPUTES
CLEAR COLUMNS

SET VERIFY OFF
SET PAGESIZE 100
SET LINESIZE 120

COLUMN page_hits FORMAT 999,999
COLUMN avg_latency FORMAT 999.999

COMPUTE AVG LABEL 'Average Latency' OF avg_latency ON REPORT
BREAK ON REPORT

SELECT
        TO_CHAR( TRUNC( creation_date, 'MI' ), 'YYYY-MM-DD HH24:MI:SS' ) AS timestamp,
        COUNT( * ) AS page_hits,
        ( AVG( elapsed_millis ) / 1000 ) AS avg_latency
FROM
        sit_page_hit
WHERE
        creation_date >= ( SYSDATE - 1/24 )
GROUP BY
        TRUNC( creation_date, 'MI' )
ORDER BY
        TRUNC( creation_date, 'MI' ) ASC
