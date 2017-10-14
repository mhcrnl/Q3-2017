###############################################
# Title:  	Spewt
# Description: 	A tetris-type game where the board spins around and zooms in and out.
# Author:  	Ben Garvey
#		bengarvey@comcast.net
#		http://www.bengarvey.com
# Date:		02/05/2004
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
use Tk::Scrollbar;
use Tk::DialogBox;
use Time::HiRes qw ( time alarm sleep );
use Ending;
use DataLoader;
use FileBaby;
use Score;
use HighScores;
use XML::Simple;
use utf8;
use Carp;
use Exporter;

# Create a new instance of the Client class
sub new 
{	my $self = {};
	bless($self);

	# This is the highest level of our gui
	$self->{mainWindow} = new MainWindow;

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


	# New Game menu

	# Menubuttons appear on the menu bar.  Interesting huh?
	my $filebutton = $menubar->Menubutton(-text=>"New Game",
	    -underline => 0);  # S in Settings
	
	# Menus are children of Menubuttons.
	my $filemenu = $filebutton->Menu();
	
	# Associate Menubutton with Menu.
	$filebutton->configure(-menu=>$filemenu);



	# Load in our settings
	my $dl = new DataLoader;
	my $settings = $dl->loadData("settings.txt", 'Settings');
		
	# Create menu choices.
	$filemenu->command(	-command => sub { $self->start(1);},
					-label => $settings->cget('level-1-name'),
	    				-underline => 0);

	$filemenu->command(	-command => sub { $self->start(2);},
					-label => $settings->cget('level-2-name'),
	    				-underline => 0);

	$filemenu->command(	-command => sub { $self->start(3);},
					-label => $settings->cget('level-3-name'),
	    				-underline => 0);

	$filemenu->command(	-command => sub { $self->start(4);},
					-label => $settings->cget('level-4-name'),
	    				-underline => 0);

	$filemenu->command(	-command => sub { $self->start(5);},
					-label => $settings->cget('level-5-name'),
	    				-underline => 0);

	$filemenu->command(	-command => sub { $self->start(6);},
					-label => $settings->cget('level-6-name'),
	    				-underline => 0);

	$filemenu->command(	-command => sub { $self->start(7);},
					-label => $settings->cget('level-7-name'),
	    				-underline => 0);


=for comment
	$filemenu->command(	-command => sub { $self->start(8);},
					-label => "Ending",
    					-underline => 0);
=cut


	# Settings menu

	# Menubuttons appear on the menu bar.  Interesting huh?
	my $settingsbutton = $menubar->Menubutton(-text=>"Settings",
	    -underline => 0);  # S in Settings
	
	# Menus are children of Menubuttons.
	my $settingsmenu = $settingsbutton->Menu();
	
	# Associate Menubutton with Menu.
	$settingsbutton->configure(-menu=>$settingsmenu);
		
	# Create menu choices.
	$settingsmenu->command(	-command => sub { $self->editSettings();},
					-label => "Edit Settings",
	    				-underline => 0);

	# About Menu

	# Menubuttons appear on the menu bar.  Interesting huh?
	my $aboutbutton = $menubar->Menubutton(-text=>"About",
	    -underline => 0);  # A in About
	
	# Menus are children of Menubuttons.
	my $aboutmenu = $aboutbutton->Menu();
	
	# Associate Menubutton with Menu.
	$aboutbutton->configure(-menu=>$aboutmenu);
		
	# Create menu choices.
	$aboutmenu->command(	-command => sub { $self->showAbout( $self->{mainWindow} );},
					-label => "About Spew",
	    				-underline => 0);
		
	# Create menu choices.
	$aboutmenu->command(	-command => sub { $self->showHighScores( $self->{mainWindow} );},
					-label => "High Scores",
	    				-underline => 0);

	$menubar->pack(-side => 'top', -fill => 'x');
	$filebutton->pack(-side => 'left');
	$settingsbutton->pack(-side => 'left');
	$aboutbutton->pack(-side => 'left');


	# Top Canvas
	$self->{topCanvas} = $self->{mainWindow}->RotCanvas();

	# Bottom Canvas
	$self->{bottomCanvas} = $self->{mainWindow}->RotCanvas();

	# Top Left
	$self->{topLeftCanvas} = $self->{topCanvas}->RotCanvas(-height => 110, -width => 600);

		$self->{titlePhoto} = $self->{topLeftCanvas}->Photo( -format => 'jpeg', -file 	=> 'images/interface/spewtitle.jpg');
		$self->{titlePhotoLabel} = $self->{topLeftCanvas}->Label( -image => $self->{titlePhoto}  )->place(-x => '0', -y => '0');
	
		$self->{nextPhoto} = $self->{topLeftCanvas}->Photo( -format => 'jpeg', -file 	=> 'images/interface/next.jpg');
		$self->{nextPhotoLabel} = $self->{topLeftCanvas}->Label( -image => $self->{nextPhoto}  )->place(-x => '310', -y => '25');

		# Completed Lines
		$self->{topLeftCanvas}->create("text", 448,  40, -text => sprintf( "%6d", "0"), -font => "Courier 12", -fill => '#000000', justify => 'left');
	
		# Print level message
		$self->{topLeftCanvas}->create("text", 448, 60, -text => sprintf( "%6d", "0"), -font => "Courier 12", -fill => '#000000', justify => 'left');
	
		# Print score
		$self->{topLeftCanvas}->create("text", 448, 80, -text => sprintf( "%6d", "0" ),  -font => "Courier 12", -fill => '#000000', justify => 'left');

		$self->{levelPhoto} = $self->{topLeftCanvas}->Photo( -format => 'jpeg', -file 	=> 'images/level1.jpg');
		$self->{levelPhotoLabel} = $self->{topLeftCanvas}->Label(-image => $self->{levelPhoto})->place(-x => '480', -y => '23');

	# This is an important part.  We're using a RotCanvas instead of a Canvas widget so we can rotate the game board.
	$self->{main} = $self->{bottomCanvas}->RotCanvas(-height => 600, -width => $self->{worldWidth})->pack();

	$self->{topLeftCanvas}->pack(-side => 'left', -fill => 'x');
	$self->{main}->pack(-side => 'left', -fill => 'x');

	$self->{topCanvas}->pack(-side => 'top');
	$self->{bottomCanvas}->pack(-side => 'bottom');

	# Set out keyboard bindings
	#$self->setKeyboardBindings();

	# Set the game speed.  The Level Controller will overrule this later
	$self->{speed} = 10;

	$self->{settings} = $settings;

	MainLoop;

	return $self;
}

