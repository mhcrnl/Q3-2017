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
#  Created by Dmitry Karasik <dk@plab.ku.dk>
#
#  $Id$

# contains:
#    ColorDialog
#    ColorComboBox

use strict;
use Prima::Const;
use Prima::Classes;
use Prima::Sliders;
use Prima::Label;
use Prima::Buttons;
use Prima::ComboBox;
use Prima::ScrollBar;

package Prima::ColorDialog;
use vars qw( @ISA $colorWheel $colorWheelShape);
@ISA = qw( Prima::Dialog);

{
my %RNT = (
	%{Prima::Dialog-> notification_types()},
	BeginDragColor => nt::Command,
	EndDragColor   => nt::Command,
);

sub notification_types { return \%RNT; }
}

my $shapext = Prima::Application-> get_system_value( sv::ShapeExtension);

sub hsv2rgb
{
	my ( $h, $s, $v) = @_;
	$v = 1 if $v > 1;
	$v = 0 if $v < 0;
	$s = 1 if $s > 1;
	$s = 0 if $s < 0;
	$v *= 255;
	return $v, $v, $v if $h == -1;
	my ( $r, $g, $b, $i, $f, $w, $q, $t);
	$h -= 360 if $h >= 360;
	$h /= 60;
	$i = int( $h);
	$f = $h - $i;
	$w = $v * (1 - $s);
	$q = $v * (1 - ($s * $f));
	$t = $v * (1 - ($s * (1 - $f)));

	if ( $i == 0) {
		return $v, $t, $w;
	} elsif ( $i == 1) {
		return $q, $v, $w;
	} elsif ( $i == 2) {
		return $w, $v, $t;
	} elsif ( $i == 3) {
		return $w, $q, $v;
	} elsif ( $i == 4) {
		return $t, $w, $v;
	} else {
		return $v, $w, $q;
	}
}

sub rgb2hsv
{
	my ( $r, $g, $b) = @_;
	my ( $h, $s, $v, $max, $min, $delta);
	$r /= 255;
	$g /= 255;
	$b /= 255;
	$max = $r;
	$max = $g if $g > $max;
	$max = $b if $b > $max;
	$min = $r;
	$min = $g if $g < $min;
	$min = $b if $b < $min;
	$v = $max;
	$s = $max ? ( $max - $min) / $max : 0;
	return -1, $s, $v unless $s;

	$delta = $max - $min;
	if ( $r == $max) {
		$h = ( $g - $b) / $delta;
	} elsif ( $g == $max) {
		$h = 2 + ( $b - $r) / $delta;
	} else {
		$h = 4 + ( $r - $g) / $delta;
	}
	$h *= 60;
	$h += 360 if $h < 0;
	return $h, $s, $v;
}

sub rgb2value
{
	return $_[2]|($_[1] << 8)|($_[0] << 16);
}

sub value2rgb
{
	my $c = $_[0];
	return ( $c>>16) & 0xFF, ($c>>8) & 0xFF, $c & 0xFF;
}

sub xy2hs
{
	my ( $x, $y, $c) = @_;
	my ( $d, $r, $rx, $ry, $h, $s);
	( $rx, $ry) = ( $x - $c, $y - $c);
	my $c2 = $c * $c;
	$d = $c2 * ( $rx*$rx + $ry*$ry - $c2);

	$r = sqrt( $rx*$rx + $ry*$ry);

	$h = $r ? atan2( $rx/$r, $ry/$r) : 0;

	$s = $r / $c;
	$h = $h * 57.295779513 + 180;

	$s = 1 if $s > 1;

	return $h, $s, $d > 0;
}

sub hs2xy
{
	my ( $h, $s) = @_;
	my ( $r, $a) = ( 128 * $s, ($h - 180) / 57.295779513);
	return 128 + $r * sin( $a), 128 + $r * cos( $a);
}

