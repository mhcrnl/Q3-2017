
sub getTotalUtilityForPolicy {
    my $policy = shift;

    my ($ninePolicy, $eightPolicy, $sevenPolicy) = split("AND", $policy);

    # find all sub-policies
    my @nineSubpolicies = ("");
    my @eightSubpolicies = ("");
    my @sevenSubpolicies = ("");

    my @nineComponents = split(/&/, $ninePolicy);
    if (@nineComponents) {
	push @nineSubpolicies, @nineComponents;
    }
    if (scalar @nineComponents == 2) {
	push @nineSubpolicies, $ninePolicy;
    }

    my @eightComponents = split(/&/, $eightPolicy);
    if (@eightComponents) {
	push @eightSubpolicies, @eightComponents;
    }
    if (scalar @eightComponents == 2) {
	push @eightSubpolicies, $eightPolicy;
    }

    my @sevenComponents = split(/&/, $sevenPolicy);
    if (@sevenComponents) {
	push @sevenSubpolicies, @sevenComponents;
    }
    if (scalar @sevenComponents == 2) {
	push @sevenSubpolicies, $sevenPolicy;
    }

    my @subPolicies;
    foreach my $np (@nineSubpolicies) {
	foreach my $ep (@eightSubpolicies) {
	    foreach my $sp (@sevenSubpolicies) {
		push @subPolicies, $np."AND".$ep."AND".$sp;
	    }
	}
    }
    
    #print "\nAll subpolicies of ".$policy." are: \n ".join("\n", @subPolicies);

    my $totalUtility = 0;

    # now add utility for each subpolicy
    foreach my $pol (@subPolicies) {
	$totalUtility += getUtilityForPolicy($pol);
    }

    return $totalUtility;
}

sub getUtilityForPolicy {
    my $policy = shift;

    if ($policy eq "ANDAND") {
	return 0;
    }

    my $successProb = getSuccessProbabilityForPolicy($policy);

    my $index = 0;
    my $sum = 0;
    foreach my $part (split("AND", $policy)) {
	$sum += (9-$index)*(split(/[&_]/, $part));
	$index++;
    }

    my $util = $sum*$successProb;

    return $util;
}

