#! /usr/bin/perl
use strict;
use warnings;
use Scalar::Util qw(looks_like_number); #almost always useful
use CtoF;

=pod
	 Filename: test.pl 
	 Autor: 'Mihai Cornel mhcrnl@gmail.com'
	 Create time: Tue Oct  3 14:37:41 2017
	 TODO:
=cut
# ===== ENTRY POINT 
print "Salut din perl\n";

my $conv = new CtoF(23);
my $fah = $conv->convertCtoF();
print "$fah\n";

