#!/usr/bin/perl
use v5.010;
use Mojo::UserAgent;
use Mojo::DOM;
#--------------------------------------------------------------------------Variabile
my $site = "http://perltricks.com/";
my $filename = "PerlTricksOctober.txt";

# Fine grained response handling (dies on connection errors)
my $ua  = Mojo::UserAgent->new;
# my $res = $ua->get('mojolicious.org/perldoc')->result;
# if    ($res->is_success)  { say $res->body }
# elsif ($res->is_error)    { say $res->message }
# elsif ($res->code == 301) { say $res->headers->location }
# else                      { say 'Whatever...' }

# Scrape the latest headlines from a news site
open(my $fh, '>', $filename) or die "Could not open file '$filename' $!";
my $text = $ua->get($site) ->result->dom->find('h2')->map('text')->join("\n");
my $link = $ua->get($site)->result->dom->at('a')->text;
say $text;
say $fh $text;
say $link;


=pod


=cut