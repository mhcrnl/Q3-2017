
=pod

=head1 ctkCallback

	This package collects methods which apply to callbacks.

=head2 Programming notes

=over

=item This package is not yet a class.

=back

=head2 Maintenance

	Author:	MARCO
	date:	21.11.2007
	History
			21.11.2007 mam First draft

=cut

package ctkCallback;

use base (qw/ctkBase/);

our $VERSION = 1.01;

our $debug = 0;

my @user_methods;	# list
my @callbacks;
my @subroutineNames;

=head2 RO Properties

	user_methods     list of the method's names
	callbacks        list of the callbacks
	subroutineNames  list of the subroutine's names

	allCallbackNames list of all names (sorted ascending)

	All properties return array or ref to array depending on context

=cut

sub user_methods { return wantarray ? @user_methods : scalar(@user_methods )}
sub callbacks {return wantarray ? @callbacks : scalar(@callbacks) }
sub subroutineNames { wantarray ? @subroutineNames : scalar(@subroutineNames) }

sub allCallbackNames {
	return sort( @callbacks,@user_methods,@subroutineNames)
}

=head2 Clear properties

	clearSubroutineNames
	clearCallbacks
	clearUser_methods

=cut

sub clearSubroutineNames { @subroutineNames = () }
sub clearCallbacks { @callbacks = ()}
sub clearUser_methods { @user_methods = () }

sub clearAll {
	my $self = shift;
	$self->clearSubroutineNames;
	$self->clearCallbacks;
	$self->clearUser_methods
}

=head2 Method - checkCallbackOption

	Check if the entered callback code is supported.

=over

=item Supported code formats are

	format 1   \&callback
	format 2   [\&callback,args]  args := %name, @name,@_ lois of $vars
	format 4   ['callback',args]
	format 8   sub {codeblock} i.e. sub {$rc = 0 if($error); &do_exit($rc)}

=item Arguments

	String containing the callback code.

=item Returns

	Format number (1,2,4,8) of the recognized code or undef otherwise.

=item Notes

	None.

=back

=cut