# Display information about the game
sub showAbout
{	my $self = shift;
	my $main = $_[0];

	my $top = $main->Toplevel(-height => 500, -width => 500, -title => "About Spew");

	my $button = $top->Button( -text => "Close", -command => [ sub { $top->destroy() } ], -width => 75)->place(-x => 17, -y => 50);

	my $rotateCount = 0;
	my $spinner = $top->RotCanvas(-height => 500, -width => 500)->pack();
	my $text1 = $spinner->create("rectangle", 10, 10, 20, 20, -fill => '#000000');
	my $text2 = $spinner->create("rectangle", 20, 40, 30, 50, -fill => '#000000');

	my @block = ();

	my @about = ("About Spew",
			"Author Ben Garvey",
			"http://www.bengarvey.com",
			"bengarvey\@comcast.net",
			"Spew is written \nin Perl",
			"using the \nTk GUI module",
			"most notably \nRotCanvas \nfor rotation",
			"Thanks for \nplaying!");

	my $about = 	"Author:  Ben Garvey\n" . 
			"http://www.bengarvey.com\n" . 
			"bengarvey\@comcast.net\n\n" . 
			"Spew was written in Perl and\ncompiled for Win32 using perl2exe.\n";

	my $acount = 1;
	my $amax = 15;
	my $aindex = 0;
	my $update = 0;

	my $color = $self->round( 16777215 * rand() );
	my $cshow = sprintf( "%lx", $color);
	my $cz = 4;
			

	
	#while ($rotateCount < 1000)
	while(1)
	{	# Create the box
		$spinner->destroy();
		$spinner = $top->RotCanvas(-height => 500, -width => 500)->place(-x => 0, -y => 100);


		#$spinner->create("rectangle", 0, 0, 500, 500, -fill => '#DD2255', -outline => '#000000');

		$cshow = sprintf( "%lx", $color);

		while ( length($cshow) < 6 )
		{	$cshow = "0" . $cshow;	
		}

		#print "COLOR " . scalar($color) . "\n";;

		$block[0] = $spinner->create("rectangle", 200, 50, 240, 70, -fill => '#' . $cshow, -outline => '#000000');
		$block[1] = $spinner->create("rectangle", 220, 50, 240, 70, -fill => '#' . $cshow, -outline => '#000000');
		$block[2] = $spinner->create("rectangle", 240, 50, 260, 70, -fill => '#' . $cshow, -outline => '#000000');
		$block[3] = $spinner->create("rectangle", 240, 30, 260, 50, -fill => '#' . $cshow, -outline => '#000000');

		#print "$color = $cshow\n";

		$spinner->create("text", 227, 77, -text => "About Spew", -font => "Impact " . ($acount * 2), -fill => '#000000', justify => 'left');
		$spinner->create("text", 225, 75, -text => "About Spew", -font => "Impact " . ($acount * 2), -fill => '#22DD55', justify => 'left');

		$spinner->create("text", 225, 200, -text => $about,  -font => "Courier " . $acount, -fill => '#000000', justify => 'left');


		foreach my $b (@block)
		{	$spinner->rotate($b, $rotateCount * 5, 240, 50);
		}

		if ($acount < $amax)
		{	$acount++;
		}

		if ($color < 16777215 && $color > 0)
		{	$color += $cz;
		}
		elsif ($color > 16777215)
		{	$color = 16777214;
			$cz = -4;
		}
		elsif ($color < 0)
		{	$color = 1;
			$cz = 4;
		}


		if ( $self->round(rand() * 50) == 0 )
		{	$color = $self->round(rand() * 16777215);
		}




		$spinner->update();

		$rotateCount++;



	
=for comment
		if ($update == 2)
		{	
			$acount++;
			$update = 0;
		}
		
		if ($acount > $amax )
		{	$aindex++;
			$acount = 0;
		}

	
		if ($aindex > scalar(@about))
		{	$aindex = 0;
			$acount = 0;
		}
=cut

	
	}

	MainLoop;
}

