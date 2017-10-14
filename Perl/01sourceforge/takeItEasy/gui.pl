
use Tk::Dialog;
require "tactics.pl";

sub newGuiGame {
    print "\n##########  RESETTING ...";
    resetGame(); 
    
    $canvas->destroy();
    $canvas = $gameWindow->Canvas->pack();
    $canvas->configure(-height=>$windowHeight, -width=>$windowWidth, -background=>$backgroundColor);

    repaint();
}

sub guiComputerMove {
    my $stone = $gameSequence[$currentMoveIndex];
    pickMove($stone);
}

sub undoMove {
    if ($currentMoveIndex == 0) {
	return;
    }

    # restore stone currently showing
    $stoneStillInSupply{$gameSequence[$currentMoveIndex]} = 1;

    # restore last stone
    $currentMoveIndex--;
    my $lastStone = $gameSequence[$currentMoveIndex];
    $stoneStillInSupply{$lastStone} = 1;

    foreach my $i (0..18) {
	if ($stoneAtPositionAI{$i} && $stoneAtPositionAI{$i} eq $lastStone) {
	    undef $stoneAtPositionAI{$i};
	}
	
	if ($stoneAtPositionHuman{$i} && $stoneAtPositionHuman{$i} eq $lastStone) {
	    undef $stoneAtPositionHuman{$i};
	}
    } 

    repaint();
}

sub displayHelp {

    #print "\nHelp required";

    my $helpText = "\"Take it easy\" is a very simple game. All you need to do is ";
    $helpText .= "connect lines of the same color, going from one end of the playing ";
    $helpText .= "board to the other. Each such line will give you a score equal to ";
    $helpText .= "the number of pieces it consists of multiplied by the digit belonging ";
    $helpText .= "to that color.";

    $helpText .= "\n\nThe next piece to set is shown on top of the board. The remaining ";
    $helpText .= "pieces, which will come in random order, are given below.";
    $helpText .= "\n\nTo set the piece, left-click on the target field.";

    $helpText .= "\n\nIf you really have to, you can undo moves by pressing 'u'.";

    $helpText .= "\n\nHave fun! :)";


    my $helpWindow = $gameWindow->Dialog(-title=>"Help",
					 -text=>$helpText,
					 -default_button=>"Ok",
					 -buttons=>["Ok"]);
    $helpWindow->Show();
}

sub endGuiGame {
    print "\nGame is over";

    my $humanScore = evaluateGame(1);
    my $aiScore = evaluateGame(0);

    print "\nHuman score is ".$humanScore;
    print "\nMy score is ".$aiScore;

    $gamesPlayed{$gameIndex}{"human"} = $humanScore;    
    $gamesPlayed{$gameIndex}{"ai"} = $aiScore;

    $gameIndex++;

    if (!$mode || $mode eq "gui") {
	$gameWindow->Dialog(-title => 'Current rankings',
			    -text => getCurrentRankings(),
			    -default_button => 'Ok',
			    -buttons        => ['Ok'])->Show();
    }

    newGuiGame();
}

sub getCurrentRankings {
    print "\nCurrent standings";

    my $text = "\n\tYou\tMe";
    my $humanSum = 0;
    my $aiSum = 0;

    foreach my $game (sort {$a <=> $b} keys %gamesPlayed) {
	$humanSum += $gamesPlayed{$game}{"human"};
	$aiSum += $gamesPlayed{$game}{"ai"};
	$text .= "\n".($game+1).".Game\t".$gamesPlayed{$game}{"human"}."\t".$gamesPlayed{$game}{"ai"};
    }

    $text .= "\nTotal\t".$humanSum."\t".$aiSum;

    return $text;
}


