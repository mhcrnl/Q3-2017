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
# is also a controller
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
# --- Adauga un patrat in fereastra
my $patrat = {
	pat 	=> SDLx::Rect->new($app->h/2, $app->w-20, 40, 10),
	x	=> 0,
	y	=> 0,
	w 	=> 20,
	h 	=> 80,
	vel	=> 250,
	y_vel=> 0,
};
 my $minge = {
	#min => SDLx::Cercle->new($app->h/2, $app->w/2, 10, 10),
 };
# --------------------------------------------------------EVENTS:
$app->add_event_handler( \&quit_event);
$app->add_event_handler( \&stop);
$app->add_event_handler(\&pause);
$app->add_show_handler ( \&render_laser);
$app->add_move_handler(\&move_patrat);
$app->run;
# ----------------------------------------------------------------FUNCTIONS:
# guit_event - inchide fereastra apasand pe x dreapta sus
# render_laser - afiseaza fereastra 
# pause - p opreste rularea programului si intra in pauza p/p
sub move_patrat {
	my ( $step, $app, $t ) = @_;
	$patrat->{x} = ( $patrat->{vel} * $step);
	$patrat->{y} = ( $patrat->{y_vel} * $step);
	
	$app->update();
}

# --------------------------------------------------------------pause
sub pause {
	# press P to toggle pause
	my ($e, $app ) = @_;
	if ( $e->type == SDL_QUIT ) {
		$app->stop;
		# quit handling is here so that the app can be stopped while paused
	}
	elsif ( $e->type == SDL_KEYDOWN) {
		if($e->key_sym == SDLK_p) {
			# we're paused, so end paused
			return 1 if $app->paused;
			# We're not paused, so pause
			$app->pause(\&pause);
		}
	}
	return 0;
}
# --------------------------------------------------render_laser
sub stop {
	my ( $event, $app ) =@_;
	if ($event->type == SDL_QUIT) {
		$app->stop;
	}
}
sub render_laser {
    my ( $delta, $app ) = @_;
    $app->draw_rect( [ 0, 0, $app->width, $app->height ], $COLOR->{BLACK} );
	$app->draw_rect ( $patrat->{pat}, $COLOR->{LIGHT_BLUE});
	 $app->draw_circle([100,100], 20, $COLOR->{LIGHT_BLUE});
	
    $app->update();
}
# --------------------------------------------------quit_event
sub quit_event {
    my ( $event, $controller ) = @_;
   # $controller->stop if $event->type == SDL_QUIT;
    if ($event->type == SDL_KEYDOWN) {
		my $key = $event->key_sym;
		$patrat->{y_vel} -=$patrat->{vel} if $key == SDLK_UP;
		$patrat->{y_vel} -=$patrat->{vel} if $key == SDLK_DOWN;
	    }
	     elsif ( $event->type == SDL_KEYUP ) {
		my $key = $event->key_sym;
		$patrat->{y_vel} += $patrat->{vel} if $key == SDLK_UP;
		$patrat->{y_vel} -= $patrat->{vel} if $key == SDLK_DOWN;
	} elsif ( $event->type == SDL_QUIT ) {
		exit;
	}
}
