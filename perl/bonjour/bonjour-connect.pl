#!/usr/bin/perl -w

use strict;
use warnings;
use Socket;
use Net::Bonjour;

my $res = Net::Bonjour->new('custom');
$res->discover;

my $entry = $res->shift_entry;

socket SOCK, PF_INET, SOCK_STREAM, scalar(getprotobyname('tcp'));

connect SOCK, $entry->sockaddr;

print SOCK "Send a message to the service";

while ( my $line = <SOCK> ) { print $line };

close SOCK;
