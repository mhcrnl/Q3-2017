#!/usr/bin/perl
#
use strict;
use warnings;
use v5.010;
use Mojo::UserAgent;
use LWP::Simple;

my $ua = Mojo::UserAgent->new;
my $res = $ua->get("http://www.bvb.ro/");

get_bnr_curs();
get_bvb_index();

sub get_bvb_index{
    say $ua->get("http://www.bvb.ro/")->result->dom->at('title')->text;
    my $bvb_page = LWP::Simple::get("http://www.bvb.ro");
    say $bvb_page =~m/<span id="spBET">(.+?)<\/span>/is;  
    say $ua->get("http://www.bvb.ro/")->result->dom->at('span')->text;





}
sub get_bnr_curs {
    my $page = LWP::Simple::get("http://www.bvb.ro/");
    my $bnr_curs = $ua->get("http://www.bnro.ro/Home.aspx");
    say $bnr_curs->result->dom->at('title')->text;
   # if($page =~m/<span class="date">(.+?)<\/span>/is){
    #    print $1;
    #}
    say $page =~m/<span class="date">(.+?)<\/span>/is;
    say "Tinta Inflatie:".$bnr_curs->result->dom->at('strong')->text;
    say "Inflatie actuala:".$bnr_curs->result->dom->at('li > strong')->text;
    #say $page =~m/<li><strong>(.+?)<\/strong>/is;   
    say "Curs EUR/LEU:".$bnr_curs->result->dom->at('td > span')->text;
    say $bnr_curs->result->dom->at('p')->text;
    
}
