#!/usr/bin/perl -w -d:TraceUse
use strict;
use warnings;
use Memory::Usage;
use IO::File;
use Benchmark qw( cmpthese );

use lib qw( ../lib );
use MIME::Parser::Reader;

use vars qw( $m );

no warnings qw(redefine once);;
local *MIME::Parser::Reader::read_lines = sub {
    my ($self, $in, $outlines) = @_;

$m->record('entered read_lines');
    my $data = '';
    open(my $fh, '>:scalar', \$data) or die $!;
$m->record('Opened scalar fh');
    $self->read_chunk($in, $fh);
$m->record('called read_chunk');
    close $fh;
#    @{$outlines} =  split(/^/, $data);
	while($data =~ m/^(.*)$/msg) {
		push @$outlines, $1;
	}
$m->record('finished split');
    undef $data;
$m->record('undef data');
    1;
};
use warnings qw(redefine once);;

$m = Memory::Usage->new();
$m->record('initial');
$m->record('after IO::scalar');

my $infile = '/tmp/frag.msg';
my $rdr = MIME::Parser::Reader->new();
$m->record('instantiated reader');
for(1..10) {
	my $fh = IO::File->new("<$infile");
	my @lines;
	$rdr->read_lines($fh, \@lines);

}

$m->dump();
