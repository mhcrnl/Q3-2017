#!/usr/bin/perl
# file: 02script.pl
# 
use strict;
use warnings;
use 5.020;

use SDL;
use SDL::Version;

my $v = SDL::version;
printf("Version: %d.%d.%d\n", $v->major, $v->minor, $v->patch);


help();

sub help{
    print "Salut!";
}
