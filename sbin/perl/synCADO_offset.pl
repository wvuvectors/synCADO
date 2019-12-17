#! /usr/bin/env perl -w
use strict;


my $progname = $0;
$progname =~ s/^.*?([^\/]+)$/$1/;

my $usage =   "\n";
$usage   .= "Usage: $progname [options]\n";
$usage   .= "Offset the start and end coordinates in the synCADO table on STDIN by the coordinate of the anchor feature ";
$usage   .= "as defined by -a, and write the results to STDOUT.\n";
$usage   .= "       [-a A] family Id of the anchor ortholog [DEFAULT: no offset applied].\n";
$usage   .= "       [-c C] Treat as a circular entity with length C; this will avoid any negative offsets.\n";
$usage   .= "       [-l L] Length of the genome.\n";
$usage   .= "\n";


my $anchorFamily;
my @opcols   = (1,2);
my $circular = 0;
my $length   = 0;


while (@ARGV) {
  my $arg=shift;
  if ($arg eq '-h' or $arg eq '-help') {
		die "$usage";
	} elsif ($arg eq '-a' or $arg eq '-anchor') {
	 	defined ($anchorFamily=shift) or die "FATAL : malformed -a argument.\n$usage";
	 } elsif ($arg eq '-c' or $arg eq '-circ' or $arg eq '-circular') {
	 	$circular = 1;
	} elsif ($arg eq '-l' or $arg eq '-len' or $arg eq '-length') {
	 	defined ($length=shift) or die "FATAL : malformed -l argument.\n$usage";
	}
}


# store all of the features in the input table as a hash of strings
my %feats = ();

# keep the input order intact using an incrementor
my $pos = 0;

# find the offset amount (the start of the anchorFamily member)
# no offset (0) is applied if the family does not exist in this genome
my $offset = 0;
while (my $line=<>) {
	chomp $line;
	next if $line =~ /^#/ or $line =~ /^\s*$/;

	my @cols = split /\t/, "$line", -1;
	my $fam_id = $cols[6];
	
	$length = $cols[2] unless $length > $cols[2];
	
	$offset = $cols[1] if defined $anchorFamily and $fam_id == $anchorFamily;
	$feats{$pos} = "$line";
	$pos++;
}

# now apply the offset to start and end positions of each feature in the input
foreach my $pos (sort {$a <=> $b} keys %feats) {
	my @cols = split /\t/, "$feats{$pos}", -1;
	
	foreach my $colnum (@opcols) {
		my $newval = $cols[$colnum] - $offset;
		$newval++ if $newval == 0;
		
		if ($circular == 1) {
			$newval += $length if $newval < 0;
			$newval = $length if $newval > $length;
		}
		
		$cols[$colnum] = $newval;
	}
		
	print join("\t", @cols) . "\n";
	
}


exit;

