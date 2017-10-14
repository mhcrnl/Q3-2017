###############################################
# Title:  	Spewtris
# Description: 	A tetris-type game where the board spins around and zooms in and out.
# Author:  	Ben Garvey
#		bengarvey@comcast.net
#		http://www.bengarvey.com
# Date:		08/19/2003
# Version 0.1.3
###############################################
# 
# LICENSE
#
# This program is free software; you can redistribute it and/or
# modify it under the terms of the GNU General Public License (GPL)
# as published by the Free Software Foundation; either version 2
# of the License, or (at your option) any later version.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#
# To read the license please visit http://www.gnu.org/copyleft/gpl.html
###############################################

# A class to tell everyone how hard the levels should be.
package LevelController;

use strict;

use Tk::RotCanvas;

# Create a new object of the LevelController class
sub new 
{	my $self = {};
	bless($self);

	$self->{level} = 0;
	$self->{levelThreshold} = 5;
	$self->{totalLevels} = 5;

	$self->{dropSpeed} = 20;
	$self->{rotationSpeed} = 35;
	$self->{bounceSpeed} = -1;

	$self->{bounceMin} = 30;
	$self->{bounceMax} = 30;

	$self->{distractionFreq} = 500;

	# the distraction pics
	@{$self->{pics}} = ();

	# Get the names of all the images in the directory
	opendir DIR, "images/";     # . is the current directory
	while ( my $filename = readdir(DIR) ) 
	{	
		if ($filename !~ /level/ && $filename =~ /\.jpg/i)
		{	push(@{$self->{pics}}, "images/$filename");
		}
	}

	return $self;
}

# This is where the distractions come from
sub getDistraction
{	my $self = shift;
	
	if ($self->{level} > 0 && $self->round(rand() * $self->{distractionFreq}) == 1 && $self->{counter} < 1)
	{
		$self->{counter} = $self->round( rand() * 49 / $self->{level} ) + 1;

		# initialize the picture array (we should do this automatically for any picture in the directory)
=for comment	
		my @pics = (	"baby.jpg",
				"ears.jpg",
				"elderly.jpg",
				"eyes.jpg",
				"moneyeat.jpg",
				"monkey.jpg");


		

		#my @pics = ( "ben.jpg" );


		#my $distraction = $self->{main}->Photo( 	-format => 'jpeg',
		#                                 		-file 	=> 'monkey.jpg');	
			
=cut
		my @pics = @{$self->{pics}};
		$self->{distraction} = $pics[ $self->round((rand() * (scalar(@pics) - 1))) ];
	}
	elsif ($self->{counter} < 1)
	{	$self->{distraction} = 0;
	}

	$self->{counter}--;

	return $self->{distraction};
}

sub checkLevel
{	my $self = shift;
	my $lines = $_[0];

	#print "$lines | " . $self->{level} * $self->{levelThreshold} . "\n";

	my $result = 0;

	if ( $lines >= $self->{level} * $self->{levelThreshold} )
	{	$self->{level}++;
		$result = 1;

		if ($self->{level} == 1)
		{	$self->setLevel1();	
		}
		elsif ($self->{level} == 2)		
		{	$self->setLevel2();
		}
		elsif ($self->{level} == 3)		
		{	$self->setLevel3();
		}
		elsif ($self->{level} == 4)		
		{	$self->setLevel4();
		}
		elsif ($self->{level} == 5)		
		{	$self->setLevel5();
		}
		elsif ($self->{level} == 6)		
		{	$self->setLevel6();
		}
		elsif ($self->{level} == 7)		
		{	$self->setLevel7();
		}
		elsif ($self->{level} == 8)		
		{	$self->setLevel8();
		}

		#print "Welcome to level " . $self->{level} . "\n";
	}	

	return $result;
}

sub changeLevel
{	my $self = shift;
	my $newLevel = $_[0];

	if ($newLevel == 1)
	{	$self->setLevel1();
	}
	elsif ($newLevel == 2)
	{	$self->setLevel2();
	}
	elsif ($newLevel == 3)
	{	$self->setLevel3();
	}
	elsif ($newLevel == 4)
	{	$self->setLevel4();
	}
	elsif ($newLevel == 5)
	{	$self->setLevel5();
	}
	elsif ($newLevel == 6)
	{	$self->setLevel6();
	}
	elsif ($newLevel == 7)
	{	$self->setLevel7();
	}
	elsif ($newLevel == 8)
	{	$self->setLevel8();
	}
}

