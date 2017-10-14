=pod

=head1 ctkHelp

	This class models the Help system of clickTk.

=head2 Programming notes

=over

=item Win32::process is used to display help documents.

=back

=head2 Maintenance

	Author:	MARCO
	date:	21.11.2007
	History
		21.11.2007 mam version 1.03 refactoring
		22.02.2008 mam support for non-windows platforms
		04.03.2008 mam version 1.05 support unix platforms
		14.04.2008 mam version 1.06
		04.11.2013 mam version 1.07 ctkpodW

=head2 Methods
=cut


package ctkHelp;


use File::Spec;

$debug = 0;

use vars qw/$VERSION/;

$VERSION = 1.07;

our $help_default = 'tkpod';
our $help_win ;
our $help_solaris;
our $help_linux ;

my %helpWidgets = ();

my $tempFolder = 'temp';

my $obj = {};

my @htl =();

BEGIN {
if ($^O =~ /win32/i) {
	require Win32; 'Win32'->import;
	require Win32::Process;'Win32::Process'->import;
} else {}
}

END { }

sub new {
	my ($class) = shift;
	my (%args) = @_;
	$class = ref($class) || $class;
	my $self = {};
	$self = bless $self , $class;
	$self->{hwnd} = $args{hwnd} if (exists $args{hwnd});
	$debug = $args{debug} if (exists $args{debug});
	$tempFolder = $args{tempFolder} if (exists $args{tempFolder});
	return $self;
}

sub destroy {
	my $self = shift;
	$self ={};
}

sub _debug { shift; @_ ? $debug = shift : $debug }

=head3 cleanup

	Clean up all displayed help toplevels listed in class variable %helpWidgets

=cut

sub cleanup {
	my $self = shift;
	my ($widget) = @_;
	if (exists $helpWidgets{$widget}) {
		$helpWidgets{$widget}->destroy();
		delete $helpWidgets{$widget}
		##TODO: delete from @htl
	} else {
		## OK, that's not pretty well but there is not enough to die ...
	}
}

=head3 tkpodCallback

	Send tkpod message .

=cut

sub tkpodCallback {
	my $self = shift;
	my $widget = shift;
	$self->tkpod(@_);
}

=head3 tkpod

	Send message widgetHelp or showHelp depending o the existence
	of the given ident.
	If none has been given then main::selected get used.

=cut

sub tkpod {
	my $self = shift;
	my ($id,$tk,$parent) = @_;
	&main::trace("ctkHelp::tkpod");
	map {&main::trace("'$_' ")} @_ if $debug;

	unless ($id) {
		$id = &main::getSelected ;			# default if no argument
		$id =~ s/.*\.//;					# clean up when 'selected' used
	}
	$parent = main::getmw() unless(defined($parent));
	my $d = &main::getDescriptor;
	if (exists $d->{$id}) {
		$self->widgetHelp($id,$tk,$parent);
	} else {
		$self->showHelp($id,$tk,$parent);
	}
}

=head3 tkpodW

	This methos asks the user for the class it want to get
	help.
	Then it sent the message tkpod to show the help text.

=cut


sub tkpodW {
	my $self = shift;
	my ($id,$tk,$parent) = @_;
	&main::trace("ctkHelp::tkpodW");
	map {&main::trace("'$_' ")} @_ if $debug;

	$parent = main::getmw() unless(defined($parent));

	$id = &std::dlg_getWidgetClass($parent,'-widgets',[sort keys(%{&main::getW_attr})]); ## select widget first
	return undef unless(defined($id));
		$self->showHelp($id,$tk,$parent);
}

=head2 widgetHelp

	Set up args and send showHelp message.

=cut

sub widgetHelp {
	my $self = shift;

	my ($id,$tk,$parent) = @_;

	&main::trace("ctkHelp::widgetHelp");

	my $d = &main::getDescriptor;
	my $widget = '';
	if ($id eq $main::MW) {
		$widget='MainWindow'
	} else {
		$widget = $d->{$id}->type if ($d->{$id}->type =~ /^[a-zA-Z]/); 	# for real widgets!
		$widget = $1 if ($widget =~ /^Scrolled([\w_]+)/);
		$widget='Adjuster' if $d->{$id}->type eq 'packAdjust';
		$widget='NoteBook' if $d->{$id}->type eq 'NoteBookFrame';
		$widget = $id unless $widget;
	}
	$self->showHelp($widget,$tk,$parent);
}

=head2 showHelp

	Show the given help documentation.

	Work horse for widgetHelp.

	- check if help already exists
	- set up Toplevel if Tk specified
		- load and display POD text using ROText
	- set up a process if Tk not given
		- load POD
		- write to temp file
		- start up process
			- start ctk_h.pl if it exists,
			- start cur_editor otherwise

