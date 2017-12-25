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
# ----------------------------------------------------------EVENTS:
$app->add_event_handler( \&quit_event);
$app->add_show_handler ( \&show_objects);
$app->add_event_handler( \&keyboard_event);
#$app->add_move_handler ( \&move_objects  );
$app->run;
# ----------------------------------------------------------FUNCTIONS:
sub move_objets {
    my ( $step, $app ) = @_;
    my $paddle = $rectangle->{paddle};
    my $v_y   = $rectangle->{v_y};

    $paddle->y($paddle->y ( $v_y * $step));
}
# ----------------------------------------------------show_objects
sub show_objects {
    $app->draw_rect( [0,0,$app->width,$app->height],$COLOR->{BLACK} );
    $app->draw_rect( $rectangle->{paddle}, $COLOR->{LIGHT_BLUE} );

    $app->update(); 
}
# ---------------------------------------------------------keyboard_event
sub keyboard_event {
    my $event = shift;
    # ---- buton dreapta afiseaza buton-drept
    print "buton-dreapta-apasat\n" if $event->type == SDL_MOUSEBUTTONDOWN;
    print "mouse-stanga buton\n" if $event->type == SDL_MOUSEBUTTONUP;
    #print "tasta keyboard apasata\n" if $event->type == SDL_KEYDOWN;
    if ( $event->type == SDL_KEYDOWN) {
        if ($event->key_sym == SDLK_UP){
            print "tasta-key down\n";
            $rectangle->{v_y} = -2;
        }
    }
}

# ---------------------------------------------------------quit_event
# Close the window
sub quit_event {
    my $event = shift;
    my $controller = shift;
    $controller->stop if $event->type == SDL_QUIT;
    if($event->type == SDL_KEYDOWN) {
        #$controller->stop if $event->key_sym == SDLK_UP;
    }
}

