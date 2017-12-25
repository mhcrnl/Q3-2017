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

$app->add_event_handler(	\&quit_event);

$app->run();

sub quit_event {
	# the callback receives the appropriate SDL::Event
	my ($event, $controller ) = @_;
	# stopping the controller will exit $app->run() for as 
	$controller->stop if $event->type == SDL_QUIT;
}
=pod
my $event = SDL::Event->new();

my $quit = 0;

while (!$quit) {
	SDL::Events::pump_events();
	while (SDL::Events::poll_event($event) ) {
		do_key() if $event->type == SDL_KEYDOWN;
	}
}

sub do_key { $quit = 1; }
=cut