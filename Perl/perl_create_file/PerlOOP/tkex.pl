#! /usr/bin/perl

use Tk;
my $mw = new MainWindow; 
my $label = $mw -> Label(-text=>"Hello World") -> pack();
my $button = $mw -> Button(-text => "Quit", 
        -command => sub { exit })
    -> pack();
MainLoop;
