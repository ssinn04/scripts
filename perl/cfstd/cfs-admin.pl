#!/usr/bin/perl -w

use warnings;
use strict;
use DBI;

# includes

# variables
my $todo;
my $instancename;
my $hostname;
my $stagename;
my $datacenter;
my $activegroup;
my $environment;
my $node="";
my $dbfile="<dbname>";
my $sthUpdateNodeprops;
my $sthEditNode;
my @NodeInfo;
my $sthUpdateNode;
my @hostname;
my @instancename;
my $key_NodeInfo;
my %hash_NodeInfo;


# Connect 
my $dbh = DBI->connect(
  "dbi:SQLite:dbname=$dbfile",
  "",
  "",
  { RaiseError => 1 },
  ) or die "Cannot connect: $DBI::errstr";

# Main body
until ( $todo eq '0' ) {
  print "\nDo you want to\n";
  print "\t0) Quit\n";
  print "\t1) Create a node\n";
  print "\t2) Edit a node\n";
  print "\t3) Delete a node\n";
  print "\nYour command> ";
  chomp($todo=<STDIN>);

  if ( $todo eq '0' ) {
    exit;
  } elsif ($todo eq '1') {
    &NewNode;
  } elsif ($todo eq '2') {
    &EditNode;
  } elsif ($todo eq '3') {
    &DeleteNode;
  } else {
    print "\nI don't understand.\n";
    print "\nExiting.\n";
    exit;
  }
}

sub NewNode {
  print "\nEnter the fqdn\n";
  chomp($hostname=<STDIN>);
  print "\ninstancename\n";
  chomp($instancename=<STDIN>);
  print "\nstagename\n";
  chomp($stagename=<STDIN>);
  print "\ndatacenter\n";
  chomp($datacenter=<STDIN>);
  print "\nenvironment\n";
  chomp($environment=<STDIN>);
  print "\nactivegroup\n";
  chomp($activegroup=<STDIN>);

    $sthUpdateNodeprops=$dbh->prepare("
    INSERT INTO nodeprops
    VALUES
    ('$hostname'
    ,'$instancename'
    ,'$stagename'
    ,'$datacenter'
    ,'$environment'
    ,'$node'
    ,'$activegroup')
    ");
    $sthUpdateNodeprops->execute();
  } # End of &NewNode

sub EditNode {
  # Get the hostname from user
  print "\nEnter the fqdn\n";
  chomp($hostname=<STDIN>);

  # SELECT hostname
  $sthEditNode=$dbh->prepare("
    SELECT *
    FROM nodeprops
    WHERE hostname='$hostname'
    ");
  $sthEditNode->execute();
  while ( @NodeInfo = $sthEditNode->fetchrow_array() ) {
    print "\nNodeInfo:\t (@NodeInfo) \n";
    }

  # Since this can return more than one value, we will need to push each
  # value into its own array, and allow the user to select which one they
  # would like to edit.
  # SELECT instancename
  $sthEditNode=$dbh->prepare("
    SELECT instancename 
    FROM nodeprops
    WHERE hostname='$hostname'
    ");
  $sthEditNode->execute();

  while ( @NodeInfo = $sthEditNode->fetchrow_array() ) {
    $key_NodeInfo=$NodeInfo[0];
    $hash_NodeInfo{$key_NodeInfo} = "@NodeInfo";
    print "$key_NodeInfo)\t $hash_NodeInfo{$key_NodeInfo}\n";
    # print "\ninstancename (@NodeInfo) : ";
    }
  chomp($instancename=<STDIN>);
  if ($instancename) {
    print "\ninstancename = $instancename\n";
    $sthUpdateNode=$dbh->prepare("
      UPDATE nodeprops
      SET
        instancename = ?
        WHERE hostname = ?
      ");
      $sthUpdateNode->execute($instancename, $hostname);
    } else {
    print "\n@hostname hasn't changed.\n";
    }
  } # End of &EditNode

sub DeleteNode {
  } # End of &DeleteNode
