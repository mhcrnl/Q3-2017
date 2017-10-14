#!/usr/bin/perl
#
# CHESS OPENINGS: Simple tool to practise chess openings
#
# IMPORTANT : THIS FILE MUST BE EDITED WITH A UTF-8 EDITOR.
#
# Documentation can be read with perldoc (perldoc chess-openings.pl) or directly in this script.
# 
# A little review with screenshots is available here : http://kwartik.wordpress.com/chess-openings
#
# Version: 1.0
# Author: kwartik@gmail.com
# Date of creation   : 2010-03-28
# Last revision date : 2010-03-28
# 
# History of revisions
# - 2010-03-28, v1.0 - initial version
#
# LICENCE:     Copyright 2010 kwartik@gmail.com
# 
#    Licensed under the Apache License, Version 2.0 (the "License");
#    you may not use this file except in compliance with the License.
#    You may obtain a copy of the License at
# 
#      http://www.apache.org/licenses/LICENSE-2.0
# 
#    Unless required by applicable law or agreed to in writing, software
#    distributed under the License is distributed on an "AS IS" BASIS,
#    WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
#    See the License for the specific language governing permissions and
#    limitations under the License.
#
################################################################################################

=pod

=encoding utf8

=head1 NAME

CHESS OPENINGS: Simple tool to practise chess openings.

=head1 SYNOPSIS

 chess-openings.pl [ -h|--help ] [ -c|--conf configuration_file_containing_list_of_openings ]


=head1 DESCRIPTION

B<CHESS OPENINGS> is a simple perl script to practise chess openings. It is provided with a default configuration file containing a list of 437 well known openings. CHESS OPENINGS chooses randomly one opening in the configuration file and displays it as a nice UTF-8 matrix (UTF-8 do support chess characters). CHESS OPENINGS may be simply used through the command line but may be also be called by other tools like screen savers. A little review with screenshots is available here : http://kwartik.wordpress.com/chess-openings.

=head1 PARAMETERS

All the parameters can be preconfigured in the configurable section at the beginning of the script. The parameters that are passed through the command line override the parameters set in the configurable section.

=over 1

-B<h|--help> print help

-B<c|--conf> configuration_file_containing_the_list_of_openings

=back

=head1 LIMITATIONS

This script is intended to be used in a UTF-8 environment supporting the chess characters. It has been successfully tested in a Linux terminal. Unfortunately, under Windows, the "terminal" (cmd.exe) is not able to print UTF-8 characters, so Windows users might need to use a two steps approach : 1. redirection of the output in a file: perl chess-openings > opening.out 2. edition of the output file with a UTF-8 compliant editor providing a nice font for chess characters.

=head1 CONFIGURATION FILE SYNTAX

=over 1

Each opening must be saved on one single line with the following convention : list of moves|name of the opening

Eg. :
1.d4 d5 2.c4 c6 3.Nf3 Nf6 4.Nc3 dxc4 5.a4 Bf5 6.Ne5 Nbd7 7.Nxc4 Qc7 8.g3 e5|Carlsbad Variation of the Slav Defense

Please note that only the chess international notation is supported (without the annotations characters ? and !). The notation 1. e2e4 e4e6 is not supported.

=back

=head1 AUTHOR

kwartik@gmail.com

=head1 LICENCE

    Copyright 2010 kwartik@gmail.com
 
    Licensed under the Apache License, Version 2.0 (the "License");
    you may not use this file except in compliance with the License.
    You may obtain a copy of the License at
 
      http://www.apache.org/licenses/LICENSE-2.0
 
    Unless required by applicable law or agreed to in writing, software
    distributed under the License is distributed on an "AS IS" BASIS,
    WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
    See the License for the specific language governing permissions and
    limitations under the License.

=cut

##############################################################################
use Getopt::Long;
use strict;

### BEGIN OF CONFIGURABLE SECTION ############################################


# The following options can be overriden with the command line parameters

# $conf: /path/to/configuration_file
# Eg: $conf = "~/chess-signature/chess-openings.conf";
my $conf = "";



### END OF CONFIGURABLE SECTION ############################################

my $debug = 0; #0: normal mode; 1: debug mode

my $help=0;

my @opening_list = ();

