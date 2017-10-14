#!/bin/perl

# Perl Connect Four - console game
# Copyright (C) 2006 John J Mazzitelli
# All Rights Reserved
# jmazzitelli@users.sourceforge.net
# 
# This file is part of Perl Connect Four.
#
# Perl Connect Four is free software; you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation; either version 2 of the License, or
# (at your option) any later version.
# 
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
# 
# You should have received a copy of the GNU General Public License
# along with this program; if not, write to the Free Software
# Foundation, Inc., 51 Franklin St, Fifth Floor, Boston, MA  02110-1301  USA

#
# Define some globals
#

local($LOCAL_HOSTNAME);
chop($LOCAL_HOSTNAME = `hostname`);

local($DEFAULT_CONNECT_WIN)     = 4;
local($DEFAULT_HEIGHT)          = 6;
local($DEFAULT_WIDTH)           = 6;
local($DEFAULT_REMOTE_HOSTNAME) = $LOCAL_HOSTNAME;
local($DEFAULT_TCP_PORT)        = 60001;

local($CONNECT_WIN)             = $DEFAULT_CONNECT_WIN;
local($HEIGHT)                  = $DEFAULT_HEIGHT;
local($WIDTH)                   = $DEFAULT_WIDTH;
local($REMOTE_HOSTNAME)         = $DEFAULT_REMOTE_HOSTNAME;
local($TCP_PORT)                = $DEFAULT_TCP_PORT;
local($CONNECTED)               = ();
local($WHOSE_TURN)              = 0;
local($MY_NUMBER)               = ();
local($MY_NAME)                 = $ENV{"USER"};
local($OPP_NAME)                = ();
local($SINGLE_PLAYER)           = ();
local($BEEP)                    = "\007";
local(@BOARD)                   = ();
local($WINNER)                  = -1;
local($BLANK)                   = "_";
local($SHAPES);
local($SHAPES_LAST);
local(*SOCK);
local($SELECTION);
local($LOOP);

#
# Prepare signal handlers
#

$SIG{"INT"} = $SIG{"QUIT"} = $SIG{"ILL"}  = $SIG{"ABRT"} = $SIG{"FPE"} =
$SIG{"BUS"} = $SIG{"SEGV"} = $SIG{"TERM"} = $SIG{"XCPU"} = "SignalHandler";

#
# Initialize random number generator
#

srand($$^time);

#
# Get command line options
#

while (scalar(@ARGV))
{
   if ($ARGV[0] eq '-c')
   {
      $CONNECT_WIN = $ARGV[1];
      shift;
      shift;
   }
   elsif ($ARGV[0] eq '-h')
   {
      $HEIGHT = $ARGV[1];
      shift;
      shift;
   }
   elsif ($ARGV[0] eq '-w')
   {
      $WIDTH = $ARGV[1];
      shift;
      shift;
   }
   elsif ($ARGV[0] eq '-r')
   {
      $REMOTE_HOSTNAME = $ARGV[1];
      shift;
      shift;
   }
   elsif ($ARGV[0] eq '-p')
   {
      $TCP_PORT = $ARGV[1];
      shift;
      shift;
   }
   elsif ($ARGV[0] eq '-n')
   {
      $MY_NAME = $ARGV[1];
      shift;
      shift;
   }
   elsif ($ARGV[0] eq '-1')
   {
      $SINGLE_PLAYER = 1;
      $MY_NUMBER = 0;
      $OPP_NAME = "the computer";
      shift;
   }
   elsif ($ARGV[0] eq '-q')
   {
      $BEEP = "";
      shift;
   }
   elsif ($ARGV[0] eq '-help')
   {
      print <<"EndOfHelp";

Command Line Options:
-c count        connected pieces needed to win (default: $DEFAULT_CONNECT_WIN)
-w width        the width of the board (default: $DEFAULT_WIDTH)
-h height       the height of the board (default: $DEFAULT_HEIGHT)
-1              single player mode
-help           displays this help message
-q              turns on quiet mode so the game does not beep
-n name         tells the program what your name is (otherwise, it uses \$USER)
-r remote_host  host to look for a server (default: $DEFAULT_REMOTE_HOSTNAME)
-p port         TCP port number to use (default: $DEFAULT_TCP_PORT)

Objectives:
The objective is to drop your pieces in the board's columns such that
you line up 'count' pieces, either horizontally, vertically or
diagonally.  'count' is set via the -c option.

Instructions:
When it is your turn, you pick a column (0 thru (width-1)) to drop a piece
in that column.  Then your opponent does the same.  If you connect
'count' pieces either horizontally, vertically or diagonally before
your opponent does, you win.

You cannot drop pieces in columns that are full.
EndOfHelp

      exit 0;
   }
   else
   {
      die "Usage: $0 [-1] [-c count] [-w width] [-h height] [-q] [-n name] ",
          "[-r remote host] [-p port]\n";
   }
}

