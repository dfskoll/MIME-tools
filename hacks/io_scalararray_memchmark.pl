#!/usr/bin/perl -w

use strict;
use warnings;
use Memchmark qw( cmpthese );
use IO::File;

use lib qw( ../lib );
use MIME::Parser::Reader;

no warnings 'once';
local *MIME::Parser::Reader::read_lines_old = sub {
    my ($self, $in, $outlines) = @_;
    # TODO: we are also stuck keeping this one for now
    $self->read_chunk($in, IO::ScalarArray->new($outlines));
    shift @$outlines if ($outlines->[0] eq '');   ### leading empty line
    1;
};

local *MIME::Parser::Reader::read_lines_new = sub {
    my ($self, $in, $outlines) = @_;

    my $data = '';
    open(my $fh, '>', \$data) or die $!;
    $self->read_chunk($in, $fh);
    close $fh;
    @$outlines =  split(/^/, $data);
    undef $data;
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

cmpthese(
	'direct' => sub { my $fh = IO::File->new("<$infile"); my @lines; $rdr->read_lines_new($fh, \@lines) },
	'direct_re' => sub { my $fh = IO::File->new("<$infile"); my @lines; $rdr->read_lines_re($fh, \@lines) },
	'with_scalararray' => sub {
		eval 'use IO::ScalarArray;';
		my $fh = IO::File->new("<$infile"); my @lines; $rdr->read_lines_old($fh, \@lines);
	},
);

