#! /usr/bin/env perl -w
use strict;
use POSIX;


my $progname = $0;
$progname =~ s/^.*?([^\/]+)$/$1/;

my $usage =   "\n";
$usage   .= "Usage: $progname CLIST [options]\n";
$usage   .= "Scales the values in columns CLIST in the table on STDIN by the value provided (using -s) and writes the ";
$usage   .= "result to STDOUT.\n";
$usage   .= "       [-s N]   Scaling factor to apply (1).\n";
$usage   .= "       [-r]     Round scaled values to nearest integer (false).\n";
$usage   .= "\n";


my $scale  = 1;
my %opcols = ();
my $round  = 0;
my $last_col2scale;

while (@ARGV) {
  my $arg=shift;
  if ($arg eq '-h' or $arg eq '-help') {
		die "$usage";
  } elsif ($arg eq '-s' or $arg eq "-scale") {
  	defined ($scale=shift) or die "FATAL : malformed -m argument.\n$usage";
  } elsif ($arg eq '-r' or $arg eq '-rd' or $arg eq '-round') {
  	$round = 1;
	} else {
  	my @a = split /,\s*/, $arg;
  	@opcols{@a} = (1) x @a;
  	my @b = sort {$a <=> $b} @a;
  	$last_col2scale = pop(@b);
	}
}

my $row = 0;

while (my $line=<>) {
	$row++;
	
	if ($line =~ /^\s*$/ or $line =~ /^#/) {
		print "$line";
		next;
	}
	chomp $line;

	my @cols = split /\t/, "$line", -1;
	
	if (scalar @cols <= $last_col2scale) {
		warn "WARN  : Not enough columns in line $row ($line).";
		warn "WARN  : The values in line $row have not been scaled!";
		print "$line\n";
		next;
	}
	
	foreach my $colnum (keys %opcols) {
		my $newval = $cols[$colnum] * $scale;
		$newval = floor($newval) if $round == 1;
		$cols[$colnum] = $newval;
	}
			
	print join("\t", @cols) . "\n";
	
}


exit;

