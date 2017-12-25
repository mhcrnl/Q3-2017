#!/usr/bin/perl
#
use strict;
use warnings;

use SDL;
use SDLx::App;

# Create the main screen
#
my $app = SDLx::App->new (
    width => 500,
    height => 500,
    title => "Perl Pong Game",
    dt => 0.02,
    exit_on_quit => 1,
);

$app->run();