sub checkCallbackOption {
	my $self = shift;
	my $arg = shift;
	my $rv;

	&main::trace("checkCallbackOption('$arg') :");
	$arg =~ s/^\s+//;	$arg =~s/\s+$//;
	$arg =~ s/\[\s+/[/; $arg =~ s/\s+\]$/]/;
	if ($arg =~ /^\\&[\$\w]\w+$/) {  ## support \&callback
		&main::trace("1 ok , format 1 (standard)");
		$rv = 1;
	} elsif ($arg =~ /^\[\\&(\w+::)*\w+(\s*\,\s*\$?\w+)*\]$/) {  ## support [\&callback,arg,...]
		&main::trace("2 ok , format 2");
		$rv = 2;
	} elsif ($arg =~ /^\[\$(\w+::)*\w+(\s*\,\s*\$?\w+)*\]$/) {  ## support [$callback,arg,...]
		&main::trace("2 ok , format 2");
		$rv = 2;
	} elsif ($arg =~ /^\[\\&\$?(\w+::)*\w+(\s*\,\s*[@%]\w+)*\]$/) {  ## support [\&callback,arg,...]
		&main::trace("2 ok , format 2");
		$rv = 2;
	} elsif ($arg =~ /^\[\\&\$?(\w+::)*\w+(\s*\,\s*@_)*\]$/) {  ## support [\&callback,arg,...]
		&main::trace("2 ok , format 2");
		$rv = 2;
	} elsif ($arg =~ /^\[\'(\w+::)*\w+\'(\s*\,\s*\\*[\$\w]\w+)*\]$/) {	## support ['callback',arg,...]
		&main::trace("4 ok  format 4");
		$rv = 4;
	} elsif ($arg =~ /^\[\'(\w+::)*\w+\'\s*\,\s*\@_\]$/) {	## support ['callback',@_]
		&main::trace("4 ok  format 4");
		$rv = 4;
	} elsif ($arg =~ /^\[\'(\w+::)*\w+\'(\s*\,\s*[%@]\w+)\]$/) {	## support ['callback',%\w+] or ['callback',@\w+]
		&main::trace("4 ok  format 4");
		$rv = 4;
	} elsif ($arg =~ /^\\*\&(\w+::)*\w+\s*\([^\)]*\)$/) {	## prevent \&callback(args)
		&main::trace("3 ok , invalid callback def (arglist!!!)");
		$rv = undef;
	} elsif ($arg =~ /^\s*sub\s*{\s*([^}]+)}\s*$/) {	## support sub{&callback(@_)}
		&main::trace("8 ok , format 8 anonimous code block");
		$rv = 8;
	} else {
		&main::trace("nok , unknown format ");
		$rv = undef
	}
	return($rv);
}

=head2 callback

	This methods handle command event while the clickTk session.
	It get called when the user clicks on a widget in the preview.
	It prevents that the application's callback, specified in the widget option get called.

=cut

sub callback {
	my $self = shift;
	my ($callback) = @_;
	&main::trace("callback");
	my $reply=&std::ShowDialogBox(-bitmap => 'question',
				-title => 'Callback trigger.',
				-text=> "This action triggered callback function <$callback>",
				-buttons=>['Close','Edit callbacks','Widget options','Help']
				);
	&main::file_callbacks if($reply eq 'Edit callbacks');
	&main::edit_widgetOptions if($reply eq 'Widget options');
	$main::help->tkpod('callbacks') if($reply eq 'Help');
}

=head2 pushCallback

=cut

sub pushCallback {
	my $self = shift;
	my (@args) = @_;
	&main::trace("pushCallback");
	foreach my $arg (@args) {
		next unless $arg;
		$arg="\\\&$arg" if ($arg=~/^\w/ && $arg !~ /^(sub[\s\{]|\[)/);
		my $format = $self->checkCallbackOption($arg);
		if (defined $format) {
			if($format == 1 ) {
				$arg =~ s/^\\\&//;
				push(@callbacks,$arg) unless(grep($arg eq $_, @callbacks) || grep($arg eq $_, @user_methods ));
			} elsif ($format == 2) {
				if ($arg =~ /\\\&(\w+)/ ) {
					my $x = $1;
					push(@callbacks,$x) unless(grep($x eq $_, @callbacks) || grep($x eq $_, @user_methods ));
				} else {}
			} else {}
		} else  {
			&std::ShowErrorDialog("'$arg':\nSyntax of this callback isn't supported, pls correct.",-buttons=>['Continue']);
		}
	}
}

=head2 extractSubroutines

=cut

sub extractSubroutines {
	my $self = shift;
	my ($code) = @_;
	&main::trace("extractSubroutines");
	$code =[] unless defined($code);
	my $n;
	clearSubroutineNames;
	map {
		## &main::pushCallback($n) if (defined($n = &main::extractCallbackName($_)))
		$self->pushSubroutineName($n)if (defined($n = $self->extractSubroutineName($_)))
		} @$code;
	return wantarray ? (@subroutineNames) : scalar(@subroutineNames);
}

=head2 extractSubroutineName

=cut

sub extractSubroutineName {
	my $self = shift;
	my ($line) = @_;
	&main::trace("extractSubroutineName");
	my $rv;
	$rv = $1 if ($line =~ /^\s*sub\s+([^\s\{]+)/);
	return $rv;
}

=head2 pushSubroutineName

=cut

sub pushSubroutineName {
	my $self = shift;
	my (@arg) = @_;
	&main::trace("pushSubroutineName");
	foreach my $arg (@arg) {
		next unless $arg;
		push(@subroutineNames,$arg) unless(grep($arg eq $_, @subroutineNames));
	}
}

=head2 extractMethods

=cut

sub extractMethods {
	my $self = shift;
	my ($code) = @_;
	&main::trace("extractMethods");
	$code =[] unless defined($code);
	my $n;
	$self->clearUser_methods;			## clear first
	map {
		$self->pushMethod($n) if (defined($n = $self->extractMethodName($_)))
	} @$code;
	return wantarray ? (@user_methods) : scalar(@user_methods);
}

=head2 extractMethodName

=cut

sub extractMethodName {
	my $self = shift;
	my ($line) = @_;
	&main::trace("extractMethodName");
	return $self->extractSubroutineName($line);
}

=head2 pushMethod

=cut

sub pushMethod {
	my $self = shift;
	my (@arg) = @_;
	&main::trace("pushMethod");
	foreach my $arg (@arg) {
		next unless $arg;
		push(@user_methods,$arg) unless (grep($arg eq $_, @user_methods) );
	}
}

=head2 extractMethodsAndSubroutineNames

=cut

sub extractMethodsAndSubroutineNames {
	my $self = shift;
	foreach my $line (@ctkProject::user_subroutines) {
			next unless ($line =~ /^\s*sub\s+/);
			my $n = $self->extractSubroutineName($line) ;
			$self->pushSubroutineName($n) if ($n);
	}

	foreach my $line (@ctkProject::user_methods_code) {
			next unless ($line =~ /^\s*sub\s+/);
			my $n =$self->extractMethodName($line);
			$self->pushMethod($n) if ($n);
	}
	foreach my $line (@ctkProject::other_code) {
			next unless ($line =~ /^\s*sub\s+/);
			my $n = $self->extractMethodName($line);
			$self->pushMethod($n) if ($n);
	}
	return
}

1; ## -----------------------------------

