#! /usr/bin/env perl -w
use strict;


my $progname = $0;
$progname =~ s/^.*?([^\/]+)$/$1/;

my $usage =   "\n";
$usage   .= "Usage: $progname CLIST [options]\n";
$usage   .= "Offset the values in columns CLIST in the table on STDIN by the value provided (using -m) and write the ";
$usage   .= "result to STDOUT.\n";
$usage   .= "       [-m M] Offset to apply.\n";
$usage   .= "       [-c C] Treat as a circular entity with length C; this will avoid any negative values.\n";
$usage   .= "\n";


my $offset  = 0;
my %opcols  = ();
my $length  = 0;
my $lastcol;

while (@ARGV) {
  my $arg=shift;
  if ($arg eq '-h' or $arg eq '-help') {
		die "$usage";
  } elsif ($arg eq '-m') {
  	defined ($offset=shift) or die "FATAL : malformed -m argument.\n$usage";
  } elsif ($arg eq '-c' or $arg eq '-circ' or $arg eq '-circular') {
  	defined ($length=shift) or die "FATAL : malformed -c argument.\n$usage";
	} else {
  	my @a = split /,\s*/, $arg;
  	@opcols{@a} = (1) x @a;
  	my @b = sort {$a <=> $b} @a;
  	$lastcol = pop(@b);
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
	
	if (scalar @cols <= $lastcol) {
		warn "WARN  : Not enough columns in line $row ($line).";
		warn "WARN  : Line $row has not been offset!";
		print "$line\n";
		next;
	}
	
	foreach my $colnum (keys %opcols) {
		my $newval = $cols[$colnum] - $offset;
		$newval++ if $newval == 0;
		$newval += $length if $newval < 0;
		$newval = $length if $newval > $length;

		$cols[$colnum] = $newval;
	}
		
	print join("\t", @cols) . "\n";
	
}


exit;

