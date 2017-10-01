#
#  Copyright (c) 1997-2002 The Protein Laboratory, University of Copenhagen
#  All rights reserved.
#
#  Redistribution and use in source and binary forms, with or without
#  modification, are permitted provided that the following conditions
#  are met:
#  1. Redistributions of source code must retain the above copyright
#     notice, this list of conditions and the following disclaimer.
#  2. Redistributions in binary form must reproduce the above copyright
#     notice, this list of conditions and the following disclaimer in the
#     documentation and/or other materials provided with the distribution.
#
#  THIS SOFTWARE IS PROVIDED BY THE AUTHOR AND CONTRIBUTORS ``AS IS'' AND
#  ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE
#  IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE
#  ARE DISCLAIMED.  IN NO EVENT SHALL THE AUTHOR OR CONTRIBUTORS BE LIABLE
#  FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL
#  DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS
#  OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION)
#  HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT
#  LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY
#  OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF
#  SUCH DAMAGE.
#
#  Created by:
#     Anton Berezin  <tobez@tobez.org>
#     Dmitry Karasik <dk@plab.ku.dk> 
#
#  $Id$
#
use strict;
use Prima::ScrollWidget;

package Prima::ImageViewer;
use vars qw(@ISA);
@ISA = qw( Prima::ScrollWidget);

sub profile_default
{
	my $def = $_[0]-> SUPER::profile_default;
	my %prf = (
		autoZoom     => 0,
		image        => undef,
		imageFile    => undef,
		stretch      => 0,
		zoom         => 1,
		zoomPrecision=> 100,
		alignment    => ta::Left,
		valignment   => ta::Bottom,
		quality      => 1,
	);
	@$def{keys %prf} = values %prf;
	return $def;
}

sub profile_check_in
{
	my ( $self, $p, $default) = @_;
	$self-> SUPER::profile_check_in( $p, $default);
	if ( defined $p-> {imageFile} && !defined $p-> {image})
	{
		$p-> {image} = Prima::Image-> create;
		delete $p-> {image} unless $p-> {image}-> load($p-> {imageFile});
	}
}


sub init
{
	my $self = shift;
	for ( qw( image ImageFile))
		{ $self-> {$_} = undef; }
	for ( qw( alignment autoZoom quality valignment imageX imageY stretch))
		{ $self-> {$_} = 0; }
	for ( qw( zoom integralScreen integralImage))
		{ $self-> {$_} = 1; }
	$self-> {zoomPrecision} = 10;
	my %profile = $self-> SUPER::init(@_);
	$self-> { imageFile}     = $profile{ imageFile};
	for ( qw( image zoomPrecision zoom autoZoom stretch alignment valignment quality)) {
		$self-> $_($profile{$_});
	}
	return %profile;
}


