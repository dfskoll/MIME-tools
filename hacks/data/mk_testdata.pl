#!/usr/bin/perl -w
use strict;
use warnings;
use autodie;
use MIME::Entity;
use IO::File;

my $entity = MIME::Entity->build(
	From => 'devnull@roaringpenguin.com',
	To   => 'devnull@roaringpenguin.com',
	Subject => 'MIME::Parser test message',
	Data  => 'Here are the files you requested!',
);

my @sets = (
	[ '12kb-file.txt' ],
	[ '170kb-file.pdf' ],
	[ '12kb-file.html', '12kb-file.txt' ],
	[ '170kb-file.pdf', '12kb-file.html', '12kb-file.txt' ],
	[ '170kb-file.pdf', '170kb-file.pdf', '170kb-file.pdf', '170kb-file.pdf' ],
);

my %mimetypes = (
	'12kb-file.txt' => 'text/plain',
	'12kb-file.html' => 'text/html',
	'170kb-file.pdf' => 'application/pdf',
);

my $count = 0;
foreach my $set (@sets) {
	$count++;
	my $e = $entity->dup();
	foreach my $file (@$set) {
		$e->attach(
			Path => "./$file",
			Type => $mimetypes{$file},
			Encoding => 'base64',
		);
	}

	my $out = IO::File->new(">testmessage-$count.msg");
	$e->print($out);
	$out->close();
}
