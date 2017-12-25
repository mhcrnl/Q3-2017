#!/usr/bin/perl
# fereastra care se inchide
# use strict;
use warnings;

use Carp;

use SDL;
use SDL::Event;
use SDL::Events;
use SDL::Video;
#use SDL::Color;
#use SDL::Errors;
use SDLx::App;

my $app = SDLx::App->new (
    w => 200,
    h => 200,
    d => 32,
    title => 'Inchidere fereastra',
    #exit_on_quit => 1
);

$app->add_event_handler(\&quit_event);

my $quit = 0;

# start laser on the left
my $laser = 0;

sub get_events {
    my $event = SDL::Event->new();

    SDL::Events::pump_events;

    while( SDL::Events::poll_event($event)){
        $quit = 1 if $event->type == SDL::QUIT;
    }
    
}

sub calculate_next_positions {
    # move the laser
    $laser++;
    # if the laser goes off the screen, bring it back
    $laser = 0 if $laser > $app->w();
}

sub render {
    # draw the backgrownd first
    $app->draw_rect( [0,0, $app->w, $app->h ], 0);

    # draw the laser halfway up the screen
    $app->draw_rect( [$laser, $app->h/2, 10,2], [255,0,0,255]);

    $app->update();
}

sub quit_event {
    # the callback receives the appropriate SDL::Event
    my $event = shift;
    # ...as well as the calling SDLx::Controller
    my $controller = shift;
    # stopping the controller will exit $app->run() for us
    $controller->stop if $event->type == SDL_QUIT;
}

while(1){
    get_events();
    calculate_next_positions();
    render();
    # quit_event();
}


