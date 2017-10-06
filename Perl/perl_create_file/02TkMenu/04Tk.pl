#!/usr/bin/perl

use 5.010;
use strict;
use warnings;
use Tk;

my $mw = MainWindow->new;
$mw->geometry("200x150");
$mw->title("Salut");

$mw->Label(-text=>"Salut")->pack();
$mw->Button(-text=>"close", -command=>sub{exit})->pack();
$mw->Button(-text=>'add', -command=>\&adauga)->pack();

MainLoop;

sub adauga{
	$mw->Frame(-background=>'red')->pack(-ipadx=>50, -side=>"left", -fill=>"y");
	}