sub create_wheel
{
	my ($id, $color)   = @_;
	my $imul = 256 / $id;
	my $i = Prima::DeviceBitmap-> create(
		width  => 256,
		height => 256,
		name => '',
	);

	my ( $y1, $x1) = ($id,$id);
	my  $d0 = $id / 2;

	$i-> begin_paint;
	$i-> color( cl::Black);
	$i-> bar( 0, 0, $i-> width, $i-> height);

	my ( $y, $x);

	for ( $y = 0; $y < $y1; $y++) {
		for ( $x = 0; $x < $x1; $x++) {
			my ( $h, $s, $ok) = xy2hs( $x, $y, $d0);
			next if $ok;
			my ( $r, $g, $b) = hsv2rgb( $h, $s, 1);
			$i-> color( $b | ($g << 8) | ($r << 16));
			$i-> bar( 
				$x * $imul, $y * $imul, 
				( $x + 1) * $imul - 1, ( $y + 1) * $imul - 1
			);
		}
	}
	$i-> end_paint;


	my $a = Prima::DeviceBitmap-> create(
		width  => 256,
		height => 256,
		name   => 'ColorWheel',
	);

	$a-> begin_paint;
	$a-> color( $color);
	$a-> bar( 0, 0, $a-> size);
	$a-> rop( rop::XorPut);
	$a-> put_image( 0, 0, $i);
	$a-> rop( rop::CopyPut);
	$a-> color( cl::Black);
	$a-> fill_ellipse(
		128, 128,
		255 - $imul * 2,
		255 - $imul * 2
	);
	$a-> rop( rop::XorPut);
	$a-> put_image( 0, 0, $i);
	$a-> end_paint;

	$i-> destroy;

	return $a;
}

sub create_wheel_shape
{
	return unless $shapext;
	my $id = $_[0];
	my $imul = 256 / $id;
	my $a = Prima::Image-> create(
		width => 256,
		height => 256,
		type => im::BW,
	);
	$a-> begin_paint;
	$a-> color( cl::Black);
	$a-> bar( 0, 0, 255, 255);
	$a-> color( cl::White);
	$a-> fill_ellipse( 128, 128, 255 - $imul * 2, 255 - $imul * 2);
	$a-> end_paint;
	return $a;
}

sub profile_default
{
	return {
		%{$_[ 0]-> SUPER::profile_default},

		width         => 348,
		height        => 450,
		centered      => 1,
		visible       => 0,
		scaleChildren => 0,
		text          => 'Select color',

		quality       => 0,
		value         => cl::White,
	}
}

sub init
{
	my $self = shift;
	my %profile = $self-> SUPER::init(@_);
	$self-> {setTransaction} = undef;

	my $c = $self-> {value} = $profile{value};
	$self-> {quality} = 0;
	my ( $r, $g, $b) = value2rgb( $c);
	my ( $h, $s, $v) = rgb2hsv( $r, $g, $b);
	$s *= 255;
	$v *= 255;
	$h = int($h);
	$s = int($s);
	$v = int($v);

	$colorWheel = create_wheel(32, $self-> backColor) unless $colorWheel;
	$colorWheelShape = create_wheel_shape(32) unless $colorWheelShape;

	$self-> {wheel} = $self-> insert( Widget =>
		origin         => [ 20, 172],
		width          => 256,
		height         => 256,
		name           => 'Wheel',
		shape          => $colorWheelShape,
		ownerBackColor => 1,
		syncPaint      => 1,
		delegations    => [qw(Paint MouseDown MouseUp MouseMove)],
	);

	$self-> {roller} = $self-> insert( Widget =>
		origin    => [ 288, 164],
		width     => 48,
		height    => 272,
		buffered  => 1,
		name      => 'Roller',
		ownerBackColor => 1,
		delegations    => [qw(Paint MouseDown MouseUp MouseMove)],
	);

	# RGB
	my %rgbprf = (
		width    => 72,
		max      => 255,
		onChange => sub { RGB_Change( $_[0]-> owner, $_[0]);},
	);
	$self-> {R} = $self-> insert( SpinEdit =>
		origin   => [40,120],
		value    => $r,
		name     => 'R',
		%rgbprf,
	);
	my %labelprf = (
		width      => 20,
		height     => $self-> {R}-> height,
		autoWidth  => 0,
		autoHeight => 0,
		valignment => ta::Center,
	);
	$self-> insert( Label =>
		origin     => [ 20, 120],
		focusLink  => $self-> {R},
		text       => 'R:',
		%labelprf,
	);
	$self-> {G} = $self-> insert( SpinEdit =>
		origin   => [148,120],
		value    => $g,
		name     => 'G',
		%rgbprf,
	);
	$self-> insert( Label =>
		origin     => [ 126, 120],
		focusLink  => $self-> {G},
		text       => 'G:',
		%labelprf,
	);
	$self-> {B} = $self-> insert( SpinEdit =>
		origin   => [256,120],
		value    => $b,
		name     => 'B',
		%rgbprf,
	);
	$self-> insert( Label =>
		origin     => [ 236, 120],
		focusLink  => $self-> {B},
		text       => 'B:',
		%labelprf,
	);

	$rgbprf{onChange} = sub { HSV_Change( $_[0]-> owner, $_[0])};
	$self-> {H} = $self-> insert( SpinEdit =>
		origin   => [ 40,78],
		value    => $h,
		name     => 'H',
		%rgbprf,
		max      => 360,
	);
	$self-> insert( Label =>
		origin     => [ 20, 78],
		focusLink  => $self-> {H},
		text       => 'H:',
		%labelprf,
	);
	$self-> {S} = $self-> insert( SpinEdit =>
		origin   => [ 146,78],
		value    => int($s),
		name     => 'S',
		%rgbprf,
	);
	$self-> insert( Label =>
		origin     => [ 126, 78],
		focusLink  => $self-> {S},
		text       => 'S:',
		%labelprf,
	);
	$self-> {V} = $self-> insert( SpinEdit =>
		origin   => [ 256,78],
		value    => int($v),
		name     => 'V',
		%rgbprf,
	);
	$self-> insert( Label =>
		origin     => [ 236, 78],
		focusLink  => $self-> {V},
		text       => 'V:',
		%labelprf,
	);
	$self-> insert( Button =>
		text        => '~OK',
		origin      => [ 20, 20],
		modalResult => mb::OK,
		default     => 1,
	);

	$self-> insert( Button =>
		text        => 'Cancel',
		origin      => [ 126, 20],
		modalResult => mb::Cancel,
	);
	$self-> {R}-> select;
	$self-> quality( $profile{quality});

	$self-> Roller_Repaint if $self-> {quality};
	return %profile;
}

