#! /usr/bin/perl
=pod
	this program creates a nil widget 
=cut
package Tk::Nil;
use base qw/Tk::Toplevel/;
Construct Tk::Widget 'Nil';
package main;
use Tk;
use strict;

my $mw = MainWindow->new(-title=>'Nil MW');
my $nil = $mw->Nil(-title => 'Nil object');

$nil->configure(-background => '#d9d9d9');
print '-background =', $nil->cget(-background), "\n";


MainLoop;