# looks shitty ... simplify later!
sub getSuccessProbabilityForPolicy {
    my $policy = shift;

    #print "\nEvaluating ".$policy;

    my %pieceConsiderable;
    foreach my $k (keys %stoneStillInSupply) {
	$pieceConsiderable{$k} = 1;
    }

    my ($ninePolicy, $eightPolicy, $sevenPolicy) = split("AND", $policy);

    my %fieldStillToBeAnalysed;
    foreach my $part ($ninePolicy, $eightPolicy, $sevenPolicy) {
	foreach my $x (split(/[&_]/, $part)) {
	    $fieldStillToBeAnalysed{$x} = 1;
	    #print "\n".$x." is part of the policy!";
	}
    }

    my $prob = 1;

    my @tripleIntersections = getNFoldIntersections(3, $ninePolicy, $eightPolicy, $sevenPolicy, %fieldStillToBeAnalysed);
    
    # if we need more triple intersections than are available, prob is zero
    # (possible cases are 1 needed, 0 available or multiple ones needed, 1 or 0 available)
    if (scalar @tripleIntersections > getMatchingPiecesInPieceSet("987", keys %pieceConsiderable)) {
	#print "\nImpossible policy (triple): ".$policy;
	return 0;
    }

    # if we need exactly one and there is one available
    if (@tripleIntersections == 1) {
	$prob *= getProbabilityOfNtoMFurtherXs(1,1,"9 7 8",keys %pieceConsiderable);
	delete $pieceConsiderable{"9 7 8"};
	#print "\nRemoved 9 7 8 for 9/8/7 reason. Restprob is ".$prob;
	$fieldStillToBeAnalysed{$tripleIntersections[0]} = 0;
    }

    # this may be a cumbersome solution ... check each pair in {9,8,7} for double 
    # intersections => check {9,8}, check {9,7}, check {8,7}

    # check for 9/8 intersections

    my @doubleIntersections_9_8 = getNFoldIntersections(2, $ninePolicy, $eightPolicy, "", %fieldStillToBeAnalysed);
    my @matchingPieces = getMatchingPiecesInPieceSet("98", keys %pieceConsiderable);

    if (@doubleIntersections_9_8 > scalar @matchingPieces) {

	#print "\nImpossible policy (9/8): ".$policy;
	return 0;

    } elsif (@doubleIntersections_9_8 > 0) {
	
	$prob *= getProbabilityOfNtoMFurtherXs(scalar @doubleIntersections_9_8,
					       scalar @matchingPieces,
					       "98", 
					       keys %pieceConsiderable);

	foreach my $piece ((sort {delPreference($a) <=> delPreference($b)} @matchingPieces)
			   [0..@doubleIntersections_9_8-1]){
	    delete $pieceConsiderable{$piece};
	    #print "\nRemoved ".$piece." for 9/8 reason. Restprob is ".$prob;

	}

	foreach my $field (@doubleIntersections_9_8) {
	    $fieldStillToBeAnalysed{$field} = 0;
	    #print "\nNo more analysis for ".$field;
	}
    }

    # check 9/7 intersections
    
    my @doubleIntersections_9_7 = getNFoldIntersections(2, $ninePolicy, "", $sevenPolicy, %fieldStillToBeAnalysed);
    @matchingPieces = getMatchingPiecesInPieceSet("97", keys %pieceConsiderable);

    if (@doubleIntersections_9_7 > scalar @matchingPieces) {

	#print "\nImpossible policy (9/7): ".$policy;
	return 0;

    } elsif (@doubleIntersections_9_7 > 0) {
	
	$prob *= getProbabilityOfNtoMFurtherXs(scalar @doubleIntersections_9_7,
					       scalar @matchingPieces,
					       "97", 
					       keys %pieceConsiderable);

	foreach my $piece ((sort {delPreference($a) <=> delPreference($b)} @matchingPieces)
			   [0..@doubleIntersections_9_7-1]){
	    delete $pieceConsiderable{$piece};
	    #print "\nRemoved ".$piece." for 9/7 reason. Restprob is ".$prob;
	}

	foreach my $field (@doubleIntersections_9_7) {
	    $fieldStillToBeAnalysed{$field} = 0;
	    #print "\nNo more analysis for ".$field;
	}
    }

    # check 8/7 intersections
    
    my @doubleIntersections_8_7 = getNFoldIntersections(2, "", $eightPolicy, $sevenPolicy, %fieldStillToBeAnalysed);
    @matchingPieces = getMatchingPiecesInPieceSet("87", keys %pieceConsiderable);

    if (@doubleIntersections_8_7 > scalar @matchingPieces) {

	#print "\nImpossible policy (8/7): ".$policy;
	return 0;

    } elsif (@doubleIntersections_8_7 > 0) {
	
	$prob *= getProbabilityOfNtoMFurtherXs(scalar @doubleIntersections_8_7,
					       scalar @matchingPieces,
					       "87", 
					       keys %pieceConsiderable);

	foreach my $piece ((sort {delPreference($a) <=> delPreference($b)} @matchingPieces)
			   [0..@doubleIntersections_8_7-1]){
	    delete $pieceConsiderable{$piece};
	    #print "\nRemoved ".$piece." for 8/7 reason. Restprob is ".$prob;
	}

	foreach my $field (@doubleIntersections_8_7) {
	    $fieldStillToBeAnalysed{$field} = 0;
	    #print "\nNo more analysis for ".$field;
	}
    }

    # foreach number in {9,8,7} calculate the probability that the planned number
    # of pieces with this digit on it will occur. 

    # for nines
    my @nineOccurrences = getNFoldIntersections(1, $ninePolicy, "", "", %fieldStillToBeAnalysed);
    @matchingPieces = getMatchingPiecesInPieceSet("9", keys %pieceConsiderable);

    if (@nineOccurrences > scalar @matchingPieces) {

	#print "\nImpossible policy (9): ".$policy;
	return 0;

    } elsif (@nineOccurrences > 0) {
	
	$prob *= getProbabilityOfNtoMFurtherXs(scalar @nineOccurrences,
					       scalar @matchingPieces,
					       "9", 
					       keys %pieceConsiderable);

	foreach my $piece ((sort {delPreference($a) <=> delPreference($b)} @matchingPieces)
			   [0..@nineOccurrences-1]){
	    delete $pieceConsiderable{$piece};
	    #print "\nRemoved ".$piece." for 9 reason. Restprob is ".$prob;
	}

	foreach my $field (@nineOccurrences) {
	    $fieldStillToBeAnalysed{$field} = 0;
	    #print "\nNo more analysis for ".$field;
	}
    }
    
    # for eights
    my @eightOccurrences = getNFoldIntersections(1, $eightPolicy, "", "", %fieldStillToBeAnalysed);
    @matchingPieces = getMatchingPiecesInPieceSet("8", keys %pieceConsiderable);

    if (@eightOccurrences > scalar @matchingPieces) {

	#print "\nImpossible policy (8): ".$policy;
	return 0;

    } elsif (@eightOccurrences > 0) {
	
	$prob *= getProbabilityOfNtoMFurtherXs(scalar @eightOccurrences,
					       scalar @matchingPieces,
					       "8", 
					       keys %pieceConsiderable);

	foreach my $piece ((sort {delPreference($a) <=> delPreference($b)} @matchingPieces)
			   [0..@eightOccurrences-1]){
	    delete $pieceConsiderable{$piece};
	    #print "\nRemoved ".$piece." for 8 reason. Restprob is ".$prob;
	}

	foreach my $field (@eightOccurrences) {
	    $fieldStillToBeAnalysed{$field} = 0;
	    #print "\nNo more analysis for ".$field;
	}
    }
    
    # for sevens
    my @sevenOccurrences = getNFoldIntersections(1, $sevenPolicy, "", "", %fieldStillToBeAnalysed);
    @matchingPieces = getMatchingPiecesInPieceSet("7", keys %pieceConsiderable);

    if (@sevenOccurrences > scalar @matchingPieces) {

	#print "\nImpossible policy (".@sevenOccurrences."x7 needed, ".(scalar @matchingPieces)." provided): ".$policy;
	return 0;

    } elsif (@sevenOccurrences > 0) {
	
	$prob *= getProbabilityOfNtoMFurtherXs(scalar @sevenOccurrences,
					       scalar @matchingPieces,
					       "7", 
					       keys %pieceConsiderable);

	foreach my $piece ((sort {delPreference($a) <=> delPreference($b)} @matchingPieces)
			   [0..@sevenOccurrences-1]){
	    delete $pieceConsiderable{$piece};
	    #print "\nRemoved ".$piece." for 7 reason. Restprob is ".$prob;
	}

	foreach my $field (@sevenOccurrences) {
	    $fieldStillToBeAnalysed{$field} = 0;
	    #print "\nNo more analysis for ".$field;
	}
    }
   
    return $prob;
}

