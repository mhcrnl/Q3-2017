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

examples/generic.pl - A "hello world" program

=head1 FEATURES

A very basic Prima toolkit usage is demonstrated

=cut

use strict;
use lib 'blib/arch';
use Prima;
use Prima::Application name => 'Generic';

my $w = new Prima::MainWindow(
	text => "Hello, world!",
	onClose => sub {
		$::application-> destroy;
	},
	onMouseDown => sub {
		die;
	},
	onPaint   => sub {
		print STDERR "now\n";
		die;
		my ( $self, $canvas) = @_;
		my $color = $self-> color;
		$canvas-> color( $self-> backColor);
		$canvas-> bar( 0, 0, $canvas-> size);
		$canvas-> color( $color);
		$canvas-> text_out( $self-> text, 10, 10);
	},
);

$w-> insert( Timer =>
timeout => 2000,
onTick => sub { 
	$w-> width( $w-> width - 50);
},   
) -> start if 0;

print STDERR "prun\n";
eval {
run Prima;
};
warn $@;
