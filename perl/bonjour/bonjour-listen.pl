#!/usr/bin/perl -w
 
# 29jul08 ssinn
# Listens for all bonjour traffic on the network

use strict;
use warnings;
use Net::Bonjour;

foreach my $res ( Net::Bonjour->all_services ) {
	printf "-- %s (%s) ---\n", $res->service, $res->protocol;
	$res->discover;
	foreach my $entry ( $res->entries ) {
		printf "\t%s (%s:%s)\n", $entry->name, $entry->address, $entry->port;
	}
}