sub delPreference {
    my $p = shift;
    return join("", sort {$b <=> $a} split(" ", $p));
}

# method to determine the intersections fields of the nine/eight/seven policies,
# with respect to whether the field hasn't actually been "processed" yet, i.e.
# whether there has already been a part assigned to it (which is kept in the hash
# %fieldStillToBeAnalysed).
sub getNFoldIntersections {
    my ($n, $ninePolicy, $eightPolicy, $sevenPolicy, %fieldStillToBeAnalysed) = @_;

    my @nums;
    map {push @nums, split(/[&_]/, $_)} ($ninePolicy, $eightPolicy, $sevenPolicy);

    my %occurrences;
    foreach my $num (@nums) {
	$occurrences{$num}++;
    }

    my @intersections;
    foreach my $k (keys %occurrences) {
	push @intersections, $k if ($occurrences{$k} == $n && $fieldStillToBeAnalysed{$k});
    }

    #print "\nFound ".(scalar @intersections)." $n-fold intersections in ".$ninePolicy." ".$eightPolicy." ".$sevenPolicy;

    return @intersections;
}

# a policy is characterized by the lines that are planned
# to be filled with 9s, 8s and 7s. 
sub getPursuable987Policies {
    my @policies;

    foreach my $p ("",getPossibleAssignmentsFor(9, 0, @verticals)) {
	my $ninePolicy = $p;
	foreach my $q ("",getPossibleAssignmentsFor(8, 2, @descendings)) {
	    my $nineEightPolicy = $ninePolicy."AND".$q;
	    foreach my $r ("",getPossibleAssignmentsFor(7, 1, @ascendings)) {
		my $nineEightSevenPolicy = $nineEightPolicy."AND".$r;
		push @policies, $nineEightSevenPolicy;
	    }
	}
    }

    return @policies;
}

