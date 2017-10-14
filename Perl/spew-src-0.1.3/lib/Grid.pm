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

# The Grid class holds the game board
package Grid;
use strict;

use Tk::RotCanvas;

# Creates a new grid object
sub new 
{	my $self = {};
	bless($self);

	# For some dumb reason I used a one dimensional array.  Smack me.
	# The grid uses the following format.
	# A value of 0 = empty square
	# 1 = stationary block
	# 2 = moving block

	my $i=0;
	@{$self->{map}} = ();
	@{$self->{colorMap}} = ();
	for ($i=0; $i<200; $i++)
	{	#push( @{$self->{map}}, $self->round( rand() ) );
		push( @{$self->{map}}, 0 );
		push( @{$self->{colorMap}}, '#FFFFFF' );
	}

	# Set this to 1 whenever we need a new piece
	$self->{needPiece} = 1;
	$self->{width} = 10;
	$self->{zv} = 1;

	#$self->{completedLines} = 0;
	$self->{oldCompletedLines} = 0;
	$self->{oldLevel} = 0;

	# We'll override this later
	$self->{blockSize} = 25;



	return $self;
}

# Move the piece left.  I love useful comments.
sub movePieceLeft
{	my $self = shift;
	my $direction = $_[0];

	my @map = @{$self->{map}};
	my @newMap = @{$self->{map}};

	my @colorMap = @{$self->{colorMap}};
	my @newColorMap = @{$self->{colorMap}};

	my $i=0;
	my $kill = 0;

	# Loop through grid.  If we see a movable block, move it.
	for($i=0; $i<@map; $i++)
	{	if ($map[$i] == 2)
		{
			if ($map[$i - 1] == 1 || $i % $self->{width} == 0)
			{	
				#print "Blocked when moving $direction\n";
				$i=scalar(@map);
				$kill = 1;
			}
			else
			{	$newMap[$i] = 0;
				$newMap[$i - 1] = 2;
				
				#$newColorMap[$i] = '#FFFFFF';
				$newColorMap[$i - 1] = $self->{piece}->cget('color');
			}
		}
	}

	# If we can't move because of a barrier, so be it!
	if (!$kill)
	{	@{$self->{map}} = @newMap;
		@{$self->{colorMap}} = @newColorMap;	
	}
}

# Just like moving left, only right
sub movePieceRight
{	my $self = shift;
	my $direction = $_[0];

	my @map = @{$self->{map}};
	my @newMap = @{$self->{map}};

	my @colorMap = @{$self->{colorMap}};
	my @newColorMap = @{$self->{colorMap}};

	my $i=0;
	my $kill = 0;

	# Loop through grid.  If we see a movable block, move it.
	for($i=0; $i<@map; $i++)
	{	if ($map[$i] == 2)
		{
			if ($map[$i + 1] == 1 || $i % $self->{width} == $self->{width} - 1)
			{	
				#print "Blocked when moving $direction\n";
				$i=scalar(@map);
				$kill = 1;
			}
			else
			{	if ( $map[$i - 1] != 2 )
				{	$newMap[$i] = 0;
					#$newColorMap[$i] = '#FFFFFF';
				}

				$newMap[$i + 1] = 2;
				$newColorMap[$i + 1] = $self->{piece}->cget('color');
			}
		}
	}

	# If we can't move because of a barrier, so be it!
	if (!$kill)
	{	@{$self->{map}} = @newMap;
		@{$self->{colorMap}} = @newColorMap;	
	}
}

