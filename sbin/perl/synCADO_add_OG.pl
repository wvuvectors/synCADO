#! /usr/bin/env perl -w
use strict;


my $progname = $0;
$progname =~ s/^.*?([^\/]+)$/$1/;

my $usage = "\n";
$usage .=   "Usage: $progname OG_FILE [options]\n";
$usage .=   "Appends a column containing the OG assignment from OG_FILE to the table on STDIN and prints to STDOUT.\n";
$usage .=   "       [-i N]  Column that holds the accession ids to look up in OG_FILE (0).\n";
$usage .=   "\n";


my $idcol  = 0;
my $ogfile;


while (@ARGV) {
	my $arg=shift;
	if ($arg eq '-help' or $arg eq "-h") {
		die "$usage";
	} elsif ($arg eq '-i' or $arg eq '-idcol') {
		defined ($idcol=shift) or die "FATAL : Malformed -i argument!\n$usage";
	} else {
		$ogfile = $arg;
	}
}

die "FATAL : The value of OG_FILE is not a readable file.\n$usage" unless defined $ogfile and -f $ogfile;
die "FATAL : A column index was passed via -i but it is not a positive integer.\n$usage" unless defined $idcol and $idcol =~ /\d+/;

# map feature ids to OG ids
my %id2og = ();

open my $ogFH, "<", "$ogfile" or die "FATAL : Unable to open OG_FILE $ogfile for reading: $!";
while (my $line = <$ogFH>) {
	chomp $line;
	
	next if $line =~ /^\s*$/;
	
	my ($ogid, $members) = split /\t/, $line, -1;
	$ogid =~ s/^ORTHOMCL(\S+?) .*$/$1/gi;
	
	while ($members =~ /\s(.+?)\((.+?)\)/gi) {
		my $idstr = $1;
		my ($pre1, $fid1, $pre2, $fid2) = split /\|/, $idstr;
		if (defined $fid2 and "$fid2" ne "") {
			$id2og{$fid2} = $ogid;
		} elsif (defined $fid1 and "$fid1" ne "") {
			$id2og{$fid1} = $ogid;
		} else {
			$id2og{$idstr} = $ogid;
		}
	}

}
close $ogFH;

my $linenum = 0;
while (my $line = <>) {
	$linenum++;
	chomp $line;
	
	next if $line =~ /^\s*$/;
	
	if ($line =~ /^#/) {
		print "$line\n";
		next;
	}
		
	my @cols = split /\t/, "$line", -1;
	
	if (scalar(@cols) <= $idcol) {
		warn "WARN  : Input line $linenum has too few columns!";
		warn "WARN  : Line $linenum was printed without modification.";
		print "$line\n";
		next;
	}
	
	my $fid = $cols[$idcol];
	my $ogid = "-1";
	$ogid = $id2og{$fid} if defined $id2og{$fid};
	
	print "$line\t$ogid\n";
	
}

exit;

