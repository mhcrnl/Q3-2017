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
#  $Id$
#
package Prima::PS::Drawable;
use vars qw(@ISA);
@ISA = qw(Prima::Drawable);

use strict;
use Prima;
use Prima::PS::Fonts;
use Prima::PS::Encodings;
use Encode;


{
my %RNT = (
	%{Prima::Drawable-> notification_types()},
	Spool => nt::Action,
);

sub notification_types { return \%RNT; }
}


sub profile_default
{
	my $def = $_[ 0]-> SUPER::profile_default;
	my %prf = (
		copies           => 1,
		font             => {
			%{$def-> {font}},
			name => $Prima::PS::Fonts::defaultFontName,
		},
		grayscale        => 0,
		pageDevice       => undef,
		pageSize         => [ 598, 845],
		pageMargins      => [ 12, 12, 12, 12],
		resolution       => [ 300, 300],
		reversed         => 0,
		rotate           => 0,
		scale            => [ 1, 1],
		isEPS            => 0,
		textOutBaseline  => 0,
		useDeviceFonts   => 1,
		useDeviceFontsOnly => 0,
	);
	@$def{keys %prf} = values %prf;
	return $def;
}

sub profile_check_in
{
	my ( $self, $p, $default) = @_;
	Prima::Component::profile_check_in( $self, $p, $default);
	$p-> { font} = {} unless exists $p-> { font};
	$p-> { font} = Prima::Drawable-> font_match( $p-> { font}, $default-> { font}, 0);
}

sub init
{
	my $self = shift;
	$self-> {clipRect}    = [0,0,0,0];
	$self-> {pageSize}    = [0,0];
	$self-> {pageMargins} = [0,0,0,0];
	$self-> {resolution}  = [72,72];
	$self-> {scale}       = [ 1, 1];
	$self-> {isEPS}       = 0;
	$self-> {copies}      = 1;
	$self-> {rotate}      = 1;
	$self-> {font}        = {};
	$self-> {useDeviceFonts} = 1;
	my %profile = $self-> SUPER::init(@_);
	$self-> $_( $profile{$_}) for qw( grayscale copies pageDevice 
		useDeviceFonts rotate reversed useDeviceFontsOnly isEPS);
	$self-> $_( @{$profile{$_}}) for qw( pageSize pageMargins resolution scale );
	$self-> {localeEncoding} = [];
	$self-> set_font($profile{font}); # update to the changed resolution, device fonts etc
	return %profile;
}

# internal routines

sub cmd_rgb
{
	my ( $r, $g, $b) = (
		int((($_[1] & 0xff0000) >> 16) * 100 / 256 + 0.5) / 100, 
		int((($_[1] & 0xff00) >> 8) * 100 / 256 + 0.5) / 100, 
		int(($_[1] & 0xff)*100/256 + 0.5) / 100);
	unless ( $_[0]-> {grayscale}) {
		return "$r $g $b A";
	} else {
		my $i = int( 100 * ( 0.31 * $r + 0.5 * $g + 0.18 * $b) + 0.5) / 100;
		return "$i G";
	}
}

sub emit
{
	my $self = $_[0];
	return 0 unless $self-> {canDraw};
	$self-> {psData} .= $_[1] . "\n";
	if ( length($self-> {psData}) > 10240) {
		$self-> abort_doc unless $self-> spool( $self-> {psData});
		$self-> {psData} = '';
	}
	return 1;
}

sub save_state
{
	my $self = $_[0];
	
	$self-> {saveState} = {};
	if ($self-> {useDeviceFonts}) {
		# force-fill font data
		my $f = $self->get_font;
		delete $f->{size} if exists $f->{height} and exists $f->{size};
		$self-> set_font( $f );
	}
	$self-> {saveState}-> {$_} = $self-> $_() for qw( 
		color backColor fillPattern lineEnd linePattern lineWidth
		rop rop2 textOpaque textOutBaseline font lineJoin fillWinding
	);
	delete $self->{saveState}->{font}->{size};
	$self-> {saveState}-> {$_} = [$self-> $_()] for qw( 
		translate clipRect
	);
	$self-> {saveState}-> {localeEncoding} = 
		$self-> {useDeviceFonts} ? [ @{$self-> {localeEncoding}}] : [];
}

sub restore_state
{
	my $self = $_[0];
	for ( qw( color backColor fillPattern lineEnd linePattern lineWidth
			rop rop2 textOpaque textOutBaseline font lineJoin fillWinding)) {
		$self-> $_( $self-> {saveState}-> {$_});     
	}      
	for ( qw( translate clipRect)) {
		$self-> $_( @{$self-> {saveState}-> {$_}});
	}      
	$self-> {localeEncoding} = $self-> {saveState}-> {localeEncoding};
}

sub pixel2point
{
	my $self = shift;
	my $i;
	my @res;
	for ( $i = 0; $i < scalar @_; $i+=2) {
		my ( $x, $y) = @_[$i,$i+1];
		push( @res, int( $x * 7227 / $self-> {resolution}-> [0] + 0.5) / 100 );
		push( @res, int( $y * 7227 / $self-> {resolution}-> [1] + 0.5) / 100 ) if defined $y;
	}
	return @res;
}

sub point2pixel
{
	my $self = shift;
	my $i;
	my @res;
	for ( $i = 0; $i < scalar @_; $i+=2) {
		my ( $x, $y) = @_[$i,$i+1];
		push( @res, $x * $self-> {resolution}-> [0] / 72.27);
		push( @res, $y * $self-> {resolution}-> [1] / 72.27) if defined $y;
	}
	return @res;
}


sub change_transform
{
	return if $_[0]-> {delay};
	
	my @tp = $_[0]-> translate;
	my @cr = $_[0]-> clipRect;
	my @sc = $_[0]-> scale;
	my $ro = $_[0]-> rotate;
	$cr[2] -= $cr[0];
	$cr[3] -= $cr[1];
	my $doClip = grep { $_ != 0 } @cr;
	my $doTR   = grep { $_ != 0 } @tp; 
	my $doSC   = grep { $_ != 0 } @sc; 

	if ( !$doClip && !$doTR && !$doSC && !$ro) {
		$_[0]-> emit(':') if $_[1];
		return;
	}

	@cr = $_[0]-> pixel2point( @cr);
	@tp = $_[0]-> pixel2point( @tp);
	my $mcr3 = -$cr[3];
	
	$_[0]-> emit(';') unless $_[1];
	$_[0]-> emit(':');
	$_[0]-> emit(<<CLIP) if $doClip;
N $cr[0] $cr[1] M 0 $cr[3] L $cr[2] 0 L 0 $mcr3 L X C
CLIP
	$_[0]-> emit("@tp T") if $doTR;
	$_[0]-> emit("@sc Z") if $doSC;
	$_[0]-> emit("$ro R") if $ro != 0;
	$_[0]-> {changed}-> {$_} = 1 for qw(fill linePattern lineWidth lineJoin lineEnd font);
}

sub fill
{
	my ( $self, $code) = @_;
	my ( $r1, $r2) = ( $self-> rop, $self-> rop2);
	return if 
		$r1 == rop::NoOper &&
		$r2 == rop::NoOper;
	
	if ( $r2 != rop::NoOper && $self-> {fpType} ne 'F') {
		my $bk = 
			( $r2 == rop::Blackness) ? 0 :
			( $r2 == rop::Whiteness) ? 0xffffff : $self-> backColor;
		
		$self-> {changed}-> {fill} = 1;
		$self-> emit( $self-> cmd_rgb( $bk)); 
		$self-> emit( $code);
	}
	if ( $r1 != rop::NoOper && $self-> {fpType} ne 'B') {
		my $c = 
			( $r1 == rop::Blackness) ? 0 :
			( $r1 == rop::Whiteness) ? 0xffffff : $self-> color;
		if ($self-> {changed}-> {fill}) {
			if ( $self-> {fpType} eq 'F') {
				$self-> emit( $self-> cmd_rgb( $c));
			} else {
				my ( $r, $g, $b) = (
					int((($c & 0xff0000) >> 16) * 100 / 256 + 0.5) / 100, 
					int((($c & 0xff00) >> 8) * 100 / 256 + 0.5) / 100, 
					int(($c & 0xff)*100/256 + 0.5) / 100);
				if ( $self-> {grayscale}) {
					my $i = int( 100 * ( 0.31 * $r + 0.5 * $g + 0.18 * $b) + 0.5) / 100; 
					$self-> emit(<<GRAYPAT);
[\/Pattern \/DeviceGray] SS
$i Pat_$self->{fpType} SC
GRAYPAT
				} else {
					$self-> emit(<<RGBPAT);
[\/Pattern \/DeviceRGB] SS
$r $g $b Pat_$self->{fpType} SC
RGBPAT
				}
			}
			$self-> {changed}-> {fill} = 0;
		}
		$self-> emit( $code);
	}
}

