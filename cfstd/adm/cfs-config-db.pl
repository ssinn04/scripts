#!/usr/bin/perl -w

use strict;
use warnings;
use Pod::Usage;
use Getopt::Long;
use DBI;


# Define some values
my $dbfile="../cfstd.db";

# Declare some variables
my $auto;
my $batch;
my $instancename;
my $hostname;
my $stagename;
my $datacenter;
my $activegroup;
my $environment;
my $node;
my $sthUpdateNodeprops;

=pod

=head1 NAME

=head1 SYNOPSIS

This is used to update the system database. Its default behaviour is to create a new entry or clobber an exiting entry. Everything is keyed on the hostname.

=head2 OPTIONS

=over

=item B<-A,  --auto>          - Not implemented yet

=item B<-B,  --batch>         - Not implemented yet

=item B<-i,  --instancename>  - cfsapp01, cfsapp02, dnspxapp, etc

=item B<-h,  --hostname>      - The FQDN of the system. Everything keys off this

=item B<-s,  --stagename>     - dev, prd, int, sys, all

=item B<-d,  --datacenter>    - The datacenter (dc1, dc2, c031, dc7, etc) of the system

=item B<-a,  --activegroup>   - The E1 or E2 instance of this system

=back

=head2 AUTHOR

Spencer J Sinn <ssinn@digitalriver.com>

=cut

Getopt::Long::Configure ( 'auto_help', 'bundling' );
GetOptions (
  'A|auto'            => \$auto,
  'B|batch'           => \$batch,
  'i|instancename=s'  => \$instancename,
  'h|hostname=s'      => \$hostname,
  's|stagename=s'     => \$stagename,
  'd|datacenter=s'    => \$datacenter,
  'g|activegroup=s'   => \$activegroup,
  'e|environment=s'   => \$environment,
  'n|node=s'          => \$node,
) or warn pod2usage();

# Interactive - good for onesy-twosy
# get hostname
unless ( $hostname ) {
  print "Enter the hostname. This should be the fully qualified domain name ie dc2cfsdnsprd002.dc2.digitalriver.com:";
  chomp ($hostname=<STDIN>);
};

# get instancename
unless ( $instancename ) {
  print "Enter the instancename ie cfsapp01, cfswps01, dnspxapp:";
  chomp ($instancename=<STDIN>);
};

# get stagename w hints
unless ( $stagename ) {
  print "Enter the stagename name ie dev, prd, sys, all:";
  chomp ($stagename=<STDIN>);
};

# get datacenter
unless ( $datacenter ) {
  print "Enter the datacenter ie dc1, dc2, c031, dc7, all:";
  chomp ($datacenter=<STDIN>);
};

# get activegroup
unless ( $activegroup ) {
  print "Enter the active group ie E1, E2, all:";
  chomp ($activegroup=<STDIN>);
};

# get environment
unless ( $environment ) {
  print "Enter the environment is blah:";
  chomp ($environment=<STDIN>);
};

# get node
unless ( $node ) {
  print "Enter the node ie blah:";
  chomp ($node=<STDIN>);
};

# get propname
# get propvalue

# Batch

# Connect
my $dbh = DBI->connect(
      "dbi:SQLite:dbname=$dbfile",
      "",
      "",
      { RaiseError => 1 },
      ) or die "Cannot connect: $DBI::errstr";

# Does this record exist?

# Update the record
$sthUpdateNodeprops=$dbh->prepare("
  INSERT INTO nodeprops VALUES ('$hostname'
    ,'$instancename'
    ,'$stagename'
    ,'$datacenter'
    ,'$environment'
    ,'$node'
    ,'$activegroup')"
);
$sthUpdateNodeprops->execute();

__END__
  'A|auto'            => \$auto,
  'B|batch'           => \$batch,
  'i|instancename=s'  => \$instancename,
  'h|hostname=s'      => \$hostname,
  's|stagename=s'     => \$stagename,
  'd|datacenter=s'    => \$datacenter,
  'a|activegroup=s'   => \$activegroup,
