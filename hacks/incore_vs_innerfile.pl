#!/usr/bin/perl -w

use strict;
use warnings;
use Benchmark ();
use Memchmark ();
use IO::File;
use IO::InnerFile;

#use lib qw( ../lib );
use MIME::Parser;

#my $infile = './testmsgs/frag.msg';
my @infiles = qw(
	data/testmessage-1.msg
	data/testmessage-2.msg
	data/testmessage-3.msg
	data/testmessage-4.msg
	data/testmessage-5.msg
);

my $parser = MIME::Parser->new();
$parser->tmp_dir('/tmp');
$parser->output_to_core(0);

our $infile;
my %to_compare = (
	'io_innerfile' => sub {
		$parser->tmp_to_core(0);
		$parser->use_inner_files(1);
		my $fh = IO::File->new("<$infile");
		my $e = $parser->parse( $fh );
	},
	'io_tocore' => sub {
		$parser->tmp_to_core(1);
		$parser->use_inner_files(0);
		my $fh = IO::File->new("<$infile");
		my $e = $parser->parse( $fh );
	},
	'io_disktmp' => sub {
		$parser->tmp_to_core(0);
		$parser->use_inner_files(0);
		my $fh = IO::File->new("<$infile");
		my $e = $parser->parse( $fh );
	},
);

foreach $infile (@infiles) {
	print "Current input file $infile is " . (-s $infile) . " bytes\n";
	my $pid = fork;
	if(defined $pid and $pid == 0) {
		Memchmark::cmpthese( %to_compare);
		Benchmark::cmpthese( 50, \%to_compare);
		exit(0);
	}
	waitpid($pid, 0);
}
