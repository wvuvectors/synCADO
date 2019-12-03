#! /usr/bin/env perl -w
use strict;


my $progname = $0;
$progname =~ s/^.*?([^\/]+)$/$1/;

my $usage = "Usage: $progname [options]\n";
$usage .=   "Converts the NCBI feature table on STDIN to gff format and writes to STDOUT.";
$usage .=   "\n";

while (@ARGV) {
	my $arg=shift;
	if ($arg eq '-h' or $arg eq '-help') {
		print "$usage\n";
		exit;
	}
}

my $chr = "";
my %feat_map = ();
my $this_feat;

my $end = 0;

while (my $line = <>) {
	chomp $line;
	if ($line =~ /^>Feature ref\|(.+?)\|$/) {
		$chr = $1;
		next;
	}
	
	my @a = split /\t/, "$line", -1;
	if (scalar(@a) == 3) {
		my $strand = "+";
		$a[0] =~ s/\D//g;
		$a[1] =~ s/\D//g;
		if ($a[0] > $a[1]) {
			$strand = "-";
			my $swp = $a[1];
			$a[1] = $a[0];
			$a[0] = $swp;
		}
		$feat_map{$a[0]} = {} unless defined $feat_map{$a[0]};
		$feat_map{$a[0]}->{"$a[2]"} = {"end" => $a[1], "strand" => "$strand", "details" => {}};
		$this_feat = $feat_map{$a[0]}->{"$a[2]"}->{"details"};
		$end = $a[1] if $a[1] > $end;
	} elsif (scalar @a == 4) {	
		$this_feat->{"$a[3]"} = "true";
	} elsif (scalar @a == 5) {	
		$this_feat->{"$a[3]"} = "$a[4]";
	}
}

print <<HEAD;
##gff-version 0
#!gff-spec-version 0.0
#!processor synCADO
#!genome-build Unk
#!genome-build-accession Unk
#!annotation-source NCBI
##sequence-region $chr 1 $end
##species Unk
$chr	RefSeq	region	1	$end	.	+	.	ID=id0;Is_circular=true;Name=ANONYMOUS;gbkey=Src;genome=chromosome;mol_type=genomic DNA
HEAD

foreach my $feat_start (sort {$a <=> $b} keys %feat_map) {
	foreach my $feat_type (sort {$b cmp $a} keys %{$feat_map{$feat_start}}) {
		my $feat = $feat_map{$feat_start}->{$feat_type};
		print "$chr	RefSeq	$feat_type	$feat_start	$feat->{'end'}	.	$feat->{'strand'}	.	";
		foreach my $k (keys %{$feat->{"details"}}) {
			print "$k=$feat->{'details'}->{$k};";
		}
		print "\n";
	}
}

exit;
