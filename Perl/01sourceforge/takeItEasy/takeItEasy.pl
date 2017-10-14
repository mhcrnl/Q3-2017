#!/usr/bin/perl -w

############################################## 
#                                            #
#              TAKE IT EASY                  #
#                                            #
#   written by Johannes Horstmann in 2006    #
#                                            #
############################################## 

use strict;
use Tk;
use IxHash;

require Tk::Dialog;
require "gui.pl";
require "tactics.pl";

# default mode is interactive
#
# if "testruns" is given, a number of test runs ($selfGameNumber)
# is started of which scores, minimum, maximum and average
# are printed out afterwards.
#
# if "test" is given, some tests are run
my $mode = shift;

### global variables

# the 27 game stones (mapped to "1" in the beginning)
our %stoneStillInSupply;
tie %stoneStillInSupply, "Tie::IxHash";

# hash mapping 0..18 to the pieces currently on the board
our %stoneAtPositionHuman;
our %stoneAtPositionAI;

# success in the past ... mapping from fieldindex->piece->scoreSum
our %history;
our $historyFile = "history.txt";
our $historyInfluence = 0;
#our $historySize = 0;

# the current sequence of 19 game pieces to be played
our @gameSequence;
our $currentMoveIndex = 0;
our $gameIndex = 0;
our %gamesPlayed;

our $gameLimit = 10;
our $humanVictories = 0;
our $aiVictories = 0;

# Number of games to be played when testrun mode is started.
our $selfGameNumber = 1000;

### GUI variables

our $gameWindow;
our $canvas;
our @drawnFigures;
our %drawnPieceAtPosition;

### graphical constants
our $backgroundColor = 'lightgreen';

our $normalSidelength = 40;
our $smallerSidelength = 35;

our $horizontalDistance = 1.5*$normalSidelength;

our $drawingOffset = $normalSidelength;

our $fieldWidth = $horizontalDistance*5+$normalSidelength*0.5;
our $fieldHeight = (sqrt(3)*$normalSidelength)*5;
our $fieldBorder = 2;

our $windowWidth = 2*$fieldWidth+3*$drawingOffset;
our $windowHeight = $fieldHeight+2*$drawingOffset+3*sqrt(3)*$normalSidelength;

our $menuBarColor = "lightblue";

our %colorMapping = qw/1 gray 2 pink 3 purple 4 blue 5 darkgreen 6 red 7 green 8 orange 9 yellow/;

# needed althrough the program ... the vertical and diagonal lines as field indices
our @verticals = ("0 1 2", "3 4 5 6", "7 8 9 10 11", "12 13 14 15", "16 17 18");
our @ascendings = ("0 3 7", "1 4 8 12", "2 5 9 13 16", "6 10 14 17", "11 15 18");
our @descendings = ("7 12 16", "3 8 13 17", "0 4 9 14 18", "1 5 10 15", "2 6 11");

our %linesForDirection;
$linesForDirection{0} = \@verticals;
$linesForDirection{1} = \@ascendings;
$linesForDirection{2} = \@descendings;

if (-e $historyFile) {
    open(HISTORY, $historyFile);
    while (my $line = <HISTORY>) {
	my ($field, $piece, $score) = $line =~ /^(\d{1,2}),(\d \d \d),(\S+)/;
	$history{$field}{$piece} = $score;
    }
    close HISTORY;
}

####### init end

####### MAIN 

if (!$mode || $mode eq "gui") {

    resetGame();
    $gameWindow = MainWindow->new();
    my $menuBar = $gameWindow->Frame(-relief => "groove",
				     -border => 3,
				     -background => $menuBarColor)->pack("-side" => "top", 
								  "-fill" => "x");

    my $gameMenu = $menuBar->Menubutton(-text => "Game",
					  -background => $menuBarColor,
					  -activebackground => "white",
					  )->pack(-side => "left");


    $gameMenu->command(-label=>"New", -command => sub{newGuiGame()});
    #$gameMenu->command(-label=>"Undo", -command => sub{undoMove()});
    $gameMenu->command(-label=>"Help", -command => sub{displayHelp()});
    $gameMenu->command(-label=>"Exit", -command => sub{$gameWindow->destroy});

    $canvas = $gameWindow->Canvas->pack();
    $canvas->configure(-height=>$windowHeight, -width=>$windowWidth, -background=>$backgroundColor);
    $gameWindow->bind('<u>' => sub{undoMove()});
    
    repaint();
    
    MainLoop();

} elsif ($mode eq "testruns") {
    
    my @scores;
    foreach my $i (1..$selfGameNumber) {
	resetGame();
	foreach my $stone (@gameSequence[0..18]) {
	    pickMove($stone);
	}
	my $score = evaluateGame();
	print "\nScore of game ".$i." is ".$score;
	push @scores, $score;

	foreach my $field (0..18) {
	    $history{$field}{$stoneAtPositionAI{$field}} += $score;
	}
    }

    writeHistoryToFile();

    my $min = 1000;
    my $max = 0;
    my $sum;
    foreach my $s (@scores) {
	if ($s > $max) {$max = $s}
	if ($s < $min) {$min = $s}
	$sum += $s;
    }
    print "\nAverage score is ".($sum/$selfGameNumber)." with maximum ".$max." and minimum ".$min."\n\n";

} elsif ($mode eq "test") {

    resetGame();
    runTestSuite();

} elsif ($mode eq "generate") {
    
    resetGame();
    writeNRandomGamesToFile();

} elsif ($mode eq "read") {
    
    playGamesFromFile();

}

