
=pod

=head1 ctkWork

	Class ctkWork models a work file as used in the clickTk
	session.

=head2 Syntax

	new 
	destroy  

	existsFolder 
	name  
	fileName  

	select 
	save 
	restore 

=head2 Programming notes

=over

=item Still under construction

=back

=head2 Maintenance

	Author:	marco
	date:	18.04.2007
	History
			18.04.2007 MO03301 mam First draft
			26.11.2007 version 1.02 refactoring
			14.03.2008 version 1.03 MO03602 (unix)
=cut

package ctkWork;

use ctkBase;
use ctkFile;
use base (qw/ctkFile ctkBase/);

our $VERSION = 1.03;

our $debug = 0;

our $workFolder; 		##  folder for dialogs 'on work'

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
	my $rv = (-d "$path$FS$workFolder") ? 1:0;
	return $rv
}

sub name {
	my $self = shift;
	my ($file) = @_ ;
	my $rv;
	$file = $main::projectName unless (defined($file));
	if ($file =~ /[\\\/]/) {
		$rv = &main::_name($file,$workFolder);
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
	return $file if ( $file =~ /^(\.[\\\/]){0,1}$workFolder/);
	$file = &main::tail($file);
	return ".$FS$workFolder$FS$file";
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

	if($^O =~ /(^mswin)|(^$)/i) {
		my @types = ( ["Work",'.pl'], ["All files", '.*'] );
		$file =~ s/\//\\/g;
		$file = $mw->getOpenFile(-filetypes => \@types,
								-initialfile => $file,
								-defaultextension => '.pl',
								-title=>&std::_title('Select work to be restored.'));
	} else {
		$file =~ s/\\/\//g;		## i MO03602
		my $initialDir = ctkFile->head($file);
		$file = $mw->FileSelect(-directory => $initialDir,
								-initialfile => $file,
								-title=>&std::_title('Select work to be restored.'))->Show;
	}
	$rv =  ($file) ? $self->name($file) : undef;
	return $rv
}
sub save {
	my $self = shift;
	my ($file,$s) = @_;
	my $rv;
	main::trace("save");
	my $data;
	my $f = ctkFile->new(fileName => $file,debug => $debug);
	$f->backup();
	unless ($f->open('>')) {
		return $rv
	};
	$f->print($s);
	$f->close;
	$rv = 1;
	return $rv
}

sub restore {
	my $self = shift;
	my ($file) = @_;
		$file = $self->fileName($file);
		&main::trace("Restoring work from '$file");
		my $f = ctkFile->new(fileName => $file,debug => $debug);
		unless ($f->open ('<')) {
			return undef
		}
		@rv =  $f->get;
		$f->close;
	return wantarray ? @rv : join('',@rv)
}

## sub import {}

BEGIN { 1 }
END {1 }

1; ## -----------------------------------
