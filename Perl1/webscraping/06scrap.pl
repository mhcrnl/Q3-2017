#!/usr/bin/perl
# file: 06scrap.pl
# author: mhcrnl@gmail.com
# ! lynx https://engineering.semantics3.com/web-scraping-in-perl-using-mojo-dom-a453229c732f
# ! lynx http://mojolicious.org/
use strict;
use warnings;
# -------------------------------------------------
use v5.010; #for say
use utf8;
# ------------------------------------------------
use Data::Dumper;
use Mojo::DOM;
use Mojo::UserAgent;
# -------------------------------------------Variables
my $site = "https://medium.com/"; #read this site
my $ua = Mojo::UserAgent->new;
# ----------------------------------------Start Program
print "Scrap $site. This start scraping site.\n";
medium();
# --------------------------------------------Functions
sub medium {
    #my $ua = Mojo::UserAgent->new;
    my $res = $ua->get($site);
    # -------------------------Read the name of the site
    my $site_name = $res->result->dom->at('title')->text;
    my $dom = Mojo::DOM->new($res);
    my $img = $dom->find('img');

    say $site_name;
    # print Dumper @img;i
}