# Rotating the piece is a PAIN to do any other way than this.  We just shift through hard coded arrays in the Piece object. 
sub rotatePiece
{	my $self = shift;

	my $direction = $_[0];

	# First, find the x,y where we see upper left corner of the active box
	my @map = @{$self->{map}};

	my @colorMap = @{$self->{colorMap}};
	my @newColorMap = @{$self->{colorMap}};

	my $i=0;
	my $x = scalar(@map) / $self->{width};
	my $y = $self->{width};
	my $final = "";
	my $first = "";
	for($i=0; $i<@map; $i++)
	{	
		# See what this block's x and y are and compare to max
		if ($map[$i] == 2)
		{	#print " - XY TEST - \n";
			
			#print "X = " . $self->round($i / $self->{width}) . " vs $x\n"; 
			##print "Y = " . $i % $self->{width} . " vs $y\n"; 

			# this must always be rounded DOWN, otherwise the pieces fall faster when rotating
			if ( $self->roundDown($i / $self->{width}) < $x)
			{	$x = $self->roundDown($i / $self->{width});
				if ($first eq "")
				{	$first = 'x';
				}

				#print "New X = $x\n";
			}

			if ( $i % $self->{width} < $y)
			{	$y = $i % $self->{width};
				#print "XY: " . $i % $self->{width} . "\n";
				$final = $i;
				if ($first eq "")
				{	$first = 'y';
				}

				#print "New Y = $y\n";
			}

				
		}
	}

	if ($x < 0)
	{	$x = 0;
	}

	$y = ($y - $self->round($self->{width} / 2)) + 1;
	my $tempstart = ($x) * $self->{width};
	my $start = ($x * $self->{width}) + $y;

	# Some pieces have been falling when we rotate. This should counteract that.
	#print "THIS Y:  $y\n";
	if ($y >= 0)
	{	#$tempstart -= $self->{width};
		#print "Y Adjusting starting height\n";
	}

	my @pieceMap = ();

	# Find out which way we have to turn
	if ($direction eq 'clockwise')
	{	@pieceMap = $self->{piece}->rotateClockwise();
	}
	else
	{	@pieceMap = $self->{piece}->rotateCounterClockwise();
	}

	my @newMap = @map;

	# I tried to do this in one loop, but no dice (yet)!
	for($i=0; $i<@newMap; $i++)
	{	# erase the old	
		if ($map[$i] == 2)
		{	$newMap[$i] = 0;
			#$newColorMap[$i] = '#FFFFFF';	
		}
	}
	#print " - CONDITIONS - \n";
	#print "TEMPTSTART:  $tempstart\n";
	#print "X-Y:  $x-$y\n";

	my $j=0;
	my $kill = 0;
	# Now that we know where to start drawing, get rid of the old one pice and draw the rotated one
	for($i=$tempstart; $i< (4 * $self->{width}) + $tempstart; $i++)
	{	# draw the new
		if ($pieceMap[$j] == 2)
		{	if ($map[$i + $y] != 1 && ($i % $self->{width}) + $y < $self->{width} && ($i % $self->{width}) + $y > 0 && $i + $self->{width} < scalar(@newMap)  )
			{	$newMap[$i + $y] = 2;
				$newColorMap[$i + $y] = $self->{piece}->cget('color');	
			}
			else
			{	$kill = 1;
				$i = (4 * $self->{width});
					
			}
		}

		$j++;
	}

	if (!$kill)
	{	@{$self->{map}} = @newMap; 
		@{$self->{colorMap}} = @newColorMap; 
	}
	else
	{	#print "Rotation blocked!\n";
	}
}

# Check to see if we have a line to erase.  I've noticed that some times we erase too many squares, but I can't reproduce it! 
# I think I fixed it - Ben 1/7/2004
sub checkForLine
{	my $self = shift;

	my @map = @{$self->{map}};
	my @newMap = @{$self->{map}};

	my @colorMap = @{$self->{colorMap}};
	my @newColorMap = @{$self->{colorMap}};

	my $i=0;
	my $j=0;
	my $row = 0;
	my $count = 0;
	my @lines = ();

	for($i=0; $i<@map+1; $i++)
	{
		if ( ($i % $self->{width}) == 0)	
		{	#print "$i" . "-" . $count . " ";			
			if ($count == $self->{width})
			{	#print "We have a line!\n";
				push(@lines, $row - 1);
				my $start = $row * $self->{width};
				my $end = $start + $self->{width};

				#print "Row " . ($row - 1) . "\n";
			}

			$row++;
			$count = 0;
		}

		if ($map[$i] == 1)
		{	$count++;
		}

	
	}



	#print $count;

	# Let's try this in reverse so we aren't messing with the array while using the row numbers
	@lines = sort(@lines);

	# Looks like reversing the order causes us to lose too many lines
	#@lines = reverse(@lines);

	#print "Lines = " . $self->{completedLines} . "\n";

	# count how many lines the user has made
	$self->{completedLines} += scalar(@lines);

	#print "Lines - " . $self->{completedLines} . "\n";

	for ($i=0; $i<scalar(@lines); $i++)
	{	#print "SIZE:  " . scalar(@newMap) . "\n";
		#print "DELETING:  Row $lines[$i]\n";

		# First we turn the squares green.  If we ever see green squares, we know this algorithm is broken
		my $j=0;
		for ($j=($lines[$i] * $self->{width}); $j< ($lines[$i] * $self->{width}) + $self->{width}; $j++)
		{	$newMap[$j] = 3;
		}

		splice(@newMap, ($lines[$i] * $self->{width}), $self->{width});
		
		# Make the same adjustment to the new colorMap
		splice(@newColorMap, ($lines[$i] * $self->{width}), $self->{width});

		my @temp = ();
		my @colorTemp = ();

		for($j=0; $j<$self->{width}; $j++)
		{	push(@temp, 0);
			push(@colorTemp, 0);
			
		}

		push(@temp, @newMap);
		push(@colorTemp, @newColorMap);

		@newMap = @temp;
		@newColorMap = @colorTemp;
	}

	if (scalar(@lines) > 0)
	{	#<>;
	}

	if (scalar(@lines) > 0)
	{	@{$self->{map}} = @newMap;
		@{$self->{colorMap}} = @newColorMap;
	}

	#print "\n";

	#print "Lines | " . $self->{completedLines} . "\n";

	return $self->{completedLines};
}