sub on_paint
{
	my ( $self, $canvas) = @_;
	my @size   = $self-> size;
	my $bw     = $self-> {borderWidth};

	unless ( $self-> {image}) {
		$canvas-> rect3d( 
			0, 0, $size[0]-1, $size[1]-1, $bw, 
			$self-> dark3DColor, $self-> light3DColor, $self-> backColor
		);
		return 1;
	}

	$canvas-> rect3d( 
		0, 0, $size[0]-1, $size[1]-1, $bw, 
		$self-> dark3DColor, $self-> light3DColor
	) if $bw;

	my @r = $self-> get_active_area( 0, @size);
	$canvas-> clipRect( @r);
	$canvas-> translate( @r[0,1]);
	my $imY  = $self-> {imageY};
	my $imX  = $self-> {imageX};
	my $z = $self-> {zoom};
	my $imYz = int($imY * $z);
	my $imXz = int($imX * $z);
	my $winY = $r[3] - $r[1];
	my $winX = $r[2] - $r[0];
	my $deltaY = ($imYz - $winY - $self-> {deltaY} > 0) ? $imYz - $winY - $self-> {deltaY}:0;
	my ($xa,$ya) = ($self-> {alignment}, $self-> {valignment});
	my ($iS, $iI) = ($self-> {integralScreen}, $self-> {integralImage});
	my ( $atx, $aty, $xDest, $yDest);

	if ( $self->{stretch}) {
		$atx = $aty = $xDest = $yDest = 0;
		$imXz = $r[2] - $r[0];
		$imYz = $r[3] - $r[1];
		goto PAINT;
	}

	if ( $imYz < $winY) {
		if ( $ya == ta::Top) {
			$aty = $winY - $imYz;
		} elsif ( $ya != ta::Bottom) {
			$aty = int(($winY - $imYz)/2 + .5);
		} else {
			$aty = 0;
		}
		$canvas-> clear( 0, 0, $winX-1, $aty-1) if $aty > 0;
		$canvas-> clear( 0, $aty + $imYz, $winX-1, $winY-1) if $aty + $imYz < $winY;
		$yDest = 0;
	} else {
		$aty   = -($deltaY % $iS);
		$yDest = ($deltaY + $aty) / $iS * $iI;
		$imYz = int(($winY - $aty + $iS - 1) / $iS) * $iS;
		$imY = $imYz / $iS * $iI;
	}

	if ( $imXz < $winX) {
		if ( $xa == ta::Right) {
			$atx = $winX - $imXz;
		} elsif ( $xa != ta::Left) {
			$atx = int(($winX - $imXz)/2 + .5);
		} else {
			$atx = 0;
		}
		$canvas-> clear( 0, $aty, $atx - 1, $aty + $imYz - 1) if $atx > 0;
		$canvas-> clear( $atx + $imXz, $aty, $winX - 1, $aty + $imYz - 1) if $atx + $imXz < $winX;
		$xDest = 0;
	} else {
		$atx   = -($self-> {deltaX} % $iS);
		$xDest = ($self-> {deltaX} + $atx) / $iS * $iI;
		$imXz = int(($winX - $atx + $iS - 1) / $iS) * $iS;
		$imX = $imXz / $iS * $iI;
	}

PAINT:
	$canvas-> clear( $atx, $aty, $atx + $imXz, $aty + $imYz) if $self-> {icon};

	return $canvas-> put_image_indirect(
		$self-> {image},
		$atx, $aty,
		$xDest, $yDest,
		$imXz, $imYz, $imX, $imY,
		rop::CopyPut
	);
}

sub on_keydown
{
	my ( $self, $code, $key, $mod) = @_;

	return if $self->{stretch};

	return unless grep { $key == $_ } (
		kb::Left, kb::Right, kb::Down, kb::Up
	);

	my $xstep = int($self-> width  / 5) || 1;
	my $ystep = int($self-> height / 5) || 1;

	my ( $dx, $dy) = $self-> deltas;

	$dx += $xstep if $key == kb::Right;
	$dx -= $xstep if $key == kb::Left;
	$dy += $ystep if $key == kb::Down;
	$dy -= $ystep if $key == kb::Up;

	$self-> deltas( $dx, $dy);
}

sub on_size
{
	my $self = shift;
	$self->apply_auto_zoom if $self->{autoZoom};
	$self->SUPER::on_size(@_);
}

sub apply_auto_zoom
{
	my $self = shift;
	$self->hScroll(0);
	$self->vScroll(0);
	return unless $self->image;
	my @szA = $self->image-> size;
	my @szB = $self-> get_active_area(2);
	my $xx = $szB[0] / $szA[0];
	my $yy = $szB[1] / $szA[1];
	$self-> zoom( $xx < $yy ? $xx : $yy);
}

sub set_auto_zoom
{
	my ( $self, $az ) = @_;
	$self->{autoZoom} = $az;
	$self->apply_auto_zoom if $az;
}

sub set_alignment
{
	$_[0]-> {alignment} = $_[1];
	$_[0]-> repaint;
}

sub set_valignment
{
	$_[0]-> {valignment} = $_[1];
	$_[0]-> repaint;
}

my @cubic_palette;

