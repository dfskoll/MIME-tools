#!/usr/bin/perl -w -d:TraceUse
use strict;
use warnings;
use Memory::Usage;
use IO::File;
use IO::ScalarArray;
use Benchmark qw( cmpthese );

use lib qw( ../lib );
use MIME::Parser::Reader;
use vars qw( $m );

no warnings qw(redefine once);;
local *MIME::Parser::Reader::read_lines = sub {
    my ($self, $in, $outlines) = @_;
$m->record('before read_chunk');
    $self->read_chunk($in, IO::ScalarArray->new($outlines));
$m->record('after read_chunk');
    shift @$outlines if ($outlines->[0] eq '');   ### leading empty line
    1;
};
use warnings qw(redefine once);;

$m = Memory::Usage->new();
$m->record('initial');
my $infile = '/tmp/frag.msg';
my $rdr = MIME::Parser::Reader->new();
$m->record('instantiated reader');
for(1..10) {
	my $fh = IO::File->new("<$infile"); my @lines; $rdr->read_lines($fh, \@lines); $m->record('direct');
}

$m->dump();