sub getPossibleAssignmentsFor {
    my ($number, $direction, @lines) = @_;

    my @possibleAssignments;
    my @possibleLinesForNumber;

    # determine which lines are actually worth consideration
    foreach my $line (@lines) {
	my $possibleNumbersForLine = join("",getPossibilitiesInLineExceptField($line, "", $direction));
	if (index($possibleNumbersForLine, $number) > -1) {
	    push @possibleLinesForNumber, $line;
	}
    }
    
    my %lineNotAnOption;
    my $matchingPiecesLeft = scalar getMatchingPiecesInPieceSet($number, keys %stoneStillInSupply);

    foreach my $possibleLine (@possibleLinesForNumber) {

	my $supplySizeOfMatchingPieces = $matchingPiecesLeft;
	my @freeFields = getVacantFields($possibleLine);
	# string later containing a concatenation of all field indices
	# to be used for the current number
	my $plan; 

	# in any case, do not consider this line when looking for a second 
	# line to involve into this policy
	$lineNotAnOption{$possibleLine} = 1;
		
	# if line is full or needs too many matching pieces, skip it
	if (!@freeFields || $supplySizeOfMatchingPieces < scalar @freeFields) { 
	    next; 
	}

	$plan .= join("_", @freeFields);
	$supplySizeOfMatchingPieces -= scalar @freeFields;

	# single line can be a plan as well
	push @possibleAssignments, $plan;

	my @possibleSecondaryPlannedLines;

	# if there are still pieces left ...
	if ($supplySizeOfMatchingPieces > 0) {
	    # check each remaining line as to whether it would be a
	    # second line in the plan for the current number
	    foreach my $potentialSecondLine (@possibleLinesForNumber) {
		if ($lineNotAnOption{$potentialSecondLine}) {
		    next;
		}

		my @freeFields2 = getVacantFields($potentialSecondLine);
		
		if (!@freeFields2 || $supplySizeOfMatchingPieces < scalar @freeFields2) { 
		    next;
		}
		
		push @possibleSecondaryPlannedLines, join("_", @freeFields2);		
	    }
	}

	# combine the primary plan with each of the secondary plans
	foreach my $secondary (@possibleSecondaryPlannedLines) {
	    push @possibleAssignments, $plan."&".$secondary;
	}
    }

    return @possibleAssignments;
}

