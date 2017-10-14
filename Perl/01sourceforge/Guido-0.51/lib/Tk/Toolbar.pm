package Tk::Toolbar;
use strict;

use Tk;
use Tk::Photo;

use vars qw( @ISA );
use Tk::Derived;
use Tk::Frame;
@ISA = qw( Tk::Derived Tk::Frame );

#use base qw/Tk::Derived Tk::Frame/;

Construct Tk::Widget 'Toolbar';

#################
#TK GUI METHODS
#################

sub Populate {
	my ($cw, $args) = @_;

	my $buttons = delete $args->{-buttons};

	foreach my $button_info (@$buttons) {
		if($button_info->[1]) {
			my $icon = $cw->Photo(
				-file=>$button_info->[1], 
			);
			$cw->Button(
				-image=>$icon,
				-command=>$button_info->[2],
				-background => $cw->parent->cget(-background),
			)->pack(
				-side=>'left',
				-anchor=>'w',
			);
		}
		else {
			$cw->Button(
				-text=>$button_info->[0],
				-command=>$button_info->[2],
			)->pack(
				-side=>'left',
				-anchor=>'w',
			);
		}
	}

	#Finish by calling the SUPER class's Populate function
	$cw->SUPER::Populate($args);
}


1;