# Pose a question to the user and don't continue until he responds
sub askQuestion
{	my $self = shift;
	my $main = $_[0];
	my $question = $_[1];
	my $defaultAnswer = $_[2];
	my $title = $_[3];
	
	# Open dialog box w/ Label
	my $ask = $main->DialogBox(-title => $title, -buttons => ["OK", "Cancel"]);
	$ask->Label(-text => $question)->pack();

	# Get an answer
	my $answer = $ask->Entry()->pack();
	$answer->insert('0', $defaultAnswer);
	
	$ask->Show();
	
	return $answer->get();
	
}

# Displays the list of the top ten scores
sub showHighScores
{	my $self = shift;
	my $main = $self->{mainWindow};

	# Create the box
	my $toplevel = $main->Toplevel(-height => 600, -width => 500);
	my $top = $toplevel->Canvas(-height => 600, -width => 500)->pack();

	# Retrieving the data
	my $dl = new DataLoader;
	my $hs = $dl->loadData('highscores.txt', 'HighScores');

	# Getting the score data
	my @scores = @{$hs->cget('Score')};

	# Initialize some font variables
	my $nameFont = 'Impact 18 bold';
	my $scoreFont = 'Verdana 10';
	my $titleFont = 'Impact 35 bold';
	
	# Populate the title
	$top->create("text", 255, 30, -text => " - Hall of Spew - ", -font => $titleFont, -fill => '#000000');	
	$top->create("text", 253, 27, -text => " - Hall of Spew - ", -font => $titleFont, -fill => '#22DD55');			

	# Offset for drawing the list
	my $x = 55;
	my $y = 60;

	# Space between scores
	my $height = 25;

	my $firstmod = 15;
	my $firstheight = 10;

	# Go through each score and display the data
	foreach my $s (@scores)
	{
		$top->create("text", $x, $y, -text => $s->{'position'} . ". " . $s->{'player-name'}, -font => 'Impact ' . (18 + $firstmod), -fill => '#000000', -anchor => 'nw');	
		$top->create("text", $x, $y + $height + ($firstmod), -text => "Score: " . $s->{'score'}, -font => 'Verdana ' . (8 + $firstmod), -fill => '#000000', -anchor => 'nw');
		
		$top->Button( -text => "Stats", -height => 1, -width => 3, -command => [ sub { $self->showStats( $main, $s ); } ]  )->place(-x => ($x - 35), -y => $y + 7);

		$y += ($height * 2)  + $firstmod + $firstheight;
		$firstmod = 0;
		$firstheight = 0;
	}

   	$top->Button(-text => "Restore Default\nHigh Scores", -height => 5,
                   -command => [ sub{ $self->resetHighScores($toplevel); } ]
                   )->place( -x => 350, -y => 485 );

	MainLoop;
}

# If we want to clear the high scores and include the old ones
sub resetHighScores
{	my $self = shift;
	my $top = $_[0];

	my $fb = new FileBaby;

	my $data = $fb->getText('defaulthighscores.txt');
	$fb->writeText('highscores.txt', $data);

	$top->destroy();
	$self->showHighScores();	
}

