#! /usr/bin/env perl -w
use strict;
use POSIX;


my $progname = $0;
$progname =~ s/^.*?([^\/]+)$/$1/;

my $usage =   "\n";
$usage   .= "Usage: $progname C [options]\n";
$usage   .= "Collapse consecutive rows that share the same value in column C in the table on STDIN and writes the result to STDOUT. ";
$usage   .= "\n";
$usage   .= "       [-t T] Only collapse more than T consecutive rows that share a value in C (2).\n";
$usage   .= "       [-s M] Scale compressed blocks according to number of features times M. By default, no scaling is applied.\n";
$usage   .= "\n";


my $threshold = 2;
my $collapse_on;
my ($start, $end, $count) = (1,2,8);
my $scale;
my $pad = 10;


while (@ARGV) {
  my $arg=shift;
  if ($arg eq '-h' or $arg eq '-help') {
		die "$usage";
  } elsif ($arg eq '-t' or $arg eq "-threshold") {
  	defined ($threshold=shift) or die "FATAL : malformed -t argument.\n$usage";
  } elsif ($arg eq '-s' or $arg eq "-scale") {
  	defined ($scale=shift) or die "FATAL : malformed -s argument.\n$usage";
	} else {
  	$collapse_on = $arg;
	}
}

die "FATAL : A column index on which to collapse rows (C) is required but was not provided.\n$usage" unless defined $collapse_on;

my @rows2collapse = ();
my $collapse_val;
my $offset = 0;

while (my $line=<>) {
	
	if ($line =~ /^\s*$/ or $line =~ /^#/) {
		print "$line";
		next;
	}
	chomp $line;

	my @cols = split /\t/, "$line", -1;
		
	if (scalar @rows2collapse == 0) {
		push @rows2collapse, \@cols;
		$collapse_val = $cols[$collapse_on];
		next;
	}
	
	if ("$collapse_val" eq "$cols[$collapse_on]") {
		push @rows2collapse, \@cols;
	} else {
		if (scalar @rows2collapse >= $threshold) {
		
			# collapse rows in rows2collapse
			for (my $i=0; $i < scalar(@{$rows2collapse[-1]}); $i++) {
				next if $i == $start or $i == $end;
				$rows2collapse[-1]->[$i] = "$rows2collapse[0]->[$i]-$rows2collapse[-1]->[$i]" unless "$rows2collapse[0]->[$i]" eq "$rows2collapse[-1]->[$i]";
			}
						
			my $old_len = $rows2collapse[-1]->[$end] - $rows2collapse[0]->[$start];
			my $new_len = $old_len;
			if (defined $scale) {
				$new_len = floor(scalar(@rows2collapse) * $scale);
			}
			
			$rows2collapse[-1]->[$start] = $rows2collapse[0]->[$start] - $offset;
			$rows2collapse[-1]->[$end]   = $rows2collapse[-1]->[$start] + $new_len;
			$offset += $old_len - $new_len;

			$rows2collapse[-1]->[$count] = scalar(@rows2collapse);
			print join("\t", @{$rows2collapse[-1]}) . "\n";
		} else {
			# print each individual row in rows2collapse
			foreach my $row (@rows2collapse) {
				$row->[$start] = $row->[$start] - $offset;
				$row->[$end]   = $row->[$end] - $offset;
				print join("\t", @$row) . "\n";
			}
		}
		
		# reinit rows2collapse with the current row and new match value
		@rows2collapse = ();
		push @rows2collapse, \@cols;
		$collapse_val = $cols[$collapse_on];
	}
}


# finish processing any remaining rows in rows2collapse
if (scalar @rows2collapse >= $threshold) {

	# collapse rows in rows2collapse
	for (my $i=0; $i < scalar(@{$rows2collapse[-1]}); $i++) {
		next if $i == $start or $i == $end;
		$rows2collapse[-1]->[$i] = "$rows2collapse[0]->[$i]-$rows2collapse[-1]->[$i]" unless "$rows2collapse[0]->[$i]" eq "$rows2collapse[-1]->[$i]";
	}

	my $old_len = $rows2collapse[-1]->[$end] - $rows2collapse[0]->[$start];
	my $new_len = $old_len;
	if (defined $scale) {
		$new_len = floor(scalar(@rows2collapse) * $scale);
	}
	
	$rows2collapse[-1]->[$start] = $rows2collapse[0]->[$start] - $offset;
	$rows2collapse[-1]->[$end]   = $rows2collapse[-1]->[$start] + $new_len;
	$offset += $old_len - $new_len;

	$rows2collapse[-1]->[$count] = scalar(@rows2collapse);
	print join("\t", @{$rows2collapse[-1]}) . "\n";
} else {
	# print each individual row in rows2collapse
	foreach my $row (@rows2collapse) {
		$row->[$start] = $row->[$start] - $offset;
		$row->[$end]   = $row->[$end] - $offset;
		print join("\t", @$row) . "\n";
	}
}


exit;

