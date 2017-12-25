#!/usr/bin/perl
# file: 03script.pl
# SDL::Tutorial - introduction to perl SDL
# site: sdl.perl.org
use strict;
use warnings;

use SDL;
use SDL::Event;
use SDL::Events;
# SDLx::App initialize video and create a surface(400x400x16)
use SDLx::App;
# --------------------------------------------------------SDL VERSION:
use SDL::Version;
my $v = SDL::version;
printf("Version: %d.%d.%d\n", $v->major, $v->minor, $v->patch);
# --------------------------------------------------------------
# my $color = SDL::Video::map_RGB($app->format,$rect_r, $rect_g,$rect_b);
my $app = SDLx::App->
    new
    (
        width =>400,
        height => 400,
        depth  => 16,
        title => 'Salut!My SDL Program.',
    );
# my $color = SDL::Video::map_RGB($app->format,$rect_r, $rect_g,$rect_b);
# my $bg_color = SDL::Video::map_RGB($app->format,$bg_r, $bg_g,$bg_b);
# creats a line 
$app->draw_line( [200,20], [20,200], [255, 255, 0, 255] );

my $event = SDL::Event->new; # create a new event

SDL::Events::pump_events();

while ( SDL::Events::poll_event($event)) {
    my $type = $event->type(); # get event type
    print $type;
    exit if $type == SDL_QUIT;
}
#$app->update;
#sleep(5);

