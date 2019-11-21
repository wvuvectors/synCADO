#! /usr/bin/env perl -w
use strict;


my $progname = $0;
$progname =~ s/^.*?([^\/]+)$/$1/;

my $usage =   "\n";
$usage   .= "Usage: $progname COLSTART COLEND [options]\n";
$usage   .=   "fixes the table on STDIN so that COLSTART of any row is greater than COLEND of the previous row and writes ";
$usage   .=   "the sorted table to STDOUT.\n";
$usage   .=   "       [-h] print this helpful info.\n";
$usage   .=   "\n";

my $colstart;
my $colend;


while (@ARGV) {
	my $arg=shift;
	if ($arg eq '-h' or $arg eq '-help') {
		die "$usage";
	} else {
		if (defined $colstart) {
			$colend = $arg;
		} else {
			$colstart = $arg;
		}
	}
}

die "$usage" unless defined $colend && defined $colstart;
die "$usage" unless $colstart =~ /\d+/ && $colstart > -1;
die "$usage" unless $colend =~ /\d+/ && $colend > -1;


my @row = ();

while (my $line = <>) {
	next if $line =~ /^\s*$/;
	if ($line =~ /^#/) {
		print "$line";
		next;
	}
	
	chomp $line;
	
	my @cols = split /\t/, "$line", -1;
	if (scalar @row > 0) {
		$row[$colend] = $cols[$colstart]-1 if $row[$colend] > $cols[$colstart];
		print join("\t", @row) . "\n";
		@row = ();
	}
	
	foreach my $val (@cols) {
		push @row, $val;
	}
	
}

print join("\t", @row) . "\n";

exit;