# Displays stats for an individual on the top ten list
sub showStats
{	my $self = shift;

	my $main = $_[0];
	my $s = $_[1];

	my $toplevel = $main->Toplevel(-height => 350, -width => 500);
	my $top = $toplevel->Canvas(-height => 350, -width => 500)->pack();

	my $finished = 'No';
	if ($s->cget('finish'))
	{	$finished = 'Yes';
	}

	$top->create("text", 25, 10, -text => $s->{'position'} . ". " . $s->{'player-name'}, -font => 'Impact 35 bold', -fill => '#000000', -anchor => 'nw');
	$top->create("text", 23, 8, -text => $s->{'position'} . ". " . $s->{'player-name'}, -font => 'Impact 35 bold', -fill => '#22DD55', -anchor => 'nw');	

	$top->create("text", 25, 100, -text => "Score: " . $s->{'score'}, -font => 'Verdana 16 bold', -fill => '#000000', -anchor => 'nw');
	$top->create("text", 25, 130, -text => "Rank: " . $s->{'title'}, -font => 'Verdana 16 bold', -fill => '#000000', -anchor => 'nw');
	$top->create("text", 25, 160, -text => "Lines: " . $s->{'lines'}, -font => 'Verdana 10', -fill => '#000000', -anchor => 'nw');
	$top->create("text", 25, 180, -text => "Starting Level: " . $s->{'starting-level'}, -font => 'Verdana 10', -fill => '#000000', -anchor => 'nw');
	$top->create("text", 25, 200, -text => "Ending Level: " . $s->{'end-level'}, -font => 'Verdana 10', -fill => '#000000', -anchor => 'nw');
	$top->create("text", 25, 220, -text => "Completed Game?: " . $finished, -font => 'Verdana 10', -fill => '#000000', -anchor => 'nw');
	$top->create("text", 25, 240, -text => "Quadruples: " . $s->{'quads'}, -font => 'Verdana 10', -fill => '#000000', -anchor => 'nw');
	$top->create("text", 25, 260, -text => "Triples: " . $s->{'triples'}, -font => 'Verdana 10', -fill => '#000000', -anchor => 'nw');
	$top->create("text", 25, 280, -text => "Doubles: " . $s->{'doubles'}, -font => 'Verdana 10', -fill => '#000000', -anchor => 'nw');
	$top->create("text", 25, 300, -text => "Longest Quadruple Streak: " . $s->{'long-quad-streak'}, -font => 'Verdana 10', -fill => '#000000', -anchor => 'nw');
}

# Looks at the settings and sets the appropriate keyboard bindings.
# We can now give each move more than one key binding.
# One known issue:  If you set a key to an action and then change it, but don't replace that key with another action, it will stay bound until
# you close the program.
sub setKeyboardBindings
{	my $self = shift;

	# Load settings
	my $dl = new DataLoader;

	my $settings = $dl->loadData("settings.txt", 'Settings');

	# KEYBOARD BINDINGS #
	# All our key bindings.
	my $k = "";

	# Move Left
	# If we have more than one key set to this move, make sure we know all of them
	if ( ref( $settings->cget('move-left') ) eq 'ARRAY' )
	{	foreach $k (@{$settings->cget('move-left')})
		{	$self->{mainWindow}->bind( '<' . $k . '>', sub { $self->{grid}->movePieceLeft() } );
		}
	}
	else
	{	$self->{mainWindow}->bind( '<' . $settings->cget('move-left') . '>', sub { $self->{grid}->movePieceLeft() } );	
	}

	# Move Right
	# If we have more than one key set to this move, make sure we know all of them
	if ( ref( $settings->cget('move-right') ) eq 'ARRAY' )
	{	foreach $k (@{$settings->cget('move-right')})
		{	$self->{mainWindow}->bind( '<' . $k . '>', sub { $self->{grid}->movePieceRight() } );
		}
	}
	else
	{	$self->{mainWindow}->bind( '<' . $settings->cget('move-right') . '>', sub { $self->{grid}->movePieceRight() } );	
	}

	# Pull Down
	# If we have more than one key set to this move, make sure we know all of them
	if ( ref( $settings->cget('pull-down') ) eq 'ARRAY' )
	{	foreach $k (@{$settings->cget('pull-down')})
		{	$self->{mainWindow}->bind( '<' . $k . '>', sub { $self->pullDownPiece() } );
			$self->{mainWindow}->bind( '<KeyRelease-' . $k . '>', sub { $self->resetPieceSpeed() } );
		}
	}
	else
	{	$self->{mainWindow}->bind( '<' . $settings->cget('pull-down') . '>', sub { $self->pullDownPiece() } );	
		$self->{mainWindow}->bind( '<KeyRelease-' . $settings->cget('pull-down') . '>', sub { $self->resetPieceSpeed() } );
	}


	# Rotate Clockwise
	# If we have more than one key set to this move, make sure we know all of them
	if ( ref( $settings->cget('rotate-clockwise') ) eq 'ARRAY' )
	{	foreach $k (@{$settings->cget('rotate-clockwise')})
		{	$self->{mainWindow}->bind( '<' . $k . '>', sub { $self->{grid}->rotatePiece('clockwise')  } );
		}
	}
	else
	{	$self->{mainWindow}->bind( '<' . $settings->cget('rotateClockwise') . '>', sub { $self->{grid}->rotatePiece('clockwise') } );	
	}

	# Rotate CounterClockwise
	# If we have more than one key set to this move, make sure we know all of them
	if ( ref( $settings->cget('rotate-counter-clockwise') ) eq 'ARRAY' )
	{	foreach $k (@{$settings->cget('rotate-counter-clockwise')})
		{	$self->{mainWindow}->bind( '<' . $k . '>', sub { $self->{grid}->rotatePiece('counterClockwise')  } );
		}
	}
	else
	{	$self->{mainWindow}->bind( '<' . $settings->cget('rotate-counter-clockwise') . '>', sub { $self->{grid}->rotatePiece('counterClockwise') } );	
	}


	$self->{mainWindow}->bind( '<KeyRelease-Down>', sub { $self->resetPieceSpeed() } );
}

