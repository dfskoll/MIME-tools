#!/usr/bin/perl
use ExtUtils::MakeMaker;

# Do our own prerequisite checking
# Stolen from Net::FTPServer which stole from libwww-perl
my %modules =
(
 'Mail::Header' =>   { min_version => "1.01" },
 'Mail::Internet' => { min_version => "1.0203" },
 'Mail::Field' =>    { min_version => "1.05" },
 'MIME::Base64' =>   { min_version => "2.21",
		       rec_version => "3.03" },
 'IO::Stringy' =>    { min_version => "1.211" },
 'File::Spec' =>     { min_version => "0.6" },
 'File::Path' =>     { min_version => "1" }
 );

my($m, $foundit, $foundrec, @missing);
@missing = ();
foreach $m (sort keys %modules) {
    $foundit = 0;
    $foundrec = 0;
    my $min_ver = $modules{$m}{min_version};
    my $rec_ver = $modules{$m}{rec_version};
    if (defined($rec_ver)) {
	print "Checking for module $m (version $rec_ver)... ";
	my $eval = "require $m; $m->VERSION >= $rec_ver;";
	my $r = eval($eval);
	if ($@ || !$r) {
	    print "not found.\n --- Fallback: ";
	} else {
	    $foundit = 1;
	    $foundrec = 1;
	    print "ok.\n";
	}
    }
    print "Checking for module $m (version $min_ver)... ";
    my $eval = "require $m; $m->VERSION >= $min_ver;";
    my $r = eval($eval);
    if ($@ || !$r) {
	print "not found.\n";
    } else {
	$foundit = 1;
	print "ok.\n";
    }
    if (defined($rec_ver) and $foundit and !$foundrec) {
	print "\n   *** Warning: We can work with version $min_ver of $m, but\n   *** we recommend that you upgrade to version $rec_ver.\n\n";
    }

    push @missing, "$m: At least version $min_ver" unless $foundit;
}

if ($#missing >= 0) {
    print "*** The following required modules are missing:\n";
    foreach $m (@missing) {
	print "$m\n";
    }
    print "*** Please install them before continuing.\n";
    exit(1);
}

WriteMakefile(
      NAME         => "MIME-tools",
      VERSION_FROM => "lib/MIME/Tools.pm",
      AUTHOR => 'Eryq <eryq@zeegee.com>, David F. Skoll <dfs@roaringpenguin.com>',
      ABSTRACT => 'Tools to manipulate MIME messages',
      'dist'       => {
	  COMPRESS     =>'gzip -f',
	  SUFFIX       =>'gz',
      },
);





