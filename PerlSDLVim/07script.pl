#!/usr/bin/perl
# file: 03script.pl
# SDL::Tutorial - introduction to perl SDL
# site: sdl.perl.org
use strict;
use warnings;

use SDL;
# SDLx::App initialize video and create a surface(400x400x16)
use SDLx::App;
my $app = SDLx::App->
    new
    (
        width =>400,
        height => 400,
        depth  => 16,
        title => 'Salut!My SDL Program.',
    );

# draw a circle filled
$app->draw_circle_filled([110,100],19,[0,0,255,255]);

$app->update;
sleep(5);

