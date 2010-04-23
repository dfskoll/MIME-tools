#!/usr/bin/perl -w

use strict;
use warnings;
use Memchmark qw( cmpthese );
use IO::File;
use MIME::Parser;
use Mail::Internet;

my $infile = '/tmp/frag.msg';
my $mp = MIME::Parser->new();
#$mp->tmp_to_core(1);
#$mp->output_to_core(1);
my $fh = IO::File->new("<$infile") or die "no fh $!";
my $mi  = Mail::Internet->new($fh) or die "no mi";

#use Test::Deep;
#use Test::More 'no_plan';
#cmp_deeply(
#	$mp->parse_data([(@{$mi->header}, "\n", @{$mi->body}) ])->stringify(),
#	$mp->parse_data(\(join('', (@{$mi->header}, "\n", @{$mi->body}))))->stringify(),
#	'both parses give same data');

cmpthese(
	'existing'    => sub {
		my @lines  = (@{$mi->header}, "\n", @{$mi->body});
		my $entity = $mp->parse_data(\@lines);
	},
	'scalar'     => sub {
		my $data  = join('', (@{$mi->header}, "\n", @{$mi->body}));
		my $entity = $mp->parse_data(\$data);
	},
	'extra_copy'    => sub {
		my @lines = (@{$mi->header}, "\n", @{$mi->body});
		my $data = join('', @lines);
		my $entity = $mp->parse_data(\$data );
	},
);