#
# Test the command line arguments' validity
#

die "Invalid -c value\n" if (($CONNECT_WIN !~ /^\d+$/) || ($CONNECT_WIN <= 1));
die "Invalid height\n" if (($HEIGHT !~ /^\d+$/) || ($HEIGHT <= 0));
die "Invalid width\n" if (($WIDTH !~ /^\d+$/) || ($WIDTH <= 0));
die "Invalid port\n" if (($TCP_PORT !~ /^\d+$/) || ($TCP_PORT <= 10));
die "Can't get local hostname\n" if (!(gethostbyname($LOCAL_HOSTNAME)));
die "Invalid host: $REMOTE_HOSTNAME\n" if (!(gethostbyname($REMOTE_HOSTNAME)));
die "The connect value must be less than height and width\n"
   if (($CONNECT_WIN >= $WIDTH) || ($CONNECT_WIN >= $HEIGHT));

#
# IF we are not in single-player mode
#    Connect to the opponent
#    IF our number if 0
#       We are the server, so initiate the handshake - send our name and
#          wait for the client to tell us his (we also send the option settings)
#    ELSE
#       We are the client - so the server will send his name first (along with
#          some option settings).  When we get the info, we send back our name.
#    END IF
#    Show a title screen
# END IF
#

if (!$SINGLE_PLAYER)
{
   print "Hello $MY_NAME! I will see if anyone is available.\n";

   &FindAnother();

   if ($MY_NUMBER == 0)
   {
      print SOCK "$MY_NAME\n";
      print SOCK "$CONNECT_WIN\n";
      print SOCK "$WIDTH\n";
      print SOCK "$HEIGHT\n";
      chop($OPP_NAME = <SOCK>);
   }
   else
   {
      chop($OPP_NAME = <SOCK>);
      chop($CONNECT_WIN = <SOCK>);
      chop($WIDTH = <SOCK>);
      chop($HEIGHT = <SOCK>);
      print SOCK "$MY_NAME\n";
   }
}

#
# Initialize board
#

foreach $LOOP (0..($HEIGHT))
{
   chop($BOARD[$LOOP] = "${BLANK}|"x$WIDTH);
}

$SHAPES[0] = "x";
$SHAPES[1] = "o";

$SHAPES_LAST[0] = "X";
$SHAPES_LAST[1] = "O";

print <<"EndOfTitle";
$BEEP$BEEP$BEEP

===============================================================================
                                  Connect Four
===============================================================================
  Players: $MY_NAME ($SHAPES[$MY_NUMBER]) vs. $OPP_NAME ($SHAPES[1-$MY_NUMBER])
Objective: You must connect $CONNECT_WIN pieces using a $WIDTH x $HEIGHT board.
-------------------------------------------------------------------------------
EndOfTitle

#
# WHILE we still do not have a winner
#    Show the board
#    IF it is our turn
#       Show the prompt and wait for some input
#    ELSE
#       IF we are not playing the computer
#          Get the opponent's next move
#       ELSE
#          Get a random move for the computer
#       END IF
#    END IF
#
#    IF the selection was valid
#       Put a piece in the selected column
#       IF the column was not full
#          IF it was our turn and we aren't playing the computer
#             Tell our opponent what our move was
#          END IF
#          Change turns
#       ELSE IF it was our turn
#          Remind the user that the column is full
#       ELSE
#          The opponent played a full column (should never occur)
#          Exit by breaking the loop
#       END IF
#    ELSE IF the selection indicated that we are to abort play
#       Show a message of what happened and immediately break the while loop
#    ELSE
#       Indicate an invalid option was selected
#    END IF
# END WHILE
#

