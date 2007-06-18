use strict;
use Test::More tests => 18;

use MIME::Body;
use MIME::Tools;
config MIME::Tools DEBUGGING=>0;

#------------------------------------------------------------
# BEGIN
#------------------------------------------------------------

# Check bodies:
my $sbody = new MIME::Body::Scalar;
my $ibody = new MIME::Body::InCore;
my $fbody = new MIME::Body::File "./testout/fbody";

my $buf;
my @lines;
my $line;
my $body;
my $pos;
foreach $body ($sbody, $fbody) {
    my $io;
    my $class = ref($body);

#    diag("Checking class: ", ref($body));

    # Open body for writing, and write stuff:
    $io = $body->open("w");
    ok($io, "$class: opened for writing");
    $io->print("Line 1\nLine 2\nLine 3");
    $io->close;
    
    # Open body for reading:
    $io = $body->open("r");
    ok($io, "$class: able to open body for reading?");

    # Read all lines:
    @lines = $io->getlines;
    ok((($lines[0] eq "Line 1\n") && 
	      ($lines[1] eq "Line 2\n") &&
	      ($lines[2] eq "Line 3")),
	     "$class: getlines method works?"
	     );
	  
    # Seek forward, read:
    $io->seek(3, 0);
    $io->read($buf, 3);
    is($buf, 'e 1', "$class: seek(SEEK_START) plus read works?");

    # Tell, seek, and read:
    $pos = $io->tell;
    $io->seek(-5, 1);
    $pos = $io->tell;
    is($pos, 1, "$class: tell and seek(SEEK_CUR) works?");

    $io->read($buf, 5);
    is($buf, 'ine 1', "$class: seek(SEEK_CUR) plus read works?");

    # Read all lines, one at a time:
    @lines = ();
    $io->seek(0, 0);
    while ($line = $io->getline()) { push @lines, $line }
    ok((($lines[0] eq "Line 1\n") &&
	      ($lines[1] eq "Line 2\n") &&
	      ($lines[2] eq "Line 3")),
	     "$class: getline works?"
	     );
    
    # Done!
    $io->close;


    # Slurp lines:
    @lines = $body->as_lines;
    ok((($lines[0] eq "Line 1\n") &&
	      ($lines[1] eq "Line 2\n") &&
	      ($lines[2] eq "Line 3")),
	     "$class: as_lines works?"
	     );

    # Slurp string:
    my $str = $body->as_string;
    is($str, "Line 1\nLine 2\nLine 3", "$class: as_string works?");
}
    
exit(0);
1;