sub pickMove {
    my $stone = shift;
    my @nums = split(" ", $stone);

    # find vacant fields
    my @vacantPositions;
    foreach my $i (0..18) {
	if (!$stoneAtPositionAI{$i}) {
	    push @vacantPositions, $i;
	}
    }

    # if it's one of the first $historyInfluence moves choose
    # the field which is historically the most successful for the
    # given piece

    if (0 && scalar @vacantPositions > 19-$historyInfluence) {
	
	print "\nMaking history move ...";

	my $bestFieldInHistory;
	my $bestScoreInHistory = -1;

	foreach my $pos (@vacantPositions) {
	    if ($history{$pos}{$stone} > $bestScoreInHistory) {
		$bestFieldInHistory = $pos;
		$bestScoreInHistory = $history{$pos}{$stone};
	    }
	}

	$stoneAtPositionAI{$bestFieldInHistory} = $stone;
	#delete $stoneStillInSupply{$stone};
	$stoneStillInSupply{$stone} = 0;

	return;
    }

    my $bestUtility = -1000;
    my $bestPosition;

    foreach my $vacantPosition (@vacantPositions) {
	# compute utility value for putting this stone
	# in the currently considered place ($vacantPosition)

	# add stone temporarily
	$stoneAtPositionAI{$vacantPosition} = $stone;
	$stoneStillInSupply{$stone} = 0;

	# compute utility for all completions and sum them up
	my $utility = utilityForFieldAndDirection($vacantPosition);
	#my $utility = 1;

	#print "\nUtility for ".$vacantPosition." is ".$utility;

	if ($utility > $bestUtility) {
	    $bestUtility = $utility;
	    $bestPosition = $vacantPosition;
	}

	# remove stone again
	delete $stoneAtPositionAI{$vacantPosition};
	$stoneStillInSupply{$stone} = 1;
    }

    $stoneAtPositionAI{$bestPosition} = $stone;
    #delete $stoneStillInSupply{$stone};
    $stoneStillInSupply{$stone} = 0;

    #print "\nI move stone ".$stone." to ".$bestPosition." with utility ".$bestUtility;
}


# The overall utility is the sum of all values of 
# completions including this field, each multiplied
# by its probability.
sub utilityForFieldAndDirection {
    my $field = shift;
    
    #print "\nComputing utility for ".$field;

    my $overallUtility = 0;

    # sum up utility for each direction from the field
    foreach my $direction (keys %linesForDirection) {

	my @lines = @{$linesForDirection{$direction}};
	my $tempUtility = 0;

	foreach my $line (@lines) {

	    # check whether this line contains our field 
	    my @positions = split(" ",$line);

	    foreach my $f (@positions) {
		if ($f eq $field) {
		    # field is included in the currently considered line
		    #print "\nFound ".$field." in ".$line;

		    # my number is the number on the field pointing in $direction
		    my $myNumber = (split(" ", $stoneAtPositionAI{$field}))[$direction];
		    
		    my @possibleNumbersInLine = getPossibilitiesInLineExceptField($line, $field, $direction);

		    # the case that line is already messed up
		    # => no reward, no penalty
		    if (!@possibleNumbersInLine) {
			next;
		    }

		    my $numberOfVacantFields = getVacantFields($line);

		    # the case that the rest of the line is actually usable, but not 
		    # with the piece just set (i.e. this piece would mess up the line)
		    # => give a penalty equal to the score that has just been lost 
		    # multiplied by the probability of the completion of this line
		    if (@possibleNumbersInLine == 1 && $possibleNumbersInLine[0] ne $myNumber) {
			$tempUtility -= @positions
			    *$possibleNumbersInLine[0]
			    *getProbabilityOfNtoMFurtherXs($numberOfVacantFields,
							   9, 
							   $possibleNumbersInLine[0]);
			next;
		    }

		    # the case that the piece just set completed the line without 
		    # messing up the line (in case it would mess it up the if-stmt
		    # just before had succeded)
		    if ($numberOfVacantFields == 0) {
			$tempUtility = evaluateLine(0, $direction, ($line));
			next;
		    } 		    
		    
		    my $probability = getProbabilityOfNtoMFurtherXs($numberOfVacantFields, 
								    9, 
								    $myNumber);						
		    $tempUtility += $probability*$myNumber*@positions;
		}
	    }
	}

	$overallUtility += $tempUtility;
    }

    #print "\nOverall utility is ".$overallUtility;

    return $overallUtility;
}