while (($WINNER=&IsWinner(1-$WHOSE_TURN)) == -1)
{
   &OutputBoard(0);

   if ($WHOSE_TURN == $MY_NUMBER)
   {
      &OutputPrompt();
      chop($SELECTION = <STDIN>);
   }
   else
   {
      if (!$SINGLE_PLAYER)
      {
         print "Waiting for $OPP_NAME\n";
         chop($SELECTION = <SOCK>);
      }
      else
      {
         $SELECTION = &RandomMove();
      }
   }

   if (($SELECTION =~ /^\d+$/) && ($SELECTION < $WIDTH))
   {
      if (&IncrementBoardColumn($SELECTION) >= 0)
      {
         if ((!$SINGLE_PLAYER) && ($WHOSE_TURN == $MY_NUMBER))
         {
            print SOCK "$SELECTION\n";
         }
         $WHOSE_TURN = 1 - $WHOSE_TURN;
      }
      elsif ($WHOSE_TURN == $MY_NUMBER)
      {
         print "That column is full!  Try again.";
      }
      else
      {
         print "Opponent played a full column! [${SELECTION}]...exiting\n";
         last;
      }
   }
   elsif ($SELECTION =~ /^[qQsS]/)
   {
      if ($WHOSE_TURN == $MY_NUMBER)
      {
         if (!$SINGLE_PLAYER)
         {
            print SOCK "q\n";
            sleep 1 if ($MY_NUMBER==0); # so client dies 1st & socket cleans up
         }
      }
      else
      {
         print "${OPP_NAME} has exited the game.\n" if ($SELECTION =~ /[qQ]/);
         print "${OPP_NAME}'s game was aborted!\n"  if ($SELECTION =~ /[sS]/);
      }
      last;
   }
   else
   {
      if ($WHOSE_TURN == $MY_NUMBER)
      {
         print "Invalid option!";
      }
      else
      {
         print "Invalid socket data [${SELECTION}]...exiting\n";
         last;
      }
   }

   print "\n";
}

#
# Output board and say who won
#

&OutputBoard(1);

if ($WINNER == $MY_NUMBER)
{
   print "\n", "~"x78, "\n$MY_NAME won! Congratulations!\n";
}
elsif ($WINNER == (1-$MY_NUMBER))
{
   print "\n", "~"x78, "\n$OPP_NAME won! Sorry.\n";
}
else
{
   print "\n", "~"x78, "\nNeither player won. Sorry.\n";
}

print "$BEEP$BEEP$BEEP\n";

#
# Close the socket and exit
#

&CloseSocket();
exit 0;

# =============================================================================
# OutputPrompt
#
# This simply outputs the entry prompt
#

sub OutputPrompt
{
   print "\nEnter a column ==> ";
}

# =============================================================================
# IsWinner
#
# Determine who (if anyone) won.  Returns the player number who won.
# If no one won but the game can continue, then a -1 is returned.
# If no one won but the game cannot continue, then a -2 is returned.
#

sub IsWinner
{
   local($player) = $_[0];
   local($ret_val) = ($BOARD[$HEIGHT-1] =~ /$BLANK/) ? -1 : -2;
   local($row_num);
   local($col_num);
   local($connected) = 0;

   for ($row_num = 0; $row_num < $HEIGHT; $row_num++)
   {
      next if ($BOARD[$row_num] !~ /[$SHAPES[$player]$SHAPES_LAST[$player]]/);

      for ($col_num = 0; $col_num < $WIDTH; $col_num++)
      {
         $connected = &MatchCheck($player, $row_num, $col_num, +1, -1, 0);
         last if ($connected >= $CONNECT_WIN);

         $connected = &MatchCheck($player, $row_num, $col_num, +1, +0, 0);
         last if ($connected >= $CONNECT_WIN);

         $connected = &MatchCheck($player, $row_num, $col_num, +1, +1, 0);
         last if ($connected >= $CONNECT_WIN);

         $connected = &MatchCheck($player, $row_num, $col_num, +0, +1, 0);
         last if ($connected >= $CONNECT_WIN);
      }

      last if ($connected >= $CONNECT_WIN);
   }

   if ($connected >= $CONNECT_WIN)
   {
      $ret_val = $player;
      print "Winner at column=$col_num,row=$row_num\n";
   }

   return $ret_val;
}

# =============================================================================
# MatchCheck
#
# Looks for a piece that matches the given player in a given block.
# This is a recursive function - if a piece is found, it calls itself
# to continue looking in the same direction.
#
# $player    = player whose piece we are looking for
# $row_num   = row we are to look at
# $col_num   = column we are to look at
# $row_inc   = row direction we should look at next
# $col_inc   = column direction we should look at next
# $connected = number of times we previously found a connected piece
#

