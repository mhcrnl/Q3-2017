#!/usr/bin/perl
# ---------------------------------------------------------------------------------
# file: 03script.pl
# Fereastra cu eveniment de inchidere
# SDL::Version : 1.2.15
# SDL::Tutorial - introduction to perl SDL
# site: sdl.perl.org
# ----------------------------------------------------------------------------------
use strict;
use warnings;

use SDL;
use SDL::Event;
# SDLx::App initialize video and create a surface(400x400x16)
use SDLx::App;
use SDLx::Rect;
use SDL::Events;
# --------------------------------------------------------SDL VERSION:
# afiseaza versiunea de program pentru SDL
use SDL::Version;
my $v = SDL::version;
printf("SDL::Version: %d.%d.%d\n", $v->major, $v->minor, $v->patch);
# -------------------------------------------------------------------
SDL::init(SDL_INIT_VIDEO);
my $event = SDL::Event->new();

my $app = SDLx::App->new
		(
			width        => 500,
			height       => 500,
			depth        => 16,
			title        => 'Salut! My SDL Program.',
			exit_on_quit => 1,
		);
# ----------------------------------------------color constant in RGB
# perldoc SDL::Color 
my $COLOR = {
    BLACK      => SDL::Color->new(  0, 100,   0),
    LIGHT_BLUE => SDL::Color->new( 66, 167, 244),
};

sub render_laser {
    my ( $delta, $app ) = @_;
    $app->draw_rect( [ 0, 0, $app->width, $app->height ], $COLOR->{BLACK} );
	#$app->draw_rect ( $patrat->{pat}, $COLOR->{LIGHT_BLUE});
	 $app->draw_circle([100,100], 20, $COLOR->{LIGHT_BLUE});
	
    $app->update();
}

while (1) {
	SDL::Events::pump_events();
	if (SDL::Events::poll_event($event)) {
		if ( $event->type == SDL_MOUSEBUTTONDOWN) {
			$event->button_which;
			$event->button_button;
			$event->button_x;
			$event->button_y;
		}
		last if $event->type == SDL_QUIT;
	}
	# your screen drawing code will be here
	
	$app->add_show_handler ( \&render_laser);

	
}