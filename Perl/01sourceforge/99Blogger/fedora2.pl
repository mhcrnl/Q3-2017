#!/usr/bin/perl -w

use strict;
use LWP::Simple;

my $url = "https://start.fedoraproject.org/";
my $file = "index.html";

my $fedorasite = get($url);

my $head = head($url);
my $code = getprint($url);
my $scode = getstore($url, $file);
print "$scode";
