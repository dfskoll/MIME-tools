#!/usr/bin/perl -w
use strict;
use warnings;
use Test::More tests => 3;

use MIME::Entity;
use MIME::Parser;
use lib qw( ./t );

my $e = MIME::Entity->build(From => 'dfs@roaringpenguin.com',
			    To   => 'dfs2@roaringpenguin.com',
			    Subject => 'End-of-line test',
			    Data => ["Line 1\n", "Line 2\n"],);

my $str = $e->as_string();
is ($str, "Content-Type: text/plain\nContent-Disposition: inline\nContent-Transfer-Encoding: binary\nMIME-Version: 1.0\nX-Mailer: MIME-tools 5.509 (Entity 5.509)\nFrom: dfs\@roaringpenguin.com\nTo: dfs2\@roaringpenguin.com\nSubject: End-of-line test\n\nLine 1\nLine 2\n", 'Got expected line endings');

my $delim = "\r\n";
$MIME::Entity::BOUNDARY_DELIMITER = $delim;
$e = MIME::Entity->build(From => 'dfs@roaringpenguin.com',
			    To   => 'dfs2@roaringpenguin.com',
			    Subject => 'End-of-line test',
			    Data => ["Line 1$delim", "Line 2$delim"],);

$str = $e->as_string();

is ($str, "Content-Type: text/plain${delim}Content-Disposition: inline${delim}Content-Transfer-Encoding: binary${delim}MIME-Version: 1.0${delim}X-Mailer: MIME-tools 5.509 (Entity 5.509)${delim}From: dfs\@roaringpenguin.com${delim}To: dfs2\@roaringpenguin.com${delim}Subject: End-of-line test${delim}${delim}Line 1${delim}Line 2${delim}", 'Got expected line endings');

$e->attach(Data => ["More Text$delim"], Type => "text/plain");

$e = MIME::Entity->build(From => 'dfs@roaringpenguin.com',
			 To   => 'dfs2@roaringpenguin.com',
			 Subject => 'End-of-line test',
			 Type => 'multipart/mixed', Boundary => 'foo');
$e->attach(Data => ["Text$delim"], Type => "text/plain");
$e->attach(Data => ["More Text$delim"], Type => "text/plain");
$str = $e->as_string();
is ($str, "Content-Type: multipart/mixed; boundary=\"foo\"${delim}Content-Transfer-Encoding: binary${delim}MIME-Version: 1.0${delim}X-Mailer: MIME-tools 5.509 (Entity 5.509)${delim}From: dfs\@roaringpenguin.com${delim}To: dfs2\@roaringpenguin.com${delim}Subject: End-of-line test${delim}${delim}This is a multi-part message in MIME format...${delim}${delim}--foo${delim}Content-Type: text/plain${delim}Content-Disposition: inline${delim}Content-Transfer-Encoding: binary${delim}${delim}Text${delim}${delim}--foo${delim}Content-Type: text/plain${delim}Content-Disposition: inline${delim}Content-Transfer-Encoding: binary${delim}${delim}More Text${delim}${delim}--foo--${delim}", 'Got expected line endings');

