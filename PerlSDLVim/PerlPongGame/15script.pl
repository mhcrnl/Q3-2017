#!/usr/bin/perl
# -------------------------------------------------------------------------
# date: 15/11/2017
# author: mhcrnl@gmail.com 
# Pong is one of the first popular games in the world. Allan Alcom created it
# for Atari.inc. Its release in 1972 was both Atari's game ever and the spark
# which began the video game industry.
# 
#   Pong simulates a table tennis match ("ping pong"). Each player controls a
# paddle which moves vertically on the screen to hit a ball bouncing back and
# forth between players.
# --------------------------------------------------------------------------
use strict;
use warnings;

use SDL;
use SDL::TTF;
use SDLx::App;
use SDLx::Rect;
use SDLx::Text;
use SDL::Events;
# --------------------------------------------------------SDL VERSION:
use SDL::Version;
my $v = SDL::version;
printf("Version: %d.%d.%d\n", $v->major, $v->minor, $v->patch);
# --------------------------------------------------------Variabile globale

#my $score = SDLx::Text->new ( font => 'arial.ttf', h_align => 'center' );
# ---------------------------------------------------Color constants in RGB
my @colors = {
    BLACK        =>SDL::Color->new(  0,   0,   0),
    RED          =>SDL::Color->new(255,   0,   0),
    LIGHT_BLUE   =>SDL::Color->new( 66, 167, 244)
};


# Create the main screen
#
my $app = SDLx::App->new (
    width => 500,
    height => 500,
    title => "Perl Pong Game",
    dt => 0.02,
    exit_on_quit => 1,
);

my $player1 = {
    paddle=>SDLx::Rect->new(10, $app->height/2, 10, 40),
    v_y   => 0,
    score => 0,
    color => 0,
};

my $player2 = {
    paddle=>SDLx::Rect->new($app->width-20, $app->height/2,10,40),
    v_y   => 0,
    score => 0,
    color => 0,
};

my $ball = {
    rect=>SDLx::Rect->new($app->width/2, $app->height/2, 10,10),
    v_x => -2.7,
    v_y => 1.8,
};

$app->add_show_handler(
    sub {
        #first clear the screen
        $app->draw_rect([0,0, $app->width, $app->height], 0x000000FF);
        # then render the ball
        $app->draw_rect($ball->{rect}, 0xFF0000FF);
        # ... and each paddle
        $app->draw_rect($player1->{paddle}, 0xFF0000FF );
        $app->draw_rect($player2->{paddle}, 0xFF0000FF );

        #... and each player's score!
        #$score->write_to (
        #   $app,
        #   $player1->{score} . 'x' . $player2->{score},
        #);

        # finally, update the screen
        $app->update();
    }
);

# handles the player's movement
$app->add_move_handler( sub {
        my ($step, $app) = @_;
        my $paddle       = $player1->{paddle};
        my $v_y          = $player1->{v_y};

        $paddle->y($paddle->y ( $v_y * $step));
    });

$app->add_move_handler( sub {
        my ($step, $app) = @_;
        my $paddle       = $player2->{paddle};
        my $v_y          = $player2->{v_y};
        
        if ($ball->{rect}->y > $paddle->y ) {
            $player2->{v_y} = 1.5;
        }
        elsif ( $ball->{rect}->y < $paddle->y ) {
            $player2->{v_y} = -1.5;
        }
        else {
            $player2->{v_y} = 0;
        }

        $paddle->y($paddle->y ( $v_y * $step));
});

# handle keyboard events
$app->add_event_handler ( sub {
        my ($event, $app) = @_;

        # user pressing a key
        if ( $event->type == SDL_KEYDOWN ) {
            # up arrow key means going up(negative velocity)
            if( $event->key_sym == SDLK_UP) {
                $player1->{v_y} = -2;
            }
            # down arrow key means going down (psitive velocity)
            elsif ( $event->key_sym == SDLK_DOWN ) {
                $player1->{v_y} = 2;
            }
        }
        # user releasing a key
        elsif ($event->type == SDL_KEYUP){
            #up or down arrow keys released, stop the paddle
            if($event->key_sym == SDLK_UP or $event->key_sym == SDLK_DOWN){
                $player1->{v_y} = 0;
            }
        }
    }
);

# handle the ball movement
$app->add_move_handler ( sub {
        my ( $step, $app ) = @_;
        my $ball_rect = $ball->{rect};

        $ball_rect->x( $ball_rect->x + ($ball->{v_x} * $step));
        $ball_rect->y( $ball_rect->y + ($ball->{v_y} * $step));
        # collision to the bottom of the screen
        if ( $ball_rect->bottom >= $app->height) {
            $ball_rect->bottom( $app->height );
            $ball->{v_y} *= -1;
        }
        # collision to the top of the screen
        elsif ($ball_rect->top <= 0 ) {
            $ball_rect->top( 0 );
            $ball->{v_y} *= -1;
        }
        # collision to the right: player 1 score
        elsif ( $ball_rect->right >= $app->width) {
            $player1->{score}++;
            reset_game();
            return;
        }
        # collision to the left: player 2 score!
        elsif ( $ball_rect->left <= 0 ) {
            $player2->{score}++;
            reset_game();
            return;
        }
        # collision with player1's paddle
        elsif ( check_collision ( $ball_rect, $player1->{paddle} )) {
            $ball_rect->left ( $player1->{paddle}->right);
            $ball->{v_x} *= -1;
            $player1->{color} = ($player1->{color}+1) % @colors;
        }
        # collision with player2's paddle
        elsif ( check_collision ( $ball_rect, $player2->{paddle} )) {
            $ball->{v_x} *= -1;
            $ball_rect->right ( $player2->{paddle}->left );
            $player2->{color} = ($player2->{color}+1) % @colors;
        }
    }
);

sub reset_game {
    $ball->{rect}->x( $app->width/2 );
    $ball->{rect}->y( $app->height/2 );

    $ball->{v_x} = (1.5 + int rand 1) * (rand 2 > 1 ? 1 : -1);
    $ball->{v_y} = (1.5 + int rand 1) * (rand 2 > 1 ? 1 : -1);
}

$app->run();

sub check_collision {
    my ( $A, $B ) = @_;
    return if $A->bottom < $B->top;
    return if $A->top    > $B->bottom;
    return if $A->right  < $B->left;
    return if $A->left   > $B->right;
    # we have a collision!
    return 1;
}


