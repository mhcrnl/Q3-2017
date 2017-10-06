#! /usr/bin/perl

use warnings;
use strict;

use Net::FTP;

my $ftp= Net::FTP->new("ftp.cpan.org")or die "Conectare esuata: $@\n";

$ftp->login("anonymus");
$ftp->cwd("/pub/CPAN");
$ftp->get("README.html");
$ftp->close;
