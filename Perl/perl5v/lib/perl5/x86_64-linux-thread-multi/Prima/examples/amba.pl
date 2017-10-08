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
#  $Id$
#
use Prima 'MsgBox', Application => { name => 'Chess puzzle' };

=pod

=head1 NAME

examples/amba.pl - A chess puzzle

=head1 FEATURES

Demonstrates custom pointer creation

=cut

use strict;
use warnings;

# binhex and rle crunched data from 5 40x40 1-bit images
my $d = <<DATA;
rrrrrj1w8l1w8l1w8l1w8l1w8jj1w8l1w8mwnwn7uekk3uen3ucn1u8oe7o1e78kk3e7cn7e
7en7e7en6j6n6j6kk7e7en7e7en3e7cn1e78o66ll7epc3pdbpdbp66ll66p3cp18rrlrrrr
k1uckj1wcl7xl67v3l7iu87l7tj7tjj63ue3l78ktl7xl7xlcw98ii1aiu82cj27ej3t2j5u
ebudjbuebue8i3uc9uei17uddv417u94v417ub6v4i7u6b7ujbteebbte8i4t9ddct9j3i65
d3i6kt85dit8m5dp5dll22p1cq8q8q8lm8p3eq8q8rlrrrrk7x8k7we8k7wc8k3wc8k3wc8k
1wc8k1wc8lwc8j4i7vc8i3ei3vcj7ti1vdiitb81vdjdtciv9jcteiv9jcu87u9j7ue7uaii
7v7u2j3y2j3vbu6j1xe4kxe4ijxc8k6wc8k67v9l73vbl79v6jj3vecl3v98l1c7c7nvcm1t
78lj1e78n1c3o1i3rrmrrrk3uemy8ii1yck7x8ky8k7xl23ue2jj7cj1tl7xl7xlc1uc18kt
cj1t8ii1ycj3yej3yej7yej7zii7zj7dtbetdtj79tbetctj79t3e7ctj71t3e7c7iit1t3e
7c78ieie1c3838icie1c3818icie1c381838ic1c18ie7cic1c181t7ci8i8i81t7c1ci81c
1t383e1c3eiej3e3e3ejj3e3e3el1c3e1cn1crrlrrrrri1ycj1ycj1ycj1cl1ck3xjj3xl2
l3l3xl1wemcj18jk7vn7vn7vn7vn7vkk7vn7vn7vn7vn7vkk7vn7vn4j1nwm1wcjrj7xl7xl
7xl7c3e1tjj7c3e1tl7c3e1trrrj
DATA
$d =~ s/\n//g;
$d =~ s/([h-r])/q(0)x(ord($1)-ord('h'))/ge;
$d =~ s/([s-z])/q(f)x(ord($1)-ord('s'))/ge;
$d =~ s/(..)/chr hex qq(0x$1)/ge;
#
my @images = map { Prima::Image-> create(
	width    => 40,
	height   => 40,
	type     => im::BW,
	data     => $_,
	lineSize => 5,
)-> bitmap } grep { length } split "(.{200})", $d;

# figures mnemonic names ( incorrect :)
my %figs = (
	'K' => [0,0],
	'B1' => [0,1],
	'B2' => [0,2],
	'Q'  => [0,3],
	'T1' => [0,4],
	'T2' => [0,5],
	'R1' => [0,6],
	'R2' => [0,7],
);

my %images = (
	'K'  => $images[1],
	'B1' => $images[0], 
	'B2' => $images[0], 
	'Q'  => $images[3], 
	'T1' => $images[4], 
	'T2' => $images[4], 
	'R1' => $images[2], 
	'R2' => $images[2], 
);

# colors shade the degree of fugure coverage
my @colors = (
	0x808080,
	0x707070,
	0x606060,
	0x505050,
	0x404040,
	0x303030,
	0x202020,
	0x101010,
	0x000000,
);

my @pointer= map { 
	$::application-> get_system_value( $_ )
} sv::XPointer, sv::YPointer;
$pointer[$_] = ( $pointer[$_] - 40 ) / 2 for 0,1;

