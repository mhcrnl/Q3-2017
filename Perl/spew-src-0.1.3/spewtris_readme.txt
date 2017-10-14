###############################################
# Title:  	Spew
# Description: 	A falling blocks game where the board spins around and zooms in and out.
# Author:  	Ben Garvey
#		bengarvey@comcast.net
#		http://www.bengarvey.com
# Date:		2/07/2003
# Version 0.1.3
###############################################

Controls:
Up or d - Rotate Clockwise
a	- Rotate Counter Clockwise
Down	- Pull down piece
Left 	- Move Piece Left
Right	- Move Piece Right

Objective:
To arrange the falling blocks so you create a total of 35 solid vertical lines.  If you start from the first level the game will get tougher each time you create 5 lines.  You can start at level 7, but then you have to create all 35 lines at that difficulty.

Skill Levels:
0 Lines - Easy
5 Lines - Hard
10 Lines - Super Hard
15 Lines - What the?!
20 Lines - BARF!
25 Lines - OH MY GOD!!!
30 Lines - Kill it! Kill it! Aghajsbc jka ka~......
35 Lines - You Win!

0.1.3 Changes
* Totally reworked the layout so it looks better
* Blocks are now different colors
* Rotation now changes direction once and a while
* FINALLY fixed the bug that caused pieces to fall faster while rotating.  I was rounding up somewhere where I should have been rounding down.
* Added messages for doubles, triples, and tetrices.
* Game board shrinks for 800 x 600. Looks good in higher resolutions.
* Added cool ending
* Add configurable XML file for setting skill level names, piece adjectives, keyboard controls, and piece colors.
* Add score and save the top ten scores

0.1.2 Changes
* Fixed the bug that got rid of too many lines
* Added various random distraction images
* Timing now clock based, not CPU speed

Future Changes

* Adding sounds


