=pod

=head1 ctkApplication

	Class ctkApplication models an application as used in the clickTk
	session.

=head2 Syntax

	my $appl = ctkApplication->new();

	$appl->open ;

	$appl->save;

	$appl->close;

=head2 Programming notes

=over

=item Still under construction

=back

=head2 Maintenance

	Author:	marco
	date:	18.04.2007
	History
			18.04.2007 MO03301 mam First draft
			29.11.2007 MO03502 Version 1.02
			03.08.2010 Version 1.03

=head2 Methods

	new
	destroy
	_init

	buildApplicationFileName

	trace
	Log
	log
	getDateAndTime

=cut

package ctkApplication;

use Time::localtime;

use base (qw/ctkBase/);

our $VERSION = 1.03;

our $debug = 0;

my $FS = 'ctkFile'->FS;		##  file separator

our $applName;

our $applFolder;

sub new {
	my $class = shift;
	my (%args) = @_;
	$class = ref($class) || $class ;
	my $self = {};
	bless  $self, $class;
	$self->_init(%args);

	return $self
}

sub destroy {
	my $self = shift;
}

sub _init {
	my $self = shift;
	my (%args) = @_;
	$self->clear();
	return 1
}

=head3 clear

	Clear the class variables applName and applFolder.
	It returns always 1.

=cut

sub clear {
	my $self = shift;
	$ctkApplication::applName   = '';
	$ctkApplication::applFolder = '';
	return 1
}


=head3 buildApplicationFileName

	Add the application path to the given project name
	and return it as a file path.

=cut

sub buildApplicationFileName {
	my $self = shift;
	my ($file) = @_ ;
	my $rv;
	$rv = &main::tail($file);
	$rv = "$applFolder$FS$rv" if ($applFolder);
	return $rv
}

=head2 setApplication

	Get application name and application folder.

	It returns true if the application has been set,
	undef otherwise.

=cut

sub setApplication {
	my $self = shift;
	my $rv;
	&main::trace("setApplication");
	my ($w1,$w2) = ($applName,$applFolder);
	$w2 =~ s/[\\\/]/$FS/g;
	if (&std::dlg_getApplicationParms(&main::getmw(),\$w1,\$w2)) {
		($applName,$applFolder) = ($w1,$w2);
		$applFolder =~ s/[\\\/]/\//g;		## must be unix like
		&main::changes(1);
		$rv = 1
	} else {}
	return $rv
}

## sub import {}

BEGIN { 1 }
END {1 }

1; ## -----------------------------------