# Pop up a window and let the user change some settings
sub editSettings
{	my $self = shift;
	
	# Load current settings
	my $dl = new DataLoader;
	my $settings = $dl->loadData("settings.txt", 'Settings');

	# Level Names
	my $i=1;
	my $levelNames = "";
	for ($i=1; $i<8; $i++)
	{	$levelNames .= $settings->cget('level-' . $i . '-name') . "\n";
	}

	# Piece colors
	my @colors = @{$settings->cget('color')};
	my $totalColors = scalar(@colors);
	my $pieceColors = "";
	foreach my $c (@colors)
	{	$pieceColors .= $c . "\n";
	}

	# Piece Adjectives
	my @adjectives = @{$settings->cget('piece-adjective')};
	my $totalAdjectives = scalar(@adjectives);
	my $pieceAdjectives = "";
	foreach my $p (@adjectives )
	{	$pieceAdjectives .= $p . "\n";
	}

	# Keyboard controls
	my $controlList = "";	
	my @controls = ('move-left', 'move-right', 'pull-down', 'rotate-clockwise', 'rotate-counter-clockwise');

	foreach my $con (@controls)
	{	if (ref($settings->cget($con)) eq 'ARRAY')
		{	my @commands = 	@{$settings->cget($con)};
			my $first = 1;

			$controlList .= $con . "=";

			foreach my $co (@commands)
			{	
				if (!$first)
				{	$co = "," . $co;	
				}
				else
				{	$first = 0;
				}

				$controlList .= $co;
			}
			
			$controlList .= "\n";
		}	
		else
		{	$controlList .= $con . "=" . $settings->cget($con) . "\n";
		}
	}

	# Pop up the new window
	my $toptop = $self->{mainWindow}->Scrolled("Toplevel", -height => 1000, -width => 1000);

	my $top = $toptop->Canvas();
	$top->pack();

	$top->Label('text' => "Keyboard Controls")->pack(-anchor => 'w');
	my $keyboardText = $top->Text( -height => 3);
	$keyboardText->insert('1.0', $controlList);
	$keyboardText->pack();

	$top->Label('text' => "Level Names")->pack(-anchor => 'w');
	my $levelNameText = $top->Text( -height => 3);
	$levelNameText->insert('1.0', $levelNames);
	$levelNameText->pack();

	$top->Label('text' => "Colors")->pack(-anchor => 'w');
	my $colorText = $top->Text( -height => 3);
	$colorText->insert('1.0', $pieceColors);
	$colorText->pack();

	$top->Label('text' => "Piece Adjectives")->pack(-anchor => 'w');
	my $adjectiveText = $top->Text( -height => 3);
	$adjectiveText->insert('1.0', $pieceAdjectives);
	$adjectiveText->pack();

   	$top->Button(-text => 'Restore Default Settings',
                   -command => [ sub{ $self->restoreDefaultSettings($top); } ]
                   )->pack( -side => 'left' );

   	$top->Button(-text => 'Save Changes',
                   -command => [ sub{ $self->saveSettings( $top, $settings, $keyboardText, $levelNameText, $colorText, $adjectiveText); } ]
                   )->pack( -side => 'left' );

   	$top->Button(-text => 'Close',
                   -command => [ sub{ $top->destroy(); } ]
                   )->pack( -side => 'left' );

	MainLoop();
}

# Save the changes we made to the settings
sub saveSettings()
{	my $self = shift;
	
	my $top 		= $_[0];
	my $settings 		= $_[1];
	my $keyboard 		= $_[2];
	my $levelName 		= $_[3];
	my $colorText 		= $_[4];
	my $adjectiveText 	= $_[5];

	my $k = $keyboard->get('1.0', 'end');
	my $l = $levelName->get('1.0', 'end');
	my $c = $colorText->get('1.0', 'end');
	my $a = $adjectiveText->get('1.0', 'end');

	my $adjectives = "";
	my $colors = "";
	my $levels = "";
	my $keys = "";

	# Format properly for the XML file
	while ($a =~ /(.*)\n/igc)
	{	if ($1 ne "")
		{	$adjectives .= "\t\t<piece-adjective>" . $1 . "</piece-adjective>\n";
		}
	}

	while ($c =~ /(.*)\n/igc)
	{	if ($1 ne "")
		{	$colors .= "\t\t<color>" . $1 . "</color>\n";
		}
	}

	my $i=1;
	while ($l =~ /(.*)\n/igc)
	{	if ($1 ne "")
		{	$levels .= "\t\t<level-$i-name>" . $1 . "</level-$i-name>\n";
			$i++;
		}
	}

	while ( $k =~ /([^\=]*)\=(.*)\n/igc )
	{	
		if ($1 ne "" && $2 ne "")
		{	my $command = $1;
			my $keystrokes = $2;
			while ($keystrokes =~ /([^,]*)[,|\n]*/igc)
			{	if ($1 ne "")
				{	$keys .= "\t\t<$command>" . $1 . "</$command>\n";
				}
			}
		}
	}
	
	# Wrap around some XML data
	my $settingsData = 	'<?xml version="1.0" encoding="ISO-8859-1"?>' . "\n" . 
				"\t<Settings>\n" . 
					"$adjectives" . "\n" . 
					"$colors" .  "\n" . 
					"$levels" .  "\n" . 
					"$keys" . "\n" . 
				"\t</Settings>\n";

	# Save the settings
	my $fb = new FileBaby;
	$fb->writeText('settings.txt', $settingsData);

	$top->destroy();
	$self->editSettings();
	
}

