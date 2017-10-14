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

# A class to decide what each ending is and how it should look.
package Ending;

use strict;

use Tk::RotCanvas;
use Tk::TopLevel;
require Tk::TopLevel;

# Creates a new grid object
sub new 
{	my $self = {};
	bless($self);

	

	return $self;
}

sub go
{	my $self = shift;

	my $canvas = $_[0];
	my $main = $_[1];
	my $size = $_[2];

	$canvas->destroy();

	$canvas = $main->RotCanvas(-height => $main->screenwidth(), -width => ($main->screenheight() - 100) );

	#$canvas = $self->testEnding( $canvas );


	my $message = "Congratulations!  \nYou managed to get through\n Spewtris without puking.\nCheck out http://www.bengarvey.com";

	if ( $self->round( rand() * 5) == 1)
	{	$message = "You stink!\n";
	}

	$canvas->destroy();

	$canvas = $main->RotCanvas(-height => $main->screenwidth(), -width => ($main->screenheight() - 100) );

	my $photo = $canvas->Photo( -format => 'jpeg', -file 	=> 'images/level8.jpg' );
	my $photoLabel = $canvas->Label('-image' => $photo )->place(-x => 300, -y => 400);
	$canvas->create("text", 500 + 5, 200 + 5, -text => $message, -font => "Impact " . $size * 1.5, -fill => '#DDFFDD');
	$canvas->create("text", 500, 200, -text => $message, -font => "Impact " . $size * 1.5, -fill => '#111111');

	return $canvas;
}

sub swe
{	my $self = shift;
	my $main = $_[0];
	
	my $top = $main->Toplevel(-height => 500, -width => 500, -title => "Congratulations!");
	my $canvas = $top->RotCanvas(-height => 500, -width =>600)->place(-x => 0, -y => 0);

	$self->starWarsEnding($top, $canvas);

	#MainLoop;
}

sub starWarsEnding
{	my $self = shift;
	my $main = $_[0];
	my $canvas = $_[1];


	my @text = (	"Congratulations!",
			"You have proven your",
			"worthiness to society",
			"and are now an official",
			"Spewmaster.",
			"",
			"",
			"",
			"",
			"- Spew Credits - ",
			"Written by Ben Garvey",
			"Photography by Ben Garvey",
			"Programmed in Perl",
			"Using the Tk GUI Module",
			"Thanks for playing!");

	my @sizes = ();

	my $fontCeiling = 50;
	my $fontFloor = 0;

	my $inc = 20;
	my $oinc = $inc;

	foreach my $t (@text)
	{	push(@sizes, $fontCeiling + $inc);
		$inc += $oinc;
	}

	my $done = 0;
	my $i=0;
	my $dec = 1;

	my $tempcount = 0;

	while (!$done)
	{
		if ($canvas)
		{	$canvas->destroy();
		}

		$canvas = $main->RotCanvas(-height => 500, -width => 750)->place(-x => 0, -y => 0);

		for($i=0; $i<@text; $i++)
		{	if ($sizes[$i] < $fontCeiling || $sizes[$i] > $fontFloor)
			{	$canvas->create("text", 250, $sizes[$i] * 6,-text => $text[$i], -font => "Times " . $sizes[$i], -fill => '#000000');
			}
		}

		# Decrement all the sizes
		for($i=0; $i<@sizes; $i++)
		{	$sizes[$i] -= $dec;
		}

		# Have all the words disappeared?
		if ($sizes[ scalar(@sizes) - 1] == 10)
		{	$done = 1;
		}

		$canvas->update();

		$tempcount++;
	}

	$self->spinSomePieces($main, $canvas);

	
}

