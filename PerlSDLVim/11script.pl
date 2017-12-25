#!/usr/bin/perl
# fereastra care se inchide
use strict;
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
    exit_on_quit => 1
);

$app->add_event_handler(\&quit_event);
$app->add_event_handler(\&keyboard_event);
$app->add_event_handler(\&mouse_event);

$app->run();

sub quit_event {
    # the callback receives the appropriate SDL::Event
    my $event = shift;
    # ...as well as the calling SDLx::Controller
    my $controller = shift;
    # stopping the controller will exit $app->run() for us
    $controller->stop if $event->type == SDL_QUIT;
}

sub save_image {
    if (SDL::Video::save_BMP($app, 'painted.bmp') == 0 
    && -e 'painted.bmp'){
        warn 'Saved painted.bmp to' . cwd();
    } else {
        warn 'Could not save painted.bmp:' . SDL::get_errors();
    }
}

my $brush_color = 0;

sub keyboard_event {
    my $event = shift;
    if( $event->type == SDL_KEYDOWN) {
        # convert the key_symbol (integer) to a keyname
        my $key_name = SDL::Events::get_key_name($event->key_sym);

        #if $key_name is a digit, us it as a color
        $brush_color = $key_name if $key_name =~ /^\d$/;
        
        # get the keyboard modifier (see perldoc SDL::Events)
        my $mod_state = SDL::Events::get_mod_state();

        # we are using eny CTRL  so KMOD_CTRL is fine
        save_image() if $key_name =~ /^s$/ && ($mod_state & KMOD_CTRL);
    
        # clear the screen
        $app->draw_rect( [0,0,$app->w, $app->h],0) if $key_name =~ /^c$/;
        
        # exit
        $app->stop() if $key_name =~ /^q$/;
    }
    $app->update();
}

# track the drawing status
my $drawing = 0;

sub mouse_event {
    my $event = shift;
    # detect Mouse Button events and check if user currently drawing
    if($event->type == SDL_MOUSEBUTTONDOWN || $drawing) {
        # set drawing to 1
        $drawing = 1;
        my @colors = 0;
        # get the x and y values of the mouse
        my $x = $event->button_x;
        my $y = $event->button_y;
        # draw a rectangle at the specified position
        $app->draw_rect( [ $x, $y, 2,2], $colors[$brush_color] );

        $app->update();
    }
    # disable drawing when user releases mouse button
    $drawing=0 if ($event->type == SDL_MOUSEBUTTONUP);
}


