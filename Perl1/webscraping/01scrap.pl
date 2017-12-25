#!/usr/bin/perl
#
use strict;
use warnings;
use LWP::Simple;

my $page = LWP::Simple::get("http://www.bvb.ro/");

if($page == /<span id="spBET">(.+?)<\/span>/is){
    print $1;
}