# Should we switch the rotation?
sub switchRotationCheck
{	my $self = shift;

	#print "Checking for switch.. " . $self->{switchDirection} . " / 100\n";


	
	if ( $self->round( rand() * 100 ) < $self->{switchDirection} )
	{	$self->{rotationAmount}	*= -1;
	}
}

sub setLevel1
{	my $self = shift;

	$self->{dropSpeed} = 20;
	$self->{rotationSpeed} = -1;
	$self->{rotationAmount} = 3;
	$self->{bounceSpeed} = -1;
	$self->{distractionFreq} = 50000;
	$self->{switchDirection} = 0;

	$self->{level} = 1;
}

sub setLevel2
{	my $self = shift;

	$self->{dropSpeed} = 20;
	$self->{rotationSpeed} = 30;
	$self->{rotationAmount} = 3;
	$self->{bounceSpeed} = -1;
	$self->{distractionFreq} = 100;
	$self->{switchDirection} = 0;

	$self->{level} = 2;
}

sub setLevel3
{	my $self = shift;

	$self->{dropSpeed} = 20;
	$self->{rotationSpeed} = 4;
	$self->{rotationAmount} = 3;
	$self->{bounceSpeed} = -1;
	#$self->{bounceMin} = 0.8;
	#$self->{bounceMax} = 1.1;
	$self->{distractionFreq} = 100;
	$self->{switchDirection} = 0;

	$self->{level} = 3;
}

sub setLevel4
{	my $self = shift;

	$self->{dropSpeed} = 20;
	$self->{rotationSpeed} = 4;
	$self->{rotationAmount} = 3;
	$self->{bounceSpeed} = 15;
	$self->{bounceMin} = 0.6;
	$self->{bounceMax} = 1.2;
	$self->{distractionFreq} = 8;
	$self->{switchDirection} = 1;

	$self->{level} = 4;
}

sub setLevel5
{	my $self = shift;

	$self->{dropSpeed} = 10;
	$self->{rotationSpeed} = 1;
	$self->{rotationAmount} = -3;
	$self->{bounceSpeed} = 2;
	$self->{bounceMin} = 0.5;
	$self->{bounceMax} = 1.3;
	$self->{distractionFreq} = 8;
	$self->{switchDirection} = 3;

	$self->{level} = 5;
}

sub setLevel6
{	my $self = shift;

	$self->{dropSpeed} = 5;
	$self->{rotationSpeed} = 1;
	$self->{rotationAmount} = 3;
	$self->{bounceSpeed} = 2;
	$self->{bounceMin} = 0.3;
	$self->{bounceMax} = 1.4;
	$self->{distractionFreq} = 7;
	$self->{switchDirection} = 4;

	$self->{level} = 6;
}

sub setLevel7
{	my $self = shift;

	$self->{dropSpeed} = 4;
	$self->{rotationSpeed} = 1;
	$self->{rotationAmount} = 6;
	$self->{bounceSpeed} = 1;
	$self->{bounceMin} = 0.2;
	$self->{bounceMax} = 1.4;
	$self->{distractionFreq} = 4;
	$self->{switchDirection} = 5;

	$self->{level} = 7;
}

sub setLevel8
{	my $self = shift;

	$self->{dropSpeed} = 4;
	$self->{rotationSpeed} = 1;
	$self->{rotationAmount} = -3;
	$self->{bounceSpeed} = 1;
	$self->{bounceMin} = 0.2;
	$self->{bounceMax} = 1.4;
	$self->{distractionFreq} = 4;

	$self->{level} = 8;
}


sub cget
{	my $self = shift;
	my $option = $_[0];

	return $self->{$option};
}


sub configure
{	my $self = shift;
	my $option = $_[0];
	my $value = $_[1];

	$self->{$option} = $value;
}

sub round 
{	my $self = shift;
	my $number = shift;
	
	return int($number + .5);
}

return 1;
