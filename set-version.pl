#!/usr/bin/perl
#
# Fix up the version numbers on all subsidiary modules.  Meant for
# internal developer use.
#
# $Id$

use strict;

sub fix_version($$) {
    my($fname, $version) = @_;

    # Ignore main file!
    if ($fname eq "lib/MIME/Tools.pm") {
	return;
    }

    open(IN, "<$fname") or die("Can't open $fname for input: $!");
    open(OUT, ">$fname.new") or die("Can't open $fname.new for output: $!");
    while(<IN>) {
	if (/^\$VERSION =/) {
	    print OUT "\$VERSION = \"$version\";\n";
	    print STDERR "Updated VERSION in $fname\n";
	} else {
	    print OUT;
	}
    }
    close(IN);
    close(OUT);
}

do './lib/MIME/Tools.pm';
my $version = MIME::Tools::version();

open(FIND, "find lib/MIME -name '*.pm'|");
while(<FIND>) {
    chomp;
    fix_version($_, $version);
}
close(FIND);
