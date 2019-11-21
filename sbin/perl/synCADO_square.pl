#! /usr/bin/env perl -w
use strict;


my $progname = $0;
$progname =~ s/^.*?([^\/]+)$/$1/;

my $usage = "\n";
$usage .=   "Usage: $progname N [options]\n";
$usage .=   "Pads short rows so all rows contain exactly N columns.\n";
$usage .=   "\n";
$usage .=   "       [-p S] Add string S to all padding cells (empty string).\n";

my $pad = "";
my $N   = 0;

while (@ARGV) {
  my $arg=shift;
  if ($arg eq '-h' or $arg eq '-help') {
		die "$usage";
	} elsif ($arg eq '-p' or $arg eq '-pad') {
		defined ($pad = shift) or die "FATAL : Malformed -p argument.\n$usage";
	} else {
		$N = $arg;
	}
}

die "FATAL : target row length N must be a positive integer greater than 0.\n$usage" unless $N =~ /^\d+$/ and $N > 0;


while (my $line = <>) {
	chomp $line;
	next if $line =~ /^\s*$/;
	
	my @cols = split /\t/, $line, -1;
	
	while (scalar @cols < $N) {
		push @cols, "$pad";
	}
	
	print join("\t", @cols) . "\n";
}

exit;

