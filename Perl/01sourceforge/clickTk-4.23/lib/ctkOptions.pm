#!/usr/lib/perl
##              -w -d:ptkdb

=pod

=head1 ctkOptions

	Save and restore system options.

=head2 Programming notes

=over

=item Properties

	name
	options

=item Methods

	new
	save
	restore
	getconfigparam

=item Aggregate classes

	Data::Dumper
	ctkFile

=back

=head2 Maintenance

	Author:	MARCO
	date:	26.10.2006
	History
			26.10.2006 MO03001 mam First draft

=cut

package ctkOptions;

our $VERSION = 1.02;

our $debug = 0;

my $fName ='ctkConfigOptions.txt';

my $options ={};

require
1; ## -----------------------------------

sub new {
	my $class = shift;
	my $self ={};
	$self = bless $self, __PACKAGE__;
	$debug =  delete $args{debug} if (exists $args{debug});
	$self->_init(@_);
	return $self
}
sub destroy {
	my $self = shift;
	$self = {};
}

sub _init {
	my $self = shift;
	my (%args) = @_;
	my $rv;
	my $restore =  delete $args{restore} if (exists $args{restore});
	$options = $self->default unless $restore;
	$rv = $self->restore if ($restore);
	$self->save unless (-f $self->name);
	return $rv
}

sub debug {
	my $self = shift;
	$debug = shift if (@_);
	return ($debug) ? 1:0
}

sub name {
	return $fName
}

sub options {
	return $options
}

sub default {
	my $self = shift;
	return {
  'opt_isolate_geom' => 0,
  'opt_copyChildren' => 1,
  'geomMgr' => [
    'pack',
    'grid',
    'place',
    'form'
  ],
  'popupmenuTearoff' => 1,
  'initialGeometryPreview' => '=300x300+420+10',
  ## 'initialGeometry' => '=500x800+20+20',
  'initialGeometry' => '',
  'templateFolder' => 'templates',
  'opt_colorPicker' => 0,
  'opt_modalDialog' => 0,
  'HListDefaultHeight' => 30,
  'HListSelectMode' => 'single',
  'ctkPreview::opt_useToplevel' => 0,
  'main::ctkC' => '## ctk:',
  'main::cacheLogSize' => 2048,
  'imageFolder' => 'images',
  'MSWin32_editor' => 'C:/windows/system32/Notepad.exe', ## windows XP
   ## 'MSWin32_editor' => 'NOTEPAD.EXE', ## windows 98
  'MSWin32_explorer' => 'C:\\Programme\\Internet Explorer\\IEXPLORE.EXE',
  'HListDefaultWidth' => 32,
  'opt_fileHistory' => 10,
  'tempFolder' => 'temp',
  'ctkProject::noname' => 'noname.pl',
  'userid' => 'Tkadmin',
  'ctkTargetSub::subroutineName' => 'thisDialog',
  'ctkTargetSub::subroutineArgsName' => '%args',
  'opt_autoSave' => 1,
  'sessionFileNamePrefix' => 'ctk_session',
  'ctkProject::opt_modalDialogClassName' => 'DialogBox',
  'defaultGeometryManager' => 'pack',
  'xterm' => 'xterm',
  'widgetFolder' => 'widgets',
  'toolbarFolder' => 'toolbar',
  'ctkProject::projectFolder' => 'project',
  'MW' => 'mw',
  'editingCodeProperties' => 0,
  'ctkWork::workFolder' => 'work',
  'ctkTitle' => 'clickTk',
  'identPrefix' => 'wr_',
  'ctkLogFileName' => 'ctk_w_log.txt',
  'aix_editor' => 'nedit',
  'opt_defaultButtons' => '[qw(Ok Cancel)]',
  'autoEdit' => 1,
  'opt_autoRestore' => 0,
  'opt_askIdent' => 1,
  'opt_TestCode' => 1,
  'ctkApplication::applName' => '',
  'ctkApplication::applFolder' => '',
  'UNIX_editor' => 'nedit', 			## vi 
  'UNIX_explorer' => 'Netscape',
  'linux_editor' => 'gedit',
  'linux_explorer' => 'firefox',
  'ctkTargetSub::opt_defaultSubroutineArgs' => '-title , \'???\'',
  'ctkHelp::help_default' => 'tkpod', 
  'ctkHelp::help_win' => 'perldoc', 
  'ctkHelp::help_solaris' => '/usr/perl5/bin/perldoc',
  'ctkHelp::help_linux' => 'perldoc' 
}
}

sub save {
	my $self = shift;
	my $rv ;
	require Data::Dumper;
	my $f = ctkFile->new(fileName => $fName,debug => $debug);
	$f->backup();
	unless ($f->open('>')) {
		$self->log("Could not open '$file',options not saved.");
		return undef
	};
	$Data::Dumper::Indent = 1;		# turn indentation to a minimum
	my $s = Data::Dumper->Dump([$options],['rOptions']);
	$f->print($s);
	$f->close;
	$rv = 1;
	return $rv
}

sub restore {
	my $self = shift;
	my $rv ;
	my $f = ctkFile->new(fileName => $fName,debug => $debug);
	unless ($f->open ('<')) {
		$self->log("Could not open '$file', defaults appplied.");
		$options = $self->default;
		return undef
	}
	my @code =  $f->get;
	$f->close;
	my $rOptions = {};
	eval join ('',@code);
	if ($@) {
		$self->log( "Could not restore options '$file' because of'$@',defaults applied.");
		$options = $self->default;
	} else {
		%$options = %$rOptions;
		$rv = 1
	}
	return $rv
}

sub get {
	my $self = shift;
	my $opt = $self->options;
	my $p = shift;
	if (exists $opt->{$p}) {
		if (ref $opt->{$p} eq 'HASH') {
				return $self->getConfigParam(@_)
		} else {
				return $opt->{$p}
		}
	} else {
			die "Unknown options '$p'"
	}
	return undef
}

sub set {
	my $self = shift;
	my $opt = $self->options;
	my $p = shift;
	if (exists $opt->{$p}) {
		if (ref $opt->{$p} eq 'HASH') {
				return $self->set(@_)
		} else {
				$opt->{$p} = shift if (@_);
				return $opt->{$p};
		}
	} else {
			die "Unknown options '$p'"
	}
	return undef
}

sub Trace { shift->trace(@_);}
sub trace {
	shift->log(@_) if ($debug);
}

sub Log { shift->log(@_)}
sub log {
	my $self = shift;
	&main::log(@_)
}
