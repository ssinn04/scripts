#!/usr/bin/perl -w

use strict;
use warnings;
use Tie::File;

my $words_in='dict.txt';
my $words_out='words.txt';
my $excludes='excludes.txt';
my @excludes_array;
my @dict_array;
my @words_array;
my $word;
my %hash;

tie @dict_array, 'Tie::File', $words_in
	or die "Couldn't tie $words_in: $!";

tie @excludes_array, 'Tie::File', $excludes
	or die "Couldn't open $excludes: $!";

open OUT, '>', $words_out
	or die "Couldn't open $words_out: $!";

for my $word ( @dict_array ) {
	if ( grep ($word eq $_, @excludes_array) ) {
		$hash{$word}++;
	} 
	else {
	push ( @words_array, $word );
	}
}

foreach my $value (@words_array) {
	print OUT "$value\n";
}

close OUT;
	
__END__
