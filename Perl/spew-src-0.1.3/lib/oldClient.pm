###############################################
# Title:  	Spewtris
# Description: 	A tetris-type game where the board spins around and zooms in and out.
# Author:  	Ben Garvey
#		bengarvey@comcast.net
#		http://www.bengarvey.com
# Date:		08/19/2003
# Version 0.1
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

# The Client class runs the game loop and provides the GUI
package Client;
use strict;

# My packages
use Grid;
use Piece;
use LevelController;

# Perl's packages
use Tk;
use Tk::Canvas;
use Tk::Text;
use Tk::Menubutton;
use Tk::TopLevel;
use Tk::Photo;
use Tk::JPEG;
use Time::HiRes qw ( time alarm sleep );
use Ending;

# Create a new instance of the Client class
sub new 
{	my $self = {};
	bless($self);

	# This is the highest level of our gui
	$self->{mainWindow} = new MainWindow;

	# Find out the screen resolution
	#$self->{worldWidth} = $self->{mainWindow}->screenwidth();
	#$self->{worldHeight} = $self->{mainWindow}->screenheight();

	#print $self->{worldWidth} . " | " . $self->{worldHeight} . "\n";<>;

	# We're locking down the window size from now on
	$self->{worldWidth} = 600;
	$self->{worldHeight} = 600;

	# This is how tall and wide in pixels our board will be, but we can change this later
	$self->{boardHeight} = 25 * 20;
	$self->{boardWidth} = 25 * 10;

	# This gives us the proper game data that changes with each level
	$self->{level} = new LevelController;

	# The menu bar which holds our (duh) menu.
	my $menubar = $self->{mainWindow}->Frame(-relief=>"groove", -borderwidth=>2)->pack( -fill => "x");

	# Menubuttons appear on the menu bar.  Interesting huh?
	my $filebutton = $menubar->Menubutton(-text=>"Actions and Settings",
	    -underline => 0);  # S in Settings
	
	# Menus are children of Menubuttons.
	my $filemenu = $filebutton->Menu();
	
	# Associate Menubutton with Menu.
	$filebutton->configure(-menu=>$filemenu);
		
	# Create menu choices.
	$filemenu->command(	-command => sub { $self->start(1);},
					-label => "Easy!",
	    				-underline => 0);

	$filemenu->command(	-command => sub { $self->start(2);},
					-label => "Hard!",
	    				-underline => 0);

	$filemenu->command(	-command => sub { $self->start(3);},
					-label => "Super Hard!",
	    				-underline => 0);

	$filemenu->command(	-command => sub { $self->start(4);},
					-label => "What the?!",
	    				-underline => 0);

	$filemenu->command(	-command => sub { $self->start(5);},
					-label => "BARF!",
	    				-underline => 0);

	$filemenu->command(	-command => sub { $self->start(6);},
					-label => "OH MY GOD!!!",
	    				-underline => 0);

	$filemenu->command(	-command => sub { $self->start(7);},
					-label => "Kill it! Kill it! Aghajsbc jka ka~......",
	    				-underline => 0);


=for comment
	$filemenu->command(	-command => sub { $self->start(8);},
					-label => "Ending",
    					-underline => 0);
=cut





	$menubar->pack(-side => 'top', -fill => 'x');
	$filebutton->pack(-side => 'top', -fill => 'x');


	# Top Canvas
	$self->{topCanvas} = $self->{mainWindow}->RotCanvas()->pack();

	# Top Left
	$self->{topLeftCanvas} = $self->{topCanvas}->RotCanvas(-height => 240, -width => 600);

	# Display the game title
	#$self->{topLeftCanvas}->Label( -text => "Ben Garvey's", -font => "Verdana 8", -foreground => '#222222')->pack(-side => 'bottom');
	#$self->{topLeftCanvas}->Label( -text => "Spewtris", -font => "Impact 32 bold", -foreground => '#22AA33')->pack(-side => 'bottom');

	#$self->{topLeftCanvas}->create("text", 270, 20, -text => "Ben Garvey's", -font => "Verdana 8", -fill => '#000000');
	#$self->{topLeftCanvas}->create("text", 295, 20 + 60, -text => "S p e w", -font => "Impact 100 bold", -fill => '#22AA33');


	# Top Right
	#$self->{topRightCanvas} = $self->{topCanvas}->RotCanvas();
	#$self->{topRightCanvas}->Label( -text => "Ben Garvey's", -font => "Verdana 8", -foreground => '#222222')->pack();
	#$self->{topRightCanvas}->Label( -text => "Spewtris", -font => "Impact 32 bold", -foreground => '#22AA33')->pack();

	#$self->{topRightCanvas}->create("text", 300, 10, -text => "Ben Garvey's", -font => "Verdana 8", -fill => '#000000');


	$self->{titlePhoto} = $self->{topLeftCanvas}->Photo( -format => 'jpeg', -file 	=> 'images/spewtitle.jpg');
	$self->{titlePhotoLabel} = $self->{topLeftCanvas}->Label( -image => $self->{titlePhoto}  )->place(-x => '0', -y => '0');

	$self->{nextPhoto} = $self->{topLeftCanvas}->Photo( -format => 'jpeg', -file 	=> 'images/next.jpg');
	$self->{nextPhotoLabel} = $self->{topLeftCanvas}->Label( -image => $self->{nextPhoto}  )->place(-x => '310', -y => '25');

	$self->{topLeftCanvas}->createText(440, 41, -text => "0", -font => "Courier 12", -fill => '#222222');
	$self->{topLeftCanvas}->createText(440, 60, -text => "0", -font => "Courier 12", -fill => '#222222');



	# Top Bottom Center
	$self->{topBottomCenterCanvas} = $self->{mainWindow}->RotCanvas();
	$self->{levelPhoto} = $self->{topLeftCanvas}->Photo( -format => 'jpeg', -file 	=> 'images/level1.jpg');
	#$self->{levelPhotoLabel} = $self->{mainWindow}->Label('-image' => $self->{levelPhoto} );
	$self->{levelPhotoLabel} = $self->{topLeftCanvas}->Label()->place(-x => '480', -y => '20');

	# Top Top Center
	$self->{bottomTopCenterCanvas} = $self->{topCanvas}->RotCanvas();




	# Display the game title
	#$self->{mainWindow}->Label( -text => "Ben Garvey's", -font => "Verdana 8", -foreground => '#222222')->pack();
	#$self->{mainWindow}->Label( -text => "Spewtris", -font => "Impact 32 bold", -foreground => '#22AA33')->pack();


	# Bottom Canvas
	#$self->{bottomCanvas} = $self->{mainWindow}->RotCanvas(-height => 200, -width => $self->{worldWidth})->pack(-side => 'bottom');


	$self->{topLeftCanvas}->pack(-side => 'left', -fill => 'x');

	#$self->{topRightCanvas}->pack(-side => 'right');
	#$self->{topBottomCenterCanvas}->pack();

	$self->{topBottomCenterCanvas}->pack();
	$self->{topCanvas}->pack(-side => 'top', -fill => 'x');


	# This is an important part.  We're using a RotCanvas instead of a Canvas widget so we can rotate the game board.
	#$self->{main} = $self->{mainWindow}->RotCanvas(-height => $self->{worldHeight}, -width => $self->{worldWidth})->pack();
	$self->{main} = $self->{mainWindow}->RotCanvas(-height => 200, -width => $self->{worldWidth})->pack();

	# All our key bindings. Maybe someday we'll let the user pick what he wants to use.
	$self->{mainWindow}->bind( '<Left>', sub { $self->{grid}->movePieceLeft() } );
	$self->{mainWindow}->bind( '<Right>', sub { $self->{grid}->movePieceRight() } );
	$self->{mainWindow}->bind( '<Down>', sub { $self->pullDownPiece() } );
	$self->{mainWindow}->bind( '<KeyRelease-Down>', sub { $self->resetPieceSpeed() } );
	$self->{mainWindow}->bind( '<Up>', sub { $self->{grid}->rotatePiece('clockwise') } );
	$self->{mainWindow}->bind( '<d>', sub { $self->{grid}->rotatePiece('clockwise') } );
	$self->{mainWindow}->bind( '<a>', sub { $self->{grid}->rotatePiece('counterclockwise') } );

	# Set the game speed.  The Level Controller will overrule this later
	$self->{speed} = 10;



	MainLoop;

	return $self;
}

