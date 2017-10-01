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

=pod 

=head1 NAME

examples/cv.pl - Standard color dialog

=head1 FEATURES

Demonstrates usage of a standard color dialog.
Note the left-button drag effect from the color wheel with 
compbinations of Shift,Alt,and Control.

=cut

use strict;
use Prima 'StdDlg', Application => { name => 'CV' };

my $p = Prima::ColorDialog-> create(
	value => 0x3030F0,
	visible => 1,
	quality => 1,
);

my $banner = $p-> {wheel}-> insert( Label => 
	text => <<MSG,
Drag colors from the color wheel by left mouse button together with combinations of Alt, Shift, and Control
MSG
	autoHeight => 1,
	wordWrap   => 1,
	transparent => 1,
	alignment => ta::Center,
	left  => $p-> {wheel}-> width * 0.125,
	top => 0,
	width => $p-> {wheel}-> width * 0.75,
);

$p-> insert( Timer => 
	timeout => 100,
	onTick  => sub {
		if ( $banner-> bottom > $p->{wheel}-> height) {
			$_[0]-> destroy;
		} else {
			$banner-> bottom( $banner-> bottom + 2);
		}
	},
)-> start;

$p-> execute;