sub repaint {

    #$canvas->destroy();
    #$canvas = $gameWindow->Canvas->pack();
    #$canvas->configure(-height=>$windowHeight, -width=>$windowWidth, -background=>$backgroundColor);

    # repaint background
    $canvas->createRectangle(0,0,$windowWidth, $windowHeight, -fill=>$backgroundColor);

    for my $verticalIndex (0..@verticals-1) {
	my $x = $drawingOffset + $verticalIndex*$horizontalDistance;
	my $verticalPosition = 0;

	my @verticalIndices = split(" ", $verticals[$verticalIndex]);
	# drawing offset from top
	my $offset = $drawingOffset+(6-@verticalIndices)*(sqrt(3)*$normalSidelength)*0.5;

	foreach my $index (@verticalIndices) {
	    my $y = $offset+$verticalPosition*(sqrt(3)*$normalSidelength);

	    # store "human" fields in a hash to bind it later
	    $drawnPieceAtPosition{$index} = drawPieceAtLocation($stoneAtPositionHuman{$index}, $x, $y, $normalSidelength);
	    # AI fields are just painted
	    drawPieceAtLocation($stoneAtPositionAI{$index}, $x+$fieldWidth+$drawingOffset, $y, $normalSidelength);

	    $verticalPosition++;
	}
    }

    # bind all hexagons to left-clicking
    foreach my $position (keys %drawnPieceAtPosition) {
	$canvas->bind($drawnPieceAtPosition{$position}, "<Button-1>", [\&selectField, $position]);
    }

    # draw field names "you" and "me"
    $canvas->createText($drawingOffset+0.5*$fieldWidth, 0.5*$drawingOffset, -text => "You");
    $canvas->createText($drawingOffset*2+1.5*$fieldWidth, 0.5*$drawingOffset, -text => "Me");
    
    # draw pending piece above the two fields
    drawPieceAtLocation($gameSequence[$currentMoveIndex], 
			$fieldWidth+$drawingOffset-0.5*$normalSidelength, 
			0.5*(sqrt(3)*$normalSidelength)+10,
			$normalSidelength);

    # draw remaining pieces at the bottom of the screen
    my $stonesDrawnAtBottom = 0;
    my $offset = ($windowWidth-(8*5+9*2*$smallerSidelength))/2;

    foreach my $piece (keys %stoneStillInSupply) {

	my $x = $offset+($stonesDrawnAtBottom % 9)*(2*$smallerSidelength+5);
	my $y = $fieldHeight + 2*$drawingOffset + (int ($stonesDrawnAtBottom / 9))*(sqrt(3)*$smallerSidelength+5);

	if ($piece && $gameSequence[$currentMoveIndex] 
	    && $stoneStillInSupply{$piece} && $piece ne $gameSequence[$currentMoveIndex]) {
	    drawPieceAtLocation($piece, $x, $y, $smallerSidelength);	    
	} 

	$stonesDrawnAtBottom++;
    }
}

sub selectField {
    my ($c, $position) = @_;
    #print "\nEvent at $position";

    if ($currentMoveIndex > 18) {
	return;
    }

    my $currentPiece = $gameSequence[$currentMoveIndex];

    if (!$stoneAtPositionHuman{$position}) {
	$stoneAtPositionHuman{$position} = $currentPiece;
	# two repaints ... due to computer considering time
	repaint();
	guiComputerMove();
	$currentMoveIndex++;
	repaint();
    }

    if (getNumberOfMovesLeft() == 0) {
	endGuiGame();	
    }
}

sub drawPieceAtLocation {
    my ($piece, $x, $y, $sidelength) = @_;
    my @numbersToDraw = $piece ? split(" ", $piece) : ("","","");
    #print "\nDrawing @numbersToDraw at $x|$y";

    my $verticalDistance = sqrt(3)*$sidelength;
    my $linewidth = int ($sidelength*15/50);


    my $hexagon = $canvas->createPolygon(int $x,int $y,
			   int ($x+0.5*$sidelength), int ($y+0.5*$verticalDistance),
			   int ($x+1.5*$sidelength), int ($y+0.5*$verticalDistance),
			   int ($x+2*$sidelength), int $y,
			   int ($x+1.5*$sidelength), int($y-0.5*$verticalDistance),
			   int ($x+0.5*$sidelength), int($y-0.5*$verticalDistance),
			   int $x,int $y,
			   -width => $fieldBorder, 
			   -fill => 'white',
			   -outline => 'black');

    if ($piece) {
	$canvas->createLine($x+0.25*$sidelength, $y-0.25*$verticalDistance,
			    $x+1.75*$sidelength, $y+0.25*$verticalDistance,
			    -width => $linewidth,
			    -fill => $colorMapping{$numbersToDraw[2]});

	$canvas->createLine($x+0.25*$sidelength, $y+0.25*$verticalDistance,
			    $x+1.75*$sidelength, $y-0.25*$verticalDistance,
			    -width => $linewidth,
			    -fill => $colorMapping{$numbersToDraw[1]});

	$canvas->createLine($x+$sidelength, $y-0.5*$verticalDistance,
			    $x+$sidelength, $y+0.5*$verticalDistance,
			    -width => $linewidth,
			    -fill => $colorMapping{$numbersToDraw[0]});
    }

    $canvas->createText($x+$sidelength,$y-$sidelength*0.5,-text => $numbersToDraw[0]);
    $canvas->createText($x+$sidelength*0.5,$y+$sidelength*0.5,-text => $numbersToDraw[1]);
    $canvas->createText($x+$sidelength*1.5,$y+$sidelength*0.5,-text => $numbersToDraw[2]);

    push @drawnFigures, $hexagon;

    return $hexagon;
}


return 1;
