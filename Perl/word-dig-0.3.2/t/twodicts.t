# Before `make install' is performed this script should be runnable with
# `make test'. After `make install' it should work as `perl test.pl'

######################### We start with some black magic to print on failure.

# Change 1..1 below to 1..last_test_to_print .
# (It may become useful if the test is moved to ./t subdirectory.)

BEGIN { $| = 1; print "1..2\n"; }
END {print "not ok 1\n" unless $loaded;}
use Games::WordDig;
$loaded = 1;
print "ok 1\n";

######################### End of black magic.

# Insert your test code below (better if it prints "ok 13"
# (correspondingly "not ok 13") depending on the success of chunk 13
# of the test code):

my %dict = (
	    dict => [
		     "./words",
		     "./words2",
		     ],
	    );

my $dict = Games::Dictionary->new(%dict);


my (@words1, @words2);

%player1 = (	
	    _player_name => "Player 1",
	    _used_words  => \@words1,
	    );

%player2 = (
	    _player_name => "Player 2",
	    _used_words  => \@words2,
	    );

@players = ( \%player1, \%player2 );

%game = (
	 dict_obj        => $dict,
	 num_players => 2,
	 players     => \@players,
	 );


$game = Games::WordDig->new(%game);

$out = $game->Player_Turn("fool");

if ( "good" eq $out ) {
    print "ok 2\n";
} else {
    print "not ok 2\n";
}
