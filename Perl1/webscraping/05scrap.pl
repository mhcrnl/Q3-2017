#!/usr/bin/perl
#
use strict;
use warnings;

use v5.010;
use Mojo::UserAgent;
use LWP::Simple;
use Mojo::DOM;

my $ua = Mojo::UserAgent->new;

bvb_site();

sub bvb_site{
    my $res = $ua->get("http://www.bvb.ro/");
    my $site_name = $res->result->dom->at('title')->text;
=pod

=cut
    my $bet = $res->result->dom->at('strong > a')->text;
    say $res->result->dom->at('style')->text;
    say $site_name.$bet ;
    my $dom = Mojo::DOM->new($res);

    #say $dom->find('#ctl00_NewAcc')->text;
    say $dom->find('p')->map('text')->join("\n");
}