sub on_destroy
{
	$colorWheelShape = undef;
}

sub on_begindragcolor
{
	my ( $self, $property) = @_;
	$self-> {old_text} = $self-> text;
	$self-> {wheel}-> pointer( cr::Invalid);
	$self-> text( "Apply $property...");
}

sub on_enddragcolor
{
	my ( $self, $property, $widget) = @_;

	$self-> {wheel}-> pointer( cr::Default);
	$self-> text( $self-> {old_text});
	if ( $widget) {
		$property = $widget-> can( $property);
		$property-> ( $widget, $self-> value) if $property;
	}
	delete $self-> {old_text};
}

use constant Hue    => 1;
use constant Sat    => 2;
use constant Lum    => 4;
use constant Roller => 8;
use constant Wheel  => 16;
use constant All    => 31;

sub RGB_Change
{
	my ($self, $pin) = @_;
	return if $self-> {setTransaction};
	$self-> {setTransaction} = 1;
	$self-> {RGBPin} = $pin;
	my ( $r, $g, $b) = value2rgb( $self-> {value});
	$r = $self-> {R}-> value if $pin == $self-> {R};
	$g = $self-> {G}-> value if $pin == $self-> {G};
	$b = $self-> {B}-> value if $pin == $self-> {B};
	$self-> value( rgb2value( $r, $g, $b));
	undef $self-> {RGBPin};
	undef $self-> {setTransaction};
}

sub HSV_Change
{
	my ($self, $pin) = @_;
	return if $self-> {setTransaction};
	$self-> {setTransaction} = 1;
	my ( $h, $s, $v);
	$self-> {HSVPin} = Hue | Lum | Sat | ( $pin == $self-> {V} ? (Wheel|Roller) : 0);
	$h = $self-> {H}-> value      ;
	$s = $self-> {S}-> value / 255;
	$v = $self-> {V}-> value / 255;
	$self-> value( rgb2value( hsv2rgb( $h, $s, $v)));
	undef $self-> {HSVPin};
	undef $self-> {setTransaction};
}

sub Wheel_Paint
{
	my ( $owner, $self, $canvas) = @_;
	$canvas-> put_image( 0, 0, $colorWheel);
	my ( $x, $y) = hs2xy( $owner-> {H}-> value, $owner-> {S}-> value/273);
	$canvas-> color( cl::White);
	$canvas-> rop( rop::XorPut);
	if ( $shapext) {
		my @sz = $canvas-> size;
		$canvas-> linePattern( lp::DotDot);
		$canvas-> line( $x, 0, $x, $sz[1]);
		$canvas-> line( 0, $y, $sz[0], $y);
	} else {
		$canvas-> lineWidth( 3);
		$canvas-> ellipse( $x, $y, 13, 13);
	}
}