sub MatchCheck
{
   local($player, $row_num, $col_num, $row_inc, $col_inc, $connected) = @_;

   if (($row_num < $HEIGHT)  &&
       ($row_num >= 0)       &&
       ($col_num < $WIDTH)   &&
       ($col_num >= 0)       &&
       ((((&BoardRowArray($row_num))[$col_num]) eq $SHAPES[$player]) ||
        (((&BoardRowArray($row_num))[$col_num]) eq $SHAPES_LAST[$player])))
   {
      $connected = &MatchCheck($player,
                               $row_num + $row_inc,
                               $col_num + $col_inc,
                               $row_inc,
                               $col_inc,
                               $connected + 1);
   }

   return $connected;
}

# =============================================================================
# OutputBoard
#
# Simply outputs what the board looks like on stdout.
# $show_row_num - shows row numbers
#

sub OutputBoard
{
   local($show_row_num) = @_;
   local($i);

   print "\n";

   foreach $i (reverse(0..($HEIGHT-1)))
   {
      print "$BOARD[$i]";
      print " $i" if ($show_row_num);
      print "\n";
   }

   print "\n";

   if ($WIDTH <= 10)
   {
      foreach $i (0..($WIDTH-1))
      {
         print "$i ";
      }
   }
   else
   {
      foreach $i (0..($WIDTH-1))
      {
         print ((($i % 2)==0) ? "$i" : ((int($i) > 10) ? "  " : "   "));
      }
      print "\n ";

      foreach $i (1..($WIDTH-1))
      {
         print ((($i % 2)==0) ? ((int($i) > 10) ? "  " : "   ") : "$i");
      }
   }

   print "\n";
}

# =============================================================================
# IncrementBoardColumn
#
# Given a column number, will put the player's piece in that column.
# This updates $BOARD and uses $WHOSE_TURN.
# If the column is full, a -1 is returned, otherwise, the
# row number where the piece got placed is returned.
#
# $column = board column to increment
#

sub IncrementBoardColumn
{
   local($ret_val) = -1;
   local($column)  = $_[0];
   local($row_num);
   local(@row);

   foreach $row_num (0..($HEIGHT-1))
   {
      $BOARD[$row_num] =~ s/$SHAPES_LAST[$WHOSE_TURN]/$SHAPES[$WHOSE_TURN]/g;
   }

   foreach $row_num (0..($HEIGHT-1))
   {
      @row = &BoardRowArray($row_num);
      if ($row[$column] eq "$BLANK")
      {
         $row[$column] = $SHAPES_LAST[$WHOSE_TURN];
         $BOARD[$row_num] = join("|", @row);
         $ret_val = $row_num;
         last;
      }
   }
   return $ret_val;
}

# =============================================================================
# BoardRowArray
#
# Returns a row of the board in array form.
#
# $_[0] = the row
#

sub BoardRowArray
{
   return (split(/\|/, $BOARD[$_[0]]));
}

# =============================================================================
# RandomMove
#
# Returns a random column number (0..$WIDTH-1)
# It will not select a column that is full.
#

sub RandomMove
{
   local($rand_num);
   local(@row) = &BoardRowArray($HEIGHT-1);

   do
   {
      $rand_num = int(rand($WIDTH));
   } until ($row[$rand_num] eq "$BLANK");

   return $rand_num;
}

# =============================================================================
# SignalHandler
#
# This is our generic signal handler.  It will do some quick cleanup.
#

sub SignalHandler
{
   local($sig) = @_;
   print "\nCaught a SIG$sig...exiting\n";
   print SOCK "s\n" if ($CONNECTED); # tell the opponent to abort also
   &CloseSocket();
   exit 1;
}

# =============================================================================
# INTERPROCESS COMMUNICATIONS FUNCTIONS
# =============================================================================

# =============================================================================
# FindAnother
#
# This will go out on the network to find the server (i.e. another player).
# If a server cannot be found, we will become the server and wait for
# someone to come along.
#

