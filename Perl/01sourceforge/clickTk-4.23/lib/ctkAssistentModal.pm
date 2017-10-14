#!/usr/bin/perl

=head1 ctkAssistent

	Unlike the base class ctkAssistent this class sets up
	the selection list for assisted values as a modal dialog.
	This may have some advantages, but usually it is not used.

	To use this mode simply adapt the constructor message in the dialog
	ctkDlgGetCode::Populate and ctkDialogs::dlg_getOrder.

=head2 Public interface

	my $assistent = ctkAssistentModal->new(-parent => $mw);

	$code = $assistent->Show();

=head2 Programmin notes

	None

=head2 Maintenance

	Author:	marco
	date:	07.03.2008
	History
			07.03.2008 varsion 1.01 , first draft.

=head2 Methods

=over

=item new

=back

=head2 Properties

	See base class.

=head2 Private methods

=over

=item _popupMenu4Values {
=item _execPopupmenu4Values {

=back

=cut

package ctkAssistentModal ;

use base (qw/ctkAssistent/);

use vars qw/$VERSION/;

$VERSION = 1.01;

=head2 new

		Create a new instance .
		It simply routes arguments to the base class.

=cut

sub new {
	my $class = shift;
	my (%args) = @_;
	return  $class->SUPER::new(%args);
}


=head2 _popupMenu4Values

	Set up the modal popup to select assisted values.

=over

=item Arguments

	- self,
	- ref to main window,
	- ref to text widget receiving the selected value.

	These args must be passed to the individual selection methods.

=item Return

	Ref to the popup menu

=item Notes

	Sasme as base class ctkAssistent


=back

=cut

sub _popupMenu4Values {
	my $self = shift;
	my ($mw,$text) = @_;
	my $rv=$mw->Dialog(-popover => 'cursor', -title => &std::_title('Assisted values'));
	my $callbacks = $self->assistedValues();

	foreach my $r (sort keys %$callbacks) {
		$rv->add('Button',-text=>$r,-command=>[$callbacks->{$r},$self,$mw,$text], -bg => 'white')->pack(-fill, 'x', -expand , 1);
	}
	$rv->overrideredirect(0);
	return $rv;
}

=head2 _execPopupmenu4Values

	Execute the popup menu to select assisted values.

=over

=item Arguments

	- self
	- ref to main window
	- ref to text widget receiving the selected value.

=item Return

	Always undef.

=item Notes

	- Popup has replaced Menubutton which didn't work properly.

=back

=cut

sub _execPopupmenu4Values {
	my $self = shift;
	my ($mw,$text) = @_;
	my $rv;
	my $popup = $self->_popupMenu4Values($mw,$text);
	my $x = $popup->Show();
	&main::trace("x = '$x'");
	return $rv
}


1; ## make perl happy ...