sub spinSomePieces
{	my $self = shift;
	my $main = $_[0];
	my $canvas = $_[1];

	my $xoffset = 0;
	my $yoffset = 0;

	my @xs = (0,1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,15,15,15,15,15,15,15,14,13,12,11,10,9,8,7,6,5,4,3,2,1,0,0,0,0,0,0,0);
	my @ys = (0,0,0,0,0,0,0,0,0,0, 0, 0, 0, 0, 0, 0, 1, 2, 3, 4, 5, 6, 7, 7, 7, 7, 7, 7,7,7,7,7,7,7,7,7,7,7,6,5,4,3,2,1);

	my @text = split(/\|/, "T|h|a|n|k|s| |f|o|r| |P|l|a|y|i|n|g|!");

	my $size = 25;

	my $tspace = 0;

	my $rcount = 1;

	my @obs = ();

	my $i=0;
	my $j=0;
	for ($i=0; $i<250; $i++)
	{	if ($canvas)
		{	$canvas->destroy();
		}

		@obs = ();



		$canvas = $main->RotCanvas(-height => (500), -width => (750) )->place(-x => 0, -y => 0);

		for($j=0; $j<@xs; $j++)
		{	$xoffset = $self->round( rand() * ((499 - $i) - 250) );
			$yoffset = $self->round( rand() * ((499 - $i) - 250) );
			
			my $r = $canvas->create("rectangle", 	60 + ($xs[$j] * $size) + $xoffset, 200 + ($ys[$j] * $size) + $yoffset, 
							60 + $size + ($xs[$j] * $size) + $xoffset, 200 + $size + ($ys[$j] * $size) + $yoffset, 
							-fill => '#22DD66', -outline => '#000000');

			#print $yoffset . "\n";

			$canvas->rotate($r, $rcount * 3, 250, 265);

		}

		for($j=0; $j<@text; $j++)
		{	$xoffset = $self->round( rand() * ((499 - $i) - 250) );
			$yoffset = $self->round( rand() * ((499 - $i) - 250) );

			$canvas->create("text", 100 + $tspace + 2 + $xoffset, 265 + 2 + $yoffset, -text => $text[$j], -font => "Impact " . 24, -fill => '#000000');
			$canvas->create("text", 100 + $tspace - $xoffset, 265 - $yoffset, -text => $text[$j], -font => "Impact " . 24, -fill => '#22DD66');

			$tspace += 18;
		}

		$tspace = 0;

		$rcount++;

		if ($rcount > 360)
		{	$rcount = 0;
		}

		if ( $i== 249 )	
		{	$i = 248;
		}



		$canvas->update();	
	}
}

sub testEnding
{	my $self = shift;

	my $canvas = $_[0];

	my $x = 300;
	my $y = 300;
	my $blockSize = 3;

	my @pieceArray = (		0,0,0,0,2,0,0,0,0,0,
					0,0,0,0,2,0,0,0,0,0,
					0,0,0,0,2,2,0,0,0,0,
					0,0,0,0,0,0,0,0,0,0 );


	my @pieceArray = (		2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,0,0,0,0,0,0,
					2,2,2,2,2,2,2,2,2,2,2,2,2,2,1,2,2,1,0,0,0,0,0,0,
					2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,0,0,0,0,0,0,
					2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,0,0,0,0,0,0,
					2,2,2,2,2,2,2,2,2,2,2,2,2,1,2,2,2,2,1,0,0,0,0,0,
					2,2,2,2,2,2,2,2,2,2,2,2,2,2,1,1,1,1,0,0,0,0,0,0,
					2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,0,0,0,0,0,0,
					2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,0,0,0,0,0,0,
					2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,0,0,0,0,0,0,
					2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,0,0,0,0,0,0,
					2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,0,0,0,0,0,0,
					2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,0,0,0,0,0,0,
					2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,
					2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,
					2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,
					2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,
					2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,
					2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2, 
					2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,0,0,0,0,0,0,
					2,2,2,2,2,2,2,2,2,2,2,2,2,2,1,2,2,1,0,0,0,0,0,0,
					2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,0,0,0,0,0,0,
					2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,0,0,0,0,0,0,
					2,2,2,2,2,2,2,2,2,2,2,2,2,1,2,2,2,2,1,0,0,0,0,0,
					2,2,2,2,2,2,2,2,2,2,2,2,2,2,1,1,1,1,0,0,0,0,0,0,
					2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,0,0,0,0,0,0,
					2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,0,0,0,0,0,0,
					2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,0,0,0,0,0,0,
					2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,0,0,0,0,0,0,
					2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,0,0,0,0,0,0,
					2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,0,0,0,0,0,0,
					2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,
					2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,
					2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,
					2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,
					2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,
					2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2 );




	$self->drawPiece( $x, $y, $blockSize, $canvas, @pieceArray);

	#my $square = $canvas->create("rectangle", $x, $y, $x + $blockSize, $y + $blockSize, -fill => '#AA2244', -outline => '#000000');

	return $canvas;
}

sub drawPiece
{	my $self = shift;

	my $x = shift(@_);
	my $y = shift(@_);
	my $blockSize = shift(@_);
	my $canvas = shift(@_);
	my $originalX = $x;
	my $color = '#000000';

	my @pieceArray = @_;

	my %colorHash = ();
	$colorHash{1} = '#000000';
	$colorHash{2} = '#FFFFFF';
	$colorHash{3} = '#AA2244';
	

	my $i=0;
	for ($i=0; $i<@pieceArray; $i++)
	{
		if ($pieceArray[$i] != 0)
		{
			$color = $colorHash{$pieceArray[$i]};

			my $square = $canvas->create("rectangle", $x, $y, $x + $blockSize, $y + $blockSize, -fill => $color , -outline => $color);
		}

			if ( ($i+1) % 24 == 0)
			{	$x = $originalX;
				$y += $blockSize;
			}
			else
			{	$x += $blockSize;
			}
	}

		
}

sub round 
{	my $self = shift;
	my $number = shift;
	
	return int($number + .5);
}

return 1;