# probability that N to M pieces will follow that carry
# the number(s) $numbersToHave (a string with the desired numbers).
# Only pieces from the set @givenSetOfPieces are considered
sub getProbabilityOfNtoMFurtherXs {
    my ($n, $m, $numbersToHave, @givenSetOfPieces) = @_;

    #print "\nGetting prob of $n to $m further $numbersToHave in @givenSetOfPieces";

    if (!@givenSetOfPieces) {
	@givenSetOfPieces = keys %stoneStillInSupply;
    }

    # the difficult part ... add probability*completion 
    # for each completion
    
    my $matchingPiecesInGivenSet = scalar getMatchingPiecesInPieceSet($numbersToHave, @givenSetOfPieces);
    my $numberOfPiecesInRemainingSet = scalar @givenSetOfPieces;
    my $numberOfMovesLeft = $numberOfPiecesInRemainingSet - 8;
    
    my $prob = 0;

    foreach my $i ($n..$m) { 

	if ($i > $matchingPiecesInGivenSet || $i > $numberOfMovesLeft) {
	    last;
	} 
	
	# one special case ... needs to be excluded
	if ($numberOfPiecesInRemainingSet-$matchingPiecesInGivenSet-$numberOfMovesLeft+$i < 0) {
	    next;
	}
 
	$prob += (fac($numberOfMovesLeft)/(fac($i)*fac($numberOfMovesLeft-$i)))
	    *(fac($matchingPiecesInGivenSet)/fac($matchingPiecesInGivenSet-$i))
	    *(fac($numberOfPiecesInRemainingSet-$matchingPiecesInGivenSet)
	      /fac($numberOfPiecesInRemainingSet-$matchingPiecesInGivenSet-$numberOfMovesLeft+$i))
	    *(fac($numberOfPiecesInRemainingSet-$numberOfMovesLeft)/fac($numberOfPiecesInRemainingSet));
    }

    return $prob;
}

sub getMatchingPiecesInPieceSet {
    my ($numbersToHave, @pieceSet) = @_;

    my @numbers = split("", $numbersToHave);

    my @matchingPieces;
    foreach my $p (@pieceSet) {

	# if no number arguments were give, calculate the total size of the supply,
	# so increase counter in any case.
	if (!@numbers) {
	    push @matchingPieces, $p;
	    next;
	}

	my $matches = 0;
	map {$matches++ if index($p, $_) > -1} @numbers; 
	push @matchingPieces, $p if $matches == scalar @numbers;
    }

    #print "\nFound matches @matchingPieces for '@numbers'";
    return @matchingPieces;
}

sub getNumberOfMovesLeft {
    my $counter = 19;
    foreach my $pos (keys %stoneAtPositionAI) {
	if ($stoneAtPositionAI{$pos}) {
	    $counter--;
	}
    }

    return $counter;
}

sub minimum {
    my ($a, $b) = @_;
    return ($a > $b) ? $b : $a;
}

sub getVacantFields {
    my $line = shift;

    my @vacants;
    foreach my $i (split(" ", $line)) {
	if (!$stoneAtPositionAI{$i}) {
	    push @vacants, $i;
	}
    }

    return @vacants;
}

# get the numbers for a line (vertical or diagonal) that are still 
# possible if field $field is omitted
sub getPossibilitiesInLineExceptField {
    my ($line, $field, $direction) = @_;
    
    my @possibilities;

    foreach my $i (split(" ", $line)) {

	# omit field index if it's not occupied or equals the parameter $field
	# (since the method is supposed to ignore this index)
	if (!$stoneAtPositionAI{$i} || $i eq $field) {
	    next;
	}
	
	my $number = (split(" ",$stoneAtPositionAI{$i}))[$direction];

	if (!@possibilities) {
	    @possibilities = ($number);
	} elsif ($possibilities[0] ne $number) {
	    return;
	}
    }

    return @possibilities ? @possibilities : (1..9);
}

return 1;
