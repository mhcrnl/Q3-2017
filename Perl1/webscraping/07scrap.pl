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
my $site = "www.perl.org"; #read this site
my $ua = Mojo::UserAgent->new;
# ----------------------------------------Start Program
print "--------------------------------------------\n";
print "Scrap $site. This start scraping site.\n";
print "--------------------------------------------\n";
perl_org();
# --------------------------------------------Functions
sub perl_org {
    #my $ua = Mojo::UserAgent->new;
    my $res = $ua->get($site);
    # -------------------------Read the name of the site
    my $site_name = $res->result->dom->at('title')->text;
    #------------------------------------Extract p tag from this site
    my @p_tag = $res->result->dom->find('p')->map('text')->join("\n");
    # -----------------------------------Extract h3 tag from this site
    my @h3_tag = $res->result->dom->find('h3')->map('text')->join("\n");
    # -----------------------------------Extract a tag ----------------
    my @a_tag = $res->result->dom->find('a')->map('text')->join("\n");

    my $dom = Mojo::DOM->new($res);
    my $img = $dom->find('img');

    say $res->result->dom->find('[href]')->map(attr => 'href')->join("\n");
    say $site_name;
    say @p_tag;
    say @a_tag;
    say @h3_tag;
    print "----------------------------------------TEXT_ALL______\n";
    say $res->result->dom->all_text;
}




