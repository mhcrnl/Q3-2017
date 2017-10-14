#!/usr/bin/perl -w

use strict;
use lib ".";
use WordDig;
use Data::Dumper;

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
	    dict_obj => $dict,
	 num_players => 2,
	 players     => \@players,
	 );

my $game = Games::WordDig->new(%game);


$game->Player_Turn("task");
my $all_ref = $game->_get_all_used();
print "@$all_ref\n";

$game->Computer_Turn();
$all_ref = $game->_get_all_used();
print "@$all_ref\n";

$game->Player_Turn("lima");
$all_ref = $game->_get_all_used();
print "@$all_ref\n";

$game->Computer_Turn();
$all_ref = $game->_get_all_used();
print "@$all_ref\n";

$game->Player_Turn("ki");
$all_ref = $game->_get_all_used();
print "@$all_ref\n";

my $error = $game->Computer_Turn();
print "$error\n";
$all_ref = $game->_get_all_used();
print "@$all_ref\n";
