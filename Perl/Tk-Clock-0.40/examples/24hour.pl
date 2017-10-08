#!/usr/bin/perl

# A weird clock where the hour hand uses a 24-hour scale
use Tk;
use Clock;

my $m = MainWindow->new;

#my $but0 =$m->Button(-text => "Close", -command => \&b_exit)->pack();

my $c = $m->Clock->pack (-expand => 1, -fill => "both");
my $but0 =$m->Button(-text => "Close", -command => \&b_exit)->pack();
#$m->$but0->pack;

$c->config (
    anaScale  => 250,
    ana24hour => 1,
    tickFreq  => 2.5,
    useLocale => "C",
    )->config (anaScale => 0);

MainLoop;

sub b_exit {
    exit;
    }