sub stroke
{
	my ( $self, $code) = @_; 

	my ( $r1, $r2) = ( $self-> rop, $self-> rop2);
	my $lp = $self-> linePattern;
	return if 
		$r1 == rop::NoOper &&
		$r2 == rop::NoOper;

	if ( $self-> {changed}-> {lineWidth}) {
		my ($lw) = $self-> pixel2point($self-> lineWidth);
		$self-> emit( $lw . ' SW');
		$self-> {changed}-> {lineWidth} = 0;
	}

	if ( $self-> {changed}-> {lineEnd}) { 
		my $le = $self-> lineEnd;
		my $id = ( $le == le::Round) ? 1 : (( $le == le::Square) ? 2 : 0);
		$self-> emit( "$id SL");
		$self-> {changed}-> {lineEnd} = 0;
	}
	
	if ( $self-> {changed}-> {lineJoin}) { 
		my $lj = $self-> lineJoin;
		my $id = ( $lj == lj::Round) ? 1 : (( $lj == lj::Bevel) ? 2 : 0);
		$self-> emit( "$id SJ");
		$self-> {changed}-> {lineJoin} = 0;
	}

	if ( $r2 != rop::NoOper && $lp ne lp::Solid ) {
		my $bk = 
			( $r2 == rop::Blackness) ? 0 :
			( $r2 == rop::Whiteness) ? 0xffffff : $self-> backColor;
		
		$self-> {changed}-> {linePattern} = 1;
		$self-> {changed}-> {fill}        = 1;
		$self-> emit('[] 0 SD');
		$self-> emit( $self-> cmd_rgb( $bk)); 
		$self-> emit( $code);
	}
	
	if ( $r1 != rop::NoOper && length( $lp)) {
		my $fk = 
			( $r1 == rop::Blackness) ? 0 :
			( $r1 == rop::Whiteness) ? 0xffffff : $self-> color;
			
		if ( $self-> {changed}-> {linePattern}) {
			if ( length( $lp) == 1) {
				$self-> emit('[] 0 SD');
			} else {
				my @x = split('', $lp);
				push( @x, 0) if scalar(@x) % 1;
				@x = map { ord($_) } @x;
				$self-> emit("[@x] 0 SD");
			}
			$self-> {changed}-> {linePattern} = 0;
		}

		if ( $self-> {changed}-> {fill}) {
			$self-> emit( $self-> cmd_rgb( $fk));
			$self-> {changed}-> {fill} = 0;
		}
		$self-> emit( $code);
	}
}

# Prima::Printer interface

sub begin_doc
{
	my ( $self, $docName) = @_;
	return 0 if $self-> get_paint_state;
	$self-> {psData}  = '';
	$self-> {canDraw} = 1;

	$docName = $::application ? $::application-> name : "Prima::PS::Drawable"
		unless defined $docName;
	my $data = scalar localtime;
	my @b2 = (
		int($self-> {pageSize}-> [0] - $self-> {pageMargins}-> [2] + .5),
		int($self-> {pageSize}-> [1] - $self-> {pageMargins}-> [3] + .5)
	);
	
	$self-> {fpHash}  = {};
	$self-> {pages}   = 1;

	my ($x,$y) = (
		$self-> {pageSize}-> [0] - $self-> {pageMargins}-> [0] - $self-> {pageMargins}-> [2],
		$self-> {pageSize}-> [1] - $self-> {pageMargins}-> [1] - $self-> {pageMargins}-> [3]
	);

	my $extras = '';
	my $setup = '';
	my %pd = defined( $self-> {pageDevice}) ? %{$self-> {pageDevice}} : ();
	
	if ( $self-> {copies} > 1) {
		$pd{NumCopies} = $self-> {copies};
		$extras .= "\%\%Requirements: numcopies($self->{copies})\n";
	}
	
	if ( scalar keys %pd) {
		my $jd = join( "\n", map { "/$_ $pd{$_}"} keys %pd);
		$setup .= <<NUMPAGES; 
%%BeginFeature
<< $jd >> SPD
%%EndFeature
NUMPAGES
	}
	$self-> {localeData} = {};
	$self-> {fontLocaleData} = {};

	my $header = "%!PS-Adobe-2.0";
	$header .= " EPSF-2.0" if $self->isEPS;
	
	$self-> emit( <<PSHEADER);
$header
%%Title: $docName
%%Creator: Prima::PS::Drawable
%%CreationDate: $data
%%Pages: (atend)
%%BoundingBox: @{$self->{pageMargins}}[0,1] @b2
$extras
%%LanguageLevel: 2
%%DocumentNeededFonts: (atend)
%%DocumentSuppliedFonts: (atend)
%%EndComments

/d/def load def/,/load load d/~/exch , d/S/show , d/:/gsave , d/;/grestore ,
d/N/newpath , d/M/moveto , d/L/rlineto , d/X/closepath , d/C/clip ,
d/T/translate , d/R/rotate , d/P/showpage , d/Z/scale , d/I/imagemask ,
d/@/dup , d/G/setgray , d/A/setrgbcolor , d/l/lineto , d/F/fill ,
d/FF/findfont , d/XF/scalefont , d/SF/setfont , 
d/O/stroke , d/SD/setdash , d/SL/setlinecap , d/SW/setlinewidth , 
d/SJ/setlinejoin , d/E/eofill , 
d/SS/setcolorspace , d/SC/setcolor , d/SM/setmatrix , d/SPD/setpagedevice ,
d/SP/setpattern , d/CP/currentpoint , d/MX/matrix , d/MP/makepattern , 
d/b/begin , d/e/end , d/t/true , d/f/false , d/?/ifelse , d/a/arc ,
d/dummy/_dummy

%%BeginSetup
$setup
%%EndSetup

%%Page: 1 1
PSHEADER

	$self-> {pagePrefix} = <<PREFIX;
@{$self->{pageMargins}}[0,1] T
N 0 0 M 0 $y L $x 0 L 0 -$y L X C
PREFIX

	$self-> {pagePrefix} .= "0 0 M 90 R 0 -$x T\n" if $self-> {reversed};

	$self-> {changed} = { map { $_ => 0 } qw(
		fill lineEnd linePattern lineWidth lineJoin font)};
	$self-> {docFontMap} = {};
	
	$self-> SUPER::begin_paint;
	$self-> save_state;
	
	$self-> {delay} = 1;
	$self-> restore_state;
	$self-> {delay} = 0;
	
	$self-> emit( $self-> {pagePrefix});
	$self-> change_transform( 1);
	$self-> {changed}-> {linePattern} = 0; 
	
	return 1;
}

sub abort_doc
{
	my $self = $_[0];
	return unless $self-> {canDraw};
	$self-> {canDraw} = 0; 
	$self-> SUPER::end_paint;
	$self-> restore_state;
	delete $self-> {$_} for 
		qw (saveState localeData psData changed fontLocaleData pagePrefix);
	$self-> {plate}-> destroy, $self-> {plate} = undef if $self-> {plate};
}

