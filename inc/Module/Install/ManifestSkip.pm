#line 1
##
# name:      Module::Install::ManifestSkip
# abstract:  Generate a MANIFEST.SKIP file
# author:    Ingy döt Net <ingy@cpan.org>
# license:   perl
# copyright: 2010, 2011

package Module::Install::ManifestSkip;
use 5.008003;
use strict;
use warnings;

use base 'Module::Install::Base';

our $VERSION = '0.17';
our $AUTHOR_ONLY = 1;

my $skip_file = "MANIFEST.SKIP";

sub manifest_skip {
    my $self = shift;
    return unless $self->is_admin;

    print "manifest_skip\n";

    my $keepers;
    if (-e $skip_file) {
        open IN, $skip_file
            or die "Can't open $skip_file for input: $!";
        my $input = do {local $/; <IN>};
        close IN;
        if ($input =~ s/(.*?\n)\s*\n.*/$1/s and $input =~ /\S/) {
            $keepers = $input;
        }
    }
    open OUT, '>', $skip_file
        or die "Can't open $skip_file for output: $!";;

    if ($keepers) {
        print OUT "$keepers\n";
    }

    print OUT _skip_files();

    close OUT;

    $self->clean_files('MANIFEST');
}

sub _skip_files {
    return <<'...';
^Makefile$
^Makefile\.old$
^pm_to_blib$
^blib/
^pod2htm.*
^MANIFEST\.SKIP$
^MANIFEST\.bak$
^xt/
^\.git/
^\.gitignore
^\.gitmodules
/\.git/
\.svn/
^\.vimrc$
\.sw[op]$
^core$
^out$
^tmon.out$
^.devel-local$
^\w$
^foo.*
^notes
^todo
^ToDo$
## avoid OS X finder files
\.DS_Store$
## skip komodo project files
\.kpf$
## ignore emacs and vim backup files
~$
...
}

1;

