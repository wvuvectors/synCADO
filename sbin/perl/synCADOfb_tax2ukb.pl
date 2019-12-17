#! /usr/bin/env perl -w
use strict;
use LWP::UserAgent;


my $progname = $0;
$progname =~ s/^.*?([^\/]+)$/$1/;

my $usage = "\n";
$usage .=   "Usage: $progname CLADE [options]\n";
$usage .=   "Accepts a list of NCBI taxonomy ids on STDIN and prints a synCADO family table to STDOUT. This utility uses ";
$usage .=   "orthoDB to construct families and requires CLADE, an NCBI taxonomy id that encompasses all of the taxa in ";
$usage .=   "the input set.\n";
$usage .=   "\n";


while (@ARGV) {
	my $arg=shift;
	if ($arg eq "-help" or $arg eq "-h") {
		die "$usage";
	} else {
		$target = $arg;
	}
}


my $base = "https://www.uniprot.org";
my $tool = "uploadlists";

my $params = {
	"from" => "ACC",
	"to" => "P_REFSEQ_AC",
	"format" => "tab",
	"query" => "$ids"
};

# $ids is space-delim set of uniprotkb ids

my $contact = "driscollmml@gmail.com";
my $agent = LWP::UserAgent->new(agent => "libwww-perl $contact");
push @{$agent->requests_redirectable}, "POST";

my $response = $agent->post("$base/$tool/", $params);

while (my $wait = $response->header("Retry-After")) {
#  print STDERR "Waiting ($wait)...\n";
  sleep $wait;
  $response = $agent->get($response->base);
}

if ($response->is_success) {
	print $response->content;
} else {
	die "Failed, got " . $response->status_line . " for " . $response->request->uri . "\n";
}
    
die "FATAL : A target is required; this is used to identify the family of interest.\n$usage" unless defined $target;


while (my $line = <>) {
	chomp $line;
	next if $line =~ /^\s*$/;
	
	my @cols = split /\t/, "$line", -1;
	$famid = shift @cols;
	
	my %members = ();
	foreach my $fid (@cols) {
		$members{$fid} = $id;
	}
	if (defined $members{$target}) {
		print "$famid";
		last;
	}
}

print "-1";

exit;

