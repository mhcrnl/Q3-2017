#! /usr/bin/perl

use strict;
use constant GNUPLOT => '/usr/local/bin/gnuplot';

open(GP, ' | '.GNUPLOT) || die "Gnuplot: $!";
print GP "set terminal gif\n";
print GP "plot sin(x)/cos(x)\n";
close GP;