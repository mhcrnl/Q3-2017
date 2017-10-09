#!/usr/bin/perl
# by acramon1, 23 june 2000
# ttt-text.pl <= this is the text only version of tictactoe...
# the AI isn't spectacular, but it's not bad...
# considering adding a database file to make it learn from losses...

#initial junk
$daturl = './ttt.dat';
$turn = 'x';
srand;
$map = "123456789";
$won = 0;
$formatmap = &formatstring($map);
&printboard($formatmap);

#######   the while
while ((! $won) && (! &fullofxo)) {
    $cnvrtd = &convert($map);
    $won = &checkwon($cnvrtd);
    if ($won) {
	&wehaveawinner;
    }
    if (&fullofxo) {
	&yaytie;
    }
    if ($turn =~ /o/i) {
	$willwin = &checkwillwin($turn, $cnvrtd);
	if ($willwin) {
	    &move($willwin,$turn);
	} else {
	    $willwin = &checkwillwin(&changeturn($turn), $cnvrtd);
	    &move($willwin,$turn) if ($willwin);
	    &move(&randommove($map), $turn) if (! $willwin);
	}
    }
    else {
	&move(&getusermove, $turn);
    }
    $turn = &changeturn($turn);
    $formatmap = &formatstring($map);
    &printboard($formatmap);
}

#########################################################	
##### MAIN SUB-FUNCTIONS
# converts raw, with or without ! to formatted
sub convert {
    $_ = @_[0] ;
    if (/!/) {
	$_ = &formatstring($_);
    }
    my @temp = split '', $_ ;
    my @cnvrtd = ((join '',@temp[6,7,8]),(join '',@temp[3,4,5]),(join '',@temp[0,1,2]),(join '',@temp[0,3,6]),(join '',@temp[1,4,7]),(join '',@temp[2,5,8]),(join '',@temp[0,4,8]),(join '',@temp[2,4,6]));
    $bleheth = join '|', @cnvrtd;
    return $bleheth;
}

#takes converted string as input
sub checkwon {
    $_ = @_[0] ;
    if (/xxx/i) {
	return 'X';
    }
    if (/ooo/i) {
	return 'O';
    }
    return 0;
}



#checks whether a win is possible and returns move to win
sub checkwillwin {
    $move = @_[0] ;
    $_ = @_[1] ;
    if ($move =~ /x/i) {
	if (/xx([1-9])/i) {
	    return $1;
	}
	if (/x([1-9])x/i) {
	    return $1;
	}
	if (/([1-9])xx/i) {
	    return $1;
	}
    }
    if ($move =~ /o/i) {
	if (/oo([1-9])/i) {
	    return $1;
	}
	if (/o([1-9])o/i) {
	    return $1;
	}
	if (/([1-9])oo/i) {
	    return $1;
	}
    }
    return 0;
}

# changes turns
sub changeturn {
    $_ = @_[0] ;
    if (/x/i) {
	return 'o';
    }
    else {
	return 'x';
    }
}


# this is to make a move
sub move {
    $_ = $map ;
    my $other = @_[0] ;
    my $other2 = @_[1] ;
    s/$other/$other2/ig;
    $map = $_ ;
    return $map;
}

# this makes a random move for computer
sub randommove {
    my $asdg = 0;
    $_ = $map;
    while (!$asdg) {
	my $temp = int (rand 8);
	if (/$temp/) {
	    return $temp;
	    $asdg++;
	}
    }
    return 0;
}

# full?
sub fullofxo {
    $_ = $map;
    if (/[1-9]/) {
	return 0;
    }
    else {
	return 1;
    }
}


###################################################################
##### UI - very insipid
# input is things with !
sub printboard {
    my $bleh = @_[0] ;
    my @test = split /!/, $bleh;
    print "
@test[6]\|@test[7]\|@test[8]
@test[3]\|@test[4]\|@test[5]
@test[0]\|@test[1]\|@test[2]
";
    return "true";
}

# adds or takes away the ! (for printing)
sub formatstring {
    $_ = @_[0] ;
    if (/!/) {
	my @asd = split /!/, $_;
	my $asd = join '', @asd;
	return $asd;
    }
    else {
	my @asd = split //, $_;
	my $asd = join '!', @asd;
	return $asd;
    }
}

# we have a winner!
sub wehaveawinner {
    print $won . ' wins!  Good job!' . "\n";
    exit;
}

# this is for a tie
sub yaytie {
    print 'Good game...but it was a tie...\n';
    exit;
}


# gets the user's move
sub getusermove {
    my $movement = <STDIN>;
    chomp $movement;
    return $movement;
}