# Check to see if our piece is near the top.  This is useful for controlling PullDowns run amok.
sub nearTop
{	my $self = shift;

	my @map = @{$self->{map}};
	my $i=0;
	my $rowsToCheck = 1;
	my $result = 0;

	for($i=0; $i<($self->{width} * $rowsToCheck); $i++)
	{	if ($map[$i] == 2)
		{	# Yes, we're near the top
			$result = 1;
		}	
	}

	#print "RESULT: $result\n";	

	return $result;
}

# Move the piece down
sub movePiece
{	my $self = shift;

	my @map = @{$self->{map}};
	my @newMap = @{$self->{map}};
	
	my @colorMap = @{$self->{colorMap}};
	my @newColorMap = @{$self->{colorMap}};

	my $i=0;
	my $kill = 0;

	for($i=0; $i<@map; $i++)
	{	if ($map[$i] == 2)
		{	if ($map[$i + $self->{width}] == 1 || ($i + $self->{width}) > scalar(@map) - 1 )
			{	# Convert all live blocks
				$kill = 1;
				$i=scalar(@map);
				$self->{needPiece} = 1;					
			}
			else
			{	if ($map[$i - $self->{width}] != 2 && $i - $self->{width} < scalar(@map))
				{	$newMap[$i] = 0;
					#$newColorMap[$i] = '#FFFFFF';
				}

				$newMap[$i + $self->{width}] = 2;
				$newColorMap[$i + $self->{width}] = $self->{piece}->cget('color');
				
			}
		}
	}

	if ($kill)
	{	
		@newMap = @{$self->{map}};
		@map = @{$self->{map}};

		for($i=0; $i<@map; $i++)
		{	if ($map[$i]== 2)
			{	$newMap[$i] = 1;
			}

			#print $map[$i];

			#if ($i % $self->{width} == 0)
			#{	print "\n";		
			#}
		}	
	}

	@{$self->{map}} = @newMap;
	@{$self->{colorMap}} = @newColorMap;
}

# Add a new piece to the top.  Sometimes the piece starts out in row 2.  Why?  I don't know.
sub addPiece
{	my $self = shift;
	my $piece = $_[0];
	my @pieceMap = $piece->getMap();

	# Describe our next piece
	my @adjectives 		= (	"crazy", 
					"cheeky", 
					"swirly", 
					"sketchy", 
					"super", 
					"world", 
					"dismal", 
					"asinine",
					"unruly",
					"methodical",
					"smelly",
					"obsequious",
					"original",
					"annual",
					"horrific",
					"worthwhile");



	#$self->{adjective} = $adjectives[ $self->round((rand() * scalar(@adjectives) - 1)) ];
	$self->{adjective} = "";

	$self->{piece} = $piece;
	
	my $i=0;
	my $kill = 0;
	my @map = @{$self->{map}};
	my @colorMap = @{$self->{colorMap}};
	for ($i=0; $i<@pieceMap; $i++)
	{	if ($pieceMap[$i] == 2 && $map[$i] == 1)
		{	#print "We died!\n";
			$kill = 1;
			$i = scalar(@pieceMap);
		}
		elsif ($pieceMap[$i] == 2 && $map[$i] == 0)
		{	$map[$i] = 2;
			$colorMap[$i] = $piece->cget('color');
		}
	}

	$self->{needPiece} = 0;

	@{$self->{map}} = @map;
	@{$self->{colorMap}} = @colorMap;

	return $kill;
}