sub set_image
{
	my ( $self, $img) = @_;
	unless ( defined $img) {
		$self-> {imageX} = $self-> {imageY} = 0;
		$self-> limits(0,0);
		$self-> palette([]);
		$self-> repaint if defined $self-> {image};
		$self-> {image} = $img;
		return;
	}

	$self-> {image} = $img;
	my ( $x, $y) = ($img-> width, $img-> height);
	$self-> {imageX} = $x;
	$self-> {imageY} = $y;
	$x *= $self-> {zoom};
	$y *= $self-> {zoom};
	$self-> {icon}   = $img-> isa('Prima::Icon');
	$self-> {bitmap} = $img-> isa('Prima::DeviceBitmap');
	$self-> limits($x,$y) unless $self->{stretch};
	if ( $self-> {quality}) {
		my $do_cubic;

		if ( $self-> {bitmap}) {
			$do_cubic = not($img-> monochrome) && $::application-> get_bpp == 8;
		} else {
			$do_cubic = ( $img-> type & im::BPP) > 8;
		}

		if ( $do_cubic) {
			my $depth = $self-> get_bpp;
			if (($depth > 2) && ($depth <= 8)) {
				unless ( scalar @cubic_palette) {
					my ( $r, $g, $b) = (6, 6, 6);
					@cubic_palette = ((0) x 648);
					for ( $b = 0; $b < 6; $b++) {
						for ( $g = 0; $g < 6; $g++) {
							for ( $r = 0; $r < 6; $r++) {
								my $ix = $b + $g * 6 + $r * 36;
								@cubic_palette[ $ix, $ix + 1, $ix + 2] = 
									map {$_*51} ($b,$g,$r); 
				}}}}
				$self-> palette( \@cubic_palette);
			}
		} else {
			$self-> palette( $img-> palette);
		}
	}
	$self-> repaint;
}

sub set_image_file
{
	my ($self,$file,$img) = @_;
	$img = Prima::Image-> create;
	return unless $img-> load($file);
	$self-> {imageFile} = $file;
	$self-> image($img);
}

sub set_quality
{
	my ( $self, $quality) = @_;
	return if $quality == $self-> {quality};
	$self-> {quality} = $quality;
	return unless defined $self-> {image};
	$self-> palette( $quality ? $self-> {image}-> palette : []);
	$self-> repaint;
}

sub zoom_round
{
	my ( $self, $zoom) = @_;
	$zoom = 100 if $zoom > 100;
	$zoom = 0.01 if $zoom <= 0.01;

	my $mul = $self-> {zoomPrecision};
	my $dv = int( $mul * ( $zoom - int( $zoom)) + 0.5);
	$dv-- if ($dv % 2) and ( $dv % 5);
	return int($zoom) + $dv / $mul;
}

sub set_zoom
{
	my ( $self, $zoom) = @_;

	return if $self->{stretch};

	$zoom = 100 if $zoom > 100;
	$zoom = 0.01 if $zoom < 0.01;

	my $mul = $self-> {zoomPrecision};
	my $dv = int( $mul * ( $zoom - int( $zoom)) + 0.5);
	$dv-- if ($dv % 2) and ( $dv % 5);
	$zoom = int($zoom) + $dv / $mul;
	$dv = 0 if $dv >= $mul;
	my ($r,$n,$m) = (1,$mul,$dv);
	while(1) {
		$r = $m % $n;
		last unless $r;
		($m,$n) = ($n,$r);
	}
	return if $zoom == $self-> {zoom};

	$self-> {zoom} = $zoom;
	$self-> {integralScreen} = int( $mul / $n) * int( $zoom) + int( $dv / $n);
	$self-> {integralImage}  = int( $mul / $n);

	return unless defined $self-> {image};
	my ( $x, $y) = ($self-> {image}-> width, $self-> {image}-> height);
	$x *= $self-> {zoom};
	$y *= $self-> {zoom};

	$self-> limits($x,$y);
	$self-> repaint;
	$self-> {hScrollBar}-> set_steps( $zoom, $zoom * 10) if $self-> {hScroll};
	$self-> {vScrollBar}-> set_steps( $zoom, $zoom * 10) if $self-> {vScroll};
}

sub set_zoom_precision
{
	my ( $self, $zp) = @_;

	$zp = 10 if $zp < 10;
	return if $zp == $self-> {zoomPrecision};

	$self-> {zoomPrecision} = $zp;
	$self-> zoom( $self-> {zoom});
}

sub set_stretch
{
	my ( $self, $s) = @_;
	$s = $s ? 1 : 0;
	return if $self->{stretch} == $s;
	$self->{stretch} = $s;
	$self->limits(0,0) if $s;
	$self->repaint;
}

