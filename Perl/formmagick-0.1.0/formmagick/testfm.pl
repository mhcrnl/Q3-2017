#!/usr/bin/perl -w

use strict;
use FormMagick;

my $xmlfilename = $ARGV[0];

# a default filename.

if (! $xmlfilename) {
  $xmlfilename = "testfm.xml";
}

my $fm = new FormMagick("file", "./$xmlfilename");

$fm->display();