# A useless test subroutine
sub randomize
{	my $self = shift;

	my $i=0;
	@{$self->{map}} = ();
	for ($i=0; $i<120; $i++)
	{	push( @{$self->{map}}, $self->round( rand() ) );
	}
}

sub bounce
{	my $self = shift;
	
	if ($self->{blockSize} < $self->{level}->cget('bounceMin') * $self->{originalBlockSize} && $self->{zv} < 0) 
	{	$self->{zv} *= -1;
	}
	elsif ($self->{blockSize} > $self->{level}->cget('bounceMax') * $self->{originalBlockSize} && $self->{zv} > 0)
	{	$self->{zv} *= -1;
	}
	else
	{	$self->{blockSize} += $self->{zv};
	}	

	#print "Z: $self->{blockSize} $self->{zv} \n";	
}

# A very important sub.  This draws our board on the screen properly
sub draw
{	my $self = shift;
	my $x 		= $_[0];
	my $y 		= $_[1];
	my $canvas 	= $_[2];
	my $angle 	= $_[3];
	my $nextPiece	= $_[4];

	my $debug = 0;

	# these are the angle modified x's and y's.
	my $ax 		= $self->round(( ( $self->{width} * $self->{blockSize} ) ) / 2) + $x;
	my $ay 		= $self->round( ( ( ( scalar(@{$self->{map}}) / $self->{width} ) * $self->{blockSize} )  ) / 2 )+ $y;

	#print "$ax  $ay\n";

	my $originalX = $x;
	my $originalY = $y;

	my @grid = @{$self->{map}};
	my @colorGrid = @{$self->{colorMap}};
	my @obs = ();

	if ($canvas)
	{	my $newX = $originalX + ( $self->{blockSize} * $self->{width} );
		my $newY = $originalY + ( $self->{blockSize} * ( scalar(@grid) / $self->{width} ) );
		my $box = $canvas->create("rectangle", $originalX - 1, $originalY - 1, $newX + 1 , $newY + 1, -fill => '#FFFFFF', -outline => '#000000');
		#print "$originalX, $originalY, " . ( $self->{blockSize} * $self->{width} ) . ", $y\n";

		# Rotate the board
		$canvas->rotate($box, $angle, $ax, $ay);

		my $i=0;
		for($i=0; $i<scalar(@grid); $i++)
		{	# Draw the various types of pieces.  Some day I'd like to have the actual piece determine the color (that day has come! - BG)
			if ($grid[$i] == 1)
			{	#$self->{canvas}->createRectangle( $x, $y, $x + $self->{blockSize}, $y + $self->{blockSize}, -fill => '#AA2244');
				my $square = $canvas->create("rectangle", $x, $y, $x + $self->{blockSize}, $y + $self->{blockSize}, -fill => $colorGrid[$i], -outline => '#000000');

				if ($debug)
				{	$canvas->create("text", $x + 9, $y + 9, -text => $self->roundDown($i / $self->{width}), -font => "Times 10", -fill => '#EEEEEE');
				}

				push(@obs, $square)
			}
			elsif ($grid[$i] == 2)
			{	my $square = $canvas->create("rectangle", $x, $y, $x + $self->{blockSize}, $y + $self->{blockSize}, -fill => $self->{piece}->cget('color'), -outline => '#000000');

				if ($debug)
				{	$canvas->create("text", $x + 9, $y + 9, -text => $self->roundDown($i / $self->{width}), -font => "Times 10", -fill => '#EEEEEE');
				}

				push(@obs, $square)
			}
			elsif ($grid[$i] == 3)
			{	my $square = $canvas->create("rectangle", $x, $y, $x + $self->{blockSize}, $y + $self->{blockSize}, -fill => '#22AA44', -outline => '#000000');
				push(@obs, $square)
			}

			if ( ($i+1) % $self->{width} == 0)
			{	$x = $originalX;
				$y += $self->{blockSize};
			}
			else
			{	$x += $self->{blockSize};
			}
		}
	}

	# Rotate!
	foreach my $o (@obs)
	{	$canvas->rotate($o, $angle, $ax, $ay);
	}

	# Draw game stats
	#$self->drawStats( $canvas, ($originalX + (20 * 14)), $originalY, $nextPiece);
}