# Pulls down the piece faster if you already know where you want it
sub pullDownPiece
{	my $self = shift;

	# If this piece is high in the grid, don't do it!
	if ( !$self->{grid}->nearTop() )
	{	$self->{level}->configure('dropSpeed' => 1)
	}
	else
	{	$self->resetPieceSpeed();
	}
}

# When we stop pulling the piece down, we'll want to reset the speed
sub resetPieceSpeed
{	my $self = shift;

	# If this piece is high in the grid, don't do it!
	# which level is it?
	my $level = $self->{level}->cget('level');
	$self->{level}->changeLevel($level);
}

# This subroutine holds our game loop
sub start
{	my $self = shift;
	my $i=0;

	# We pass in our starting level, allowing us to start on any level we want
	my $level = $_[0];

	# Creating the Grid object that holds most of our game data
	$self->{grid} = new Grid;

	# Did we win?
	my $won = 0;

	# Set the appropriate difficulty level
	$self->{level}->configure('main' => $self->{main});
	$self->{level}->changeLevel($level);

	my $blockSize = 25;

=for comment

	# How big should our blocks be?
	if ($self->{worldHeight} <= 600)
	{	$blockSize = 20;
		print "new block size = $blockSize\n";
	}
	elsif ($self->{worldHeight} > 600 && $self->{worldHeight} <= 768)
	{	$blockSize = 18;
	}
	elsif ($self->{worldHeight} > 768 && $self->{worldHeight} <= 1024)
	{	$blockSize = 25;
	}
	else
	{	#$blockSize = $self->{worldHeight} / 40;
	}
=cut

	#$blockSize = $self->{worldHeight} / 40;
	$self->{grid}->configure( 'blockSize' => $blockSize);
	$self->{grid}->configure( 'client' => $self );
	$self->{grid}->configure( 'level' => $self->{level} );
	$self->{grid}->configure( 'originalBlockSize' => $blockSize);
	$self->{originalBlockSize} = $blockSize;
 


	# How big is our board?
	$self->{boardHeight} = $blockSize  * 20;
	$self->{boardWidth} = $blockSize  * 10;

	my $gameOver = 0;
	my $angle = 0;
	my $distraction = 0;

	#$self->{levelPhoto} = $self->{topLeftCanvas}->Photo( -format => 'jpeg', -file 	=> 'images/level' . $level . '.jpg' );
	$self->{levelPhoto} = $self->{topLeftCanvas}->Photo( -format => 'jpeg', -file 	=> 'images/level' . $level . '.jpg' );
	$self->{levelPhotoLabel}->configure( -image => $self->{levelPhoto} );
	$self->{levelPhotoLabel}->update();
	
	# Initialize our time clock
	my $oldTime = Time::HiRes::time();
	my $justStarted = 1;

	my $startX = 0;
	my $startY = 0;

	my $completedLines = 0;
	$self->{'updateGameStats'} = 1;

	# Here is the famous GAME LOOP!
	while (!$gameOver)
	{
		# Check to see if the Window has been resized
		#$self->{worldWidth} = $self->{mainWindow}->width();
		#$self->{worldHeight} = $self->{mainWindow}->height();

		$self->{'updateGameStats'} = 0;

		print "WORLD:  " . $self->{worldHeight} . "|" . $self->{mainWindow}->height() . "\n";

		# Should we change our block size?
		#$blockSize = $self->resizeBoard();

		# If enough time has expired since last time, skip the game update and just redraw
		if ( ($oldTime + .05) < Time::HiRes::time() || $justStarted)
		{	#print $oldTime + 1 . " vs " . time() . " - waiting\n";

			# Set this to false on the first loop
			$justStarted = 0;
			
			# Reset our time clock
			$oldTime = Time::HiRes::time();


			# Ask our level controller if we should move to the next level
			if ( $self->{level}->checkLevel( $self->{grid}->cget('completedLines') ) )
			{		#$self->{levelPhotoLabel}->destroy();
					#$self->{levelPhoto} = $self->{topLeftCanvas}->Photo( -format => 'jpeg', -file 	=> 'images/level1.jpg');
					#$self->{levelPhotoLabel} = $self->{mainWindow}->Label(-image => $self->{levelPhoto})->place(-x => 100, -y => 100);
	
					if ($self->{level}->cget('level') < 8)
					{
						#$self->{levelPhoto} = $self->{main}->Photo( -format => 'jpeg', -file 	=> 'images/level' . $self->{level}->cget('level') . '.jpg' );
						$self->{levelPhoto} = $self->{topLeftCanvas}->Photo( -format => 'jpeg', -file 	=> 'images/level' . $self->{level}->cget('level') . '.jpg' );

						$self->{levelPhotoLabel}->configure( -image => $self->{levelPhoto} );
						$self->{levelPhotoLabel}->update();
						$self->{'updateGameStats'} = 1;
					}
	
			}
	
			# Are we zooming in and out?
			if ($i % $self->{level}->cget('bounceSpeed') == 0 && $self->{level}->cget('bounceSpeed') > 0)
			{	$self->{grid}->bounce();
			}
	
			# Do we need to generate a new piece?
			if ($self->{grid}->{needPiece})
			{	
				# Do we have a piece on deck?
				if ($self->{nextPiece})
				{	# Throw in our next piece and check to see if we lost
					$gameOver = $self->{grid}->addPiece($self->{nextPiece});	
				}
				else
				{	$self->{grid}->addPiece( new Piece );	
				}
	
				# Preview the new next piece
				my $p = new Piece;
				$self->{nextPiece} = $p;
	
				# This shouldn't be here
				#$self->{speed} = 50;
	
				$self->resetPieceSpeed();


				$self->{'updateGameStats'} = 1;
			}
		
			# We use this so the pieces don't drop as fast as they possibly can.  It should be set to some sort of timer.
			if ($i % $self->{level}->cget('dropSpeed') == 0)
			{	$self->{grid}->movePiece();
			}
	
			# If we're rotating, here is where the rotation occurs
			if ($i % $self->{level}->cget('rotationSpeed') == 0 && $self->{level}->cget('rotationSpeed') > 0)
			{	$angle += 3;
				if ($angle > 360)
				{	$angle = 0;
				}
	
				#print "ANGLE : $angle\n";
			}
			
			my $oldLines = $completedLines;
	
			# Did we make a line?
			$completedLines = $self->{grid}->checkForLine();

			if ($oldLines < $completedLines)
			{	$self->{'updateGameStats'} = 1;
			}
	
			# Are we distracting the player?
			$distraction = $self->{level}->getDistraction();
	
			# Kill the old rotCanvas
			$self->{main}->destroy();
	
			# Make a new one
			$self->{main} = $self->{mainWindow}->RotCanvas(-height => 200, -width => $self->{worldWidth});
	
			# If we're distracting, make the distraction visible
			if ($distraction && $self->{levelPhoto}->cget(-file) !~ /$distraction/)
			{	
				#$self->{levelPhoto} = $self->{main}->Photo( 	-format => 'jpeg',
			        #                        			-file 	=> $distraction);
				#$self->{main}->Label('-image' => $distraction)->place(-x => 100, -y => 100);
	
					#$self->{levelPhotoLabel}->destroy();
					#$self->{levelPhoto} = $self->{main}->Photo( -format => 'jpeg', -file 	=> 'images/level1.jpg');
					#$self->{levelPhotoLabel} = $self->{mainWindow}->Label(-image => $self->{levelPhoto})->place(-x => 100, -y => 100);
	
					$self->{levelPhoto} = $self->{topLeftCanvas}->Photo( -format => 'jpeg', -file 	=> $distraction );
					$self->{levelPhotoLabel}->configure( -image => $self->{levelPhoto} );
					#$self->{levelPhotoLabel}->update();
					print "changed image\n";
			}
			elsif ($self->{levelPhoto}->cget(-file) !~ /level/ && $self->{levelPhoto}->cget(-file) !~ /$distraction/ && $self->{level}->cget('level') < 8)
			{		$self->{levelPhoto} = $self->{topLeftCanvas}->Photo( -format => 'jpeg', -file 	=> 'images/level' . $self->{level}->cget('level') . '.jpg' );
					$self->{levelPhotoLabel}->configure( -image => $self->{levelPhoto} );
					#$self->{levelPhotoLabel}->update();
					print "changed image back\n";	
			}
	
			# Where should we start drawing?
			#$startX = ($self->{mainWindow}->screenwidth() / 2) - ($self->{boardWidth} / 2);
			#$startY = ($self->{mainWindow}->screenheight() / 2) - ($self->{boardHeight} / 1.1);

			# Trying a change here - BG 1/5/04
			#$startX = ($self->{mainWindow}->width() / 2) - ($self->{boardWidth} / 2);
			#$startY = ($self->{mainWindow}->height() / 2) - ($self->{boardHeight} / 1.1);
			$startX = 150;
			$startY = 50;

			# I don't remember exactly why we add 6 each time, but I think it would run too fast or slow at 1.
			$i += 6;
		}

		if (1)
		{	#$self->{main}->createText( 150, 200, -fill => 'red', -text => "TETRIS!");
				#print "tetris!\n";
		}

		# Draw the game board
		$self->{grid}->draw( $startX, $startY, $self->{main}, $angle, $self->{nextPiece});
		#$self->{grid}->drawStats( $self->{topRightCanvas}, 80, 40, $self->{nextPiece});
		#$self->{main}->update();





		if ( $self->{'updateGameStats'} == 1 )
		{	#$self->{topLeftCanvas}->destroy();
			#$self->{topLeftCanvas} = $self->{topCanvas}->RotCanvas(-height => 240, -width => 600);

			#$self->{topRightCanvas}->create("text", 300, 10, -text => "Ben Garvey's", -font => "Verdana 8", -fill => '#000000');
			#$self->{topRightCanvas}->create("text", 290, 70, -text => "S p e w", -font => "Impact 110 bold", -fill => '#22AA33');

=for comment
			$self->{titlePhoto} = $self->{topLeftCanvas}->Photo( -format => 'jpeg', -file 	=> 'images/spewtitle.jpg');
			$self->{titlePhotoLabel} = $self->{topLeftCanvas}->Label( -image => $self->{titlePhoto}  )->place(-x => '0', -y => '0');
		
			$self->{nextPhoto} = $self->{topLeftCanvas}->Photo( -format => 'jpeg', -file 	=> 'images/next.jpg');
			$self->{nextPhotoLabel} = $self->{topLeftCanvas}->Label( -image => $self->{nextPhoto}  )->place(-x => '310', -y => '25');

			$self->{levelPhoto} = $self->{topLeftCanvas}->Photo( -format => 'jpeg', -file 	=> 'images/level' . $self->{level}->cget('level') . '.jpg');
			$self->{levelPhotoLabel} = $self->{topLeftCanvas}->Label(-image => $self->{levelPhoto})->place(-x => '480', -y => '20');
=cut

			$self->{grid}->drawStats( $self->{topLeftCanvas}, 0, 0, $self->{nextPiece});	
			#$self->{topLeftCanvas}->pack(-side => 'left', -fill => 'x');
		}

		$self->{'updateGameStats'}  = 0;

		$self->{main}->pack();
		$self->{main}->update();

# testing ending transition
=for comment
		if ($self->{level}->cget('level') == 2)
		{	$won = 1;
			$gameOver = 1;
			print "we won!";
		}
=cut

		if ($self->{level}->cget('level') > 7)
		{	$won = 1;
			$gameOver = 1;
		}





	}

	# If we won, show the ending sequence
	if ($won)
	{	
		my $ending = new Ending;
		

		$self->{main} = $ending->go($self->{main}, $self->{mainWindow}, $self->{grid}->cget('blockSize') );
$self->{levelPhotoLabel}->destroy();
=for comment
		my $message = "Congratulations!  \nYou managed to get through\n Spewtris without puking.\nCheck out http://www.bengarvey.com";
		$self->{main}->destroy();
		$self->{levelPhotoLabel}->destroy();
		$self->{main} = $self->{mainWindow}->RotCanvas(-height => $self->{worldHeight}, -width => $self->{worldWidth});


		$self->{levelPhoto} = $self->{topLeftCanvas}->Photo( -format => 'jpeg', -file 	=> 'images/level8' . '.jpg' );
		$self->{levelPhotoLabel} = $self->{mainWindow}->Label('-image' => $self->{levelPhoto} )->pack();
	#	$self->{main}->create("text", ($self->{worldWidth} / 2) + 3, ($self->{worldHeight} / 6) + 3, -text => $message, -font => "Impact " . $self->{grid}->cget('blockSize') * 1.5, -fill => '#111111');
		$self->{main}->create("text", ($self->{worldWidth} / 2) + 3, ($self->{worldHeight} / 6) + 3, -text => $message, -font => "Impact " . $self->{grid}->cget('blockSize') * 1.5, -fill => '#DDFFDD');
		$self->{main}->create("text", ($self->{worldWidth} / 2), ($self->{worldHeight} / 6), -text => $message, -font => "Impact " . $self->{originalBlockSize}  * 1.5, -fill => '#111111');
	
=cut

		$self->{main}->pack();
		$self->{main}->update();


	}

	# Tell perl to update the screen
	$self->{main}->update();
}

