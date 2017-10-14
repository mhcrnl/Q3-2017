#!/usr/lib/perl
##              -w -d:ptkdb

=pod

=head1 ctkTools

	This module provides the processes of the menu item Tools

=head2 Programming notes

=over

=item Start session resp. projects on linux

	- start session from the terminal 

	  $ env PERL5LIB='/opt/ActivePerl-5.8/lib' perl -w ctk_w.pl -d

	- start terminal and start session

	  $ xterm -e env PERL5LIB='/opt/ActivePerl-5.8/lib' perl ctk_w.pl

	- start session and exec project

	  $ xterm -e env PERL5LIB='/opt/ActivePerl-5.8/lib' perl project/t_demoArgList.pl 

	Note: env command is used to select a specific perl version.

=back

=head2 Maintenance

	Author:	MARCO
	date:	01.01.2007
	History
			05.12.2007 refactoring
			19.12.2007 version 1.03
			13.03.2008 version 1.04
			18.03.2008 version 1.05
			14.04.2008 version 1.06

=cut

package ctkTools;

use strict;

use base (qw/ctkBase/);
our $VERSION = 1.06;


my $curEditor;
my $curExplorer;
my $autoSave;
my $xterm;

sub xterm {
	my $self = shift;
	$xterm = $_[0] if (@_);
	return $xterm
}

sub autoSave {
	my $self = shift;
	$autoSave = $_[0] if (@_);
	return $autoSave
}
sub curEditor  {
	my $self = shift;
	if (@_) {
		my (%args) = @_;
		$curEditor = ($^O =~ /^mswin/i) ? $args{-win} : 
			($^O  =~ /aix/i) ? $args{-aix} : 
			($^O  =~ /solaris/i) ? $args{-solaris} : 
			($^O  =~ /linux/i) ? $args{-linux} : $args{-unix};
	} else {}
	return $curEditor
}

sub curExplorer  {
	my $self = shift;
	if (@_) {
		my (%args) = @_;
		$curExplorer = ($^O =~ /win/i) ? $args{-win} : ($^O  =~ /aix|solaris|linux/i) ? $args{-aix} : $args{-unix};
	} else {}
	return $curExplorer
}

=head2 _do

	Execute the given command

		- save the project
		- build the command
		- launch the process
		- get the status code
		- and return it

=cut

sub _do {
	my $self = shift;
	my ($str,$title) = @_;
	my $rv;
	$self->trace("_do");
	&main::file_save() if ($autoSave);
	if (&main::isChanged()) {
		&std::ShowErrorDialog("Project could not be successfully saved!\n") ;
	} else {
		my $filepath = ctkProject->fileName($main::projectName);
		$str =~s /%%filepath%%/\"$filepath\"/g;
		$title="-T '$title' " if $title;
		if ($^O =~ /^mswin/i) {
			$self->trace("$str");
			$rv = system "$str";
			$rv >>= 8;
			$self->trace("rv = $rv");
		} elsif ($^O =~ /^solaris/i) {
			$self->trace("$str");
			$rv = system("$str");
			$rv >>= 8;
			$self->trace("rv = $rv");
		} elsif ($^O =~ /^linux/i) {
			$self->trace("$str");
			$rv = system("$str");
			$rv >>= 8;
			$self->trace("rv = $rv");
		} else {			
			$rv = system("$xterm $title -e $str");
			$rv >>= 8;
			$self->trace("rv = $rv");
		}
	}
	$self->trace("rv = $rv");
	
	return $rv
}

=head2 _edit

	Start the editor defined in $curEditor

=cut

sub _edit {
	my $self = shift;
	my $rv;
	$self->trace("_edit");

	unless (defined($curEditor)) {
		&std::ShowWarningDialog("Missing standard editor, cannot proceed.");
		return $rv ;
	}

	if ($^O =~ /^mswin/i) {
		 $rv = $self->_do("$curEditor %%filepath%%",'Editing');
	} else {
		 $rv = $self->_do("$curEditor %%filepath%% &",'Editing');
	}
	return $rv;
}

=head2 _syntax

	- Check the syntax of the target code.
	- Issue a dialog box depending on the status code of the process
	- Output of the check is on the STDOUT stream

=cut

sub _syntax {
	my $self = shift;
	my $rv;
	$self->trace("_syntax");

	my $opt = ($main::file_opt{'strict'}) ? '-c -w' : '-c';

	if ($^O =~ /^mswin/i) {
		$rv = $self->_do("$main::perlInterp $opt %%filepath%%",'Syntax check');
	} elsif($^O =~ /^linux/i) {
		$rv = $self->_do("$main::perlInterp -c %%filepath%%",'Syntax check');
	} elsif($^O =~ /^solaris/i) {
		$main::perlInterp =~ s/\.exe$//;
		$rv = $self->_do("$main::perlInterp -c %%filepath%% | more",'Syntax check');
	} else  {
		$self->Log("$^O not yet supported , cannot perform 'Syntax check'");
		return $rv
	}
	if ($rv) {
		&std::ShowWarningDialog("Syntax of '$main::projectName' seems to have some errors.\n\nSee STDOUT for details.");
	} else {
		&std::ShowInfoDialog("Syntax of '$main::projectName' seems to be OK.");
	}
	return $rv
}

=head2 _run

	- Execute (run) the target code of the project while the clickTk session.
		-check the OS
		-issue a command to start the Perl interpreter

	- Always return UNDEF.

=cut

sub _run {
	my $self = shift;
	$self->trace("_run");
	my $opt = ($main::file_opt{'strict'}) ? '-w' : '';
	if ($^O =~ /^mswin/i) {
		$self->_do("$main::perlInterp $opt %%filepath%%");
	} elsif($^O =~ /^linux/i) {
		$self->_do("$main::perlInterp $opt %%filepath%%");
	} elsif($^O =~ /^solaris/i) {
		$main::perlInterp =~ s/\.exe$//;
		$self->_do("$main::perlInterp $opt %%filepath%% | more");
	} else  {
		$self->Log("$^O not yet supported , cannot perform 'debug run'");
	}
	return undef
}
 
1; ## -----------------------------------

