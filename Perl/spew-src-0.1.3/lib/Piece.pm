###############################################
# Title:  	Spew
# Description: 	A tetris-type game where the board spins around and zooms in and out.
# Author:  	Ben Garvey
#		bengarvey@comcast.net
#		http://www.bengarvey.com
# Date:		08/19/2003
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

package Piece;

use strict;

sub new 
{	my $self = {};
	bless($self);

	my $settings = $_[1];


	@{$self->{map}} = ();

	my $rand = $self->round(rand() * 6);
	$self->{type} = $rand;
	#$rand = 4;
	
	$self->{rotationIndex} = $self->round(rand() * 3);

	#print "RAND = $rand\n";
	
=for comment
	# Eventually we'll want to pull these from a file
	my @colors = (	'00AA33', 
			'33AA00', 
			'EE7733', 
			'AA0033', 
			'8800AA', 
			'0077AA', 
			'00AAFF', 
			'FFAA00', 
			'AAFF00', 
			'AA00FF', 
			'FF00AA', 
			'00FFAA', 
			'EEAA33', 
			'1144BB', 
			'AA2233',
			);
=cut

	my $dl = new DataLoader;

	#my $settings = $dl->loadData("settings.txt", 'Settings');

	my @colors = @{$settings->cget('color')};

	$self->{color} = $colors[ $self->round( rand() * (scalar(@colors)) - 1) ];

	#$self->{color} = sprintf( "%lx", $self->round(rand() * 16777215) );

	#print "STR LENGTH " . length($self->{color}) . "\n";

	while ( length($self->{color}) < 6 )
	{	$self->{color} = "0" . $self->{color};	
	}

	$self->{color} = "#" . $self->{color};

	#print "NEW COLOR:  " . $self->{color} . "\n";

	if ($rand == 0)
	{	@{$self->{map0}} = (	0,0,0,0,0,2,0,0,0,0,
					0,0,0,0,0,2,0,0,0,0,
					0,0,0,0,2,2,0,0,0,0,
					0,0,0,0,0,0,0,0,0,0 );

		@{$self->{map1}} = (	0,0,0,0,2,0,0,0,0,0,
					0,0,0,0,2,2,2,0,0,0,
					0,0,0,0,0,0,0,0,0,0,
					0,0,0,0,0,0,0,0,0,0 );

		@{$self->{map2}} = (	0,0,0,0,2,2,0,0,0,0,
					0,0,0,0,2,0,0,0,0,0,
					0,0,0,0,2,0,0,0,0,0,
					0,0,0,0,0,0,0,0,0,0 );

		@{$self->{map3}} = (	0,0,0,0,2,2,2,0,0,0,
					0,0,0,0,0,0,2,0,0,0,
					0,0,0,0,0,0,0,0,0,0,
					0,0,0,0,0,0,0,0,0,0 );
	}
	elsif ($rand == 1)
	{	@{$self->{map0}} = (	0,0,0,0,2,2,0,0,0,0,
					0,0,0,0,2,2,0,0,0,0,
					0,0,0,0,0,0,0,0,0,0,
					0,0,0,0,0,0,0,0,0,0 );

		@{$self->{map1}} = (	0,0,0,0,2,2,0,0,0,0,
					0,0,0,0,2,2,0,0,0,0,
					0,0,0,0,0,0,0,0,0,0,
					0,0,0,0,0,0,0,0,0,0 );

		@{$self->{map2}} = (	0,0,0,0,2,2,0,0,0,0,
					0,0,0,0,2,2,0,0,0,0,
					0,0,0,0,0,0,0,0,0,0,
					0,0,0,0,0,0,0,0,0,0 );

		@{$self->{map3}} = (	0,0,0,0,2,2,0,0,0,0,
					0,0,0,0,2,2,0,0,0,0,
					0,0,0,0,0,0,0,0,0,0,
					0,0,0,0,0,0,0,0,0,0 );
	}
	elsif ($rand == 2)
	{	@{$self->{map0}} = (	0,0,0,2,2,0,0,0,0,0,
					0,0,0,0,2,2,0,0,0,0,
					0,0,0,0,0,0,0,0,0,0,
					0,0,0,0,0,0,0,0,0,0 );

		@{$self->{map1}} = (	0,0,0,0,0,2,0,0,0,0,
					0,0,0,0,2,2,0,0,0,0,
					0,0,0,0,2,0,0,0,0,0,
					0,0,0,0,0,0,0,0,0,0 );

		@{$self->{map2}} = (	0,0,0,0,2,2,0,0,0,0,
					0,0,0,0,0,2,2,0,0,0,
					0,0,0,0,0,0,0,0,0,0,
					0,0,0,0,0,0,0,0,0,0 );

		@{$self->{map3}} = (	0,0,0,0,0,0,2,0,0,0,
					0,0,0,0,0,2,2,0,0,0,
					0,0,0,0,0,2,0,0,0,0,
					0,0,0,0,0,0,0,0,0,0 );
	}
	elsif ($rand == 3)
	{	@{$self->{map0}} = (	0,0,0,0,0,2,2,0,0,0,
					0,0,0,0,2,2,0,0,0,0,
					0,0,0,0,0,0,0,0,0,0,
					0,0,0,0,0,0,0,0,0,0 );

		@{$self->{map1}} = (	0,0,0,0,2,0,0,0,0,0,
					0,0,0,0,2,2,0,0,0,0,
					0,0,0,0,0,2,0,0,0,0,
					0,0,0,0,0,0,0,0,0,0 );

		@{$self->{map2}} = (	0,0,0,0,0,2,2,0,0,0,
					0,0,0,0,2,2,0,0,0,0,
					0,0,0,0,0,0,0,0,0,0,
					0,0,0,0,0,0,0,0,0,0 );

		@{$self->{map3}} = (	0,0,0,0,2,0,0,0,0,0,
					0,0,0,0,2,2,0,0,0,0,
					0,0,0,0,0,2,0,0,0,0,
					0,0,0,0,0,0,0,0,0,0 );
	}
	elsif ($rand == 4)
	{	@{$self->{map0}} = (	0,0,0,0,0,2,0,0,0,0,
					0,0,0,0,0,2,0,0,0,0,
					0,0,0,0,0,2,0,0,0,0,
					0,0,0,0,0,2,0,0,0,0 );

		@{$self->{map1}} = (	0,0,0,0,2,2,2,2,0,0,
					0,0,0,0,0,0,0,0,0,0,
					0,0,0,0,0,0,0,0,0,0,
					0,0,0,0,0,0,0,0,0,0 );

		@{$self->{map2}} = (	0,0,0,0,2,0,0,0,0,0,
					0,0,0,0,2,0,0,0,0,0,
					0,0,0,0,2,0,0,0,0,0,
					0,0,0,0,2,0,0,0,0,0 );

		@{$self->{map3}} = (	0,0,0,2,2,2,2,0,0,0,
					0,0,0,0,0,0,0,0,0,0,
					0,0,0,0,0,0,0,0,0,0,
					0,0,0,0,0,0,0,0,0,0 );
	}
	elsif ($rand == 5)
	{	@{$self->{map0}} = (	0,0,0,0,0,2,0,0,0,0,
					0,0,0,0,2,2,2,0,0,0,
					0,0,0,0,0,0,0,0,0,0,
					0,0,0,0,0,0,0,0,0,0 );

		@{$self->{map1}} = (	0,0,0,0,2,0,0,0,0,0,
					0,0,0,0,2,2,0,0,0,0,
					0,0,0,0,2,0,0,0,0,0,
					0,0,0,0,0,0,0,0,0,0 );

		@{$self->{map2}} = (	0,0,0,0,2,2,2,0,0,0,
					0,0,0,0,0,2,0,0,0,0,
					0,0,0,0,0,0,0,0,0,0,
					0,0,0,0,0,0,0,0,0,0 );

		@{$self->{map3}} = (	0,0,0,0,0,2,0,0,0,0,
					0,0,0,0,2,2,0,0,0,0,
					0,0,0,0,0,2,0,0,0,0,
					0,0,0,0,0,0,0,0,0,0 );
	}
	elsif ($rand == 6)
	{	@{$self->{map0}} = (	0,0,0,0,2,0,0,0,0,0,
					0,0,0,0,2,0,0,0,0,0,
					0,0,0,0,2,2,0,0,0,0,
					0,0,0,0,0,0,0,0,0,0 );

		@{$self->{map1}} = (	0,0,0,0,2,2,2,0,0,0,
					0,0,0,0,2,0,0,0,0,0,
					0,0,0,0,0,0,0,0,0,0,
					0,0,0,0,0,0,0,0,0,0 );

		@{$self->{map2}} = (	0,0,0,0,2,2,0,0,0,0,
					0,0,0,0,0,2,0,0,0,0,
					0,0,0,0,0,2,0,0,0,0,
					0,0,0,0,0,0,0,0,0,0 );

		@{$self->{map3}} = (	0,0,0,0,0,0,2,0,0,0,
					0,0,0,0,2,2,2,0,0,0,
					0,0,0,0,0,0,0,0,0,0,
					0,0,0,0,0,0,0,0,0,0 );
	}
	else
	{	@{$self->{map}} = (	0,0,0,0,2,0,0,0,0,0,
					0,0,0,2,2,2,0,0,0,0,
					0,0,0,0,2,0,0,0,0,0,
					0,0,0,0,0,0,0,0,0,0 );
	}

	return $self;
}

sub rotateClockwise
{	my $self = shift;

	$self->{rotationIndex}++;

	if ($self->{rotationIndex} > 3)
	{	$self->{rotationIndex} = 0;
	}

	return @{$self->{'map' . $self->{rotationIndex}}};
}

sub rotateCounterClockwise
{	my $self = shift;

	$self->{rotationIndex}--;

	if ($self->{rotationIndex} < 0)
	{	$self->{rotationIndex} = 3;
	}

	return @{$self->{'map' . $self->{rotationIndex}}};
}

sub getMap
{	my $self = shift;
	return @{$self->{'map' . $self->{rotationIndex}}};
}

sub round 
{	my $self = shift;
	my $number = shift;
	
	return int($number + .5);
}

sub cget
{	my $self = shift;
	my $option = $_[0];

	return $self->{$option};
}

return 1;