=cut

sub showHelp {
	my $self = shift;

	my ($widget,$tk,$parent) = @_;

	&main::trace("ctkHelp::showHelp");

	if (main::Exists($helpWidgets{$widget})) {
		$helpWidgets{$widget}->deiconify();
		return
	}
	my $FS = ctkFile::FS;
	my $podFname = "$tempFolder$FS".'tkpod_output_';

	$parent->Busy;
	my $pod_util = 	($^O =~ /(win)|(^$)/i) ? $help_win :
			($^O =~ /solaris/i) ? $help_solaris :
			($^O =~ /linux/i) ? $help_linux : $help_default;

	return  unless defined $pod_util;
	if(defined($tk)) {
		my ($tl,$t);
		local *POD;
		$tl = $parent->Toplevel(-title => "Help for $widget");
		$t = $tl->Scrolled('ROText',-scrollbars => 'se', font => 'C_normal')->pack(-side => 'top',-anchor => 'nw', -expand => 1, -fill => 'both');
		$tl->protocol(WM_DELETE_WINDOW => ['ctkHelp::cleanup',$self,$widget]);
		push @htl,$tl;
		open(POD,"$pod_util Tk::$widget|");
		my $n = 0;
		while (<POD>) {
			$t->insert('end',$_); $n++
		}
		close POD;
		unless ($n) {
			$t->insert('end',"Could not build help information\n\nProbably $widget do not have POD section\nor it cannot be located.");
		}
		$helpWidgets {$widget} = $tl;
	} else {
		open(POD,"$pod_util Tk::$widget|");
		my $n = 0;
		my @lines =();
		while (<POD>) {
			push @lines,$_; $n++
		}
		close POD;

		unless ($n) {
			@lines = ("Could not build help information",
						"\n\n",
				"Probably $widget do not have POD section",
				"\n",
				"or it cannot be located.");
		} else {}

		if ($^O =~ /win/i) {
			my $f = ctkFile->new(fileName => "$podFname$widget");
			$f->open('>');
			$f->print(@lines) ;
			$f->close;
			@lines=();
			if (-e 'ctk_w_h.pl') {
				$self->process("perl ctk_w_h.pl $podFname$widget") if (-f "$podFname$widget");
			} else {
				if ($^O =~ /win/i) {
					$self->process(ctkTools->curEditor(),"$podFname$widget") if (-f "$podFname$widget");
				} else {
					$self->process(ctkTools->curEditor(),"$podFname$widget")  if (-f "$podFname$widget");
				}
			}
		} elsif($^O =~ /solaris/i) {
			my ($tl,$t);
			local *POD;
			$tl = main::getmw()->Toplevel(-title => "Help $widget");
			$t = $tl->Scrolled('ROText',-scrollbars => 'se', font => 'C_normal',-width => 98)->pack(-side => 'top',-anchor => 'nw', -expand => 1, -fill => 'both');
			$tl->protocol(WM_DELETE_WINDOW => ['ctkHelp::cleanup',$self,$userDoc]);
			push @htl,$tl;

			my $width = 0;

			if (@lines) {
				map {
					s/^\t+/ /; s/\r$//;
					$width = length($_) if($width < length($_));
					$t->insert('end',$_); $n++
				} @lines;
			} else {
				$t->insert('end',"Could not build help information.");
			}
			$t->configure(-width , $width);
			$helpWidgets {$userDoc} = $tl;
		} elsif($^O =~ /linux/i) {
			my ($tl,$t);
			local *POD;
			$tl = main::getmw()->Toplevel(-title => "Help $widget");
			$t = $tl->Scrolled('ROText',-scrollbars => 'se', font => 'C_normal',-width => 98)->pack(-side => 'top',-anchor => 'nw', -expand => 1, -fill => 'both');
			$tl->protocol(WM_DELETE_WINDOW => ['ctkHelp::cleanup',$self,$userDoc]);
			push @htl,$tl;

			my $width = 0;
			if (@lines) {
				map {
					s/^\t+/ /; s/\r$//;
					$width = length($_) if($width < length($_));
					$t->insert('end',$_); $n++
				} @lines;
			} else {
				$t->insert('end',"Could not build help information.");
			}
			$t->configure(-width , $width);
			$helpWidgets {$userDoc} = $tl;
		} else {
		}
	}
	$parent->Unbusy;
}

=head2 errorReport

	Write the WIN32 message to clickTk logfile.

=cut

sub errorReport {
	my $self = shift;
	if ($^O =~ /win32/i) {
		&main::Log(Win32::FormatMessage( Win32::GetLastError() ));
	} else {}
}

=head2 process

	Set up a process to view ASCII files with notepad.

