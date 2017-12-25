#!/usr/bin/perl
#
use strict;
use warnings;

use v5.010;
#use utf-8;
use Mojo::UserAgent;
use LWP::Simple;
use Mojo::DOM;

my $ua = Mojo::UserAgent->new;

fedora();

sub fedora {

    my $res = $ua->get("https://www.imobiliare.ro/vanzare-apartamente/bucuresti");
    my $site_name = $res->result->dom->at('title')->text;
    say "Pret: ". $res->result->dom->at('.pret')->text;
    say $res->result->dom->at('.descriere')->text;
    #say $res->result->dom->find('.descriere last')->text;
    my $box = $res->result->dom->at('.border-box');
    say $box->at('span')->text;
    say "Pret: ".$box->at('.pret-mare')->text;
    say $box->find('li > span')->map('text')->join("\n");
    say $site_name;
}
