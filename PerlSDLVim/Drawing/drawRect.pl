#!/usr/bin/perl

use strict;
use warnings;

use SDL;
use SDL::Event;
use SDL::Events;
use SDLx::App;

my $app =SDLx::App->new (
	w	=> 500,
	h	=> 500,
	d 	=> 32,
	title	=> 'QUIT EVENTS',
	exit_on_quit => 1,
);

$app->draw_rect([200, 20, 20, 200], [255,255,0,255]);

$app->run();