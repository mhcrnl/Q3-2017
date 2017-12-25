#!/usr/bin/perl

use strict;
use warnings;

use SDL;
use SDL::Events;
use SDLx::App;
use SDLx::Rect;
use SDLx::Text;
# create the main screen
my $app = SDLx::App->new(
	width	=>500,
	height	=>500,
	title		=> 'New Game!',
	dt		=> 0.02,
	exit_on_quit => 1,
);

my $player = {
	patrat 	=> SDLx::Rect->new( $app->w/2,$app->h-20,80, 20),
	vel   	=> 250,
	x_vel 	=> 5,
};
my $minge = {
	x	=> $app->w/2,
	y	=> $app->h/2,
	dim	=> 10,
};

$app->add_show_handler( \&show);
$app->add_move_handler(\&move_patrat);
$app->run;

sub move_patrat {
	my ($step, $app) = @_;
	my $patrat = $player->{patrat};
	my $x_vel = $player->{x_vel};
	
	$patrat->x($patrat->x($x_vel * $step));
}

sub show {
	# first, clear the screen
	$app->draw_rect( [0, 0, $app->width, $app->height], 0x000000FF);
	$app->draw_rect($player->{patrat}, 0xFF0000FF);
	$app->draw_circle_filled([$minge->{x}, $minge->{y}], $minge->{dim}, [0, 0,255, 255]);
	$app->update();
}