#
# word-dig Copyright Pat Eyler 1999 and 2000
# it is licensed under the GPL, see the file COPYING that
# is distributed with it.
#
# word-dig implements a word game my wife and I made up while
# driving.  Starting with an arbitrary word, each successive word must
# start with the letter the previous word ended with and must be of the
# same length (plus or minus one letter).  
#

use strict;

use 5.004;


1;

=head1 NAME

Games::WordDig - A game engine in perl

=head1 SYNOPSIS

  use Games::WordDig;

  my %dict = (
	      dict => "./words",
	      );

  my $dict = Games::Dictionary->new(%dict);


  my @player1_words;
  my @player2_words;

  my %player1 = (	
		_player_name => "Player 1",
		_used_words  => \@player1_words,
	        );

  my %player2 = (
	        _player_name => "Player 2",
	        _used_words  => \@player2_words,
	        );

  my @players = ( \%player1, \%player2 );

  my %game = (
	      dict_obj    => $dict;
	      num_players => 2,
	      players     => \@players,
	      );

  my $game = Games::WordDig->new();


=head1 DESCRIPTION

Games::WordDig provides an 'engine' for building a word-dig game.
This 'engine' is encapsulated in a game object which provides several
methods for game use.  It also makes use of the Games::Dictionary
object (included in the module) to provide a suitable dictionary for
the game.

A game of word-dig is played as players each take turns choosing a
word, which is the same length (plus or minus one letter) as the
word used by the previous player, and beginning with the last
letter of that word.

This engine does not provide anything but a canned computer player,
and a player word verifier.  Game boards and similar presentation
chores are the responsiblity of the game itself.

The important methods provided by Games::WordDig are new, Player_Turn, 
and Computer_Turn.  The only method normally used with
Games::Dictionary is new.

=head1 METHODS

=over 3

=cut

package _Initializable;

sub new {
    my ($class, %args) = @_;
    my $self = bless {}, ref($class) || $class;
    $self->_init(%args);
    return $self;
}

package Games::Dictionary;
{
    use Carp;
    use vars qw($VERSION @ISA $AUTOLOAD);
    
    @ISA = qw( _Initializable );
    
    $VERSION = "0.1.0";
    
    my %_attrs = (
		  _dict_ref => 'read/write',
		  );
    
    sub _accessible {
	my ($self, $attr, $mode) = @_;
	$_attrs{$attr} =~ /$mode/
	}

    sub _init {
	my ($self, %args)     = @_;
	$self->{_dict_ref}    = $self->_build_dict($args{dict});
    }

=pod

=item Games::Dictionary::new(%dict)

This will initialize a dictionary for use with Games::WordDig.  
%dict{dict} can contain either a filename for the dictionary to be
used, or a reference to an array of filenames to be used.  If left
blank, Games::Dictionary::new will use /usr/dict/words.

=cut

    sub _build_dict {
	my ($self, $words) = @_;
	my (%dict_ref, @words);
	
	unless ($words) {
	    $words = "/usr/dict/words";
	}

	unless (ref($words)) {
	    @words = ("$words");
	} else {
	    @words = @$words;
	}

	foreach my $letter ("a".."z") {
	    $dict_ref{$letter} = [];
	}

	foreach my $file (@words) {
	    open(DICT, "$file");
	    while (<DICT>) {
		chomp;
		my $word = $_;
		my $first = substr($word,0,1);
		my $letter_dict = $dict_ref{$first};
		push(@$letter_dict,$word);
	    }
	    close(DICT);
	}	
	return(\%dict_ref);
    }

    sub AUTOLOAD {
	my ($self, $newval) = @_;
	
	# set up get_foo methods
	$AUTOLOAD =~ /.*::get(_\w+)/
	    and $self->_accessible($1,'read')
		and return $self->{$1};
	
	# set up incr_foo methods
	$AUTOLOAD =~ /.*::incr(_\w+)/
	    and $self->_accessible($1,'write')
		and do { $self->{$1} = ($self->{$1} + $newval); return };
	
	# set up set_foo methods
	$AUTOLOAD =~ /.*::set(_\w+)/
	    and $self->_accessible($1,'write')
		and do { $self->{$1} = $newval; return };
	
	croak "No such method: $AUTOLOAD";
    }

    sub get_dict_ref {
	my ($self, $letter) = @_;

	my $letter_dict = $self->{_dict_ref};
	my $dict_ref = $$letter_dict{$letter};
	return $dict_ref;
    }

}