sub screen2point
{
	my $self = shift;
	my @ret = ();
	my ( $i, $wx, $wy, $z, $dx, $dy, $ha, $va) =
		@{$self}{qw(indents winX winY zoom deltaX deltaY alignment valignment)};

	my ($maxx, $maxy, $zx, $zy);

	if ( $self->{stretch}) {
		$dx = $dy = $maxx = $maxy = 0;
		$zx = ($self->width  - $$i[2] - $$i[0]) / $self->{imageX};
		$zy = ($self->height - $$i[3] - $$i[1]) / $self->{imageY};
	} else {
		$zx = $zy = $z;
		$maxy = ( $wy < $self-> {limitY}) ? $self-> {limitY} - $wy : 0;
		unless ( $maxy) {
			if ( $va == ta::Top) {
				$maxy += $self-> {imageY} * $z - $wy;
			} elsif ( $va != ta::Bottom) {
				$maxy += ( $self-> {imageY} * $z - $wy) / 2;
			}
		}

		$maxx = 0;
		if ( $wx > $self-> {limitX}) {
			if ( $ha == ta::Right) {
				$maxx += $self-> {imageX} * $z - $wx;
			} elsif ( $ha != ta::Left) {
				$maxx += ( $self-> {imageX} * $z - $wx) / 2;
			}
		}
	}

	while ( scalar @_) {
		my ( $x, $y) = ( shift, shift);
		$x += $dx - $$i[0];
		$y += $maxy - $dy - $$i[1];
		$x += $maxx;
		push @ret, $x / $zx, $y / $zy;
	}
	return @ret;
}

sub point2screen
{
	my $self = shift;
	my @ret = ();
	my ( $i, $wx, $wy, $z, $dx, $dy, $ha, $va) =
		@{$self}{qw(indents winX winY zoom deltaX deltaY alignment valignment)};

	my ( $maxx, $maxy, $zx, $zy );
	if ( $self->{stretch}) {
		$dx = $dy = $maxx = $maxy = 0;
		$zx = ($self->width  - $$i[2] - $$i[0]) / $self->{imageX};
		$zy = ($self->height - $$i[3] - $$i[1]) / $self->{imageY};
	} else {
		$zx = $zy = $z;
		$maxy = ( $wy < $self-> {limitY}) ? $self-> {limitY} - $wy : 0;
		unless ( $maxy) {
			if ( $va == ta::Top) {
				$maxy += $self-> {imageY} * $z - $wy;
			} elsif ( $va != ta::Bottom) {
				$maxy += ( $self-> {imageY} * $z - $wy) / 2;
			}
		}
		
		$maxx = 0;
		if ( $wx > $self-> {limitX}) {
			if ( $ha == ta::Right) {
				$maxx += $self-> {imageX} * $z - $wx;
			} elsif ( $ha != ta::Left) {
				$maxx += ( $self-> {imageX} * $z - $wx) / 2;
			}
		}
	}

	while ( scalar @_) {
		my ( $x, $y) = ( $zx * shift, $zy * shift);
		$x -= $maxx + $dx - $$i[0];
		$y -= $maxy - $dy - $$i[1];
		push @ret, $x, $y;
	}
	return @ret;
}

