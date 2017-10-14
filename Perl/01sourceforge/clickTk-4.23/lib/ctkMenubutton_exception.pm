=pod

=head1 tk_derived_widget_skeleton

	This module provides a skeleton to build derived widgets.

	Pls note:

	- Write derived widgets only to enhance the funtionality of the
	  base widget, i.e. adding new options or new methods.

	- Write composite widgets to build assemble widgets to a new widget.

=cut

package ctkMenubutton_exception;

use vars qw($VERSION);
$VERSION = '1.01';

require Tk::Menubutton;
## require Tk::Derived;
# @ISA = qw(Tk::Derived Tk::Menubutton); 
@ISA = qw(Tk::Menubutton);

Construct Tk::Widget 'ctkMenubutton_exception';

my $debug = 1;

sub InitClass {			# called just once per Mainwindow!
	my $self = shift;
	my ($mw) = @_;
	Trace("InitClass called (ctkMenubutton_exception)");
	$self->SUPER::InitClass(@_); ## in order to activate the base class (resp widget)!

}

sub InitObject {			# called just once per Mainwindow!
	my $self = shift;
	$self->Trace("InitObject called (ctkMenubutton_exception)");
	$self->SUPER::InitObject(@_); ## in order to activate the base class (resp widget)!
}

sub Populate {
	my $self = shift;
	my ($args) = @_;		## <==== $args is of ref to HASH
	Trace("Populate  (ctkMenubutton_exception)");

	$self->SUPER::Populate($args);
	$self->ConfigSpecs(-menuitems => [SELF, 'menuitems', 'Menuitems', undef]); 
	return $self;
}

sub _debug { shift; @_ ? $debug = shift : $debug }

##
## pls code here specific methods
##

# -----------------------------------------------

sub Trace { &trace(@_);}
sub trace {
	&log(@_) if ($debug);
}

sub Log { &log(@_)}
sub log { 
	map {print STDERR "\n\t",__PACKAGE__, ' ',$_} @_;
}

1; ## make perl happy ...!

=head1 NAME

    ctkMenubutton - Specialized version of Menubutton

=head1 SYNOPSIS

	use ctkMenubutton;
	$widget = $parent->ctkMenubutton(<args for Menubutton>, -activeOnState => <programstate>);

=head1 DESCRIPTION

	This class expands Tk::Menubutton with the ability to define an arguments that
	controls its state. The value of this argument speecifies the programstates which
	require the menu item have to be available.

	This arguments is saved in the Menu structure and is checked by ctkMenu::updateMenu, which
	usually get called when the mainloop is idle.


=head2 Exception

	---------- Execute perl script ----------

	Subroutine Tk::Error redefined at ctk_w.pl line 1193.

	2007 11 23 - 12:19:34 . , C:\Perl\bin\perl.exe
	2007 11 23 - 12:19:34 ctk_w.pl starting under 'MSWin32'
	2007 11 23 - 12:19:34 Session 'Tkadmin' successfully restored.
	2007 11 23 - 12:19:34 Version '3.099'
	2007 11 23 - 12:19:35 DEBUG: widget 'MainWindow=HASH(0x258afd8)'
	2007 11 23 - 12:19:35 error 'Can't set -menuitems to `ARRAY(0x29c4db0)' for ctkMenubutton=HASH(0x29c5c50): Bad option `-menuitems' at C:/Perl/site/lib/Tk/Configure.pm line 46.
	 at C:/Perl/site/lib/Tk/Derived.pm line 294
	'
	2007 11 23 - 12:19:35  from 
	2007 11 23 - 12:19:35 Tk callback for .errordialog.scrollbar
	2007 11 23 - 12:19:35 Tk callback for .frame.frame.ctkmenubutton
	2007 11 23 - 12:19:35 Tk::Derived::configure at C:/Perl/site/lib/Tk/Derived.pm line 306
	2007 11 23 - 12:19:35 Tk::Widget::new at C:/Perl/site/lib/Tk/Widget.pm line 196
	2007 11 23 - 12:19:35 Tk::Widget::__ANON__ at C:/Perl/site/lib/Tk/Widget.pm line 247
	2007 11 23 - 12:19:35 ctkMenu::setupMenu at lib/ctkMenu.pm line 174Can't set -menuitems to `ARRAY(0x29c4db0)' for ctkMenubutton=HASH(0x29c5c50): Bad option `-menuitems' at C:/Perl/site/lib/Tk/Configure.pm line 46.
	 at C:/Perl/site/lib/Tk/Derived.pm line 294

	 at C:/Perl/site/lib/Tk/Derived.pm line 306

	ctk_w.pl ended 
	Output completed (2 sec consumed) - Normal Termination

=head3 Reason

	Tk::Derived do not initialize the Object as expected.
	Option -menuitems get deleted from the args and saved locally in MenuButton::InitObject.

=head3 Solution

	Do not specify Tk::Derived as base class, specify only Tk::Menubutton instead

=head3 Unit test

---------- Execute perl script ----------

	Subroutine Tk::Error redefined at ctk_w.pl line 1193.

	2007 11 23 - 18:46:28 . , C:\Perl\bin\perl.exe
	2007 11 23 - 18:46:28 ctk_w.pl starting under 'MSWin32'
	2007 11 23 - 18:46:28 Session 'Tkadmin' successfully restored.
	2007 11 23 - 18:46:28 Version '3.099'
		ctkMenubutton ClassInit called (ctkMenubutton)
		ctkMenubutton ctkMenubutton=HASH(0x29d0fc0)
		ctkMenubutton InitObject called (ctkMenubutton)
		ctkMenubutton_exception InitClass called (ctkMenubutton_exception)
		ctkMenubutton_exception ctkMenubutton_exception=HASH(0x29d034c)
		ctkMenubutton_exception InitObject called (ctkMenubutton_exception)
		ctkMenubutton ClassInit called (ctkMenubutton)
		ctkMenubutton ctkMenubutton=HASH(0x29ceefc)
		ctkMenubutton InitObject called (ctkMenubutton)
		ctkMenubutton ClassInit called (ctkMenubutton)
		ctkMenubutton ctkMenubutton=HASH(0x29dcf04)
		ctkMenubutton InitObject called (ctkMenubutton)
		ctkMenubutton ClassInit called (ctkMenubutton)
		ctkMenubutton ctkMenubutton=HASH(0x29eaa94)
		ctkMenubutton InitObject called (ctkMenubutton)
		ctkMenubutton ClassInit called (ctkMenubutton)
		ctkMenubutton ctkMenubutton=HASH(0x29efcec)
		ctkMenubutton InitObject called (ctkMenubutton)
		ctkMenubutton ClassInit called (ctkMenubutton)
		ctkMenubutton ctkMenubutton=HASH(0x29f6d30)
		ctkMenubutton InitObject called (ctkMenubutton)Use of uninitialized value in concatenation (.) or string at ctk_w.pl line 629.
	Use of uninitialized value in concatenation (.) or string at ctk_w.pl line 629.

	2007 11 23 - 18:46:31 Session 'Tkadmin' successfully saved.
	ctk_w.pl ended 
	Output completed (5 sec consumed) - Normal Termination

=cut

