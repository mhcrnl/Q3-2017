#!/usr/bin/perl
# Mojo::DOM test file 
use strict;
use warnings;
# -------------------------------------------------
use v5.010; #for say
use utf8;
# ------------------------------------------------
use Data::Dumper;
use Mojo::DOM;
#-------------------------------------------------PARSE
my $dom = Mojo::DOM->new('<div><p id="a">Test</p><p id="b">123</p></div>');
#----------------------------------------------------------------Find
say $dom->at('#b')->text;
say $dom->find('p')->map('text')->join("\n");
say $dom->find('[id]')->map(attr => 'id')->join("\n");
say "---------------------------------------------";
# ITERATE
$dom->find('p[id]')->reverse->each(sub { say $_->{id}});
# LOOP
for my $e ($dom->find('p[id]')->each){
    say $e->{id}, ':', $e->text;
}
say "MODIFY------------------------------------------\n";
$dom->find('div p')->last->append('<p id="c">456</p>');
$dom->find(':not (p)')->map('strip');
# --------------------------------------------------------- Afiseaza
say "$dom";
say"Extract all text --------------------------------------";
my $text = $dom->all_text;
say $text;




