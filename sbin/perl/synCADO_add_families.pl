#! /usr/bin/env perl -w
use strict;


my $progname = $0;
$progname =~ s/^.*?([^\/]+)$/$1/;

my $usage = "\n";
$usage .=   "Usage: $progname FAM_FILE [options]\n";
$usage .=   "Appends a column containing the OG assignment from synCADO families file FAM_FILE to the table on STDIN and ";
$usage .=   "prints the results to STDOUT.\n";
$usage .=   "       [-i N]  Column that holds the ids in the table on STDIN to look up in FAM_FILE (0).\n";
$usage .=   "\n";

my $idcol  = 0;
my $famfile;


while (@ARGV) {
	my $arg=shift;
	if ($arg eq '-help' or $arg eq "-h") {
		die "$usage";
	} elsif ($arg eq '-i' or $arg eq '-idcol') {
		defined ($idcol=shift) or die "FATAL : Malformed -i argument!\n$usage";
	} else {
		$famfile = $arg;
	}
}

die "FATAL : The value of FAM_FILE is not a readable file.\n$usage" unless defined $famfile and -f $famfile;
die "FATAL : A column index was passed via -i but it is not a positive integer.\n$usage" unless defined $idcol and $idcol =~ /\d+/;

# map feature ids to family ids
my %id2fam = ();

open my $famFH, "<", "$famfile" or die "FATAL : Unable to open FAM_FILE $famfile for reading: $!";
while (my $line = <$famFH>) {
	chomp $line;
	
	next if $line =~ /^\s*$/;
	
	my @cols = split /\t/, "$line", -1;
	my $famid = shift @cols;
	
	foreach my $fid (@cols) {
		$id2fam{$fid} = $famid;
	}
}
close $famFH;


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
	my $famid = "-1";
	$famid = $id2fam{$fid} if defined $id2fam{$fid};
	
	print "$line\t$famid\n";
	
}

exit;

