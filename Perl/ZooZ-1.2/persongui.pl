#!perl

##################
#
# This file was automatically generated by ZooZ.pl v1.2
# on Thu Oct  5 16:53:07 2017.
# Project: Project 1
# File:    
#
##################

#
# Headers
#
use strict;
use warnings;

use Tk 804;

#
# Global variables
#
my (
     # MainWindow
     $MW,

     # Hash of all widgets
     %ZWIDGETS,
    );

#
# User-defined variables (if any)
#

######################
#
# Create the MainWindow
#
######################

$MW = MainWindow->new;

######################
#
# Load any images and fonts
#
######################
ZloadImages();
ZloadFonts ();



# Widget Nume: isa Label
$ZWIDGETS{'Nume:'} = $MW->Label(
   -text => 'Label1',
  )->grid(
   -row    => 0,
   -column => 0,
  );

# Widget Prenume: isa Label
$ZWIDGETS{'Prenume:'} = $MW->Label(
   -text => 'Label2',
  )->grid(
   -row    => 1,
   -column => 0,
  );

# Widget CNP: isa Label
$ZWIDGETS{'CNP:'} = $MW->Label(
   -text => 'Label3',
  )->grid(
   -row    => 2,
   -column => 0,
  );

# Widget Enume isa Entry
$ZWIDGETS{'Enume'} = $MW->Entry()->grid(
   -row    => 0,
   -column => 1,
  );

# Widget Eprenume isa Entry
$ZWIDGETS{'Eprenume'} = $MW->Entry()->grid(
   -row    => 1,
   -column => 1,
  );

# Widget Ecnp isa Entry
$ZWIDGETS{'Ecnp'} = $MW->Entry()->grid(
   -row    => 2,
   -column => 1,
  );

# Widget Add isa Button
$ZWIDGETS{'Add'} = $MW->Button(
   -text => 'Button1',
  )->grid(
   -row    => 0,
   -column => 2,
  );

# Widget Save isa Button
$ZWIDGETS{'Save'} = $MW->Button(
   -text => 'Button2',
  )->grid(
   -row    => 1,
   -column => 2,
  );

# Widget Close isa Button
$ZWIDGETS{'Close'} = $MW->Button(
   -text => 'Quit',
   -command => \&close,
  )->grid(
   -row    => 2,
   -column => 2,
  );

###############
#
# MainLoop
#
###############

MainLoop;

#######################
#
# Subroutines
#
#######################

sub ZloadImages {
}

sub ZloadFonts {
}

sub close {
	exit;
}
