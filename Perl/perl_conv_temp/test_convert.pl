#! /usr/bin/perl

use Convert::Temperature;

my $conv = new Convert::Temperature();

my $cels = $conv->from_fahr_to_cel('56'); #result in celsius

print "$cels"; 