sub FindAnother
{
   local($af_inet)      = 2;
   local($sock_stream)  = 1;
   local($sock_addr)    = 'S n a4 x8';
   local($proto);
   local($remote);
   local($remoteaddr);
   local($local);
   local($localaddr);
   local($name);
   local($alias);
   local($type);
   local($len);
   local(*GENSOCK);

   ($name, $alias, $proto)                   = getprotobyname("tcp");
   ($name, $alias, $type, $len, $remoteaddr) = gethostbyname($REMOTE_HOSTNAME);
   ($name, $alias, $type, $len, $localaddr)  = gethostbyname($LOCAL_HOSTNAME);

   $local  = pack($sock_addr, $af_inet, 0,         $localaddr);
   $remote = pack($sock_addr, $af_inet, $TCP_PORT, $remoteaddr);

   # Make the socket filehandle and give it an address

   if (!(socket(GENSOCK, $af_inet, $sock_stream, $proto)))
   {
      die "Failed to create socket: $!\n";
   }

   if (!(bind(GENSOCK, $local)))
   {
      die "Failed to bind socket: $!\n";
   }

   #
   # IF we successfully connected to the other machine
   #    Set the global filehandle to the generic socket we connected to
   #    Tell the socket to flush on write
   #    Indicate that we are connected
   #    Since we are a client, our player number is 1
   # ELSE
   #    We will become the server - so listen for a connection from a client
   #       (we need to close the old socket and create a new one)
   #    Tell the socket to flush on write
   #    Accept a client connection (blocks until we get one)
   #    Tell the new socket to flush on write
   #    Indicate that we are connected
   #    Since we are the server, our player number is 0
   # ENDIF
   #

   print "Trying to connect to server at $REMOTE_HOSTNAME...\n";

   if (connect(GENSOCK, $remote))
   {
      *SOCK = GENSOCK;
      select(SOCK); $| = 1; select(STDOUT);

      $CONNECTED = 1;
      $MY_NUMBER = 1;
   }
   else
   {
      print "$! - we will be the server\n";

      close(GENSOCK);
      $local = pack($sock_addr, $af_inet, $TCP_PORT, $localaddr);

      if (!(socket(GENSOCK, $af_inet, $sock_stream, $proto)))
      {
         die "Failed to create socket: $!\n";
      }

      if (!(bind(GENSOCK, $local)))
      {
         die "Failed to bind socket: $!\n";
      }

      listen(GENSOCK, 1) || die "Failed to listen to socket: $!\n";
      select(GENSOCK); $| = 1; select(STDOUT);

      print "Waiting for someone to play with...\n";
      accept(SOCK, GENSOCK) || die "Failed to accept client connection: $!\n";
      select(SOCK); $| = 1; select(STDOUT);

      $CONNECTED = 1;
      $MY_NUMBER = 0;
   }
}

# =============================================================================
# CloseSocket
#
# This will close the socket if one is open.  Use this function in a
# signal handler to make sure the socket gets closed.
#

sub CloseSocket
{
   if ($CONNECTED)
   {
      shutdown(SOCK, 2);  # 0=disable recv,1=disable send,2=disable both
      close(SOCK);
   }
   $CONNECTED = ();
}

