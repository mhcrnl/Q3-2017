=pod

=head1 ctkpreviewDialogBox


	This composite replaces the standard modal dialog box
	during the clickTk session.
	Unlike the original dialog box it sets up a non modal dialog,
	but it applies the same subwidgets, arguments and appearance.
	Further more it allocate a Frame to host the widgets.
	This is due to the fact that these widgets may have a
	different geometry manager as the preview itself.

=head2 Syntax

		use ctkPreviewDialogBox;

		my $dlg = $mw->ctkPreviewDialogBox(<options>);		## same options as Tk::DialogBox

		$dlg->add(WidgetClass , <options>)-><geom manager(<args>);

		$dlg->Show();

=head2 Programming notes

=over

=item Base class

	Tk::DialogBox

=item Globals

	None.

=item Class data

	clipboard content (array of items)

=item Member data

	See Tk::DialogBox

=item Properties

	None.

=item Methods

	Show

=back

=head2 Maintenance

	Author:	Marco
	date:	27.10.2008
	History
		27.10.2008 mam First draft
		23.02.2013 version 1.02

=cut


use Tk;


package ctkPreviewDialogBox;
use vars qw($VERSION);
$VERSION = '1.02';
require Tk::DialogBox;
require Tk::Derived;


@ctkPreviewDialogBox::ISA = qw(Tk::Derived Tk::DialogBox);
Construct Tk::Widget 'ctkPreviewDialogBox';

sub ClassInit {
	my $self = shift;
	$self->SUPER::ClassInit(@_);
}

sub Populate {
	my ($self,$args) = @_;
	my $text = delete $args->{-text} if exists $args->{-text};
	my $bitmap = delete $args->{-bitmap} if exists $args->{-bitmap};
	$args->{-title} = 'clickTk preview pseudo-modal' unless exists $args->{-title};
	$args->{-buttons} = [qw (Ok Cancel)] unless(exists $args->{-buttons});
	$self->SUPER::Populate($args);

## 	 set up ConfigSpecs 	(optional)
	unless(defined $self->Subwidget('message')) {
		my $message = $self->Label(-text => $text, -relief , 'flat')->pack(-padx => 20, -pady => 20, -fill => 'x', -expand => 1);
		$self->Advertise('message' => $message);
		my $top = $self->Frame()->pack(-fill => 'both', -expand => 1);
		$self->Advertise('ctkTop' => $top);
	}
	return $self;
}

sub add {	## add widgets without advertising
	my $self = shift;
	my ($class,@args) = @_;
	$rv = $self->Subwidget('ctkTop')->$class(@args);
	return $rv;
}

sub Wait{1}


sub Show {
    my $self = shift;
    $self->Popup();
}

sub show {shift->Show(@_)}

1;	## make perl compiler happy...

