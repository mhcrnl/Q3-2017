#!/usr/bin/perl

# Aceasta este o fila de cod perl perlcode.
# Autor: 'Mihai Cornel mhcrnl@gmail.com'

use strict;
use warnings;

use File::Basename qw(dirname);
use Cwd qw(abs_path);
use lib dirname(dirname abs_path $0) . '/Modul';

use Math qw(add);

print "Salut din perl.\n";

print add(23,45);
