#!/usr/bin/perl
#
use strict;
use warnings;

use v5.010;
use Mojo::UserAgent;
use LWP::Simple;
use Mojo::DOM;

my $ua = Mojo::UserAgent->new;

fedora();

sub fedora {

    my $res = $ua->get("https://start.fedoraproject.org/");
    my $site_name = $res->result->dom->at('title')->text;
    
    say $site_name;
}
