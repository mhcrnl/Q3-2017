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
	title		=> 'Ping/Pong Game!',
	dt		=> 0.02,
	exit_on_quit => 1,
);

my $player1 = {
	paddle => SDLx::Rect->new(10, $app->h/2, 10, 40),
	v_y	    => 1,
	score   => 0,
};

my $player2 = {
	paddle => SDLx::Rect->new($app->w-20, $app->h/2, 10, 40),
	v_y	   => 10,
	score  => 0,
};

my $ball = {
	rect => SDLx::Rect->new($app->w/2, $app->h/2, 10, 10),
	v_x => -2.7,
	v_y => 1.8,
};

my $score = SDLx::Text->new ( 
	h_align	=> 'center',
	size		=> 50,
	x 		=> $app->w/2,
	y		=> 0,
);

$app->add_show_handler(
	sub {
			# first, clear the screen
			$app->draw_rect( [0, 0, $app->width, $app->height], 0x000000FF);
			# render the ball
			$app->draw_rect( $ball->{rect}, 0xFF0000FF);
			# each paddle
			$app->draw_rect( $player1->{paddle}, 0xFF0000FF);
			$app->draw_rect( $player2->{paddle}, 0xFF0000FF);
			
			# ... and each player's score
			$score->write_to($app, 'Scorul: '.$player1->{score}. ' x ' .$player2->{score});
			$app->update();
	}
);
# ---- handles the player's paddle movement
$app->add_move_handler(
	sub {
			my ( $step, $app ) = @_;
			my $paddle = $player1->{paddle};
			my $v_y	    = $player1->{v_y};
			
			$paddle->y( $paddle->y( $v_y * $step )); 
	}
);
# handles AI's paddle movement
$app->add_move_handler(
	sub {
			my ( $step, $app ) = @_;
			my $paddle = $player2->{paddle};
			my $v_y	    = $player2->{v_y};
			
			if ( $ball->{rect}->y > $paddle->y ) {
				$player2->{v_y} = 1.5;
			}
			elsif ( $ball->{rect}->y < $paddle->y) {
				$player2->{v_y} = -1.5;
			}
			else {
				$player2->{v_y} = 0;
			}
			$paddle->y( $paddle->y( $v_y * $step )); 
	}
);
# ---- handles Keyboard events
$app->add_event_handler(
	sub {
			my ( $event, $app ) = @_;
			# user pressing a key
			if ( $event->type == SDL_KEYDOWN ) {
				# up arrow key means going up (negative velocity)
				if ( $event->key_sym == SDLK_UP ) {
					$player1->{v_y} = -1.5;
				}
				# down arrow key means going down (positive velocity)
				elsif ( $event->key_sym == SDLK_DOWN ) {
					$player1->{v_y} = 1.50;
				}
			}
			# user releasing a key 
			elsif ( $event->type == SDL_KEYUP ) {
				# up or down arrow keys released, stop the paddle
				if ( $event->key_sym==SDLK_UP or $event->key_sym== SDLK_DOWN ) {
					$player1->{v_y} =500;
					
			}
		}
	}
);
# handles the ball movement
$app->add_move_handler (
	sub {
		my ( $step, $app )  = @_;
		my $ball_rect 	= $ball->{rect};
		
		$ball_rect->x( $ball_rect->x +( $ball->{v_x} * $step));
		$ball_rect->y( $ball_rect->y +( $ball->{v_y} * $step));
		
		# collision to the bottom of the screen
		if ( $ball_rect->bottom >= $app->h ) {
			$ball_rect->bottom( $app->h );
			$ball->{v_y} *= -1; 
		}
		# collision to the top of the screen
		elsif ( $ball_rect->top <= 0 ) {
			$ball_rect->top( 0 );
			$ball->{v_y} *= -1
		}
		# collision to the right: player1 score!
		elsif ( $ball_rect->right >= $app->w ) {
			$player1->{score}++;
			reset_game();
			return;
		}
		# collision to the right: player2 score!
		elsif ( $ball_rect->left <= 0 ) {
			$player2->{score}++;
			reset_game();
			return;
		}
		# collision width player1's paddle
		elsif ( check_collision( $ball_rect, $player1->{paddle} )) {
			$ball_rect->left( $player1->{paddle}->right );
			$ball->{v_x} *= -1;
		}
		# collision width player2's paddle
		elsif ( check_collision($ball_rect, $player2->{paddle} )) {
			$ball->{v_x} *= -1;
			$ball_rect->right($player2->{paddle}->left );
		}	
	}
);

# let's roll!
$app->run;

sub reset_game {
	$ball->{rect}->x( $app->w/2 );
	$ball->{rect}->y( $app->h/2 );
	
	$ball->{v_x} = (1.5 + int rand 1) * (rand 2 > 1 ? 1: -1);
	$ball->{v_y} = (1.5 + int rand 1) * (rand 2 > 1 ? 1: -1);
}

sub check_collision {
	my ( $A, $B ) = @_;
	
	return if $A->bottom < $B->top;
	return if $A->top	    > $B->bottom;
	return if $A->right      < $B->left;
	return if $A->left       > $B->right;
	
	# we have collision
	return 1;	
}