sub Wheel_MouseDown
{
	my ( $owner, $self, $btn, $mod, $x, $y) = @_;
	return if $self-> {mouseTransation};
	return if $btn != mb::Left;
	my ( $h, $s, $ok) = xy2hs( $x-9, $y-9, 119);
	return if $ok;
	$self-> {mouseTransation} = $btn;
	$self-> capture(1);
	if ( $btn == mb::Left) {
		if ( $mod == ( km::Ctrl | km::Alt)) {
			$self-> {drag_color} = 'disabledColor';
		} elsif ( $mod == ( km::Ctrl | km::Alt | km::Shift)) {
			$self-> {drag_color} = 'disabledBackColor';
		} elsif ( $mod == ( km::Ctrl | km::Shift)) {
			$self-> {drag_color} = 'hiliteColor';
		} elsif ( $mod == ( km::Alt | km::Shift)) {
			$self-> {drag_color} = 'hiliteBackColor';
		} elsif ( $mod & km::Ctrl) {
			$self-> {drag_color} = 'color';
		} elsif ( $mod & km::Alt) {
			$self-> {drag_color} = 'backColor';
		} else {
			$self-> notify( "MouseMove", $mod, $x, $y);
		}

		$owner-> notify( 'BeginDragColor', $self-> {drag_color})
			if $self-> {drag_color};
	}
}

sub Wheel_MouseMove
{
	my ( $owner, $self, $mod, $x, $y) = @_;
	return if !$self-> {mouseTransation} or $self-> {drag_color};
	my ( $h, $s, $ok) = xy2hs( $x-9, $y-9, 119);
	$owner-> {setTransaction} = 1;
	$owner-> {HSVPin} = Lum|Hue|Sat;
	$owner-> {H}-> value( int( $h));
	$owner-> {S}-> value( int( $s * 255));
	$owner-> value( rgb2value( hsv2rgb( int($h), $s, $owner-> {V}-> value/255)));
	$owner-> {HSVPin} = undef;
	$owner-> {setTransaction} = undef;
}

sub Wheel_MouseUp
{
	my ( $owner, $self, $btn, $mod, $x, $y) = @_;
	return unless $self-> {mouseTransation};
	$self-> {mouseTransation} = undef;
	$self-> capture(0);
	if ( $self-> {drag_color}) {
		$owner-> notify('EndDragColor', $self-> {drag_color},
			$::application-> get_widget_from_point( $self-> client_to_screen( $x, $y)));
		delete $self-> {drag_color};	 
	}
}

sub Roller_Paint
{
	my ( $owner, $self, $canvas) = @_;
	my @size = $self-> size;
	$canvas-> clear;
	my $i;
	my ( $h, $s, $v, $d) = ( $owner-> {H}-> value, $owner-> {S}-> value,
		$owner-> {V}-> value, ($size[1]-16) / 32);
	$s /= 255;
	$v /= 255;
	my ( $r, $g, $b);

	for $i (0..31) {
		( $r, $g, $b) = hsv2rgb( $h, $s, $i / 31);
		$canvas-> color( rgb2value( $r, $g, $b));
		$canvas-> bar( 8, 8 + $i * $d, $size[0] - 8, 8 + ($i + 1) * $d);
	}

	$canvas-> color( cl::Black);
	$canvas-> rectangle( 8, 8, $size[0] - 8, $size[1] - 8);
	$d = int( $v * ($size[1]-16));
	$canvas-> rectangle( 0, $d, $size[0]-1, $d + 15);
	$canvas-> color( $owner-> {value});
	$canvas-> bar( 1, $d + 1, $size[0]-2, $d + 14);
	$self-> {paintPoll} = 2 if exists $self-> {paintPoll};
}

