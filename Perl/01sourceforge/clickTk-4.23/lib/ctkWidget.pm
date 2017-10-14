=pod

=head1 ctkWidget

	This class models a widget class in the clickTk environment.
	It extends the functionality of a widget with clickTk
	peculiar functions.

	Thus it can be used as base class to extend existing widget
	with clickTk functions.

=over

=item Methods

	- register

	- editOptions

=item Base class  

	- TkAnalysis
	- ctkBase

=item Class data member

	- debug

=item Data member 

	None.

=back

=head1 Methods

=cut

package ctkWidget;
use strict;
use base (qw/ctkBase/);

use vars qw($VERSION);
$VERSION = '1.02';

use ctkBase;
use Tk::Derived;
use TkAnalysis 1.09;

@ctkWidget::ISA = qw(Tk::Derived TkAnalysis ctkBase);

Construct Tk::Widget 'ctkWidget';

my $debug = 1;

sub ClassInit { 			# called just once per Mainwindow (composite widgets)!
	my $self = shift;
	$self->Trace("ClassInit called");
	$self->SUPER::ClassInit(@_); ## in order to activate the base class (resp widget)!

}
sub ObjectInit { 			# called just once per Mainwindow (only on derived widgets)!
	my $self = shift;
	$self->Trace("ObjectInit called");
	$self->SUPER::ObjectInit(@_); ## in order to activate the base class (resp widget)!
}

sub Populate {
	my ($self,$args) = @_;
	$self->Trace("Populate called");
	$self->{hwnd} = delete $args->{-hwnd};
	$self->SUPER::Populate($args);

}

sub _debug { shift; @_ ? $debug = shift : $debug }

=head2 CreateArgs

	This method can be used to add/check mandatory options
	or delete those options which may lead to exceptions/uncompatibilities.

=cut

sub CreateArgs { 
	my ($package, $parent, $args) = @_;
	$package->Trace("CreateArgs $package $parent $args");
	map {$package->Trace("$_ =" . $args->{$_})} sort keys %$args;
	my $newargs = %$args;
	%$newargs = %$args;
	## check/add/delete options depending on the needs of the composite
	$newargs = $package->SUPER::CreateArgs($newargs);
	map {$package->Trace("$_ =" . $newargs->{$_})} sort keys %$newargs;
	return $newargs; 
}

=head2 register

	This method is an example for the use of clickTk functions, in this
	case inherited from the base class TkAnalysis.

=cut

sub register {
	my $self =shift;
	my ($hwnd) = @_;
	$self->Trace("register");
	my $db = $hwnd->Dialog (-text => 'Register widget '.__PACKAGE__.'.',
							-title => 'Register widget',
							-buttons => [qw /view edit cancel/]);
	$db->Subwidget('B_view')->configure(-command =>[ sub {shift->viewCurrentOptions(@_)},$self,$db]);
	$db->Subwidget('B_edit')->configure(-command =>[ sub {shift->updateAllOptions(@_)},$self,$db]);

	$db->Show();
}

=head2 editOptions

	This method is a further example for the use of clickTk functions, in this
	case inherited from the base class TkAnalysis.

=cut

sub editOptions {
	my $self =shift;
	my ($hwnd) = @_;
	$self->Trace("editOptions");
	$self->viewCurrentOptions();
}

# -----------------------------------------------

sub Trace { shift->trace(@_);}
sub trace {
	shift->log(@_) if ($debug);
}

sub Log { shift->log(@_)}
sub log {
	my $self = shift;
	map {print STDERR "\n".__PACKAGE__." $_"} @_;
}

1; ## make perl happy ...!
