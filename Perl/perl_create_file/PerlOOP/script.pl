#! /usr/bin/perl

use strict;
use warnings;

opendir DIR, ".";
while( my $fn = readdir(DIR)) {
		print $fn , "\n";
	}