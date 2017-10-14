
=head1 ctkSession

	The class ctkSession provides funtionalities related to session of any ctk script.

=head2 Base classes

	ctkFile
	ctkBase

=head2 Methods

=over

=item Public methods

	destroy
	new
	restartSession
	restore
	save
	save_changes
	sessionFileName

=item Private methods

	None.

=item Data member

	userid
	values

=item Class member

	VERSION
	debug
	sessionFileNamePrefix

=back

=cut

package ctkSession;

use vars (qw/$VERSION/);

use ctkFile 1.01;

use base (qw/ctkFile ctkBase/);

$VERSION = 1.04;

my $debug = 0;

my $sessionFileNamePrefix = 'ctk_session';

=head3 new

	Construct an instance of the type ctkSession.

	Arguments

		prefix
		userid
		values
		debug

	Notes

		None.

=cut


sub new {
	my $class = shift;
	my (%args) = @_;
	$class = ref $class || $class;
	my $self = $class->SUPER::new(%args);
	$debug = delete $args{debug} if (exists $args{debug});
	$self->{'userid'} = delete $args{'userid'} if (exists $args{'userid'});
	$self->{'values'} = delete $args{'values'} if (exists $args{'values'});
	$sessionFileNamePrefix = delete $args{'prefix'} if (exists $args{'prefix'});
	$self->fileName($self->sessionFileName());
	$self->trace("new $self");
	return $self
}

sub destroy {
	my $self = shift;
	$self->SUPER::destroy(@_);
}

=head3 sessionFileName

	Return the standard filename of the current session.

	The file name consists of

		prefix . '_' . userid . '.txt'

	Example : ctk_session_sysadmin.txt

=cut

sub sessionFileName {
	my $self = shift;
	my $userid = $self->{userid} ;
	return "${sessionFileNamePrefix}_$userid.txt";
}

sub save {
	my $self = shift;
	my (@values) = @_;
	my $rv;
	return 0 unless (@values);
	require Data::Dumper;
	$Data::Dumper::Indent = 1;		# turn indentation to a minimum
	$Data::Dumper::Purity = 1;
	my $s = Data::Dumper->Dump(@values);

	if ($self->open('>')) {
		$self->print($s);
		$self->close();
		$self->destroy();
		$rv = 1;
	} ## else {}
	return $rv;
}

sub restore {
	my $self = shift;
	require Data::Dumper;
	my $fName = $self->fileName();
	my $code;
	if (-f $self->sessionFileName()) {
		if ($self->open ('<')) {
			my @lines = $self->get;
			$self->close;
			$code = join('',@lines);
			eval $code;
			if ($@) {
				&main::Log("Could not restore session because of '$@'.");
				return undef ;
			}
			return 1;
		} else {
			return 0;
		}
	} else {
		&main::Log("Session not restored, session file didn't exist.")
	}
	return 1
}

sub save_changes {
	my $self = shift;
	my $rv;
	&main::trace("save_changes");
	if(&main::isChanged()) {   # ask for save
		my $reply=&std::ShowDialogBox(-bitmap=>'question',
							-text=>"Project '$main::projectName' not yet saved!\nDo you want to save the changes?",
							-title => 'Project changed.',
							-buttons => ["Save","Don't save", "Cancel"]);
		if ($reply eq 'Save') {
			$reply = &main::file_save();
			$rv = ($reply) ? 1 : 0;
		} elsif ($reply eq 'Cancel') {
			$rv = 0
		} else {
			$rv = 1 ;
		}
	} else {
		$rv = 1;
	}
	return $rv;		# Ok
}

=head3 restartSession

	Restart the session by means of Win32::Process .

	Arguments

		command (optional, default $0)
		file name (optional)

=cut

sub restartSession {
	my $self = shift;
	my ($command,$fName,$autoRestart) = @_ ;
	my $rv ;
	my $args = '';
	$args = '-x' if ($autoRestart);
	$args .= ' -d ' if ($debug);
	$args .= ' -t ' if (exists $cmdLineOpt{t} && $cmdLineOpt{t});

	$command ="$0" unless defined $command;
	return $rv unless ($^O =~ /win32/i);
	my $processObj ;
	$fName = '' unless defined $fName;
	$fName = '"'.$fName.'"' if($fName =~ /\S/);
no strict;
	$rv = Win32::Process::Create($processObj,
		"$command" ,
		"$command $args $fName",
		0,
		NORMAL_PRIORITY_CLASS,
		".");
	return $rv;
use strict;
}



BEGIN {1}
END{1}
1; ## make perl happy ...

=head2 Note

Dumper cannot handle array, ref to array must be passed!


2006 03 07 - 15:10:49                             $now->year+1900, $now->mon+1,$
now->mday,

2006 03 07 - 15:10:49                             $now->hour, $now->min, $now->s
ec) ;

2006 03 07 - 15:10:49   return $rv;

2006 03 07 - 15:10:49 }

2006 03 07 - 15:10:49
2006 03 07 - 15:10:55 xyz
2006 03 07 - 15:10:55 uvw
2006 03 07 - 15:10:55 ijkBareword found where operator expected at (eval 90)[../
/ctkSession.pm:95] line 2, near "$@main::previousFiles"
        (Missing operator before main::previousFiles?)

2006 03 07 - 15:12:09 Could not restore session because of 'syntax error at (eva
l 90)[..//ctkSession.pm:95] line 2, near "$@main::previousFiles "
'.
2006 03 07 - 15:13:05
2006 03 07 - 15:13:05 ctkFile_test.pl is exiting
Press any key to continue...

=cut
