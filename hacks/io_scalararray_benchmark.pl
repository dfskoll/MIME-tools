#!/usr/bin/perl -w

use strict;
use warnings;
use Benchmark qw( cmpthese );
use Test::More 'no_plan';
use Test::Deep;
use IO::File;
use IO::ScalarArray;

use lib qw( ../lib );
use MIME::Parser::Reader;

no warnings 'once';
local *MIME::Parser::Reader::read_lines_old = sub {
    my ($self, $in, $outlines) = @_;
    $self->read_chunk($in, IO::ScalarArray->new($outlines));
    shift @$outlines if ($outlines->[0] eq '');   ### leading empty line
    1;
};

local *MIME::Parser::Reader::read_lines_new = sub {
    my ($self, $in, $outlines) = @_;

    my $data = '';
    open(my $fh, '>', \$data) or die $!;
    $self->read_chunk($in, $fh);
    @$outlines =  split(/^/, $data);
    1;
};
local *MIME::Parser::Reader::read_lines_re = sub {
    my ($self, $in, $outlines) = @_;

    my $data = '';
    open(my $fh, '>', \$data) or die $!;
    $self->read_chunk($in, $fh);
	while($data =~ m/^(.*?\n)/msg) {
		push @$outlines, $1;
	}
    1;
};
use warnings 'once';

#my $infile = './testmsgs/frag.msg';
my $infile = '/tmp/frag.msg';
my $rdr = MIME::Parser::Reader->new();

my (@old, @new, @re);
my $fh = IO::File->new("<$infile");
$rdr->read_lines_old($fh, \@old);
$fh = IO::File->new("<$infile");
$rdr->read_lines_new($fh, \@new);
$fh = IO::File->new("<$infile");
$rdr->read_lines_re($fh, \@re);

cmp_deeply(
	\@new,
	\@old,
	"Same output (starts with $old[0]") or diag(explain($new[-1], $old[-1]));
cmp_deeply(
	\@re,
	\@old,
	"Same output (starts with $old[0]") or diag(explain($re[-1], $old[-1]));

cmpthese( 100, {
	'with_scalararray' => sub { my $fh = IO::File->new("<$infile"); my @lines; $rdr->read_lines_old($fh, \@lines) },
	'direct' => sub { my $fh = IO::File->new("<$infile"); my @lines; $rdr->read_lines_new($fh, \@lines) },
	'direct_re' => sub { my $fh = IO::File->new("<$infile"); my @lines; $rdr->read_lines_re($fh, \@lines) },
});