sub Roller_Repaint
{
	my $owner = $_[0];
	my $roller = $owner-> {roller};
	if ( $owner-> {quality}) {
		my ( $h, $s, $v) = ( $owner-> {H}-> value, $owner-> {S}-> value, $owner-> {V}-> value);
		$s /= 255;
		$v /= 255;
		my ( $i, $r, $g, $b);
		my @pal;

		for ( $i = 0; $i < 32; $i++) {
			( $r, $g, $b) = hsv2rgb( $h, $s, $i / 31);
			push ( @pal, $b, $g, $r);
		}
		( $r, $g, $b) = value2rgb( $owner-> {value});
		push ( @pal, $b, $g, $r);

		$roller-> {paintPoll} = 1;
		$roller-> palette([@pal]);
		$roller-> repaint if $roller-> {paintPoll} != 2;
		delete $roller-> {paintPoll};
	} else {
		$roller-> repaint;
	}
}


sub Roller_MouseDown
{
	my ( $owner, $self, $btn, $mod, $x, $y) = @_;
	return if $self-> {mouseTransation};
	$self-> {mouseTransation} = 1;
	$self-> capture(1);
	$self-> notify( "MouseMove", $mod, $x, $y);
}

sub Roller_MouseMove
{
	my ( $owner, $self, $mod, $x, $y) = @_;
	return unless $self-> {mouseTransation};
	$owner-> {setTransaction} = 1;
	$owner-> {HSVPin} = Hue|Sat|Wheel|Roller;
	$owner-> value( rgb2value( hsv2rgb(
		$owner-> {H}-> value, $owner-> {S}-> value/255,
		($y - 8) / ( $self-> height - 16))));
	$owner-> {HSVPin} = undef;
	$owner-> {setTransaction} = undef;
	$self-> update_view;
}

sub Roller_MouseUp
{
	my ( $owner, $self, $btn, $mod, $x, $y) = @_;
	return unless $self-> {mouseTransation};
	$self-> {mouseTransation} = undef;
	$self-> capture(0);
}


sub set_quality
{
	my ( $self, $quality) = @_;
	return if $quality == $self-> {quality};
	$self-> {quality} = $quality;
	$self-> {roller}-> palette([]) unless $quality;
	$self-> Roller_Repaint;
}

sub set_value
{
	my ( $self, $value) = @_;
	return if $value == $self-> {value} and ! $self-> {HSVPin};
	$self-> {value} = $value;
	my $st = $self-> {setTransaction};
	$self-> {setTransaction} = 1;
	my $rgb = $self-> {RGBPin} || 0;
	my $hsv = $self-> {HSVPin} || 0;
	my ( $r, $g, $b) = value2rgb( $value);
	my ( $h, $s, $v) = rgb2hsv( $r, $g, $b);
	$s = int( $s*255);
	$v = int( $v*255);
	$self-> {R}-> value( $r) if $self-> {R} != $rgb;
	$self-> {G}-> value( $g) if $self-> {G} != $rgb;
	$self-> {B}-> value( $b) if $self-> {B} != $rgb;
	$self-> {H}-> value( int($h)) unless $hsv & Hue;
	$self-> {S}-> value( int($s)) unless $hsv & Sat;
	$self-> {V}-> value( int($v)) unless $hsv & Lum;
	$self-> {wheel}-> repaint unless $hsv & Wheel;
	if ( $hsv & Roller) {
		$self-> {roller}-> repaint;
	} else {
		$self-> Roller_Repaint;
	}
	$self-> {setTransaction} = $st;
	$self-> notify(q(Change));
}

