#!/usr/bin/perl -w

use strict;
use warnings;

use Net::MDNS::Client ':all';

my $q = make_query("host by service", "", "local.", "perl", "tcp");

query( "host by service", $q);

	while (1) {
		if (process_network_events()) {
			while (1) {
			my $res = get_a_result("host by service", $q);
			print "Found host: ", $res, "\n";
			sleep 1;
			}
		}
	}
