#!/usr/bin/perl
use strict;
use warnings;
use File::Basename qw(dirname);
use Cwd qw(abs_path);
use lib dirname(dirname abs_path perlcode.pl) . '/Modul';
use Math qw(add);
print "Salut din perl.";