package Games::WordDig;
{
    use Carp;
    use vars qw($VERSION @ISA $AUTOLOAD);

    require Exporter;


    @ISA = qw(Exporter _Initializable);

    $VERSION = '0.3.3';

    my %_attrs = (
		  _dict_obj    => 'read',
		  _turn        => 'read/write',
		  _num_players => 'read',
		  _players     => 'read/write',
		  );

    sub _accessible {
	my ($self, $attr, $mode) = @_;
	$_attrs{$attr} =~ /$mode/
	}

=pod

=item new(%game)

This will initialize the word-dig game engine.

=cut

    sub _init {
	my ($self, %args)     = @_;
	$self->{_dict_obj}    = $args{dict_obj};
	$self->{_turn}        = "0";
	$self->{_num_players} = $args{num_players};
	$self->{_players}     = $args{players};
    }

    sub AUTOLOAD {
	my ($self, $newval) = @_;
	
	# set up get_foo methods
	$AUTOLOAD =~ /.*::get(_\w+)/
	    and $self->_accessible($1,'read')
		and return $self->{$1};
	
	# set up incr_foo methods
	$AUTOLOAD =~ /.*::incr(_\w+)/
	    and $self->_accessible($1,'write')
		and do { $self->{$1} = ($self->{$1} + $newval); return };
	
	# set up set_foo methods
	$AUTOLOAD =~ /.*::set(_\w+)/
	    and $self->_accessible($1,'write')
		and do { $self->{$1} = $newval; return };
	
    croak "No such method: $AUTOLOAD";
    }

#####
#  multiplexing routines 
#####

=pod

=item Player_Turn($word)

This method takes a word chosen by the player and verifies its
legality.  If the provided word is legal, Player_Turn will return the
string "good"  if not, it will return a string acceptable for
returning as an error to the player.

=cut


    sub Player_Turn {
	my ($self, $word) = @_;
	my $turn = $self->get_turn;
	
	
	if ( 0 == $turn ) {
	    my $test = $self->_in_dict($word);
	    if ($test eq "good") {
		$self->_add_used_word($word);
		$self->incr_turn(1);
		return $test;
	    } else {
		return $test;
	    }
	} 
	else {
	    my $last = $self->_last_word();
	    my $test = $self->_right_length($last,$word);
	    if ($test eq "good") {
		$test = $self->_right_start($last,$word);
		if ($test eq "good") {
		    $test = $self->_not_used($word);
		    if ($test eq "good") {
			$test = $self->_in_dict($word);
			if ($test eq "good") {
			    $self->_add_used_word($word);
			    $self->incr_turn(1);
			}
		    }
		}
	    }
	    return $test;
	}
    }

=pod

=item Computer_Turn()

This will return a legal word if one can be found in the dictionary,
or the string "out of words" if it can not find a legal word.

=cut


    sub Computer_Turn { 
	my ($self) = @_;
	
	my $last = $self->_last_word;
	my $first_char = substr($last,-1,1);
	undef my @choices;
	my $dict_obj = $self->get_dict_obj();
	my $dict = $dict_obj->get_dict_ref($first_char);
	
	foreach my $word (@$dict) {
	    if ( $word =~ /^$first_char/ ) {
		my $test = $self->_right_length($last,$word);
		if ( $test eq "good" ) {
		    $test = $self->_not_used($word);
		    if ( $test eq "good" ) {
			push(@choices, $word);
		    }
		}
	    }
	}
	my $num_choices = @choices;
	if ( 0 == $num_choices ) {
	    return("out of words");
	} else {
	    my $word = @choices[int(rand($num_choices))-1];
	    $self->_add_used_word($word);
	    $self->incr_turn(1);
	    return($word);
	}
    }
    
#####
# base routines
#####

    sub _last_word {
	my ($self) = @_;
	my $last_player = 
	    ( ($self->get_turn() - 1) % $self->get_num_players() );
	my $player_words = $self->_get_word_list($last_player);
	my $length = @$player_words;
	my $last_word = $$player_words[$length - 1];
	return $last_word;
    }

    sub _in_dict {
	my ($self,$word) = @_;
	my $letter = substr($word,0,1);

	my $dict_obj = $self->get_dict_obj();
	my $dict = $dict_obj->get_dict_ref($letter);

	foreach my $test (@$dict) {
	    if ( $word eq $test ) {
		return("good");
	    }
	}
	return("That word is not in the dictionary");
    }

    sub _right_length { 
	my ($self, $last, $word) = @_;
	my @last = split(//, $last);
	my $len_last = @last;
	$len_last -= 1; # decrement by one to account for smaller word
	
	my @word = split(//, $word);
	my $len_word = @word;
	
	if ($len_word == $len_last++) {
	    return("good");
	} elsif ($len_word == $len_last++) {
	    return("good");
	} elsif ($len_word == $len_last) {
	    return("good");
	} else {
	    return("That word is not the right length");
	}
    }

    sub _right_start {
	my ($self, $last, $word) = @_;
    
	if ( substr($last,-1,1) eq substr($word,0,1) ) { 
	    return("good");
	} else {
	    return("That word starts with the wrong letter");
	}

    }

    sub _not_used { 
	my ($self, $word) = @_;
	my $used = $self->_get_all_used();
	my @temp_used = @$used;

	foreach my $test (@$used) {
	    if ($test eq $word) {   # if the guess matches a word in
		# the used word list, then try
		# again
		return("That word has been used before");
	    }
	}
	return("good");
    }


    sub _get_all_used {
	my ($self) = @_;
	
	my @total_words;
	my $players = $self->get_num_players();
	foreach my $player (0..$players) {
	    my $words = $self->_get_word_list("$player");
	    @total_words = (@total_words, @$words) if ($words);
	}
	@total_words = sort(@total_words);
	return \@total_words;
    }


    sub _get_word_list {
	my ($self, $player) = @_;

	my $players = $self->get_players();
	my $player_ref = $$players[$player];
	my $ref = $$player_ref{_used_words};
	return $ref;
    }

    sub _add_used_word {
	my ($self, $word) = @_;
	my $player = ($self->get_turn) % $self->get_num_players;
	my $words_ref = $self->_get_word_list($player);
	push(@$words_ref,$word);
    }

}
1;
__END__


=pod

=head1 AUTHOR

Pat Eyler <pate@gnu.org>

=head1 SEE ALSO

perl(1).

=cut