sub autoZoom     {($#_)?$_[0]-> set_auto_zoom($_[1]):return $_[0]-> {autoZoom}}
sub alignment    {($#_)?($_[0]-> set_alignment(    $_[1]))               :return $_[0]-> {alignment}    }
sub valignment   {($#_)?($_[0]-> set_valignment(    $_[1]))              :return $_[0]-> {valignment}   }
sub image        {($#_)?$_[0]-> set_image($_[1]):return $_[0]-> {image} }
sub imageFile    {($#_)?$_[0]-> set_image_file($_[1]):return $_[0]-> {imageFile}}
sub zoom         {($#_)?$_[0]-> set_zoom($_[1]):return $_[0]-> {zoom}}
sub zoomPrecision{($#_)?$_[0]-> set_zoom_precision($_[1]):return $_[0]-> {zoomPrecision}}
sub quality      {($#_)?$_[0]-> set_quality($_[1]):return $_[0]-> {quality}}
sub stretch      {($#_)?$_[0]-> set_stretch($_[1]):return $_[0]-> {stretch}}

sub PreviewImage_HeaderReady
{ 
	my ( $self, $image) = @_;
	my $db;
	eval {
		$db = Prima::DeviceBitmap-> new(
			width    => $image-> width,
			height   => $image-> height,
		);
	};
	return unless $db;

	$self-> image($db);
        $self-> image-> backColor(0);
        $self-> image-> clear;
	$self-> {__preview_image} = 1;
}

sub PreviewImage_DataReady
{ 
	my ( $self, $image, $x, $y, $w, $h) = @_;
	return unless $self-> {__preview_image};

	# do not update if DataReady covers the whole image at once
	return if $y == 0 and $h == $image-> height;

	$self-> image-> put_image_indirect( $image, $x, $y, $x, $y, $w, $h, $w, $h, rop::CopyPut);
	my @r = $self-> point2screen( $x, $y, $x + $w, $y + $h);
	$self-> invalidate_rect(
		(map { int($_) } @r[0,1]),
		(map { int($_ + .5) + 1 } @r[2,3])
	);
	$self-> update_view;
}

sub watch_load_progress
{
	my ( $self, $image) = @_;

	$self-> unwatch_load_progress(0);

	my @ids =
		$image-> add_notification( 'HeaderReady', \&PreviewImage_HeaderReady, $self),
		$image-> add_notification( 'DataReady',   \&PreviewImage_DataReady,   $self)
		;
	$self-> {__watch_notifications} = [ @ids ];
}

sub unwatch_load_progress
{
	my ( $self, $clear_image) = @_;

	return unless $self-> {__watch_notifications};

	if ( $self-> {image}) {
		$self-> {image}-> remove_notification($_) 
			for @{ $self-> {__watch_notifications} };
	}
	delete $self-> {__watch_notifications};

	$clear_image = 1 unless defined $clear_image;
	if ( $self-> {__preview_image}) {
		$self-> image( undef) if $clear_image;
		delete $self-> {__preview_image};
	}
}

1;

__DATA__

=pod

=head1 NAME

Prima::ImageViewer - standard image, icon, and bitmap viewer class.

=head1 DESCRIPTION

The module contains C<Prima::ImageViewer> class, which provides
image displaying functionality, including different zoom levels.

C<Prima::ImageViewer> is a descendant of C<Prima::ScrollWidget>
and inherits its document scrolling behavior and programming interface.
See L<Prima::ScrollWidget> for details.

=head1 API

=head2 Properties

=over

=item alignment INTEGER

One of the following C<ta::XXX> constants:

	ta::Left
	ta::Center 
	ta::Right

Selects the horizontal image alignment.

Default value: C<ta::Left>

=item autoZoom BOOLEAN

When set, the image is automatically stretched while keeping aspects to the best available fit,
given the C<zoomPrecision>. Scrollbars are turned off if C<autoZoom> is set to 1.

=item image OBJECT

Selects the image object to be displayed. OBJECT can be
an instance of C<Prima::Image>, C<Prima::Icon>, or C<Prima::DeviceBitmap> class.

=item imageFile FILE

Set the image FILE to be loaded and displayed. Is rarely used since does not return
a loading success flag.

=item stretch BOOLEAN

If set, the image is simply stretched over the visual area,
without keeping the aspect. Scroll bars, zooming and
keyboard navigation become disabled.

=item quality BOOLEAN

A boolean flag, selecting if the palette of C<image> is to be 
copied into the widget palette, providing higher visual
quality on paletted displays. See also L<Prima::Widget/palette>.

Default value: 1

=item valignment INTEGER

One of the following C<ta::XXX> constants:

	ta::Top
	ta::Middle or ta::Center
	ta::Bottom

Selects the vertical image alignment.

NB: C<ta::Middle> value is not equal to C<ta::Center>'s, however
the both constants produce equal effect here.

Default value: C<ta::Bottom>

=item zoom FLOAT

Selects zoom level for image display. The acceptable value range is between
0.01 and 100. The zoom value is rounded to the closest value divisible by
1/C<zoomPrecision>. For example, is C<zoomPrecision> is 100, the zoom values
will be rounded to the precision of hundredth - to fiftieth and twentieth
fractional values - .02, .04, .05, .06, .08, and 0.1 . When C<zoomPrecision>
is 1000, the precision is one thousandth, and so on.

Default value: 1

=item zoomPrecision INTEGER

Zoom precision of C<zoom> property. Minimal acceptable value is 10, where zoom
will be rounded to 0.2, 0.4, 0.5, 0.6, 0.8 and 1.0 .

The reason behind this arithmetics is that when image of arbitrary zoom factor
is requested to be displayed, the image sometimes must begin to be drawn from
partial pixel - for example, 10x zoomed image shifted 3 pixels left, must be
displayed so the first image pixel from the left occupies 7 screen pixels, and
the next ones - 10 screen pixels.  That means, that the correct image display
routine must ask the system to draw the image at offset -3 screen pixels, where
the first pixel column would correspond to that pixel.

When zoom factor is fractional, the picture is getting more complex. For
example, with zoom factor 12.345, and zero screen offset, first image pixel
begins at 12th screen pixel, the next - 25th ( because of the roundoff ), then
37th etc etc. Also, for example the image is 2000x2000 pixels wide, and is
asked to be drawn so that the image appears shifted 499 screen image pixels
left, beginning to be drawn from ~ 499/12.3456=40.42122 image pixel. Is might
seem that indeed it would be enough to ask system to begin drawing from image
pixel 40, and offset int(0.42122*12.345)=5 screen pixels to the left, however,
that procedure will not account for the correct fixed point roundoff that
accumulates as system scales the image. For zoom factor 12.345 this roundoff
sequence is, as we seen before, (12,25,37,49,62,74,86,99,111,123) for first 10
pixels displayed, that occupy (12,13,12,12,13,12,12,13,12,12) screen pixels.
For pixels starting at 499, this sequence is
(506,519,531,543,556,568,580,593,605,617) offsets or
(13,12,12,13,13,12,12,13,12,12) widths -- note the two subsequent 13s there.
This sequence begins to repeat itself after 200 iterations
(12.345*200=2469.000), which means that in order to achieve correct display
results, the image must be asked to be displayed from image pixel 0 if image's
first pixel on the screen is between 0 and 199 ( or for screen pixels 0-2468),
from image pixel 200 for offsets 200-399, ( screen pixels 2469-4937), and so
on.

Since system internally allocate memory for image scaling, that means that up
to 2*200*min(window_width,image_width)*bytes_per_pixel unneccessary bytes will
be allocated for each image drawing call (2 because the calculations are valid
for both the vertical and horizontal strips), and this can lead to slowdown or
even request failure when image or window dimensions are large. The proposed
solution is to roundoff accepted zoom factors, so these offsets are kept small
- for example, N.25 zoom factors require only max 1/.25=4 extra pixels. When
C<zoomPrecision> value is 100, zoom factors are rounded to 0.X2, 0.X4, 0.X5,
0.X6, 0.X8, 0.X0, thus requiring max 50 extra pixels.

NB. If, despite the efforts, the property gets in the way, increase it to
1000 or even 10000, but note that this may lead to problems.

Default value: 100

=back

=head2 Methods

=over

=item on_paint SELF, CANVAS

The C<Paint> notification handler is mentioned here for the specific case
of its return value, that is the return value of internal C<put_image> call.
For those who might be interested in C<put_image> failures, that mostly occur
when trying to draw an image that is too big, the following code might be 
useful:

    sub on_paint 
    {
        my ( $self, $canvas) = @_;
	warn "put_image() error:$@" unless $self-> SUPER::on_paint($canvas);
    }

=item screen2point X, Y, [ X, Y, ... ]

Performs translation of integer pairs integers as (X,Y)-points from widget coordinates 
to pixel offset in image coordinates. Takes in account zoom level,
image alignments, and offsets. Returns array of same length as the input.

Useful for determining correspondence, for example, of a mouse event
to a image point.

The reverse function is C<point2screen>.

=item point2screen   X, Y, [ X, Y, ... ]

Performs translation of integer pairs as (X,Y)-points from image pixel offset
to widget image coordinates. Takes in account zoom level,
image alignments, and offsets. Returns array of same length as the input.

Useful for determining a screen location of an image point.

The reverse function is C<screen2point>.

=item watch_load_progress IMAGE

When called, image viewer watches as IMAGE is being loaded ( see L<Prima::Image/load> )
and displays the progress. As soon as IMAGE begins to load, it replaces the existing C<image>
property. Example:

    $i = Prima::Image-> new;
    $viewer-> watch_load_progress( $i);
    $i-> load('huge.jpg');
    $viewer-> unwatch_load_progress;

Similar functionality is present in L<Prima::ImageDialog>.

=item unwatch_load_progress CLEAR_IMAGE=1

Stops monitoring of image loading progress. If CLEAR_IMAGE is 0, the leftovers of the
incremental loading stay intact in C<image> propery. Otherwise, C<image> is set to C<undef>.

=item zoom_round ZOOM

Rounds the zoom factor to C<zoomPrecision> precision, returns
the rounded zoom value. The algorithm is the same as used internally
in C<zoom> property.

=back

=head1 AUTHOR

Dmitry Karasik, E<lt>dmitry@karasik.eu.orgE<gt>.

=head1 SEE ALSO

L<Prima>, L<Prima::Image>, L<Prima::ScrollWidget>, L<Prima::ImageDialog>, F<examples/iv.pl>.

=cut