# Restores settings to the default
sub restoreDefaultSettings()
{	my $self = shift;
	my $top = $_[0];

	my $fb = new FileBaby;

	my $data = $fb->getText('defaultsettings.txt');
	$fb->writeText('settings.txt', $data);

	$top->destroy();
	$self->editSettings();
	
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
	
	# reset our keyboard bindings
	$self->setKeyboardBindings();

	# We pass in our starting level, allowing us to start on any level we want
	my $level = $_[0];

	my $startingLevel = $level;

	# Creating the Grid object that holds most of our game data
	$self->{grid} = new Grid;
	
	# Give the grid a settings object
	$self->{grid}->configure( 'settings' => $self->{settings} );

	# Did we win?
	my $won = 0;

	# Set the appropriate difficulty level
	$self->{level}->configure('main' => $self->{main});
	$self->{level}->changeLevel($level);

	my $blockSize = 18;

	if ($self->{mainWindow}->screenheight() <= 600)
	{	$blockSize = 13;
	}

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
	#$self->{completedLines} = 0;
	$self->{'updateGameStats'} = 1;
	$self->{'updateNextPiece'} = 1;

	my $tetris = 0;
	my $tetrisClock = 30;
	my $lineMessage = "";

	#$self->{level}->configure('level' => 1);
	$self->{level}->configure('score' => 0);
	$self->{grid}->configure('completedLines' => 0);

	my $maxLevelClock = 30;
	my $levelClock = $maxLevelClock;
	my $levelMessage = $self->{settings}->cget('level-' . $self->{level}->cget('level') . '-name');	

	my $totalDoubles = 0;
	my $totalTriples = 0;
	my $totalQuads = 0;
	my $longestQuadStreak = 0;						

	$self->{score} = '000000';

	my $quadCounter = 0;

	my $first = 1;

	$self->{score} = 0;

	my $waiting = 0;

	# Here is the famous GAME LOOP!
	while (!$gameOver)
	{
		# Check to see if the Window has been resized
		#$self->{worldWidth} = $self->{mainWindow}->width();
		#$self->{worldHeight} = $self->{mainWindow}->height();

		#print "WORLD:  " . $self->{worldHeight} . "|" . $self->{mainWindow}->height() . "\n";

		# Should we change our block size?
		#$blockSize = $self->resizeBoard();

		
		$self->{'updateGameStats'} = 0;

		if ($first)
		{	$self->{'updateGameStats'} = 1;
			$first  = 0;
		}
		

		# If enough time has expired since last time, skip the game update and just redraw
		if ( ($oldTime + .05) < Time::HiRes::time() || $justStarted)
		{	#print $oldTime + 1 . " vs " . time() . " - waiting\n";

			#print "we waited $waiting times\n";
			#$waiting = 0;

			# Set this to false on the first loop
			$justStarted = 0;
			
			# Reset our time clock
			$oldTime = Time::HiRes::time();


			# Ask our level controller if we should move to the next level
			if ( $self->{level}->checkLevel( $self->{grid}->cget('completedLines') ) )
			{		
					if ($self->{level}->cget('level') < 8)
					{
						$self->{levelPhoto} = $self->{topLeftCanvas}->Photo( -format => 'jpeg', -file 	=> 'images/level' . $self->{level}->cget('level') . '.jpg' );

						$self->{levelPhotoLabel}->configure( -image => $self->{levelPhoto} );
						$self->{levelPhotoLabel}->update();
						$self->{'updateGameStats'} = 1;

						$levelClock = $maxLevelClock;
						$levelMessage = $self->{settings}->cget('level-' . $self->{level}->cget('level') . '-name');
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
				{	$self->{grid}->addPiece( Piece->new( $self->{settings} ) );	
				}	$self->{rotationAmount} = 3;
	
				# Preview the new next piece
				my $p = Piece->new( $self->{settings} );
				$self->{nextPiece} = $p;
	
				# This shouldn't be here
				#$self->{speed} = 50;
	
				$self->resetPieceSpeed();


				$self->{'updateNextPiece'} = 1;
			}

			# If we just switched levels, wait a while
			if ($levelClock < 1)
			{
		
			# We use this so the pieces don't drop as fast as they possibly can.  It should be set to some sort of timer.
			if ($i % $self->{level}->cget('dropSpeed') == 0)
			{	$self->{grid}->movePiece();
			}
	
			# If we're rotating, here is where the rotation occurs
			if ($i % $self->{level}->cget('rotationSpeed') == 0 && $self->{level}->cget('rotationSpeed') > 0)
			{	
				$self->{level}->switchRotationCheck();

				$angle += $self->{level}->cget('rotationAmount');
				if ($angle > 360)
				{	$angle = 0;
				}
				elsif ($angle < 0)
				{	$angle = 360;
				}
	
				#print "ANGLE : $angle\n";
			}
			
			my $oldLines = $completedLines;
	
			# Did we make a line?
			$completedLines = $self->{grid}->checkForLine();

			if ($oldLines < $completedLines)
			{	$self->{'updateGameStats'} = 1;
				$self->{score} += ($self->{level}->cget('level') ** ($completedLines - $oldLines)) * ($quadCounter+1);
			}

			# Quad
			if ($completedLines - $oldLines > 3)
			{	# Set the tetris clock
				$tetrisClock = 25;
				$tetris = $tetrisClock;	

				$quadCounter++;
				
				if ($quadCounter > 1)
				{	$lineMessage = "$quadCounter QUADRUPLES\nIN A ROW!";
				}
				else
				{	$lineMessage = "QUADRUPLE!";
				}
				
				$totalQuads++;

				if ($quadCounter > $longestQuadStreak)
				{	$longestQuadStreak = $quadCounter;
				}


			}
			elsif ($completedLines - $oldLines > 2)  # Triple
			{	# Set the tetris clock
				$tetrisClock = 20;
				$tetris = $tetrisClock;	
				$lineMessage = "Triple!";

				$quadCounter = 0;
				$totalTriples++;
			}
			elsif ($completedLines - $oldLines > 1)  # Double
			{	# Set the tetris clock
				$tetrisClock = 18;
				$tetris = $tetrisClock;	
				$lineMessage = "Double!";

				$quadCounter = 0;	
			}
			elsif ($completedLines - $oldLines > 0)
			{	$quadCounter = 0;
				$totalDoubles++;	
			}

			}


	
			# Are we distracting the player?
			$distraction = $self->{level}->getDistraction();
	
			# Kill the old rotCanvas
			$self->{main}->destroy();
	
			# Make a new one
			$self->{main} = $self->{bottomCanvas}->RotCanvas(-height => 600, -width => $self->{worldWidth});
	
			# If we're distracting, make the distraction visible
			if ($distraction && $self->{levelPhoto}->cget(-file) !~ /$distraction/)
			{	
				
					$self->{levelPhoto} = $self->{topLeftCanvas}->Photo( -format => 'jpeg', -file 	=> $distraction );
					$self->{levelPhotoLabel}->configure( -image => $self->{levelPhoto} );
			}
			elsif ($self->{levelPhoto}->cget(-file) !~ /level/ && $self->{levelPhoto}->cget(-file) !~ /$distraction/ && $self->{level}->cget('level') < 8)
			{		$self->{levelPhoto} = $self->{topLeftCanvas}->Photo( -format => 'jpeg', -file 	=> 'images/level' . $self->{level}->cget('level') . '.jpg' );
					$self->{levelPhotoLabel}->configure( -image => $self->{levelPhoto} );
			}
	
			# Where should we start drawing?
			#$startX = ($self->{mainWindow}->screenwidth() / 2) - ($self->{boardWidth} / 2);
			#$startY = ($self->{mainWindow}->screenheight() / 2) - ($self->{boardHeight} / 1.1);

			# Trying a change here - BG 1/5/04
			#$startX = ($self->{mainWindow}->width() / 2) - ($self->{boardWidth} / 2);
			#$startY = ($self->{mainWindow}->height() / 2) - ($self->{boardHeight} / 1.1);
			$startX = 150;
			$startY = 25;

			# I don't remember exactly why we add 6 each time, but I think it would run too fast or slow at 1.
			$i += 6;
		}
#		else
#		{	$waiting++;
#		}

		if (1)
		{	#$self->{main}->createText( 150, 200, -fill => 'red', -text => "TETRIS!");
				#print "tetris!\n";
		}

		# Draw the game board
		$self->{grid}->draw( $startX, $startY, $self->{main}, $angle, $self->{nextPiece});
		#$self->{grid}->drawStats( $self->{topRightCanvas}, 80, 40, $self->{nextPiece});
		#$self->{main}->update();

		if ( $self->{'updateGameStats'} == 1 )
		{	$self->{grid}->drawStats( $self->{topLeftCanvas}, 0, 0, $self->{nextPiece});
	
		}


		# Update "next piece" every frame
		$self->{grid}->drawNextPiece( $self->{main}, 450, 54, $self->{nextPiece});

		# Are we showing the new level animation?
		if ($levelClock > 0)
		{	my $tetSize = 110 - ($levelClock * (110/$maxLevelClock));

			$tetSize = $self->round($tetSize / 2);

			my $off = $self->round($tetSize / 10);

			$self->{main}->create("text", 250 + $off, 290 + $off, -text => "Level\n" . $levelMessage, -font => "Verdana $tetSize bold", -fill => '#000000');			
			$self->{main}->create("text", 250, 290, -text => "Level\n" . $levelMessage, -font => "Verdana $tetSize bold", -fill => $self->{nextPiece}->cget('color'));
			
			$levelClock--;
		}

		# Are we showing the multi-line animation?
		if ($tetris > 0)
		{	my $tetSize = 110 - ($tetris * (110/$tetrisClock));

			if ($quadCounter > 1)
			{	$tetSize = $self->round($tetSize / 2);
			}

			$tetSize = $self->round($tetSize / 2);

			my $off = $self->round($tetSize / 10);

			$self->{main}->create("text", 250 + $off, 100 + $off, -text => $lineMessage, -font => "Impact $tetSize bold", -fill => '#000000');			
			$self->{main}->create("text", 250, 100, -text => $lineMessage, -font => "Impact $tetSize bold", -fill => $self->{nextPiece}->cget('color'));
			$tetris--;
			"Tetris stuff!\n";
		}

		$self->{'updateGameStats'}  = 0;
		$self->{'updateNextPiece'} = 0;

		$self->{main}->pack();
		$self->{main}->update();

		if ($self->{level}->cget('level') > 7)
		{	$won = 1;
			$gameOver = 1;
		}
	}

	# If we won, show the ending sequence
	if ($won)
	{	
		my $ending = new Ending;		

		#$self->{main} = $ending->go($self->{main}, $self->{mainWindow}, $self->{grid}->cget('blockSize') );
		$ending->swe($self->{main});
		#$self->{levelPhotoLabel}->destroy();

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
	

	# Did we score high enough to get in the top ten?
	my $dl = new DataLoader;
	my $hs = $dl->loadData('highscores.txt', 'HighScores');
	my @scores = @{$hs->cget('Score')};

	my @sortedScores = sort { $b->cget('score') <=> $a->cget('score') } @scores;
	my @newScores = ();
	my $newHigh = 0;
	my $poscount = 1;
	my $newScore = new Score;

	# Using this to debug the top ten list
	#$self->{score} = 501;

	# Check for highest Scores
	foreach my $s (@sortedScores)
	{	

		#if (200 > $s->cget('score') && !$newHigh)
		# If this score is high enough and we haven't found a new high score yet...
		if ( $self->{score} > $s->{'score'} && !$newHigh)
		{	# We have a new high score!
			$newScore = new Score;

			$newHigh = 1;
			my $name = $self->askQuestion($self->{main}, "Your score made the top ten!\nPlease enter your name", 'Your Name Here', 'Enter Your Name'); 

			$newScore->configure('player-name' 	=> $name );
			$newScore->configure('score' 		=> $self->{'score'} );
			$newScore->configure('starting-level' 	=> $startingLevel );
			$newScore->configure('end-level' 	=> $self->{level}->cget('level') );
			$newScore->configure('finish' 		=> $won );
			$newScore->configure('lines' 		=> $completedLines );
			$newScore->configure('quads' 		=> $totalQuads );
			$newScore->configure('triples' 		=> $totalTriples );
			$newScore->configure('doubles' 		=> $totalDoubles );
			$newScore->configure('long-quad-streak' 	=> $longestQuadStreak );
			$newScore->configure('position' 	=> $poscount);
			$newScore->configure('title' 		=> $hs->cget('title-' . $newScore->cget('position')) );

			push(@newScores, $newScore);

			$poscount++;			
			$s->{'position'} = $poscount;

			push(@newScores, $s);
		}
		else
		{	$s->configure('position' => $poscount);
			push(@newScores, $s);
		}

		$poscount++;
	}

	# If we found a new high score, display the list and your stats
	if ($newHigh)
	{	# Remove the last entry in the top ten list
		pop(@newScores);

		print "We have " . scalar(@newScores) . " scores\n";
		my $temp = ();

		@{$temp} = @newScores;
		$hs->configure('Score' => $temp);

		my $fb = new FileBaby;
		$fb->writeText("highscores.txt", $hs->getXML());

		$self->showStats($self->{mainWindow}, $newScore);
		$self->showHighScores($self->{mainWindow});
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
	my $blockSize = 1;	

	# I had to shrink the game board for 800 x 600 resolution
	if ($self->{worldHeight} >= 600)
	{	$blockSize = 20;
	}
	else
	{	$blockSize = 16;
	}

	$self->{grid}->configure( 'blockSize' => $blockSize);

	return $blockSize;
}

return 1;

