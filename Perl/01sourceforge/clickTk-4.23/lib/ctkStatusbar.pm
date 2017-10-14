=pod

=head1 ctkStatusbar

	This module provides a statusbar for the clickTk main window.

=over

=item Methods

	ClassInit
	Populate
	message
	debug
	changes
	xy
	lastFile
	applName
	trace
	Log

=item Subwidgets

	message
	debug
	changes
	lastFile
	applName
	xy

=item Globals

	$main::debug
	$main::projectName
	$ctkApplication::applName
	$ctkPreview::xy

=back

=head2 Maintenance

	30.12.2006 first draft
	03.12.2007 version 1.02

=cut

package ctkStatusbar;

require Tk::Derived;
require Tk::Frame;                    # or Tk::Toplevel

@ISA = (qw/Tk::Derived Tk::Frame/);    # or Tk::Toplevel

our $VERSION = 1.02;

my $debug = 0;

Construct Tk::Widget 'ctkStatusbar';

sub ClassInit {
	my ($class,$mw) = @_;
	my $rv;
	#... e.g., class bindings here ...
	$rv = $class->SUPER::ClassInit($mw);
	return $rv;
}

sub Populate {
	my ($cw,$args) = @_;

	my @rv;

	## there are no flags to process, so go on

	$cw->SUPER::Populate($args);
	push @rv, $cw->Label(-text=>'No selection',-anchor => 'w',-relief=>'sunken',-borderwidth=>1)
	->pack(-side=>'left', -expand => 1, -fill => 'x',-padx=>2);
	push @rv, $cw->Label(-textvariable=>\$main::debug,-relief=>'sunken',-borderwidth=>1)
	->pack(-side=>'right',-padx=>2);
	push @rv, $cw->Label(-text=>'      ',-relief=>'sunken',-borderwidth=>1)
	->pack(-side=>'right',-padx=>2);
	push @rv, $cw->Label(-textvariable=>\$main::projectName,-relief=>'sunken',-borderwidth=>1)
	->pack(-side=>'right',-padx=>2);
	push @rv, $cw->Label(-textvariable=>\$ctkApplication::applName,-relief=>'sunken',-borderwidth=>1)
	->pack(-side=>'right');
	push @rv, $cw->Label(-textvariable=>\$ctkPreview::xy,-relief=>'sunken',-borderwidth=>1,-width=>11)
	->pack(-side=>'right',-padx=>2);

	$cw->Advertise ('message' => $rv[0]);
	$cw->Advertise ('debug' => $rv[1]);
	$cw->Advertise ('changes' => $rv[2]);
	$cw->Advertise ('lastFile' => $rv[3]);
	$cw->Advertise ('applName' => $rv[4]);
	$cw->Advertise ('xy' => $rv[5]);

	return $cw
}


sub message {
	my ($self,$value) = @_;
	my $rv = $self->Subwidget('message')->configure(-text);
	if (@_ > 1) {
		$self->Subwidget('message')->configure(-text => $value);
	}
	return $rv
}

sub debug {
	my ($self,$value) = @_;
	my $rv = $self->Subwidget('debug')->configure(-text);
	if (@_ > 1) {
		$self->Subwidget('debug')->configure(-text => $value);
	}
	return $rv
}
sub changes {
	my ($self,$value) = @_;
	my $rv = $self->Subwidget('changes')->configure(-text);
	if (@_ > 1) {
		$self->Subwidget('changes')->configure(-text => $value);
	}
	return $rv
}
sub xy {
	my ($self,$value) = @_;
	my $rv = $self->Subwidget('xy')->configure(-text);
	if (@_ > 1) {
		$self->Subwidget('xy')->configure(-text => $value);
	}
	return $rv
}
sub lastFile {
	my ($self,$value) = @_;
	my $rv = $self->Subwidget('lastFile')->configure(-text);
	if (@_ > 1) {
		$self->Subwidget('lastFile')->configure(-text => $value);
	}
	return $rv
}
sub applName {
	my ($self,$value) = @_;
	my $rv = $self->Subwidget('applName')->configure(-text);
	if (@_ > 1) {
		$self->Subwidget('applName')->configure(-text => $value);
	}
	return $rv
}

## -------------------

sub Trace { shift->trace(@_);}
sub trace {
	shift->log(@_) if ($debug);
}

sub Log { shift->log(@_)}
sub log {
	my $self = shift;
	map {print STDERR "\n$_"} @_;
}

1;
__END__



