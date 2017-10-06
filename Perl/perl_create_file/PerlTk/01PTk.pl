#! /usr/bin/perl
use strict;
use warnings;
use Tk;
=pod
RESURSE:
    http://bin-co.com/perl/perl_tk_tutorial/perl_tk_tutorial.pdf
RUN:
    $ perl 01PTk.pl
    
=cut
my $mw = new MainWindow; 
my $label = $mw -> Label(-text=>"Hello World") -> pack();
my $button = $mw -> Button(-text => "Quit", 
        -command => sub { exit })
    -> pack();
MainLoop;
