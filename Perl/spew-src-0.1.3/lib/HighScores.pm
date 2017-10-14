###############################################
# Title:  	Spew
# Description: 	A tetris-type game where the board spins around and zooms in and out.
# Author:  	Ben Garvey
#		bengarvey@comcast.net
#		http://www.bengarvey.com
# Date:		01/26/2004
# Version 0.1.3
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

package HighScores;

use strict;
use DataLoader;

sub new 
{	my $self = {};
	bless($self);

}

sub configure
{	my $self = shift;
	my $option = $_[0];
	my $value = $_[1];

	$self->{$option} = $value;

	return 1;


}

sub cget
{	my $self = shift;
	my $option = $_[0];

	return $self->{$option};
	
}

sub getXML
{	my $self = shift;

	my @scores = @{$self->{Score}};
	
	my $data = "";

	print scalar(@scores) . " Scores\n";

	foreach my $s (@scores)
	{	
		if ($s ne 'Score')
		{	
			$data .= "\t<Score>\n";
			foreach my $k (keys(%{$s}))
			{	if ($k ne 'main' && $s->{$k} ne "")
				{	$data .= "\t\t<$k>" . $s->{$k} . "</$k>\n";
				}
			}

			$data .= "\t</Score>\n";
		}


	}

	my $i = 0;
	for ($i=1; $i<=10; $i++)
	{	$data .= "\t\t" . "<title-$i>" . $self->{"title-$i"} . "</title-$i>\n";
	}
	
	return '<?xml version="1.0" encoding="ISO-8859-1"?>' . "\n" . 
			"<HighScores>\n" . 
			$data . 
			"</HighScores>\n";
}

return 1;