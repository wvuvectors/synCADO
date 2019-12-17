#! /usr/bin/env perl -w
use strict;


my $progname = $0;
$progname =~ s/^.*?([^\/]+)$/$1/;

my $usage = "\n";
$usage .=   "Usage: $progname TARGET [options]\n";
$usage .=   "Accepts a synCADO family table on STDIN, finds the family ID that includes TARGET, and prints to STDOUT.\n";
$usage .=   "\n";

my $target;

while (@ARGV) {
	my $arg=shift;
	if ($arg eq '-help' or $arg eq "-h") {
		die "$usage";
	} else {
		$target = $arg;
	}
}

die "FATAL : A target is required; this is used to identify the family of interest.\n$usage" unless defined $target;

my $famid = -1;

while (my $line = <>) {
	chomp $line;
	next if $line =~ /^\s*$/;
	
	my @cols = split /\t/, "$line", -1;
	$famid = shift @cols;
	
	my %members = ();
	foreach my $fid (@cols) {
		$members{$fid} = $famid;
	}
	last if defined $members{$target};
}

print "$famid";

exit;

