#!/usr/bin/perl
# file: 03script.pl
# SDL::Tutorial - introduction to perl SDL
# site: sdl.perl.org
use strict;
use warnings;

use SDL;
use SDL::Event;
# SDLx::App initialize video and create a surface(400x400x16)
use SDLx::App;
use SDLx::Rect;
# --------------------------------------------------------SDL VERSION:
use SDL::Version;
my $v = SDL::version;
printf("SDL::Version: %d.%d.%d\n", $v->major, $v->minor, $v->patch);
# -------------------------------------------------------------------

my $app = SDLx::App->
    new
    (
        width        => 500,
        height       => 500,
        depth        => 16,
        title        => 'Salut!My SDL Program.',
        exit_on_quit => 1,
    );
# ----------------------------------------------color constant in RGB
# perldoc SDL::Color 
my $COLOR = {
    BLACK      => SDL::Color->new(  0, 100,   0),
    LIGHT_BLUE => SDL::Color->new( 66, 167, 244),
};
# ---------------------------------------------------draw a rectangle
my $rectangle = {
    paddle => SDL::Rect->new(10, $app->height/2, 10, 40),  
    v_y    => 0,
};
my $event = SDL::Event->new;
my $laser = {
    desen => SDLx::Rect->new(10, 10, 10, 10),
    v_y   => 0,
};
my $velocity = 10;
# --------------------------------------------------------EVENTS:
$app->add_event_handler( \&quit_event);
$app->add_show_handler ( \&render_laser);
$app->add_move_handler ( \&calculate_laser);
$app->add_event_handler( \&move_laser);
$app->run;
# --------------------------------------------------------FUNCTIONS:
# quit_event - close the window
# render_laser - afiseaza laser in window
# calculate_laser - print the laser
# move_laser - move laser right and left
# --------------------------------------------------move_laser
sub move_laser {
    my ($event, $app ) = @_;
    if($event->type == SDL_KEYDOWN) {
        if ( $event->key_sym == SDLK_RIGHT ) {
            $laser += 2;
        } elsif ($event->key_sym == SDLK_LEFT ) {
            $laser += -2;
        }
    }
}
# -------------------------------------------------calculate_laser
sub calculate_laser {
    my ( $step, $app, $t ) = @_;
    $laser += $velocity * $step;
    $laser = 0 if $laser > $app->width;
}
# --------------------------------------------------render_laser
sub render_laser {
    my ( $delta, $app ) = @_;
    $app->draw_rect( [ 0, 0, $app->width, $app->height ], $COLOR->{BLACK} );
    # $app->draw_rect( [$laser, $app->width/2, 10, 2], $COLOR->{LIGHT_BLUE} );
    $app->draw_rect( [ $app->width/2,$laser, 10, 2 ], $COLOR->{LIGHT_BLUE} );

    $app->update();
}
# --------------------------------------------------quit_event
sub quit_event {
    my ( $event, $controller ) = @_;
    $controller->stop if $event->type == SDL_QUIT;
}



