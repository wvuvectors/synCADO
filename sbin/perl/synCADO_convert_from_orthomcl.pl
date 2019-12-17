#! /usr/bin/env perl -w
use strict;


my $progname = $0;
$progname =~ s/^.*?([^\/]+)$/$1/;

my $usage = "\n";
$usage .=   "Usage: $progname [options]\n";
$usage .=   "Accepts an orthoMCL .end file of OGs on STDIN and prints a synCADO-friendly sequence family table to STDOUT. ";
$usage .=   "The output from this script can be passed directly to synCADO using the -f argument.\n";
$usage .=   "\n";


my $ogfile;


while (@ARGV) {
	my $arg=shift;
	if ($arg eq '-help' or $arg eq "-h") {
		die "$usage";
	}
}


# map feature ids to OG ids
my %fid2og = ();
# map OG ids to feature ids
my %og2fid = ();

while (my $line = <>) {
	chomp $line;
	
	next if $line =~ /^\s*$/;
	
	my ($ogid, $members) = split /\t/, $line, -1;
	$ogid =~ s/^ORTHOMCL(\S+?) .*$/$1/gi;
	$og2fid{$ogid} = {} unless defined $og2fid{$ogid};
	
	while ($members =~ /\s(.+?)\((.+?)\)/gi) {
		my $idstr = $1;
		my $tax   = $2;
		my ($pre1, $fid1, $pre2, $fid2) = split /\|/, $idstr;
		if (defined $fid2 and "$fid2" ne "") {
			$fid2og{$fid2} = $ogid;
			$og2fid{$ogid}->{$fid2} = 1;
		} elsif (defined $fid1 and "$fid1" ne "") {
			$fid2og{$fid1} = $ogid;
			$og2fid{$ogid}->{$fid1} = 1;
		} else {
			$fid2og{$idstr} = $ogid;
			$og2fid{$ogid}->{$idstr} = 1;
		}
	}
	
}

foreach my $ogid (sort {$a <=> $b} keys %og2fid) {
	print "$ogid\t" . join("\t", keys %{$og2fid{$ogid}}) . "\n";
}


exit;

