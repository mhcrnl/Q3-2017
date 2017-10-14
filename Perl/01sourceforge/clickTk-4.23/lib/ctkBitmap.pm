#!/usr/bin/perl

=head1 ctkBitmap

	This class provides standard bitmaps.

	Public interface

	$widget->ctkBitmap(qw/ list of predefined bitmaps /);
	
	where $widget must be a composite widget which derives from class ctkBitmap

=head2 Programmin notes	

	None

=head2 Maintenance

	Author:	marco
	date:	04.03.2006
	History 
		    04.03.2006 take over methods from package main.

=head1 Methods

=cut

package ctkBitmap ;

use vars qw/$VERSION/;

$VERSION = 1.01;

my $bitmaps ={};

my $inc_bits = pack("b8"x5,
		    "........",
		    "...11...",
		    "..1111..",
		    ".111111.",
		    "........"
		  );

=head2 ctkBitmap

		Create predefined bitmaps

=over

=item Argument

		List of bitmap names to be created.

=item Return

		Always true.

=back

=cut

sub ctkBitmap {
	my $hwnd = shift; 
	map {
		&$_($hwnd) unless(exists $bitmaps->{$_})
	} @_;
}

sub INCBITMAP {
	shift->DefineBitmap('INCBITMAP' => 8,5, $inc_bits);
	$bitmaps->{'INCBITMAP'} = 1;		
}
sub DECBITMAP {
	shift->DefineBitmap('DECBITMAP' => 8,5,scalar reverse $inc_bits);
	$bitmaps->{'DECBITMAP'} = 1;		
}