# A cool sub to draw the game stats
sub drawStats
{	my $self = shift;
	my $canvas = $_[0];
	my $x = $_[1];
	my $y = $_[2];
	my $nextPiece = $_[3];

	my $offset = 20;

	#print "hello\n";

	my $l = " Line";

	#print "LINES ! " . $self->{completedLines} . "\n";

	# Print level message
	$canvas->create("text", $x + 448, $y + 40, -text => sprintf( "%6d", $self->{oldLevel}), -font => "Courier 12", -fill => '#ECE9DB', justify => 'left');
	$canvas->create("text", $x + 448, $y + 40, -text => sprintf( "%6d", $self->{client}->cget('level')->cget('level')), -font => "Courier 12", -fill => '#000000', justify => 'left');

	# Lines
	$canvas->create("text", $x + 448, $y + 60, -text => sprintf( "%6d", $self->{oldCompletedLines}), -font => "Courier 12", -fill => '#ECE9DB', justify => 'left');
	$canvas->create("text", $x + 448, $y + 60, -text => sprintf( "%6d", $self->{completedLines}), -font => "Courier 12", -fill => '#000000', justify => 'left');

	# Print score
	$canvas->create("text", $x + 448, $y + 80, -text => sprintf( "%6d", $self->{oldScore} ), -font => "Courier 12", -fill => '#ECE9DB', justify => 'left');
	$canvas->create("text", $x + 448, $y + 80, -text => sprintf( "%6d", $self->{client}->cget('score') ),  -font => "Courier 12", -fill => '#000000', justify => 'left');

	$self->{oldCompletedLines} = $self->{completedLines};
	$self->{oldLevel} = $self->{client}->cget('level')->cget('level');
	$self->{oldScore} = $self->{client}->cget('score');

=for comment

	# Draw next piece
	$canvas->create("text", $x + 430, $y + 320, -text => "Next " . $self->{adjective} . " piece:", -font => "Verdana 10", -fill => '#000000');
	my $i=0;
	my $height = 100;
	my @grid = $nextPiece->getMap();
	my $row = 0;
	for($i=0; $i<scalar(@grid); $i++)
	{
		if ( $i % $self->{width} == 0)
		{	$row++;
		}	
	
		#print "ROW:  $row | $self->{width}\n";
	
		if ($grid[$i] == 2)
		{	my $square = $canvas->create("rectangle", 	$x + ($offset * ($i % $self->{width})) + 380,
									$y + ($offset * $row) + 150, 
									$x + $offset + ($offset * ($i % $self->{width})) + 380, 
									$y + $offset + ($offset * $row) + 150, -fill => $nextPiece->cget('color'), -outline => '#000000');
		}
	}
=cut	
}

# A cool sub to draw the next piece
sub drawNextPiece
{	my $self = shift;
	my $canvas = $_[0];
	my $x = $_[1];
	my $y = $_[2];
	my $nextPiece = $_[3];

	my $scale = 20;
	my $textOffset = -100;

	# Draw next piece
	$canvas->create("text", $x, $y, -text => "Next " . $self->{adjective} . " piece:", -font => "Verdana 10", -fill => '#000000');
	my $i=0;
	my $height = 100;
	my @grid = $nextPiece->getMap();
	my $row = 0;
	for($i=0; $i<scalar(@grid); $i++)
	{
		if ( $i % $self->{width} == 0)
		{	$row++;
		}	
	
		#print "ROW:  $row | $self->{width}\n";
	
		if ($grid[$i] == 2)
		{	my $square = $canvas->create("rectangle", 	$x + ($scale * ($i % $self->{width})) + $textOffset,
									$y + ($scale * $row), 
									$x + $scale + ($scale * ($i % $self->{width})) + $textOffset, 
									$y + $scale + ($scale * $row), -fill => $nextPiece->cget('color'), -outline => '#000000');
		}
	}	
}

# We already know what these next three do.	

sub configure
{	my $self = shift;
	my $option = $_[0];
	my $value = $_[1];

	$self->{$option} = $value;

	return 1;
}

sub cget
{	my $self = shift;
	my $option = $_[0];

	return $self->{$option};
}

sub round 
{	my $self = shift;
	my $number = shift;
	
	return int($number + .5);
}

sub roundDown
{	my $self = shift;
	my $number = shift;
	
	return int($number);
}

return 1;