#!/usr/bin/perl
# file: 03script.pl
# SDL::Tutorial - introduction to perl SDL
# site: sdl.perl.org
use strict;
use warnings;

use SDL;
# SDLx::App initialize video and create a surface(400x400x16)
use SDLx::App;
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

$app->draw_line( [200,20], [20,200], [255, 255, 0, 255] );
$app->update;
sleep(5);

