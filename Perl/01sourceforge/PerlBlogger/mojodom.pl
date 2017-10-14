#!/usr/bin/perl
use v5.010;
use Mojo::UserAgent;
use Mojo::DOM;
# Fine grained response handling (dies on connection errors)
my $ua  = Mojo::UserAgent->new;

my $dom = $ua->get( 'http://search.cpan.org/~bdfoy/' )
    ->res
    ->dom;
    
my $dom = Mojo::DOM->new($ua);
say $dom->find('p')->map('text')->join("\n");