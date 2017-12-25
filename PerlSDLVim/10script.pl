#!/usr/bin/perl
# fereastra care se inchide
use strict;
use warnings;

use SDL;
use SDL::Event;
use SDLx::App;

my $app = SDLx::App->new (
    w => 200,
    h => 200,
    d => 32,
    title => 'Inchidere fereastra',
    exit_on_quit => 1
);

$app->add_event_handler(\&quit_event);
$app->run();

sub quit_event {
    # the callback receives the appropriate SDL::Event
    my $event = shift;
    # ...as well as the calling SDLx::Controller
    my $controller = shift;
    # stopping the controller will exit $app->run() for us
    $controller->stop if $event->type == SDL_QUIT;
}

