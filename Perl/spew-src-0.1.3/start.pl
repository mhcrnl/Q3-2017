###############################################
# Title:  	Spewtris
# Description: 	A tetris-type game where the board spins around and zooms in and out.
# Author:  	Ben Garvey
#		bengarvey@comcast.net
#		http://www.bengarvey.com
# Date:		08/19/2003
# Version 0.1.0
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

# Hmmm... can I do relative lib paths? I don't know how.
use lib 'C:\Documents and Settings\Ben Garvey\My Documents\spintris\lib';

# Hmmm.. maybe its working now!
#use lib 'lib';

use strict;
use lib::Client;

# Creating the client starts the game
my $c = new Client;