GetOptions (
	"c|conf=s" => \$conf,
	"h|help" => \$help
);


sub help() {
	print "\nCHESS-SIGNATURE: Simple tool to practise chess openings.\n\nSyntax: chess.signature [ -h|--help ] [ -c|--conf configuration_file_containing_the_list_of_openings ]\n";
	return 0;
}

if ( $help ne 0 || $conf eq "" ) {
	help();
	exit 1;
}


sub parse_configuration_file()
{
	open(CONF, "<$conf") or die "ERROR: unable to open \"$conf\"", $!;

	while ( <CONF> ) {

		if ( $_ !~ /^#/) {
		
			if ( $_ =~ /\|/) {
				chomp ($_);
				print ">> :$_:\n" if ( $debug );
				push( @opening_list, $_ );
			}
		}
	}
	
	close (CONF);
}

if ( ! -f $conf ) {
 	print "ERROR: configuration file $conf does not exist\n";
 	exit 2;
}

# ♔♕♖♗♘♙♚♛♜♝♞♟
my @chess_matrix = (
	[ '♜', '♞', '♝', '♛', '♚', '♝', '♞', '♜' ],
	[ '♟', '♟', '♟', '♟', '♟', '♟', '♟', '♟' ],
	[ ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ' ],
	[ ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ' ],
	[ ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ' ],
	[ ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ' ],
	[ '♙', '♙', '♙', '♙', '♙', '♙', '♙', '♙' ],
	[ '♖', '♘', '♗', '♕', '♔', '♗', '♘', '♖' ]
);

sub print_chessboard()
{
	for ( my $i=0; $i <= 7; $i ++ ) {
		print "\t";
		for ( my $j=0; $j <= 7; $j ++ ) {
			print $chess_matrix[$i][$j], " ";
		}
		print "\n";
	}


}


# row:   a <=> 0, b <=> 1 ... h <=> 7
# lines: 1 <=> 8, 2 <=> 7 ... 8 <=> 0 
my %row_c_to_mat = ( 'a', 0, 'b', 1, 'c', 2, 'd', 3, 'e', 4, 'f', 5, 'g', 6, 'h', 7);
my %line_c_to_mat = ( '1', 7, '2', 6, '3', 5, '4', 4, '5', 3, '6', 2, '7', 1, '8', 0);

my %mat_to_row_c = ( '0', 'a', '1', 'b', '2', 'c', '3', 'd', '4', 'e', '5', 'f', '6', 'g', '7', 'h');
my %mat_to_line_c = ( '0', '8', '1', '7', '2', '6', '3', '5', '4', '4', '5', '3', '6', '2', '7', '1');

sub get_matrix_pos( $ $ )
{
	my ($piece, $ref_list_res) =@_;
	
	for ( my $i=0; $i <= 7; $i ++ ) {
		for ( my $j=0; $j <= 7; $j ++ ) {
			if ( $chess_matrix[$i][$j] eq $piece ) {
				push( @{$ref_list_res}, $i, $j );
			}
		}
		
	}
}

# ♔♕♖♗♘♙♚♛♜♝♞♟
# get_all_next_pos($src_line, $src_row, $ref_list_ref) : identifies all the next possible destinations for a given piece on the matrix
# The next positions are pushed in the array passed in the third argument.
# IMPORTANT: This function does not check if the next positions are authorized by the chess rules
# (the position may be forbidden because of a check or because of the presence of a piece in between.)
sub get_all_next_pos( $ $ $ )
{
	my ( $src_line, $src_row, $ref_list_res) =@_;
	
	@{$ref_list_res} = ();

	my $piece = $chess_matrix[$src_line][$src_row];
	
	if ( $piece eq '♘' or $piece eq '♞' ) {
		printf( "\n>> get_all_next_pos for $piece at pos %d,%d", $src_line, $src_row)  if ( $debug );
		
		if ( $src_line - 2 >= 0 && $src_row + 1 <= 7 ) {
			push (  @{$ref_list_res}, $src_line - 2, $src_row + 1 );
			printf( "\n>>> add pos %d,%d", $src_line - 2, $src_row + 1)  if ( $debug );
		}
		if ( $src_line - 1 >= 0 && $src_row + 2 <= 7 ) {
			push (  @{$ref_list_res}, $src_line - 1, $src_row + 2 );
			printf( "\n>>> add pos %d,%d", $src_line - 1, $src_row + 2)  if ( $debug );
		}
		if ( $src_line + 1 <= 7 && $src_row + 2 <= 7 ) {
			push (  @{$ref_list_res}, $src_line + 1, $src_row + 2 );
			printf( "\n>>> add pos %d,%d", $src_line + 1, $src_row + 2)  if ( $debug );
		}
		if ( $src_line + 2 <= 7 && $src_row + 1 <= 7 ) {
			push (  @{$ref_list_res}, $src_line + 2, $src_row + 1 );
			printf( "\n>>> add pos %d,%d", $src_line + 2, $src_row + 1)  if ( $debug );
		}
		if ( $src_line + 2 <= 7 && $src_row - 1 >= 0 ) {
			push (  @{$ref_list_res}, $src_line + 2, $src_row - 1 );
			printf( "\n>>> add pos %d,%d", $src_line + 2, $src_row - 1)  if ( $debug );
		}
		if ( $src_line + 1 <= 7 && $src_row - 2 >= 0 ) {
			push (  @{$ref_list_res}, $src_line + 1, $src_row - 2 );
			printf( "\n>>> add pos %d,%d", $src_line + 1, $src_row - 2)  if ( $debug );
		}
		if ( $src_line - 1 >= 0 && $src_row - 2 >= 0 ) {
			push (  @{$ref_list_res}, $src_line - 1, $src_row - 2 );
			printf( "\n>>> add pos %d,%d", $src_line - 1, $src_row - 2)  if ( $debug );
		}
		if ( $src_line - 2 >= 0 && $src_row - 1 >= 0 ) {
			push (  @{$ref_list_res}, $src_line - 2, $src_row - 1 );
			printf( "\n>>> add pos %d,%d", $src_line - 2, $src_row - 1)  if ( $debug );
		}
	}
	elsif ( $piece eq '♗' or $piece eq '♝' ) {
		printf( "\n>> get_all_next_pos for $piece at pos %d,%d", $src_line, $src_row)  if ( $debug );
		
		for ( my $i = 1; $i <= 7; $i ++ ) {
			if ( $src_line - $i >= 0 && $src_row - $i >= 0 ) {
				push (  @{$ref_list_res}, $src_line - $i, $src_row - $i );
				printf( "\n>>> add pos %d,%d", $src_line - $i, $src_row - $i )  if ( $debug );
			}
			if ( $src_line + $i <= 7 && $src_row + $i <= 7 ) {
				push (  @{$ref_list_res}, $src_line + $i, $src_row + $i );
				printf( "\n>>> add pos %d,%d", $src_line + $i, $src_row + $i )  if ( $debug );
			}
			if ( $src_line - $i >= 0 && $src_row + $i <= 7 ) {
				push (  @{$ref_list_res}, $src_line - $i, $src_row + $i );
				printf( "\n>>> add pos %d,%d", $src_line - $i, $src_row + $i )  if ( $debug );
			}
			if ( $src_line + $i <= 7 && $src_row - $i >= 0 ) {
				push (  @{$ref_list_res}, $src_line + $i, $src_row - $i );
				printf( "\n>>> add pos %d,%d", $src_line + $i, $src_row - $i )  if ( $debug );
			}
		}
	}
	elsif ( $piece eq '♖' or $piece eq '♜' ) {
		printf( "\n>> get_all_next_pos for $piece at pos %d,%d", $src_line, $src_row)  if ( $debug );
		
		for ( my $i = 1; $i <= 7; $i ++ ) {
			if ( $src_line - $i >= 0 ) {
				push (  @{$ref_list_res}, $src_line - $i, $src_row );
				printf( "\n>>> add pos %d,%d", $src_line - $i, $src_row )  if ( $debug );
			}
			if ( $src_line + $i <= 7 ) {
				push (  @{$ref_list_res}, $src_line + $i, $src_row );
				printf( "\n>>> add pos %d,%d", $src_line + $i, $src_row )  if ( $debug );
			}
			if ( $src_row - $i >= 0 ) {
				push (  @{$ref_list_res}, $src_line, $src_row - $i );
				printf( "\n>>> add pos %d,%d", $src_line, $src_row - $i )  if ( $debug );
			}
			if ( $src_row + $i <= 7 ) {
				push (  @{$ref_list_res}, $src_line, $src_row + $i );
				printf( "\n>>> add pos %d,%d", $src_line, $src_row + $i )  if ( $debug );
			}
		}
	}
	elsif ( $piece eq '♕' or $piece eq '♛' ) {
		printf( "\n>> get_all_next_pos for $piece at pos %d,%d", $src_line, $src_row)  if ( $debug );
		
		for ( my $i = 1; $i <= 7; $i ++ ) {
			if ( $src_line - $i >= 0 ) {
				push (  @{$ref_list_res}, $src_line - $i, $src_row );
				printf( "\n>>> add pos %d,%d", $src_line - $i, $src_row )  if ( $debug );
			}
			if ( $src_line + $i <= 7 ) {
				push (  @{$ref_list_res}, $src_line + $i, $src_row );
				printf( "\n>>> add pos %d,%d", $src_line + $i, $src_row )  if ( $debug );
			}
			if ( $src_row - $i >= 0 ) {
				push (  @{$ref_list_res}, $src_line, $src_row - $i );
				printf( "\n>>> add pos %d,%d", $src_line, $src_row - $i )  if ( $debug );
			}
			if ( $src_row + $i <= 7 ) {
				push (  @{$ref_list_res}, $src_line, $src_row + $i );
				printf( "\n>>> add pos %d,%d", $src_line, $src_row + $i )  if ( $debug );
			}
			if ( $src_line - $i >= 0 && $src_row - $i >= 0 ) {
				push (  @{$ref_list_res}, $src_line - $i, $src_row - $i );
				printf( "\n>>> add pos %d,%d", $src_line - $i, $src_row - $i )  if ( $debug );
			}
			if ( $src_line + $i <= 7 && $src_row + $i <= 7 ) {
				push (  @{$ref_list_res}, $src_line + $i, $src_row + $i );
				printf( "\n>>> add pos %d,%d", $src_line + $i, $src_row + $i )  if ( $debug );
			}
			if ( $src_line - $i >= 0 && $src_row + $i <= 7 ) {
				push (  @{$ref_list_res}, $src_line - $i, $src_row + $i );
				printf( "\n>>> add pos %d,%d", $src_line - $i, $src_row + $i )  if ( $debug );
			}
			if ( $src_line + $i <= 7 && $src_row - $i >= 0 ) {
				push (  @{$ref_list_res}, $src_line + $i, $src_row - $i );
				printf( "\n>>> add pos %d,%d", $src_line + $i, $src_row - $i )  if ( $debug );
			}
			
			
		}
	}
	elsif ( $piece eq '♔' or $piece eq '♚' ) {
		printf( "\n>> get_all_next_pos for $piece at pos %d,%d", $src_line, $src_row)  if ( $debug );

			if ( $src_line - 1 >= 0 ) {
				push (  @{$ref_list_res}, $src_line - 1, $src_row );
				printf( "\n>>> add pos %d,%d", $src_line - 1, $src_row )  if ( $debug );
			}
			if ( $src_line + 1 <= 7 ) {
				push (  @{$ref_list_res}, $src_line + 1, $src_row );
				printf( "\n>>> add pos %d,%d", $src_line + 1, $src_row )  if ( $debug );
			}
			if ( $src_row - 1 >= 0 ) {
				push (  @{$ref_list_res}, $src_line, $src_row - 1 );
				printf( "\n>>> add pos %d,%d", $src_line, $src_row - 1 )  if ( $debug );
			}
			if ( $src_row + 1 <= 7 ) {
				push (  @{$ref_list_res}, $src_line, $src_row + 1 );
				printf( "\n>>> add pos %d,%d", $src_line, $src_row + 1 )  if ( $debug );
			}
			if ( $src_line - 1 >= 0 && $src_row - 1 >= 0 ) {
				push (  @{$ref_list_res}, $src_line - 1, $src_row - 1 );
				printf( "\n>>> add pos %d,%d", $src_line - 1, $src_row - 1 )  if ( $debug );
			}
			if ( $src_line + 1 <= 7 && $src_row + 1 <= 7 ) {
				push (  @{$ref_list_res}, $src_line + 1, $src_row + 1 );
				printf( "\n>>> add pos %d,%d", $src_line + 1, $src_row + 1 )  if ( $debug );
			}
			if ( $src_line - 1 >= 0 && $src_row + 1 <= 7 ) {
				push (  @{$ref_list_res}, $src_line - 1, $src_row + 1 );
				printf( "\n>>> add pos %d,%d", $src_line - 1, $src_row + 1 )  if ( $debug );
			}
			if ( $src_line + 1 <= 7 && $src_row - 1 >= 0 ) {
				push (  @{$ref_list_res}, $src_line + 1, $src_row - 1 );
				printf( "\n>>> add pos %d,%d", $src_line + 1, $src_row - 1 )  if ( $debug );
			}

	}
	else {
		die "error get_all_next_pos $src_line,$src_row";
	}
	
}

# next_move( $color , $next )
# $color : 'white' or 'black'
# $next :  e4 ok|Nf3 ok|exd4 ok|Bb4+ ok|Bxd4 ok|0-0 ok|0-0-0 ok|
# next_move interprets the chess notation of a given movement and update the chess matrix accordingly.
# LIMITATIONS:
# next-move calls for each candidate piece to the move get_all_next_pos to see if the destination
# specified in the move matches one of the possible destinations returned by get_all_next_pos.
# The first candidate that passes this test is considered as the piece to move and
# the chess matrix is updated accordingly. This may lead to a wrong interpretation but the
# probability is very low in a chess opening, indeed I see only two theorical cases:
# - a tower movement, like Ta6 accessible by only one tower according to chess rules but by two for chess-signature
# who would not be clever enough to see that one of the two tower can't perform the move
# because of a piece in between. Hopefully, it happens that no tower movements (besides 0-0 and 0-0-0) are present in the
# most famous openings.
# - the case at the end of a game where they could be several queens or bishops of the same color. Not relevant
# at all for chess-signature who has been designed to ilustrate openings.
sub next_move
{
	my ($color, $next) =@_;
	
	
	# 'e4' syntax  (only for pawns)
	if ( $next =~ /^[abcdefgh][12345678]$/ ) {
	
		my $piece = '';
		if ( $color eq 'white' ) {
			$piece='♙';
		}
		elsif ( $color eq 'black' ) {
			$piece='♟';
		}
		else {
			die "\nERROR: first parameter of next_move should be white or black and not $color\n";
		}
		
		my ( $row_c, $line_c ) = ( $next =~ /^([abcdefgh])([12345678])$/ );
		my $row = $row_c_to_mat{$row_c};
		my $line = $line_c_to_mat{$line_c};
		my $src_line = '';
		my $src_row = '';
		print "\n\n Syntax e4 :$line_c:$row_c: <=> :$line:$row:\n" if ( $debug );

		if ( $color='white' && $line == 4 && $line + 2 <= 7 &&  $chess_matrix[$line + 2][$row] eq $piece && $chess_matrix[$line + 1][$row] eq ' ' ) {
			$src_row  = $row;
			$src_line = $line + 2;
			my $src_row_c = $mat_to_row_c{$src_row};
			my $src_line_c = $mat_to_line_c{$src_line};
			print "source piece :$src_row:$src_line:  <=> :$src_row_c:$src_line_c:\n" if ( $debug );
			$chess_matrix[$line][$row] = $chess_matrix[$src_line][$src_row];
			$chess_matrix[$src_line][$src_row] = ' ';
			return 1;
		}
		elsif ( $color='white' && $line + 1 <= 7 &&  $chess_matrix[$line + 1][$row] eq $piece ) {
			$src_row  = $row;
			$src_line = $line + 1;
			my $src_row_c = $mat_to_row_c{$src_row};
			my $src_line_c = $mat_to_line_c{$src_line};
			print "source piece :$src_row:$src_line:  <=> :$src_row_c:$src_line_c:\n" if ( $debug );
			$chess_matrix[$line][$row] = $chess_matrix[$src_line][$src_row];
			$chess_matrix[$src_line][$src_row] = ' ';
			return 1;
		}
		elsif ( $color='black' && $line == 3 && $line - 2 >= 0 &&  $chess_matrix[$line - 2][$row] eq $piece && $chess_matrix[$line - 1][$row] eq ' ' ) {
			$src_row  = $row;
			$src_line = $line - 2;
			my $src_row_c = $mat_to_row_c{$src_row};
			my $src_line_c = $mat_to_line_c{$src_line};
			print "source piece :$src_row:$src_line:  <=> :$src_row_c:$src_line_c:\n" if ( $debug );
			$chess_matrix[$line][$row] = $chess_matrix[$src_line][$src_row];
			$chess_matrix[$src_line][$src_row] = ' ';
			return 1;
		}
		elsif ( $color='black' && $line - 1 >= 0 &&  $chess_matrix[$line - 1][$row] eq $piece ) {
			$src_row  = $row;
			$src_line = $line - 1;
			my $src_row_c = $mat_to_row_c{$src_row};
			my $src_line_c = $mat_to_line_c{$src_line};
			print "source piece :$src_row:$src_line:  <=> :$src_row_c:$src_line_c:\n" if ( $debug );
			$chess_matrix[$line][$row] = $chess_matrix[$src_line][$src_row];
			$chess_matrix[$src_line][$src_row] = ' ';
			return 1;
		}
		else {
			return 0;
		}
	}
	
	# exf3[+] Syntax  (only for pawns)
	# ♙♟
	elsif ( $next =~ /^[abcdefgh]x[abcdefgh][12345678]\+?$/ ) {
		my ( $row_src_c, $row_c, $line_c ) = ( $next =~ /^([abcdefgh])x([abcdefgh])([12345678])\+?$/ );
		my $piece = '';

		my $row_src = $row_c_to_mat{$row_src_c};
		my $row = $row_c_to_mat{$row_c};
		my $line = $line_c_to_mat{$line_c};
		my $src_line = '';
		my $src_row = '';
		print "\n\n Syntax exf3[+]  :$next: :$row_src_c:$line_c:$row_c: <=> :$row_src:$line:$row:\n" if ( $debug );

		if ( $color eq 'white' ) {
			$chess_matrix[$line][$row] = $chess_matrix[$line + 1][$row_src];
			$chess_matrix[$line + 1][$row_src] = ' ';
		}
		elsif ( $color eq 'black' ) {
			$chess_matrix[$line][$row] = $chess_matrix[$line - 1][$row_src];
			$chess_matrix[$line - 1][$row_src] = ' ';
		}
		else {
			die "\nERROR: first parameter of next_move should be white or black and not $color\n";
		}
		return 0;
	}	
	
	# NBTQK[x]f3[+] Syntax  E.g. : 'Nf3' or 'Bb4+' or 'Bxd4'
	# ♔♕♖♗♘♙♚♛♜♝♞♟
	elsif ( $next =~ /^[NBTQK]x?[abcdefgh][12345678]\+?$/ ) {
		my ( $piece_c, $row_c, $line_c ) = ( $next =~ /^([NBQKT])x?([abcdefgh])([12345678])\+?$/ );
		my $piece = '';
		if ( $color eq 'white' ) {
			$piece='♘' if ( $piece_c eq 'N' );
			$piece='♗' if ( $piece_c eq 'B' );
			$piece='♖' if ( $piece_c eq 'T' );
			$piece='♕' if ( $piece_c eq 'Q' );
			$piece='♔' if ( $piece_c eq 'K' );
		}
		elsif ( $color eq 'black' ) {
			$piece='♞' if ( $piece_c eq 'N' );
			$piece='♝' if ( $piece_c eq 'B' );
			$piece='♜' if ( $piece_c eq 'T' );
			$piece='♛' if ( $piece_c eq 'Q' );
			$piece='♚' if ( $piece_c eq 'K' );
		}
		else {
			die "\nERROR: first parameter of next_move should be white or black and not $color\n";
		}
		
		my $row = $row_c_to_mat{$row_c};
		my $line = $line_c_to_mat{$line_c};
		my $src_line = '';
		my $src_row = '';
		print "\n\n Syntax NBTQK[x]f3[+] :$next: :$line_c:$row_c: <=> :$line:$row:\n" if ( $debug );

		my @src_pos_list = ();
		my @all_next_pos_list = ();

		get_matrix_pos($piece, \@src_pos_list);

		for ( my $i = 0; $i < @src_pos_list; $i += 2 ) {
			my $src_line = $src_pos_list[$i];
			my $src_row = $src_pos_list[$i+1];
			print "\n>> pos $src_line,$src_row is candidate for $piece" if ( $debug );

			get_all_next_pos( $src_line, $src_row, \@all_next_pos_list );
			
			for ( my $j = 0; $j < @all_next_pos_list; $j += 2 ) {
				if ( $all_next_pos_list[$j] == $line && $all_next_pos_list[$j+1] == $row ) {
					printf( "\n>>> good : %d,%d ==  %d,%d", $all_next_pos_list[$j], $all_next_pos_list[$j+1], $line, $row)  if ( $debug );
					$chess_matrix[$line][$row] = $chess_matrix[$src_line][$src_row];
					$chess_matrix[$src_line][$src_row] = ' ';
					return 1;
				}
				else {
					printf( "\n>>> bad  : %d,%d !=  %d,%d", $all_next_pos_list[$j], $all_next_pos_list[$j+1], $line, $row)  if ( $debug );
				}
			}
		}
		return 0;
	}
	
	# 0-0 syntax
	elsif ( $next eq '0-0' ) {
	
		if ( $color eq 'white' ) {
			$chess_matrix[7][6] = $chess_matrix[7][4];
			$chess_matrix[7][4] = ' ';
			$chess_matrix[7][5] = $chess_matrix[7][7];
			$chess_matrix[7][7] = ' ';
		}
		elsif ( $color eq 'black' ) {
			$chess_matrix[0][6] = $chess_matrix[0][4];
			$chess_matrix[0][4] = ' ';
			$chess_matrix[0][5] = $chess_matrix[0][7];
			$chess_matrix[0][7] = ' ';
		}
		else {
			die "\nERROR: first parameter of next_move should be white or black and not $color\n";
		}
	}
	
	# 0-0-0 syntax
	elsif ( $next eq '0-0-0' ) {
	
		if ( $color eq 'white' ) {
			$chess_matrix[7][2] = $chess_matrix[7][4];
			$chess_matrix[7][4] = ' ';
			$chess_matrix[7][3] = $chess_matrix[7][0];
			$chess_matrix[7][0] = ' ';
		}
		elsif ( $color eq 'black' ) {
			$chess_matrix[0][2] = $chess_matrix[0][4];
			$chess_matrix[0][4] = ' ';
			$chess_matrix[0][3] = $chess_matrix[0][0];
			$chess_matrix[0][0] = ' ';
		}
		else {
			die "\nERROR: first parameter of next_move should be white or black and not $color\n";
		}
	}

}

# Notes: $chess_matrix[line][row]     $chess_matrix[6][4] <=> e2



# parse_opening: parse a opening like '1.d4 d5 2.e3 Nf6 3.Bd3 c5 4.c3 Nc6 5.f4'
# and calls next_move( 'white' , 'Nxe5' ) as many times as necessary.
sub parse_opening( $ )
{
	my ($opening) =@_;
	print "\n>>> opening: $opening" if ($debug);
	my @array_moves = split(/ /, $opening);
	foreach( @array_moves ) {
		my $move = $_;
		printf("\n>>>> |%s|", $move) if ($debug);
		# White move
		if ( $move =~ /^\d\./ ) {
			my ($move_final) = ( $move =~ /^\d\.(.*)$/ );
 			print("\n>>>> next_move( 'white', '$move_final' )") if ($debug);
 			next_move( 'white', $move_final );
		}
		# Black movements
		else {
			print("\n>>>> next_move( 'black', '$move' )") if ($debug); 
			next_move( 'black', $move );
		}
	}
	print("\n\n") if ($debug);
}

### MAIN PROGRAM ###


# Configuration file parsing
parse_configuration_file();



print "\n";

# We choose a opening

my $random = $opening_list[ rand(@opening_list-1) ];
my ( $opening, $description ) = ( $random =~ /^(.*)\|(.*)$/ );

parse_opening( $opening );

print_chessboard();

print "\n$description\n$opening\n";

print "\n";
