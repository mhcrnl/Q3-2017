#! /usr/bin/perl

use LWP::Simple;
use JSON qw(decode_json);
use Data::Dumper;
use strict;
use warnings;

my $trendsurl = "https://graph.facebook.com/?ids=http://www.filestube.com";
my $json = get ( $trendsurl);
die "Could not get $trendsurl!" unless defined $json;

my $decoded_json = decode_json($json);

print Dumper $decoded_json;

print "Shares: ",
	$decoded_json->{'http://www.filestube.com'}{'id'},
	$decoded_json->{'http://www.filestube.com'}{'og_object'}{'id'},
	"\n";