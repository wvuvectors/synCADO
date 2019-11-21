#! /usr/bin/env perl -w
use strict;


my $progname = $0;
$progname =~ s/^.*?([^\/]+)$/$1/;

my $usage = "Usage: $progname FEATURE [options]\n";
$usage .=   "Extracts FEATURE from gff data on STDIN and writes to STDOUT. Accepted values of FEATURE are:\n";
$usage .=   "   l,len,length\n";
$usage .=   "   c,chr,chromosome\n";
$usage .=   "\n";

my $feature = "len";

while (@ARGV) {
	my $arg=shift;
	if ($arg eq 'l' or $arg eq 'len' or $arg eq 'length') {
		$feature = "len";
	} elsif ($arg eq 'c' or $arg eq 'chr' or $arg eq 'chromosome') {
		$feature = "chr";
	}
}

my $len = -1;
my $chr = "";

while (my $line = <>) {
	chomp $line;
	if ($line =~ /^##sequence-region/) {
		my @a = split /\s+/, "$line", -1;
		if ($a[-2] == 1) {
			$len = $a[-1];
			$chr = $a[-3];
			last;
		}
	}
}

my $retval = $len;
$retval = $chr if "$feature" eq "chr";

print "$retval";

exit;
