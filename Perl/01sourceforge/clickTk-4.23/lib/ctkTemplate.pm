=pod

=head1 ctkTemplate

	Class ctkTemplate models a template file as used in the clickTk
	session.

=head2 Syntax



=head2 Programming notes

=over

=item Still under construction

=back

=head2 Maintenance

	Author:	marco
	date:	17.12.2007
	History
			17.12.2007 first draft
			14.03.2008 version 1.02 MO03602 (unix)

=cut

package ctkTemplate;

use ctkBase;
use ctkFile;
use base (qw/ctkFile ctkBase/);

our $VERSION = 1.02;

our $debug = 0;

our $templateFolder; 		##  folder for dialogs 'on work'

my $FS = ctkFile->FS;

sub new {
	my $class = shift;
	my (%args) = @_;
	$class = ref($class) || $class ;
	my $self = $class->SUPER::new(%args);
	bless  $self, $class;
	$self->_init(%args);

	return $self
}

sub destroy {
	my $self = shift;
	$self->SUPER::destroy(@_);
}

sub _init {
	my $self = shift;
	my (%args) = @_;
	## $self->SUPER::_init(%args);

	return 1
}

sub existsFolder {
	my $self = shift;
	my ($path) = @_;
	my $rv = (-d "$path$FS$templateFolder") ? 1:0;
	return $rv
}

sub name {
	my $self = shift;
	my ($file) = @_ ;
	my $rv;
	$file = $main::projectName unless (defined($file));
	if ($file =~ /[\\\/]/) {
		$rv = &main::_name($file,$templateFolder);
	} else {
		$rv = $file
	}
	return $rv
}

sub fileName {
	my $self = shift;
	my ($file) = @_ ;
	&main::trace("fileName");
	$file = ctkProject->noname unless(defined($file));
	return $file if ( $file =~ /^(\.[\\\/]){0,1}$templateFolder/);
	$file = &main::tail($file);
	return ".$FS$templateFolder$FS$file";
}

sub select {
	my $self = shift ;
	my ($mw,$file,$force) = @_;
	my $rv;
	&main::trace("select");
	if($force) {
		if (-f $self->fileName($file)) {
			return $file
		} else {
			return undef
		}
	} ## else {}

	if($^O =~/(^mswin)|(^$)/i) {
		my @types = ( ["Template",'.pl'], ["All files", '.*'] );
		$file =~ s/\//\\/g;
		$file = $mw->getOpenFile(-filetypes => \@types,
								-initialfile => $file,
								-defaultextension => '.pl',
								-title=>&std::_title('Select template to be used.'));
	} else {
		$file =~ s/\\/\//g;		## i MO03602
		my $initialDir = ctkFile->head($file);
		$file = $mw->FileSelect(-directory => $initialDir,
								-initialfile => $file,
								-title=>&std::_title('Select template to be used.'))->Show;
	}
	$rv =  ($file) ? $self->name($file) : undef;
	return $rv
}

## sub import {}

BEGIN { 1 }
END {1 }

1; ## -----------------------------------
