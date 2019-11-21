#! /usr/bin/env perl -w
use strict;


my $progname = $0;
$progname =~ s/^.*?([^\/]+)$/$1/;

my $usage =   "\n";
$usage   .= "Usage: $progname COLNUM [options]\n";
$usage   .=   "sorts the table on STDIN by the values in COLNUM in ascending order, ";
$usage   .=   "and writes the sorted table to STDOUT.\n";
$usage   .=   "       [-h] print this helpful info.\n";
$usage   .=   "       [-d] sort in descending order.\n";
$usage   .=   "       [-n] sort values in COLNUM as numbers, not strings.\n";
$usage   .=   "\n";

my $colnum;
my $desc   =0;
my $numeric=0;

while (@ARGV) {
	my $arg=shift;
	if ($arg eq '-h' or $arg eq '-help') {
		die "$usage";
	} elsif ($arg eq '-a' or $arg eq '-asc' or $arg eq '-ascend') {
		$desc=0;
	} elsif ($arg eq '-d' or $arg eq '-desc' or $arg eq '-descend') {
		$desc=1;
	} elsif ($arg eq '-n' or $arg eq '-num' or $arg eq '-numeric') {
		$numeric=1;
	} else {
		$colnum=$arg;
	}
}

die "$usage" unless defined $colnum && $colnum =~ /\d+/ && $colnum > -1;


my @rows = ();

while (my $line = <>) {
	next if $line =~ /^\s*$/;
	if ($line =~ /^#/) {
		print "$line";
		next;
	}
	
	chomp $line;
	
	my @cols = split /\t/, "$line", -1;
	push @rows, {"row"=>"$line", "val"=>$cols[$colnum]};
}

#my @sorted = sort {$b->{"val"} <=> $a->{"val"}} @rows;
if ($desc) {
	if ($numeric) {
		for my $hash (sort {$b->{"val"} <=> $a->{"val"}} @rows) {
			print "$hash->{row}\n";
		}
	} else {
		for my $hash (sort {$b->{"val"} cmp $a->{"val"}} @rows) {
			print "$hash->{row}\n";
		}
	}
} else {
	if ($numeric) {
		for my $hash (sort {$a->{"val"} <=> $b->{"val"}} @rows) {
			print "$hash->{row}\n";
		}
	} else {
		for my $hash (sort {$a->{"val"} cmp $b->{"val"}} @rows) {
			print "$hash->{row}\n";
		}
	}
}


exit;

