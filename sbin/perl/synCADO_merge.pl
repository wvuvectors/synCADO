#! /usr/bin/env perl -w
use strict;


my $progname = $0;
$progname =~ s/^.*?([^\/]+)$/$1/;

my $usage = "\n";
$usage .=   "Usage: $progname KEYFILE COLNUM TABLEFILE2 COLNUM2\n";
$usage .=   "Merges KEYFILE and TABLEFILE2 into a single table using COLNUMS as key. ";
$usage .=   "Key columns will be collapsed into one column. Rows in a table file ";
$usage .=   "with no entries in KEYFILE will not be printed. Writes merge to STDOUT.\n";
$usage .=   "       [-p P]   Rows unique to KEYFILE will be printed after the merge and padded with string P.\n";
$usage .=   "       [-o]     Rows unique to TABLEFILE2 will be printed last.\n";
$usage .=   "       [-nohdr] Strip out all header/comment lines.\n";
$usage .=   "\n";

my @infiles=();
my $pad    ='';
my $outerj =0;
my $nohdr  =0;


while (@ARGV) {
  my $arg=shift;
  if ($arg eq '-h' or $arg eq '-help') {
		die "$usage";
	} elsif ($arg eq '-p' or $arg eq '-pad' or $arg eq '-padding') {
		defined ($pad=shift) or die "$usage";
	} elsif ($arg eq '-o' or $arg eq '-outer' or $arg eq '-outerjoin') {
		$outerj=1;
	} elsif ($arg eq '-nohdr') {
		$nohdr=1;
	} else {
		defined(my $col=shift) or die "missing column\n$usage";
		push @infiles, [$arg,$col];
	}
}

my %data   =();
my $dheader='';

my ($infile,$incol)= @{pop @infiles};

# read in the data file rows and store keyed by values in the defined id col
open my $infh, "$infile" or die "$!";
while (<$infh>) {

	next if /^\s*$/ or (/^#/ and $nohdr);
	chomp;

	if (/^#/) {
		my @h = split /\t/, "$_", -1;
		splice @h, $incol, 1;
		$dheader=join("\t", @h);
		next;
	}
	
	my @a = split /\t/;
	my $key = splice @a, $incol, 1;
	#$key =~ s/\|$//i;
	
	$data{$key}=[] unless defined $data{$key};
	push @{$data{$key}}, join("\t", @a);
}
close $infh;



my %printed_keys=();

# read in the key file rows
my ($keyfile,$keycol)= @{pop @infiles};
open my $keyfh, "$keyfile" or die "$!";
while (<$keyfh>) {
	chomp;
	
	if (/^\s*$/) {
		print "$_\n";
		next;
	}

	next if /^#/ and $nohdr;
	
	my $keyline="$_";
	
	if ($keyline =~ /^#/) {
		print join("\t", $keyline, $dheader) . "\n";
		next;
	}
	
	my @cols = split /\t/, $keyline, -1;
	my $key = $cols[$keycol];
	#$key =~ s/\|$//i;
	
	my $add = '';
	if (defined $data{$key}) {
		$printed_keys{$key}=1;
		foreach my $line (@{$data{$key}}) {
			print join("\t", $keyline, $line) . "\n";
		}
	} else {
		print join("\t", $keyline, "$pad") . "\n";
	}
}
close $keyfh;

#print Dumper(\%printed_keys);
#die;

if ($outerj) {
	foreach my $key (sort keys %data) {
		#$key =~ s/\|$//i;
		unless (defined $printed_keys{$key}) {
			foreach my $line (@{$data{$key}}) {
				print "$key\t" . join("\t", $line) . "\n";
			}
		}
	}
}


exit;