sub end_doc
{
	my $self = $_[0];
	return 0 unless $self-> {canDraw};
	$self-> emit(<<PSFOOTER);
; P

%%Trailer
%%DocumentNeededFonts:
%%DocumentSuppliedFonts:
%%Pages: $_[0]->{pages}
%%EOF
PSFOOTER

	# if ( $self-> {locale}) {
	# 	my @z = map { '/' . $_ } keys %{$self-> {docFontMap}};
	# 	my $xcl = "/FontList [@z] d\n";
	# }
	
	my $ret = $self-> spool( $self-> {psData});
	$self-> {canDraw} = 0; 
	$self-> SUPER::end_paint;
	$self-> restore_state;
	delete $self-> {$_} for 
		qw (saveState localeData changed fontLocaleData psData pagePrefix);
	$self-> {plate}-> destroy, $self-> {plate} = undef if $self-> {plate};
	return $ret;
}

# Prima::Drawable interface

sub begin_paint { return $_[0]-> begin_doc; }
sub end_paint   {        $_[0]-> abort_doc; }

sub begin_paint_info
{
	my $self = $_[0];
	return 0 if $self-> get_paint_state;
	my $ok = $self-> SUPER::begin_paint_info;
	return 0 unless $ok;
	$self-> save_state;
}

sub end_paint_info
{
	my $self = $_[0];
	return if $self-> get_paint_state != ps::Information;
	$self-> SUPER::end_paint_info;
	$self-> restore_state;
}

sub new_page
{
	return 0 unless $_[0]-> {canDraw};
	my $self = $_[0];
	$self-> {pages}++;
	$self-> emit("; P\n%%Page: $self->{pages} $self->{pages}\n");
	$self-> $_( @{$self-> {saveState}-> {$_}}) for qw( translate clipRect);
	$self-> change_transform(1);
	$self-> emit( $self-> {pagePrefix});
	return 1;
}

sub pages { $_[0]-> {pages} }

sub spool
{
	shift-> notify( 'Spool', @_);
	return 1;
	# my $p = $_[1];
	# open F, ">> ./test.ps";
	# print F $p;
	# close F;
}   

# properties

sub color
{
	return $_[0]-> SUPER::color unless $#_;
	$_[0]-> SUPER::color( $_[1]);
	return unless $_[0]-> {canDraw};
	$_[0]-> {changed}-> {fill} = 1;
}

sub fillPattern
{
	return $_[0]-> SUPER::fillPattern unless $#_;
	$_[0]-> SUPER::fillPattern( $_[1]);
	return unless $_[0]-> {canDraw};
	
	my $self = $_[0];
	my @fp  = @{$self-> SUPER::fillPattern};
	my $solidBack = ! grep { $_ != 0 } @fp;
	my $solidFore = ! grep { $_ != 0xff } @fp;
	my $fpid;
	my @scaleto = $self-> pixel2point( 8, 8);
	if ( !$solidBack && !$solidFore) {
		$fpid = join( '', map { sprintf("%02x", $_)} @fp);
		unless ( exists $self-> {fpHash}-> {$fpid}) {
			$self-> emit( <<PATTERNDEF);
<< 
\/PatternType 1 \% Tiling pattern
\/PaintType 2 \% Uncolored
\/TilingType 1
\/BBox [ 0 0 @scaleto]
\/XStep $scaleto[0]
\/YStep $scaleto[1] 
\/PaintProc { b 
: 
@scaleto Z
8 8 t
[8 0 0 8 0 0]
< $fpid > I
;
e 
} bind
>> MX MP 
\/Pat_$fpid ~ d
      
PATTERNDEF
			$self-> {fpHash}-> {$fpid} = 1;
		}
	}
	$self-> {fpType} = $solidBack ? 'B' : ( $solidFore ? 'F' : $fpid);
	$self-> {changed}-> {fill} = 1; 
}

sub lineEnd
{
	return $_[0]-> SUPER::lineEnd unless $#_;
	$_[0]-> SUPER::lineEnd($_[1]);
	return unless $_[0]-> {canDraw};
	$_[0]-> {changed}-> {lineEnd} = 1; 
}

sub lineJoin
{
	return $_[0]-> SUPER::lineJoin unless $#_;
	$_[0]-> SUPER::lineJoin($_[1]);
	return unless $_[0]-> {canDraw};
	$_[0]-> {changed}-> {lineJoin} = 1; 
}

sub fillWinding
{
	return $_[0]-> SUPER::fillWinding unless $#_;
	$_[0]-> SUPER::fillWinding($_[1]);
}

sub linePattern
{
	return $_[0]-> SUPER::linePattern unless $#_;
	$_[0]-> SUPER::linePattern($_[1]);
	return unless $_[0]-> {canDraw};
	$_[0]-> {changed}-> {linePattern} = 1; 
}

sub lineWidth
{
	return $_[0]-> SUPER::lineWidth unless $#_;
	$_[0]-> SUPER::lineWidth($_[1]);
	return unless $_[0]-> {canDraw};
	$_[0]-> {changed}-> {lineWidth} = 1; 
}

sub rop
{
	return $_[0]-> SUPER::rop unless $#_;
	my ( $self, $rop) = @_;
	$rop = rop::CopyPut if 
		$rop != rop::Blackness || $rop != rop::Whiteness || $rop != rop::NoOper;
	$self-> SUPER::rop( $rop);
}

sub rop2
{
	return $_[0]-> SUPER::rop2 unless $#_;
	my ( $self, $rop) = @_;
	$rop = rop::CopyPut if 
		$rop != rop::Blackness && $rop != rop::Whiteness && $rop != rop::NoOper;
	$self-> SUPER::rop2( $rop);
}

sub translate
{
	return $_[0]-> SUPER::translate unless $#_;
	my $self = shift;
	$self-> SUPER::translate(@_);
	$self-> change_transform;
}

sub clipRect
{
	return @{$_[0]-> {clipRect}} unless $#_;
	$_[0]-> {clipRect} = [@_[1..4]];
	$_[0]-> change_transform;
}

sub region
{
	return undef;
}

sub scale
{
	return @{$_[0]-> {scale}} unless $#_;
	my $self = shift;
	$self-> {scale} = [@_[0,1]];
	$self-> change_transform;
}

