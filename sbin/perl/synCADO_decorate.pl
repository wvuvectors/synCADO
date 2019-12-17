#! /usr/bin/env perl -w
use strict;


# WHAT IF TARGET IS NOT PRESENT IN THE FAMILIES FILE???!


my $progname = $0;
$progname =~ s/^.*?([^\/]+)$/$1/;

my $usage = "\n";
$usage .=   "Usage: $progname CFG_FILE [options]\n";
$usage .=   "Accepts a synCADO targets config file, adds labels and colors to the feature table on STDIN, and prints to STDOUT.\n";
$usage .=   "       [-c HEXCODE] Use as a color code for off-target families [DEFAULT: f3f3f3].\n";
$usage .=   "\n";


my $cfgFile;
my $defColor = "f3f3f3";
my $defLabel = "-1";


while (@ARGV) {
	my $arg=shift;
	if ($arg eq '-h' or $arg eq '-help') {
		die "$usage";
	} elsif ($arg eq '-c' or $arg eq '-color') {
		defined ($defColor = shift) or die "FATAL : Malformed -c argument!\n$usage";
	} else {
		$cfgFile = $arg;
	}
}

die "$usage" unless defined $cfgFile;


my %fam2label = ();
my %fam2color = ();

open my $cfgFH, "<", "$cfgFile" or die "";
while (my $line = <$cfgFH>) {
	chomp $line;
	next if $line =~ /^#/ or $line =~ /^\s*$/;
	my @cols = split /\t/, "$line", -1;
	$fam2label{$cols[0]} = $cols[1] unless scalar(@cols) < 2 or $cols[1] eq "";
	$fam2color{$cols[0]} = $cols[2] unless scalar(@cols) < 3 or $cols[2] eq "";
}
close $cfgFH;


# store all of the features in the input table as a hash of strings
my %feats = ();
# keep the input order intact using an incrementor
my $pos = 0;

while (my $line = <>) {
	chomp $line;
	next if $line =~ /^#/ or $line =~ /^\s*$/;
	
	my @cols = split /\t/, "$line", -1;
	my $fam_id = $cols[6];
	if (defined $fam2color{$cols[5]}) {
		my $color = $fam2color{$cols[5]};
		$fam2color{$fam_id} = "$color";
		delete $fam2color{$cols[5]};
	}
	if (defined $fam2label{$cols[5]}) {
		my $label = $fam2label{$cols[5]};
		$fam2label{$fam_id} = "$label";
		delete $fam2label{$cols[5]};
	}
	
	$feats{$pos} = "$line";
	$pos++;
}

# print the new features with color and label
foreach my $pos (sort {$a <=> $b} keys %feats) {
	my @cols = split /\t/, "$feats{$pos}", -1;
	my $color = "$defColor";
	$color = "$fam2color{$cols[6]}" if (defined $fam2color{$cols[6]});
	
	my $label = "$defLabel";
	$label = "$fam2label{$cols[6]}" if (defined $fam2label{$cols[6]});
	
	print "$feats{$pos}\t$color\t$label\n";
}

exit;


