# GIF compare script

# Copyright (C) 1998, 1999 by Peter Verthez

# This program is free software; you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation; either version 2, or (at your option)
# any later version.

# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.

# You should have received a copy of the GNU General Public License
# along with this program; if not, write to the Free Software
# Foundation, Inc., 59 Temple Place - Suite 330, Boston, MA
# 02111-1307, USA.

# Written by Peter Verthez, <Peter.Verthez@advalvas.be>.


require 5.003_23;

use strict;
use diagnostics;
use GD;

sub error {
  my ($msg) = @_;
  print "$msg\n";
  exit 1;
}

my $imageHandle;

open IM, $ARGV[0] or die "Can't open $ARGV[0]\n";
$imageHandle = \*IM;
my $image1 = newFromPng GD::Image($imageHandle);
close $imageHandle;

open $imageHandle, $ARGV[1] or die "Can't open $ARGV[1]\n";
my $image2 = newFromPng GD::Image($imageHandle);
close $imageHandle;

error "Differ in interlacing"
    if $image1->interlaced xor $image2->interlaced;

my $transcol1 = $image1->transparent;
my $transcol2 = $image2->transparent;

error "Differ in transparency"
    if $transcol1 xor $transcol2;

my @size1 = $image1->getBounds;
my @size2 = $image2->getBounds;

error "Differ in size"
    if ($size1[0] != $size2[0]) or ($size1[1] != $size2[1]);

# Color index transform from image 1 to image 2
my @trans1to2;
my $ind1;
for ($ind1 = 0; $ind1 < $image1->colorsTotal; $ind1++) {
  $trans1to2[$ind1] = $image2->colorExact($image1->rgb($ind1));
}

my ($x, $y);
for ($x = 0; $x < $size1[0]; $x++) {
  for ($y = 0; $y < $size1[1]; $y++) {
    my $col1 = $image1->getPixel($x, $y);
    my $col2 = $image2->getPixel($x, $y);
    error "Differ on pixel ($x, $y)"
	if ($col1 == $image1->transparent) xor ($col2 == $image2->transparent);
    next if ($col1 == $image1->transparent) and ($col2 == $image2->transparent);
    my $transcol2 = $trans1to2[$col1];
    error "Differ on pixel ($x, $y)"
	unless (defined $transcol2 and ($transcol2 == $col2));
  }
}