sub isEPS { $#_ ? $_[0]-> {isEPS} = $_[1] : $_[0]-> {isEPS} }

sub reversed
{
	return $_[0]-> {reversed} unless $#_;
	my $self = $_[0];
	$self-> {reversed} = $_[1] unless $self-> get_paint_state;
	$self-> calc_page;
}


sub rotate
{
	return $_[0]-> {rotate} unless $#_;
	my $self = $_[0];
	$self-> {rotate} = $_[1];
	$self-> change_transform;
}


sub resolution
{
	return @{$_[0]-> {resolution}} unless $#_;
	return if $_[0]-> get_paint_state;
	my ( $x, $y) =  @_[1..2];
	return if $x <= 0 || $y <= 0;
	$_[0]-> {resolution} = [$x, $y];
	$_[0]-> calc_page;
}

sub copies
{
	return $_[0]-> {copies} unless $#_;
	$_[0]-> {copies} = $_[1] unless $_[0]-> get_paint_state;
}

sub pageDevice
{
	return $_[0]-> {pageDevice} unless $#_;
	$_[0]-> {pageDevice} = $_[1] unless $_[0]-> get_paint_state;
}

sub useDeviceFonts
{
	return $_[0]-> {useDeviceFonts} unless $#_;
	if ( $_[1]) {
		delete $_[0]-> {font}-> {width};
		$_[0]-> set_font( $_[0]-> get_font);
	}
	$_[0]-> {useDeviceFonts} = $_[1] unless $_[0]-> get_paint_state;
	$_[0]-> {useDeviceFonts} = 1 if $_[0]-> {useDeviceFontsOnly};
	if ( !$::application && !$_[1] ) {
		warn "warning: ignored .useDeviceFonts(0) because Prima::Application is not instantiated\n";
		$_[0]->{useDeviceFonts} = 1;
	}
}

sub useDeviceFontsOnly
{
	return $_[0]-> {useDeviceFontsOnly} unless $#_;
	$_[0]-> useDeviceFonts(1) 
		if $_[0]-> {useDeviceFontsOnly} = $_[1] && !$_[0]-> get_paint_state;
}

sub grayscale 
{
	return $_[0]-> {grayscale} unless $#_;
	$_[0]-> {grayscale} = $_[1] unless $_[0]-> get_paint_state;
}

sub set_locale
{
	my ( $self, $loc) = @_;
	return if !$self-> {useDeviceFonts};

	$self-> {locale} = $loc;
	my $le  = $self-> {localeEncoding} = Prima::PS::Encodings::load( $loc);

	return unless $self->{canDraw};

	unless ( scalar keys %{$self-> {localeData}}) {
		return if ! defined($loc);
		$self-> emit( <<ENCODER);
\/reencode_font { ~ \/enco ~ d
@ @ FF @ length dict b { 1 index 
\/FID ne{d}{pop pop}?} forall \/Encoding 
enco d currentdict e definefont } bind d
ENCODER
	}

	unless ( exists $self-> {localeData}-> {$loc}) {
		$self-> {localeData}-> {$loc} = 1;
		$self-> emit( "/Encoding_$loc [");
		my $i = 0;
		for ( $i = 0; $i < 16; $i++) {
			$self-> emit( join('', map {'/' . $_ } @$le[$i * 16 .. $i * 16 + 15]));
		}
		$self-> emit("] d\n");
	}
}

sub calc_page
{
	my $self = $_[0];
	my @s =  @{$self-> {pageSize}};
	my @m =  @{$self-> {pageMargins}};
	if ( $self-> {reversed}) {
		@s = @s[1,0];
		@m = @m[1,0,3,2];
	}
	$self-> {size} = [
		int(( $s[0] - $m[0] - $m[2]) * $self-> {resolution}-> [0] / 72.27 + 0.5),
		int(( $s[1] - $m[1] - $m[3]) * $self-> {resolution}-> [1] / 72.27 + 0.5),
	];
}

sub pageSize
{
	return @{$_[0]-> {pageSize}} unless $#_;
	my ( $self, $px, $py) = @_;
	return if $self-> get_paint_state;
	$px = 1 if $px < 1;
	$py = 1 if $py < 1;
	$self-> {pageSize} = [$px, $py];
	$self-> calc_page;
}

sub pageMargins
{
	return @{$_[0]-> {pageMargins}} unless $#_;
	my ( $self, $px, $py, $px2, $py2) = @_;
	return if $self-> get_paint_state;
	$px = 0 if $px < 0;
	$py = 0 if $py < 0;
	$px2 = 0 if $px2 < 0;
	$py2 = 0 if $py2 < 0;
	$self-> {pageMargins} = [$px, $py, $px2, $py2];
	$self-> calc_page;
}

sub size
{
	return @{$_[0]-> {size}} unless $#_;
	$_[0]-> raise_ro("size");
}

# primitives

sub arc
{
	my ( $self, $x, $y, $dx, $dy, $start, $end) = @_;
	my $try = $dy / $dx;
	( $x, $y, $dx, $dy) = $self-> pixel2point( $x, $y, $dx, $dy);
	my $rx = $dx / 2;
	$end -= $start;
	$self-> stroke( <<ARC );
$x $y M : $x $y T 1 $try Z $start R
N $rx 0 M 0 0 $rx 0 $end a O ;
ARC
}

sub chord
{
	my ( $self, $x, $y, $dx, $dy, $start, $end) = @_;
	my $try = $dy / $dx;
	( $x, $y, $dx, $dy) = $self-> pixel2point( $x, $y, $dx, $dy);
	my $rx = $dx / 2;
	$end -= $start;
	$self-> stroke(<<CHORD);
$x $y M : $x $y T 1 $try Z $start R
N $rx 0 M 0 0 $rx 0 $end a X O ;
CHORD
}

sub ellipse
{
	my ( $self, $x, $y, $dx, $dy) = @_;
	my $try = $dy / $dx;
	( $x, $y, $dx, $dy) = $self-> pixel2point( $x, $y, $dx, $dy);
	my $rx = $dx / 2;
	$self-> stroke(<<ELLIPSE);
$x $y M : $x $y T 1 $try Z
N $rx 0 M 0 0 $rx 0 360 a O ;
ELLIPSE
}

sub fill_chord
{
	my ( $self, $x, $y, $dx, $dy, $start, $end) = @_;
	my $try = $dy / $dx;
	( $x, $y, $dx, $dy) = $self-> pixel2point( $x, $y, $dx, $dy);
	my $rx = $dx / 2;
	$end -= $start;
	my $F = $self-> fillWinding ? 'F' : 'E';
	$self-> fill( <<CHORD );
$x $y M : $x $y T 1 $try Z
N $rx 0 M 0 0 $rx 0 $end a X $F ;
CHORD
}

sub fill_ellipse
{
	my ( $self, $x, $y, $dx, $dy) = @_;
	my $try = $dy / $dx;
	( $x, $y, $dx, $dy) = $self-> pixel2point( $x, $y, $dx, $dy);
	my $rx = $dx / 2;
	$self-> fill(<<ELLIPSE);
$x $y M : $x $y T 1 $try Z
N $rx 0 M 0 0 $rx 0 360 a F ;
ELLIPSE
}

sub sector
{
	my ( $self, $x, $y, $dx, $dy, $start, $end) = @_;
	my $try = $dy / $dx;
	( $x, $y, $dx, $dy) = $self-> pixel2point( $x, $y, $dx, $dy);
	my $rx = $dx / 2;
	$end -= $start;
	$self-> stroke(<<SECTOR);
$x $y M : $x $y T 1 $try Z $start R
N 0 0 M 0 0 $rx 0 $end a 0 0 l O ;
SECTOR
}

sub fill_sector
{
	my ( $self, $x, $y, $dx, $dy, $start, $end) = @_;
	my $try = $dy / $dx;
	( $x, $y, $dx, $dy) = $self-> pixel2point( $x, $y, $dx, $dy);
	my $rx = $dx / 2;
	$end -= $start;
	my $F = $self-> fillWinding ? 'F' : 'E';
	$self-> fill(<<SECTOR);
$x $y M : $x $y T 1 $try Z $start R
N 0 0 M 0 0 $rx 0 $end a 0 0 l $F ;
SECTOR
}

sub text_out
{
	my ( $self, $text, $x, $y) = @_;
	return 0 unless $self-> {canDraw} and length $text;
	$y += $self-> {font}-> {descent} if !$self-> textOutBaseline;
	( $x, $y) = $self-> pixel2point( $x, $y); 

	my $n = $self-> {typeFontMap}-> {$self-> {font}-> {name}};
	my $spec = exists ( $self-> {font}-> {encoding}) ? 
		exists ( $Prima::PS::Encodings::fontspecific{ $self-> {font}-> {encoding}}) : 0;
	if ( $n == 1) {
		my $fn = $self-> {font}-> {docname};
		unless ( $spec || 
			( !defined( $self-> {locale}) && !defined($self-> {fontLocaleData}-> {$fn})) ||
			( defined( $self-> {locale}) && defined($self-> {fontLocaleData}-> {$fn}) && 
					($self-> {fontLocaleData}-> {$fn} eq $self-> {locale}))) {
			$self-> {fontLocaleData}-> {$fn} = $self-> {locale};
			$self-> emit( "Encoding_$self->{locale} /$fn reencode_font");
			$self-> {changed}-> {font} = 1;
		}      

		if ( $self-> {changed}-> {font}) {
			$self-> emit( "/$fn FF $self->{font}->{size} XF SF");
			$self-> {changed}-> {font} = 0;
		}
	}
	my $wmul = $self-> {font}-> {width} / $self-> {fontWidthDivisor};
	$self-> emit(": $x $y T");
	$self-> emit("$wmul 1 Z") if $wmul != 1;
	$self-> emit("0 0 M");
	if ( $self-> {font}-> {direction} != 0) {
		my $r = $self-> {font}-> {direction};
		$self-> emit("$r R");
	}
	my @rb;
	if ( $self-> textOpaque || $self-> {font}-> {style} & (fs::Underlined|fs::StruckOut)) {
		my ( $ds, $bs) = ( $self-> {font}-> {direction}, $self-> textOutBaseline);
		$self-> {font}-> {direction} = 0;
		$self-> textOutBaseline(1) unless $bs;
		@rb = $self-> pixel2point( @{$self-> get_text_box( $text)});
		$self-> {font}-> {direction} = $ds;
		$self-> textOutBaseline($bs) unless $bs;
	}
	if ( $self-> textOpaque) {
		$self-> emit( $self-> cmd_rgb( $self-> backColor)); 
		$self-> emit( ": N @rb[0,1] M @rb[2,3] l @rb[6,7] l @rb[4,5] l X F ;");
	}
	
	$self-> emit( $self-> cmd_rgb( $self-> color));
	my ( $rm, $nd) = $self-> get_rmap;
	my ( $xp, $yp) = ( $x, $y);
	my $c  = $self-> {font}-> {chardata}; 
	my $le = $self-> {localeEncoding};
	my $adv = 0;

	my ( @t, @umap);
	my $unicode = Encode::is_utf8( $text);
	if ( defined($self-> {font}-> {encoding}) && $unicode) {
		# known encoding?
		eval { Encode::encode( $self-> {font}-> {encoding}, ''); };
		unless ( $@) {
			# convert as much of unicode text as possible into the current encoding
			while ( 1) {
				my $conv = Encode::encode(
					$self-> {font}-> {encoding}, $text,
					Encode::FB_QUIET
				);
				push @t, split( '', $conv);
				push @umap, (undef) x length $conv;
				last unless length $text;
				push @t, substr( $text, 0, 1, '');
				push @umap, 1;
			}
		} else {
			@t = split '', $text;
			@umap = map { undef } @t;
		}
	} else {
		@t = split '', $text;
		@umap = map { undef } @t;
	}

	my $i = -1;
	for my $j ( @t) {
		$i++;
		my $advance;
		my $u = $umap[$i]||0;
		if ( 
			!$umap[$i] &&                           # not unicode
			$n == 1 &&                              # postscript font 
			( $le-> [ ord $j] ne '.notdef') && (    # 
				$spec ||                        # fontspecific
				exists ( $c-> {$le-> [ ord $j]} # have predefined font metrics
			)
		)) {
			$j =~ s/([\\()])/\\$1/g; 
			my $adv2 = int( $adv * 100 + 0.5) / 100;
			$self-> emit( "$adv2 0 M") if $adv2 != 0;
			$self-> emit("($j) S");
			my $xr = $rm-> [ ord $j];
			$advance = $$xr[1] + $$xr[2] + $$xr[3];
		} else {
			my ( $pg, $a, $b, $c) = $self-> place_glyph( $j);
			if ( length $pg) {
				my $adv2 = $adv + $a * 72.27 / $self-> {resolution}-> [0]; 
				$adv2 = int( $adv * 100 + 0.5) / 100;
				$self-> emit( "$adv2 $self->{plate}->{yd} M : CP T");
				$self-> emit( $pg);
				$self-> emit(";");
				$advance = $a + $b + $c;
			} elsif ( defined $a ) {
				$advance = $a + $b + $c;
			} else {
				$advance = $$nd[1] + $$nd[2] + $$nd[3];
			}
		}
		$adv += $advance * 72.27 / $self-> {resolution}-> [0];
	}
	
	#$text =~ s/([\\()])/\\$1/g;
	#$self-> emit("($text) S");
	
	if ( $self-> {font}-> {style} & (fs::Underlined|fs::StruckOut)) {
		my $lw = $self-> {font}-> {size}/30; # XXX empiric
		$self-> emit("[] 0 SD 0 SL $lw SW");
		if ( $self-> {font}-> {style} & fs::Underlined) {
			$self-> emit("N @rb[0,3] M $rb[4] 0 L O");
		}
		if ( $self-> {font}-> {style} & fs::StruckOut) {
			$rb[3] += $rb[1]/2;
			$self-> emit("N @rb[0,3] M $rb[4] 0 L O");
		}
	}
	$self-> emit(";");
	return 1;
}

sub bar
{
	my ( $self, $x1, $y1, $x2, $y2) = @_;
	( $x1, $y1, $x2, $y2) = $self-> pixel2point( $x1, $y1, $x2, $y2);
	$self-> fill( "N $x1 $y1 M $x1 $y2 l $x2 $y2 l $x2 $y1 l X F");
}

sub bars
{
	my ( $self, $array) = @_;
	my $i; 
	my $c = scalar @$array;
	my @a = $self-> pixel2point( @$array);
	$c = int( $c / 4) * 4;
	my $z = '';
	for ( $i = 0; $i < $c; $i += 4) {
		$z .= "N @a[$i,$i+1] M @a[$i,$i+3] l @a[$i+2,$i+3] l @a[$i+2,$i+1] l X F ";
	}
	$self-> stroke( $z);
}

sub rectangle
{
	my ( $self, $x1, $y1, $x2, $y2) = @_;
	( $x1, $y1, $x2, $y2) = $self-> pixel2point( $x1, $y1, $x2, $y2);
	$self-> stroke( "N $x1 $y1 M $x1 $y2 l $x2 $y2 l $x2 $y1 l X O");
}

sub clear
{
	my ( $self, $x1, $y1, $x2, $y2) = @_; 
	if ( grep { ! defined } $x1, $y1, $x2, $y2) {
		($x1, $y1, $x2, $y2) = $self-> clipRect;
		unless ( grep { $_ != 0 } $x1, $y1, $x2, $y2) {
			($x1, $y1, $x2, $y2) = (0,0,@{$self-> {size}});
		}
	}
	( $x1, $y1, $x2, $y2) = $self-> pixel2point( $x1, $y1, $x2, $y2);
	my $c = $self-> cmd_rgb( $self-> backColor);
	$self-> emit(<<CLEAR);
$c
N $x1 $y1 M $x1 $y2 l $x2 $y2 l $x2 $y1 l X F
CLEAR
	$self-> {changed}-> {fill} = 1;
}

sub line
{
	my ( $self, $x1, $y1, $x2, $y2) = @_;
	( $x1, $y1, $x2, $y2) = $self-> pixel2point( $x1, $y1, $x2, $y2);
	$self-> stroke("N $x1 $y1 M $x2 $y2 l O");
}

sub lines
{
	my ( $self, $array) = @_;
	my $i; 
	my $c = scalar @$array;
	my @a = $self-> pixel2point( @$array);
	$c = int( $c / 4) * 4;
	my $z = '';
	for ( $i = 0; $i < $c; $i += 4) {
		$z .= "N @a[$i,$i+1] M @a[$i+2,$i+3] l O ";
	}
	$self-> stroke( $z);
}

sub polyline
{
	my ( $self, $array) = @_;
	my $i; 
	my $c = scalar @$array;
	my @a = $self-> pixel2point( @$array);
	$c = int( $c / 2) * 2;
	return if $c < 2;
	my $z = "N @a[0,1] M ";
	for ( $i = 2; $i < $c; $i += 2) {
		$z .= "@a[$i,$i+1] l ";
	}
	$z .= "O";
	$self-> stroke( $z);
}

sub fillpoly
{
	my ( $self, $array) = @_;
	my $i; 
	my $c = scalar @$array;
	$c = int( $c / 2) * 2;
	return if $c < 2;
	my @a = $self-> pixel2point( @$array); 
	my $x = "N @a[0,1] M ";
	for ( $i = 2; $i < $c; $i += 2) {
		$x .= "@a[$i,$i+1] l ";
	}
	$x .= 'X ' . ($self-> fillWinding ? 'F' : 'E');
	$self-> fill( $x);
}

sub flood_fill { return 0; }

sub pixel
{
	my ( $self, $x, $y, $pix) = @_;
	return cl::Invalid unless defined $pix;
	my $c = $self-> cmd_rgb( $pix);   
	($x, $y) = $self-> pixel2point( $x, $y);
	$self-> emit(<<PIXEL);
:
$c
N $x $y M 0 0 L F
;
PIXEL
	$self-> {changed}-> {fill} = 1;
}


# methods

sub put_image_indirect
{
	return 0 unless $_[0]-> {canDraw};
	my ( $self, $image, $x, $y, $xFrom, $yFrom, $xDestLen, $yDestLen, $xLen, $yLen) = @_;
	
	my $touch;
	$touch = 1, $image = $image-> image if $image-> isa('Prima::DeviceBitmap');

	
	unless ( $xFrom == 0 && $yFrom == 0 && $xLen == $image-> width && $yLen == $image-> height) {
		$image = $image-> extract( $xFrom, $yFrom, $xLen, $yLen);
		$touch = 1;
	}    

	my $ib = $image-> get_bpp;
	if ( $ib != $self-> get_bpp) {
		$image = $image-> dup unless $touch;     
		if ( $self-> {grayscale} || $image-> type & im::GrayScale) {
			$image-> type( im::Byte);
		} else {
			$image-> type( im::RGB); 
		}
	} elsif ( $self-> {grayscale} || $image-> type & im::GrayScale) {
		$image = $image-> dup unless $touch;     
		$image-> type( im::Byte);
	}
	
	$ib = $image-> get_bpp;
	$image-> type( im::RGB) if $ib != 8 && $ib != 24;
	
	
	my @is = $image-> size;
	($x, $y, $xDestLen, $yDestLen) = $self-> pixel2point( $x, $y, $xDestLen, $yDestLen);
	my @fullScale = (
		$is[0] / $xLen * $xDestLen,
		$is[1] / $yLen * $yDestLen,
	);
	

	my $g  = $image-> data;
	my $bt = ( $image-> type & im::BPP) * $is[0] / 8;
	my $ls = $image->lineSize;
	my ( $i, $j);

	$self-> emit(": $x $y T @fullScale Z");
	$self-> emit("/scanline $bt string d");
	$self-> emit("@is 8 [$is[0] 0 0 $is[1] 0 0]");
	$self-> emit('{currentfile scanline readhexstring pop}');
	$self-> emit(( $image-> type & im::GrayScale) ? "image" : "false 3 colorimage");

	for ( $i = 0; $i < $is[1]; $i++) {
		my $w  = substr( $g, $ls * $i, $bt);
		$w =~ s/(.)(.)(.)/$3$2$1/gs if $ib == 24;
		$w =~ s/(.)/sprintf("%02x",ord($1))/egs;
		$self-> emit( $w);
	}
	$self-> emit(';');
	return 1;
}

sub get_bpp              { return $_[0]-> {grayscale} ? 8 : 24 }
sub get_nearest_color    { return $_[1] }
sub get_physical_palette { return $_[0]-> {grayscale} ? [map { $_, $_, $_ } 0..255] : 0 }
sub get_handle           { return 0 }

# fonts
sub fonts
{  
	my ( $self, $family, $encoding) = @_;
	$family   = undef if defined $family   && !length $family;
	$encoding = undef if defined $encoding && !length $encoding;

	my $f1 = $self-> {useDeviceFonts} ? Prima::PS::Fonts::enum_fonts( $family, $encoding) : [];
	return $f1 if !$::application || $self-> {useDeviceFontsOnly};

	my $f2 = $::application-> fonts( $family, $encoding);
	if ( !defined($family) && !defined($encoding)) {
		my %f = map { $_-> {name} => $_ } @$f1;
		my @add;
		for ( @$f2) {
			if ( $f{$_}) {
				push @{$f{$_}-> {encodings}}, @{$_-> {encodings}};
			} else {
				push @add, $_;
			}
		}
		push @$f1, @add;
	} else {
		push @$f1, @$f2;
	}
	return $f1;
}

sub font_encodings
{
	my @r;
	if ( $_[0]-> {useDeviceFonts}) {
		@r = Prima::PS::Encodings::unique, keys %Prima::PS::Encodings::fontspecific;
	}
	if ( $::application && !$_[0]-> {useDeviceFontsOnly}) {
		my %h = map { $_ => 1 } @r;
		for ( @{$::application-> font_encodings}) {
			next if $h{$_};
			push @r, $_;
		}
	}
	return \@r;
}

sub get_font 
{ 
	my $z = {%{$_[0]-> {font}}};
	delete $z-> {charmap};
	delete $z-> {docname};
	return $z;
}

# we're asked to substitute a non-PS font, which most probably has its own definiton of box width
# let's find out what em-width the font has, and if we can adapt for it
#
# return the multiplication factor between the requested gui font and the currently selected PS font
sub _get_gui_font_ratio
{
	my ($self, %request) = @_;
	my $n = $request{name};

	return unless
		($n ne 'Default') && exists $request{width} && exists $request{height} && $::application &&
		!exists($Prima::PS::Fonts::enum_families{ $n}) && !exists($Prima::PS::Fonts::files{ $n})
		;

	my $ratio;
	my $paint_state = $::application->get_paint_state == ps::Disabled;
	my $save_font;
	$paint_state ? $::application->begin_paint_info : ( $save_font = \%{ $::application->get_font } );

	my $scale = ($request{height} < 20) ? 10 : 1; # scale font 10 times for better accuracy
	my $width = delete($request{width});
	$request{height} *= $scale;
	$::application->set_font(\%request);

	if ( $n eq $::application->font->name) {
		my $gui_scaling = $width / $::application->font->width;
		my $ps_scaling  = $self->{font}->{referenceWidth} / $self->{font}->{width}; 
		$ratio = $ps_scaling * $gui_scaling * $scale;
	}
	
	$paint_state ? $::application->end_paint_info   : ( $::application->set_font($save_font) );
	return $ratio;
}

sub set_font 
{
	my ( $self, $font) = @_;
	$font = { %$font }; 
	my $n = exists($font-> {name}) ? $font-> {name} : $self-> {font}-> {name};
	my $gui_font;
	$n = $self-> {useDeviceFonts} ? $Prima::PS::Fonts::defaultFontName : 'Default'
		unless defined $n;

	$font-> {height} = int(( $font-> {size} * $self-> {resolution}-> [1]) / 72.27 + 0.5)
		if exists $font-> {size};
AGAIN:
	if ( $self-> {useDeviceFontsOnly} || !$::application ||
			( $self-> {useDeviceFonts} && 
			( 
			# enter, if there's a device font
				exists $Prima::PS::Fonts::enum_families{ $n} || 
				exists $Prima::PS::Fonts::files{ $n} ||
				(
					# or the font encoding is PS::Encodings-specific,
					# not present in the GUI space
					exists $font-> {encoding} &&
					(  
						exists $Prima::PS::Encodings::fontspecific{$font-> {encoding}} ||
						exists $Prima::PS::Encodings::files{$font-> {encoding}}
					) && (
						!grep { $_ eq $font-> {encoding} } @{$::application-> font_encodings}
					)
				)
			) && 
			# and, the encoding is supported
			( 
				!exists $font-> {encoding} || !length ($font-> {encoding}) || 
				(
					exists $Prima::PS::Encodings::fontspecific{$font-> {encoding}} ||
					exists $Prima::PS::Encodings::files{$font-> {encoding}}
				)
			) 
		)
	)
	{
		$self-> {font} = Prima::PS::Fonts::font_pick( $font, $self-> {font}, 
			resolution => $self-> {resolution}-> [1]); 
		$self-> {fontCharHeight} = $self-> {font}-> {charheight};
		$self-> {docFontMap}-> {$self-> {font}-> {docname}} = 1; 
		$self-> {typeFontMap}-> {$self-> {font}-> {name}} = 1; 
		$self-> {fontWidthDivisor} = $self-> {font}-> {referenceWidth};
		$self-> set_locale( $self-> {font}-> {encoding});

		my %request = ( %$font, name => $n );
		$request{height} = $self->{font}->{height} unless defined $request{height};
		delete $request{size};
		if ( my $ratio = $self->_get_gui_font_ratio(%request)) {
			$self->{font}->{width}        *= $ratio;
			$self->{font}->{maximalWidth} *= $ratio;
		}
	} else {
		my $wscale = $font-> {width};
		my $wsize  = $font-> {size};
		my $wfsize = $self-> {font}-> {size};
		delete $font-> {width};
		delete $font-> {size};
		delete $self-> {font}-> {size};
		unless ( $gui_font) {
			$gui_font = Prima::Drawable-> font_match( $font, $self-> {font});
			if ( $gui_font-> {name} ne $n && $self-> {useDeviceFonts}) {
				# back up
				my $pitch = (exists ( $font-> {pitch} ) ? 
					$font-> {pitch} : $self-> {font}-> {pitch}) || fp::Variable;
				$n = $font-> {name} = ( $pitch == fp::Variable) ? 
					$Prima::PS::Fonts::variablePitchName :
					$Prima::PS::Fonts::fixedPitchName;
				$font-> {width} = $wscale if defined $wscale;
				$font-> {wsize} = $wsize  if defined $wsize;
				$self-> {font}-> {size} = $wfsize if defined $wfsize;
				goto AGAIN;
			}
		}
		$self-> {font} = $gui_font;
		$self-> {font}-> {size} = 
			int( $self-> {font}-> {height} * 72.27 / $self-> {resolution}-> [1] + 0.5);
		$self-> {typeFontMap}-> {$self-> {font}-> {name}} = 2; 
		$self-> {fontWidthDivisor} = $self-> {font}-> {width};
		$self-> {font}-> {width} = $wscale if $wscale;
		$self-> {fontCharHeight} = $self-> {font}-> {height};
	}
	$self-> {changed}-> {font} = 1;
	$self-> {plate}-> destroy, $self-> {plate} = undef if $self-> {plate};
}

my %fontmap = 
(Prima::Application-> get_system_info-> {apc} == apc::Win32) ? (
	'Helvetica' => 'Arial',
	'Times'     => 'Times New Roman',
	'Courier'   => 'Courier New',
) : ();

sub plate
{
	my $self = $_[0];
	return $self-> {plate} if $self-> {plate};
	return {ABC => []} if $self-> {useDeviceFontsOnly};
	my ( $dimx, $dimy) = ( $self-> {font}-> {maximalWidth}, $self-> {font}-> {height});
	my %f = %{$self-> {font}};
	$f{style} &= ~(fs::Underlined|fs::StruckOut);
	if ( $self-> {useDeviceFonts} && exists $Prima::PS::Fonts::files{$f{name}}) {
		$f{name} =~ s/^([^-]+)\-.*$/$1/;
		$f{pitch} = fp::Default unless $f{pitch} == fp::Fixed;
		$f{name} = $fontmap{$f{name}} if exists $fontmap{$f{name}};
	}
	delete $f{size};
	delete $f{width};
	delete $f{direction};
	$self-> {plate} = Prima::Image-> create(
		type   => im::BW,
		width  => $dimx,
		height => $dimy,
		font      => \%f,
		backColor => cl::Black,
		color     => cl::White,
		textOutBaseline => 1,
		preserveType => 1,
		conversion   => ict::None,
	);
	my ( $f, $l) = ( $self-> {plate}-> font-> {firstChar}, $self-> {plate}-> font-> {lastChar});
	my $x = $self-> {plate}-> {ABC} = $self-> {plate}-> get_font_abc( $f, $l);
	my $j = (230 - $f) * 3;
	return $self-> {plate};
}

sub place_glyph
{
	return '' if $_[0]-> {useDeviceFontsOnly};
	my ( $self, $char) = @_;
	my $z = $_[0]-> plate;
	my $x = ord $char;
	my $d  = $z-> font-> descent;
	my ( $dimx, $dimy) = $z-> size;
	my ( $f, $l) = ( $z-> font-> firstChar, $z-> font-> lastChar);
	my $ls = int(( $dimx + 31) / 32) * 4; 
	my $la = int ($dimx / 8) + (( $dimx & 7) ? 1 : 0);
	my $ax = ( $dimx & 7) ? (( 0xff << (7-( $dimx & 7))) & 0xff) : 0xff;
	
	my $xsf = 0;
	my ( $a, $b, $c);

	if ( Encode::is_utf8( $char)) {
		( $a, $b, $c) = @{ $z-> get_font_abc( $x, $x, 1)};
	} else {
		my $abc = $z-> {ABC};
		( $a, $b, $c) = (
			$abc-> [ ( $x - $f) * 3],
			$abc-> [ ( $x - $f) * 3 + 1],
			$abc-> [ ( $x - $f) * 3 + 2],
		);
	}
	return '' if $b <= 0;
	$z-> begin_paint;
	$z-> clear;
	$z-> text_out( chr( $x), ($a < 0) ? -$a : 0, $d);
	$z-> end_paint;
	my $dd = $z-> data;
	my ($j, $k);
	my @emmap = (0) x $dimy;
	my @bbox = ( $a, 0, $b - $a, $dimy - 1);
	for ( $j = $dimy - 1; $j >= 0; $j--) {
		#my @ss  = map { my $x = ord $_; map { ($x & (0x80>>$_))?'X':'.'} 0..7 } split( '', substr( $dd, $ls * $j, $la)); 
		my @xdd = map { ord $_ } split( '', substr( $dd, $ls * $j, $la));
		#print "@ss @xdd\n";
		$xdd[-1] &= $ax;
		$emmap[$j] = 1 unless grep { $_ } @xdd;
	}
	for ( $j = 0; $j < $dimy; $j++) {
		last unless $emmap[$j];
		$bbox[1]++;
	}
	for ( $j = $dimy - 1; $j >= 0; $j--) {
		last unless $emmap[$j];
		$bbox[3]--;
	}
	
	if ( $bbox[3] >= 0) {
		$bbox[1] -= $d;
		$bbox[3] -= $d;
		my $zd = $z-> extract( 
			( $a < 0) ? 0 : $a,
			$bbox[1] + $d,
			$b,
			$bbox[3] - $bbox[1] + 1,
		);
		# $z-> save("a.gif");
		
		my $bby = $bbox[3] - $bbox[1] + 1;
		my $zls = int(( $b + 31) / 32) * 4; 
		my $zla = int ($b / 8) + (( $b & 7) ? 1 : 0);
		$zd = $zd-> data;
		my $cd = '';
		for ( $j = $bbox[3] - $bbox[1]; $j >= 0; $j--) {
			$cd .= substr( $zd, $j * $zls, $zla);
		}

		my $cdz = '';
		for ( $j = 0; $j < length $cd; $j++) {
			$cdz .= sprintf("%02x", ord substr( $cd, $j, 1));
		}

		$_[0]-> {plate}-> {yd} = $bbox[1] * 72.27 / $_[0]-> {resolution}-> [1];
		my $scalex = 72.27 * $b   / $_[0]-> {resolution}-> [0];
		my $scaley = 72.27 * $bby / $_[0]-> {resolution}-> [1];
		return 
			"$scalex $scaley scale $b $bby true [$b 0 0 -$bby 0 $bby] <$cdz> imagemask",
			$a, $b, $c;
	}
	return '', $a, $b, $c;
}

sub get_rmap
{
	my @rmap;
	my $self = shift;
	my $c  = $self-> {font}-> {chardata};
	my $le = $self-> {localeEncoding};
	my $nd = $c-> {'.notdef'};
	my $fs = $self-> {font}-> {height} / $self-> {fontCharHeight};
	if ( defined $nd) {
		$nd = [ @$nd ];
		$$nd[$_] *= $fs for 1..3;
	} else {
		$nd = [0,0,0,0];
	}

	my ( $f, $l) = ( $self-> {font}-> {firstChar}, $self-> {font}-> {lastChar});
	my $i;
	my $abc;
	if ( $self-> {typeFontMap}-> {$self-> {font}-> {name}} == 1) {
		for ( $i = 0; $i < 255; $i++) {
			if (defined($le->[$i]) && ( $le-> [$i] ne '.notdef') && $c-> { $le-> [ $i]}) {
				$rmap[$i] = [ $i, map { $_ * $fs } @{$c-> { $le-> [ $i]}}[1..3]];
			} elsif ( !$self->{useDeviceFontsOnly} && $i >= $f && $i <= $l) {
				$abc = $self-> plate-> {ABC} unless $abc; 
				my $j = ( $i - $f) * 3; 
				$rmap[$i] = [ $i, @$abc[ $j .. $j + 2]];   
			}
		}
	} else {
		$abc = $self-> plate-> {ABC};
		for ( $i = $f; $i <= $l; $i++) {
			my $j = ( $i - $f) * 3;
			$rmap[$i] = [ $i, @$abc[ $j .. $j + 2]];
		}
	}
#  @rmap = map { $c-> {$_} } @{$_[0]-> {localeEncoding}};
	
	return \@rmap, $nd;
}

sub get_font_abc
{
	my ( $self, $first, $last) = @_;
	my $lim = ( defined ($self-> {font}-> {encoding}) && 
			exists($Prima::PS::Encodings::fontspecific{$self-> {font}-> {encoding}})) 
		? 255 : 127;
	$first = 0    if !defined $first || $first < 0;
	$first = $lim if $first > $lim;
	$last  = $lim if !defined $last || $last < 0 || $last > $lim;
	my $i;
	my @ret; 
	my ( $rmap, $nd) = $self-> get_rmap;
	my $wmul = $self-> {font}-> {width} / $self-> {fontWidthDivisor};
	for ( $i = $first; $i < $last; $i++) {
		my $cd = $rmap-> [ $i] || $nd;
		push( @ret, map { $_ * $wmul } @$cd[1..3]);
	}
	return \@ret;
}

sub get_font_ranges
{
	my $self = $_[0];
	return [ $self-> {font}-> {firstChar}, $self-> {font}-> {lastChar}];
}

sub get_text_width
{
	my ( $self, $text, $addOverhang) = @_;

	my $i;
	my $len = length $text;
	return 0 unless $len;
	my ( $rmap, $nd) = $self-> get_rmap;
	my $cd;
	my $w = 0;
	
	for ( $i = 0; $i < $len; $i++) {
		my $cd = $rmap-> [ ord( substr( $text, $i, 1))] || $nd;
		$w += $cd-> [1] + $cd-> [2] + $cd-> [3];
	}
	
	if ( $addOverhang) {
		$cd = $rmap-> [ ord( substr( $text, 0, 1))] || $nd; 
		$w += ( $cd-> [1] < 0) ? -$cd-> [1] : 0; 
		$cd = $rmap-> [ ord( substr( $text, $len - 1, 1))] || $nd; 
		$w += ( $cd-> [3] < 0) ? -$cd-> [3] : 0; 
	}
	return $w * $self-> {font}-> {width} / $self-> {fontWidthDivisor}; 
}

sub get_text_box
{
	my ( $self, $text) = @_;
	my ( $rmap, $nd) = $self-> get_rmap;
	my $len = length $text;
	return [ (0) x 10 ] unless $len; 
	my $cd;
	my $wmul = $self-> {font}-> {width} / $self-> {fontWidthDivisor};
	$cd = $rmap-> [ ord( substr( $text, 0, 1))] || $nd; 
	my $ovxa = $wmul * (( $cd-> [1] < 0) ? -$cd-> [1] : 0);
	$cd = $rmap-> [ ord( substr( $text, $len - 1, 1))] || $nd; 
	my $ovxb = $wmul * (( $cd-> [3] < 0) ? -$cd-> [3] : 0);
	
	my $w = $self-> get_text_width( $text);
	my @ret = (
		-$ovxa,      $self-> {font}-> {ascent} - 1,
		-$ovxa,     -$self-> {font}-> {descent}, 
		$w - $ovxb,  $self-> {font}-> {ascent} - 1,
		$w - $ovxb, -$self-> {font}-> {descent},
		$w, 0
	);
	unless ( $self-> textOutBaseline) {
		$ret[$_] += $self-> {font}-> {descent} for (1,3,5,7,9);
	}
	if ( $self-> {font}-> {direction} != 0) {
		my $s = sin( $self-> {font}-> {direction} / 57.29577951);
		my $c = cos( $self-> {font}-> {direction} / 57.29577951);
		my $i;
		for ( $i = 0; $i < 10; $i+=2) {
			my ( $x, $y) = @ret[$i,$i+1];
			$ret[$i]   = $x * $c - $y * $s;
			$ret[$i+1] = $x * $s + $y * $c;
		}
	}
	return \@ret;
}


1;

__END__

=pod

=head1 NAME

Prima::PS::Drawable -  PostScript interface to Prima::Drawable

=head1 SYNOPSIS

	use Prima;
	use Prima::PS::Drawable;

	my $x = Prima::PS::Drawable-> create( onSpool => sub {
		open F, ">> ./test.ps";
		print F $_[1];
		close F;
	});
	die "error:$@" unless $x-> begin_doc;
	$x-> font-> size( 30);
	$x-> text_out( "hello!", 100, 100);
	$x-> end_doc;


=head1 DESCRIPTION

Realizes the Prima library interface to PostScript level 2 document language.
The module is designed to be compliant with Prima::Drawable interface.
All properties' behavior is as same as Prima::Drawable's, except those 
described below. 

=head2 Inherited properties

=over

=item ::resolution

Can be set while object is in normal stage - cannot be changed if document
is opened. Applies to fillPattern realization and general pixel-to-point
and vice versa calculations

=item ::region

- ::region is not realized ( yet?)

=back

=head2 Specific properties

=over

=item ::copies

amount of copies that PS interpreter should print

=item ::grayscale

could be 0 or 1

=item ::pageSize 

physical page dimension, in points

=item ::pageMargins

non-printable page area, an array of 4 integers:
left, bottom, right and top margins in points.

=item ::reversed

if 1, a 90 degrees rotated document layout is assumed 

=item ::rotate and ::scale

along with Prima::Drawable::translate provide PS-specific
transformation matrix manipulations. ::rotate is number,
measured in degrees, counter-clockwise. ::scale is array of
two numbers, respectively x- and y-scale. 1 is 100%, 2 is 200% 
etc.

=item ::useDeviceFonts

1 by default; optimizes greatly text operations, but takes the risk
that a character could be drawn incorrectly or not drawn at all -
this behavior depends on a particular PS interpreter.

=item ::useDeviceFontsOnly

If 1, the system fonts, available from Prima::Application
interfaces can not be used. It is designed for
developers and the outside-of-Prima applications that wish to
use PS generation module without graphics. If 1, C<::useDeviceFonts>
is set to 1 automatically.

Default value is 0

=back

=head2 Internal methods

=over

=item emit

Can be called for direct PostScript code injection. Example:

	$x-> emit('0.314159 setgray');
	$x-> bar( 10, 10, 20, 20);

=item pixel2point and point2pixel

Helpers for translation from pixel to points and vice versa.

=item fill & stroke

Wrappers for PS outline that is expected to be filled or stroked.
Apply colors, line and fill styles if necessary.

=item spool

Prima::PS::Drawable is not responsible for output of
generated document, it just calls ::spool when document
is closed through ::end_doc. By default just skips data.
Prima::PS::Printer handles spooling logic.

=item fonts

Returns Prima::Application::font plus those that defined into Prima::PS::Fonts module.

=back

=cut