# =============================================================================
#
#		    GNU GENERAL PUBLIC LICENSE
#		       Version 2, June 1991
#
# Copyright (C) 1989, 1991 Free Software Foundation, Inc.
#                       51 Franklin St, Fifth Floor, Boston, MA  02110-1301  USA
# Everyone is permitted to copy and distribute verbatim copies
# of this license document, but changing it is not allowed.
# 
#  			    Preamble
# 
#   The licenses for most software are designed to take away your
# freedom to share and change it.  By contrast, the GNU General Public
# License is intended to guarantee your freedom to share and change free
# software--to make sure the software is free for all its users.  This
# General Public License applies to most of the Free Software
# Foundation's software and to any other program whose authors commit to
# using it.  (Some other Free Software Foundation software is covered by
# the GNU Library General Public License instead.)  You can apply it to
# your programs, too.
# 
#   When we speak of free software, we are referring to freedom, not
# price.  Our General Public Licenses are designed to make sure that you
# have the freedom to distribute copies of free software (and charge for
# this service if you wish), that you receive source code or can get it
# if you want it, that you can change the software or use pieces of it
# in new free programs; and that you know you can do these things.
# 
#   To protect your rights, we need to make restrictions that forbid
# anyone to deny you these rights or to ask you to surrender the rights.
# These restrictions translate to certain responsibilities for you if you
# distribute copies of the software, or if you modify it.
# 
#   For example, if you distribute copies of such a program, whether
# gratis or for a fee, you must give the recipients all the rights that
# you have.  You must make sure that they, too, receive or can get the
# source code.  And you must show them these terms so they know their
# rights.
# 
#   We protect your rights with two steps: (1) copyright the software, and
# (2) offer you this license which gives you legal permission to copy,
# distribute and/or modify the software.
# 
#   Also, for each author's protection and ours, we want to make certain
# that everyone understands that there is no warranty for this free
# software.  If the software is modified by someone else and passed on, we
# want its recipients to know that what they have is not the original, so
# that any problems introduced by others will not reflect on the original
# authors' reputations.
# 
#   Finally, any free program is threatened constantly by software
# patents.  We wish to avoid the danger that redistributors of a free
# program will individually obtain patent licenses, in effect making the
# program proprietary.  To prevent this, we have made it clear that any
# patent must be licensed for everyone's free use or not licensed at all.
# 
#   The precise terms and conditions for copying, distribution and
# modification follow.
# 
# 		    GNU GENERAL PUBLIC LICENSE
#    TERMS AND CONDITIONS FOR COPYING, DISTRIBUTION AND MODIFICATION
# 
#   0. This License applies to any program or other work which contains
# a notice placed by the copyright holder saying it may be distributed
# under the terms of this General Public License.  The "Program", below,
# refers to any such program or work, and a "work based on the Program"
# means either the Program or any derivative work under copyright law:
# that is to say, a work containing the Program or a portion of it,
# either verbatim or with modifications and/or translated into another
# language.  (Hereinafter, translation is included without limitation in
# the term "modification".)  Each licensee is addressed as "you".
# 
# Activities other than copying, distribution and modification are not
# covered by this License; they are outside its scope.  The act of
# running the Program is not restricted, and the output from the Program
# is covered only if its contents constitute a work based on the
# Program (independent of having been made by running the Program).
# Whether that is true depends on what the Program does.
# 
#   1. You may copy and distribute verbatim copies of the Program's
# source code as you receive it, in any medium, provided that you
# conspicuously and appropriately publish on each copy an appropriate
# copyright notice and disclaimer of warranty; keep intact all the
# notices that refer to this License and to the absence of any warranty;
# and give any other recipients of the Program a copy of this License
# along with the Program.
# 
# You may charge a fee for the physical act of transferring a copy, and
# you may at your option offer warranty protection in exchange for a fee.
# 
#   2. You may modify your copy or copies of the Program or any portion
# of it, thus forming a work based on the Program, and copy and
# distribute such modifications or work under the terms of Section 1
# above, provided that you also meet all of these conditions:
# 
#     a) You must cause the modified files to carry prominent notices
#     stating that you changed the files and the date of any change.
# 
#     b) You must cause any work that you distribute or publish, that in
#     whole or in part contains or is derived from the Program or any
#     part thereof, to be licensed as a whole at no charge to all third
#     parties under the terms of this License.
# 
#     c) If the modified program normally reads commands interactively
#     when run, you must cause it, when started running for such
#     interactive use in the most ordinary way, to print or display an
#     announcement including an appropriate copyright notice and a
#     notice that there is no warranty (or else, saying that you provide
#     a warranty) and that users may redistribute the program under
#     these conditions, and telling the user how to view a copy of this
#     License.  (Exception: if the Program itself is interactive but
#     does not normally print such an announcement, your work based on
#     the Program is not required to print an announcement.)
# 
# These requirements apply to the modified work as a whole.  If
# identifiable sections of that work are not derived from the Program,
# and can be reasonably considered independent and separate works in
# themselves, then this License, and its terms, do not apply to those
# sections when you distribute them as separate works.  But when you
# distribute the same sections as part of a whole which is a work based
# on the Program, the distribution of the whole must be on the terms of
# this License, whose permissions for other licensees extend to the
# entire whole, and thus to each and every part regardless of who wrote it.
# 
# Thus, it is not the intent of this section to claim rights or contest
# your rights to work written entirely by you; rather, the intent is to
# exercise the right to control the distribution of derivative or
# collective works based on the Program.
# 
# In addition, mere aggregation of another work not based on the Program
# with the Program (or with a work based on the Program) on a volume of
# a storage or distribution medium does not bring the other work under
# the scope of this License.
# 
#   3. You may copy and distribute the Program (or a work based on it,
# under Section 2) in object code or executable form under the terms of
# Sections 1 and 2 above provided that you also do one of the following:
# 
#     a) Accompany it with the complete corresponding machine-readable
#     source code, which must be distributed under the terms of Sections
#     1 and 2 above on a medium customarily used for software interchange; or,
# 
#     b) Accompany it with a written offer, valid for at least three
#     years, to give any third party, for a charge no more than your
#     cost of physically performing source distribution, a complete
#     machine-readable copy of the corresponding source code, to be
#     distributed under the terms of Sections 1 and 2 above on a medium
#     customarily used for software interchange; or,
# 
#     c) Accompany it with the information you received as to the offer
#     to distribute corresponding source code.  (This alternative is
#     allowed only for noncommercial distribution and only if you
#     received the program in object code or executable form with such
#     an offer, in accord with Subsection b above.)
# 
# The source code for a work means the preferred form of the work for
# making modifications to it.  For an executable work, complete source
# code means all the source code for all modules it contains, plus any
# associated interface definition files, plus the scripts used to
# control compilation and installation of the executable.  However, as a
# special exception, the source code distributed need not include
# anything that is normally distributed (in either source or binary
# form) with the major components (compiler, kernel, and so on) of the
# operating system on which the executable runs, unless that component
# itself accompanies the executable.
# 
# If distribution of executable or object code is made by offering
# access to copy from a designated place, then offering equivalent
# access to copy the source code from the same place counts as
# distribution of the source code, even though third parties are not
# compelled to copy the source along with the object code.
# 
#   4. You may not copy, modify, sublicense, or distribute the Program
# except as expressly provided under this License.  Any attempt
# otherwise to copy, modify, sublicense or distribute the Program is
# void, and will automatically terminate your rights under this License.
# However, parties who have received copies, or rights, from you under
# this License will not have their licenses terminated so long as such
# parties remain in full compliance.
# 
#   5. You are not required to accept this License, since you have not
# signed it.  However, nothing else grants you permission to modify or
# distribute the Program or its derivative works.  These actions are
# prohibited by law if you do not accept this License.  Therefore, by
# modifying or distributing the Program (or any work based on the
# Program), you indicate your acceptance of this License to do so, and
# all its terms and conditions for copying, distributing or modifying
# the Program or works based on it.
# 
#   6. Each time you redistribute the Program (or any work based on the
# Program), the recipient automatically receives a license from the
# original licensor to copy, distribute or modify the Program subject to
# these terms and conditions.  You may not impose any further
# restrictions on the recipients' exercise of the rights granted herein.
# You are not responsible for enforcing compliance by third parties to
# this License.
# 
#   7. If, as a consequence of a court judgment or allegation of patent
# infringement or for any other reason (not limited to patent issues),
# conditions are imposed on you (whether by court order, agreement or
# otherwise) that contradict the conditions of this License, they do not
# excuse you from the conditions of this License.  If you cannot
# distribute so as to satisfy simultaneously your obligations under this
# License and any other pertinent obligations, then as a consequence you
# may not distribute the Program at all.  For example, if a patent
# license would not permit royalty-free redistribution of the Program by
# all those who receive copies directly or indirectly through you, then
# the only way you could satisfy both it and this License would be to
# refrain entirely from distribution of the Program.
# 
# If any portion of this section is held invalid or unenforceable under
# any particular circumstance, the balance of the section is intended to
# apply and the section as a whole is intended to apply in other
# circumstances.
# 
# It is not the purpose of this section to induce you to infringe any
# patents or other property right claims or to contest validity of any
# such claims; this section has the sole purpose of protecting the
# integrity of the free software distribution system, which is
# implemented by public license practices.  Many people have made
# generous contributions to the wide range of software distributed
# through that system in reliance on consistent application of that
# system; it is up to the author/donor to decide if he or she is willing
# to distribute software through any other system and a licensee cannot
# impose that choice.
# 
# This section is intended to make thoroughly clear what is believed to
# be a consequence of the rest of this License.
# 
#   8. If the distribution and/or use of the Program is restricted in
# certain countries either by patents or by copyrighted interfaces, the
# original copyright holder who places the Program under this License
# may add an explicit geographical distribution limitation excluding
# those countries, so that distribution is permitted only in or among
# countries not thus excluded.  In such case, this License incorporates
# the limitation as if written in the body of this License.
# 
#   9. The Free Software Foundation may publish revised and/or new versions
# of the General Public License from time to time.  Such new versions will
# be similar in spirit to the present version, but may differ in detail to
# address new problems or concerns.
# 
# Each version is given a distinguishing version number.  If the Program
# specifies a version number of this License which applies to it and "any
# later version", you have the option of following the terms and conditions
# either of that version or of any later version published by the Free
# Software Foundation.  If the Program does not specify a version number of
# this License, you may choose any version ever published by the Free Software
# Foundation.
# 
#   10. If you wish to incorporate parts of the Program into other free
# programs whose distribution conditions are different, write to the author
# to ask for permission.  For software which is copyrighted by the Free
# Software Foundation, write to the Free Software Foundation; we sometimes
# make exceptions for this.  Our decision will be guided by the two goals
# of preserving the free status of all derivatives of our free software and
# of promoting the sharing and reuse of software generally.
# 
# 			    NO WARRANTY
# 
#   11. BECAUSE THE PROGRAM IS LICENSED FREE OF CHARGE, THERE IS NO WARRANTY
# FOR THE PROGRAM, TO THE EXTENT PERMITTED BY APPLICABLE LAW.  EXCEPT WHEN
# OTHERWISE STATED IN WRITING THE COPYRIGHT HOLDERS AND/OR OTHER PARTIES
# PROVIDE THE PROGRAM "AS IS" WITHOUT WARRANTY OF ANY KIND, EITHER EXPRESSED
# OR IMPLIED, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF
# MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE.  THE ENTIRE RISK AS
# TO THE QUALITY AND PERFORMANCE OF THE PROGRAM IS WITH YOU.  SHOULD THE
# PROGRAM PROVE DEFECTIVE, YOU ASSUME THE COST OF ALL NECESSARY SERVICING,
# REPAIR OR CORRECTION.
# 
#   12. IN NO EVENT UNLESS REQUIRED BY APPLICABLE LAW OR AGREED TO IN WRITING
# WILL ANY COPYRIGHT HOLDER, OR ANY OTHER PARTY WHO MAY MODIFY AND/OR
# REDISTRIBUTE THE PROGRAM AS PERMITTED ABOVE, BE LIABLE TO YOU FOR DAMAGES,
# INCLUDING ANY GENERAL, SPECIAL, INCIDENTAL OR CONSEQUENTIAL DAMAGES ARISING
# OUT OF THE USE OR INABILITY TO USE THE PROGRAM (INCLUDING BUT NOT LIMITED
# TO LOSS OF DATA OR DATA BEING RENDERED INACCURATE OR LOSSES SUSTAINED BY
# YOU OR THIRD PARTIES OR A FAILURE OF THE PROGRAM TO OPERATE WITH ANY OTHER
# PROGRAMS), EVEN IF SUCH HOLDER OR OTHER PARTY HAS BEEN ADVISED OF THE
# POSSIBILITY OF SUCH DAMAGES.
# 
# 		     END OF TERMS AND CONDITIONS
# 
# 	    How to Apply These Terms to Your New Programs
# 
#   If you develop a new program, and you want it to be of the greatest
# possible use to the public, the best way to achieve this is to make it
# free software which everyone can redistribute and change under these terms.
# 
#   To do so, attach the following notices to the program.  It is safest
# to attach them to the start of each source file to most effectively
# convey the exclusion of warranty; and each file should have at least
# the "copyright" line and a pointer to where the full notice is found.
# 
#     <one line to give the program's name and a brief idea of what it does.>
#     Copyright (C) <year>  <name of author>
# 
#     This program is free software; you can redistribute it and/or modify
#     it under the terms of the GNU General Public License as published by
#     the Free Software Foundation; either version 2 of the License, or
#     (at your option) any later version.
# 
#     This program is distributed in the hope that it will be useful,
#     but WITHOUT ANY WARRANTY; without even the implied warranty of
#     MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
#     GNU General Public License for more details.
# 
#     You should have received a copy of the GNU General Public License
#     along with this program; if not, write to the Free Software
#     Foundation, Inc., 51 Franklin St, Fifth Floor, Boston, MA  02110-1301  USA
# 
# 
# Also add information on how to contact you by electronic and paper mail.
# 
# If the program is interactive, make it output a short notice like this
# when it starts in an interactive mode:
# 
#     Gnomovision version 69, Copyright (C) year name of author
#     Gnomovision comes with ABSOLUTELY NO WARRANTY; for details type `show w'.
#     This is free software, and you are welcome to redistribute it
#     under certain conditions; type `show c' for details.
# 
# The hypothetical commands `show w' and `show c' should show the appropriate
# parts of the General Public License.  Of course, the commands you use may
# be called something other than `show w' and `show c'; they could even be
# mouse-clicks or menu items--whatever suits your program.
# 
# You should also get your employer (if you work as a programmer) or your
# school, if any, to sign a "copyright disclaimer" for the program, if
# necessary.  Here is a sample; alter the names:
# 
#   Yoyodyne, Inc., hereby disclaims all copyright interest in the program
#   `Gnomovision' (which makes passes at compilers) written by James Hacker.
# 
#   <signature of Ty Coon>, 1 April 1989
#   Ty Coon, President of Vice
# 
# This General Public License does not permit incorporating your program into
# proprietary programs.  If your program is a subroutine library, you may
# consider it more useful to permit linking proprietary applications with the
# library.  If this is what you want to do, use the GNU Library General
# Public License instead of this License.
