=head1 Tk::ctkTiler

	This mega-wigdget expands the standard Tiler class with
	the methods

	- clear
	- clearAll

	and the property

	- Slaves

=head2 Syntax

	my $t = $mw->ctkTiler(<options>); ## options for Tk::Tiler

	$t->clear(<ref to widget>); ## widget get first destroyed and then deleted from the Tiler

	$t->clearAll(); ## all widgets currently managed by the Tiler get destroyed and deleted from the Tiler widget.

=head2 Maintenance

	Author:	marco
	date:	04.11.2013
	History
			04.11.2013 P106 first draft

=head2 Methods

=cut

package Tk::ctkTiler;
require Tk;
require Tk::Frame;
require Tk::Tiler;

use vars qw($VERSION);
$VERSION = '1.01';

use base  qw(Tk::Tiler);

Construct Tk::Widget 'ctkTiler';

use Tk::Pretty;

=head3 property Slaves

	This property returns in array context the list of the widgets currently
	displayed on the Tiler or the nnumber of these widgets in scalar context.

=cut

sub Slaves {
	my $m = shift;
	return wantarray ? @{$m->{'Slaves'}} : scalar($m->{'Slaves'});
}
sub Populate
{
 my ($obj,$args) = @_;
 $obj->SUPER::Populate($args);
 return $obj;
}

=head3 clear

	Destroy the given widget and delete it from the Tiler widget.


=over

=item Arguments

		-ref to the widget to be deleted

=item Return code

		1 if the specified has been successfully processed,
		0 otherwise .

=item Progamming note

		If you want to delete a widget from the Tiler, which has already been
		destroyed, the you may issue the message LostSlave(<destroyed widget>);

		If you issue LostSlave specifying a widget that still exists then you will
		enter a messy state of the Tiler.

		Remember that Tk::Tiler updates the widget at the next idle state.

=back

=cut

sub clear {
 my ($m,$s) = @_;
	return 0 unless defined $s;
	$s->destroy() if(Tk::Exists($s));
	$m->LostSlave($s);
	return 1
}

=head3 clearAll {

	Send a 'clear' message to the Tiler widget for all
	widget currently shown on the Tiler.


=over

=item Arguments

		None.
=item Return code

		Always returns 1 .

=item Programming note

	After this message the property Slaves returns a empty array.

=back

=cut

sub clearAll {
	my $m = shift;
	my @slaves = @{$m->Slaves};
	map {
		$m->clear($_);
	} @slaves;
	return 1
}

1;
