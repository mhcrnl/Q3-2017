## ctk: description test framing
## ctk: title Framing
## ctk: application '' ''
## ctk: strict  0
## ctk: code  3
## ctk: testCode  1
## ctk: subroutineName dlgFraming
## ctk: autoExtractVariables  1
## ctk: autoExtract2Local  1
## ctk: modal 0
## ctk: buttons  
## ctk: baseClass  Tk::Frame
## ctk: isolGeom 0
## ctk: version 4.11
## ctk: onDeleteWindow  sub{exit(0)}
## ctk: Toplevel  1
## ctk: argList -label , "$0 - Test default arglist"   
## ctk: treewalk D 
## ctk: 2010 07 30 - 18:18:36

## ctk: uselib start

## ctk: uselib end

use Tk;
use Tk::Adjuster;
use Tk::Button;
use Tk::Frame;
use Tk::LabFrame;
use Tk::Label;
use Tk::Listbox;
use Tk::ROText;
 $mw=MainWindow->new(-title=>'Framing');


package ty_component;
use vars qw($VERSION);
$VERSION = '1.01';
require Tk::Frame;
require Tk::Derived;
@ty_component::ISA = qw(Tk::Derived Tk::Frame);
Construct Tk::Widget 'ty_component';
## ctk: Globalvars
## ctk: Globalvars end
sub ClassInit {
	my $self = shift;
##
## 	init class
##
	$self->SUPER::ClassInit(@_);

}
sub Populate {
	my ($self,$args) = @_;
##
## ctk: Localvars
## ctk: Localvars end
## 	move args to local variables)
##
	$self->SUPER::Populate($self->arglist($args));
##
##
my $mw = $self;
## ctk: code generated by ctk_w version '4.11' 
## ctk: instantiate and display widgets 

## ctk: widgets generated using treewalk D
$wr_006 = $mw -> Frame ( -relief , 'solid'  ) -> pack(-side=>'top', -anchor=>'nw', -fill=>'x', -expand=>1);

$wr_007 = $mw -> LabFrame ( -label , 'Actions' , -labelside , 'acrosstop'  ) -> pack(-side=>'top', -anchor=>'nw', -fill=>'x', -expand=>1);

$wr_008 = $wr_006 -> Frame ( -relief , 'solid'  ) -> pack(-side=>'top', -anchor=>'nw', -fill=>'both', -expand=>1);

$wr_009 = $wr_006 -> Frame ( -relief , 'solid'  ) -> pack(-side=>'top', -anchor=>'nw', -fill=>'both', -expand=>1);

$wr_010 = $wr_007 -> Frame ( -relief , 'solid'  ) -> pack(-side=>'top', -anchor=>'sw', -fill=>'x', -expand=>1);

$wr_011 = $wr_007 -> Frame ( -relief , 'flat'  ) -> pack(-side=>'bottom', -anchor=>'sw', -ipadx=>2, -ipady=>2, -fill=>'x', -expand=>1);

$wr_014 = $wr_008 -> Label ( -anchor , 'nw' , -background , '#c0c0c0' , -justify , 'left' , -text , 'Title' , -relief , 'flat'  ) -> pack(-side=>'left', -anchor=>'nw', -fill=>'x', -expand=>1);

$wr_015 = $wr_009 -> LabFrame ( -label , 'Data' , -labelside , 'acrosstop'  ) -> pack(-side=>'left', -anchor=>'nw', -fill=>'both', -expand=>1);

$wr_017 = $wr_010 -> Button ( -background , '#ffffff' , -state , 'normal' , -text , 'Ok' , -relief , 'raised'  ) -> pack(-side=>'left', -anchor=>'nw', -fill=>'x', -expand=>1, -padx=>2);

$wr_018 = $wr_010 -> Button ( -background , '#ffffff' , -state , 'normal' , -text , 'Cancel' , -relief , 'raised'  ) -> pack(-side=>'left', -anchor=>'nw', -fill=>'x', -expand=>1, -padx=>2);

$wr_012 = $wr_011 -> Label ( -anchor , 'nw' , -background , '#c0c0c0' , -borderwidth , 1 , -justify , 'left' , -text , 'Status' , -relief , 'flat'  ) -> pack(-side=>'left', -anchor=>'nw', -fill=>'x', -expand=>1);

$wr_020 = $wr_015 -> Listbox ( -selectmode , 'single' , -relief , 'sunken'  ) -> pack(-anchor=>'nw', -side=>'left', -fill=>'both', -expand=>1);

$wr_019 = $wr_015 -> ROText ( -state , 'normal' , -relief , 'sunken' , -wrap , 'none'  ) -> pack(-anchor=>'nw', -side=>'left', -fill=>'both', -expand=>1);

$wr_016 = $wr_020 -> packAdjust ( -side , 'left'  );

## ctk: end of gened Tk-code

## 	ctkTargetComposite->ConfigSpecs();
## 	$self->Delegates(); 	(optional)
	return $self;
}
## ctk: methods
sub arglist { 
	my $self = shift;
	my ($args) = @_;
	## move composite specific args to class variables
	return $args ## return $args for SUPER::Populate
}
## ctk: methods end

## ctk: testCode
# -----------------------------------------------
##
package main;
&main::init();
my (%args) =(-label , "$0 - Test default arglist"  );
my $toplevel = $mw->Toplevel();
my $instance = $toplevel->ty_component(%args)->pack();
$toplevel->protocol('WM_DELETE_WINDOW',sub{exit(0)});
MainLoop;
##
## ctk: testCode end

## ctk: callbacks
sub init { 1 }
## ctk: other code
## ctk: eof 2010 07 30 - 18:18:36
1;	## make perl compiler happy...