####### MAIN END

sub resetGame {
    
    foreach my $i (9,5,1) {
	foreach my $k (8,4,3) {
	    foreach my $j (7,6,2) {
		$stoneStillInSupply{$i." ".$j." ".$k} = 1;
	    }
	}
    }

    for my $i (0..18) {
	delete $stoneAtPositionHuman{$i};
	delete $stoneAtPositionAI{$i};
    }

    if (!$mode || $mode eq "gui") {
	#destroyDrawnPieces();
    }

    @gameSequence = generateGame();
    $currentMoveIndex = 0;
}

sub writeHistoryToFile {
    open(OUTPUT, ">".$historyFile);
    #print OUTPUT "Number: ".$historySize;

    foreach my $field (0..18) {
	my %map = %{$history{$field}};
	foreach my $piece (keys %map) {
	    print OUTPUT $field.",".$piece.",".$map{$piece}."\n";
	}
    }

    close OUTPUT;
}

sub generateGame {
    my @gameStones = keys %stoneStillInSupply;
    for (my $i = @gameStones; --$i;) {
	my $j = int rand ($i+1);
	next if $i == $j;
	@gameStones[$i,$j] = @gameStones[$j,$i];
    }

    return @gameStones[0..18];
}


sub evaluateGame {
    my $human = shift;
    my $totalScore = 0;
    $totalScore += evaluateLine($human, 0, @verticals);
    $totalScore += evaluateLine($human, 1, @ascendings);
    $totalScore += evaluateLine($human, 2, @descendings);
    return $totalScore;
}

#
# Method to get the score of a "line", which might be a vertical
# one or a diagonal one.
#
# Inputs are the index of the number to be concerned (0 for the vertical
# number, 1 for the ascending diagonal's numbers, 2 for the descending one's)
# Returns the score for that line, i.e. either zero or length*number
#
sub evaluateLine {
    my ($human, $direction, @lines) = @_;

    my %stoneAtPosition;
    if ($human) {
	%stoneAtPosition = %stoneAtPositionHuman;
    } else {
	%stoneAtPosition = %stoneAtPositionAI;
    }

    my $score = 0;
    foreach my $line (@lines) {
	# indices are the board field indices for the line to be 
	# investigated, e.g. (0,3,7) for the first ascending diagonal
	my @positions = split(" ", $line);

	my $lineString = "";
	foreach my $position (@positions) {
	    if ($stoneAtPosition{$position}) {
		$lineString .= (split(" ", $stoneAtPosition{$position}))[$direction];
	    } else {
		# 0 indicates no piece
		$lineString .= "0";
	    }
	}	

	my $first = substr($lineString, 0, 1);
	$score += ($lineString eq $first x @positions) ? $first*@positions : 0;
    }
    
    return $score;
}

sub fac {
    my $n = shift;
    if ($n < 0) {die("Negative factorial!\n")}
    return ($n == 0) ? 1 : $n * fac($n-1);
}

sub writeNRandomGamesToFile {
    my ($n, $file) = @_;

    $n = 2000 unless $n;
    $file = $n."randomGames" unless $file;

    open(FILE, ">".$file) || die("\nCannot write to ".$file);
    
    for (1..$n) {
	my @game = generateGame();
	print FILE join(",", @game)."\n";
    }

    close FILE;
}

sub playGamesFromFile {
    
    my $file = shift;

    $file = "2000randomGames" unless $file;

    open(FILE, $file) || die("\nCannot read from ".$file);
    my @lines = <FILE>;
    close FILE;

    open(RESULTS, ">".$file."Results") || die("Squonk!");

    my $counter = 0;
    foreach my $line (@lines) {

	chomp($line);
	
	$counter++;

	my @game = split(",", $line);
	resetGame();
	@gameSequence = @game;

	foreach my $stone (@gameSequence[0..18]) {
	    pickMove($stone);
	}
	my $score = evaluateGame();
	print "\nScore of game ".$counter." is ".$score;
	print RESULTS "\n".$score." in game ".$counter;

    }

    close RESULTS;
}

sub runTestSuite {

    # test some Methods
    my $sum = 0;
    my $testString = "87";
    for my $i (0..9) {
	my $p = getProbabilityOfNtoMFurtherXs($i,$i,$testString);
	$sum += $p;
	print "\nProb of exactly ".$i." further ".$testString." is ".$p;
    }
    print "\ntotal: ".$sum."\n";

    my %utilityForPolicy;
    foreach my $pol (getPursuable987Policies()) {
	my $util = getTotalUtilityForPolicy($pol);
	if ($util > 0) {
	    $utilityForPolicy{$pol} = $util;
	}
    }

    foreach my $pol (sort {$utilityForPolicy{$b} <=> $utilityForPolicy{$a}} keys %utilityForPolicy) {
	print "\nUtility for ".$pol." is ".$utilityForPolicy{$pol};
    }
}
