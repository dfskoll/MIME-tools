#!/usr/bin/perl -w -d:TraceUse
use strict;
use warnings;
use Memory::Usage;
use IO::File;
use Benchmark qw( cmpthese );

use MIME::Parser;
use vars qw( $m );

$m = Memory::Usage->new();
$m->record('initial');
my $infile = '/tmp/frag.msg';
my $parser = MIME::Parser->new();
$m->record('instantiated reader');
for(1..10) {
	my $fh = IO::File->new("<$infile"); my @lines; $parser->parse($fh); $m->record("Parse, rep $_");
}

$m->dump();