sub value        {($#_)?$_[0]-> set_value        ($_[1]):return $_[0]-> {value};}
sub quality      {($#_)?$_[0]-> set_quality      ($_[1]):return $_[0]-> {quality};}

package Prima::ColorComboBox;
use vars qw(@ISA);
@ISA = qw(Prima::ComboBox);

{
my %RNT = (
	%{Prima::Widget-> notification_types()},
	Colorify => nt::Action,
);

sub notification_types { return \%RNT; }
}


sub profile_default
{
	my %sup = %{$_[ 0]-> SUPER::profile_default};
	my @std = Prima::Application-> get_default_scrollbar_metrics;
	return {
		%sup,
		style            => cs::DropDownList,
		height           => $sup{ editHeight},
		value            => cl::White,
		width            => 56,
		literal          => 0,
		colors           => 20 + 128,
		editClass        => 'Prima::Widget',
		listClass        => 'Prima::Widget',
		editProfile      => {
			selectingButtons => 0,
		},
		listProfile      => {
			width    => 78 + $std[0],
			height   => 130,
			growMode => 0,
		},
	};
}

sub profile_check_in
{
	my ( $self, $p, $default) = @_;
	$p-> { style} = cs::DropDownList;
	$self-> SUPER::profile_check_in( $p, $default);
}

sub init
{
	my $self    = shift;
	my %profile = @_;
	$self-> {value} = $profile{value};
	$self-> {colors} = $profile{colors};
	@{$profile{listDelegations}} = grep { $_ ne 'SelectItem' } @{$profile{listDelegations}};
	push ( @{$profile{listDelegations}}, qw(Create Paint MouseDown));
	push ( @{$profile{editDelegations}}, qw(Paint MouseDown Enter Leave Enable Disable KeyDown));
	%profile = $self-> SUPER::init(%profile);
	$self-> colors( $profile{colors});
	$self-> value( $profile{value});
	return %profile;
}

sub InputLine_KeyDown
{
	my ( $combo, $self, $code, $key) = @_;
	$combo-> listVisible(1), $self-> clear_event if $key == kb::Down;
	return if $key != kb::NoKey;
	$self-> clear_event;
}

sub InputLine_Paint
{
	my ( $combo, $self, $canvas, $w, $h, $focused) =
		($_[0],$_[1],$_[2],$_[1]-> size, $_[1]-> focused);
	my $back = $self-> enabled ? $self-> backColor : $self-> disabledBackColor;
	my $clr  = $combo-> value;
	$clr = $back if $clr == cl::Invalid;
	$canvas-> rect3d( 0, 0, $w-1, $h-1, 1, $self-> light3DColor, $self-> dark3DColor);
	$canvas-> color( $back);
	$canvas-> rectangle( 1, 1, $w - 2, $h - 2);
	$canvas-> rectangle( 2, 2, $w - 3, $h - 3);
	$canvas-> color( $clr);
	$canvas-> fillPattern([(0xEE, 0xBB) x 4]) unless $self-> enabled;
	$canvas-> bar( 3, 3, $w - 4, $h - 4);
	$canvas-> rect_focus(2, 2, $w - 3, $h - 3) if $focused;
}

sub InputLine_MouseDown
{
	# this code ( instead of listVisible(!listVisible)) is formed so because
	# ::InputLine is selectable, and unwilling focus() could easily hide
	# listBox automatically. Manual focus is also supported by
	# selectingButtons == 0.
	my ( $combo, $self)  = @_;
	my $lv = $combo-> listVisible;
	$combo-> listVisible(!$lv);
	$self-> focus if $lv;
	$self-> clear_event;
}

sub InputLine_Enable  { $_[1]-> repaint };
sub InputLine_Disable { $_[1]-> repaint };
sub InputLine_Enter   { $_[1]-> repaint; }

sub InputLine_Leave
{
	$_[0]-> listVisible(0) if $Prima::ComboBox::capture_mode;
	$_[1]-> repaint;
}


sub InputLine_MouseWheel
{
	my ( $self, $widget, $mod, $x, $y, $z) = @_;

	my $v = $self-> value;
	$z = $z / 120 * 16;
	my ( $r, $g, $b) = ( $v >> 16, ($v >> 8) & 0xff, $v & 0xff);
	if ( $mod & km::Shift) {
		$r += $z;
	} elsif ( $mod & km::Ctrl) {
		$g += $z;
	} elsif ( $mod & km::Alt) {
		$b += $z;
	} else {
		$r += $z;
		$g += $z;
		$b += $z;
	}
	for ( $r, $g, $b) {
		$_ = 0 if $_ < 0;
		$_ = 255 if $_ > 255;
	}
	$self-> value( $r * 65536 + $g * 256 + $b);
	$widget-> clear_event;
}

sub List_Create
{
	my ($combo,$self) = @_;
	$combo-> {btn} = $self-> insert( Button =>
		origin     => [ 3, 3],
		width      => $self-> width - 6,
		height     => 28,
		text       => '~More...',
		selectable => 0,
		name       => 'MoreBtn',
		onClick    => sub { $combo-> MoreBtn_Click( @_)},
	);
	
	my $c = $combo-> colors;
	$combo-> {scr} = $self-> insert( ScrollBar =>
		origin     => [ 75, $combo-> {btn}-> height + 8],
		top        => $self-> height - 3,
		vertical   => 1,
		name       => 'Scroller',
		max        => $c > 20 ? $c - 20 : 0,
		partial    => 20,
		step       => 4,
		pageStep   => 20,
		whole      => $c,
		delegations=> [ $combo, 'Change'],
	);
}


sub List_Paint
{
	my ( $combo, $self, $canvas) = @_;
	my ( $w, $h) = $self-> size;
	my @c3d = ( $self-> light3DColor, $self-> dark3DColor);
	$canvas-> rect3d( 0, 0, $w-1, $h-1, 1, @c3d, cl::Back)
		unless exists $self-> {inScroll};
	my $i;
	my $pc = 18;
	my $dy = $combo-> {btn}-> height;

	my $maxc = $combo-> colors;
	my $shft = $combo-> {scr}-> value;
	for ( $i = 0; $i < 20; $i++) {
		next if $i >= $maxc;
		my ( $x, $y) = (($i % 4) * $pc + 3, ( 4 - int( $i / 4)) * $pc + 9 + $dy);
		my $clr = 0;
		$combo-> notify('Colorify', $i + $shft, \$clr);
		$canvas-> rect3d( $x, $y, $x + $pc - 2, $y + $pc - 2, 1, @c3d, $clr);
	}
}

sub List_MouseDown
{
	my ( $combo, $self, $btn, $mod, $x, $y) = @_;
	$x -= 3;
	$y -= $combo-> {btn}-> height + 9;
	return if $x < 0 || $y < 0;
	$x = int($x / 18);
	$y = int($y / 18);
	return if $x > 3 || $y > 4;
	$y = 4 - $y;
	$combo-> listVisible(0);
	my $shft = $combo-> {scr}-> value;
	my $maxc = $combo-> colors;
	my $xcol = $shft + $x + $y * 4;
	return if $xcol >= $maxc;
	my $xval = 0;
	$combo-> notify('Colorify', $xcol, \$xval);
	$combo-> value( $xval);
}

sub MoreBtn_Click
{
	my ($combo,$self) = @_;
	my $d;
	$combo-> listVisible(0);
	$d = Prima::ColorDialog-> create(
		text  => 'Mixed color palette',
		value => $combo-> value,
	);
	$combo-> value( $d-> value) if $d-> execute != mb::Cancel;
	$d-> destroy;
}

sub Scroller_Change
{
	my ($combo,$self) = @_;
	$self = $combo-> List;
	$self-> {inScroll} = 1;
	$self-> invalidate_rect(
		4, $combo-> {btn}-> top+6,
		$self-> width - $combo-> {scr}-> width,
		$self-> height - 3,
	);
	delete $self-> {inScroll};
}


sub set_style { $_[0]-> raise_ro('set_style')}

sub set_value
{
	my ( $self, $value) = @_;
	return if $value == $self-> {value};
	$self-> {value} = $value;
	$self-> notify(q(Change));
	$self-> {edit}-> repaint;
}

sub set_colors
{
	my ( $self, $value) = @_;
	return if $value == $self-> {colors};
	$self-> {colors} = $value;
	my $scr = $self-> {list}-> {scr};
	$scr-> set(
		max        => $value > 20 ? $value - 20 : 0,
		whole      => $value,
	) if $scr;
	$self-> {list}-> repaint;
}


my @palColors = (
	0xffffff,0x000000,0xc6c3c6,0x848284,
	0xff0000,0x840000,0xffff00,0x848200,
	0x00ff00,0x008200,0x00ffff,0x008284,
	0x0000ff,0x000084,0xff00ff,0x840084,
	0xc6dfc6,0xa5cbf7,0xfffbf7,0xa5a2a5,
);


sub on_colorify
{
	my ( $self, $index, $sref) = @_;
	if ( $index < 20) {
		$$sref = $palColors[ $index];
	} else {
		my $i = $index - 20;
		my ( $r, $g, $b);
		if ( $i < 64) {
			( $r, $g, $b) = Prima::ColorDialog::hsv2rgb( 
				$i * 4, 0.25 + ($i % 4) * 0.25, 1
			);
		} else {
			( $r, $g, $b) = Prima::ColorDialog::hsv2rgb( 
				$i * 4, 1, 0.25 + ($i % 4) * 0.25
			);
		}
		$$sref = $b | $g << 8 | $r << 16;
	}
	$self-> clear_event;
}


sub value        {($#_)?$_[0]-> set_value       ($_[1]):return $_[0]-> {value};  }
sub colors       {($#_)?$_[0]-> set_colors      ($_[1]):return $_[0]-> {colors};  }


1;

__DATA__

=pod

=head1 NAME

Prima::ColorDialog - standard color selection facilities

=head1 SYNOPSIS

	use Prima qw(StdDlg Application);

	my $p = Prima::ColorDialog-> create(
		quality => 1,
	);
	printf "color: %06x", $p-> value if $p-> execute == mb::OK;

=head1 DESCRIPTION

The module contains two packages, C<Prima::ColorDialog> and C<Prima::ColorComboBox>,
used as standard tools for interactive color selection. C<Prima::ColorComboBox> is
a modified combo widget, which provides selecting from predefined palette but also can
invoke C<Prima::ColorDialog> window.

=head1 Prima::ColorDialog

=head2 Properties

=over

=item quality BOOLEAN

Used to increase visual quality of the dialog if run on paletted displays.

Default value: 0

=item value COLOR

Selects the color, represented by the color wheel and other dialog controls.

Default value: C<cl::White>

=back

=head2 Methods

=over

=item hsv2rgb HUE, SATURATION, LUMINOSITY

Converts color from HSV to RGB format and returns three integer values, red, green,
and blue components.

=item rgb2hsv RED, GREEN, BLUE

Converts color from RGB to HSV format and returns three numerical values, hue, saturation,
and luminosity components.

=item rgb2value RED, GREEN, BLUE

Combines separate channels into single 24-bit RGB value and returns the result.

=item value2rgb COLOR

Splits 24-bit RGB value into three channels, red, green, and blue and returns
three integer values.

=item xy2hs X, Y, RADIUS

Maps X and Y coordinate values onto a color wheel with RADIUS in pixels.
The code uses RADIUS = 119 for mouse position coordinate mapping.
Returns three values, - hue, saturation and error flag. If error flag
is set, the conversion has failed.

=item hs2xy HUE, SATURATION

Maps hue and saturation onto 256-pixel wide color wheel, and
returns X and Y coordinates of the corresponding point.

=item create_wheel SHADES, BACK_COLOR

Creates a color wheel with number of SHADES given,
drawn on a BACK_COLOR background, and returns a C<Prima::DeviceBitmap> object.

=item create_wheel_shape SHADES

Creates a circular 1-bit mask, with radius derived from SHAPES.
SHAPES must be same as passed to L<create_wheel>.
Returns C<Prima::Image> object.

=back

=head2 Events

=over

=item BeginDragColor $PROPERTY

Called when the user starts dragginh a color from the color wheel by with left
mouse button and combination of Alt, Ctrl, and Shift keys. $PROPERTY is one
of C<Prima::Widget> color properties, and depends on combination of keys:

	Alt              backColor
	Ctrl             color
	Alt+Shift        hiliteBackColor
	Ctrl+Shift       hiliteColor
	Ctrl+Alt         disabledColor
	Ctrl+Alt+Shift   disabledBackColor

Default action reflects the property to be changes in the dialog title

=item Change

The notification is called when the L<value> property is changed, either 
interactively or as a result of direct call.

=item EndDragColor $PROPERTY, $WIDGET

Called when the user releases the mouse drag over a Prima widget.
Default action sets C<< $WIDGET->$PROPERTY >> to the current color value.

=back

=head2 Variables

=over

=item $colorWheel

Contains cached result of L<create_wheel> call.

=item $colorWheelShape

Contains cached result of L<create_wheel_shape> call.

=back

=head1 Prima::ColorComboBox

=head2 Events

=over

=item Colorify INDEX, COLOR_PTR

C<nt::Action> callback, designed to map combo palette index into a RGB color.
INDEX is an integer from 0 to L<colors> - 1, COLOR_PTR is a reference to a
result scalar, where the notification is expected to write the resulting color.

=back

=head2 Properties

=over

=item colors INTEGER

Defines amount of colors in the fixed palette of the combo box.

=item value COLOR

Contains the color selection as 24-bit integer value.

=back

=head1 SEE ALSO

L<Prima>, L<Prima::ComboBox>, F<examples/cv.pl>.

=head1 AUTHOR

Dmitry Karasik, E<lt>dmitry@karasik.eu.orgE<gt>.

=cut
