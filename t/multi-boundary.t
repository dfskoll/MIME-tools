#!/usr/bin/perl -w
use strict;
use warnings;
use Test::Deep;
use Test::More tests => 2;

use MIME::Entity;
use MIME::Parser;
use lib qw( ./t );

my $parser = MIME::Parser->new();
$parser->output_to_core(1);

my $entity = $parser->parse_open('testmsgs/double-boundary.msg');
my $ans = $entity->head->mime_attr('content-type.@duplicate_parameters');
cmp_deeply($ans, ['boundary'], 'Duplicate "boundary" parameter was detected in bad message');

$entity = $parser->parse_open('testmsgs/attachment-filename-encoding-UTF8.msg');
$ans  = $entity->head->mime_attr('content-type.@duplicate_parameters');
ok(!defined($ans), 'No duplicate "boundary" parameter was detected in good message');