=cut

sub process {
	my $self = shift;
	my ($command,$fName) = @_ ;
	my $rv ;
	my $processObj ;

	return $rv unless ($^O =~ /win32/i);

	Win32::Process::KillProcess($obj->{$fName}->[1], 0) if (exists $obj->{$fName});
	$rv = Win32::Process::Create($processObj,
		"$command",
		"notepad $fName",
		0,
		NORMAL_PRIORITY_CLASS,
		".");
	if ($rv) {
		$obj->{$fName} = [$processObj,$processObj->GetProcessID()];
	} else {
		$self->errorReport
	}
	return $rv ;
}

=head2 process1

	Same as process but not specialized for notepad .

=cut

sub process1 {
	my $self = shift;
	my ($command,$fName) = @_ ;
	my $rv ;

	return $rv unless ($^O =~ /win32/i);

	my $processObj ;
	Win32::Process::KillProcess($obj->{$fName}->[1], 0) if (exists $obj->{$fName});
	$rv = Win32::Process::Create($processObj,
		"$command",
		"\"$command\" \"$fName\"",
		0,
		NORMAL_PRIORITY_CLASS,
		".");
	if ($rv) {
		$obj->{$fName} = [$processObj,$processObj->GetProcessID()];
	} else {
		$self->errorReport
	}
	return $rv ;
}

=head2 killAll

	Kill all help processes listed in class variable %obj

=cut

sub killAll {
	my $self = shift;
	my $rv;

	while (@htl) {
		my $w = pop @htl;
		$w->destroy if(Tk::Exists($w));
	}

	%helpWidgets = () ;

	return $rv unless ($^O =~ /win32/i);

	map {
		## $obj->{$_}->kill(0);		## error 'Your vendor has not defined Win32::Process macro kill, used at ctkHelp.pm line 191. at C:/Perl/site/lib/Win32/Process.pm line 47.
		Win32::Process::KillProcess($obj->{$_}->[1], 0);
		delete $obj->{$_};
	} keys %$obj;
	return $rv
}

sub userDoc {
	my $self = shift;
	&main::trace("help");
	my $userDoc = 'doc/userDoc/user_doc';
	return if (exists $helpWidgets {$userDoc});
	if ($^O =~/win/i) {
		if (-f "$userDoc.html") {
			$userDoc = File::Spec->rel2abs("$userDoc.html");
			return $self->process1(ctkTools->curExplorer(),$userDoc)
		} elsif (-f "$userDoc.txt"){
			$userDoc = File::Spec->rel2abs("$userDoc.txt");
			return $self->process(ctkTools->curEditor(),$userDoc);
		} else {
			return undef
		}
	} elsif ($^O =~/solaris/i) {
		return undef unless -f "$userDoc.txt";
		my ($tl,$t);
		local *POD;
		$tl = main::getmw()->Toplevel(-title => "Help ");
		$t = $tl->Scrolled('ROText',-scrollbars => 'se', font => 'C_normal'-width => 98)->pack(-side => 'top',-anchor => 'nw', -expand => 1, -fill => 'both');
		$tl->protocol(WM_DELETE_WINDOW => ['ctkHelp::cleanup',$self,$userDoc]);
		push @htl,$tl;
		open(POD,"$userDoc.txt");
		my $n = 0;
		my $width =0;
		while (<POD>) {
			s/\r$//;
			$width = length($_) if($width < length($_));
			$t->insert('end',$_); $n++
		}
		close POD;
		unless ($n) {
			$t->insert('end',"Could not build help information.");
		}
		$t->configure(-width , $width);
		$helpWidgets {$userDoc} = $tl;
	} elsif ($^O =~/^linux/i) {
		return undef unless -f "$userDoc.txt";
		my ($tl,$t);
		local *POD;
		$tl = main::getmw()->Toplevel(-title => "Help ");
		$t = $tl->Scrolled('ROText',-scrollbars => 'se', font => 'C_normal',-width => 98)->pack(-side => 'top',-anchor => 'nw', -expand => 1, -fill => 'both');
		$tl->protocol(WM_DELETE_WINDOW => ['ctkHelp::cleanup',$self,$userDoc]);
		push @htl,$tl;
		open(POD,"$userDoc.txt");
		my $n = 0;
		my $width = 0;
		while (<POD>) {
			s/^\t+/ /; s/\r$//;
			$width = length($_) if($width < length($_));
			$t->insert('end',$_); $n++
		}
		close POD;
		unless ($n) {
			$t->insert('end',"Could not build help information.");
		}
		$t->configure(-width , $width);
		$helpWidgets {$userDoc} = $tl;
	} else {}
	return undef
}

1; ## make perl happy ...!