my $w = Prima::MainWindow-> create(
	name => 'Chess puzzle',
	size => [ 360, 360],
	font => { style => fs::Bold, size => 11,},
	buffered => 1,
	menuItems => [
		["~Help" => sub{
			Prima::MsgBox::message( 
				'Chess puzzle. Objective is to put figures so they could reach every cell upon the board',
				mb::OK | mb::Cancel,
				buttons => { mb::Cancel , {
					text => '~Solution',
					onClick => sub {
						Prima::MsgBox::message(
							'Use Ctrl + mouse doubleclick on the board ', 
							mb::OK
						);
					}
				}}
			);
		}],
	],
	onPaint => sub {
		my $self = $_[0];
		my $i;
		$self-> color( cl::Back);
		$self-> bar ( 0, 0, $self-> size);
		$self-> color( cl::Black);
		for ( $i = 0; $i < 9; $i++) {
			$self-> line( $i * 40, 0, $i * 40, 40 * 8);
			$self-> line( 0, $i * 40, 40 * 8, $i * 40);
		}
		my @boy = (0) x 64;
		my @busy = (0) x 64;
		for ( keys %figs) {
			my ($x,$y) = @{$figs{$_}};
			$busy[$y*8+$x] = 1;
		}
		my $add = sub {
			my ($x,$y) = @_;
			if ( $x >= 0 && $x < 8 && $y >= 0 && $y < 8) {
				$boy[$y*8+$x] += 1;
				return !$busy[$y*8+$x];
			} else {
				return 0;
			}
		};
		for ( keys %figs) {
			my ( $x, $y) = @{$figs{$_}};
			next unless $x >= 0 && $x < 8 && $y >= 0 && $y < 8;
			if ($_ eq 'K') {
				$add-> ($x-1,$y-1);
				$add-> ($x-1,$y);
				$add-> ($x-1,$y+1);
				$add-> ($x,$y-1);
				$add-> ($x,$y+1);
				$add-> ($x+1,$y-1);
				$add-> ($x+1,$y);
				$add-> ($x+1,$y+1);
			} elsif ($_ eq 'Q') {
				for (1..7) { last unless $add-> ($x-$_,$y); }
				for (1..7) { last unless $add-> ($x+$_,$y); }
				for (1..7) { last unless $add-> ($x,$y-$_); }
				for (1..7) { last unless $add-> ($x,$y+$_); }
				for (1..7) { last unless $add-> ($x-$_,$y-$_); }
				for (1..7) { last unless $add-> ($x-$_,$y+$_); }
				for (1..7) { last unless $add-> ($x+$_,$y-$_); }
				for (1..7) { last unless $add-> ($x+$_,$y+$_); }
			} elsif (/^T\d$/) {
				for (1..7) { last unless $add-> ($x-$_,$y); }
				for (1..7) { last unless $add-> ($x+$_,$y); }
				for (1..7) { last unless $add-> ($x,$y-$_); }
				for (1..7) { last unless $add-> ($x,$y+$_); }
			} elsif (/^B\d$/) {
				for (1..7) { last unless $add-> ($x-$_,$y-$_); }
				for (1..7) { last unless $add-> ($x-$_,$y+$_); }
				for (1..7) { last unless $add-> ($x+$_,$y-$_); }
				for (1..7) { last unless $add-> ($x+$_,$y+$_); }
			} elsif (/^R\d$/) {
				$add-> ($x-1,$y-2);
				$add-> ($x-1,$y+2);
				$add-> ($x-2,$y-1);
				$add-> ($x-2,$y+1);
				$add-> ($x+1,$y-2);
				$add-> ($x+1,$y+2);
				$add-> ($x+2,$y-1);
				$add-> ($x+2,$y+1);
			}
		}
		for ( grep $boy[$_], 0..63) {
			my ( $x, $y) = ($_ % 8, int($_/8));
			$self-> color( $colors[$boy[$_]] );
			$self-> bar( $x * 40+1, $y * 40+1, $x * 40+39, $y * 40+39);
		}
		
		for ( keys %figs) {
			my ( $x, $y) = @{$figs{$_}};
			$self-> set(
				color     => cl::White,
				backColor => cl::Black,
				rop       => rop::AndPut,
			);
			$self-> put_image( $x * 40, $y * 40, $images{$_});
			$self-> set(
				color     => cl::Black,
				backColor => $boy[ $y * 8 + $x] ? cl::LightGreen : cl::Green,
				rop       => rop::XorPut,
			);
			$self-> put_image( $x * 40, $y * 40, $images{$_});
		}
	},
	onMouseDown => sub {
		my ( $self, $btn, $mod, $x, $y) = @_;
		return if $self-> {cap};
		$x = int( $x / 40);
		$y = int( $y / 40);
		return if $x < 0 || $x > 8 || $y < 0 || $y > 8;
		my $i = '';
		for ( keys %figs) {
			my ( $ax, $ay) = @{$figs{$_}};
			$i = $_, last if $ax == $x and $ay == $y;
		}
		return unless $i;
		$self-> {cap} = $i;
		$self-> capture(1);
		$self-> pointer( cr::Size);
		my $xx = $self-> pointerIcon;
		my ( $xor, $and) = $xx-> split;

		$and-> begin_paint;
		$and-> rop( rop::NotSrcAnd);
		$and-> put_image( @pointer, $images{$i});
		$and-> end_paint;

		$xor-> begin_paint;
		$xor-> set(
			color      => cl::Black,
			backColor  => $::application-> get_system_value( sv::ColorPointer) ? 
					cl::Green : cl::White, 
			rop        => rop::OrPut,
		);
		$xor-> put_image( @pointer, $images{$i});
		$xor-> end_paint;

		$xx-> combine( $xor, $and);
		$self-> pointer( $xx);
	},
	onMouseUp => sub {
		my ( $self, $btn, $mod, $x, $y) = @_;
		return unless $self-> {cap};
		$x = int( $x / 40);
		$y = int( $y / 40);
		$self-> capture(0);
		$self-> pointer( cr::Default);
		my $fg = $self-> {cap};
		delete $self-> {cap};
		return if $x < 0 || $x > 8 || $y < 0 || $y > 8;
		my $i = '';
		for ( keys %figs) {
			my ( $ax, $ay) = @{$figs{$_}};
			$i = $_, last if $ax == $x and $ay == $y;
		}
		return if $i;
		$figs{$fg} = [ $x, $y];
		$self-> repaint;
	},
	onMouseClick => sub {
		my ( $self, $btn, $mod, $x, $y, $dbl) = @_;
		if ( $dbl and ( $mod & km::Ctrl)) {
			%figs = (
				'K'  => [2,5],
				'B1' => [5,5],
				'B2' => [2,2],
				'Q'  => [5,2],
				'T1' => [7,7],
				'T2' => [0,0],
				'R1' => [4,4],
				'R2' => [3,3],
			);
			$self-> repaint;
		}
	},
);


run Prima;
