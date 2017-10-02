#!/usr/bin/perl
use strict;
use warnings;
=pod
    File: Phonebook.pl
=cut

use File::Basename qw(dirname);
use Cwd qw(abs_path);
use lib dirname(dirname abs_path $0) . '/PerlPhoneBook';

use PhoneBook qw(run_main);



print "Salut din perl";
run_main();
