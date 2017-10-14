#!/usr/bin/perl
use v5.010;
use Mojo::UserAgent;
use Mojo::DOM;
#-------------------------------------------------------------------VARIABILE
my $site = "https://www.example.com/";


# Fine grained response handling (dies on connection errors)
my $ua  = Mojo::UserAgent->new;
my $get_site = $ua->get($site);
say $get_site;

my $title = $ua->get($site)->result->dom->at('title')->text;
say $title;

my $h1 = $get_site->result->dom->at('h1')->text;
say $h1;

my $p = $get_site->result->dom->at('p')->text;
say $p;

my $style = $get_site->result->dom->at('style')->text;
say $style;

my $meta = $get_site->result->dom->at('p > a')->text;
say $meta;
my $div = $get_site->result->dom->at('div')->text;
say $div;

# Fetch website
my $ua = Mojo::UserAgent->new;
my $res = $ua->get('mojolicious.org/perldoc')->result;

# Extract title
say 'Title: ', $res->dom->at('head > title')->text;

# Extract headings
$res->dom('h1, h2, h3')->each(sub { say 'Heading: ', shift->all_text });

# Visit all nodes recursively to extract more than just text
for my $n ($res->dom->descendant_nodes->each) {

  # Text or CDATA node
  print $n->content if $n->type eq 'text' || $n->type eq 'cdata';

  # Also include alternate text for images
  print $n->{alt} if $n->type eq 'tag' && $n->tag eq 'img';
}
#my $all = $ua->select('*');

use Mojo::UserAgent;
use Mojo::URL;

# Fresh user agent
my $ua = Mojo::UserAgent->new;

# Search MetaCPAN for "mojolicious" and list latest releases
my $url = Mojo::URL->new('http://fastapi.metacpan.org/v1/release/_search');
$url->query({q => 'mojolicious', sort => 'date:desc'});
for my $hit (@{$ua->get($url)->result->json->{hits}{hits}}) {
  say "$hit->{_source}{name} ($hit->{_source}{author})";
}