# Why doesn't perl have its own round function?  Maybe it does, but this one works for me.
sub round 
{	my $self = shift;
	my $number = shift;
	
	return int($number + .5);
}

# So other classes can retrieve our data
sub cget
{	my $self = shift;
	my $option = $_[0];

	return $self->{$option};
}

# So other classes can set our data
sub configure
{	my $self = shift;
	my $option = $_[0];
	my $value = $_[1];

	$self->{$option} = $value;
}

# Included this so we can change the window size mid game - BG 1/6/04
sub resizeBoard
{	my $self = shift;

	my $b1 = 1;
	my $b2 = 1;
	my $blockSize = 3;


=for comment
	# How big should our blocks be?
	if ($self->{worldHeight} <= 600)
	{	$blockSize = 20;
	}
	elsif ($self->{worldHeight} > 600 && $self->{worldHeight} <= 768)
	{	$blockSize = 18;
	}
	elsif ($self->{worldHeight} > 768 && $self->{worldHeight} <= 1024)
	{	$blockSize = 25;
	}
	else
	{	#$blockSize = $self->{worldHeight} / 40;
	}
=cut
	

	#$b1 = $self->round($self->{worldHeight} / 35);
	#$b2 = $self->round($self->{worldWidth} / 35);

	$b1 = 20;
	$b2 = 20;

	if ($b1 < $b2)
	{	$blockSize = $b1;
	}
	else
	{	$blockSize = $b2;
	}

	$self->{grid}->configure( 'blockSize' => $blockSize);

	print "BLOCKSIZE = $blockSize . |" . $b1 . "\n";

	return $blockSize;
}

return 1;

