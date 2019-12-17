#! /usr/bin/env perl -w
use strict;


my $progname = $0;
$progname =~ s/^.*?([^\/]+)$/$1/;

my $usage = "\n";
$usage .=   "Usage: $progname [options]\n";
$usage .=   "Transposes the file on STDIN and writes to STDOUT.\n";
$usage .=   "\n";


while (@ARGV) {
	my $arg=shift;
	if ($arg eq "-help" or $arg eq "-h") {
		die "$usage";
	}
}


my @transp = ();

my $row=0;
while (my $line = <>) {
	chomp $line;
	my @this = split "\t", "$line", -1;
	$transp[$row] = [] unless defined $transp[$row];
	for (my @i=0; $i < scalar(@this); $i++) {
		push @{$transp[$row]}, $v;
	}
	$row++;
}


exit;


1	2	3	4
5	6	7	8

1	5
2	6
3	7
4	8
