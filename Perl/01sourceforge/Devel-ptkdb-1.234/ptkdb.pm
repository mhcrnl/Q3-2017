
package DB ;

use strict;
##
## Expedient fix for Perl 5.8.0.  True DB::DB is further down.
##
sub DB {}

my $debug = 0;

our $sleeping = 0; ## set this flag on to short cut ptkdb

our $sessionPID;

sub debug () { return $debug }

sub setDebugMode  { $debug = shift if (@_); return $debug }

sub Trace { &DB::trace(@_);}
sub trace {
	&DB::log(@_) if (DB::debug);
}

sub Log { &DB::log(@_)}
sub log {
	return unless($Devel::ptkdb::verbose);
	local *OUT = ($Devel::ptkdb::log_into_STDERR) ? *STDERR : *STDOUT;
	map {
		print OUT "\nptkdb - $_\n";
		# $DB::window->{'log_page_text'}->insert('end',"$_\n") if ($DB::window && $Devel::ptkdb::use_log_page && defined($DB::window->{'log_page_text'}) && Tk::Exists($DB::window->{'log_page_text'}));
	} @_;
}

use Tk qw(:eventtypes);

# ---------------------------------------------------------------------------
#
# ptkdb Perl Tk Perl Debugger
#
# Copyright 2010,2011 Version 1.2xx Marco Marazzi,Zurich Switzerland
# Copyright 2007 by Svetoslav Marinov
# Copyright 1998, 2003, Andrew E. Page
# All rights reserved.
#
# This program is free software; you can redistribute it and/or modify
# it under the terms of either:
#
# a) the GNU General Public License as published by the Free
# Software Foundation; either version 1, or (at your option) any
# later version, or
#
# b) the "Artistic License" which comes with this kit.
#
#    This program is distributed in the hope that it will be useful,
#    but WITHOUT ANY WARRANTY; without even the implied warranty of
#    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See either
#    the GNU General Public License or the Artistic License for more details.
#
# ---------------------------------------------------------------------------

use vars qw($VERSION @dbline %dbline);

#
# This package is the main_window object for the debugger.
# We start with the Devel::prefix because we want to install
# it with the DB:: package that is required to be in a Devel/
# subdir of a directory in the @INC set.
#
package Devel::ptkdb ;

##
## do this check once, rather than repeating the string comparison again and again
##

my $isWin32 = $^O eq 'MSWin32' ;


#
## Perform a check to see if we have the Tk library, if not, attempt
## to load it for the user.
#

sub BEGIN {

eval {require Tk  ; };
if( $@ ) {
print << "__PTKDBTK_INSTALL__" ;
***
*** The PerlTk library could not be found.  Ptkdb requires the PerlTk library.
***
Preferably Tk800.015 or better:

In order to install this the following conditions must be met:

1.  You have to have access to a C compiler.
2.  You must have sufficient permissions to install the libraries on your system.

To install PerlTk:

a  Download the Tk library source from http://www.perl.com/CPAN/modules/by-category/08_User_Interfaces/Tk
b  Uncompress the archive and run "perl Makefile.PL"
c  run "make install"

If this process completes successfully ptkdb should be operational now.

We can attempt to run the CPAN module for you.  This will, after some questions, download
and install the Tk library automatically.

Would you like to run the CPAN module? (y/n)
__PTKDBTK_INSTALL__

my $answer = <STDIN> ;
chomp $answer ;
if( $answer =~ /y|yes/i) {
	require CPAN ;
	CPAN::install Tk ;
} # if

} # if $@

# TODO: Check if under running Windows and Apache, if Apache has rights to interact with desktop
# Start -> Run -> services.msc -> Choose Apache -> Log On [Allow service to interact with desktop]
} # end of sub BEGIN

sub END {
	return unless ($DB::sessionPID eq $$);
	&DB::trace( "END block " .  __PACKAGE__);
	DB::dlg_showTrace_cancel($DB::window->{'trace_window'}) if(exists $DB::window->{'trace_window'} && defined($DB::window->{'trace_window'})) ;
	my $hwnd ;
	unless ($DB::no_stop_at_end) {
		$hwnd = Devel::ptkdb::get_Main_Window();
		$DB::window->setStatus2('session end');	#
		my $ans = DB::dlg_endSession($hwnd,$DB::window->{'dirtyFlag'});
		if ($ans) {
			Devel::ptkdb::DoRestart();## spawn the session again
		} else {
		## terminate session
		}
		DB::dlg_showTrace_cancel($hwnd) ;
	}
	$hwnd->destroy if(Tk::Exists($hwnd));
}

use 5.004;
use Tk 800 qw(:eventtypes);
use Data::Dumper ;
use FileHandle ;

require Tk::Dialog;
require Tk::TextUndo ;
require Tk::ROText;
require Tk::NoteBook ;
require Tk::HList ;
require Tk::Table ;
require Tk::BrowseEntry;
require Tk::Checkbutton;

use vars qw(@dbline) ;

use Config ;

sub OpenURL { # Opens given URL
	my ($context)  = @_;
	my %URLS = (
		'home'            => 'http://ptkdb.sourceforge.net',
		'feature_request' => 'http://sourceforge.net/tracker/?atid=437612&group_id=43854&func=browse',
		'bug_report'      => 'http://sourceforge.net/tracker/?atid=437609&group_id=43854&func=browse',
		'mail_list'       => 'http://lists.sourceforge.net/lists/listinfo/ptkdb-user',
		);
	if (exists $URLS{$context}) {
		my $url = $URLS{$context};
		if ($isWin32) {
			# Executing "start http://domain.com" it will start the default browser.
			system(qq!start "ptkdb url title" "$url"!);
		} else {
			my (@browsers) = qw/netscape mozilla/ ;
			my ($fh, $pid, $sh);
			$sh = 'sh' ;
			$fh = new FileHandle() ;

			for (@browsers) {
				$pid = open($fh, qq!$sh $_ "$URLS{ $context }" 2&> /dev/null |!) ;
				sleep(2);
				waitpid $pid, 0 ;
				return if ($? == 0) ;
				}
		}
	} else {
		warn "Unknown Context '$context'.";
	}
} ## end of OpenURL

#
# Check to see if the package actually
# exists. If it does import the routines
# and return a true value ;
#
# NOTE:  this needs to be above the 'BEGIN' subroutine,
# otherwise it will not have been compiled by the time
# that it is called by sub BEGIN.
#
sub check_avail {
	my ($file,$package, @list) = @_ ;

	eval {
		require $file ; import $package @list ;
	} ;

	return 0 if $@ ;
	return 1 ;
} # end of check_avail

sub takeOverFontEnvVar {
	my $eVar = shift;
	my @rv = ();
	if (exists $ENV{$eVar}) {
		my $opt = $ENV{$eVar};
		$opt =~s /^[\'\"]//;$opt =~s /[\'\"]$//; ## unquote
		@rv = eval "(-font,[$opt])";
		warn "$eVar is incorrect, discarded.\n$@" if($@);
	} else {
		## nothing to do
	}
	return wantarray ? @rv : scalar(@rv)
}

sub BEGIN {

$DB::sessionPID = $$;
$DB::on = 0 ;

$DB::subroutine_depth = 0 ; # our subroutine depth counter
$DB::step_over_depth = -1 ;

$DB::brkpt_filter = {
	'action' , '1',         ## 1: set breakpoint , 2: trace
	'expr' , ' ',           ## no expression
	'fname' , $0,           ## started script
	'lineno' , 1,           ## line 1
	'package' ,'main',      ## package main
	'state' , 1				## active
	};
@DB::condbrkptList  = ();
@DB::brkonsubList   = ();
@DB::condbrkptList  = ();
@DB::brkptList = ();
#
# the bindings and font specs for these operations have been placed here
# to make them accessible to people who might want to customize the
# operations.  REF The 'bind.html' file, included in the PerlTk FAQ has
# a fairly good explanation of the binding syntax.
#

#
# These lists of key bindings will be applied
# to the "Step In", "Step Out", "Return" Commands
#
$Devel::ptkdb::pathSep = '\x00' ;
$Devel::ptkdb::pathSepReplacement = "\0x01" ;

@Devel::ptkdb::step_in_keys = ( '<Shift-F9>', '<Alt-s>', '<Button-3>' ) ; # step into a subroutine
@Devel::ptkdb::step_over_keys = ( '<F9>', '<Alt-n>', '<Shift-Button-3>' ) ; # step over a subroutine
@Devel::ptkdb::return_keys   = ( '<Alt-u>', '<Control-Button-3>' ) ; # return from a subroutine
@Devel::ptkdb::toggle_breakpt_keys = ( '<Alt-b>' ) ; # set or unset a breakpoint

# Fonts used in the displays

#
# NOTE:   The environmental variable syntax here works like this:
# $ENV{'NAME'} accesses the environmental variable "NAME"
#
# $ENV{'NAME'} || 'string' results in  $ENV{'NAME'} or 'string' if  $ENV{'NAME'} is not defined.
#
#
@Devel::ptkdb::fontSizeList = (8,10,12);


@Devel::ptkdb::button_font = (exists $ENV{'PTKDB_BUTTON_FONT'}) ? takeOverFontEnvVar('PTKDB_BUTTON_FONT') : () ; # font for buttons
@Devel::ptkdb::code_text_font = (exists $ENV{'PTKDB_CODE_FONT'}) ? takeOverFontEnvVar('PTKDB_CODE_FONT') : ("-font" => [qw(-family Courier -size 10)]) ;

@Devel::ptkdb::expression_text_font = (exists$ENV{'PTKDB_EXPRESSION_FONT'}) ? takeOverFontEnvVar('PTKDB_EXPRESSION_FONT') : ("-font" => [qw(-family Courier -size 10)]) ;
@Devel::ptkdb::eval_text_font = (exists $ENV{'PTKDB_EVAL_FONT'}) ? takeOverFontEnvVar('PTKDB_EVAL_FONT') : ("-font" => [qw(-family Courier -size 10)]) ; # text for the expression eval window

$Devel::ptkdb::geometry = (exists $ENV{'PTKDB_GEOMETRY'}) || "800x600";
$Devel::ptkdb::eval_dump_indent = $ENV{'PTKDB_EVAL_DUMP_INDENT'} || 1 ;

$Devel::ptkdb::Entry_Class = $ENV{'PTKDB_ENTRY_CLASS'} || 'browseEntry' ;

$Devel::ptkdb::trace_array_size = (exists $ENV{'PTKDB_TRACE_ARRAY_SIZE'}) ? $ENV{'PTKDB_TRACE_ARRAY_SIZE'} : 512 ;
$Devel::ptkdb::trace_array_size_saved  =  0;
$Devel::ptkdb::trace_active = ($Devel::ptkdb::trace_array_size) ? 1 : 0;
$Devel::ptkdb::trace_sub_active = (exists $ENV{'PTKDB_TRACE_SUB_ACTIVE'}) ? $ENV{'PTKDB_TRACE_SUB_ACTIVE'} : 0 ;
$Devel::ptkdb::trace_expressions = (exists $ENV{'PTKDB_TRACE_EXPRESSIONS'}) ? $ENV{'PTKDB_TRACE_EXPRESSIONS'} : 0 ;
$Devel::ptkdb::verbose = (exists $ENV{'PTKDB_VERBOSE'}) ? $ENV{'PTKDB_VERBOSE'} : 1 ;
$Devel::ptkdb::use_log_page = (exists $ENV{'PTKDB_USE_LOG_PAGE'}) ? $ENV{'PTKDB_USE_LOG_PAGE'} : 1 ;
$Devel::ptkdb::use_log_page = 0 unless($Devel::ptkdb::verbose);
$Devel::ptkdb::log_into_STDERR = (exists $ENV{'PTKDB_LOG_INTO_STDERR'}) ? $ENV{'PTKDB_LOG_INTO_STDERR'} : 1 ;


$Devel::ptkdb::iconify = $ENV{'PTKDB_ICONIFY'} || 0 ;

$Devel::ptkdb::allow_calls_in_expr_list = $ENV{'PTKBD_ALLOW_CALLS_IN_EXPR_LIST'} || 0;

$Devel::ptkdb::balloon = $ENV{'PTKDB_BALLOON'} || 1;
$Devel::ptkdb::balloon_time = $ENV{'PTKDB_BALLOON_TIME'} || 300;
$Devel::ptkdb::balloon_background = $ENV{'PTKDB_BALLOON_BACKGROUND'} || '#CCFFFF';
$Devel::ptkdb::codeside = $ENV{'PTKDB_CODE_SIDE'} || 'left' ;
$Devel::ptkdb::codeside = 'left' unless ($Devel::ptkdb::codeside =~/^(left|right|top|bottom)/);

$Devel::ptkdb::decorate_code = (exists $ENV{'PTKDB_DECORATE_CODE'}) ? $ENV{'PTKDB_DECORATE_CODE'} : 0 ;

#
# Windows users are more used to having scroll bars on the right.
# If they've set PTKDB_SCROLLBARS_ONRIGHT to a non-zero value
# this will configure our scrolled windows with scrollbars on the right
#
# this can also be done by setting:
#
# ptkdb*scrollbars: se
#
# in the .Xdefaults/.Xresources file on X based systems
#
@Devel::ptkdb::scrollbar_cfg = ('-scrollbars' => 'se'); ## don't use 'osoe' !!!
if (exists $ENV{'PTKDB_SCROLLBARS_ONRIGHT'}) {
	if ($ENV{'PTKDB_SCROLLBARS_ONRIGHT'} ) {
		@Devel::ptkdb::scrollbar_cfg = ('-scrollbars' => 'se') ;
	} else {
		@Devel::ptkdb::scrollbar_cfg = ( ) ;
	}
}

#
# Controls how far an expression result will be 'decomposed'.   Setting it
# to 0 will take it down only one level, setting it to -1 will make it
# decompose it all the way down. However, if you have a situation where
# an element is a ref   back to the array or a root of the array
# you could hang the debugger by making it recursively evaluate an expression
#
$Devel::ptkdb::expr_depth = -1 ;
$Devel::ptkdb::add_expr_depth = $ENV{'PTKDB_ADD_EXPR_DEPTH'} || 1 ; # how much further to expand an expression when clicked
$Devel::ptkdb::savedPathForSee = '';

$Devel::ptkdb::linenumber_format = $ENV{'PTKDB_LINENUMBER_FORMAT'} || "%05d " ;
$Devel::ptkdb::linenumber_length = 5 ;

$Devel::ptkdb::linenumber_offset = length sprintf($Devel::ptkdb::linenumber_format, 0) ;
$Devel::ptkdb::linenumber_offset -= 1 ;

#
# Check to see if "Data Dumper" is available
# if it is we can save breakpoints and other
# various "functions". This call will also
# load the subroutines needed.
#
$Devel::ptkdb::DataDumperAvailable = 1 ; # assuming that it is now
$Devel::ptkdb::useDataDumperForEval = $Devel::ptkdb::DataDumperAvailable ;

$Devel::ptkdb::showProximityWindow = $ENV{'PTKDB_SHOWPROXIMITYWINDOW'} || 1;
$Devel::ptkdb::proximityWindowInitialDepth = $ENV{'PTKDB_PROXIMITYWINDOWINITIALDEPTH'} || 0;
$Devel::ptkdb::savedProximityPathForSee = '';
#
# DB Options (things not directly involving the window)
#

# Flag to disable us from intercepting $SIG{'INT'} and $SIG{'__DIE__'}

$DB::sigint_disable = exists $ENV{'PTKDB_SIGINT_DISABLE'} && $ENV{'PTKDB_SIGINT_DISABLE'} ;

$DB::sigdie_disable = exists $ENV{'PTKDB_SIGDIE_DISABLE'} && $ENV{'PTKDB_SIGDIE_DISABLE'};

$DB::autostep_delay_time = exists $ENV{'PTKDB_AUTOSTEP_DELAY_TIME'} ? $ENV{'PTKDB_AUTOSTEP_DELAY_TIME'} : 1500;

$DB::controlC_disable = exists $ENV{'PTKDB_CTRLC_DISABLE'} ? $ENV{'PTKDB_CTRLC_DISABLE'} : 1;

$DB::autostep = 0;


$DB::balloon_msg_max_length = exists $ENV{'PTKDB_BALLOON_MSG_MAX_LENGTH'} ? $ENV{'PTKDB_BALLOON_MSG_MAX_LENGTH'} : 256;
#
# Possibly for debugging Perl CGI Web scripts on
# remote machines.
#
$ENV{'DISPLAY'} = $ENV{'PTKDB_DISPLAY'} if exists $ENV{'PTKDB_DISPLAY'} ;

} # end of BEGIN

##
## subroutine for the commands allowed in the ptkdbrc files
##

sub __brkpt {   # set breakpoint at the given lines
	my ($fname, @idx) = @_ ;
	my($offset) ;
	return unless exists $main::{'_<' . $fname};
	local(*dbline) = $main::{'_<' . $fname} ;
	my @brkptList =();

	$offset = $dbline[1] =~ /use\s+.*Devel::_?ptkdb/ ? 1 : 0 ;

	for( sort @idx ) {
		if( !&DB::checkdbline($fname, $_ + $offset) ) {
		DB::log("__brkpt $fname line $_ is not breakable, discarded") ;
		next ;
		}
		push @brkptList , ($_,1,'') ;
	}
	$DB::window->insertBreakpointList($fname, @brkptList) ;
} # end of __brkpt

sub _brkpt {
	for (@_) {
		my $list = $_;
		__brkpt(@$list)
	}
}

sub brkpt {
	my @list = @_;
	push @DB::brkptList , [@list];
}

sub __condbrkpt {		# Set conditional breakpoint(s)
	my $fname = shift ;
	my ($offset) ;
	return unless	exists $main::{'_<'	. $fname};
	local(*dbline) = $main::{'_<'	. $fname} ;
	my @brkptList	=();

	$offset =	$dbline[1] =~ /use\s+.*Devel::_?ptkdb/ ? 1 : 0 ;

	while( @_	) {	# arg loop
		my($index, $expr) =	splice @_, 0, 2	; #	take args 2	at a time
		if(	!&DB::checkdbline($fname, $index + $offset)	) {
		DB::log("__condbrkpt $fname line $index is not breakable, discarded") ;
		next ;
		}
		push @brkptList	, ($index, 1, $expr)
	}	# end of arg loop
	$DB::window->insertBreakpointList($fname,	@brkptList)	;

} #	end	of __condbrkpt

sub _condbrkpt {  ## obsolete ?
	foreach (@_) {
		my $list = $_;
		__condbrkpt(@$list)
	}
}

sub condbrkpt {
	my @list = @_;
	push @DB::condbrkptList , [@list];
}

sub _brkonsub { # set breakpoint at the first line of the given sub
	my($names) = @_ ;
	my %brkptList =();
	for( my $i = scalar(@$names) - 1; $i >= 0; $i-- ) {
		if( !exists $DB::sub{$names->[$i]} ) {
		DB::trace("No subroutine $_.  Try main::$_") ;
		next ;
		}
		# get the filename and line number range of the target subroutine
		if ($DB::sub{$names->[$i]} =~ /(.*):([0-9]+)-([0-9]+)$/o) { # file name will be in $1, start line $2, end line $3
		my ($fname,$start,$end) = ($1,$2,$3);
		for( my $line = $start; $line <= $end; $line++ ) {
			next unless(&DB::checkdbline($fname, $line)) ;
			if (exists $brkptList{$fname }) {
			push @{$brkptList{$fname }} , $line
			} else {
			$brkptList{$fname }=  [$line];
			}
			splice @$names, $i,1 ;
			last ; # only need the one breakpoint
		}
		} else {}
	} # end of name loop
	map { ## subs may be on different files
		my $fname = $_;
		my @bList =();
		map {
		push @bList,($_,1,'');
		} @{$brkptList{$fname}};
		$DB::window->insertBreakpointList($fname, @bList) ;
	} sort keys %brkptList;
} # end of _brkonsub

sub brkonsub {
	map {
		my $name = $_;
		$name ="main::$name" unless ($name =~/\:\:/); ## sub name must be like this 'Tk::do_something'
		push @DB::brkonsubList , $name unless( grep /^$name/,@DB::brkonsubList);
	} @_;
}

sub brkonsub_regex { # set breakpoints on subroutines matching a regex
	my(@regexps) = @_ ;
	my($regexp, @subList) ;

	#
	# be adviced: this process may accumulate a huge amount of
	#             items and dramatically slow down the session !
	#
	foreach $regexp ( @regexps ) {
		study $regexp ;
		map {
			push @subList, $_ if ($_ =~ $regexp) ;
		} keys %DB::sub;
	} # end of brkonsub_regex
	brkonsub(@subList) ; # set breakpoints on matching subroutines
} # end of brkonsub_regex


sub textTagConfigure {
	my ($tag, @config) = @_ ;
	$DB::window->{'text'}->tagConfigure($tag, @config) ;
} # end of textTagConfigure

sub setTabs { # Change the tabs in the text field
	my $self = shift;
	return unless (@_);
	$self->{'text'}->configure(-tabs => [ @_ ]) ;
}

sub add_exprs { # add expressions to the expression list window
	push @{$DB::window->{'expr_list'}}, map { 'expr' => $_, 'depth' => $Devel::ptkdb::expr_depth }, @_ ;
	map {
		$_->{'expr'} =~ s/^\s+//; $_->{'expr'} =~ s/\s+$//;
	}@{$DB::window->{'expr_list'}};
} # end of add_exprs


##
## register a subroutines that will be called whenever
## ptkdb sets up it's windows
##

sub _validatePtkdbrcRegisterItem {
	my $r = ref($_[0]);
	return ($r =~/^\s*$/ || $r eq 'CODE') ? 1 : 0;
}

sub register_user_window_init {
	map {
		if (_validatePtkdbrcRegisterItem($_)) {
			push @{$DB::window->{'user_window_init_list'}}, $_ ;
		} else {
			DB::log("Unexpected type of 'window init', item discarded.");
		}
	} @_;
} # end of register_user_window_init

##
## register a subroutines that will be called whenever
## ptkdb sets up it's windows
##

sub register_user_window_end {
	map {
		if (_validatePtkdbrcRegisterItem($_)) {
			push @{$DB::window->{'user_window_end_list'}}, $_ ;
		} else {
			DB::log("Unexpected type of 'window end', item discarded.");
		}
	} @_;
} # end of register_user_window_init


##
## register a subroutines that will be called whenever
## ptkdb enters from code
##

sub register_user_DB_entry {
	map {
		if (_validatePtkdbrcRegisterItem($_)) {
			push @{$DB::window->{'user_window_DB_entry_list'}}, $_ ;
		} else {
			DB::log("Unexpected type of 'DB entry', item discarded.");
		}
	} @_;
} # end of register_user_DB_entry

sub register_user_DB_leave {
	map {
		if (_validatePtkdbrcRegisterItem($_)) {
			push @{$DB::window->{'user_window_DB_leave_list'}}, $_ ;
		} else {
			DB::log("Unexpected type of  'DB leave' , item discarded.");
		}
	} @_;
} # end of register_user_DB_leave

sub register_user_restart_entry {
	map {
		if (_validatePtkdbrcRegisterItem($_)) {
			push @{$DB::window->{'user_restart_list'}}, $_ ;
		} else {
			DB::log("Unexpected type of 'restart' , item discarded.");
		}
	} @_;
} # register_user_restart_entry

sub get_notebook_widget {
	return $DB::window->{'notebook'} ;
} # end of get_notebook_widget

#

#
sub doEvalPtkdbrc { # Run existing ptkdbrc files
	use vars qw($dbg_window) ;
	local $dbg_window = shift ;

	eval {
		do "$Config{'installprivlib'}/Devel/ptkdbrc" ;
		DB::log("User init file .ptkdbrc failed: $@") if ($@);
	} if -e "$Config{'installprivlib'}/Devel/ptkdbrc" ;
	if( $@ ) {
		DB::log("System init file $Config{'installprivlib'}/ptkdbrc failed: $@") ;
	}

	eval {
		do "$ENV{'HOME'}/.ptkdbrc" ;
		DB::log("User init file .ptkdbrc failed: $@") if ($@);
	} if exists $ENV{'HOME'} && -e "$ENV{'HOME'}/.ptkdbrc" ;
	if( $@ ) {
		DB::log("User init file $ENV{'HOME'}/.ptkdbrc failed: $@") ;
	}

	eval {
		do ".ptkdbrc" ;
		DB::log("User init file .ptkdbrc failed: $@") if ($@);
	} if -e ".ptkdbrc" ;

	if( $@ ) {
		DB::log("User init file .ptkdbrc failed: $@") ;
	}
	&set_stop_on_warning() ;
} # end of doEvalPtkdbrc

sub new { # Constructor for our Devel::ptkdb
	my($type) = @_ ;
	my($self) = {} ;

	bless $self, $type ;

	# Current position of the executing program

	$self->{'DisableOnLeave'} = [] ; # List o' Widgets to disable when leaving the debugger

	$self->{'current_file'} = "" ;
	$self->{'current_line'} = -1 ; # initial value indicating we haven't set our line/tag
	$self->{'window_pos_offset'} = 10 ; # when we enter how far from the top of the text are we positioned down
	$self->{'search_start'} = "0.0" ;
	$self->{'fwdOrBack'} = 1 ;
	$self->{'searchRegexp'} = 0 ;
	$self->{'searchExact'} = 1;
	$self->{'searchHistory'} = [];
	$self->{'gotoHistory'} = [];
	$self->{'BookMarksPath'} = $ENV{'PTKDB_BOOKMARKS_PATH'} || "$ENV{'HOME'}/.ptkdb_bookmarks" || '.ptkdb_bookmarks'  ;

	$self->{'expr_list'} = [] ; # list of expressions to eval in our window fields:  {'expr'} The expr itself {'depth'} expansion depth


	$self->{'brkPtCnt'} = 0 ;
	$self->{'brkPtSlots'} = [] ; # open slots for adding breakpoints to the table

	$self->{'main_window'} = undef ;

	$self->{'user_window_init_list'} = [] ;
	$self->{'user_window_end_list'} = [] ;
	$self->{'user_window_DB_entry_list'} = [] ;
	$self->{'user_window_DB_leave_list'} = [] ;

	$self->{'user_restart_list'} = [];

	$self->{'subs_list_cnt'} = 0 ;
	$self->{'dirtyFlag'} = 0 ;
	$self->{'eventMask'} = 'all' ;
	## $self->{'eventMask'} = 'dont_wait window idle' ;

	$self->setup_main_window() ;

	return $self ;

} # end of new

sub setup_main_window {
	my($self) = @_ ;
	my $mw = MainWindow->new() ; # Main Window

	$mw->protocol ('WM_DELETE_WINDOW',sub { $self->DoQuit()});
	$self->{'main_window'} = $mw ;
	$self->{'main_window'}->withdraw();
	$self->{'main_window'}->geometry($Devel::ptkdb::geometry) ;

	$self->setup_options() ; # must be done after MainWindow and before other frames are setup

	# $self->{'main_window'}->bind('<Control-c>', \&DB::dbint_handler) ;
	$self->{'main_window'}->bind('<Control-c>', \&DB::dbExit) if(!$DB::controlC_disable);

	$self->{'main_window'}->protocol('WM_DELETE_WINDOW', sub {
		$self->{'main_window'}->deiconify() if(defined $self->{'main_window'} && Tk::Exists($self->{'main_window'}));
		if ($self->DoQuestion(-text,"<OK> terminates only the debugger (the process goes on),\n<No> terminates the process.")) {
			$self->removeAllBreakpointsAllFiles();
			$self->closeWindowAndRun();
		} else {
			$self->DoQuit();
		}
		}
		) ;

	$mw->fontCreate('codeTextFont',@{$Devel::ptkdb::code_text_font[1]});
	$mw->fontCreate('evalTextFont',@{$Devel::ptkdb::eval_text_font[1]});
	$mw->fontCreate('exprTextFont',@{$Devel::ptkdb::expression_text_font[1]});

	$self->setup_menu_bar() ;
	$self->setup_frames() ;
	$self->{'main_window'}->deiconify();
	$self->setStatus2('ready');	#
	$DB::ptkdb_isInitialized = 2;
	$self->setStatus0();	#

} ## setup_main_window

sub fontExists {
	my $self = shift;

	my ($name) = @_;
	my $rv = 0;
	my @myFonts = $DB::window->get_Main_Window(0)->fontNames;
	@myFonts = map {$$_} @myFonts; ## simply dereference
	$rv = 1 if (grep ($_ eq $name, @myFonts));
	return $rv;
}

sub _incFontSize {
	my $self = shift;
	my ($fontName)= @_;
	my $mw = $DB::window->get_Main_Window(0);
	my $size = $mw->fontConfigure($fontName,-size) ; ## don't use fontActual
	my $i ;
	for($i = 0;$i < $#Devel::ptkdb::fontSizeList;$i++) {
		last if ($size < $Devel::ptkdb::fontSizeList[$i])
	}
	$mw->fontConfigure($fontName,-size,$Devel::ptkdb::fontSizeList[$i]);
	return 1
}

sub _decFontSize {
	my $self = shift;
	my ($fontName)= @_;
	my $mw = $DB::window->get_Main_Window(0);
	my $size = $mw->fontConfigure($fontName,-size) ;
	my $i;
	for($i = $#Devel::ptkdb::fontSizeList;$i > 0;$i--) {
		last if ($size > $Devel::ptkdb::fontSizeList[$i])
	}
	$mw->fontConfigure($fontName,-size,$Devel::ptkdb::fontSizeList[$i]);
	return 1
}

sub incFontSize {
	my $self = shift;
	$self = 'Devel::ptkdb' unless(defined $self);
	$self->_incFontSize('codeTextFont');
	# $text->configure(-font , 'codeTextFont');
}

sub decFontSize {
	my $self = shift;
	$self = 'Devel::ptkdb' unless(defined $self);
	$self->_decFontSize('codeTextFont');
	#$text->configure(-font , 'codeTextFont');
}

sub incFontSizeX {
	my $self = shift;
	$self = 'Devel::ptkdb' unless(defined $self);
	$self->_incFontSize('evalTextFont');
	$self->{'eval_window'}->raise();
}

sub decFontSizeX {
	my $self = shift;
	$self->_decFontSize('evalTextFont');
	$self->{'eval_window'}->raise();
}

#
# Check for changes to the bookmarks and quit
#
sub DoQuit {
	my $self = shift ;
	$DB::window->setStatus2('terminating');	#
	$self->save_bookmarks($self->{'BookMarksPath'}) if($Devel::ptkdb::DataDumperAvailable && $self->{'bookmarks_changed'});
	if(defined($self->{'main_window'})) {
		my $mw = $self->{'main_window'}->parent() ;
		$self->{'main_window'}->destroy  ;
		$self->{'main_window'} = undef ;
		$mw->destroy() if (defined ($mw) && Tk::Exists($mw));
	} else {}
	&DB::dbExit()
}

#
# This supports the File -> Open menu item
# We create a new window and list all of the files
# that are contained in the program.  We also
# pick up all of the PerlTk files that are supporting
# the debugger.
#

sub DoOpen {
	my $self = shift ;
	my ($topLevel, $listBox, $frame, $selectedFile, @fList) ;

	my $chooseSub = sub { # subroutine we call when we've selected a file
		$selectedFile = $listBox->get('active') ;
		DB::trace("attempting to open $selectedFile") ;
		$DB::window->set_file($selectedFile, 0) ;
		$topLevel->destroy() ;
		} ;

	#
	# Take the list the files and resort it.
	# we put all of the local files first, and
	# then list all of the system libraries.
	#
	@fList = sort {
		# sort comparison function block
		my $fa = substr($a, 0, 1) ;
		my $fb = substr($b, 0, 1) ;
		return $a cmp $b if ($fa eq '/') && ($fb eq '/') ;
		return -1 if ($fb eq '/') && ($fa ne '/') ;
		return 1 if ($fa eq '/' ) && ($fb ne '/') ;
		return $a cmp $b ;
	} grep s/^_<//, keys %main:: ;

	## TODO: get rid of eval items
	#
	# Create a list box with all of our files
	# to select from
	#
	$topLevel = $self->{'main_window'}->Toplevel(-title => "ptkdb - File Select", -overanchor => 'cursor') ;

	$listBox = $topLevel->Scrolled('Listbox',
			@Devel::ptkdb::scrollbar_cfg,
			-font , 'exprTextFont',-width => 30
			)->pack(-side => 'top', -fill => 'both', -expand => 1) ;

	# Bind a double click on the mouse button to the same action
	# as pressing the OK button

	$listBox->bind('<Double-Button-1>' => $chooseSub) ;

	$listBox->insert('end', @fList) ;

	$topLevel->Button( -text => "OK", -command => $chooseSub, -font , 'buttonTextFont',
			)->pack(-side => 'left', -fill => 'both', -expand => 1) ;
	$topLevel->Button( -text => "Cancel",
			-font , 'buttonTextFont',
			-command => sub { $topLevel->destroy(); }
			)->pack(-side => 'left', -fill => 'both', -expand => 1) ;
} # end of DoOpen

sub do_autoStepDelayTime {
	my($delaytime) ;
	my($w, $result) ;
	require Tk::Dialog ;

	$w = $DB::window->{'main_window'}->DialogBox(-title => "ptkdb - austostep delay time", -buttons => [qw/OK Cancel/]) ;
	$delaytime = $DB::autostep_delay_time;
	$w->add('Label', -text => 'Delay time [msec]:')->pack(-side => 'left', -pady, 20, -padx, 10) ;
	$w->add('Entry', -textvariable => \$delaytime, -width, 6)->pack(-side => 'left',-pady, 20, -padx, 10)->selectionRange(0,'end') ;
	$result = $w->Show() ;
	return unless($result =~/OK/i) ;
	$DB::autostep_delay_time =  $delaytime;
}

sub do_tabs {
	my($tabs_str) ;
	my($w, $result, $tabs_cfg) ;
	require Tk::Dialog ;

	$w = $DB::window->{'main_window'}->DialogBox(-title => "ptkdb - Tabs", -buttons => [qw/OK Cancel/]) ;
	$tabs_cfg = $DB::window->{'text'}->cget(-tabs) ;
	$tabs_str = join " ", @$tabs_cfg if $tabs_cfg ;
	$w->add('Label', -text => 'Tabs:')->pack(-side => 'left', -pady, 20, -padx, 10) ;
	$w->add('Entry', -textvariable => \$tabs_str, -width, 6)->pack(-side => 'left', -pady, 20, -padx, 10)->selectionRange(0,'end') ;
	$result = $w->Show() ;
	return unless $result =~/OK/i ;
	$DB::window->setTabs(split /\s/, $tabs_str);
}

sub close_ptkdb_window {
	my($self) = @_ ;
	if (&DB::getBreakpoints() > 0) {
		if ($self->DoQuestion(-text, "Do you want to clear all breakpoint?")) {
			$self->removeAllBreakpointsAllFiles();
		} # else {}
	} # else {}
	$DB::window->{'event'} = 'run' ;
	$self->{'current_file'} = "" ; # force a file reset
	$self->{'main_window'}->destroy ;
	$self->{'main_window'} = undef ;
}

sub closeWindowAndRun {
	my $self = shift;
	$self->close_ptkdb_window ;
	$DB::single = 0 ;
	$DB::step_over_depth = -1;
	$self->{'event'} = 'run'
}

sub statusbar {		#set up statusbar
	my $self = shift;
	$self->{'statusbar'} = $self->{'button_bar'}->Frame()->pack(-side, 'right', -expand, 0, , -fill, 'x');
	$self->{'statusbar2'}= $self->{'statusbar'}->Label( -anchor , 'w' , -borderwidth , 1 , -justify , 'left' , -relief , 'sunken' , -text , 'status 2', -width, 8)->pack(-side,'right',-padx, 5, -expand,0);
	$self->{'statusbar1'} = $self->{'statusbar'}->Label( -anchor , 'w' , -borderwidth , 1 , -justify , 'left' , -relief , 'sunken' , -text , 'status 1', -width, 8)->pack(-side,'right',-padx, 5, -expand,0);
	$self->{'statusbar0'} = $self->{'statusbar'}->Label( -anchor , 'w' , -borderwidth , 1 , -justify , 'left' , -relief , 'sunken' , -text , 'status 0', -width, 8)->pack(-side,'right',-padx, 5, -expand,0);
	return $self->{'status_bar'};
}
sub setStatus0 { ## update statusbar 0 - filter
	my $self = shift;
	return unless(Tk::Exists($DB::window->{'statusbar0'}));
	my $status = ('ptkdbFilter'->active) ? 'Filter' : '      ';
	$self->{'statusbar0'}->configure (-text, $status);
	$self->{'statusbar0'}->update();
}

sub setStatus1 { ## update statusbar 1
	my $self = shift;
	return unless(Tk::Exists($DB::window->{'statusbar1'}));
	my $status = ($DB::window->{'dirtyFlag'}) ? 'changed' : '       ';
	$self->{'statusbar1'}->configure (-text, $status);
	$self->{'statusbar1'}->update();
}

sub setStatus2 { ## update statusbar 2
	my $self = shift;
	my ($status) = @_;
	return unless (Tk::Exists($DB::window->{'statusbar2'}));
	$self->{'statusbar2'}->configure (-text, $status);
	if ($status =~/ready/i) {
		$self->{'statusbar2'}->configure (-bg, '#80ff80');
	} else {
		$self->{'statusbar2'}->configure (-bg, '#ff9393');
	}
	$self->{'statusbar2'}->configure (-text, $status);
	$self->{'statusbar2'}->update();
}

sub setup_menu_bar {	## set up menu and toolbar
	my ($self) = @_ ;
	my $mw = $self->{'main_window'} ;
	my ($mb, $items) ;

	#
	# We have menu items/features that are not available if the Data::DataDumper module
	# isn't present.  For any feature that requires it we add this option list.
	#
	my @dataDumperEnableOpt = ( state => 'disabled' ) unless $Devel::ptkdb::DataDumperAvailable ;

	$self->{'menu_bar'} = $mw->Frame(-relief => 'raised', -borderwidth => '1')->pack(-side => 'top', -fill => 'x') ;

	$mb = $self->{'menu_bar'} ;

	# file menu in menu bar

	$items = [
			[ 'command' => 'Open', -accelerator => 'Alt+O',
			-underline => 0,
			-command => sub { $self->DoOpen() ; } ],

			[ 'command' => 'Save Config...', -accelerator => 'Ctrl-s',
			-underline => 0,
			-command => \&DB::SaveState,
			@dataDumperEnableOpt ],

			[ 'command' => 'Restore Config...',
			-underline => 0,
			-command => \&DB::RestoreState,
			@dataDumperEnableOpt ],

			[ 'command' => 'Goto Line...',
			-underline => 0,
			-accelerator => 'Alt-g',
			-command => sub { $self->GotoLine() ; },
			@dataDumperEnableOpt ] ,

			[ 'command' => 'Find Text...',
			-accelerator => 'Ctrl-f',
			-underline => 0,
			-command => sub { $self->FindText() ; } ],

			[ 'command' => "Tabs...", -command => \&do_tabs ],

			"-",

			[ 'command' => 'Close Window and Run', -accelerator => 'Alt+W',
			-underline => 6, -command => [\&closeWindowAndRun, $self]],

			[ 'command' => 'Quit...', -accelerator => 'Alt+Q',
			-underline => 0,
			-command => sub { $self->DoQuit } ]
			] ;

	$mw->bind('<Control-s>' => sub { &DB::SaveState(); } );
	$mw->bind('<Alt-g>' =>  sub { $self->GotoLine() ; }) ;
	$mw->bind('<Control-f>' => sub { $self->FindText() ; }) ;
	$mw->bind('<Control-r>' => \&Devel::ptkdb::DoRestart) ;
	$mw->bind('<Alt-q>' => sub { $self->{'event'} = 'quit' } ) ;
	$mw->bind('<Alt-w>' => [\&closeWindowAndRun, $self]) ;

	$self->{'file_menu_button'} = $mb->Menubutton(-text => 'File',-width , 8, ## -relief , 'raised',
			## -underline => 0,
			-menuitems => $items
			)->pack(-side =>, 'left',
			-anchor => 'nw',
			-padx => 2) ;

	# Control Menu

	my $runSub = sub {
			if(ptkdbFilter->active()) {
				ptkdbFilter->deactivate();
				$DB::window->setStatus0();
			} ## else {}
			$DB::step_over_depth = -1 ;
			$DB::window->{'lastevent'} = '';
			$self->{'event'} = 'run';
			$DB::autostep = 0;
			} ;

	my $runToSub = sub {
			if ($DB::window->SetBreakPoint(1)) {
					if(ptkdbFilter->active()) {
						ptkdbFilter->deactivate();
						$DB::window->setStatus0();
					} ## else {}
					$DB::step_over_depth = -1 if($DB::window->{'lastevent'} = 'stepover');
					$DB::window->{'event'} = 'run';
					$DB::window->{'lastevent'} = '';
					$DB::autostep = 0;
			} else {}
			} ;

	my $stepOverSub = sub {
			&DB::SetStepOverBreakPoint(0) ;
			$DB::single = 1 ;
			$DB::window->{'lastevent'} = 'stepover';
			$DB::window->{'event'} = 'step' ;
			} ;


	my $stepInSub = sub {
			$DB::step_over_depth = -1 ;
			$DB::single = 1 ;
			$DB::window->{'lastevent'} = 'stepin';
			$DB::window->{'event'} = 'step' ;
			} ;

	my $eventMaskSub = sub{
			my $w = $self->dlg_getEventMask($self->{'main_window'}, -eventMask, $self->{'eventMask'});
			$self->{'eventMask'} = $w if (defined($w));
			} ;

	my $returnSub =  sub {
			&DB::SetStepOverBreakPoint(-1) ;
			$DB::window->{'lastevent'} = '';
			$self->{'event'} = 'run' ;
			$DB::autostep = 0;
			} ;

	my $autostepSub = sub {
			$DB::window->{'lastevent'} = '';
			};

	my $removeAllBreakpointSub = sub {
			$DB::window->removeAllBreakpoints($DB::window->{'current_file'}) ;
			&DB::clearalldblines(sub{1},$DB::window->{'current_file'}) ;
			$DB::window->{'dirtyFlag'} = 1; ## may be a bad idea 10.03.2011/mm
			$DB::window->setStatus1();
			} ;

	# This feature: Does not "respects" break points and runs the script
	my $passThru =  sub {
			## $DB::window->removeAllBreakpoints($DB::window->{current_file});
			## &DB::clearalldblines();
			$DB::window->setvalueOfAllBreakpoints(undef,0);
			$DB::step_over_depth = -1 ;
			$DB::window->{'lastevent'} = '';
			$self->{'event'} = 'run';
			$DB::autostep = 0;
			};

	$items = [
			[ 'command' => 'Run', -accelerator => 'Alt+r', -underline => 0, -command => $runSub ],
			[ 'command' => 'Run To Here', -accelerator => 'Alt+t', -underline => 5, -command => $runToSub ],
			[ 'command' => 'Pass Thru', -underline => 5, -command => $passThru ],
			'-',
			[ 'command' => 'Enter breakpoint filter conditions', -command => sub {ptkdbFilter->dlg_getFilter($DB::window->{'main_window'})}],
			[ 'command' => 'Switch breakpoint filter', -command => sub {ptkdbFilter->switchFilter($DB::window->{'main_window'})}],
			'-',
			[ 'command' =>  'Set Breakpoint', -underline => 4, -command => sub { $self->SetBreakPoint ; }, -accelerator => 'Ctrl-b' ],
			[ 'command' => 'Clear Breakpoint', -command => sub { $self->UnsetBreakPoint } ],
			[ 'command' => 'Clear All Breakpoints', -underline => 6, -command => $removeAllBreakpointSub ],
			'-',
			[ 'command' => 'Activate All Breakpoints', -command => sub{$self->setvalueOfAllBreakpoints(undef,1)} ],
			[ 'command' => 'Deactivate All Breakpoints', -command => sub{$self->setvalueOfAllBreakpoints(undef,0)} ],
			'-',
			[ 'command' => 'Event mask', -command => $eventMaskSub ],
			'-',
			[ 'command' => 'Step Over', -accelerator => 'Alt+N', -underline => 0, -command => $stepOverSub ],
			[ 'command' => 'Step In', -accelerator => 'Alt+S', -underline => 5, -command => $stepInSub ],
			[ 'command' => 'Return', -accelerator => 'Alt+U', -underline => 3, -command => $returnSub ],
			'-',
			[ 'command' => 'Set autostep delay time',  -command => \&do_autoStepDelayTime ],
			[ 'checkbutton' => 'Autostep', -variable => \$DB::autostep, -command, \&switch_autostep ],
			'-',
			[ 'command' => 'Restart...', -accelerator => 'Ctrl-r', -underline => 0, -command => \&Devel::ptkdb::DoRestart ],
			'-',
			[ 'checkbutton' => 'Allow calls/messages on expr list', -variable => \$Devel::ptkdb::allow_calls_in_expr_list, -command, \&switch_allow_calls_in_expr_list ],
			[ 'checkbutton' => 'Stop On Warning', -variable => \$DB::ptkdb::stop_on_warning, -command => \&set_stop_on_warning ],
			[ 'checkbutton' => 'Stop On Restart', -variable => \$DB::ptkdb::stop_on_restart, -command => \&set_stop_on_restart ]
			] ; # end of control menu items


	$self->{'control_menu_button'} = $mb->Menubutton(-text => 'Control',-width , 8, ## -relief , 'raised',
		-underline => 0,
		-menuitems => $items,
		)->pack(-side =>, 'left',-fill , 'x', -expand, 0,
		-padx => 2) ;


	$mw->bind('<Alt-r>' => $runSub) ;
	$mw->bind('<Alt-t>', $runToSub) ;
	$mw->bind('<Control-b>', sub { $self->SetBreakPoint ; }) ;

#	for( @Devel::ptkdb::step_over_keys ) {
#		$mw->bind($_ => $stepOverSub );
#	}
#
#	for( @Devel::ptkdb::step_in_keys ) {
#		$mw->bind($_ => $stepInSub );
#	}
#
#	for( @Devel::ptkdb::return_keys ) {
#		$mw->bind($_ => $returnSub );
#	}

	# Data Menu

	my $enterExprSub = sub {
		$self->EnterExpr();
		} ;
	my $delExprSub = sub {
		$self->deleteExpr();
		$DB::window->{'dirtyFlag'} = 1;
		$DB::window->setStatus1();
		} ;
	my $delAllExprSub = sub {
		$self->deleteAllExprs() ;
		$self->{'expr_list'} = [] ; # clears list by dropping ref to it, replacing it with a new one
		$DB::window->{'dirtyFlag'} = 1;
		$DB::window->setStatus1();
		} ;
	my $setupValSub = sub { $self->setupEvalWindow()} ;

	$items = [
			[ 'command' => 'Enter Expression', -accelerator => 'Alt+E', -command => $enterExprSub ],
			[ 'command' => 'Delete Expression', -accelerator => 'Ctrl+D', -command => $delExprSub],
			[ 'command' => 'Delete All Expressions',  -command => $delAllExprSub ],
			'-',
			[ 'command' => 'Show DB trace',  -command => \&DB::dlg_showTrace ],
			'-',
			[ 'command' => 'Expression Eval Window...', -accelerator => 'F8', -command => $setupValSub ],
			'-',
			[ 'checkbutton' => 'Decorate code page', -variable =>\$Devel::ptkdb::decorate_code, -command ,\&switch_decorate_code],
			'-',
			[ 'command' => 'Zoom+',  -command ,\&Devel::ptkdb::incFontSize],
			[ 'command' => 'Zoom-',  -command ,\&Devel::ptkdb::decFontSize],
			'-',
			[ 'checkbutton' => 'DB trace is active', -variable =>\$Devel::ptkdb::trace_active, -command ,\&switch_trace],
			[ 'checkbutton' => 'DB trace expressions', -variable =>\$Devel::ptkdb::trace_expressions, -command ,\&switch_trace_expressions],
			[ 'checkbutton' => 'DB trace subroutines', -variable =>\$Devel::ptkdb::trace_sub_active, -command ,\&switch_trace_sub],
			[ 'checkbutton' => 'Display variable at cursor position', -variable =>\$Devel::ptkdb::balloon, -command ,\&switch_balloon],
			[ 'checkbutton' => "Show Proximity Window", -variable => \$Devel::ptkdb::showProximityWindow, -command, \&switch_Proximity_Window ],
			[ 'checkbutton' => "Use DataDumper for Eval Window", -variable => \$Devel::ptkdb::useDataDumperForEval, @dataDumperEnableOpt ]
			] ;

	$self->{'data_menu_button'} = $mb->Menubutton(-text => 'Data', -menuitems => $items,-width , 8, ## - relief , 'raised',
			-underline => 0,
			)->pack(-side => 'left',-fill , 'x', -expand, 0, -padx => 2) ;

	$mw->bind('<Alt-e>' => $enterExprSub ) ;
	$mw->bind('<Control-d>' => $delExprSub );
	$mw->bind('<F8>', $setupValSub) ;
	#
	# Stack menu
	#
	$self->{'stack_menu'} = $mb->Menubutton(-text => 'Stack',-width , 8, ## -relief , 'raised',
			-underline => 2,
			)->pack(-side => 'left',-fill , 'x', -expand, 0, -padx => 2) ;

	#
	# Bookmarks menu
	#
	$self->{'bookmarks_menu'} = $mb->Menubutton(-text => 'Bookmarks',-width , 8, ## -relief , 'raised',
			-underline => 0,
			@dataDumperEnableOpt
			)->pack(-side => 'left',-fill , 'x', -expand, 0, -padx => 2) ;
	$self->setup_bookmarks_menu() ;

	#
	# Tools -> Options
	#
	$items = [
			#			"-",
			[ 'command' => 'Options', -command => sub { $self->DoShowOptions() ; } ],
			] ;

	$mb->Menubutton(-text => 'Tools', -menuitems => $items,-width , 8, ## -relief , 'raised',
			)->pack(-side => 'left',-fill , 'x', -expand, 0, -padx => 2) ;

	#
	# Windows Menu
	#
	my $bsub = sub { $self->{'text'}->focus() } ;
	my $csub = sub {
		$self->{'notebook'}->raise("datapage") unless ($self->{'notebook'}->raised() eq "datapage");
		$self->{'quick_entry'}->focus();
		} ;
	my $dsub = sub {
		$self->{'notebook'}->raise("datapage") unless ($self->{'notebook'}->raised() eq "datapage");
		$self->{'entry'}->focus();
		} ;

	$items = [ [ 'command' => 'Code Pane', -accelerator => 'Alt+0', -command => $bsub ],
			[ 'command' => 'Quick Entry', -accelerator => 'F9', -command => $csub ],
			[ 'command' => 'Expr Entry', -accelerator => 'F11', -command => $dsub ]
			] ;

	$mb->Menubutton(-text => 'Windows', -menuitems => $items, -width , 8, ## -relief , 'raised',
			)->pack(-side => 'left',-fill , 'x', -expand, 0, -padx => 2) ;

	$items = [
			[ 'command' => 'Home Page', -command => [\&OpenURL,'home'] ],
			"-",
			[ 'command' => 'Feature Request', -command => [\&OpenURL,'feature_request'] ],
			[ 'command' => 'Bug Report', -command => [\&OpenURL,'bug_report'] ],
			[ 'command' => 'Mailing List', -command => [\&OpenURL,'mail_list'] ],
			"-",
			[ 'command' => 'About', -command => \&DoAbout ],
			] ;

	$mb->Menubutton(-text => 'Help',-menuitems => $items,  -width , 8, ## -relief , 'raised'
			)->pack(-side => 'right', -padx => 2) ;

	$mw->bind('<Alt-0>', $bsub) ;
	$mw->bind('<F9>', $csub) ;
	$mw->bind('<F11>', $dsub) ;

	#
	# Bar for some popular controls
	#

	$self->{'button_bar'} = $mw->Frame(-relief => 'sunken', -borderwidth => '1')->pack(-side => 'top',-expand => 0, -fill => 'x') ;

	$self->{'stepin_button'} = $self->{'button_bar'}->Button(-text, => "Step In",
		-command => $stepInSub, @Devel::ptkdb::button_font) ;
	$self->{'stepin_button'}->pack(-side => 'left', -anchor => 'nw',  -padx => 2, -pady => 2, -expand => 0 ) ;

	$self->{'stepover_button'} = $self->{'button_bar'}->Button(-text, => "Step Over",
		-command => $stepOverSub, @Devel::ptkdb::button_font) ;
	$self->{'stepover_button'}->pack(-side => 'left', -anchor => 'nw', -padx => 2, -pady => 2, -expand => 0) ;

	$self->{'return_button'} = $self->{'button_bar'}->Button(-text, => "Return",
		-command => $returnSub, @Devel::ptkdb::button_font) ;
	$self->{'return_button'}->pack(-side => 'left', -anchor => 'nw', -padx => 2, -pady => 2, -expand => 0) ;

	$self->{'run_button'} = $self->{'button_bar'}->Button(-background => 'green', -text, => "Run",
		-command => $runSub,@Devel::ptkdb::button_font) ;
	$self->{'run_button'}->pack(-side => 'left', -anchor => 'nw', -padx => 2, -pady => 2, -expand => 0) ;

	$self->{'run_to_button'} = $self->{'button_bar'}->Button(-text, => "Run To",
		-command => $runToSub, @Devel::ptkdb::button_font) ;
	$self->{'run_to_button'}->pack(-side => 'left', -anchor => 'nw', -padx => 2, -pady => 2, -expand => 0) ;
	# Pass Thru Button
	$self->{run_transit_button} = $self->{button_bar}->Button(-text, => "Pass Thru",
		-command => $passThru,@Devel::ptkdb::button_font);
	$self->{run_transit_button}->pack(-side => 'left') ;

	$self->{'breakpt_button'} = $self->{'button_bar'}->Button(-text, => "Break",
		-command => sub { $self->SetBreakPoint ; }, @Devel::ptkdb::button_font ) ;
	$self->{'breakpt_button'}->pack(-side => 'left', -anchor => 'nw', -padx => 2, -pady => 2, -expand => 0) ;

	$self->{'autostep_button'} = $self->{'button_bar'}->Checkbutton( -relief , 'raised' , -variable , \$DB::autostep , -anchor , 'nw' , -justify , 'left' , -text , 'Autostep' , -onvalue , 1,
		-command => $autostepSub, @Devel::ptkdb::button_font ) ;
	$self->{'autostep_button'}->pack(-side => 'left', -anchor => 'nw', -padx => 2, -pady => 2, -expand => 0) ;

	push @{$self->{'DisableOnLeave'}}, @$self{'stepin_button', 'stepover_button', 'return_button', 'run_button', 'run_to_button', 'breakpt_button','autostep_button'} ;

	$self->statusbar();
} # end of setup_menu_bar

sub edit_bookmarks {
	my ($self) = @_ ;
	my $top =  $self->{'main_window'}->Toplevel(-title => "ptkdb - Edit Bookmarks") ;
	my $list = $top->Scrolled('Listbox', -selectmode => 'multiple')->pack(-side => 'top', -fill => 'both', -expand => 1) ;
	my $deleteSub = sub {
		my $cnt = 0 ;
		for( $list->curselection ) {
			$list->delete($_ - $cnt) ;
			# splice @{$self->{'bookmarks'}},$_ - $cnt,1;
			$cnt++;
		}
		# $self->reset_bookmark_items(@{$self->{'bookmarks'}}) if ($cnt);
		} ;
	my $okaySub = sub {
		$self->{'bookmarks'} = [ ($list->get(0, 'end')) ]  ; # replace the bookmarks
		$self->reset_bookmark_items(@{$self->{'bookmarks'}});
		$top->destroy ;
		} ;
	my $saveSub = sub {
		$self->save_bookmarks();
		} ;
	my $frm = $top->Frame()->pack(-side => 'top', -fill => 'x', -expand => 1 ) ;
	my $deleteBtn = $frm->Button(-text => 'Delete', -command => $deleteSub,-relief,'raised')->pack(-side => 'left', -fill => 'x', -expand => 1 , -padx, 5, -pady, 5) ;
	my $cancelBtn = $frm->Button(-text => 'Cancel', -command => sub { $top->destroy ; },-relief,'raised')->pack(-side  =>'left', -fill => 'x', -expand => 1 , -padx, 5, -pady, 5) ;
	my $dismissBtn = $frm->Button(-text => 'OK', -command => $okaySub,-relief,'raised')->pack(-side => 'left', -fill => 'x', -expand => 1, -padx, 5, -pady, 5 ) ;
	my $saveBtn = $frm->Button(-text => 'Save', -command => $saveSub,-relief,'raised')->pack(-side => 'left', -fill => 'x', -expand => 1, -padx, 5, -pady, 5) ;

	$list->insert('end', sort @{$self->{'bookmarks'}}) ;
} # end of edit_bookmarks

sub setup_bookmarks_menu {
	my ($self) = @_ ;

	my $bkMarkSub = sub { $self->add_bookmark() ; } ;
	$self->{'bookmarks_menu'}->command(-label => "Add Bookmark",
		-accelerator => 'Alt+k',
		-command => $bkMarkSub
		) ;
	$self->{'main_window'}->bind('<Alt-k>', $bkMarkSub) ;
	$self->{'bookmarks_menu'}->command(-label => "Edit Bookmarks",
		-command => sub { $self->edit_bookmarks() } ) ;
	$self->{'bookmarks_menu'}->command(-label => "Save Bookmarks",
		-command => sub { $self->save_bookmarks() } ) ;
	$self->{'bookmarks_menu'}->separator() ;
	#
	# Check to see if there is a bookmarks file
	#
	return unless -e $self->{'BookMarksPath'} && -r $self->{'BookMarksPath'} ;
	use vars qw($ptkdb_bookmarks) ;
	local($ptkdb_bookmarks) ; # ref to hash of bookmark entries
	do $self->{'BookMarksPath'} ; # eval the file
	$self->add_bookmark_items(@$ptkdb_bookmarks) ;
} # end of setup_bookmarks_menu

#
# $item = "$fname:$lineno"
#
sub add_bookmark_items {
	my($self, @items) = @_ ;
	my($menu) = ( $self->{'bookmarks_menu'} ) ;
	$self->{'bookmarks_changed'} = 1 ;
	for( sort @items ) {
		my $item = $_ ;
		$menu->command( -label => $_,
		-command => sub { $self->bookmark_cmd($item) }) ;
		push @{$self->{'bookmarks'}}, $item ;
	}
} # end of add_bookmark_item

sub reset_bookmark_items {
	my($self, @items) = @_ ;
	my $menu = $self->{'bookmarks_menu'}->cget(-menu) ;
	$menu->delete(5, 'end');
	$self->{'bookmarks'} = [];
	$self->add_bookmark_items(@items) if (@items);
} # end of add_bookmark_item

sub add_bookmark { # Invoked from the "Add Bookmark" command
	my($self) = @_ ;
	my $line = $self->get_lineno() ;
	my $fname = $self->{'current_file'} ;
	$self->add_bookmark_items($fname.':'.sprintf ('%05d',$line)) ;
} # end of add_bookmark

sub bookmark_cmd { # Command executed when someone selects a bookmark
	my ($self, $item) = @_ ;
	$item =~ /(.*):([0-9]+)$/ ;
	$self->set_file($1,$2,'bookmark') ;
} # end of bookmark_cmd

sub save_bookmarks {
	my($self, $pathName) = @_ ;
	return unless $Devel::ptkdb::DataDumperAvailable ; # we can't save without the data dumper
	local(*F) ;
	$pathName = $self->{'BookMarksPath'} unless defined $pathName;
	eval {
		open F, ">$pathName" || die "ptkdb - save_bookmarks, open failed" ;
		my $d = Data::Dumper->new([ $self->{'bookmarks'} ],[ 'ptkdb_bookmarks' ]) ;
		$d->Indent(2) ; # make it more editable for people
		my $str ;
		if( $d->can('Dumpxs') ) {
			$str = $d->Dumpxs() ;
		} else {
			$str = $d->Dump() ;
		}
		print F $str || die "ptkdb - save_bookmarks, outputing bookmarks failed." ;
		close(F) ;
	} ;
	if( $@ ) {
		$self->DoAlert("Couldn't save bookmarks file $@") ;
		return ;
	} else {
		$self->{'bookmarks_changed'} = 0 ;
	}
} # end of save_bookmarks

#
# This is our callback from a double click in our
# HList.  A click in an expanded item will delete
# the children beneath it, and the next time it
# updates, it will only update that entry to that
# depth.  If an item is 'unexpanded' such as
# a hash or a list, it will expand it one more
# level.  How much further an item is expanded is
# controled by package variable $Devel::ptkdb::add_expr_depth
#
sub expr_expand {
	my ($path) = @_ ;
	my $hl = $DB::window->{'data_list'} ;
	my ($parent, $root, $index, @children, $depth) ;

	$parent = $path ;
	$root = $path ;
	$depth = 0 ;

	for( $root = $path ; defined $parent && $parent ne "" ; $parent = $hl->infoParent($root) ) {
		$root = $parent ;
		$depth += 1 ;
	} #end of root search

	#
	# Determine the index of the root of our expression
	#
	$index = 0 ;
	for( @{$DB::window->{'expr_list'}} ) {
		last if $_->{'expr'} eq $root ;
		$index += 1 ;
	}

	#
	# if we have children we're going to delete them
	#
	@children = $hl->infoChildren($path) ;
	if( scalar @children > 0 ) {
		$hl->deleteOffsprings($path) ;
		$DB::window->{'expr_list'}->[$index]->{'depth'} = $depth - 1 ; # adjust our depth
	} else {
		$DB::window->{'expr_list'}->[$index]->{'depth'} += $Devel::ptkdb::add_expr_depth ;
		$DB::window->{'event'} = 'update' ; # Force an update on our expressions
	}
	$Devel::ptkdb::savedPathForSee = $path if(defined($path)); ## save path for see meaage later on in method updateExpr
} # end of expr_expand

sub seeItemIfExisting {
	my $self = shift;
	my ($hL,$path) = @_;
	my $rv = 0;
	return $rv unless defined $path;
	$rv = $hL->info('exists',$path);
	$hL->see($path) if($rv);
	return 1;
} ## end of seeItemIfExisting

sub refreshProximityWindow {
	my $self = shift;
	my ($depth) = @_;
	$depth = $Devel::ptkdb::proximityWindowInitialDepth unless(defined $depth);
	my $vars = $DB::window->{'proximity_expr_list'};
	$self->deleteAllProximityExprs();
	for (my $i=0; $i < @$vars; $i++) {
		my $expr = $vars->[$i]->[0];
		my @result= @{$vars->[$i]->[1]};
		if (@result == 1) {
			$self->insertExpr([ $result[0] ], $DB::window->{'proximity_data_list'}, $result[0], $expr, $depth) ;
		} else {
			$self->insertExpr([ \@result ], $DB::window->{'proximity_data_list'}, \@result, $expr, $depth) ;
		}
	} ;

	$self->seeItemIfExisting($DB::window->{'proximity_data_list',$Devel::ptkdb::savedProximityPathForSee});
	$Devel::ptkdb::savedProximityPathForSee = '';
	return undef
}

sub expr_expand_proximity {
	my ($path) = @_ ;
	my $hl = $DB::window->{'proximity_data_list'} ;
	my ($parent, $root, $index, @children, $depth) ;

	return unless $hl->ismapped(); ## be sure we are there ...

	$parent = $path ;
	$root = $path ;
	$depth = 0 ;

	for( $root = $path ; defined $parent && $parent ne "" ; $parent = $hl->infoParent($root) ) {
		$root = $parent ;
		$depth += 1 ;
	} #end of root search
	#
	# Determine the index of the root of our expression
	#
	$index = 0 ;
	for( @{$DB::window->{'proximity_expr_list'}} ) {
		last if($_->[0] eq $root) ;
		$index += 1 ;
	}
	#
	# if we have children we're going to delete them
	#
	@children = $hl->infoChildren($path) ;
	if( scalar @children > 0 ) {
		$hl->deleteOffsprings($path) ;
		$DB::window->{'proximity_data_list'}->update();
	} else {
		$Devel::ptkdb::savedProximityPathForSee = $path if(defined($path));
		$DB::window->refreshProximityWindow($depth) ; # refresh the current content
	}
} # end of expr_expand_proximity

sub line_number_from_coord {
	my($txtWidget, $coord) = @_ ;
	my($index) ;

	$index = $txtWidget->index($coord) ;
	$index =~ /([0-9]*)\.([0-9]*)/o ; # index is in the format of lineno.column
	#
	# return a list of (col, line).  Why backwards?
	#
	return wantarray ? ($2 ,$1) : $1;
} # end of line_number_from_coord

#
# It may seem as if $txtWidget and $self are
# erroneously reversed, but this is a result
# of the calling syntax of the text-bind callback.
#
sub set_breakpoint_tag {
	my($txtWidget, $self, $coord, $value) = @_ ;
	my($idx) ;
	$idx = line_number_from_coord($txtWidget, $coord) ;
	$self->insertBreakpoint($self->{'current_file'}, $idx, $value) ;
	$DB::window->{'dirtyFlag'} = 1;  ## mark state as changed
	$DB::window->setStatus1();
} # end of set_breakpoint_tag

sub clear_breakpoint_tag {
	my($txtWidget, $self, $coord) = @_ ;
	my($idx) ;
	$idx = line_number_from_coord($txtWidget, $coord) ;
	$self->removeBreakpoint($self->{'current_file'}, $idx) ;
	$DB::window->{'dirtyFlag'} = 1;  ## mark state as changed
	$DB::window->setStatus1();
} # end of clear_breakpoint_tag

sub change_breakpoint_tag {
	my($txtWidget, $self, $coord, $value) = @_ ;
	my($idx, $brkPt, @tagSet) ;

	$idx = line_number_from_coord($txtWidget, $coord) ;

	# Change the value of the breakpoint

	@tagSet = ( "$idx.0", "$idx.$Devel::ptkdb::linenumber_length" ) ;
	$brkPt = &DB::getdbline($self->{'current_file'}, $idx + $self->{'line_offset'}) ;
	return unless $brkPt ;

	# Check the breakpoint tag

	if ( $txtWidget ) {
		$txtWidget->tagRemove('breaksetLine', @tagSet ) ;
		$txtWidget->tagRemove('breakdisabledLine', @tagSet ) ;
	}
	$brkPt->{'value'} = $value ;
	if ( $txtWidget ) {
		if ( $brkPt->{'value'} ) {
			$txtWidget->tagAdd('breaksetLine', @tagSet ) ;
		}
		else {
			$txtWidget->tagAdd('breakdisabledLine', @tagSet ) ;
		}
	}
} # end of change_breakpoint_tag

#
# God Forbid anyone comment something complex and tightly optimized.
#
#  We can get a list of the subroutines from the interpreter
# by querrying the *DB::sub typeglob:  keys %DB::sub
#
# The list appears broken down by module:
#
#  main::BEGIN
#  main::mySub
#  main::otherSub
#  Tk::Adjuster::Mapped
#  Tk::Adjuster::Packed
#  Tk::Button::BEGIN
#  Tk::Button::Enter
#
#  We would like to break this list down into a hierarchy.
#
#         main                             Tk
#  |        |       |                       |
# BEGIN   mySub  OtherSub          |                 |
#                               Adjuster           Button
#                             |         |        |        |
#                           Mapped    Packed   BEGIN    Enter
#
#
#  We translate this list into a hierarchy of hashes(say three times fast).
# We take each entry and split it into elements.  Each element is a leaf in the tree.
# We traverse the tree with the inner for loop.
# With each branch we check to see if it already exists or
# we create it.  When we reach the last element, this becomes our entry.
#

#
# An incoming list is potentially 'large' so we
# pass in the ref to it instead.
#
#  New entries can be inserted by providing a $topH
# hash ref to an existing tree.
#
sub tree_split {
	my ($listRef, $separator, $topH) = @_ ;
	my ($h, $list_elem) ;

	$topH = {} unless $topH ;

	foreach $list_elem ( @$listRef ) {
		$h = $topH ;
		my $last;
		for( split /$separator/o, $list_elem ) { # Tk::Adjuster::Mapped  -> ( Tk Adjuster Mapped )
			$last = $_;
			$h->{$_} or $h->{$_} = {} ; # either we have an entry for this OR we create one
			$h = $h->{$_} ;
		}
		@$h{'++name', 'path'} = ($last, $list_elem) ; # the last leaf is our entry
	} # end of tree_split loop

	return $topH ;
} # end of tree_split

#
# callback executed when someone double clicks
# an entry in the 'Subs' Tk::Notebook page.
#
sub sub_list_cmd {
	my ($self, $path) = @_ ;
	my ($h) ;
	my $sub_list = $self->{'sub_list'} ;
	if (  $sub_list->info('children', $path)  ) {
		#
		# Delete the children
		#
		$sub_list->deleteOffsprings($path) ;
		return ;
	}
	#
	# split the path up into elements
	# end descend through the tree.
	#
	$h = $Devel::ptkdb::subs_tree ;
	for ( split /\./o, $path ) {
		$h = $h->{$_} ; # next level down
	}
	#
	# if we don't have a '++name' entry we
	# still have levels to decend through.
	#
	if ( !exists $h->{'++name'} ) {
		#
		# Add the next level paths
		#
		for ( sort keys %$h ) {
		next if(/__ANON__/); ## discard anonimous blocks
		if ( exists $h->{$_}->{'path'} ) {
		$sub_list->add($path . '.' . $_, -text => $h->{$_}->{'path'}) ;
		}
		else {
		$sub_list->add($path . '.' . $_, -text => $_) ;
		}
		}
		return ;
	} else {}

	$DB::sub{$h->{'path'}} =~ /(.*):([0-9]+)-[0-9]+$/o ; # file name will be in $1, line number will be in $2 */
	$self->set_file($1, $2) ;
} # end of sub_list_cmd

sub fill_subs_page {
	my($self) = @_ ;
	$self->{'sub_list'}->delete('all') ; # clear existing entries
	my @list = keys %DB::sub ;
	$Devel::ptkdb::subs_tree = tree_split(\@list, "::") ;
	for ( sort keys %$Devel::ptkdb::subs_tree ) {   # setup to level of list
		$self->{'sub_list'}->add($_, -text => $_) ;
	} # end of top level loop
}
sub configure_brkpts_page {
	my $self = shift;
	return 1
}
sub setup_log_page {
	my $self = shift;
	return 0;
}

sub setup_subs_page {
	my($self) = @_ ;
	$self->{'subs_page_activated'} = 1 ;
	$self->{'sub_list'} = $self->{'subs_page'}->Scrolled('HList', @Devel::ptkdb::scrollbar_cfg, -command => sub { $self->sub_list_cmd(@_) ; } ) ;
	$self->fill_subs_page() ;
	$self->{'sub_list'}->pack(-side => 'left', -fill => 'both', -expand => 1) ;
	$self->{'subs_list_cnt'} = scalar keys %DB::sub ;
} # end of setup_subs_page


sub check_search_request {
	my $self = shift;
	my($entry, $searchButton, $regexBtn) = @_ ;
	my $txt = $entry->can('Subwidget') ?
	$entry->Subwidget('entry')->get() :
	$entry->get();
	if( $txt =~ /^\s*[0-9]+\s*$/ ) {
		$self->DoGoto($entry) ;
		return ;
	}
	if( $txt =~ /\.\*/ ) { # common regex search pattern
		$self->saveInputIntoHistory($entry) ;
		$self->FindSearch($entry, $regexBtn, 1,0) ;
		return ;
	}
	$self->saveInputIntoHistory($entry) ;
	$self->FindSearch($entry, $searchButton, 0,0) ; # vanilla search
}

sub saveInputIntoHistory {
	my $self = shift;
	my ($entry,$item) = @_;
	return undef unless($entry->can('Subwidget'));

	my @history = $entry->Subwidget('slistbox')->get('0','end');
	$item = $entry->Subwidget('entry')->get() unless defined ($item);
	$entry->Subwidget('slistbox')->insert ('end',$item) unless grep ($item eq $_,@history);
	return $item
}

sub saveInputIntoGotoHistory {
	my $self = shift;
	my ($entry,$item) = @_;
	$item = $self->saveInputIntoHistory($entry,$item);
	return 0 unless defined $item;
	push @{$self->{'gotoHistory'}},$item unless grep ($item eq $_,@{$self->{'searchHistory'}});
	return 1
}

sub saveInputIntoSearchHistory {
	my $self = shift;
	my ($entry,$item) = @_;
	$item = $self->saveInputIntoHistory($entry,$item);
	push @{$self->{'searchHistory'}},$item unless grep ($item eq $_,@{$self->{'searchHistory'}});
	return 1
}

sub setup_search_panel {
	my ($self, $parent, @packArgs) = @_ ;
	my ($frm, $srchBtn, $regexBtn, $entry) ;

	my $onGoto = sub {
		$self->saveInputIntoHistory($entry) ;
		$self->DoGoto($entry);
		};
	my $onReturn = sub {
		$self->saveInputIntoSearchHistory($entry) ;
		$self->check_search_request($entry, $srchBtn, $regexBtn) ;
		};
	my $onSearch = sub {
		$self->saveInputIntoSearchHistory($entry) ;
		$self->FindSearch($entry, $srchBtn, 0,0) ;
	};
	my $onRegex = sub {
		$self->saveInputIntoSearchHistory($entry) ;
		$self->FindSearch($entry, $regexBtn, 1,0) ;
	};
	$frm = $parent->Frame() ;
	$frm->Button(-text => 'Goto', -command => $onGoto, @Devel::ptkdb::button_font)->pack(-side => 'left', -anchor=>'sw') ;
		$srchBtn = $frm->Button(-text => 'Search', -command => $onSearch,@Devel::ptkdb::button_font)->pack(-side => 'left', -anchor=>'sw' ) ;
	$regexBtn = $frm->Button(-text => 'Regex',
		-command => $onRegex,@Devel::ptkdb::button_font)->pack(-side => 'left', -anchor=>'sw' ) ;
	if ($Devel::ptkdb::Entry_Class =~ /^entry/i) {
		$entry = $frm->Entry(-width => 50,-font , 'exprTextFont')->pack(-side => 'left', -fill => 'both', -expand => 1) ;
	} elsif ($Devel::ptkdb::Entry_Class =~ /^browseEntry/i) {
		$entry = $frm->BrowseEntry ( -width, 50, -bg => '#FFFFFF', -state , 'normal' , -relief , 'flat',-font , 'exprTextFont'  )->pack(-side => 'left', -anchor=>'nw') ;
	} else {
		$entry = $frm->$Devel::ptkdb::Entry_Class ( -width, 50, -bg => '#FFFFFF', -state , 'normal' , -relief , 'flat',-font , 'exprTextFont'  )->pack(-side => 'left', -anchor=>'nw') ;
	}
	$frm->Button(-text => 'Zoom-', -command => [\&Devel::ptkdb::decFontSize,$self],@Devel::ptkdb::button_font)->pack(-side => 'right', -anchor=>'se');
	$frm->Button(-text => 'Zoom+', -command => [\&Devel::ptkdb::incFontSize,$self],@Devel::ptkdb::button_font)->pack(-side => 'right', -anchor=>'se');
	$entry->bind('<Return>', $onReturn) ;
	$frm->pack(@packArgs) ;
} # end of setup search_panel

sub setup_breakpts_page {
	my ($self) = @_ ;
	$self->{'breakpts_page'} = $self->{'notebook'}->add("brkptspage", -label => "BrkPts",-raisecmd ,sub{$self->adaptBrkptPageWidth()}) ;
	$self->{'breakpts_table'} = $self->{'breakpts_page'}->Table(-columns => 1, @Devel::ptkdb::scrollbar_cfg)->
	pack(-side => 'top', -fill => 'both', -expand => 1) ;
	$self->{'breakpts_table_data'} = { } ; # controls addressed by "fname:lineno"
} # end of setup_breakpts_page

sub setup_frames {
	my ($self) = @_ ;
	my $mw = $self->{'main_window'} ;
	my ($txt, $frm) ;
	require Tk::ROText ;
	require Tk::NoteBook ;
	require Tk::HList ;
	require Tk::Balloon ;
	require Tk::Adjuster ;

	$mw->update ; # force geometry manager to map main_window
	$frm = $mw->Frame(-width => $mw->reqwidth()) ; # frame for our code pane and search controls
	$self->{'main_window_frame'} = $frm;
	$self->setup_search_panel($frm, -side => 'top', -fill => 'x') ;

	# Text window for the code of current file

	$self->{'text'} = $frm->Scrolled('ROText',
		-wrap => "none",
		@Devel::ptkdb::scrollbar_cfg,
		-font , 'codeTextFont' # @Devel::ptkdb::code_text_font
		) ;

	$txt = $self->{'text'} ;
	for( $txt->children ) {
		next unless (ref $_) =~ /ROText$/ ;
		$self->{'text'} = $_ ;
		last ;
	}

	$frm->packPropagate(0) ;
	$txt->packPropagate(0) ;
	$txt->menu(undef); ## 02.05.2012/mm

	$frm->packAdjust(-side => $Devel::ptkdb::codeside, -fill => 'both', -expand => 1) ;
	$txt->pack(-side => 'left', -fill => 'both', -expand => 1) ;

	$self->configure_text() ;

	for( @Devel::ptkdb::step_over_keys ) {
		$txt->bind($_ => sub {
			&DB::SetStepOverBreakPoint(0) ;
			$DB::single = 1 ;
			$DB::window->{'lastevent'} = 'stepover';
			$DB::window->{'event'} = 'step' ;
			} );
	}

	for( @Devel::ptkdb::step_in_keys ) {
		$txt->bind($_ => sub {
			$DB::step_over_depth = -1 ;
			$DB::single = 1 ;
			$DB::window->{'lastevent'} = 'stepin';
			$DB::window->{'event'} = 'step' ;
			} );
	}

	for( @Devel::ptkdb::return_keys ) {
		$txt->bind($_ => sub {
			&DB::SetStepOverBreakPoint(-1) ;
			$DB::window->{'lastevent'} = '';
			$self->{'event'} = 'run' ;
			$DB::autostep = 0;
			} );
	}

	# Notebook

	$self->{'notebook'} = $mw->NoteBook() ;
	$self->{'notebook'}->packPropagate(0) ;
	$self->{'notebook'}->pack(-side => $Devel::ptkdb::codeside, -fill => 'both', -expand => 1) ;

	$self->{'data_page'} = $self->{'notebook'}->add("datapage", -label => "Exprs") ;

	# frame, entry and label for quick expressions

	my $frame = $self->{'data_page'}->Frame()->pack(-side => 'top', -fill => 'x') ;
	my $label = $frame->Label(-text => "Quick Expr:")->pack(-side => 'left') ;
	if ($Devel::ptkdb::Entry_Class =~ /^entry/i) {
		$self->{'quick_entry'} = $frame->Entry(-width => 50,-font , 'exprTextFont')->pack(-side => 'left', -fill => 'both', -expand => 1) ;
	} elsif ($Devel::ptkdb::Entry_Class =~ /^browseEntry/i) {
		$self->{'quick_entry'} = $frame->BrowseEntry ( -width , 50, -bg => '#FFFFFF', -state , 'normal' , -relief , 'flat',-font , 'exprTextFont'  )->pack(-side => 'left', -anchor=>'nw') ;
	} else {
		$self->{'quick_entry'} = $frame->$Devel::ptkdb::Entry_Class ( -width , 50, -bg => '#FFFFFF', -state , 'normal' , -relief , 'flat' ,-font , 'exprTextFont' )->pack(-side => 'left', -anchor=>'nw') ;
	}
	$frame->Button(-text ,'Exec', -command , sub { $self->QuickExpr() ; }, -width , 4, -relief , 'raised')->pack(-side => 'left', -padx , 5) ;

	$self->{'quick_entry'}->bind('<Return>', sub { $self->QuickExpr() ; } ) ;

	# Entry widget for expressions and breakpoints

	$frame = $self->{'data_page'}->Frame()->pack(-side => 'top', -fill => 'x') ;
	$label = $frame->Label(-text => "Enter Expr:")->pack(-side => 'left') ;
	if ($Devel::ptkdb::Entry_Class =~ /^entry/i) {
		$self->{'entry'} = $frame->Entry(-width => 50,-font , 'exprTextFont')->pack(-side => 'left', -fill => 'both', -expand => 1) ;
	} elsif ($Devel::ptkdb::Entry_Class =~ /^browseEntry/i) {
		$self->{'entry'} = $frame->BrowseEntry (  -width , 50, -bg => '#FFFFFF', -state , 'normal' , -relief , 'flat' ,-font , 'exprTextFont' )->pack(-side => 'left', -anchor=>'nw') ;
	} else {
		$self->{'entry'} = $frame->$Devel::ptkdb::Entry_Class ( -width, 50, -bg => '#FFFFFF', -state , 'normal' , -relief , 'flat' ,-font , 'exprTextFont' )->pack(-side => 'left', -anchor=>'nw') ;
	}
	$frame->Button(-text ,'List', -command , sub { $self->EnterExpr() ; }, -width , 4, -relief , 'raised')->pack(-side => 'left', -padx , 5) ;

	$self->{'entry'}->bind('<Return>', sub { $self->EnterExpr() }) ;

	$self->{'data_list'} = $self->{'data_page'}->Scrolled('HList',
		@Devel::ptkdb::scrollbar_cfg,
		separator => $Devel::ptkdb::pathSep,
		-font , 'exprTextFont',
		-command => \&Devel::ptkdb::expr_expand,
		-selectmode => 'multiple',
		-height => 25
	) ;
	$self->{'data_list'}->pack(-side => 'top', -fill => 'both', -expand => 1) ;
	$self->{'data_list'}->packAdjust(-side => 'top', -fill => 'x', -expand => 1) ;
	$self->{'proximity_data_list'} = $self->{'data_page'}->Scrolled('HList',
			@Devel::ptkdb::scrollbar_cfg,
			separator => $Devel::ptkdb::pathSep,
			-font , 'exprTextFont',
			-command => \&Devel::ptkdb::expr_expand_proximity,
			## -selectmode => 'multiple',
			-height => 3
			) ;

	$self->{'proximity_data_list'}->pack(-side => 'top', -fill => 'both', -expand => 1) ;

	$self->{'subs_page_activated'} = 0 ;
	$self->{'subs_page'} = $self->{'notebook'}->add("subspage", -label => "Subs", -createcmd => sub { $self->setup_subs_page }) ;

	$self->setup_breakpts_page() ;
	if ($Devel::ptkdb::use_log_page) {
		$self->{'log_page'} = $self->{'notebook'}->add("logpage", -label => "Log", -createcmd => sub { $self->setup_log_page }) ;
		$self->{'log_page_text'} = $self->{'log_page'}->Scrolled('ROText', @Devel::ptkdb::scrollbar_cfg,-font,'codeTextFont')->pack(-fill,'both', -expand, 1);
	} else {
		$self->{'log_page'} = undef;
		$self->{'log_page_text'} = undef;
	}

} # end of setup_frames

sub configure_text {
	my($self) = @_ ;
	my($txt, $mw) = ($self->{'text'}, $self->{'main_window'}) ;
	my($place_holder) ;

	$self->{'expr_balloon'} = $txt->Balloon(-background=>$Devel::ptkdb::balloon_background);
	$self->{'expr_balloon'}->Subwidget('message')->configure(-anchor,'nw', -justify,'left');
	$self->{'balloon_expr'} = ' ' ; # initial expression
	if ( $Devel::ptkdb::DataDumperAvailable ) { # # setup a dumper for the balloon
		$self->{'balloon_dumper'} = Data::Dumper->new([$place_holder]) ;
		$self->{'balloon_dumper'}->Terse(1) ;
		$self->{'balloon_dumper'}->Indent($Devel::ptkdb::eval_dump_indent) ;
		$self->{'quick_dumper'} = Data::Dumper->new([$place_holder]) ;
		$self->{'quick_dumper'}->Terse(1) ;
		$self->{'quick_dumper'}->Indent(0) ;
	}
	$self->{'expr_balloon_msg'} = ' ' ;
	$self->attach_balloon($txt);
	# tags for the text
	my @stopTagConfig = ( -foreground => 'white', -background  => $mw->optionGet("stopcolor", "background") || $ENV{'PTKDB_STOP_TAG_COLOR'} || 'darkgreen' ) ;

	my $stopFnt = $mw->optionGet("stopfont", "background") || $ENV{'PTKDB_STOP_TAG_FONT'};
	push @stopTagConfig, ( -font => $stopFnt ) if $stopFnt ; # user may not have specified a font, if not, stay with the default

#	$txt->tagConfigure('code',-foreground, 'black');
	$txt->tagConfigure('bookmark', "-background" => $mw->optionGet("bookmarktagcolor", "background") || $ENV{'PTKDB_BOOKMARKS_COLOR'} || "#CEFFDB") ;
	$txt->tagConfigure('stoppt', @stopTagConfig) ;
	$txt->tagConfigure('search_tag', "-background" => $mw->optionGet("searchtagcolor", "background") || "green") ;

	$txt->tagConfigure("breakableLine", -overstrike => 0) ;
	$txt->tagConfigure("nonbreakableLine", -overstrike => 1) ;
	$txt->tagConfigure("breaksetLine", -background => $mw->optionGet("breaktagcolor", "background") || $ENV{'PTKDB_BRKPT_COLOR'} || 'red') ;
	$txt->tagConfigure("breakdisabledLine", -background => $mw->optionGet("disabledbreaktagcolor", "background") || $ENV{'PTKDB_DISABLEDBRKPT_COLOR'} || 'green') ;
	$txt->tagConfigure("breaksetLineTemp", -background => $mw->optionGet("breaktagcolor", "background") || $ENV{'PTKDB_TEMP_BRKPT_COLOR'} || '#00FFFF') ; ## 12.11.2014/mm

	$txt->tagRaise('sel');

	$txt->tagBind("breakableLine", '<Button-1>', [ \&Devel::ptkdb::set_breakpoint_tag, $self, Tk::Ev('@'), 1 ]  ) ;
	$txt->tagBind("breakableLine", '<Shift-Button-1>', [ \&Devel::ptkdb::set_breakpoint_tag, $self, Tk::Ev('@'), 0 ]  ) ;

	$txt->tagBind("breaksetLine", '<Button-1>',  [ \&Devel::ptkdb::clear_breakpoint_tag, $self, Tk::Ev('@') ]  ) ;
	$txt->tagBind("breaksetLine", '<Shift-Button-1>',  [ \&Devel::ptkdb::change_breakpoint_tag, $self, Tk::Ev('@'), 0 ]  ) ;

	$txt->tagBind("breakdisabledLine", '<Button-1>', [ \&Devel::ptkdb::clear_breakpoint_tag, $self, Tk::Ev('@') ]  ) ;
	$txt->tagBind("breakdisabledLine", '<Shift-Button-1>', [ \&Devel::ptkdb::change_breakpoint_tag, $self, Tk::Ev('@'), 1 ]  ) ;
} # end of configure_text


sub setup_options {
	my ($self) = @_ ;
	my $mw = $self->{'main_window'} ;

	return unless $mw->can('appname') ;

	$mw->appname("ptkdb") ;
	$mw->optionAdd("stopcolor" => 'cyan', 60 ) ;
	$mw->optionAdd("stopfont" => 'fixed', 60 ) ;
	$mw->optionAdd("breaktag" => 'red', 60 ) ;
	$mw->optionAdd("searchtagcolor" => 'green') ;

	$mw->optionClear ; #  necessary to reload xresources
} # end of setup_options

sub get_Main_Window {
	my $self = shift;
	my ($forceNew) = @_;
	my $hwnd;
	if(defined $forceNew && $forceNew) {
		$hwnd = Tk::MainWindow->new();
		DB::trace("Forced new main_window $hwnd");
	} else {
		$hwnd = $self->{'main_window'} if defined $self;
		if (defined ($hwnd) && Tk::Exists ($hwnd)) {
			DB::trace("Using Toplevel main_window $hwnd");
			$hwnd->deiconify() ;
		} else {
			$hwnd = Tk::MainWindow->new();
			DB::trace("New main_window $hwnd");
		}
	}
	return $hwnd;
}

sub DoQuestion {
	my $self = shift;
	my $hwnd = defined($self) ? $self->get_Main_Window() : Devel::ptkdb::get_Main_Window();
	my (%args) = @_;
	my $rv;

	my $mw = $hwnd->DialogBox(-title=> 'ptkdb - Question',-buttons=> ['OK','No']);
	$mw->protocol('WM_DELETE_WINDOW',sub{1});
	my $wr_001 = $mw -> Message ( -anchor , 'nw' , -borderwidth , 1 , -justify , 'left' , -relief , 'ridge' , -aspect , 400  ) -> pack(-anchor=>'nw', -side=>'top', -pady=>20, -fill=>'both', -expand=>1, -padx=>5);
	$wr_001->configure(-text, $args{-text});
	$rv =  $mw->Show();
	$rv = ($rv =~/OK/i) ? 1 : 0;
	return $rv;
} # end of DoQuestion

sub DoShowOptions {
	my ($self) = @_ ;
	my ($dlg,$msg);

	my $hwnd = $self->get_Main_Window();
	my $okaySub = sub {
		destroy $dlg ;
		$hwnd->fontDelete('optionsTextFont');
		} ;
	my $cancelSub = sub {
		destroy $dlg ;
		$hwnd->fontDelete('optionsTextFont');
		} ;
	$dlg = $hwnd->Toplevel(-title => "Options", -overanchor => 'cursor');
	$dlg->protocol('WM_DELETE_WINDOW', $cancelSub);
	my $d = Data::Dumper->new([\%ENV],['ENV']) ;
	$d->Indent(2) ; # make it more editable for people
	if( $d->can('Dumpxs') ) {
		$msg = $d->Dumpxs() ;
	} else {
		$msg = $d->Dump() ;
	}
	my $font = $hwnd->fontCreate('optionsTextFont',@{$Devel::ptkdb::code_text_font[1]});
	my $t = $dlg->Scrolled('ROText',
		@Devel::ptkdb::scrollbar_cfg,
		-font , 'optionsTextFont', ## @Devel::ptkdb::code_text_font,
		-bg , 'white',
		-height , 20,
		-tabs , 4,
		)->pack( -side => 'top', -expand , 1 , -fill ,'both') ;
	my $f = $dlg->Frame()->pack(-side , 'top', -fill => 'x', -expand => 1);
	$f->Button( -text => "OK", -command => $okaySub , -relief , 'raised', -bg , 'white')->pack( -side => 'left', -fill => 'x', -expand => 1 , -padx , 3, -pady , 3)->focus();
	$f->Button( -text => "Cancel", -command => $cancelSub, -relief , 'raised', -bg , 'white' )->pack( -side => 'left', -fill => 'x', -expand => 1 , -padx , 3, -pady , 3);
	# Pressing Escape should also close this Window.
	$dlg->bind('<Escape>', $cancelSub) ;
	$dlg->bind('<Return>', $okaySub) ;

	## insert here filter for $msg , if any is desired
	$t->insert('end',$msg);
} # end of DoShowOptions

sub DoAlert {
	my($self, $msg, $title) = @_ ;
	my($dlg) ;
	my $okaySub = sub {
		$dlg->destroy() ;
		} ;
	my $hwnd = $self->get_Main_Window();

	$dlg = $hwnd->Toplevel(-title => "ptkdb - $title" || "ptkdb - Alert", -overanchor => 'cursor') ;
	$dlg->Label( -text => $msg )->pack( -side => 'top',-padx, 20, -pady , 20 ) ;
	$dlg->Button( -text => "OK", -command => $okaySub )->pack( -side => 'top' )->focus   ;

	# Pressing Escape should also close the About Window.
	$dlg->bind('<Escape>', $okaySub) ;
	$dlg->bind('<Return>', $okaySub) ;
} # end of DoAlert

sub doAlert_Modal {
	my ($self, $msg, $title, $okaySub, $cancelSub) = @_ ;
	my $rv;

	$okaySub = sub{ 1 } unless defined $okaySub;
	$cancelSub = sub{ 0 } unless defined $cancelSub;
	my $dlg ;
	my $hwnd = $self->get_Main_Window();
	my @widgets = $hwnd->grabCurrent();
	if (@widgets) {
		map {$_->grabRelease()} @widgets; ## release
	}
	$dlg = $hwnd->DialogBox(-title => "ptkdb - $title", -buttons => [qw/OK Cancel/]) ;
	$dlg->add('Label',-text => $msg, -anchor , 'nw' , -justify , 'left' )-> pack(-padx,10, -pady,10);
	$dlg->add('ptkdb_arglistEditor',-arglist, \@Devel::ptkdb::script_args)-> pack(-padx,10, -pady,10);
	my $retry = $dlg->Show();
	if ($retry =~/OK/i) {
		&$okaySub();
		$rv = 1
	} elsif ($retry =~/Cancel/i) {
		&$cancelSub();
		$rv = 0
	} else {}
	if (@widgets) {
		map {$_->grab()} @widgets; ## restore grab
	}
	return $rv ;
} # end of doAlert_Modal

sub simplePromptBox_Modal {
	my ($self, $title, $defaultText, $okaySub, $cancelSub) = @_ ;
	my ($top, $entry, $okayBtn) ;
	my $rv;
	$Devel::ptkdb::promptString = $defaultText;
	my $hwnd = $self->get_Main_Window();

	my @widgets = $hwnd->grabCurrent();
	if (@widgets) {
		map {$_->grabRelease()} @widgets; ## release
	}
	$top = $hwnd->DialogBox(-title => "ptkdb - $title", -buttons => [qw/OK Cancel/]) ;
	$entry = $top->add('Entry', -textvariable => \$Devel::ptkdb::promptString, -width , 64)->pack(-side => 'top', -fill => 'both', -expand => 1, -padx => 20, -pady => 20) ;
	$entry->icursor('end') ;
	$entry->selectionRange(0, 'end') if $entry->can('selectionRange') ; # some win32 Tk installations can't do this
	$entry->focus() ;

	my $retry = $top->Show();

	if ($retry =~/OK/i) {
		&$okaySub();
		$rv = 1
	} elsif ($retry =~/Cancel/i) {
		&$cancelSub();
		$rv = 0
	} else {}
	if (@widgets) {
		map {$_->grab()} @widgets; ## restore grab
	}
	return $rv ;
} # end of simplePromptBox_Modal

sub simplePromptBox {
	my ($self, $title, $defaultText, $okaySub, $cancelSub) = @_ ;
	my ($top, $entry, $okayBtn) ;
	my $hwnd = $self->get_Main_Window();

	$top = $hwnd->Toplevel(-title => "ptkdb - $title", -overanchor => 'cursor' ) ;
	$Devel::ptkdb::promptString = $defaultText ;
	$entry = $top->Entry('-textvariable' => \$Devel::ptkdb::promptString)->pack(-side => 'top', -fill => 'both', -expand => 1, -padx => 20, -pady => 20) ;
	$okayBtn = $top->Button( -text => "OK",
		-command => sub {  &$okaySub() ; $top->destroy ;},
		-bg => 'white',
		@Devel::ptkdb::button_font
		)->pack(-side => 'left', -fill => 'both', -expand => 1) ;
	$top->Button( -text => "Cancel",
		-command => sub { &$cancelSub() if $cancelSub ; $top->destroy() },
		-bg => 'white',
		@Devel::ptkdb::button_font
		)->pack(-side => 'left', -fill => 'both', -expand => 1) ;

	$entry->icursor('end') ;
	$entry->selectionRange(0, 'end') if $entry->can('selectionRange') ; # some win32 Tk installations can't do this
	# Binding important keys
	$entry->bind('<Escape>', sub { &$cancelSub() if $cancelSub; $top->destroy(); } );
	$entry->bind('<Return>', sub { &$okaySub(); $top->destroy(); } );
	$entry->focus() ;
	return $top ;
} # end of simplePromptBox

sub get_entry_text {
	my($self) = @_ ;
	return $self->{'entry'}->get() ; # get the text in the entry
} # end of get_entry_text

#
# Clear any text that is in the entry field.  If there
# was any text in that field return it.  If there
# was no text then return any selection that may be active.
#
sub clear_entry_text {
	my($self) = @_ ;
	my $entry = ($self->{'entry'}->can('Subwidget')) ? $self->{'entry'}->Subwidget('entry') : $self->{'entry'};
	my $str =  $entry->get() ;
	$entry->delete(0, 'end') ;

	if( !$str || $str eq "" || $str =~ /^\s+$/ ) { # No String, Empty String Or a string that is only whitespace
		#
		# If there is no string or the string is just white text
		# Get the text in the selction( if any)
		#
		if( $self->{'text'}->tagRanges('sel') ) { # check to see if 'sel' tag exists (return undef value)
			$str = $self->{'text'}->get("sel.first", "sel.last") ; # get the text between the 'first' and 'last' point of the sel (selection) tag
			}
			# If still no text, bring the focus to the entry
		elsif( !$str || $str eq "" || $str =~ /^\s+$/ ) {
			$self->{'entry'}->focus() ;
			$str = "" ;
		} else {}
	}
	return $str ;
} # end of clear_entry_text

sub setvalueOfAllBreakpoints {
	my $self = shift;
	my ($fname,$value) = @_;
	$fname = $self->{'current_file'} unless defined $fname;
	my $offset = 0;
	local(*dbline) = $main::{'_<' . $fname} ;
	my $nLines = $#dbline; ## scalar @dbline ;
	$offset = $dbline[1] =~ /use\s+.*Devel::_?ptkdb/ ? 1 : 0 ;
	map {
		my $index = $_;
		my $brkPt;
		if (($brkPt = &DB::getdbline($fname,$index))) {
			if ($brkPt->{'value'} ne $value) {
				$brkPt->{'value'} = $value;
				$self->brkPtCheckbutton($fname, $index, $brkPt);
			} ## else {}
		} ## else {}
	} $offset .. $nLines;

	for(keys %{$DB::window->{'breakpts_table_data'}}) {
		if (/^$fname/) {
			my $brkpt = $DB::window->{'breakpts_table_data'}->{$_}->{'brkpt'};
			$brkpt->{'value'} = $value if ($brkpt->{'value'} ne $value);
		} else {}
	}
	$DB::window->{'dirtyFlag'} = 1;
	$DB::window->setStatus1();
} # end of setvalueOfAllBreakpoints

sub brkPtCheckbutton {
	my ($self, $fname, $idx, $brkPt) = @_ ;
	my ($widg) ;

	change_breakpoint_tag($self->{'text'}, $self, "$idx.0", $brkPt->{'value'}) if $fname eq $self->{'current_file'} ;

} # end of brkPtCheckbutton

#
# insert a breakpoint control into our breakpoint list.
# returns a handle to the control
#
#  Expression, if defined, is to be evaluated at the breakpoint
# and execution stopped if it is non-zero/defined.
#
# If action is defined && True then it will be evalled
# before continuing.
#

sub createTempBrkpt {
	my $self = shift;
	my ($fname,$index, $value, $expression,$txt) = @_;
	$value = 1 unless defined $value;
	$expression = '' unless defined $expression;
	$txt = '' unless defined $txt;
	my $brkPt = {} ;
	@$brkPt{'type', 'line',  'expr',      'value', 'fname', 'text'} =
	       ('temp', $index,  $expression, $value,   $fname, "$txt") ;

	return $brkPt
}

sub createUserBrkpt {
	my $self = shift;
	my ($fname,$index, $value, $expression,$txt) = @_;
	$value = 1 unless defined $value;
	$expression = '' unless defined $expression;
	$txt = '' unless defined $txt;
	my $brkPt = {} ;
	@$brkPt{'type', 'line',  'expr',      'value', 'fname', 'text'} =
	       ('user', $index,  $expression,  $value,  $fname, "$txt") ;
	return $brkPt
}

sub insertBreakpointList {
	my ($self, $fname, @brks) = @_ ;
	my ($btn, $cnt, $item) ;
	my $rv=0;
	local(*dbline) = $main::{'_<' . $fname} ;
	my $offset = $dbline[1] =~ /use\s+.*Devel::_?ptkdb/ ? 1 : 0 ;

	while( @brks ) {
		my($index, $value, $expression) = splice @brks, 0, 3 ; # take args 3 at a time
		next if !&DB::checkdbline($fname, $index + $offset);
		my $txt = &DB::getdbtextline($fname, $index) ;
		my $brkPt = $self->createUserBrkpt($fname,$index,$value,$expression,$txt);
		&DB::setdbline($fname, $index + $offset, $brkPt) ;
		$self->add_to_breakpts_table_data($brkPt) ;
		$rv++;
		next unless $fname eq $self->{'current_file'} ;

		$self->{'text'}->tagRemove("breakableLine", "$index.0", "$index.$Devel::ptkdb::linenumber_length") ;
		$self->{'text'}->tagAdd($value ? "breaksetLine" : "breakdisabledLine",  "$index.0", "$index.$Devel::ptkdb::linenumber_length") ;
	} # end of loop
	if ($rv) {
		$self->refreshBrkptPage() ;
		$self->{'notebook'}->raise("brkptspage") unless ($self->{'notebook'}->raised() eq "brkptspage");
	}
	return $rv
} # end of insertBreakpointList


sub insertBreakpoint {
	my $self = shift ;
	my ($fname, @brks) = @_ ;
	my $rv = 0;
	my ($btn, $cnt, $item) ;

	local(*dbline) = $main::{'_<' . $fname} ;
	my $offset = $dbline[1] =~ /use\s+.*Devel::_?ptkdb/ ? 1 : 0 ;

	while( @brks ) {
		my($index, $value, $expression) = splice @brks, 0, 3 ; # take args 3 at a time
		my $txt = &DB::getdbtextline($fname, $index) ;
		my $brkPt = $self->createUserBrkpt($fname,$index,$value,$expression,$txt);
		&DB::setdbline($fname, $index + $offset, $brkPt) ;
		$self->add_brkpt_to_brkpt_page($brkPt) ;
		$rv++;
		next unless $fname eq $self->{'current_file'} ;

		$self->{'text'}->tagRemove("breakableLine", "$index.0", "$index.$Devel::ptkdb::linenumber_length") ;
		$self->{'text'}->tagAdd($value ? "breaksetLine" : "breakdisabledLine",  "$index.0", "$index.$Devel::ptkdb::linenumber_length") ;
	} # end of loop
	return 1
} # end of insertBreakpoint

sub validate_brkpt_expr {
	my ($v) = @_;	## actual field value, entered char, indicators
	return 1 unless defined $v;
	return 1 if ( $v =~ /^\s*$/);

	eval "{no strict; $v }";

	unless ($@) {
		$DB::window->{'dirtyFlag'} = 1;
		$DB::window->setStatus1();
		return 1
	}
	$DB::window->DoAlert("Entered cond expression \n$v\nmay be incorrect,\n$@,\n pls check.");
	return 0
}

sub brkptKey {
	my $self = shift;
	my ($fname,$index) = @_;
	return $fname.'.'.sprintf('%05d',$index);
}

sub adapt_brkpt_page_width {
	my $self = shift;
	my ($w) = @_;
	return 0 unless($Devel::ptkdb::codeside =~/^(right|left)/);

	my $wN = $w+10;

	return 1 if ($self->{'notebook'}->Width >= $wN ) ;

	my $hN = $self->{'notebook'}->Height;
	my $wM = $wN + $self->{'main_window_frame'}->Width()+20;
	my $hM = $self->{'main_window'}->geometry();
	($hM) = $hM =~ /^\d+x(\d+)/i;
	$self->{'main_window'}->geometry($wM.'x'.$hM);
	$self->{'notebook'}->GeometryRequest($wN,$hN);
	$self->{'main_window'}->update();

	return 2;
} # end of adapt_brkpt_page_width

sub createBrkptWidget {
	my $self = shift;
	my ($fname, $index, $brkPt) = @_;
	my $btnName = $fname ;
	$btnName =~ s/.*\/([^\/]*)$/$1/o ;
	my ($wr_001,$wr_002,$wr_003,$wr_004,$wr_005,$wr_007,$wr_008);
	my $frm=$self->{'breakpts_table'}->Frame(-relief => 'sunken',-borderwidth,1) ;
	$wr_001=$frm->Frame ( -borderwidth , 1 , -relief , 'flat'  ) -> pack(-anchor=>'nw', -side=>'top', -fill=>'both', -expand=>1,-pady, 4);
	$wr_003=$wr_001->Checkbutton( -text => "$btnName : $index", -variable => \$brkPt->{'value'}, # CAUTION value tracking
				-command => sub {
					$self->brkPtCheckbutton($fname, $index, $brkPt);
					$DB::window->{'dirtyFlag'} = 1;
					$DB::window->setStatus1();
					},
				-relief , 'flat' , -anchor , 'nw' , -indicatoron , 1 , -justify , 'left'
				)->pack(-anchor=>'nw', -side=>'left');
	$wr_004=$wr_001->Button ( -underline , 0 , -relief , 'raised' , -state , 'normal' , -text , 'goto',
				-command => sub {
							$self->set_file($fname, $index) ;
							}
				)->pack(-anchor=>'ne', -side=>'right', -padx,2);
	$wr_005=$wr_001->Button ( -underline , 0 , -relief , 'raised' , -state , 'normal' , -text , 'delete',
				-command => sub {
							$self->removeBreakpoint($fname, $index) ;
							$DB::window->{'dirtyFlag'} = 1;
							$DB::window->setStatus1();
							}
				)->pack(-anchor=>'ne', -side=>'right',-padx,2);
	$wr_002=$frm->Frame ( -borderwidth , 1 , -relief , 'flat'  ) -> pack(-anchor=>'nw', -side=>'top', -fill=>'both', -expand=>1, -pady,4);
	$wr_007=$wr_002->Label ( -underline , 0 , -relief , 'flat' , -anchor , 'e' , -justify , 'right' , -text , 'Condition:', -width, 12
				)->pack(-anchor=>'nw', -side=>'left');
	$wr_008=$wr_002->Entry ( -relief , 'sunken' , -state , 'normal' , -justify , 'left', -textvariable => \$brkPt->{'expr'},
				-width,32,
				-vcmd ,\&validate_brkpt_expr,
				-validate , 'focusout'
				)->pack(-anchor=>'nw', -side=>'left', -fill=>'x', -expand=>1);
	return $frm;
} ## end of createBrkptWidget

sub refreshBrkptPage {
	my $self = shift;
	my $row = 0;
	my $col = 0; ## Tk::Table 4016
	my $width = 0;
	my ($fname,$brkPt,$index,$frm,$bKey);
	my @frmList;
	$self->{'breakpts_table'}->clear();
	my @brkpts = sort keys %{$self->{'breakpts_table_data'}};
	$self->{'breakpts_table'}->configure(-columns,1,-rows,scalar(@brkpts));
	map {
		$bKey = $self->{'breakpts_table_data'}->{$_};
		$frm = $self->createBrkptWidget ($bKey->{'fname'}, $bKey->{'line'}, $bKey->{'brkpt'});
		if (defined ($frm)) {
			$self->{'breakpts_table'}->put($row, $col, $frm) ;  ## Tk::Table 4016
			push @frmList,$frm;
		} else {
			DB::log("Missing widget ref for key '$_'");
		}
		$row++ ;  ## Tk::Table 4016
	} @brkpts;
	#map {
	#	my $w = $_->reqwidth();
	#	warn "refreshBrkptPage w = $w";
	#	$width = $w if($width < $w);
	#} @frmList;
	#$width = $self->{'breakpts_table'}->reqwidth();
	#@frmList = (); @brkpts =();
	#$self->adapt_brkpt_page_width($width) if ($width);
	$self->adaptBrkptPageWidth();
	return 1
} # end of refreshBrkptPage

sub adaptBrkptPageWidth {
	my $self =shift;
	my $width = $self->{'breakpts_table'}->reqwidth();
	$self->adapt_brkpt_page_width($width) if ($width);
}

sub add_to_breakpts_table_data { 	# Add the given breakpoint to 'breakpts_table_data'
	my $self = shift;
	my($brkPt) = @_ ;
	my( $fname, $index) = @$brkPt{'fname', 'line'} ;
	my $key = $self->brkptKey($fname, $index);
	return if exists $self->{'breakpts_table_data'}->{$key} ;
	$self->{'breakpts_table_data'}->{$key}->{'brkpt'} = $brkPt;
	$self->{'breakpts_table_data'}->{$key}->{'fname'} = $fname ;
	$self->{'breakpts_table_data'}->{$key}->{'line'} = $index ;
	$self->{'breakpts_table_data'}->{$key}->{'frm'} = '' ;
	return 1
} # end of add_to_breakpts_table_data

sub add_brkpt_to_brkpt_page { 	# Add the given breakpoint to the page 'brkptspage'
	my $self = shift;
	$self->add_to_breakpts_table_data(@_);
	$self->refreshBrkptPage();
	$self->{'notebook'}->raise("brkptspage") unless ($self->{'notebook'}->raised() eq "brkptspage");
} # end of add_brkpt_to_brkpt_page

sub locateAdjuster {
	my $self = shift;
	my ($parent)= @_;
	my @children = $parent->packSlaves();
	my $adj;
	while (@children) {
		$adj= shift @children;
		if (ref($adj) =~/Adjuster/) {
			last;
		} elsif (ref($adj) =~/Frame/) {
			$adj = $self->locateAdjuster($adj);
			last if(defined($adj) && ref($adj) =~/Adjuster/);
		} else {
			$adj= undef;
		}
	}
	return $adj;
}

sub remove_brkpt_from_brkpt_page {
	my($self, $fname, $index) = @_ ;

	my $key = $self->brkptKey($fname, $index);
	if (exists $self->{'breakpts_table_data'}->{$key}) {
		delete $self->{'breakpts_table_data'}->{$key} ;
		$self->refreshBrkptPage();
	} ## else {}
} # end of remove_brkpt_From_brkpt_page

sub insertTempBreakpoint { # Supporting the "Run To Here..." command
	my ($self, $fname, $index) = @_ ;
	my($offset) ;
	local(*dbline) = $main::{'_<' . $fname} ;

	$offset = $dbline[1] =~ /use\s+.*Devel::_?ptkdb/ ? 1 : 0 ;

	return if( &DB::getdbline($fname, $index + $offset) ) ; # we already have a breakpoint here

	&DB::setdbline($fname, $index + $offset, $self->createTempBrkpt($fname,$index) ) ;

	$self->{'text'}->tagRemove("breakableLine", "$index.0", "$index.$Devel::ptkdb::linenumber_length") ; # 12.11.2014/mm
	$self->{'text'}->tagAdd("breaksetLineTemp", "$index.0", "$index.$Devel::ptkdb::linenumber_length") ; # 12.11.2014/mm
} # end of insertTempBreakpoint

sub reinsertBreakpoints {
	my ($self, $fname) = @_ ;
	my ($brkPt) ;
	my @brkptList;
	foreach $brkPt ( &DB::getBreakpoints($fname) ) {
		next unless defined $brkPt ;
		push @brkptList , @$brkPt{'line', 'value', 'expr'} if( $brkPt->{'type'} eq 'user' ) ;
		$self->insertTempBreakpoint($fname, $brkPt->{'line'}) if( $brkPt->{'type'} eq 'temp' ) ;
	}
	$self->insertBreakpointList($fname,@brkptList);
} # end of reinsertBreakpoints

sub removeBreakpointTags {
	my ($self, @brkPts) = @_ ;
	my($idx, $brkPt) ;

	foreach $brkPt (@brkPts) {
		$idx = $brkPt->{'line'} ;
		if ( $brkPt->{'value'} ) {
			$self->{'text'}->tagRemove("breaksetLine", "$idx.0", "$idx.$Devel::ptkdb::linenumber_length") ;
		}
		else {
			$self->{'text'}->tagRemove("breakdisabledLine", "$idx.0", "$idx.$Devel::ptkdb::linenumber_length") ;
		}
		$self->{'text'}->tagAdd("breakableLine", "$idx.0", "$idx.$Devel::ptkdb::linenumber_length") ;
	}
} # end of removeBreakpointTags

sub removeTempBreakpointTags { ## 12.11.2014/mm
	my ($self, @brkPts) = @_ ;
	my($idx, $brkPt) ;

	foreach $brkPt (@brkPts) {
		$idx = $brkPt->{'line'} ;
		if ( $brkPt->{'value'} ) {
			$self->{'text'}->tagRemove("breaksetLineTemp", "$idx.0", "$idx.$Devel::ptkdb::linenumber_length") ;
		}
		else {
			$self->{'text'}->tagRemove("breakdisabledLine", "$idx.0", "$idx.$Devel::ptkdb::linenumber_length") ;
		}
		$self->{'text'}->tagAdd("breakableLine", "$idx.0", "$idx.$Devel::ptkdb::linenumber_length") ;
	}
} # end of removeBreakpointTags

sub removeBreakpoint { # Remove a breakpoint from the current window
	my ($self, $fname, @idx) = @_ ;
	my ($idx, $chkIdx, $i, $j, $info) ;
	my($offset) ;
	local(*dbline) = $main::{'_<' . $fname} ;

	$offset = $dbline[1] =~ /use\s+.*Devel::_?ptkdb/ ? 1 : 0 ;

	foreach $idx (@idx) { # end of removal loop
		next unless defined $idx ;
		my $brkPt = &DB::getdbline($fname, $idx + $offset) ;
		next unless $brkPt ; # if we do not have an entry
		&DB::cleardbline($fname, $idx + $offset) ;
		$self->remove_brkpt_from_brkpt_page($fname, $idx) ;

		next unless $brkPt->{'fname'} eq $self->{'current_file'}  ; # if this isn't our current file there will be no controls

		$self->removeBreakpointTags($brkPt) ;
	} # end of idx loop
} # end of removeBreakpoint

sub removeAllBreakpoints {
	my ($self, $fname) = @_ ;
	$fname = $self->{'current_file'} unless defined $fname;
	$self->removeBreakpoint($fname, &DB::getdblineindexes($fname)) ;
} # end of removeAllBreakpoints

sub removeAllBreakpointsAllFiles {
	my ($self) = @_ ;
	map {
		if (/^_</) {
			s/^_<//;
			DB::trace("Removing all breakpoint from '$_'");
			$self->removeAllBreakpoints ($_) ;
		} else {
			DB::trace("No breakpoints to remove from '$_'");
		}
	} keys %$DB::main;
	&DB::clearalldblines();
}

sub deleteAllProximityExprs {
	my ($self) = @_ ;
	$DB::window->{'proximity_data_list'}->delete('all') ;
} # end of deleteAllProximityExprs

sub deleteAllExprs { # Delete expressions prior to an update
	my ($self) = @_ ;
	$self->{'data_list'}->delete('all') ;
} # end of deleteAllExprs

sub EnterExpr {
	my ($self) = @_ ;
	my $str = $self->clear_entry_text() ;
	if( $str && $str ne "" && $str !~ /^\s+$/ ) { # if there is an expression and it's more than white space
		$self->saveInputIntoHistory($self->{'entry'},$str);
		my $isCall = ($Devel::ptkdb::allow_calls_in_expr_list) ? 0 : 'ptkdbTools'->checkIfCall($str);
		if (!$isCall ) {
			$str =~s/^\s+//; $str =~s/\s+$//;
			$self->{'expr'} = $str ;
			$self->{'event'} = 'expr' ;
		} else {
			$self->DoAlert("The given expr is a message or subroutine call.\nActually, this is not allowed.\nCheck the option 'allow calls in expr list' to allow it.\n\nBe careful!") ;
		}
	}
} # end of EnterExpr

sub QuickExpr {
	my ($self) = @_ ;

	my $entry = ($self->{'quick_entry'}->can('Subwidget')) ? $self->{'quick_entry'}->Subwidget('entry') : $self->{'quick_entry'};
	my $str = $entry->get() ;
	if( $str && $str ne "" && $str !~ /^\s+$/ ) { # if there is an expression and it's more than white space
		$self->saveInputIntoHistory($self->{'quick_entry'});
		$self->{'qexpr'} = $str ;
		$self->{'event'} = 'qexpr' ;
	}
} # end of QuickExpr

sub deleteExpr {
	my $self = shift ;
	my ($entry, $i, @indexes) ;
	my @sList = $self->{'data_list'}->info('select') ;
	#
	# if we're deleting a top level expression
	# we have to take it out of the list of expressions
	#
	foreach $entry ( @sList ) {
		next if ($entry =~ /\//) ; # goto next expression if we're not a top level ( expr/entry)
		$i = 0 ;
		grep { push @indexes, $i if ($_->{'expr'} eq $entry) ; $i++ ; } @{$self->{'expr_list'}} ;
	} # end of check loop

	for( 0..$#indexes ) { # now take out our list of indexes ;
		splice @{$self->{'expr_list'}}, $indexes[$_] - $_, 1 ;
	}

	for( @sList ) {
		$self->{'data_list'}->delete('entry', $_) ;
	}
} # end of deleteExpr

sub fixExprPath {
	my(@pathList) = @_ ;

	for (@pathList) {
		s/$Devel::ptkdb::pathSep/$Devel::ptkdb::pathSepReplacement/go ;
	} # end of path list

	return $pathList[0] unless wantarray ;
	return @pathList ;
} # end of fixExprPath

##
##  Inserts an expression($theRef) into an HList Widget($dl).  If the expression
## is an array, blessed array, hash, or blessed hash(typical object), then this
## routine is called recursively, adding the members to the next level of hierarchy,
## prefixing array members with a [idx] and the hash members with the key name.
## This continues until the entire expression is decomposed to it's atomic constituents.
## Protection is given(with $reusedRefs) to ensure that 'circular' references within
## arrays or hashes(i.e. where a member of a array or hash contains a reference to a
## parent element within the hierarchy.
##
#
# Returns 1 if successfully added 0 if not
#

sub insertExpr {
	my($self, $reusedRefs, $dl, $theRef, $name, $depth, $dirPath) = @_ ;
	my($label, $type, $result, $selfCnt, @circRefs) ;
	local($^W) = 0 ; # spare us uncessary warnings about comparing strings with ==

	$dirPath = "" unless defined $dirPath ;
	$label = "" ;
	$selfCnt = 0 ;

	while( ref $theRef eq 'SCALAR' ) {
		$theRef = $$theRef ;
	}
	REF_CHECK: for( ; ; ) {
		push @circRefs, $theRef ;
		$type = ref $theRef ;
		last unless ($type eq "REF")  ;
		$theRef = $$theRef ; # dref again
		$label .= "\\" ; # append a
		if( grep $_ == $theRef, @circRefs ) {
			$label .= "(circular)" ;
			last ;
		}
	}
	if( !$type || $type eq "" || $type eq "GLOB" || $type eq "CODE") {
		eval {
			if( !defined $theRef ) {
				$dl->add($dirPath . $name, -text => "$name = $label" . "UNDEF") ;
			} else {
				$theRef = ptkdbTools->toHex($theRef) if ($theRef =~/[\x00-\x06\x14\x1f]/);
				$dl->add($dirPath . $name, -text => "$name = $label$theRef") ;
			}
		} ;
		if ($@) {
			$self->DoAlert($@);
			return 0;
		}
		return 1 ;
	}

	if($type eq 'ARRAY' or "$theRef" =~ /ARRAY/ ) {
		my ($r, $idx) ;
		$idx = 0 ;
		eval {
			$dl->add($dirPath . $name, -text => "$name = $theRef") ;
		} ;
		if( $@ ) {
			DB::log($@) ;
			return 0 ;
		}
		$result = 1 ;
		foreach $r ( @{$theRef} ) {
			if( grep $_ == $r, @$reusedRefs ) { # check to make sure that we're not doing a single level self reference
				eval {
					$dl->add($dirPath .  fixExprPath($name) . $Devel::ptkdb::pathSep . "__ptkdb_self_path" . $selfCnt++, -text => "[$idx] = $r REUSED ADDR") ;
				} ;
				DB::log($@) if( $@ ) ;
				next ;
			}
			push @$reusedRefs, $r ;
			$result = $self->insertExpr($reusedRefs, $dl, $r, "[$idx]", $depth-1, $dirPath . fixExprPath($name) . $Devel::ptkdb::pathSep) unless $depth == 0 ;
			pop @$reusedRefs ;
			return 0 unless $result ;
			$idx += 1 ;
		}
		return 1 ;
	} # end of array case
	if("$theRef" !~ /HASH\050\060x[0-9a-f]*\051/o ) {
		eval {
			$dl->add($dirPath . fixExprPath($name), -text => "$name = $theRef") ;
		} ;
		if( $@ ) {
			DB::log($@) ;
			return 0 ;
		}
		## $DB::window->{'dirtyFlag'} = 1;
		## $DB::window->setStatus1();
		return 1 ;
	}
	#
	# Anything else at this point is
	# either a 'HASH' or an object
	# of some kind.
	#
	my($r, @theKeys, $idx) ;
	$idx = 0 ;
	@theKeys = sort keys %{$theRef} ;
	$dl->add($dirPath . $name, -text => "$name = " . "$theRef") ;
	$result = 1 ;

	foreach $r ( @$theRef{@theKeys} ) { # slice out the values with the sorted list
		if( grep $_ == $r, @$reusedRefs ) { # check to make sure that we're not doing a single level self reference
			eval {
				$dl->add($dirPath .  fixExprPath($name) . $Devel::ptkdb::pathSep . "__ptkdb_self_path" . $selfCnt++, -text => "$theKeys[$idx++] = $r REUSED ADDR") ;
			} ;
			DB::log("Bad path $@") if( $@ ) ;
			next ;
			}
		push @$reusedRefs, $r ;
		$result = $self->insertExpr($reusedRefs,                              # recursion protection
		$dl,                                      # data list widget
		$r,                                       # reference whose value is displayed
		$theKeys[$idx],                           # name
		$depth-1,                                 # remaining expansion depth
		$dirPath . $name . $Devel::ptkdb::pathSep # path to add to
		) unless $depth == 0 ;
		pop @$reusedRefs ;
		return 0 unless $result ;
		$idx += 1 ;
	} # end of ref add loop
	return 1 ;
} # end of insertExpr

sub set_line {      # set the line where we are stopped.
	my ($self, $lineno,$tagid) = @_ ;
	$tagid = 'stoppt' unless defined $tagid;
	my $text = $self->{'text'} ;

	return if( $lineno <= 0 ) ;

	if( $self->{'current_line'} > 0 ) {
		$text->tagRemove('stoppt', "1.0", "end") if($tagid eq 'stoppt');
	}
	$self->{'current_line'} = $lineno - $self->{'line_offset'} ;
	$text->tagAdd($tagid, "$self->{'current_line'}.0 linestart", "$self->{'current_line'}.0 lineend") ;
	$self->{'text'}->see("$self->{'current_line'}.0 linestart") ;
} # end of set_line

#
# Set the file that is in the code window.
#
# $fname the 'new' file to view
# $line the line number we're at
# $brkPts any breakpoints that may have been set in this file
#

use Carp ;

sub takeOverBrkptsFromPtkdbrc {
	my $self = shift;
	my ($fname) = @_;
	$fname = $self->{'current_file'} unless defined $fname;
	DB::trace("takeOverBrkptsFromPtkdbrc '$fname'");
	for (my $i = scalar(@DB::condbrkptList) - 1; $i >= 0 ; $i--) {
		my $list = $DB::condbrkptList[$i];
		my $f = $list->[0];
		$f = '/'.$f  if($fname =~ /^\// && $list->[0] !~ /^\//);
		if($fname eq $f) {
			$list->[0] = $f;
			__condbrkpt(@$list);
			splice @DB::condbrkptList, $i, 1 ;
		} ## else {}
	}
	for (my $i = scalar(@DB::brkptList) - 1; $i >= 0 ;$i--) {
		my $list = $DB::brkptList[$i];
		my $f = $list->[0];
		$f = '/'.$f  if($fname =~/^\// && $list->[0] !~ /^\//);
		if($fname eq $f) {
			$list->[0] = $f;
			__brkpt(@$list);
			splice @DB::brkptList,$i,1 ;
		} ## else {}
	}
	_brkonsub(\@DB::brkonsubList) if (@DB::brkonsubList);
} # eof takeOverBrkptsFromPtkdbrc

sub set_file {
	my ($self, $fname, $line, $tagid) = @_ ;
	my ($lineStr, $offset, $text, $i, @text, $noCode, $title) ;
	my (@breakableTagList, @nonBreakableTagList) ;
	$tagid = 'stoppt' unless defined $tagid;

	return unless $fname ;  # we're getting an undef here on 'Restart...'

	local(*dbline) = $main::{'_<' . $fname};
	#
	# with the #! /usr/bin/perl -d:ptkdb at the header of the file
	# we've found that with various combinations of other options the
	# files haven't come in at the right offsets
	#
	$offset = 0 ;
	$offset = 1 if $dbline[1] =~ /use\s+.*Devel::_?ptkdb/ ;
	$self->{'line_offset'} = $offset ;
	$text = $self->{'text'} ;
	if( $fname eq $self->{'current_file'} ) {
		$self->set_line($line,$tagid) unless (int($line) == int($self->{'current_line'}));
		return ;
	} # else {}
	$title = $fname ; # removing the - messes up stashes on -e invocations
	$title =~ s/^\-// ; # Tk does not like leadiing '-'s
	$self->{'main_window'}->configure('-title' => $title) ;
	$text->delete('0.0','end') ;
	my $len = $Devel::ptkdb::linenumber_length ;
	#
	# This is the tightest loop we have in the ptkdb code.
	# It is here where performance is the most critical.
	# The map block formats Perl code for display.  Since
	# the file could be potentially large, we will try
	# to make this loop as thin as possible.
	#
	# NOTE:  For a new Perl individual this may appear as
	# if it was intentionally obfuscated.  This is not
	# not the case.  The following code is the result
	# of an intensive effort to optimize this code.
	# Prior versions of this code were quite easier
	# to read, but took 3 times longer.
	#

	$lineStr = " " x 200 ; # pre-allocate space for $lineStr
	$i = 1 ;
	local($^W) = 0 ; # spares us useless warnings under -w when checking $dbline[$_] != 0
	#
	# The 'map' call will build list of 'string', 'tag' pairs
	# that will become arguments to the 'insert' call.  Passing
	# the text to insert "all at once" rather than one insert->('end', 'string', 'tag')
	# call at time provides a MASSIVE savings in execution time.
	#
	$noCode = ($#dbline - ($offset + 1)) < 0 ;
	if (!$Devel::ptkdb::decorate_code) {
		$text->insert('end', map {
				#
				# build collections of tags representing
				# the line numbers for breakable and
				# non-breakable lines.  We apply these
				# tags after we've built the text
				#
				($_ != 0 && push @breakableTagList, "$i.0", "$i.$len") || push @nonBreakableTagList, "$i.0", "$i.$len" ;
				$lineStr = sprintf($Devel::ptkdb::linenumber_format, $i++) . $_ ; # line number + text of the line
				substr $lineStr, -2, 1, '' if(substr($lineStr,-2,1) eq "\r"); #if $isWin32
				$lineStr .= "\n" unless /\n$/o ; # append a \n if there isn't one already
##				($lineStr, 'code') ; # return value for block, a string,tag pair for text insert
				($lineStr, '') ; # return value for block, a string,tag pair for text insert
		} @dbline[$offset+1 .. $#dbline] ) unless $noCode ;
	} else {
		map {
			($_ != 0 && push @breakableTagList, "$i.0", "$i.$len") || push @nonBreakableTagList, "$i.0", "$i.$len" ;
				$lineStr = sprintf($Devel::ptkdb::linenumber_format, $i++) . $_ ; # line number + text of the line
				substr $lineStr, -2, 1, '' if(substr($lineStr,-2,1) eq "\r"); #if $isWin32
				$lineStr .= "\n" unless /\n$/o ; # append a \n if there isn't one already
				my $items = ptkdbTools->parseVariables($lineStr);
				ptkdbTools->decorate($text,$items)
		}@dbline[$offset+1 .. $#dbline] unless $noCode ;
	}
	#
	# Apply the tags that we've collected
	# NOTE:  it was attempted to incorporate these
	# operations into the 'map' block above, but that
	# actually degraded performance.
	#
	$text->tagAdd("breakableLine", @breakableTagList) if @breakableTagList ; # apply tag to line numbers where the lines are breakable
	$text->tagAdd("nonbreakableLine", @nonBreakableTagList) if @nonBreakableTagList ; # apply tag to line numbers where the lines are not breakable.

	$self->set_line($line,$tagid ) ;  # Reinsert breakpoints (if info provided)
	$self->{'current_file'} = $fname ;
	$self->takeOverBrkptsFromPtkdbrc($fname);
	return $self->reinsertBreakpoints($fname) ;
} # end of set_file

#
# Get the current line that the insert cursor is in
#
sub get_lineno {
	my ($self) = @_ ;
	my ($info) ;
	$info = $self->{'text'}->index('insert') ; # get the location for the insertion point
	$info =~ s/\..*$/\.0/ ;
	return int $info ;
} # end of get_lineno

sub DoGoto {
	my ($self, $entry) = @_ ;

	my $txt = $entry->can('Subwidget') ?
	$entry->Subwidget('entry')->get() :
	$entry->get();
	$txt =~ s/(\d*).*/$1/ ; # take the first blob of digits
	if( $txt eq "" ) {
		DB::trace("$entry , invalid text range") ;
		return if $txt eq "" ;
	}
	$self->{'text'}->see("$txt.0") ;
	$entry->selectionRange(0, 'end') if $entry->can('selectionRange')
} # end of DoGoto

sub GotoLine {
	my ($self) = @_ ;
	my ($topLevel) ;

	if( Tk::Exists($self->{'goto_window'}) ) {
		$self->{'goto_window'}->raise() ;
		$self->{'goto_text'}->focus() ;
		return ;
	}
	my $okaySub = sub {  $self->saveInputIntoGotoHistory($self->{'goto_text'}) ;$self->DoGoto($self->{'goto_text'}) } ;
	$topLevel = $self->{'main_window'}->Toplevel(-title => "ptkdb - Goto Line", -overanchor => 'cursor') ;
	$self->{'goto_text'} = $topLevel->BrowseEntry(-bg, '#ffffff')->pack(-side => 'top', -fill => 'both', -expand => 1, -padx => 20, -pady => 20) ;
	for (@{$self->{'gotoHistory'}}) {
		$self->{'goto_text'}->Subwidget('slistbox')->insert('end',$_);
	}
	$self->{'goto_text'}->bind('<Return>', $okaySub) ; # make a CR do the same thing as pressing an OK
	$self->{'goto_text'}->focus() ;
	# TODO: Bind a double click on the mouse button to the same action
	# as pressing the OK button

	$topLevel->Button( -text => "OK",
		-command => $okaySub,
		-bg => 'white',
		@Devel::ptkdb::button_font
		)->pack(-side => 'left', -fill => 'both', -expand => 1) ;

	my $dismissSub = sub {
		delete $self->{'goto_text'} ;
		destroy {$self->{'goto_window'}} ;
		delete $self->{'goto_window'} ; # remove the entry from our hash so we won't
		} ;

	$topLevel->Button( -text => "Cancel",
		-bg => 'white',
		-command => $dismissSub ,
		@Devel::ptkdb::button_font )->pack(-side => 'left', -fill => 'both', -expand => 1) ;
	$topLevel->protocol('WM_DELETE_WINDOW', $dismissSub ) ;
	$self->{'goto_window'} = $topLevel ;
} # end of GotoLine

sub FindSearch {
	my ($self, $entry, $btn, $regExp,$exact) = @_ ;
	my (@switches, $result) ;
	$exact = $self->{'searchExact'} unless defined $exact;
	my $txt = $entry->can('Subwidget') ?
	$entry->Subwidget('entry')->get() :
	$entry->get();
	return if $txt eq "" ;
	push @switches, "-forward" if $self->{'fwdOrBack'}  ;
	push @switches, "-backward" unless $self->{'fwdOrBack'} ;
	push @switches, $exact ? "-exact" : '-nocase' ;
	if( $regExp ) {
		push @switches, "-regexp" ;
	} else {
		# push @switches, "-nocase" ; # if we're not doing regex we may as well do caseless search
	}
	$result = $self->{'text'}->search(@switches, $txt, $self->{'search_start'}) ;
	# untag the previously found text
	$self->{'text'}->tagRemove('search_tag', @{$self->{'search_tag'}}) if defined $self->{'search_tag'} ;
	if( !$result || $result eq "" ) {
		# No Text was found
		$btn->flash() ;
		$btn->bell() ;
		delete $self->{'search_tag'} ;
		$self->{'search_start'} = "0.0" ;
	} else { # text found
		$self->{'text'}->see($result) ;
		# set the insertion of the text as well
		$self->{'text'}->markSet('insert' => $result) ;
		my $len = length $txt ;
		if( $self->{'fwdOrBack'} ) {
			$self->{'search_start'}  = "$result +$len chars"  ;
			$self->{'search_tag'} = [ $result, $self->{'search_start'} ]  ;
		} else {
			# backwards search
			$self->{'search_start'}  = "$result -$len chars"  ;
			$self->{'search_tag'} = [ $result, "$result +$len chars"  ]  ;
		}
		# tag the newly found text
		$self->{'text'}->tagAdd('search_tag', @{$self->{'search_tag'}}) ;
	} # end of text found
	$entry->selectionRange(0, 'end') if $entry->can('selectionRange') ;
} # end of FindSearch

sub FindText { # Support for the Find Text... Menu command
	my ($self) = @_ ;
	my ($top, $entry, $rad1, $rad2, $chk, $frm, $okayBtn, $case) ;

	#
	# if we already have the Find Text Window
	# open don't bother openning another, bring
	# the existing one to the front.
	#
	if( $self->{'find_window'} ) {
		$self->{'find_window'}->raise() ;
		$self->{'find_text'}->focus() ;
		return ;
	}
	$self->{'search_start'} = $self->{'text'}->index('insert') if( $self->{'search_start'} eq "" ) ;

	my $okSub = sub {
		$self->saveInputIntoSearchHistory($self->{'find_text'});
		$self->FindSearch($self->{'find_text'}, $okayBtn, $self->{'searchRegexp'}) ;
		};
	my $dismissSub = sub {
		$self->{'text'}->tagRemove('search_tag', @{$self->{'search_tag'}}) if defined $self->{'search_tag'} ;
		$self->{'search_start'} = "" ;
		destroy {$self->{'find_window'}} ;
		delete $self->{'search_tag'} ;
		delete $self->{'find_window'} ;
		} ;

	$top = $self->{'main_window'}->Toplevel(-title => "ptkdb - Find Text") ;
	$self->{'find_text'} = $top->BrowseEntry(-label, 'Text', -bg,'#ffffff', -labelPack , [-side=>'left',-anchor=>'n'])->pack(-side => 'top', -fill => 'both', -expand => 1,-padx, 20, -pady , 20) ;
	for (@{$self->{'searchHistory'}}) {
		$self->{'find_text'}->Subwidget('slistbox')->insert('end',$_);
	}
	$frm = $top->Frame()->pack(-side => 'top', -fill => 'both', -expand => 1) ;
	$self->{'fwdOrBack'} = 1 unless exists $self->{'fwdOrBack'};
	$rad1 = $frm->Radiobutton(-text => "Forward", -value => 1, -variable => \$self->{'fwdOrBack'}) ;
	$rad1->pack(-side => 'left', -fill => 'both', -expand => 1) ;
	$rad2 = $frm->Radiobutton(-text => "Backward", -value => 0, -variable => \$self->{'fwdOrBack'}) ;
	$rad2->pack(-side => 'left', -fill => 'both', -expand => 1) ;
	$self->{'searchExact'} = 0  unless exists $self->{'searchExact'};
	$case = $frm->Checkbutton(-text => "Exact", -variable => \$self->{'searchExact'}) ;
	$case->pack(-side => 'left', -fill => 'both', -expand => 1) ;
	$self->{'searchRegexp'} = 0 unless exists $self->{'searchRegexp'};
	$chk = $frm->Checkbutton(-text => "RegExp", -variable => \$self->{'searchRegexp'}) ;
	$chk->pack(-side => 'left', -fill => 'both', -expand => 1) ;
	# TODO Bind a double click on the mouse button to the same action
	# as pressing the OK button
	$okayBtn = $top->Button( -text => "OK", -command => $okSub,
		@Devel::ptkdb::button_font,
		)->pack(-side => 'left', -fill => 'both', -expand => 1) ;
	$self->{'find_text'}->bind('<Return>', $okSub) ;
	$top->Button( -text => "Cancel",
		-command => $dismissSub,
		@Devel::ptkdb::button_font)->pack(-side => 'left', -fill => 'both', -expand => 1) ;

	$top->protocol('WM_DELETE_WINDOW', $dismissSub) ;

	$self->{'find_text'}->focus() ;
	$self->{'find_window'} = $top ;
} # end of FindText

sub dlg_getEventMask {
	my ($self) = shift;
	my $hwnd = shift;
	my (%args) = @_;
	my $rv;
	my $allEvents = '';
	my $windowEvent = '';
	my $fileEvent = '';
	my $timerEvent = '';
	my $idleEvent = '';
	my $dontWait = '';
	$allEvents = 'all' if ($args{-eventMask} =~ /all/);
	$windowEvent = 'window'  if ($args{-eventMask} =~ /window/);
	$fileEvent = 'file' if ($args{-eventMask} =~ /file/);
	$timerEvent = 'timer' if ($args{-eventMask} =~ /timer/);
	$idleEvent = 'idle' if ($args{-eventMask} =~ /idle/);
	$dontWait = 'dont_wait' if ($args{-eventMask} =~ /dont_wait/);

	my $mw = $hwnd->DialogBox(
		-title=> 'ptkdb - Enter event mask',
		-buttons=> ['OK','Cancel']);
	$mw->protocol('WM_DELETE_WINDOW',sub{1});
	my $wr_001 = $mw -> Frame ( -borderwidth , 1 , -relief , 'sunken'  ) -> pack(-side=>'top', -anchor=>'nw', -pady=>5, -fill=>'x', -expand=>1, -padx=>5);
	my $wr_002 = $mw -> Frame ( -borderwidth , 1 , -relief , 'sunken'  ) -> pack(-side=>'top', -anchor=>'nw', -pady=>5, -fill=>'x', -expand=>1, -padx=>5);
	my $wr_005 = $wr_001 -> Checkbutton ( -relief , 'flat' , -variable , \$allEvents , -anchor , 'nw' , -offvalue , ' ' , -justify , 'left' , -text , 'ALL_EVENTS' , -onvalue , 'all'  ) -> pack(-side=>'top', -anchor=>'nw', -fill=>'x', -expand=>1);
	my $wr_006 = $wr_002 -> Checkbutton ( -relief , 'flat' , -variable , \$windowEvent , -anchor , 'nw' , -offvalue , ' ' , -justify , 'left' , -text , 'WINDOW_EVENT' , -onvalue , 'window'  ) -> pack(-side=>'top', -anchor=>'nw', -fill=>'x', -expand=>1);
	my $wr_007 = $wr_002 -> Checkbutton ( -relief , 'flat' , -variable , \$fileEvent , -anchor , 'nw' , -offvalue , ' ' , -justify , 'left' , -text , 'FILE_EVENT' , -onvalue , 'file'  ) -> pack(-side=>'top', -anchor=>'nw', -fill=>'x', -expand=>1);
	my $wr_009 = $wr_002 -> Checkbutton ( -relief , 'flat' , -variable , \$timerEvent , -anchor , 'nw' , -offvalue , ' ' , -justify , 'left' , -text , 'TIMER_EVENT' , -onvalue , 'timer'  ) -> pack(-side=>'top', -anchor=>'nw', -fill=>'x', -expand=>1);
	my $wr_011 = $wr_002 -> Checkbutton ( -relief , 'flat' , -variable , \$idleEvent , -anchor , 'nw' , -offvalue , ' ' , -justify , 'left' , -text , 'IDLE_EVENT' , -onvalue , 'idle'  ) -> pack(-side=>'top', -anchor=>'nw', -fill=>'x', -expand=>1);
	my $wr_013 = $wr_002 -> Checkbutton ( -relief , 'flat' , -variable , \$dontWait , -anchor , 'nw' , -offvalue , ' ' , -justify , 'left' , -text , 'DONT_WAIT' , -onvalue , 'dont_wait'  ) -> pack(-side=>'top', -anchor=>'nw', -fill=>'x', -expand=>1);

	$rv =  $mw->Show();
	if ($rv =~/ok/i) {
		if ($allEvents =~ /all/i) {
			$rv = "$allEvents"
		} else {
			$rv = "$windowEvent $fileEvent $timerEvent $idleEvent $dontWait"
		}
	} else { $rv = undef}
		$rv =~s /\s+/ /g;
		return $rv;
} ## end of dlg_getEventMask

sub _eventMask {
	my ($self) = shift;
	my $rv = 0;
	##  event types : qw (all window file timer idle dont_wait);
	my $events = 'all';		## default
	$events = $self->{'eventMask'};	## OK, worked fine  timer stops at breakpoint, but it restart as soon as actions occur

	if ($events =~ /all/i) {
		$rv = ALL_EVENTS;
	} else {
		$rv |= WINDOW_EVENTS if ($events =~ /window/i);
		$rv |= FILE_EVENTS   if ($events =~ /file/i);
		$rv |= TIMER_EVENTS  if ($events =~ /timer/i);
		$rv |= IDLE_EVENTS   if ($events =~ /idle/i);
		$rv |= DONT_WAIT     if ($events =~ /dont_wait/i);
	}
	DB::trace(" _eventMask uses '$events' and sets '$rv'");
	return $rv;
}

sub main_loop {
	my $self = shift ;
	my $evt ;
	my $autostepId;
	my $cancel_autostepId = sub {1};
	# my $i = 0;
	my $eventMask = $self->_eventMask();

	$DB::window->setStatus2('ready');	#

	if ($DB::autostep && $DB::autostep_delay_time > 0) {
		$autostepId = $DB::window->{'main_window'}->after($DB::autostep_delay_time,sub {$self->{'event'} = 'autostep'});
		$cancel_autostepId = sub {
				$DB::window->{'main_window'}->afterCancel($autostepId) if defined ($autostepId);
		}
	} else {
	}

	SWITCH: for ($self->{'event'} = 'null' ; ; $self->{'event'} = undef ) {
		Tk::DoOneEvent($eventMask) if (Tk::MainWindow->Count); ##
		next unless $self->{'event'} ;

		$evt = $self->{'event'} ;
		$evt eq 'autostep' && do { &$cancel_autostepId();last SWITCH if ($DB::autostep); } ;
		$evt eq 'autostep' && do { next SWITCH } ;

		$evt eq 'step'     && do { &$cancel_autostepId();last SWITCH ; } ;
		$evt eq 'null'     && do { next SWITCH ; } ;
		$evt eq 'run'      && do { &$cancel_autostepId();last SWITCH ; } ;
		$evt eq 'quit'     && do { &$cancel_autostepId();$DB::autostep = 0;$self->DoQuit ; } ;
		$evt eq 'expr'     && do { &$cancel_autostepId();return $evt ; } ; # adds an expression to our expression window
		$evt eq 'qexpr'    && do { &$cancel_autostepId();$DB::autostep = 0;return $evt ; } ; # does a 'quick' expression
		$evt eq 'update'   && do { &$cancel_autostepId();return $evt ; } ; # forces an update on our expression window
		$evt eq 'reeval'   && do { &$cancel_autostepId();$DB::autostep = 0;return $evt ; } ; # updated the open expression eval window
		$evt eq 'balloon_eval' && do { &$cancel_autostepId();return $evt } ;
	} # end of switch block

	if ($evt eq 'run' && $DB::step_over_depth == -1) {
		$self->{'main_window'}->iconify() if ($Devel::ptkdb::iconify && defined $self->{'main_window'} && Tk::Exists($self->{'main_window'}));
		$DB::window->setStatus2('running');	#
	} elsif ($evt eq 'step') {
		$DB::window->setStatus2('stepping');	#
	} elsif ($evt eq 'autostep') {
		if($DB::window->{'lastevent'} eq 'stepin') {
			$DB::window->setStatus2('autostep in');	#
			$DB::step_over_depth = -1 ; ## simulate step in
			$DB::single = 1 ;
			$self->{'event'} = $evt = 'step';
		} elsif ($DB::window->{'lastevent'} eq 'stepover') {
			$DB::window->setStatus2('autostep over');	#
			&DB::SetStepOverBreakPoint(0) ;
			$DB::single = 1 ;
			$DB::window->{'event'} = $evt = 'step' ;
		} else {
			DB::log("Unexpected lastevent ".$DB::window->{'lastevent'}." ignored");
		}
	} else {}
	return $evt ;
} # end of main_loop

sub goto_sub_from_stack {
	my $self = shift;
	my ($f, $lineno) = @_ ;
	$self->set_file($f, $lineno) ;
} # end of goto_sub_from_stack ;

sub refresh_stack_menu {
	my $self = shift ;
	my ($str, $name, $i, $sub_offset, $subStack) ;

	#
	# CAUTION:  In the effort to 'rationalize' the code
	# are moving some of this function down from DB::DB
	# to here.  $sub_offset represents how far 'down'
	# we are from DB::DB.  The $DB::subroutine_depth is
	# tracked in such a way that while we are 'in' the debugger
	# it will not be incremented, and thus represents the stack depth
	# of the target program.
	#
	$sub_offset = 1 ; ## one down from DB::DB
	$subStack = [] ;

	return unless defined $self->{'stack_menu'};
	# clear existing entries

	for( $i = $sub_offset ; 1 ; $i++ ) {
		my($package, $filename, $line, $subName) = CORE::caller($i) ;
		last if !$subName ;
		push @$subStack, { '++name' => $subName, 'pck' => $package, 'filename' => $filename, 'line' => $line } ;
	}

	$self->{'stack_menu'}->menu->delete(0, 'last') ; # delete existing menu items

	for( $i = 0 ; $subStack->[$i] ; $i++ ) {

		$str = defined $subStack->[$i+1] ? "$subStack->[$i+1]->{'++name'}" : "MAIN" ;
		my $state = ($str =~/_ANON_/) ? 'disabled' : 'active';
		my ($f, $line) = ($subStack->[$i]->{'filename'}, $subStack->[$i]->{'line'}) ; # make copies of the values for use in 'sub'
		$str .= " [$f:$line]" unless($str =~ /\[$f\:$line\]/);
		$self->{'stack_menu'}->command(
				-label , $str,
				-command , sub { $self->goto_sub_from_stack($f, $line) ; },
				-state ,$state
				)
	}

} # end of refresh_stack_menu


no strict ;

sub get_state {
	my ($self, $fname) = @_ ;
	my ($val) ;
	DB::trace("get_state $fname");
	local ($files, $expr_list, $eval_saved_text, $main_win_geometry,$dirtyFlag,$stop_on_restart,$param,$decorate_code) ;

	do "$fname"  ;

	if( $@ ) {
		$self->DoAlert($@) ;
		return ( undef ) x 4 ; # return a list of 4 undefined values
	}
	return ($files, $expr_list, $eval_saved_text, $main_win_geometry,$dirtyFlag,$stop_on_restart,$param,$decorate_code) ;
} # end of get_state

use strict ;

sub restoreStateFile {
	my $self = shift ;
	my ($fname) = @_ ;
	local(*F) ;
	my ($saveCurFile, $s, @n, $n) ;
	DB::trace("restoreStateFile $fname");
	if (!(-e $fname && -r $fname)) {
		$self->DoAlert("$fname does not exist") ;
		return ;
	}
	my ($files, $expr_list, $eval_saved_text, $main_win_geometry,$dirtyFlag,$stop_on_restart,$param,$decorate_code) = $self->get_state($fname) ;
	my ($f, $brks) ;
	$self->{'dirtyFlag'} = $dirtyFlag;
	$Devel::ptkdb::decorate_code = $decorate_code;
	$self->setStatus1();
	$DB::ptkdb::stop_on_restart = $stop_on_restart;
	$param = 'ptkdbFilter'->defaultParam unless(defined($param));
	'ptkdbFilter'->setParam($param);
	$DB::window->setStatus0();

	return unless defined $files || defined $expr_list ;

	&DB::restore_breakpoints_from_save($files) ;
	#
	# This should force the breakpoints to be restored
	#
	$saveCurFile = $self->{'current_file'} ;
	$self->{'files'} = $files if defined $files ;	## save for delayed requires

	@$self{ 'current_file', 'expr_list', 'eval_saved_text' } =
		  ( ""             , $expr_list,  $eval_saved_text) ;

	$self->set_file($saveCurFile, $self->{'current_line'}) ;

	$self->{'event'} = 'update' ;

	if ( $main_win_geometry && $self->{'main_window'} ) {
		$main_win_geometry = "800x600" if ($main_win_geometry =~ /1x1/);
		# restore the height and width of the window
		$self->{'main_window'}->geometry( $main_win_geometry ) ;
	}
	DB::trace("restoreStateFile done");
} # end of restoreStateFile

sub refreshEvalWindowResults {
	my $self = shift ;
	my (@result) = @_ ;
	my ($leng, $str, $d) ;

	return unless Tk::Exists($self->{'eval_results'});

	$leng = 0 ;
	for( @result ) {
		if( $self->{'hexdump_evals'} ) {
			# eventually put hex dumper code in here
			$self->{'eval_results'}->insert('end', ptkdbTools->hexDump($_)) ;
		} elsif( !$Devel::ptkdb::DataDumperAvailable || !$Devel::ptkdb::useDataDumperForEval ) {
			$str = "$_\n" ;
		} else {
			$d = Data::Dumper->new([ $_ ]) ;
			$d->Indent($Devel::ptkdb::eval_dump_indent) ;
			$d->Terse(1) ;
			if( Data::Dumper->can('Dumpxs') ) {
				$str = $d->Dumpxs( $_ ) ;
			} else {
				$str = $d->Dump( $_ ) ;
			}
		}
		$leng += length $str ;
		$self->{'eval_results'}->insert('end', $str) ;
	}
} # end of refreshEvalWindowResults


sub setupEvalWindow {
	my $self = shift ;
	my($top) ;
	my $eval = sub { $DB::window->{'event'} = 'reeval' ; };
	my $clearResult = sub { $self->{'eval_results'}->delete('0.0', 'end')};
	my $clearEval = sub { $self->{'eval_text'}->delete('0.0', 'end') };
	my $switchHex = sub{&$clearResult();&$eval()};
	my $dismissSub = sub {
		$self->{'eval_saved_text'} = $self->{'eval_text'}->get('0.0', 'end') ;
		$self->{'eval_window'}->destroy ;
		delete $self->{'eval_window'} ;
		} ;

	$self->{'eval_window'}->deiconify(),$self->{'eval_text'}->focus(),return if exists $self->{'eval_window'} ; # already running this window?

	$top = $self->{'main_window'}->Toplevel(-title => "ptkdb - Evaluate Expressions...") ;
	$self->{'eval_window'} = $top ;
	my $f = $top->Frame()->pack(-side=>'top', -anchor=>'nw', -fill=>'both', -expand=>1);
	$self->{'eval_text'} = $f->Scrolled('TextUndo',
		@Devel::ptkdb::scrollbar_cfg,
		-font, 'evalTextFont',		## @Devel::ptkdb::eval_text_font,
		-width => 50,
		-height => 3,
		-wrap => "none",
		)-> pack(-anchor=>'nw', -side=>'top', -fill=>'both', -expand=>1);
	$self->{'eval_location'} = $f->Label(-text,'Results :',-justify , 'left',-anchor, 'w')->pack(-side,'top',-fill,'x',-expand, 1);
	$f->packAdjust(-side => 'top', -fill => 'both', -expand => 1) ;

	$self->{'eval_text'}->insert('end', $self->{'eval_saved_text'}) if exists $self->{'eval_saved_text'} && defined $self->{'eval_saved_text'} && $self->{'eval_saved_text'} !~ /^\s*$/;

	## $top->Label(-text, "Results:",-justify , 'left',-anchor, 'w')->pack(-side => 'top', -fill => 'both', -expand => 'n') ;

	$self->{'eval_results'} = $top->Scrolled('ROText',
		@Devel::ptkdb::scrollbar_cfg,
		-width => 50,
		-height => 17,
		-wrap => "none",
		-font, 'evalTextFont',		## @Devel::ptkdb::eval_text_font
		)->pack(-anchor=>'nw', -side => 'top', -fill => 'both', -expand => 1) ;

	my $btn = $top->Button(-text => 'Eval...', -command => $eval)->pack(-side => 'left', -fill => 'x', -expand => 1) ;


	$top->protocol('WM_DELETE_WINDOW', $dismissSub ) ;

	$top->Button(-text => 'Clear Eval', -command => $clearEval
		)->pack(-side => 'left', -fill => 'x', -expand => 1) ;
	$top->Button(-text => 'Clear Results', -command => $clearResult
		)->pack(-side => 'left', -fill => 'x', -expand => 1) ;
	$top->Button(-text => 'Cancel', -command => $dismissSub)->pack(-side => 'left', -fill => 'x', -expand => 1) ;
	$top->Checkbutton(-text => 'Hex', -variable => \$self->{'hexdump_evals'}, -command ,$switchHex)->pack(-side => 'right', -fill => 'x', -expand => 1) ;
		$top->Button(-text => 'Zoom-', -command => [\&Devel::ptkdb::decFontSizeX,$self])->pack(-side => 'right', -anchor=>'se');
	$top->Button(-text => 'Zoom+', -command =>  [\&Devel::ptkdb::incFontSizeX,$self])->pack(-side => 'right', -anchor=>'se');

	$self->{'eval_text'}->focus();
} # end of setupEvalWindow ;


sub filterBreakPts {
	my ($breakPtsListRef, $fname) = @_ ;
	my $dbline = $main::{'_<' . $fname}; # breakable lines
	local($^W) = 0 ;
	#
	# Go through the list of breaks and take out any that
	# are no longer breakable
	#

	for( @$breakPtsListRef ) {
		next unless defined $_ ;
		next if $dbline->[$_->{'line'}] != 0 ; # still breakable
		$_ = undef ;
	}
} # end of filterBreakPts

sub DoAbout {
	my $self = $DB::window ;
	my $str = "ptkdb $DB::VERSION\nCopyright 2010,2011 by Marco Marazzi\nCopyright 2007 by Svetoslav Marinov\nCopyright 1998,2006 by Andrew E. Page\nFeedback to mmarazzi\@users.sourceforge.net\n\n" ;
	my $threadString = "" ;

	$threadString = "Threads Available" if $Config::Config{'usethreads'} ;
	$threadString = " Thread Debugging Enabled" if $DB::usethreads ;

$str .= <<"__STR__" ;
This program is free software; you can redistribute it and/or modify
it under the terms of either:

a) the GNU General Public License as published by the Free
Software Foundation; either version 1, or (at your option) any
later version, or

b) the "Artistic License" which comes with this Kit.

This program is distributed in the hope that it will be useful,
but WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See either
the GNU General Public License or the Artistic License for more details.

OS $^O
Tk Version $Tk::VERSION
Perl Version $]
Data::Dumper Version $Data::Dumper::VERSION
$threadString
__STR__

	$self->DoAlert($str, "About ptkdb") ;
} # end of DoAbout

#
# return 1 if succesfully set,
# return 0 if otherwise
#
sub SetBreakPoint {
	my $self = shift;
	my ($isTemp) = @_ ;
	my $rv;
	my $lineno = $self->get_lineno() ;
	my $expr;
	local($^W) = 0 ;

	if (&DB::checkdbline($self->{'current_file'}, $lineno + $self->{'line_offset'}) ) {
		if( $isTemp ) {
			$self->insertTempBreakpoint($self->{'current_file'}, $lineno) ;
			$rv = 1 ;
		} else {
			$expr = $self->clear_entry_text() ; ## 12.11.2014/mm
			$self->insertBreakpoint($self->{'current_file'}, $lineno, 1, $expr) ;
			$rv = 1 ;
		}
	} else {
		$self->DoAlert("line $lineno in $self->{'current_file'} is not breakable") ;
		$rv = 0
	}
	return $rv ;
} # end of SetBreakPoint

sub UnsetBreakPoint {
	my $self = shift ;
	my $lineno = $self->get_lineno() ;

	$self->removeBreakpoint($DB::window->{'current_file'}, $lineno) ;
	$self->{'dirtyFlag'} = 1;
	$self->setStatus1();
} # end of UnsetBreakPoint

sub attach_balloon {
	my $self = shift;
	my ($txt) = @_;
	$self = $DB::window unless defined $self;
	return unless (defined $self);
	$txt = $self->{'text'} unless defined $txt;
	$self->{'expr_balloon'}->attach($txt, -initwait => $Devel::ptkdb::balloon_time,
		-msg => \$self->{'expr_balloon_msg'},
		-balloonposition => 'mouse',
		-postcommand => \&Devel::ptkdb::balloon_post,
		-motioncommand => \&Devel::ptkdb::balloon_motion ) ;
}

sub detach_balloon {
	my $self = shift;
	$self = $DB::window unless defined $self;
	my ($txt) = @_;
	$txt = $self->{'text'} unless defined $txt;
	$self->{'expr_balloon'}->detach($txt);
}

sub switch_balloon {
	my $self = shift;
	$self = $DB::window unless defined $self;
	if ($Devel::ptkdb::balloon) {
		$self->attach_balloon();
	} else {
		$self->detach_balloon();
	}
}

sub balloon_post {
	my $self = $DB::window ;
	my $txt = $DB::window->{'text'} ;
	return 0 if ($self->{'expr_balloon_msg'} eq "") || ($self->{'balloon_expr'} eq "") ; # don't post for an empty string
	return $self->{'balloon_coord'} ;
}

sub balloon_motion {
	my ($txt, $x, $y) = @_ ;
	my $self = $DB::window ;

	my ($offset_x, $offset_y) = ($x + 4, $y + 4) ;
	my $txt2 = $self->{'text'} ;
	my $data ;

	return 0 unless( $DB::on);	## work only during debugger is active

	$self->{'balloon_coord'} = "$offset_x,$offset_y" ;

	#$x -= $txt->rootx ;
	#$y -= $txt->rooty ;
	#
	# Post an event that will cause us to put up a popup
	#

	if( $txt2->tagRanges('sel') ) { # check to see if 'sel' tag exists (return undef value)
		$data = $txt2->get("sel.first", "sel.last") ; # get the text between the 'first' and 'last' point of the sel (selection) tag
		$data = $self->isolateVariable($data);  ## new
	} else {
		$x -= $txt->rootx ;
		$y -= $txt->rooty ;
		$data = $self->retrieve_text_expr($x, $y) ;
	}

	if( !$data ) {
		$self->{'balloon_expr'} = "" ;
		return 0 ;
	}

	return 0 if ($data eq $self->{'balloon_expr'}) ; # nevermind if it's the same expression

	$self->{'event'} = 'balloon_eval' ;
	$self->{'balloon_expr'} = $data ;

	return 1 ; # balloon will be canceled and a new one put up(maybe)
} # end of balloon_motion

sub isolateVariable {
	my $self = shift;
	my ($data,$col) = @_;
	my $rv;
	$col = length $data unless defined $col;
	# if we're sitting over white space, leave
	my $len = length($data) ;

	return undef unless($data && $col && $len > 0) ;

	return undef if(substr($data, $col, 1) =~ /\s/) ;

	# walk backwards till we find some whitespace

	$col = $len if $len < $col ;
	while( --$col >= 0 ) {
		## last if  substr($data, $col, 1) =~ /[\s\$\@\%]/ ;
		last if  substr($data, $col, 1) =~ /[\$\@\%]/ ;
	}
	$rv = $1 if (substr($data, $col) =~ /^([\$\@\%][a-z0-9_]+(::[a-zA-Z0-9_]+)*((\s*\[\s*[^\]]+\s*\])|(\s*{\s*[^}]+\s*})|(\s*->\s*\[\s*[^\]]+\s*\])|(\s*->\s*{\s*[^}]+\s*}))*|([$][#][a-z0-9_]+(::[a-zA-Z0-9_]+)*))/i) ;
	$rv = "'expr!'" if(defined $rv && $rv =~ /\[[^+^\-]*(--|\+\+)[^\]]*\]/);
	$rv = "'expr!'" if(defined $rv && $rv =~ /\{[^+^\-]*(--|\+\+)[^\}]*\}/);
	return $rv ;
}

sub retrieve_text_expr {
	my $self = shift;
	my($x, $y) = @_ ;
	my $rv = 0;
	my $txt = $self->{'text'} ;

	my $coord = "\@$x,$y" ;

	my($idx, $col, $data, $offset) ;

	($col, $idx) = line_number_from_coord($txt, $coord) ;
	$offset = $Devel::ptkdb::linenumber_length + 1 ; # line number text + 1 space

	return undef if $col < $offset ; # no posting

	$col -= $offset ;
	local(*dbline) = $main::{'_<' . $self->{'current_file'}} ;
	$idx += $dbline[1] =~ /use\s+.*Devel::_?ptkdb/ ? 1 : 0 ;	## OK
	return undef if( !defined $dbline[$idx] || $dbline[$idx] == 0 ) ; # no executable text, no real variable(?)

	$data = $dbline[$idx] ;
	$rv =  $self->isolateVariable($data,$col);
	return $rv ;
}

#
# after DB::eval get's us a result
#
sub code_motion_eval {
	my $self = shift;
	my (@result) = @_ ;
	my $str ;

	if( exists $self->{'balloon_dumper'} ) {
		my $d = $self->{'balloon_dumper'} ;
		$d->Reset() ;
		$d->Values( [ $#result == 0 ? @result : \@result ] ) ;
		if( $d->can('Dumpxs') ) {
			$str = $d->Dumpxs() ;
		} else {
			$str = $d->Dump() ;
		}
		chomp($str) ;
		$str = ptkdbTools->toHex($str) if ($str =~/[\x00-\x06\x14\x1f]/);
	} else {
		$str = "@result" ;
	}

	# Cut the string down to DB::balloon_msg_max_length characters

	if (length($str) > $DB::balloon_msg_max_length) {
		$self->{'expr_balloon_msg'} = "$self->{'balloon_expr'} = " . substr($str, 0, $DB::balloon_msg_max_length) . "\n...data partly shown!";
	} else {
		$self->{'expr_balloon_msg'} = "$self->{'balloon_expr'} = " . $str;
	}
} # end of code_motion_eval

sub EnterSession {
	my $self = shift;
	return DB::evalActionsList('user_window_init_list');
}

sub LeaveSession {
	my $self = shift;
	return DB::evalActionsList('user_window_end_list');
}
#
# Subroutine called when we enter DB::DB() .
# In other words when the target script 'stops'
# in the Debugger
#
sub EnterActions {
	my $self = shift;
	my ($package,$filename,$line) = @_ ;

	DB::trace("EnterActions $package,$filename,$line");
	DB::print_dbline($filename) if (DB::debug);
	#	$self->{'main_window'}->Unbusy() ;
	return 1
} # end of EnterActions

#
# Subroutine called when we return from DB::DB()
# and the target script resumes.
#
sub LeaveActions {
	my $self  = shift ;
	my ($package,$filename,$line) = @_;
	DB::trace("LeaveActions $package,$filename,$line");
	#	$self->{'main_window'}->Busy() ;
	return 1
} # end of LeaveActions

sub BEGIN {
	$Devel::ptkdb::scriptName = $0 ;
	@Devel::ptkdb::script_args = @ARGV ; # copy args
}


sub DoRestart { # Save the ptkdb state file and restart the debugging session
	my($fname) ;
	my $moduleName = 'ptkdb';

	$fname = $ENV{'TMP'} || $ENV{'TMPDIR'} || $ENV{'TMP_DIR'} || $ENV{'TEMP'} || $ENV{'HOME'} ;
	$fname .= '/' if ($fname) ;
	$fname = "" unless($fname) ;
	if ($DB::ptkdb::stop_on_restart) {
		$DB::window->setStatus2('restarting');	#
		my $ans = $DB::window->doAlert_Modal("Some resources of the test environment has been possibly changed during the debugging session.\nIf it is so, then restore them now manually before you restart the session.\n\nPress 'Ok' to restart or press 'cancel' to continue the current session.",
			"Restart",
			sub {'ptkdb_arglistEditor'->ok()},
			sub {'ptkdb_arglistEditor'->cancel()}
			);
		unless ($ans){
			$DB::window->setStatus2('ready');	#
			return(0);
		} else {
			@Devel::ptkdb::script_args = ptkdb_arglistEditor::getArglist() if (ptkdb_arglistEditor::getResult());
		}
	} # else {}
	if ($fname =~ /^\s*$/) {
		$fname = $DB::CALLERCW."/ptkdb_restart_state$$" ;
	} else {
		$fname .= "ptkdb_restart_state$$" ;
	}
	'ptkdbFilter'->param->{'state'} = 0; ## set filter off
	DB::trace("Saving temp state file '$fname'") ;
	&DB::save_state_file($fname) ;
	$ENV{'PTKDB_RESTART_STATE_FILE'} = $fname ;

	chdir $DB::CALLERCW;
	if (@{$DB::window->{'user_restart_list'}}) {	## call user's restart entry
		for my $entry (@{$DB::window->{'user_restart_list'}}) {
			if (ref($entry) eq 'CODE') {
				&$entry((\@Devel::ptkdb::script_args)); ## temp patch 25.01.2012  , pass arguments (main window, options, ...
			} elsif (ref($entry) =~ /^\s*$/) {
				eval $entry . '(\\@Devel::ptkdb::script_args)';
			} else {
				DB::log("Unexpected type of restart entry item, item discarded ") ;
			}
		}
	}
	my @qq = map{ ptkdbTools->qq($_)} @Devel::ptkdb::script_args; # build up the command to do the restart
	$fname = "perl -w -d:$moduleName $Devel::ptkdb::scriptName @qq" ;
	DB::trace("Pid $$ is doing a restart with '$fname'") ;

	exec $fname ;

} # end of DoRestart

##
## Enables/Disables the feature where we stop
## if we've encountered a Perl warning such as:
## "Use of uninitialized value at undef_warn.pl line N"
##

sub stop_on_warning_cb {
	&$DB::ptkdb::warn_sig_save() if $DB::ptkdb::warn_sig_save ; # call any previously registered warning
	$DB::window->DoAlert(@_) ;
	$DB::single = 1 ; # forces debugger to stop next time
}

sub set_stop_on_warning {

	if( $DB::ptkdb::stop_on_warning ) {
		return if $DB::ptkdb::warn_sig_save == \&stop_on_warning_cb ; # prevents recursion
		$DB::ptkdb::warn_sig_save = $SIG{'__WARN__'} if $SIG{'__WARN__'} ;
		$SIG{'__WARN__'} = \&stop_on_warning_cb ;
	} else {
		##
		## Restore any previous warning signal
		##
		local($^W) = 0 ;
		$SIG{'__WARN__'} = $DB::ptkdb::warn_sig_save ;
	}
} # end of set_stop_on_warning

sub set_stop_on_restart { ## dummy
	return 1
}

sub switch_decorate_code {
	DB::trace("switch_decorate_code");
	my $text = $DB::window->{'text'};
	if ($Devel::ptkdb::decorate_code) {
		ptkdbTools->decorateReset($text);
	} else {
		ptkdbTools->decorateRemove($text);
	}
	$DB::window->{'text'}->see($DB::window->{'current_line'}.'.0 linestart') ;
	return 1
}

sub switch_trace_expressions {
	return 1
}

sub switch_trace_sub {
	return 1
}

sub switch_trace {
	if ($Devel::ptkdb::trace_active ) {
		$Devel::ptkdb::trace_array_size = $Devel::ptkdb::trace_array_size_saved
	} else {
		$Devel::ptkdb::trace_array_size_saved  =  $Devel::ptkdb::trace_array_size;
		$Devel::ptkdb::trace_array_size = 0;
		if (defined $DB::window->{'trace_window'}) {
			Devel::ptkdb::dlg_showTrace_init($DB::window->{'trace_window'})
		} else {
			@DB::traceArea =();
		}
	}
}

sub switch_Proximity_Window {
	if ($Devel::ptkdb::showProximityWindow) {
		my $h = $DB::window->{'data_list'}->cget(-height) - $DB::window->{'proximity_data_list'}->cget(-height);
		$h = 30 if ($h > 30);
		$DB::window->{'data_list'}->configure(-height,$h);
		$DB::window->{'data_list'}->packAdjust(-side,'top');
		$DB::window->{'proximity_data_list'}->pack(-side => 'top', -fill => 'both', -expand => 1);
		$DB::window->refreshProximityWindow();
	} else {
		$DB::window->deleteAllProximityExprs();
		my $h = $DB::window->{'proximity_data_list'}->cget(-height) + $DB::window->{'data_list'}->cget(-height);
		$h = 30 if ($h > 30);
		my $adj = $DB::window->locateAdjuster($DB::window->{'data_page'});
		if (defined($adj)) {
			$DB::window->{'proximity_data_list'}->packForget();
			$adj->packForget(0);
			$DB::window->{'data_list'}->configure(-height,$h);
			$DB::window->{'data_list'}->packPropagate(1);
			$DB::window->{'data_page'}->update();
		}  else {
			DB::trace("no Tk::Adjuster located."); ## discard and go on ...
		}
	}
}

sub switch_autostep {
	return 1
}

sub switch_allow_calls_in_expr_list {
	my $self = $DB::window;
	unless ($Devel::ptkdb::allow_calls_in_expr_list) {
		my $i =0;
		my @x;
		map {
			my $expr = $_->{'expr'};
			push @x,$i if 'ptkdbTools'->checkIfCall($expr);
			$i++;
		} @{$self->{'expr_list'}};
		map {
			splice @{$self->{'expr_list'}}, $_,1;
		} reverse sort @x;
			## TODO refresh widget 'data_list' see DB::updateExpr() and/or ptkdb::deleteExpr
	}
}

1 ; # end of Devel::ptkdb

package ptkdbScopeGuardx;
{

sub new {
	my $class = shift;
	my ($value) = @_;
	return bless \$value,$class
}
sub DESTROY {
	my $self = shift;
	my $depth = $$self;
	ptkdbScopeGuardx::restoreValues($depth) ; ## execute the handler
	undef $self
}
sub restoreValues  {
	my $saved_depth = shift;
	$DB::subroutine_depth = $saved_depth ;
	$DB::single = 1 if ($DB::step_over_depth >= $DB::subroutine_depth && !$DB::on)	;
}

1;
} ## end of ptkdbScopeGuardx

package DB ;

use vars qw($VERSION $header);

$VERSION = '1.234' ;
$header = "ptkdb.pm version $DB::VERSION";
$DB::window->{'current_file'} = "" ;
$DB::window->{'trace_window'} = undef;

sub print_dbline {
	my $filename = shift;
	no strict;
	local(*dbline) = $main::{'_<' . $filename} ;
	print "\n$dbline";
	print "\n";
	for my $i (0 .. $#dbline) {
		print sprintf "%04d",int($i);
		($dbline[$i] != 0) ? print 'b ' : print '  '; print $dbline[$i] ;
		last if ($i >= 9);
	}
	print "\nbreakpoints ";
	map	 {
		print "\n$_";
		my $brkpt = $dbline{"$_"};
		map {
			print "\n$_ " , $brkpt->{$_}
		} sort keys %$brkpt;
	} keys %dbline;
	use strict;
	print "\n";
}

sub updateEvalWindow {
	my ($filename,$package,$line,$subName) = @_;
	my $rv = 0;
	if (defined($DB::window->{'eval_text'}) && Tk::Exists ($DB::window->{'eval_text'})) {
		my $txt = $DB::window->{'eval_text'}->get('0.0', 'end') ;
		if ($txt =~/\S+/) {
			my @result = &DB::dbeval($package, $txt) ;
			$DB::window->{'eval_location'}->configure(-text,"Results ($package, $filename, $line, $subName) :");
			$DB::window->refreshEvalWindowResults(@result) ;
			$rv = 1;
		} ## else {} ## intentionally left empty
	} ## else {} ## intentionally left empty
	return $rv
}

#
# Here's the clue...
# eval only seems to eval the context of
# the executing script while in the DB
# package.  When we had updateExprs in the Devel::ptkdb
# package eval would turn up an undef result.
#

sub updateExprs {
	my ($package,$line) = @_ ;
	#
	# Update expressions
	#
	$DB::window->deleteAllExprs() ;
	my ($expr, @result);

	foreach $expr ( @{$DB::window->{'expr_list'}} ) {
		next if length $expr == 0 ;

		my @result = &DB::dbeval($package, $expr->{'expr'}) ;

		if(  @result == 1 ) {
			&DB::DoTrace('exprBP',-1,$package,$line,$expr->{'expr'},$result[0]) ; # trace watched expressions
			$DB::window->insertExpr([ $result[0] ], $DB::window->{'data_list'}, $result[0], $expr->{'expr'}, $expr->{'depth'}) ;
		} else {
			&DB::DoTrace('exprBP',-1,$package,$line,$expr->{'expr'},\@result) ; # trace watched expressions
			$DB::window->insertExpr([ \@result ], $DB::window->{'data_list'}, \@result, $expr->{'expr'}, $expr->{'depth'}) ;
		}
	}
	$DB::window->seeItemIfExisting($DB::window->{'data_list'},$Devel::ptkdb::savedPathForSee);
	$Devel::ptkdb::savedPathForSee = '';
} # end of updateExprs

sub updateProximity {
	my ($filename,$package,$line) = @_;

	DB::trace("updateProximity $filename $package $line");
	my $stmt = DB::getdbtextline($filename,$line);
	DB::trace("updateProximity, '$stmt'");
	my @vars = 'ptkdbTools'->parseStmt($stmt);
	$DB::window->{'proximity_expr_list'} = [];
	while(@vars) {
		my $x= shift(@vars);
		my $expr = ($x =~/^[\w:_]+/) ? "\\&$x" : $x; ## prevent call to sub , i.e. sprintf or even main::_map
		my @result = DB::dbeval($package,$expr);
		push @{$DB::window->{'proximity_expr_list'}}, [$x,\@result];
	}
	$DB::window->refreshProximityWindow() if ($Devel::ptkdb::showProximityWindow);
	return undef
}

sub updateExprAndProximity {
	my ($filename,$package,$line) = @_;
	updateExprs($package) ;
	updateProximity($filename,$package,$line); ## TODO update proximity window ## 20.02.2013/mm
}

no strict ; # turn strict off (shame shame) because we keep getting errors for the local(*dbline)

use Carp ;

sub checkdbline($$) { # returns true if line is breakable
	my ($fname, $lineno) = @_ ;

	return 0 unless $fname; # we're getting an undef here on 'Restart...'

	local($^W) = 0 ; # spares us warnings under -w
	local(*dbline) = $main::{'_<' . $fname} ;
	my $flag = $dbline[$lineno] != 0 ;
	return $flag;
} # end of checkdbline

#
# sets a breakpoint 'through' a magic
# variable that Perl is able to interpert
#
sub setdbline($$$) {
	my ($fname, $lineno, $value) = @_ ;
	local(*dbline) = $main::{'_<' . $fname};

	$dbline{$lineno} = $value ;
} # end of setdbline

sub getdbline($$) {
	my ($fname, $lineno) = @_ ;
	DB::trace("getdbline $fname $lineno");
	local(*dbline) = $main::{'_<' . $fname};
	return $dbline{$lineno} ;
} # end of getdbline

sub getdbtextline {
	my ($fname, $lineno) = @_ ;
	local(*dbline) = $main::{'_<' . $fname};
	return $dbline[$lineno] ;
} # end of getdbline


sub cleardbline($$;&) {
	my ($fname, $lineno, $clearsub) = @_ ;
	local(*dbline) = $main::{'_<' . $fname};
	my $value ; # just in case we want it for something

	$value = $dbline{$lineno} ;
	delete $dbline{$lineno} ;
	&$clearsub($value) if $value && $clearsub ;
	## $DB::window->{'dirtyFlag'} = 1;
	## $DB::window->setStatus1();
	return $value ;
} # end of cleardbline

sub clearalldblines(;&$) {
	my ($clearsub,$fname) = @_ ;
	my ($key, $value, $brkPt, $dbkey) ;
	local(*dbline) ;

	while ( ($key, $value) = each %main:: )  { # key loop
		next unless $key =~ /^_</ ;
		next if (defined $fname && $key ne "_<$fname");
		*dbline = $value ;
		DB::trace("clearalldblines '$key'");
		foreach $dbkey (keys %dbline) {
		$brkPt = $dbline{$dbkey} ;
		delete $dbline{$dbkey} ;
		next unless($brkPt && defined ($clearsub)) ;
		&$clearsub($brkPt) ; # if specificed, call the sub routine to clear the breakpoint
		}

	} # end of key loop

} # end of clearalldblines

sub getdblineindexes {
	my ($fname) = @_ ;
	local(*dbline) = $main::{'_<' . $fname} ;
	return keys %dbline ;
} # end of getdblineindexes

sub getBreakpoints {
	my (@fnames) = @_ ;
	unless (@fnames) {
		@fnames = keys %main:: ;
		map ( $fnames[$_] =~ s/^_<// , 0..$#fnames);
	}
	my ($fname, @retList) ;

	foreach $fname (@fnames) {
		next unless  exists $main::{'_<' . $fname} ;
		local(*dbline) = $main::{'_<' . $fname} ;
		push @retList, values %dbline ;
	}
	return wantarray ? @retList : scalar(@retList);
} # end of getBreakpoints

#
# Construct a hash of the files
# that have breakpoints to save
#
sub breakpoints_to_save {
my ($file, @breaks, $brkPt, $svBrkPt, $list) ;
my ($brkList) ;

$brkList = {} ;

foreach $file ( keys %main:: ) { # file loop
	next unless $file =~ /^_</ && exists $main::{$file} ;
	local(*dbline) = $main::{$file} ;
	next unless @breaks = values %dbline ;
	$list = [] ;
	foreach $brkPt ( @breaks ) {
		$svBrkPt = { %$brkPt } ; # make a copy of it's data
		push @$list, $svBrkPt ;
	} # end of breakpoint loop
	$brkList->{$file} = $list ;
} # end of file loop

return $brkList ;

} # end of breakpoints_to_save

#
# When we restore breakpoints from a state file
# they've often 'moved' because the file
# has been edited.
#
# We search for the line starting with the original line number,
# then we walk it back 20 lines, then with line right after the
# orginal line number and walk forward 20 lines.
#
# NOTE: dbline is expected to be 'local'
# when called
#

sub fix_breakpoints {
	my(@brkPts) = @_ ;
	my($startLine, $endLine, $nLines, $brkPt) ;
	my (@retList) ;
	local($^W) = 0 ;

	$nLines = $#dbline; ## scalar @dbline ;

	foreach $brkPt (@brkPts) {

		$startLine = $brkPt->{'line'} > 20 ? $brkPt->{'line'} - 20 : 0 ;
		$endLine   = $brkPt->{'line'} < $nLines - 20 ? $brkPt->{'line'} + 20 : $nLines ;
		my $w1 = $brkPt->{'text'};
		$w1 = ptkdbTools::_clearLine($w1);
		for( (reverse $startLine..$brkPt->{'line'}), $brkPt->{'line'} + 1 .. $endLine ) {
			my $w2 = $dbline[$_];
			$w2 = ptkdbTools::_clearLine($w2);
			next unless ($w1 eq $w2 || ptkdbTools::codeSimilarity($w1,$w2));
			# next unless $brkPt->{'text'} eq $dbline[$_] ;
			$brkPt->{'line'} = $_ ;
			push @retList, $brkPt ;
			last ;
		}

	} # end of breakpoint list
	return @retList ;
} # end of fix_breakpoints

#
# Restore breakpoints saved above
#
sub restore_breakpoints_from_save {
	my ($brkList) = @_ ;
	my $self = $DB::window;
	my ($offset, $key, $list, $brkPt, @newList) ;

	if ($DB::no_stop_at_start && !(keys %$brkList)) {
		$DB::no_stop_at_start = 0;
		$self->DoAlert("Option 'no stop at start' forced to off.\nReason: no breakpoints.");
	}

	while ( ($key, $list) = each %$brkList ) { # reinsert loop
		next unless exists $main::{$key} ;
		local(*dbline) = $main::{$key} ;

		$offset = 0 ;
		$offset = 1 if $dbline[1] =~ /use\s+.*Devel::_?ptkdb/ ;

		@newList = fix_breakpoints(@$list) ;
		if ($DB::no_stop_at_start && !scalar(@newList)) {
			$DB::no_stop_at_start = 0;
			$self->DoAlert("Option 'no stop at start' forced to off.\nReason: no valid breakpoints.");
		}
		my @d = ();
		if (scalar(@newList) ne scalar(@$list)) {
			foreach $brkPt (@$list) {
				push @d, "$key:$brkPt->{'line'}" unless (grep $brkPt->{'line'} eq $_->{'line'}, @newList);
			}
		}
		my $bBset =0;
		foreach $brkPt ( @newList ) {
			if( !&DB::checkdbline($key, $brkPt->{'line'} + $offset) ) {
				DB::trace("Breakpoint $key:$brkPt->{'line'} in config file is not breakable.") ;
				push @d, "$key:$brkPt->{'line'}";
				next ;
			}
			$dbline{$brkPt->{'line'}} = { %$brkPt } ; # make a fresh copy
			$bBset ++;
			DB::trace("breakpoint set $key $brkPt->{'line'}")
		}
		if ($bBset == 0 && $DB::no_stop_at_start) {
			$DB::no_stop_at_start = 0;
			$self->DoAlert("Option 'no stop at start' forced to off.\nReason: no valid breakpoints.");
		}
		$self->DoAlert("Breakpoint discarded on these lines\n" . join("\n",@d)) if (@d);
		##
		## TODO: set dirtyFlag on if @d > 0 ???
		##
	} # end of reinsert loop
} # end of restore_breakpoints_from_save ;

use strict ; ## set strict again ...

sub dbint_handler {
	my($sigName) = @_ ;
	$DB::single = 1 ;
	warn "\n#---------\n# ptkdb - catched a INT exception\n#---------\n";
	DB::Log("signalled '$sigName'") ;
} # end of dbint_handler

#
# Set up the debugging session
#
#
sub Initialize {
	my ($fName) = @_ ;
	return if $DB::ptkdb_isInitialized ;
	DB::trace("Initialize");
	$DB::ptkdb_isInitialized = 1 ;

	$DB::window = Devel::ptkdb->new() ;

	$DB::window->doEvalPtkdbrc() ;

	my @w = @{$DB::window->{'expr_list'}}; ## save for later use (dirty hack!)

	unless ($DB::sigint_disable) { # saves the old handler and set the new one
		$DB::dbint_handler_save = $SIG{'INT'};
		$SIG{'INT'} = "DB::dbint_handler";
	}
	# Save the file name we started up with
	$DB::startupFname = $fName ;

	# Check for a 'restart' file

	if( $ENV{'PTKDB_RESTART_STATE_FILE'} && $Devel::ptkdb::DataDumperAvailable && -e $ENV{'PTKDB_RESTART_STATE_FILE'} ) {
		##
		## Restore expressions and breakpoints in state file
		##
		$DB::window->restoreStateFile($ENV{'PTKDB_RESTART_STATE_FILE'}) ;
		unlink $ENV{'PTKDB_RESTART_STATE_FILE'} ; # delete state file

		DB::trace("Restoring state from $ENV{'PTKDB_RESTART_STATE_FILE'}") ;

		$ENV{'PTKDB_RESTART_STATE_FILE'} = "" ; # clear entry
	}
	else {
		&DB::restoreState($fName) if $Devel::ptkdb::DataDumperAvailable ;
	}

	map {		## now reinsert items defined in .ptkdbrc
		my $e = $_;
		$e = undef if(grep($_->{'expr'} eq $e->{'expr'}, @{$DB::window->{'expr_list'}}));
		unshift @{$DB::window->{'expr_list'}},$e if defined $e;
	} @w;

	DB::trace("Initialize done");

} # end of Initialize

sub restoreStateOfRequiredFile {
	my($fName) = @_ ;
	my $files = {};
	DB::trace("Restoring breakpoints for $fName");
	for (keys %{$DB::window->{'files'}}) {
		$files->{$_} = $DB::window->{'files'}->{$_} if ($fName eq $_) ;
	}
	if (exists $files->{$fName}) {
		&DB::restore_breakpoints_from_save($files) ;
	} else {
		DB::trace("There are no breakpoint to restore for '$fName'");
	}
} # end of Restore State

sub restoreState {
	my($fName) = @_ ;
	my ($stateFile, $files, $expr_list, $eval_saved_text, $main_win_geometry, $restoreName) ;

	DB::trace("restoreState");

	$stateFile = makeFileSaveName($fName) ;

	DB::trace("stateFile = $stateFile");

	if( -e $stateFile && -r $stateFile ) {
		($files, $expr_list, $eval_saved_text, $main_win_geometry) = $DB::window->get_state($stateFile) ;
		&DB::restore_breakpoints_from_save($files) ;
		$DB::window->{'files'} = $files if defined $files ;	##
		$DB::window->{'expr_list'} = $expr_list if defined $expr_list ;
		$DB::window->{'eval_saved_text'} = $eval_saved_text ;

		if ( $main_win_geometry ) {
			$main_win_geometry = "800x600" if ($main_win_geometry =~ /1x1/);
			$DB::window->{'main_window'}->geometry($main_win_geometry) ;
		}
	} else {
		DB::trace("no state file found.");
	}
	$DB::window->{'dirtyFlag'} = 0;
	$DB::window->setStatus1();
	$DB::window->setStatus0();
	DB::trace("restoreState done");
} # end of Restore State

sub makeFileSaveName {
	my ($fName) = @_ ;
	my $saveName = $fName ;
	if ($saveName =~ /\.p[lm]$/ ) {
		$saveName =~ s/\.p[lm]$/.ptkdb/ ;
	}
	else {
		$saveName .= ".ptkdb" ;
	}
	return $saveName ;
} # end of makeFileSaveName

sub save_state_file {
	my($fname) = @_ ;
	my($files, $d, $saveStr) ;

	DB::trace("save_state_file $fname");
	$files = &DB::breakpoints_to_save() ;
	my $main_win_geometry = $DB::window->get_Main_Window(0)->geometry();
	my $param = 'ptkdbFilter'->param();
	$d = Data::Dumper->new( [ $files, $DB::window->{'expr_list'}, "" ,$main_win_geometry,  $DB::window->{'dirtyFlag'},$DB::ptkdb::stop_on_restart,$param,$Devel::ptkdb::decorate_code],
	                        [ "files", "expr_list",  "eval_saved_text","main_win_geometry","dirtyFlag",               "stop_on_restart",          "param","decorate_code"] ) ;
	$d->Purity(1) ;
	if( Data::Dumper->can('Dumpxs') ) {
		$saveStr = $d->Dumpxs() ;
	} else {
		$saveStr = $d->Dump() ;
	}
	DB::trace($saveStr);
	eval {
		local(*F) ;
		open F, ">$fname" || die "ptkdb - Couldn't open file $fname" ;
		print F $saveStr || die "ptkdb - Couldn't write file" ;
		close F ;
	};
} # end of save_state_file

sub SaveState {
	my($name_in) = @_ ;
	my ($top, $entry, $okayBtn, $win) ;
	my ($fname, $saveSub, $cancelSub, $saveName, $eval_saved_text, $d) ;
	my ($files, $main_win_geometry);
	$win = $DB::window ;
	my $hwnd = $win->get_Main_Window(0);
	$main_win_geometry = $hwnd->geometry ;
	if ( exists $win->{'save_box'} ) {
		$win->{'save_box'}->raise ;
		$win->{'save_box'}->focus ;
		return ;
	}
	$saveName = $name_in || makeFileSaveName($DB::startupFname) ;
	$saveSub = sub {
		$win->{'event'} = 'null' ;
		my $saveStr ;
		delete $win->{'save_box'} ;
		if( exists $win->{'eval_window'} ) {
			$eval_saved_text = $win->{'eval_text'}->get('0.0', 'end') ;
		} else {
			$eval_saved_text =  $win->{'eval_saved_text'} ;
		}
		$files = &DB::breakpoints_to_save() ;
		$d = Data::Dumper->new( [ $files, $win->{'expr_list'}, $eval_saved_text,   $main_win_geometry ],
								[ "files", "expr_list",        "eval_saved_text",  "main_win_geometry"] ) ;
		$d->Purity(1) ;
		if( Data::Dumper->can('Dumpxs') ) {
			$saveStr = $d->Dumpxs() ;
		} else {
			$saveStr = $d->Dump() ;
		}
		local(*F) ;
		# $saveName = $Devel::ptkdb::promptString;
		$saveName =  ($saveName =~ /[\\\/]/) ? $Devel::ptkdb::promptString : $DB::CALLERCW . '/' . $Devel::ptkdb::promptString;
		eval {
			open F, ">$saveName" || die "ptkdb - Couldn't open file $saveName" ;
			print F $saveStr || die "ptkdb - Couldn't write file $saveName" ;
			close F ;
		} ;
		$win->DoAlert($@) if $@ ;
		$win->{'dirtyFlag'} = 0 unless $@;
		$win->setStatus1();
		DB::log("config saved to '$saveName'");
		} ; # end of save sub
	$cancelSub = sub {
		delete $win->{'save_box'}
		} ; # end of cancel sub

	$win->simplePromptBox_Modal("Save Config?", $saveName, $saveSub, $cancelSub) ;
} # end of SaveState

sub RestoreState {
	my $restoreSub = sub {
		$DB::window->restoreStateFile($Devel::ptkdb::promptString) ;
		} ;
	$DB::window->simplePromptBox_Modal("Restore Config?", makeFileSaveName($DB::startupFname), $restoreSub, sub {1}) ;

} # end of RestoreState

sub SetStepOverBreakPoint {
	my ($offset) = @_ ;
	$DB::step_over_depth = $DB::subroutine_depth + ($offset ? $offset : 0) ;
} # end of SetStepOverBreakPoint

#
# NOTE:   It may be logical and somewhat more economical
#         lines of codewise to set $DB::step_over_depth_saved
#         when we enter the subroutine, but this gets called
#         for EVERY callable line of code in a program that
#         is being debugged, so we try to save every line of
#         execution that we can.
#
sub isBreakPoint {
	my ($fname, $line, $package) = @_ ;
	my ($brkPt) ;

	if ( $DB::single &&
		($DB::step_over_depth < $DB::subroutine_depth) &&
		($DB::step_over_depth > 0) &&
		!$DB::on) {
			$DB::single = 0  ;
			return 0 ;
	}
	if( $DB::single || $DB::signal ) { # doing a step over/in
		$DB::single = 0 ;
		$DB::signal = 0 ;
		$DB::subroutine_depth = $DB::subroutine_depth ;
		$brkPt = &DB::getdbline($fname, $line) ;
		if( $brkPt->{'type'} eq 'temp' ) { ## 12.11.2014/mm
			&DB::cleardbline($fname, $line)  ;
			$DB::window->removeTempBreakpointTags($brkPt);
			$DB::subroutine_depth = $DB::subroutine_depth ;
		} ## else {}
		return 1 if( !$brkPt || !$brkPt->{'value'} || !breakPointEvalExpr($brkPt, $package) ) ;
		return 2 ;
	}
	#
	# 1st Check to see if there is even a breakpoint there.
	# 2nd If there is a breakpoint check to see if it's check box control is 'on'
	# 3rd If there is any kind of expression, evaluate it and see if it's true.
	#
	$brkPt = &DB::getdbline($fname, $line) ;
	return 0 if( !$brkPt || !$brkPt->{'value'} || !breakPointEvalExpr($brkPt, $package) ) ;

	if( $brkPt->{'type'} eq 'temp' ) { ## 12.11.2014/mm
		&DB::cleardbline($fname, $line)  ;
		$DB::window->removeTempBreakpointTags($brkPt);
		$DB::subroutine_depth = $DB::subroutine_depth ;
	} ## else {}
	return  2 ;
} # end of isBreakPoint

#
# Check the breakpoint expression to see if it
# is true.
#
sub breakPointEvalExpr {
	my ($brkPt, $package) = @_ ;
	my (@result) ;

	return 1 unless exists $brkPt->{'expr'} ; # return if there is no expression
	return 1 unless $brkPt->{'expr'} =~ /\S/; ## or it is an empty string

	no strict ;

	@result = &DB::dbeval($package, $brkPt->{'expr'}) ;

	use strict ;

	if ($@){
		$DB::window->DoAlert("$@,\n\n breakpoint forced." );
		return 1
	}

	return $result[0] or @result ; # we could have a case where the 1st element is undefined
	                               # but subsequent elements are defined
} # end of breakPointEvalExpr

#
# Evaluate the given expression, return the result.
# MUST BE CALLED from within DB::DB in order for it
# to properly interpret the vars
#
sub dbeval {
my($ptkdb__package, $ptkdb__expr) = @_ ;
my(@ptkdb__result, $ptkdb__str) ;
my(@ptkdb_args) ;
local($^W) = 0 ; # temporarily turn off warnings

no strict ;
#
# This substitution is done so that
# we return HASH, as opposed to an ARRAY.
# An expression of %hash results in a
# list of key/value pairs.
#
$ptkdb__expr =~ s/^\s*%/\\%/o ;
@_ = @DB::saved_args ; # replace @_ arg array with what we came in with
@ptkdb__result = eval <<__EVAL__ ;

\$\@ = \$DB::save_err ;
package $ptkdb__package ;
$ptkdb__expr ;
__EVAL__

@ptkdb__result = ("ERROR ($@)") if $@ ;
use strict ;
return @ptkdb__result ;
} # end of dbeval

sub dbDie {
	my $e = shift;
	my $t = ''; ## for stringified  form of $e.
	if (ref($e)) {
		$t = 'Error Object of type '. ref($e); ## stringify temp
		## trap, $e itself may be incorrect or damaged. So, be careful!
	} else {
		$t = $e;
	}
	DB::DoTrace('exc',-1,"$t");
	warn "\n#---------\n# ptkdb - catched the die exception:\n$t\n#---------\n";
}

sub dbExit { ## callback on INT signal or DoQuit-termination
	$DB::single=0;
	'ptkdbFilter'->param->{'state'} = 0; ## set filter off
	chdir $DB::CALLERCW if (-d $DB::CALLERCW);
	CORE::exit ;
} # end of dbExit

#
# This is the primary entry point for the debugger.  When a Perl program
# is parsed with the -d(in our case -d:ptkdb) option set the parser will
# insert a call to DB::DB in front of every excecutable statement.
#
# Refs:  Programming Perl 2nd Edition, Larry Wall, O'Reilly & Associates, Chapter 8
#

##
## Since Perl 5.8.0 we need to predeclare the sub DB{} at the start of the
## package or else the compilation fails.  We need to disable warnings though
## since in 5.6.x we get warnings on the sub DB begin redeclared.  Using
## local($^W) = 0 will leave warnings disabled for the rest of the compile
## and we don't want that.
##

my($saveW) ;
our @traceArea = ();
our $min_indent= 0;
our $current_indent= 0;

our $ptkdb_isTerminating = 0;
our $ptkdb_isInitialized = 0;

sub BEGIN {							## DB::BEGIN
	$saveW = $^W ;
	$^W = 0 ;
}

sub INIT {							## DB::INIT
	DB::trace("INIT block" .  __PACKAGE__ . " $0");
	## cannot be used to perform initialization
}

sub CHECK {							## DB::CHECK
	DB::trace("CHECK block" .  __PACKAGE__ . " $0");
	unless ($^C) { ## do nothing on syntax check
		use Cwd;
		our $CALLERCW = cwd();
		&DB::Initialize($0);
		unless ($DB::sigdie_disable) {
			$SIG{'__DIE__'} = \&DB::dbDie;
		};
		$DB::window->EnterSession();
	}
}

sub END {								## DB::end
	DB::trace("END block" .  __PACKAGE__);
	$DB::ptkdb_isTerminating = 1;
	if ('ptkdbFilter'->active()) { ## this code is a dirty hack .... shame on me ! 28.02.2011/mm
		'ptkdbFilter'->param->{'state'} = 0;
		my $hwnd = Devel::ptkdb::get_Main_Window(undef,1); ## force new mainwindow
		DB::dlg_showTrace($hwnd);
	} else {
	}
	$DB::window->LeaveSession();
}

sub _DoTraceValue {
	my $v = shift;
	my $rv ;
	return 'UNDEF' unless defined $v;
	return ref $v if ref $v;
	$rv = ($v =~ /[\x00-\x06\x14\x1f]/) ? 'ptkdbTools'->toHex($v) : $v;
	return $rv;
}

sub DoTrace {
	my $id = shift;
	return undef if ($DB::on && $id !~ /^expr/i);
	return undef if ($DB::on && $id =~ /^expr/i && !$Devel::ptkdb::trace_expressions);
	return undef unless ($Devel::ptkdb::trace_array_size > 0);
	my @a = map {
		defined($_) ? DB::_DoTraceValue($_) : 'UNDEF'
	} @_;
	shift(@DB::traceArea) if(scalar(@DB::traceArea) > $Devel::ptkdb::trace_array_size);
	push @DB::traceArea, $id . '|' . join ('|',@a) ;
	return 1
}

sub dlg_endSession {
	my $hwnd = shift;
	my ($dirtyFlag) = @_;
	my $rv;
	my ($mw, $text, $wr_001);

	$hwnd = $DB::window->get_Main_Window() unless defined $hwnd;
	$text = "Session end reached.\n";
	$text .= "Session state has been modified." if($dirtyFlag);
	$mw = $hwnd->DialogBox(-title, 'ptkdb - Session end',-buttons,[qw(Quit Save Restart DB-trace)]);
	$wr_001 = $mw -> Message(-anchor,'nw',-borderwidth,1,
		-justify,'left',-relief,'ridge',-aspect,400,
		-text , $text)->pack(-anchor,'nw',-side,'top',
		-pady,20,-fill,'both',-expand,1,-padx,5);
	$mw->protocol('WM_DELETE_WINDOW',sub{1});
	$mw->Subwidget('B_Save')->configure(-state,'disabled') unless ($dirtyFlag);
	$mw->Subwidget('B_Restart')->configure(-state,'disabled');
	$mw->Subwidget('B_DB-trace')->configure(-state,'disabled') unless ($Devel::ptkdb::trace_active );
	while (1) {
		$rv =  $mw->Show();
		if ($rv =~/save/i) {
			my $saveName = &DB::makeFileSaveName($DB::startupFname) ;
			$saveName = $0 unless ($saveName);
			&DB::SaveState($saveName);
			$dirtyFlag = $DB::window->{'dirtyFlag'};
			$mw->Subwidget('B_Save')->configure(-state,'disabled') unless ($dirtyFlag);
			next
		} elsif ($rv =~/restart/i) {
			$rv = 1;
			last
		} elsif ($rv =~/quit/i) {
			$rv = 0;
			last
		} elsif($rv =~/DB-trace/i) {
			DB::dlg_showTrace($DB::window->get_Main_Window(1));
		} else {
			$rv = undef
		}
	}
	return $rv;
}

sub dlg_showTraceExists {
	my $rv = defined $DB::window->{'trace_window'} &&
		     defined $DB::window->{'trace_window_text'} &&
		     (Tk::Exists($DB::window->{'trace_window'}));
	return $rv
}

sub dlg_showTrace {
	my $hwnd = shift;
	if(&dlg_showTraceExists()) {
		&dlg_showTrace_refresh();
		$DB::window->{'trace_window'}->deiconify();
		$DB::window->{'trace_window'}->raise();
		$DB::window->{'trace_window'}->focus();
		return undef
	}
	$hwnd = $DB::window->{'main_window'} unless defined $hwnd;
	my (%args) = @_;
	my $rv;
	my ($wr_001, $wr_002, $wr_009, $wr_008, $wr_008, $wr_003, $wr_020, $wr_004, $wr_006, $wr_017, $wr_018,$wr_019);
	my $mw = $hwnd->Toplevel();
	$hwnd->fontCreate('traceTextFont',@{$Devel::ptkdb::code_text_font[1]})
	unless('Devel::ptkdb'->fontExists('traceTextFont'));
	$mw->configure(-title=> 'ptkdb - trace breakpoints');
	$mw->protocol('WM_DELETE_WINDOW',[\&dlg_showTrace_cancel,$mw]);
	$wr_001 = $mw -> Frame ( -borderwidth , 1 , -relief , 'sunken'  ) -> pack(-side=>'top', -anchor=>'nw', -pady=>5, -fill=>'both', -expand=>1, -padx=>5);
	$wr_002 = $mw -> Frame ( -borderwidth , 1 , -relief , 'sunken'  ) -> pack(-side=>'top', -anchor=>'nw', -pady=>5, -fill=>'x', -expand=>1, -padx=>5);
	$wr_009 = $mw -> Frame ( -relief , 'flat'  ) -> pack(-side=>'bottom', -anchor=>'sw', -pady=>5, -fill=>'x', -expand=>1, -padx=>5);
	$wr_008 = $wr_001 -> Scrolled ( 'ROText' ,@Devel::ptkdb::scrollbar_cfg ,-background , '#ffffff' , -state , 'normal' , -relief , 'sunken' , -wrap , 'none', -font,'traceTextFont') -> pack(-side=>'top', -anchor=>'nw', -pady=>2, -fill=>'both', -expand=>1, -padx=>2);
	$wr_003 = $wr_002 -> Button ( -background , '#ffffff' , -command , [\&dlg_showTrace_cancel , $mw ] , -state , 'normal' , -text , 'Ok' , -relief , 'raised'  ) -> pack(-side=>'left', -anchor=>'nw', -pady=>2, -fill=>'x', -expand=>1, -padx=>2);
	$wr_020 = $wr_002 -> Button ( -background , '#ffffff' , -command , [\&dlg_showTrace_init , $wr_008 ] , -state , 'normal' , -relief , 'raised' , -text , 'Init'  ) -> pack(-side=>'left', -anchor=>'nw', -pady=>2, -fill=>'x', -expand=>1, -padx=>2);
	$wr_004 = $wr_002 -> Button ( -background , '#ffffff' , -command , [\&dlg_showTrace_refresh , $wr_008 ] , -state , 'normal' , -relief , 'raised' , -text , 'Refresh'  ) -> pack(-side=>'left', -anchor=>'nw', -pady=>2, -fill=>'x', -expand=>1, -padx=>2);
	$wr_006 = $wr_002 -> Button ( -background , '#ffffff' , -command , [\&dlg_showTrace_cancel , $mw ] , -state , 'normal' , -relief , 'raised' , -text , 'Cancel'  ) -> pack(-side=>'left', -anchor=>'nw', -pady=>2, -fill=>'x', -expand=>1, -padx=>2);
	$wr_019 = $wr_002 -> Button ( -background , '#ffffff' , -command , [\&dlg_showTrace_open , $wr_008 ] , -state , 'normal' , -relief , 'raised' , -text , 'Open'  ) -> pack(-side=>'left', -anchor=>'nw', -pady=>2, -fill=>'x', -expand=>1, -padx=>2);
	$wr_017 = $wr_009 -> Label ( -relief , 'sunken' , -anchor , 'nw' , -justify , 'left' , -text , "$^O - $0"  ) -> pack(-side=>'left', -anchor=>'nw', -fill=>'x', -expand=>1);
	$wr_018 = $wr_009 -> Label ( -relief , 'sunken' , -anchor , 'ne' , -justify , 'right' , -text , "pid $$"  ) -> pack(-side=>'right', -anchor=>'ne', -fill=>'x', -expand=>1);
	$DB::window->{'trace_window'} = $mw;
	$DB::window->{'trace_window_text'} = $wr_008;
	my %tags = qw(breakpoint green sub blue result #0099FF expression #4A4A4A required #4A4A4A exception red);
	foreach (keys %tags) {
		$wr_008->tagConfigure($_,-foreground,$tags{$_});
	}
	$wr_008->tagBind('selected','<Button-1>', \&dlg_showTrace_open);

	&dlg_showTrace_refresh($wr_008) if(@DB::traceArea);

} ## end of dlg_showTrace

sub dlg_splitTraceAreaItem {
	return split /\|/,$_[0]
}

sub _dlg_editLine {
	my $line = shift;
	my $tag = '';
	my $rv = '';
	unless (defined $line) {
		return wantarray ? ('','') : '';
	}
	my @w = dlg_splitTraceAreaItem($line);
	my $entry = shift @w;
	my $depth = shift @w;
	$current_indent = int($depth - $min_indent) unless($depth < 0);
	my $indent = '    ' x $current_indent;
	if ($entry =~/db/i) {
		$rv = 'breakpoint   '."\t". join(" \t",@w);
		$tag = 'breakpoint';
	} elsif ($entry =~/sub/i) {
		@w = grep ($_ !~ /unknown/i, @w);
		shift @w ; ## get rid of type
		$rv = 'sub          '."\t". join(" \t",@w);
		$tag = 'sub';
	} elsif ($entry =~/expr/i) {
		shift @w; shift @w;
		$rv = 'expression   '."\t". join(" \t",@w);
		$tag = 'expression';
	} elsif ($entry =~/arg/i) {
		$rv = 'arglist      '."\t". join(" \t",@w);
		$tag = 'sub';
	} elsif ($entry =~/resa/i) {
		$rv = 'result array  '."\t". join(" \t",@w);
		$tag = 'result';
	} elsif ($entry =~/ress/i) {
		$rv = 'result scalar '."\t". join(" \t",@w);
		$tag = 'result';
	} elsif ($entry =~/void/i) {
		$rv = 'void context'."\t". join(" \t",@w);
		$tag = 'result';
	} elsif ($entry =~/req/i) {
		$rv = 'required      '."\t". join(" \t",@w);
		$tag = 'required';
	} elsif ($entry =~/exc/i) {
		$rv = 'exception     '."\t". join(" \t",@w);
		$tag = 'exception';
	} else {
		$rv = 'unknown       ' ."\t". join(" \t",@w);
	}
	$rv = "$indent$rv\n";
	return wantarray ? ($rv,$tag) : $rv
}

sub minIndentation {
	my $rv;
	my $depth;
	map {
		($depth) = (&dlg_splitTraceAreaItem($_))[1..1];
		$rv = (!defined $rv) ? $depth : ($rv > $depth) ? $depth : $rv
	} grep(/^sub/, @main::traceArea);
	return $rv;
}

sub dlg_showTrace_open {
	my $text = shift;
	$text = $DB::window->{'trace_window_text'} unless defined $text;
	my $rv;
	my $sel = $text->getSelected();
	return undef unless (length $sel > 0);
	if ($sel =~ /^\s*breakpoint/i) {
		$sel =~ s/^\s+//;
		my ($id,$package,$selectedFile,$line) = split /\s+/,$sel;
		if (exists $main::{'_<' . $selectedFile}){
			$line = 0 unless defined $line;
			$DB::window->set_file($selectedFile, $line) ;
		} else {
			$DB::window->DoAlert('Selected text doesn\'t contain a valid file name,'."\n".'pls select line with a <triple click>');
		}
	} elsif ($sel =~ /^required/) {
		my ($id,$selectedFile) = split /\s+/,$sel;
		if (exists $main::{'_<' . $selectedFile}){
			$DB::window->set_file($selectedFile, 0) ;
		} else {
			$DB::window->DoAlert('Selected text doesn\'t contain a valid file name,'."\n".'pls select line with a <triple click>');
		}
	} else {
		$DB::window->DoAlert('Selected line isn\'t a breakpoint or a required entry,'."\n".'pls select line with a <triple click>');
	}
	return $rv
}

sub dlg_showTrace_ok {
	my $dlg = shift;
	$DB::window->get_Main_Window(0)->fontDelete('traceTextFont');
	$dlg->destroy();
	$DB::window->{'trace_window'} = undef;
	$DB::window->{'trace_window_text'} = undef;
}

sub dlg_showTrace_refresh {
	my $text = shift;
	$text = $DB::window->{'trace_window_text'} unless defined $text;
	$text->delete('1.0','end');
	$min_indent = minIndentation();
	map {
		my @w = &_dlg_editLine($_);
		$text->insert('end',@w);
	} @DB::traceArea;
	$text->see('end');
	$text->update();
}

sub dlg_showTrace_cancel {
	my $dlg = shift;
	$dlg = $DB::window->{'trace_window'} unless defined $dlg;
	$dlg->destroy() if(defined($dlg) && Tk::Exists($dlg));
	$DB::window->get_Main_Window(0)->fontDelete('traceTextFont') if
		('Devel::ptkdb'->fontExists('traceTextFont'));
	$DB::window->{'trace_window'} = undef;
	$DB::window->{'trace_window_text'} = undef;
}

sub dlg_showTrace_init {
	my $text = shift;
	my $text = $DB::window->{'trace_window_text'} unless defined $text;
	$text->delete('1.0','end');
	@DB::traceArea = ();
}

sub brkptFilter {
	my ($fname, $line, $package) = @_;
	my $rv = 0;
	my $param = 'ptkdbFilter'->param();
	DB::trace("brkptFilter $fname, $line, $package");
	return 0 unless ('ptkdbFilter'->active);
	my $action = 'ptkdbFilter'->action();
	$action ->[0]->[1] =sub {$fname eq $param->{$_[0]} || 'ptkdbFilter'->empty($param->{$_[0]})} ;
	$action ->[1]->[1] =sub {$package eq $param->{$_[0]} || 'ptkdbFilter'->empty($param->{$_[0]})} ;
	$action ->[2]->[1] =sub { int($line) >= int($param->{$_[0]})} ;
	$action ->[3]->[1] =sub {
			return 1 if 'ptkdbFilter'->empty($param->{'expr'});
			my @r = &DB::dbeval($package,$param->{'expr'});
			return ($r[0]) ? 1 : 0
			} ;

	for (@$action) {
		next if ('ptkdbFilter'->empty($_->[0]));
		$rv = &{$_->[1]}($_->[0]) ;
		DB::trace("$_->[0] $rv");
		last unless ($rv);
	}
	DB::trace("brkptFilter rv = '$rv'");
	return ($rv) ? $param->{'action'} : 0
}

sub evalActionsList {
my $DBeL = shift;
my @args = @_;
if (defined $DB::window->{$DBeL}) {
	DB::trace("evalActionsList $DBeL");
	my $list = $DB::window->{$DBeL};
	foreach my $entry (@$list) {
		if (ref($entry) =~ /CODE/) {
			eval {&$entry(@args)};
			DB::log("$DBeL, error evaluating callback\n\$@") if ($@);
		} elsif (ref($entry) =~ /^\s*$/) {
			eval $entry ;
			DB::log("$DBeL, error evaluating '$entry'\n\$@") if ($@);
			## TODO: delete the item on error ?
		} else {
			DB::log("$DBeL, unexpected type of '$entry', discarded.")
		}
	}
} else {}
return 1
}

sub DB {
	## return 0 if($DB::sleeping);   ## dirty trick
	return 0 if($DB::ptkdb_isTerminating || !$DB::ptkdb_isInitialized);
	return 0 unless($DB::sessionPID eq $$);  ## bypass subprocesses (fork)
	@DB::saved_args = @_ ; # save arg context
	$DB::save_err = $@ ; # save value of $@
	local $SIG{'__DIE__'} = sub {
			my $e = shift;
			warn "ptkdb - >>> exception catched '$e'";
			};
	my ($package, $filename, $line, $subName) = CORE::caller ;
	$subName='' unless defined $subName;
	DB::trace("$package, $filename, $line, $subName");
	my ($stop, $cnt) ;
	if ($package =~ /^(ptkdbScopeGuardx|ptkdbFilter|ptkdbTools)/) { ## ignore processing in ptkdbScopeGuardx
		return
	}
	if ($package =~ /^Devel::(ptkdb|DB)/) { ## processing in ptkdb::END block
		$DB::single = 0;
		return 0
	} ## else {}
	my $saveOn = $DB::on; $DB::on = 1; ## save around Tk messages (temp fix)
	$^W = $saveW ;
	if (defined($DB::window->{'main_window'}) && not Tk::Exists ($DB::window->{'main_window'})) {
		DB::trace("ptkdb main window doesn't exist anymore,"," breakpoint discarded ($package, $filename, $line).");
		$DB::on = 0 ; ### patch 1
		return 0
	}
	unless( $DB::ptkdb_isInitialized ) {
		if( $filename ne $0 ){ # not in our target file
			$DB::on = $saveOn;
			DB::trace("$filename bypassed - ptkdb not yet init");
			return 0;
		} else {}
		&DB::Initialize($filename) ;
	}
	$DB::on = $saveOn;
	my $brkptType = DB::isBreakPoint($filename, $line, $package);
	if (!$brkptType) {
		$DB::single = 0;
		$@ = $DB::save_err ;
		$DB::on = 0 ; ### patch 1
		return 0;
	} elsif ($brkptType == 1) {
		DB::trace("Step forward");
		if ('ptkdbFilter'->active()) {
			my $ptkdbFilterAction = DB::brkptFilter($filename, $line, $package);
			if ($ptkdbFilterAction == 0) {
				$DB::single = 1 ;    ## force step mode
				$@ = $DB::save_err ;
				$DB::on = 0 ; ### patch 1
				return 0;
			} elsif ($ptkdbFilterAction == 1 ){
				DB::trace("BP filter , action '$ptkdbFilterAction'.");
				&DB::DoTrace('DB',-1,$package, $filename, $line, $subName) unless ($DB::on);
				## OK, show breakpoint
				$DB::autostep = 0;
			} elsif ($ptkdbFilterAction == 2) {
				&DB::DoTrace('DB',-1,$package, $filename, $line, $subName);
				DB::log("BP filter , action '$ptkdbFilterAction'.");
				$DB::single = 0 ;
				$@ = $DB::save_err ;
				$DB::on = 0 ; ### patch 1
				return 0;
			} else {
				DB::log("BP filter , unexpected action '$ptkdbFilterAction', ignored.");
				## unexpected, forget it and go on
			}
		} else {
			&DB::DoTrace('DB',-1,$package, $filename, $line, $subName) unless ($DB::on);
		}
	} elsif ($brkptType == 2) {
		DB::trace("Unconditional breakpoint");
		&DB::DoTrace('DB',-1,$package, $filename, $line, $subName) unless ($DB::on);
		$DB::autostep = 0;
	} else  {
		DB::log("Unexpected breakpoint type '$brkptType'");
	}
	$DB::on = 1 ; ### patch 1
	if ( !$DB::window ) { # not setup yet
		$@ = $DB::save_err ;
		$DB::on = 0 ; ### patch 1
		return 0 ;
	}
	$DB::window->setup_main_window() unless $DB::window->{'main_window'} ;
	$DB::window->EnterActions($package,$filename,$line) ;
	my ($saveP) ;
	$saveP = $^P ;
	$^P = 0 ;
	#
	# The user can specify this variable in one of the startup files,
	# this will make the debugger run right after startup without
	# the user having to press the 'run' button.
	#
	if( $DB::no_stop_at_start ) {
		if ($brkptType == 2) { ## conditional bp, stop
			$DB::no_stop_at_start = 0 ;
		} else { ## continue restart process until uncond bp occurs
			$DB::on = 0 ;
			$@ = $DB::save_err ;
			return 0 ;
		}
	} ## else {}  ## nothing to do
	unless( $DB::sigint_disable ) {
		$SIG{'INT'} = $DB::dbint_handler_save if $DB::dbint_handler_save ; # restore original signal handler
		$SIG{'INT'} = "DB::dbExit" unless   $DB::dbint_handler_save ;
	}

	# bring us to the top make sure OUR event loop runs
	if (defined($DB::window->{'main_window'}) && Tk::Exists ($DB::window->{'main_window'})) {
		$DB::window->{'main_window'}->deiconify() ;
		$DB::window->{'main_window'}->raise() ;
		$DB::window->{'main_window'}->focus() ;
	} else {
	}
	$DB::window->set_file($filename, $line) ;
	updateExprAndProximity($filename,$package,$line);
	## updateExprs($package,$line) ; # Refresh the exprs to see if anything has changed
	## updateProximity($filename,$package,$line);
	# Update subs Page if necessary
	$cnt = scalar keys %DB::sub ;
	if ( $cnt != $DB::window->{'subs_list_cnt'} && $DB::window->{'subs_page_activated'} ) {
		$DB::window->fill_subs_page() ;
		$DB::window->{'subs_list_cnt'} = $cnt ;
	}
	$DB::window->refresh_stack_menu() ; # Update the subroutine stack menu
	$DB::window->{'run_flag'} = 1 ;
	my ($evt, @result, $r) ;
	DB::evalActionsList ('user_window_DB_entry_list',$package,$filename,$line);
	$DB::window->{'notebook'}->raise("datapage") unless ($DB::window->{'notebook'}->raised() eq "datapage");
	while(1) {
		$evt = $DB::window->main_loop();
		if( $evt eq 'step' ) {
			last;
		} elsif ($evt eq 'run' ) {
			$DB::single = 0;
			last;
		} elsif ($evt eq 'balloon_eval' ) {
			my @result = &DB::dbeval($package, $DB::window->{'balloon_expr'});
			$result[0] = ptkdbTools::decode($result[0]) if (ref $result[0] eq 'CODE');
			# $DB::window->code_motion_eval(&DB::dbeval($package, $DB::window->{'balloon_expr'})) ;
			$DB::window->code_motion_eval(@result) ;
			next ;
		} elsif ( $evt eq 'qexpr' ) { # evaluate quick expression
			my $str ;
			my $quickEntrySubW = ($DB::window->{'quick_entry'}->can('Subwidget')) ?
			$DB::window->{'quick_entry'}->Subwidget('entry') :
			$DB::window->{'quick_entry'};
			@result = &DB::dbeval($package, $DB::window->{'qexpr'}) ;
			$quickEntrySubW->delete(0, 'end') ; # clear old text
			if (exists $DB::window->{'quick_dumper'}) {
				my $quickDumper = $DB::window->{'quick_dumper'};
				$quickDumper->Reset() ;
				$quickDumper->Values( [ ($#result == 0) ? @result : \@result ] ) ;
				if( $quickDumper->can('Dumpxs') ) {
					$str = $quickDumper->Dumpxs() ;
				} else {
					$str = $quickDumper->Dump() ;
				}
			} else {
				$str = "@result" ;
			}
			$str = ptkdbTools->toHex($str) if ($str =~/[\x00-\x06\x14\x1f]/);
			$quickEntrySubW->insert(0, $str) ; #enter the text
			$quickEntrySubW->selectionRange(0, 'end') ; # select it
			updateExprAndProximity($filename,$package,$line);
			updateEvalWindow($filename,$package,$line,$subName);
			next
		} elsif ( $evt eq 'expr' ) { # Append the new expression to the list
			if ( grep $_->{'expr'} eq $DB::window->{'expr'}, @{$DB::window->{'expr_list'}} ) {
				$DB::window->DoAlert("$DB::window->{'expr'} is already listed") ;
				next ;
			}
			my @result = &DB::dbeval($package, $DB::window->{'expr'}) ;
			if(  @result == 1 ) {
				&DB::DoTrace('expr',-1,$package,$line,$DB::window->{'expr'},$result[0]) ; # trace watched expressions
				$r = $DB::window->insertExpr([ $result[0] ], $DB::window->{'data_list'}, $result[0], $DB::window->{'expr'}, $Devel::ptkdb::expr_depth) ;
			} else {
				&DB::DoTrace('expr',-1,$package,$line,$DB::window->{'expr'},\@result) ; # trace watched expressions
				$r = $DB::window->insertExpr([ \@result ], $DB::window->{'data_list'}, \@result, $DB::window->{'expr'}, $Devel::ptkdb::expr_depth)  ;
			}
			$DB::window->{'dirtyFlag'} = 1; ## mark state has changed
			$DB::window->setStatus1();	#
			push @{$DB::window->{'expr_list'}}, { 'expr' => $DB::window->{'expr'}, 'depth' => $Devel::ptkdb::expr_depth } if $r ;
			next ;
		} elsif( $evt eq 'update' ) {
			updateExprs($package) ;
			next ;
		} elsif( $evt eq 'reeval' ) { # Evaluate the contents of the expression eval window
			updateEvalWindow($filename,$package,$line,$subName);
			updateExprAndProximity($filename,$package,$line);
			next ;
		} else {
			DB::Log("Unexpected ptkdb event '$evt', discarded.")
		}
		last ;
		}
	$^P = $saveP ;
	$SIG{'INT'} = "DB::dbint_handler" unless $DB::sigint_disable ; # set our signal handler
	$DB::window->LeaveActions($package,$filename,$line) ;
	DB::evalActionsList ('user_window_DB_leave_list',$package,$filename,$line);
	$@ = $DB::save_err ;
	$DB::on = 0 ;
	return 0;
} # end of DB

sub print_traceback {
	my $self = shift;
	my @c = $self->getCallStack();
	$self->printCaller(\@c);
}
sub getCallStack {
	my $self = shift;
	my @rv = ();
	my $i ;
	my $x ;
	for ($i=0; defined ($x = CORE::caller($i)); $i++) {
	my @call = CORE::caller($i);
	push @rv,\@call;
	}
	return wantarray ? @rv : scalar(@rv);
}

sub printCaller {
	my $self = shift(@_);
	my @caller = (ref($_[0]) eq 'ARRAY') ? @{$_[0]} : @_;
	print "\n",'--- traceback top';
	map {
		my $c = $_;
		print "\n";
		for(my $i=0;$i < @$c; $i++) {
			my $x = $c->[$i]; $x = 'UNDEF' unless defined $x;
			print " $i:'" .$x."'\n";
		}
	} @caller;
	print '--- traceback bottom',"\n";
	return 1
}

##
## in this case we do not use local($^W) since we would like warnings
## to be issued past this point, and the localized copy of $^W will not
## go out of scope until  the end of compilation
##
##

#
# This is another place where we'll try and keep the
# code as 'lite' as possible to prevent the debugger
# from slowing down the user's application
#
# When a Perl program is parsed with the -d(in our case a -d:ptkdb) option
# the parser will route all subroutine calls through here, setting $DB::sub
# to the name of the subroutine to be called, leaving it to the debugger to
# make the actual subroutine call and do any pre or post processing it may
# need to do.  In our case we take the opportunity to track the depth of the call
# stack so that we can update our 'Stack' menu when we stop.
#
# Refs:  Programming Perl 2nd Edition, Larry Wall, O'Reilly & Associates, Chapter 8
#
#

sub sub {
	no strict ;
	return &$DB::sub unless ($DB::ptkdb_isInitialized == 2 );
	return &$DB::sub if ($DB::ptkdb_isTerminating );
	use strict;
	my $doTrace ;
	# my $saved_subroutine_depth = $DB::subroutine_depth;
	my $saved_subroutine_depth;
	#
	# See NOTES(1)
	#
	## my @args = @_;
	my $guard;

	if (!$DB::on && $DB::sub !~ /^(ptkdbScopeGuardx|ptkdbFilter)/) {
		my @args = @_;
		$saved_subroutine_depth = $DB::subroutine_depth;
		$DB::subroutine_depth ++;

		$guard = 'ptkdbScopeGuardx'->new($saved_subroutine_depth);
		$DB::single = 0 if ( ($DB::step_over_depth < $DB::subroutine_depth) && ($DB::step_over_depth >= 0)) ; ## && !$DB::on) ;
		if ($Devel::ptkdb::trace_array_size && $Devel::ptkdb::trace_sub_active) {
			my @aCaller = (CORE::caller ($DB::subroutine_depth + 1))[0..3];
			if (@aCaller) {
				unless ($aCaller[0] =~/^(DB|ptkdb|ptkdbTools)/ || $aCaller[3] =~ /^DB::DB/) {
				&DB::DoTrace('sub',$saved_subroutine_depth,@aCaller);
				&DB::DoTrace('arg',$saved_subroutine_depth,@args) if (@args);
				$doTrace=1;
				}
				DB::trace("$aCaller[3] ( @args )") if (defined $aCaller[3] && @args);
			} else {
				&DB::DoTrace('sub',$saved_subroutine_depth,'unknown', 'unknown', '0', $DB::sub) unless($DB::sub =~/^DB::DB/);
				&DB::DoTrace('arg',$saved_subroutine_depth,@args) if (@args);
				$doTrace = 1 unless($DB::sub =~/^DB::DB/);
			}
		} ## else {}
	}

	if( wantarray ) {				## array context
		my @result;
		no strict ; # otherwise Perl gripes about calling the sub by the reference
		@result = &$DB::sub; #	call the subroutine	by name
		use strict;
		&DB::DoTrace('resa',$saved_subroutine_depth,@result) if (scalar(@result) && $doTrace);
		return @result;
	} elsif(defined wantarray) {	## scalar context
		my $result;
		no strict ;
		$result = &$DB::sub;
		use strict;
		&DB::DoTrace('ress',$saved_subroutine_depth,$result) if(defined ($result) && $doTrace) ;
		return $result;
	} else {						## void context
		no strict ;
		&$DB::sub ;
		use strict;
		&DB::DoTrace('void',$saved_subroutine_depth) if($doTrace);
		return ;
	}

} # end of sub

sub DB::postponed {
	no strict;
	local *dbline = $_[0];
	my $fName = $dbline;
	&DB::DoTrace('req',-1,$fName);
	DB::trace("postponed  $dbline");
	&DB::restoreStateOfRequiredFile('_<'.$fName);
	if (ref($DB::window) =~/ptkdb/) {
		$DB::window->takeOverBrkptsFromPtkdbrc($fName) ;
		$DB::window->reinsertBreakpoints($fName);
	}
	use strict;
	$DB::window->fill_subs_page() if(defined($DB::window) && ref($DB::window) =~ /^ptkdb/i) ; ## refresh tab 'subs' ## 18.02.2013/mm
	return 1;
}
1 ; # return true value

# ptkdb.pm,v
# Revision 1.23x  2011/03/01  12:00:00  mmarazzi
# Revision 1.22x  2011/02/01  12:00:00  mmarazzi
# Revision 1.21x  2010/11/01  12:00:00  mmarazzi
# Revision 1.20x  2008/10/01  12:00:00  mmarazzi
# sub postponed(), menu dialogs now modal, save config on quit
#
# Revision 1.15  2004/03/31 02:08:40  aepage
# fixes for various lacks of backwards compatiblity in Tk804
# Added a 'bug report' item to the File Menu.
#
# Revision 1.14  2003/11/20 01:59:40  aepage
# version fix
#
# Revision 1.12  2003/11/20 01:46:45  aepage
# Hex Dumper and correction of some parameters for Tk804.025_beta6
#
# Revision 1.11  2003/06/26 13:42:49  aepage
# fix for chars at the end of win32 platforms.
#
# Revision 1.10  2003/05/12 14:38:34  aepage
# win32 pushback
#
# Revision 1.9  2003/05/12 13:46:46  aepage
# optmization of win32 line fixing
#
# Revision 1.8  2003/05/11 23:42:20  aepage
# fix to remove stray win32 chars
#
# Revision 1.7  2003/05/11 23:15:26  aepage
# email address changes, fixes for Perl 5.8.0
#
# Revision 1.6  2002/11/28 19:17:43  aepage
# Changed many options to widgets and pack from bareword or 'bareword'
# to -bareword to support Tk804.024(Devel).
#
# Revision 1.5  2002/11/25 23:47:03  aepage
# A Perl debugger package is required to define a subroutine name 'sub'.
# This routine is a 'proxy' for handling subroutine calls and allows the
# debugger pacakage to track subroutine depth so that it can implement
# 'step over', 'step in' and 'return' functionality.  It must also
# handle the same context as the proxied routine; it must return a
# scalar where a scalar was being expected, an array where an array is
# being expected and a void where a void was being expected.  Ptkdb was
# not handling the case for void.  99.9% of the time this will have no
# ill effects although it is being handled incorrectly. Ref Programming
# Perl 3rd Edition pg 827
#
# Revision 1.4  2002/10/24 17:07:10  aepage
# fix for warning for undefined value assigend to typeglob during restart
#
# Revision 1.3  2002/10/20 23:49:51  aepage
#
# changed email address to aepage@ptkdb.sourceforge.net
#
# localized $^W in dbeval
#
# fix for instances where there is no code in a package.
#
# Initialized $self->{'subs_list_cnt'} in the new constructor to 0 to
# prevent warnings with -w.
#

package ptkdbTools;

use strict;

## class variables

my %decoTags;
my (%decoNames) = qw( $ scalar @ array % hash @$ derefarray %$ derefhash $$ derefscalar \& reftosub \@ reftoarray \% reftosub \$ reftoscalar * glob);
my (%decoTagsConfig) = qw( $ #006600 @ #0000CC % #0000CC @$ #0000CC %$ #0000CC $$ #0000CC \% #CC3300 \& #CC3300 \@ #CC3300 * #CC3300);

sub _clearLine { ## get rid of meaningless changes
	my ($rv) = @_;
	$rv =~ s/^\s+//;$rv =~ s/\s+$//;$rv =~ s/\s*#.*$//;
	$rv =~ s/\s+//g;
	return $rv
}
sub codeNormalize {
	my ($rv) = @_;
	$rv =~ s/^\W+//;
	$rv =~ s/\W+/ /g;
	return $rv
}

sub codeSimilarity { ## ## using variable or funktion names
	my ($a,$b) = @_;
	my $rv = 0;		# 1: similar ; at least one common name
	$a = codeNormalize($a);
	$b = codeNormalize($b);
	my @B = split/\s+/,$b;
	map {
		my $w =  $_;
		$rv++ if (grep $w eq $_,@B);
	} split(/\s+/,$a);
	return $rv ? 1 : 0
}


sub decorate {
	my $self = shift;
	my ($text,$items) = @_;
	DB::trace("decorate");
	unless(keys (%decoTags)) {
		DB::trace("init decoTags");
		map {
			$decoTags{$_} = $text->tag('configure', $decoNames{$_},-foreground, $decoTagsConfig{$_});
		} keys %decoTagsConfig;
		map {$text->tagLower($decoNames{$_})} keys %decoTagsConfig;
	}
#	map {
#		my $item = $_;
#		if ($item->[1]) {
#			$text->insert('end',$item->[0], $decoNames{$item->[1]});
#		} else {
#			$text->insert('end',$item->[0]);
#		}
#	} @$items;
	for(my $i = 1; $i < scalar(@$items);$i += 2) {
		$items->[$i] = ($items->[$i]) ? $decoNames{$items->[$i]} : '';
	}
	$text->insert('end',@$items);
}

sub decorateRemove { ## TODO : apply tagDelete for performance ?
	my $self = shift;
	my ($text) = @_;
	DB::trace("decorateRemove");
	map {
		$text->tagRemove($decoNames{$_},'1.0','end');
	} keys %decoNames;
	$text->update;
}

sub decorateReset {
	my $self = shift;
	my ($text) = @_;
	DB::trace("decorateReset");
	my @sel = $text->tagRanges('sel');
	my @stoppt = $text->tagRanges('stoppt');
	my @bookmark = $text->tagRanges('bookmark');
	my @breaksetLine = $text->tagRanges('breaksetLine');
	my @breakableLine = $text->tagRanges('breakableLine');
	my @nonbreakableLine = $text->tagRanges('nonbreakableLine');
	my @search_tag = $text->tagRanges('search_tag');

	my ($s) = $text->get('1.0','end');
	$text->delete('1.0','end');
	my $items = $self->parseVariables($s);
	$self->decorate($text,$items);
	while (@sel) {
		$text->tagAdd('sel',splice(@sel,0,2));
	}
	while (@stoppt) {
		$text->tagAdd('stoppt',splice(@stoppt,0,2));
	}
	while (@bookmark) {
		$text->tagAdd('bookmark',splice(@bookmark,0,2));
	}
	while (@nonbreakableLine) {
		$text->tagAdd('nonbreakableLine',splice(@nonbreakableLine,0,2));
	}
	while (@breakableLine) {
		$text->tagAdd('breakableLine',splice(@breakableLine,0,2));
	}
	while (@breaksetLine) {
		$text->tagAdd('breaksetLine',splice(@breaksetLine,0,2));
	}
	while(@search_tag) {
		$text->tagAdd('search_tag',splice(@search_tag,0,2));
	}
}

sub parseVariables { # return [[item, type],[item,type],...]] or []
	my $self = shift;
	my ($s) = @_;
	my $rv = [];
	my ($t,$else,$id) = ('','','');
	my $i =0;
	my $getVar = sub {
					while (1) {
						while (substr($s,$i,1) =~ /[0-9a-z_]/i) {
								$id .= substr($s,$i,1);
								$i++
						}
						if (substr($s,$i,2) eq '::') {
							$id .= substr($s,$i,2);
							$i += 2;
						} else {
							last
						}
					}
					push @$rv,($else,' ') if($else); $else = '';
					push @$rv,($id,$t)
					};
	if ($s) {
		while ($i < length $s) {
			if (substr($s,$i,1) =~ /[\$\@\%]/ ) {
				$t = substr($s,$i,1);
				if(substr($s,$i+1,1) eq '$') {
					$t .= substr($s,$i+1,1);
					$id = substr($s,$i,2);
					$i += 2;
					&$getVar();
				} elsif (substr($s,$i+1,1) =~ /[a-z_]/i ){
					$id = substr($s,$i,1);
					$i++;
					&$getVar();
				} else {
						$else .= substr($s,$i,1);
						$i++
				}
			} elsif (substr($s,$i,1) eq '*') {
					$t = substr($s,$i,1);
					if(substr($s,$i+1,1) =~ /[a-z_]/i ) {
						$id = substr($s,$i,1);
						$i++;
						&$getVar();
					} else {
						$else .= substr($s,$i,1);
						$i++
					}
			} elsif (substr($s,$i,1) eq '\\') {
				$t = substr($s,$i,1);
				if (substr($s,$i+1,1) =~ /[\$\@\%\&]/) {
					$t .= substr($s,$i+1,1);
					if(substr($s,$i+2,1) =~ /[a-z_]/i ) {
						$id = substr($s,$i,2);
						$i+=2;
						&$getVar();
					} else {
						$else .= substr($s,$i,3);
						$i+=3
					}
				} else {
						$else .= substr($s,$i,2);
						$i+=2
				}
			} else {
						$else .= substr($s,$i,1);
						$i++
			}
		}
		push @$rv,($else,' ') if $else;
	} # else {}
	return $rv ;
}

sub toHex { ## convert given arg to printable hex string X'...'
	my $self = shift;
	my $rv = 'X\'';
	foreach (split //,$_[0]) {
			$rv .= sprintf('%02X',ord($_))
	}
	$rv .='\'';
	return $rv
}

sub hexDump { ## hex dump utility function
	my $self = shift;
	my @retList ;
	my $width = 16 ;
	my $offset  ;
	my($len, $fmt, $n, @elems) ;

	my $printablestr = sub{ ## converts non printable chars to '.' for a string
		$_[0] =~ s/[\x00-\x1f\x80-\xff]/./g ; # performance!
		return $_[0]
		};

	for( @_ ) {
		my $str  ;
		$len = length $_ ;
		$offset = 0;
		$fmt = "\n%04X  " . ("%02X " x $width ) . " %s";
		while($len) {
			$n = ($len >= $width) ? $width : $len ;
			$fmt = "\n%04X  " . ("%02X " x $n ) . ( '   ' x ($width - $n) ) . " %s" if ($width - $n);
			@elems = map ord, split //, (substr $_, $offset, $n) ;
			$str .= sprintf($fmt, $offset, @elems, &$printablestr(substr $_, $offset, $n)) ;
			$offset += $width ;
			$len -= $n ;
		} # end while
		push @retList, $str ;
	} # for

	return (wantarray) ? @retList: $retList[0];
} # end of hexDump

sub parseStmt {     ## parse variable's names in the given string
	##                     return a list of names
	## open : $x = 'uu'; eval "$a = '$x'" ; print $a -> 'xx' or '$x'
	##
	## TODO: - sprintf format string
	##       - regexp
	my $self = shift;
	my ($s,$quoted) = @_;
	$quoted = 0 unless defined $quoted;

	return wantarray ? () : 0 unless $s;

	my $syn = sub { ## ${a} is synonym of $a
		my $rv = shift;
		if ($rv =~ /\$\{/) {
			$rv =~ s/\$\{/\$/;
			$rv =~ s/\}$//;
		} elsif($rv =~ /\%\{/) {
			$rv =~ s/\%\{/\%/;
			$rv =~ s/\}$//;
		}elsif($rv =~ /\@\{/) {
			$rv =~ s/\@\{/\@/;
			$rv =~ s/\}$//;
		} ## else {} intentionally left empty
		return $rv;
	};

	my ($READNEXT,$ID,$STRING,$DSTRING,$COMMENT,$SKIPID,$ANON,$END,$QUOTE,$QUOTEI)=(1,2,4,8,16,32,64,128,256,512);

	my @rv     = ();
	my $id      = '';
	my $dString ='';
	my $i       = -1;
	my $c       = '';

	my $state= $READNEXT; ## 1:read next ; 2 : id ; 4 : string
	my $nextChar  = sub {return ($i < length($s)) ? substr($s,$i+1,1) : undef};
	my $getChar   = sub {$i++; return ($i < length($s)) ? substr($s,$i,1) : undef} ;
	my $ungetChar = sub {$i-- if ($i)} ;

	my $readnext  = sub {
	if ($c =~/\s/) {
		## skip white space
	} elsif ($c eq '$') {
		$id = $c;
		$c = &$getChar();
		do { $state = $END; return 1} unless defined $c;
		if ($c =~ /[\$\#]/ ) { ## $$xyz or $#array
			$id.= $c;
		} elsif ( $c =~ /[\@\_]/) { ## PERL special variables
			$id.= $c;
		} elsif ($c eq '{') {
			$id.= $c;            ## ${a} is equivalent to $a
		} else {
			&$ungetChar();
		}
		$state = $ID
	} elsif ($c =~ /[\@\%]/ ){ ## i.e. @a or %h
		$id = $c;
		$c = &$getChar();
		do { $state = $END; return 1} unless defined $c;
		if ($c eq '$') { ## i.e. %$xyz
			$id .= $c;
			$state = $ID;
		} elsif ($c =~ /[_a-z]/i){
			$id .= $c;
			$state = $ID;
		} elsif ($c eq '{') {
			$id.= $c;        ## @{a} equivalent to @a
			$state = $ID;
		} else {         ## i.e. %04d
			&$ungetChar();
			$id = '';
			$state = $READNEXT;
		}
	} elsif ($c eq '\'' && !$quoted){ ## $a = 'xxx'
			$state = $STRING;
			$id = '';
	} elsif ($c eq '"' ){ ## $a ="xxx"
			$state = $DSTRING;
			$dString = '';
	} elsif ($c eq 'q') {
		$id = $c;
		if (&$nextChar() =~ /[wqrx\(\/\{\s]/) { ## qw/ .../
			$id.=$c;
			$state = $QUOTE;
		} else {
			$id=$c;
			$state=$SKIPID; ## i.e qu(...)
		}
	} elsif ($c =~/[_a-z]/i) { ## i.e. main::doSomething()
			## TODO check reserved words i.e. do for while ....
			$id = $c;
			$state = $SKIPID
	} elsif ($c =~/[&]/) { ## i.e. &main::doSomething()
			if (&$nextChar() =~ /\w/ ) {
				$id= '';
				$state = $ID;
			} else { }
	} elsif ($c =~/\\/) { ## i.e. \@a
			if (&$nextChar() =~ /[\$\@\%\&]/) {
				##
			} elsif (&$nextChar() =~ /[nrt]/) { # char constant
					&$getChar(); # skip it
			} else {}
	} elsif ($c eq '#') { ## comment
			$state = $COMMENT
	} else {
		## go on
	}
	return 1;
	}; ## end readnext

	my $quote = sub { ## parse q/STRING/ qq/STRING/ qr/STRING/ qx/STRING/ qw/STRING/

					  ##	Customary  Generic        Meaning        Interpolates
					  ##		''       q{}          Literal             no
					  ##		""      qq{}          Literal             yes
					  ##		``      qx{}          Command             yes*
					  ##				qw{}         Word list            no
					  ##		//       m{}       Pattern match          yes*
					  ##				qr{}          Pattern             yes*
					  ##				 s{}{}      Substitution          yes*
					  ##				tr{}{}    Transliteration         no (but see below)

		if ($c =~ /[qw]/) { ## no interpolation
			$id .= $c;
		} elsif ($c =~ /[rx]/) { ## interpolation , parse for variables
			$id .= $c;
			$state = $QUOTEI; ## temp
		} elsif ($c =~ /\s/) {
			## simply skip it
		} elsif ($c =~ /[\/\(\{]/) {
			# q/ /
			my $dlm = ($c eq '/') ? '/' :
							($c eq '(') ? ')' : '}';
			my $qString = '';
			while (defined ($c = &$getChar)) {
				last if ( $c eq $dlm);
				$qString .= $c
			}
			# temp : qString is irrelevant for now
			$id = '';
			$state = $READNEXT;
		} else {
			$id .= $c;
			$state = $SKIPID; ## temp
		}
	}; ## end quote

	my $quotei = sub { ## parse qr() and qx()
		if ($c =~/\s/) {
			## simply skip it
		} elsif ($c =~ /[\/\(\{]/) {
			# qr/ /
			my $dlm = ($c eq '/') ? '/' :
							($c eq '(') ? ')' : '}';
			my $qString = '';
			while (defined ($c = &$getChar)) {
				last if ( $c eq $dlm);
				$qString .= $c;
			}
			# qString may contain variables
			my @v = $self->parseStmt($qString) if ($qString);
			map {
				my $var = $_;
				push @rv, $var unless (grep($var eq $_,@rv) || $var =~ /^[\$\@\%]$/);
			} @v;
			$id='';
			if (defined $c) {
				$state = $READNEXT;
			} else {
				$id = ''; ## forget it
				$state = $END; ## and terminate
			}
		} else {
			$id .= $c;
			$state = $SKIPID; ## temp
		}
	}; ## end quotei

	my $xid = sub {
	if ($c =~ /[\w]/) {
		$id .= $c
	} elsif ($c eq ':') {
			$c = &$getChar();
			do { $state = $END; return 1} unless defined $c;
			if ($c eq ':') {
				$id .= "$c$c";
			} else {
				&$ungetChar();
				$id = &$syn($id);
				push @rv,$id unless (grep($id eq $_,@rv) || $id =~ /^[\$\@\%]$/);
				$id = '';
				$state = $READNEXT;
			}
	} elsif ($c =~ /\s/) {
		while (defined ($c = &$getChar)) {
			last unless ( $c =~ /\s/);
		}
		if (defined($c)) {
			if ($c =~ /[\[\{]/) {
				&$ungetChar();
			} else {
				&$ungetChar();
				$id = &$syn($id);
				push @rv,$id unless (grep($id eq $_,@rv) || $id =~ /^[\$\@\%]$/);
				$id = '';
				$state = $READNEXT;
			}
		} else {
			if ($id) {
				$id = &$syn($id);
				push @rv,$id unless (grep($id eq $_,@rv) || $id =~ /^[\$\@\%]$/);
			}
			$state = $END;
		}
	} elsif ($c =~ /[\[\{]/) {
		my $dlm1 = $c;
		my $dlm = ($dlm1 eq '[') ? ']' : '}';
		my $expr = '';
		while (defined ($c = &$getChar)) {
			last if ( $c eq $dlm);
			$expr .= $c
		}
		my @v = $self->parseStmt($expr) if ($expr);
		map {
			my $var = $_;
			push @rv, $var unless (grep($var eq $_,@rv) || $var =~ /^[\$\@\%]$/);
		} @v;
		if (defined $c) {
				$id =~ s/^\$/@/ if($dlm1 eq '[');
				$id =~ s/^\$/%/ if($dlm1 eq '{');
				$id = &$syn($id);
				push @rv,$id unless (grep($id eq $_,@rv) || $id =~ /^[\$\@\%]$/);
				$id = '';
				$state = $READNEXT;
		} else {
				$id = ''; ## forget it
				$state = $END; ## and
		}
	} elsif($c =~ /[\$\@\%]/) {
		$id = &$syn($id);
		push @rv,$id unless (grep($id eq $_,@rv) || $id =~ /^[\$\@\%]$/);
		$id = $c;
	} elsif ($c =~ /\s/) {
		while (defined ($c = &$getChar)) {
			last unless ( $c =~ /\s/);
		}
		if (defined $c) {
			if ($c eq '-' && &$nextChar eq '>') {
				$id .= '->';
				$c=&$getChar;
			} elsif ($c eq '[' || $c eq '{') {
				$id .= $c
			} elsif ($c eq ']' || $c eq '}') {
				$id .= $c;
				$id = &$syn($id);
				push @rv,$id unless (grep($id eq $_,@rv) || $id =~ /^[\$\@\%]$/);
				$id = '';
				$state = $READNEXT;
			} else {
				$id .= $c;
			}
		} else {
			$id = &$syn($id);
			push @rv,$id unless (grep($id eq $_,@rv) || $id =~ /^[\$\@\%]$/);
			$id = '';
			$state = $END;
		}
	} else {
		$id = &$syn($id);
		push @rv,$id unless(grep($id eq $_,@rv) || $id =~ /^[\$\@\%]$/);
		$id = '';
		$state = $READNEXT;
	}
	return 1
	}; ## end xid

	my $skipid = sub {
	if ($c =~ /\W/) {
		if ($id eq 'sub') {
			## skip anonimous block
			while (defined ($c = &$getChar)) {
				last unless ( $c =~ /\s/);
			}
			if ($c eq '{') {
				$state = $ANON;
				$id = '';
			} else {
				&$ungetChar();
				$state = $READNEXT;
			}
		} else {
			$id = '';
			$state = $READNEXT;
			&$ungetChar();
		}
	} else {
		$id .= $c;
	}
	return 1
	}; ## end skipid

	my $anon = sub { ## anonimous block
		if ($c eq '}' ) {
			$state = $READNEXT;
		} else {
		}
	}; ## end anon

	my $string = sub { ## single quoted string, no interpolation
		return 1 if ($c eq '\\'&& &$nextChar eq '\'');
		$state = $READNEXT if ($c eq '\'' );
	return 1;
	};      ## end string

	my $dstring = sub { ## double quoted string, parse variables
	return 1 if ($c eq '\\' && &$nextChar eq '"');
	if ($c eq '"' ) {
			$state = $READNEXT ;
			my @w = $self->parseStmt($dString,1); ## set 'quoted string' is passed to
			map {
				my $n = $_;
				push @rv,$n unless (grep($n eq $_,@rv) || $n =~ /^[\$\@\%]$/);
			} @w;
			$dString = '';
	} else {
			$dString .= $c;
	}
	return 1;
	}; ## end dstring

	while(defined($c = &$getChar())) { ## mainline
		if ($state == $READNEXT) {
			&$readnext();
		} elsif ($state == $ID) {
			&$xid();
		} elsif($state == $SKIPID) {
			&$skipid();
		} elsif ($state == $STRING) {
			&$string();
		} elsif ($state == $DSTRING) {
			&$dstring();
		} elsif($state == $COMMENT) {
			last;
		} elsif ($state == $ANON) {
			&$anon();
		} elsif ($state == $END) {
			last;
		} elsif ($state == $QUOTE) {
			&$quote();
		} elsif ($state == $QUOTEI) {
			&$quotei();
		} else {
			die "ptkdb - parseStmt, Unknown state '$state'";
		}
	}
	push @rv,$id  if($id && !grep($id eq $_,@rv) && $id !~ /^[\$\@\%]$/);

	return wantarray ? @rv : scalar(@rv);
} ## end of parseStmt

sub checkIfCall { # do not accept expr like &main::help() , $xyz->method() , main::subr
	my $self = shift;
	my ($expr) = @_;
	my $rv = 0;  ## 1: expr is scall or message
	##
	$rv = 1 if ($expr =~ /^\s*(([\w:]+)|(&[\w:]+)|(\$\w+\s*->\s*\w+))/i);
	return $rv
}

#
#
#	Returns a quoted string if the given string contains white spaces.
#
#	Example : ptkdbTools->qq('test doc') yields '"test doc"'
#             ptkdbTools->qq('testdoc') yields 'testdoc'
#
#

sub qq {
	my $self = shift;
	my ($s) = @_;
	$s = '' unless defined $s;
	my $rv = $s;
	return $rv if ($s =~/^"[^"]*"$/);
	$rv = ($s =~/\s/) ? '"'.$s.'"' : $s;
	return $rv
}

sub decode {
	my ($ref) = @_;
	my $rv;
	## TODO dialog to enter options
	return 'UNDEF' unless(defined($ref));
	return ref($ref) unless(ref($ref) eq 'CODE');
	use B::Deparse;
	my $dep = B::Deparse->new('-d','-p', '-sCi4T');
	return undef unless $dep;
	$dep->ambient_pragmas(qw/strict all warnings all/);
	$rv = $dep->coderef2text($ref) ;
	return $rv;
}

1; ## eof ptkdbTools

package ptkdbFilter;
{

use strict;

# The breakpoint filter allows the user to specify conditions that must match to
# to generate breakpoints while stepping thru the process.
# Of course, breakpoints set manually aren't affected by the filter.
#
# This class provides most of the functionality of the breakpoint filter
# excluding the execution of the filter conditions themselves.
# This processing must be done in the package DB itself in order to execute
# correctly the DB::dbeval of the logical expressions .
# See DB::brkptFilter.
#

my %defaultParam = (
	'action' , '1',         ## 1: set breakpoint , 2: trace
	'expr' , '',            ## no expression
	'fname' , "$0",         ## started script
	'lineno' , 1,           ## line 1
	'package' ,'main',      ## package main
	'state' , 0,			## 1: active 0: disabled (default 0)
	'error',' '             ## error message
	);

my %param = %defaultParam;

my $defaultActions = [
	['fname' , sub {1} ],
	['package', sub {1}],
	['lineno',  sub{1}],
	['expr' , sub{1}]
	];

my $action = [@$defaultActions];

sub defaultParam {
	return %defaultParam;
}
sub defaultActions {
	return (wantarray()) ? @$defaultActions : scalar(@$defaultActions);
}
sub param {
	return \%param
}
sub empty {
	my $self = shift;
	my $param = ptkdbFilter->param();
	return undef unless exists $param->{$_[0]};
	return $param->{$_[0]} =~ /^\s*$/
}

sub active {
	my $self = shift;
	ptkdbFilter->param()->{'state'} = $_[0] if(@_);
	return ptkdbFilter->param()->{'state'}
}
sub activate {
	shift->active(1);
}
sub deactivate {
	shift->active(0);
}
sub action {
	return $action
}
sub setParam {
	my $self = shift;
	my ($r) = @_;
	return unless(defined($r) && ref($r) eq 'HASH'); ## precondition
	map {
		$param{$_} = $r->{$_} if(exists($defaultParam{$_}));
	} keys %$r
}
sub switchFilter {
	if (ptkdbFilter->active()) {
			ptkdbFilter->deactivate();
	} else {
			ptkdbFilter->activate();
	}
	$DB::window->setStatus0();
}
sub validate {
	my $self = shift;
	my ($param) = (@_);
	my $rv = 0;
	my $action = [$self->defaultActions()];
	$param = $self->param() unless(defined($param));
	$action ->[0]->[1] = sub {1};
	$action ->[1]->[1] = sub {1};
	$action ->[2]->[1]= sub {my $x = shift;($param->{$x} =~ /^\s*\d+\s*$/) ? 1 : 0 };
	$action ->[3]->[1]= sub {my $x = shift;eval "{no strict; $param->{$x}}";$param->{'error'}=$@;return ($@) ? 0 : 1} ;

	for (@$action) {
		last unless ($rv = &{$_->[1]}($_->[0]));
	}
	return $rv
}

sub dlg_getFilter { ## gen by clickTk 4.24
	my $self = shift;
	my ($hwnd) = @_;
	require Tk::LabFrame;
	my $rv;
	my ($param,$action,$expr,$fname,$lineno,$package,$state);

	my($wr_001,$wr_004,$wr_005,$wr_006,$wr_008,
	$wr_009,$wr_010,$wr_011,$wr_012,$wr_013,
	$wr_014,$wr_015,$wr_016,$wr_017,$wr_018);

	my $mw = $hwnd->DialogBox(
		-title=> 'ptkdb - breakpoint filter',
		-buttons=> [qw(OK Cancel)]);

	$param = $self->param();

	$action  = $param->{'action'} ;
	$expr    = $param->{'expr'}   ;
	$fname   = $param->{'fname'}  ;
	$lineno  = $param->{'lineno'} ;
	$package = $param->{'package'};
	$state   = $param->{'state'}  ;

	## ctk: widgets generated using treewalk D
	$wr_001 = $mw -> LabFrame (  -label , 'Conditions' , -relief , 'sunken' , -labelside , 'acrosstop'  ) -> pack(-side=>'top', -anchor=>'nw', -pady=>5, -fill=>'both', -expand=>1, -padx=>5);
	$wr_008 = $mw -> LabFrame (  -label , 'Action' , -relief , 'sunken' , -labelside , 'acrosstop'   ) -> pack(-side=>'top', -anchor=>'nw', -pady=>5, -fill=>'both', -expand=>1, -padx=>5);
	$wr_012 = $mw -> LabFrame (  -label , 'State' , -relief , 'sunken' , -labelside , 'acrosstop'  ) -> pack(-side=>'top', -anchor=>'nw', -ipady=>5, -fill=>'both', -expand=>1, -padx=>5);
	$wr_018 = $mw -> Label (   -anchor , 'w' , -relief , 'sunken',-text ,'Ready.' , -justify , 'left' ) -> pack(-side=>'bottom', -anchor=>'sw', -fill=>'both', -expand=>1,-ipady,5,-padx,5);
	$wr_013 = $wr_012 -> Checkbutton ( -relief , 'flat' , -variable , \$state , -anchor , 'nw' , -justify , 'left' , -text , 'Active' , -onvalue , 1  ) -> pack(-side=>'top', -anchor=>'nw', -fill=>'x', -expand=>1);
	$wr_010 = $wr_008 -> Checkbutton ( -relief , 'flat' , -variable , \$action , -anchor , 'nw' , -justify , 'left' , -text , 'Breakpoint' , -onvalue , 1  ) -> pack(-side=>'top', -anchor=>'nw', -fill=>'x');
	$wr_011 = $wr_008 -> Checkbutton ( -relief , 'flat' , -variable , \$action , -anchor , 'nw' , -justify , 'left' , -text , 'Trace' , -onvalue , 2  ) -> pack(-side=>'top', -anchor=>'nw', -fill=>'x');
	$wr_014 = $wr_001 -> Label ( -text , 'File name :' , -justify , 'right' , -anchor , 'e' ) -> grid(-row=>0, -column=>0, -sticky=>'nsew');
	$wr_004 = $wr_001 -> Entry ( -relief , 'sunken' , -textvariable , \$fname , -background , '#ffffff' ) -> grid(-row=>0, -column=>1, -sticky=>'nsew');
	$wr_015 = $wr_001 -> Label ( -text, 'Package :' , -justify , 'right' ,-anchor , 'e'  ) -> grid(-row=>1, -column=>0, -sticky=>'nsew');
	$wr_005 = $wr_001 -> Entry ( -relief , 'sunken' , -textvariable , \$package , -background , '#ffffff' ) -> grid(-row=>1, -column=>1, -sticky=>'nsew');
	$wr_016 = $wr_001 -> Label ( -text , 'Line number from :' , -justify , 'right' ,-anchor , 'e'   ) -> grid(-row=>2, -column=>0, -sticky=>'nsew');
	$wr_006 = $wr_001 -> Entry ( -relief , 'sunken' , -textvariable , \$lineno , -background , '#ffffff' ) -> grid(-row=>2, -column=>1, -sticky=>'nsew');
	$wr_017 = $wr_001 -> Label ( -text, 'Expression :' , -justify , 'right' ,-anchor , 'e'   ) -> grid(-row=>3, -column=>0, -sticky=>'nsew');
	$wr_009 = $wr_001 -> Entry ( -relief , 'sunken' , -textvariable , \$expr , -background , '#ffffff' ) -> grid(-row=>3, -column=>1, -sticky=>'nsew');
	$mw->protocol('WM_DELETE_WINDOW',sub{$mw->Subwidget('B_Cancel')->invoke()});
	## ctk: end of gened Tk-code
	while(1) {
		$rv =  $mw->Show();
		if ($rv =~ /^ok/i ) {
			my %wParam = $self->defaultParam;
			$wParam{'action'}  = $action ;
			$wParam{'expr'}    = $expr   ;
			$wParam{'fname'}   = $fname  ;
			$wParam{'lineno'}  = $lineno ;
			$wParam{'package'} = $package;
			$wParam{'state'}   = $state  ;
			$wParam{'error'}   = '';
			if ($self->validate(\%wParam)){
				map {
					$param->{$_} = $wParam{$_}
				} keys %wParam;
				$DB::window->setStatus0();
				$rv = 1;
				last;
			} else {
				# $wParam{'error'} =~ s/\n//g;
				# $wr_018->configure(-text,$wParam{'error'});
				$wr_018->configure(-text,"Invalid definitions , pls check input.");
				$hwnd->update();
			}
		} elsif ($rv =~ /^cancel/i ) {
			$rv = 0;
			last;
		} else {
			$rv = undef;
			last;
		}
	} ## dialog loop
	return $rv;
} ## end of dlg_getFilter

1; ## eof ptkdbFilter
}
package ptkdb_arglistEditor;
{

require Tk::Derived;
@ptkdb_arglistEditor::ISA = qw(Tk::Derived Tk::Frame);
Construct Tk::Widget 'ptkdb_arglistEditor';
my (@arglist,@children,$result );
sub ClassInit {
	my $self = shift;
$self->SUPER::ClassInit(@_);
}
sub Populate {
	my ($self,$args) = @_;
	$self->SUPER::Populate($self->arglist($args));
my $mw = $self;
my ($wr_001,$wr_002);

$wr_001 = $mw -> Frame ( -borderwidth , 1 , -relief , 'sunken'  ) -> pack(-side=>'top', -anchor=>'nw', -pady=>5, -fill=>'both', -expand=>1, -padx=>5);
$wr_002 = $mw -> Frame ( -borderwidth , 0 , -relief , 'flat'  ) -> pack(-side=>'top', -anchor=>'nw', -fill=>'x', -expand=>1);
$wr_002 -> Button ( -underline , 0 , -state , 'normal' , -text , 'Reset', -command , [\&reset,$self] ) -> pack(-side=>'left', -anchor=>'w', -pady=>5, -fill=>'x', -expand=>1, -padx=>5);
$self->Advertise('frame'=>$wr_001);
$self->refreshGrid(@arglist);
	$result=undef;
	return $self;
}
sub destroy {
	DESTROY();
}

sub arglist {
my $self=shift;
my $args = shift;
	return $args unless exists $args->{-arglist};
	my $w = delete $args->{-arglist};
	if (@$w) {
		@arglist= ();
		map {
			push @arglist,$_
		} @$w;
	} else {
		@arglist= ('');
	}
	return $args
}

sub saveContent {
	my $self = shift;
	my @w = ();
	map {
		push @w,$_->get();
	} @children;
	return (wantarray) ? @w : scalar(@w)
}

sub refreshGrid {
	my $self = shift;
	my (@arglist) = @_;

	my ($wr_001,$wr_004);
	my $wr_001 = $self->Subwidget('frame');
	map {
		$_->destroy()
		} $wr_001->children();
	@children=();
	for(my $i=0;$i<= $#arglist;$i++) {
		$wr_001 -> Label ( -underline , 0 , -relief , 'flat' , -justify , 'left' , -text , "arglist item $i"  ) -> grid(-row=>$i, -pady=>5, -padx=>5, -column=>0, -sticky=>'nsew');
		$wr_004 = $wr_001 -> Entry ( -relief , 'sunken' , -state , 'normal' , -width , 64 , -justify , 'left'  ) -> grid(-row=>$i, -pady=>5, -padx=>5, -column=>1, -sticky=>'nsew');
		$wr_004->insert('end',$arglist[$i]);
		push @children,$wr_004;
		$wr_001->Button( -relief , 'raised' , -state , 'normal' , -text , "del" , -command , [\&delete,$self,"$i"]) -> grid(-row=>$i, -pady=>5, -padx=>5, -column=>2, -sticky=>'nsew');
		$wr_001->Button( -relief , 'raised' , -state , 'normal' , -text , "ins", -command , [\&insert,$self,"$i"] ) -> grid(-row=>$i, -pady=>5, -padx=>5, -column=>3, -sticky=>'nsew');
	}
	return 1
}

sub getArglist {
	return wantarray ? @arglist : scalar(@arglist)
}

sub getResult {
	return $result
}
sub ok {
	my $self=shift;
	@arglist=();
	for (0 .. $#children) {
		my $w = $children[$_];
		push @arglist,$w->get();
	}
	@children = ();
	$result = 1;
}
sub cancel {
	my $self=shift;
	@arglist=();
	$result = 0;
	@children = ();
	@arglist = ();
}
sub reset {
	my $self=shift;
	my $wr_001 = $self->Subwidget('frame');
	map {
		$_->destroy()
		} $wr_001->children();
	@children=();
	$self->refreshGrid(@arglist);
	return 1
}

sub delete {
	my $self=shift;
	my ($i) = @_;
	my @w = $self->saveContent();
	splice @w,$i,1;
	$self->refreshGrid(@w);
}
sub insert {
	my $self=shift;
	my ($i) = @_;
	my @w = $self->saveContent();
	splice @w,$i,0,'';
	$self->refreshGrid(@w);
}
1;
}
__END__

=head1 NAME

Devel::ptkdb - Perl debugger using a Tk GUI

ptkdb version 1.234

=head1 SYNOPSIS

To debug a script using ptkdb invoke Perl like this:

	perl <option> <script>

where

	<option> is  either  -d:ptkdb  or  -dt:ptkdb
	<script> is the file name to be debugged.

Example: start a debugging session of myScript.pl with multithreading support

	perl -dt:ptkdb myScript.pl

=head1 DESCRIPTION

ptkdb is a source debugger for Perl scripts that uses perlTk for a user interface.

It provides a wide spectrum of functionalities

=over

=item Source Code Debugging

=item Auto-stepping

=item Unconditional and Conditional Breakpoints

=item Temporary Breakpoints

=item Hot Variable Inspection

=item Proximity window

=item Breakpoint Control Panel

=item Expression List

=item Expression Evaluation Window

=item Package and Subroutine Tree

=item Breakpoint trace

=item Breakpoint filter

=item Customization by file .ptkdbrc and by Environment Variables

=item Full session control : Save, Restore and Restart

=item Persistent Bookmarks

=back

=head1 The Main Window

The main window consists of three major elements:

=over

=item the header which cantains the menu, the toolbar menu and the statusbar,

=item the code pane and

=item the notebook pane which contains four pages:

=over

=item the data page,

=item the sub page,

=item the breakpoint page,

=item the log page.

=back

=back

=head2 The Code Pane

The code pane shows the source code of the script or module currently debugged.
Moreover you may display in this pane any module by means of the menu item File/open.
The goals of this pane are first of all to show the progress of the debugging session,
then set breakpoint on code lines and finally to inspect quickly and easy the content of variables.

=over 4

=item The Line Numbers

Line numbers are presented on the left side of the window. Lines that
have lines through them are not breakable. Lines that are plain text
are breakable. Clicking on these line numbers will insert a
breakpoint on that line and change the line number color to
$ENV{'PTKDB_BRKPT_COLOR'} (Defaults to Red). Clicking on the number
again will remove the breakpoint.  If you disable the breakpoint with
the controls on the BrkPt notebook page the color will change to
$ENV{'PTKDB_DISABLEDBRKPT_COLOR'}(Defaults to Green).

=item The Cursor Motion

If you place the cursor over a variable or select it (i.e. $myVar, @myVar,
%myVar or even $main::myvar) and pause for a while, ptkdb will evaluate the current
value of the variable and pop a balloon up with the evaluated result.

The option PTKDB_BALLOON allow you to activate or deactivate this function.
This may be useful on variables which store huge amount of data.
The display of such variables may take lot of time and therefore considerably slow down
the flow of the debugging session.

The option PTKDB_BALLOON_TIME specify the delay in millisec of the pause.

I<This feature is not available with Tk400.>

If Data::Dumper(standard with perl5.00502)is available it will be used
to format the result.  If there is an active selection, the text of
that selection will be evaluated.
This may be useful , when th variable you want to inspect
is on a non-breakable line.

Please note that this feature applies only to variables.
If you want to inspect expression then select the expression and copy/past it into the
quick expression window.

Please remember that the balloon always will cut the displayed data down
to PTKDB_BALLOON_MSG_MAX_LENGTH characters.

=back

=head2 The Notebook Pane

The Notebook pane contains these pages :

	- Expression's page          'Exprs',
	- Packages and subroutines   'Sub',
	- Breakpoints definitions    'BrkPts',
	- ptkdb log items            'Log'.

=over

=item Expression's page 'Exprs'

This page contains three frames:

The 'expression frame', the 'proximity frame' and the 'quick expression frame'.

All frames have the same format and therefore may be navigated in the same way.
Nevertheless, the proximity frame is a display-only form
which unlike the exprs frame cannot be manipulated.
Both frames are always shown, although the parsing of the proximity is deactivated.
In this case it can be reduced to a minimal size with the separating adjuster.

=over

=item The expression frame

This is a list of expressions (mostly called watched-expressions)
that are evaluated each time the debugger stops.
The results of the expresssion are presented hierarchically for expression that result in hashes or lists.
Double clicking on such an expression will cause it to collapse; double
clicking again will cause the expression to expand. Expressions are
entered through B<Enter Expr> entry, or by Alt-E when text is
selected in the code pane.

=item The proximity frame

This frame shows the content of the variables at the line of the current breakpoint.

=item The quick expression frame

This frame contains an entry which will take an expression, evaluate it, and
replace the entries contents with the result.

=back

=item Packages and Subroutines 'Sub'

This page displays the hierarchical list of all the packages invoked with the script.
At the bottom of the hierarchy are the subroutines within the packages.
A <Double click> is used to
	- open/close a package,
	- show a subroutine in the code pane.
Subroutines are listed by their full package names.
The content of the list is related to the processing flow of the debugged script.
Therefore, required scripts are added to the list just after the execution of the require statement.

=item Breakpoints definitions 'BrkPts'

This page presents a list of the breakpoints current in use. The pushbutton
allows a breakpoint to be 'disabled' without removing it. Expressions
can be applied to the breakpoint.  If the expression evaluates to be
'true'(results in a defined value that is not 0) the debugger will
stop the script.  Pressing the 'Goto' button will set the text pane
to that file and line where the breakpoint is set.  Pressing the
'Delete' button will delete the breakpoint.

=item ptkdb log items 'Log'

Displays the ptkdb log items. This page is optional and depends on the options
PTKDB_VERBOSE, which suppress the log items at all, and PTKDB_USE_LOG_PAGE.

=back

=head1 The Header

=head2 The Menu

=head3 File Menu

=over

=item About...

Presents a dialog box telling you about the version of ptkdb.  It
recovers your OS name, version of Perl, version of Tk, and some other
information

=item Open

Presents a list of files that are part of the invoked Perl
script. Selecting a file from this list will present this file in the
text window.

=item Save Config...

Requires Data::Dumper. Prompts for a filename to save the
configuration to. Saves the breakpoints, expressions, eval text and
window geometry. If the name given as the default is used and the
script is reinvoked, this configuration will be reloaded
automatically.

B<NOTE:>  You may find this preferable to using

=item Restore Config...

Requires Data::Dumper.  Prompts for a filename to restore a configuration saved with
the "Save Config..." menu item.

=item Goto Line...

Prompts for a line number.  Pressing the "OK" button sends the window to the line number entered.

=item Find Text...

Prompts for text to search for.  Options include forward search,
backwards search, and regular expression searching.

=item Tabs

Set a list of tab positions for the code pane.

=item Close windows and Run

Close the debugger's main windows and continue the process.
This function requires that all breakpoint has been  previously cleared
by means of Control/Clear All breakpoints .

=item Quit

Causes the debugger to terminate the debugging session.

=back

=head3 Control Menu

=over

=item Run

The debugger allows the script to run to the next breakpoint or until the script exits.
Note: if the breakpoint filter is active, then it get automatically deactivated. In fact the filter does not  work
after a run command. Thus, the filter should be deactivated in order to avoid confusion.

=item Run To Here

Runs the debugger until it comes to wherever the insertion cursor is placed in text window .
Note: if the breakpoint filter is active, then this command deactivates it automatically.

=item Pass Thru

Instructs ptkdb to deactivate all breakpoints of the current file and then to run the script.
Note: if the breakpoint filter is active, then this command deactivates it automatically.

=item Enter breakpoint filter conditions

while stepping in/over the breakpoint filter allows to do an action
on each step depending on a set of conditions. When all given conditions meet,
then the action is done. Currently, the action may be either a breakpoint or an entry in the DB-trace.
The filter itself may be activated/deactivated at any time during the debugging session.
The conditions are:
the file name, the package name, the line number and an boolean expression.
Defined breakpoints are not affected by the filter.
The filter arguments remain valid while the debugging session and are propagated on session restart.

NOTES

- when you enter the filter conditions at a breakpoint, and conditions never meet
on the next breakpoints, then the debbugged script either runs to end or
to the next defined unconditional breakpoint.
Unfortunately, there is no way to resume the debugging session at the starting breakpoint
during the current debugging session.
To do that, the session must be first restarted and then repositioned manually
setting the starting breakpoint again.

- the filter mechanism doesn't work when the debugging session continues
by means of any 'run' command ('run', 'run to', 'return').

- usually the filter get used to force a breakpoint during the process between two unconditional breakpoints, typically
on iterations or recursions.

- the filter starts working just at the time the session is continued by means of 'step in' or 'step over'.

=item Switch breakpoint filter

This menu item allows to activate or deactivate the current breakpoint filter.
Of course, the filter conditions remain unchanged.

=item Set Breakpoint

This menu item sets a breakpoint on the line at the insertion cursor.
You may specify a breakpoint condition in the expression entry.

=item Clear Breakpoint

This menu item removes a breakpoint on the at the insertion cursor.

=item Clear All Breakpoints

This menu item removes all breakpoints of the current file actually defined.

=item Activate All Breakpoints

This menu item activates all breakpoints of the current file.

=item Deactivate All Breakpoints

This menu item deactivates all current breakpoints of the current file.

=item Event mask

This menu item opens the dialog to enter the event mask for the mainloop
of ptkdb itself. This may be important for applications which deal with
asynchronous callbacks which has been set i.e. by means of the module After.

Default value is 'ALL', which allows all kinds of TK-Events.

=item Step Over

Causes the debugger to step over the next line.  If the line is a
subroutine call it steps over the call, stopping when the subroutine
returns.

=item Step In

Causes the debugger to step into the next line.  If the line is a
subroutine call it steps into the subroutine, stopping at the first
executable line within the subroutine.

=item Autostep

This item immediately turns on/off the autostep mode.

Remember:

- the autostep mode is automatically turned off when
  the commands 'run' , 'return' , 'run to'  or  'quit' are entered.

- the autostep mode is also reset to off when a request is entered
  to evaluate an expression, a watched expression is added or deleted or the
  expression evaluation window is open.

- once the autostep mode is turned on, the next 'step in' or 'step over'
  shall start the stepping through.

- unconditional breakpoints always stop the stepping through, automatically
  resetting the austostep mode off.

=item Set autostep delay time

This item sets up the dialog to change the value of the autostep delay time.
This value defines the speed of the auto-stepping flow.

=item Return

Runs the script until it returns from the currently executing
subroutine.

=item Restart

Saves the breakpoints and expressions in a temporary file and restarts
the script from the beginning.
Doing that it first issues a modal dialog to stop the process, then it
rebuilds the command line arguments and finally it restart the session by means of an exec statement.
This stop allows the user to modify the command line arguments, do some actions to restore test data
on disks, which possibly has been changed during the debugging session.
(See also chapter FILES , items  'register_user_window_init' and 'register_user_window_end').

CAUTION: This feature will not work properly on debugging sessions of CGI Scripts.

=item Stop On Warning

When C<-w> is enabled the debugger will stop when warnings such as, "Use
of uninitialized value at undef_warn.pl line N" are encountered.  The debugger
will stop on the NEXT line of execution since the error can't be detected
until the current line has executed.

This feature can be turned on at startup by adding:

	$DB::ptkdb::stop_on_warning = 1 ;

to a .ptkdbrc file

=item Allow calls/messages on expr

This options prevents the watching of expression like &main::thisSub() which
may corrupt the test environment when called at each breakpoint.
Since ptkdb cannot analyze if a given calls is a danger for the session flow,
the user itself is responsible for the correct setting of this option.

=item Stop On restart

This option instructs ptkdb to stop at the time of session restart.
When the debugged process doesn't change the external resources while the
debugging session, it is useful to deactivate this option.

=back

=head3 Data Menu

=over

=item Enter Expression

When an expression is entered in the "Enter Expression:" text box,
selecting this item will enter the expression into the expression
list.  Each time the debugger stops this expression will be evaluated
and its result updated in the list window.

=item Delete Expression

Deletes the highlighted expression in the expression window.
An expression can be deleted either by pressing Delete key or <CTRL-D> combination.

=item Delete All Expressions

Delete all expressions in the expression window.

=item Show DB trace

Shows in a text windows the last 256 breakpoints.
To open the file named in a trace entry select the line and press the button 'open'.

Please note that the dialog content get not (yet) refreshed automatically.
Thus, press the button 'Refresh' to update the shown trace.

=item Expression Eval Window

Pops up a two pane window. Expressions of virtually unlimited length
can be entered in the top pane.  Pressing the 'Eval' button will cause
the expression to be evaluated and its placed in the lower pane. If
Data::Dumper is available it will be used to format the resulting
text.  Undo is enabled for the text in the upper pane.

HINT:  You can enter multiple expressions by separating them with commas.

=item DB trace expressions

This item enables or disables the tracing of the expressions into
the DB trace area.

=item DB trace subroutines

This item enables or disables the tracing of the called subroutines into the
DB trace area.

=item DB trace is active

This menu item enables or disables the tracing into DB-trace.
The debugging may get very slow due to the DB-trace when a large amount of data get recorded
i.e. during recursive traverse of trees. So, it may be useful to deactivate the trace
during the process of non-relevant blocks of the debugged scripts.

=item Display variable at cursor position

Enable or disable the display of the Balloon showing the
variable under the cursor position.

=item Show Proximity Window

Enable or disable the display of the proximity analysis.

=item Use Data::Dumper for Eval Window

Enables or disables the use of Data::Dumper for formatting the results
of expressions in the Eval window.

=back

=head3 Stack Menu

This menu shows in a drop-down window the list of the current subroutine stack each time the
debugger stops. Selecting an item from this menu will cause the code page
to show the file containing that particular location and make the
corresponding line to appear like a breakpoint. Nevertheless,
the current breakpoint isn't affected by this operation.
So, the expression frame and the proximity frame remain unchanged,
the evaluations window still acts at the current package/block of the current breakpoint.
Clicking on the tear down sign on the top of the list the stack windows may be fixed on the screen while a sequence of breakpoints.
This may be very helpful to analyze in depth the flow of messages resp soubroutines calls through many classes, packages or files.

=head3 Bookmarks Menu

ptkdb maintains a list of bookmarks.
The bookmarks are saved in a ASCII file at ~/.ptkdb_bookmarks .

This menu point allows you to enter the functionalities to maintain the list:

=over

=item Add Bookmark

This menu item adds a bookmark to the bookmark list.

=item Edit Bookmarks

This menu item edits the bookmark list.

=item Save Bookmarks

This menu item saves the bookmarks list.

=item List of the bookmarks

This menu item ppens the corresponding file in the code window and show the recorded line.

=back

=head3 Tools menu

=over

=item Options

This menu item shows the content of the Hash %ENV, which saves all options used by ptkdb.

=back

=head3 Windows Menu

=over

=item Code pane

Set the focus to the Code pane.


=item Quick entry

Set the focus to the Quick entry window.


=item Expression entry

Set the focus to the Expression entry.

=back

=head3 Help menu

=over

=item Home page

Connect o the ptkdb home page.

=item Feature request

Connect to the tracker page for enhancements requests.

=item Bugs report

Connect to the bug tracker page.

=item Mailing list

Connect to the ptkdb usr's info page.

=item About

Shows the About-Dialog.

=back

=head2 The Toolbar

The toolbar contains these items:

=over

=item Step in

=item Step over

=item Run

=item Return

=item Run to

=item Pass Thru

=item Break

=item Switch Autostep

=back

The toolbar cannot (yet) be customized.

=head2 The Statusbar

The statusbar at the upper right corner of the main window shows three important informations:

- the state of the breakpoint filter,
- the state o the configuration  and
- the state of the debugger session.

The state of the breakpoint filter is set to 'Filter' when the state of the filter is changed to active.

The state of the configuration is set to 'Changed' on changes of breakpoints, expressions and options.

The state of the debugger session can be one of these values:

  'ready'       ptkdb is waiting on user's input normally after a breakpoint,
  'running'     the debugged process is executing after 'run',
  'stepping'    the debugged process is executing after 'step in/over',
  'terminating' ptkdb is ending the debugging session on user's request,
  'session end' the debugged process entered its termination process.

=head1 OPTIONS

Here is a list of the current active XResources options. Several of
these can be overridden with environmental variables. Resources can be
added to .Xresources or .Xdefaults depending on your X configuration.
To enable these resources you must either restart your X server or use
the xrdb -override resFile command.  xfontsel can be used to select
fonts.

	/*
	* Perl Tk Debugger XResources.
	* Note... These resources are subject to change.
	*
	* Use 'xfontsel' to select different fonts.
	*
	* Append these resource to ~/.Xdefaults | ~/.Xresources
	* and use xrdb -override ~/.Xdefaults | ~/.Xresources
	* to activate them.
	*/
	/* Set Value to se to place scrollbars on the right side of windows
	CAUTION:  extra whitespace at the end of the line is causing
	failures with Tk800.011.

	'sw' -> puts scrollbars on left, 'se' puts scrollbars on the right.

	*/
	ptkdb*scrollbars: sw
	/* controls where the code pane is oriented, down the left side, or across the top */
	/* values can be set to left, right, top, bottom */
	ptkdb*codeside: left

	/*
	* Background color for the balloon
	* CAUTION:  For certain versions of Tk trailing
	* characters after the color produces an error
	*/
	ptkdb.frame2.frame1.rotext.balloon.background: green
	ptkdb.frame2.frame1.rotext.balloon.font: fixed                       /* Hot Variable Balloon Font */


	ptkdb.frame*font: fixed                           /* Menu Bar */
	ptkdb.frame.menubutton.font: fixed                /* File menu */
	ptkdb.frame2.frame1.rotext.font: fixed            /* Code Pane */
	ptkdb.notebook.datapage.frame1.hlist.font: fixed  /* Expression Notebook Page */

	ptkdb.notebook.subspage*font: fixed               /* Subroutine Notebook Page */
	ptkdb.notebook.brkptspage*entry.font: fixed       /* Delete Breakpoint Buttons */
	ptkdb.notebook.brkptspage*button.font: fixed      /* Breakpoint Expression Entries */
	ptkdb.notebook.brkptspage*button1.font: fixed     /* Breakpoint Expression Entries */
	ptkdb.notebook.brkptspage*checkbutton.font: fixed /* Breakpoint Checkbuttons */
	ptkdb.notebook.brkptspage*label.font: fixed       /* Breakpoint Checkbuttons */

	ptkdb.toplevel.frame.textundo.font: fixed         /* Eval Expression Entry Window */
	ptkdb.toplevel.frame1.text.font: fixed            /* Eval Expression Results Window */
	ptkdb.toplevel.button.font:  fixed                /* "Eval..." Button */
	ptkdb.toplevel.button1.font: fixed                /* "Clear Eval" Button */
	ptkdb.toplevel.button2.font: fixed                /* "Clear Results" Button */
	ptkdb.toplevel.button3.font: fixed                /* "Clear Cancel" Button */

	/*
	* Background color for where the debugger has stopped
	*/
	ptkdb*stopcolor: blue

	/*
	* Background color for set breakpoints
	*/
	ptkdb*breaktagcolor*background: yellow
	ptkdb*disabledbreaktagcolor*background: white
	/*
	* Font for where the debugger has stopped
	*/
	ptkdb*stopfont: -*-fixed-bold-*-*-*-*-*-*-*-*-*-*-*

	/*
	* Background color for the search tag
	*/
	ptkdb*searchtagcolor: green

=head1 ENVIRONMENTAL VARIABLES

=over

=item DISPLAY

See option PTKDB_DISPLAY below.

=item HOME

=item PTKDB_ADD_EXPR_DEPTH

The number of levels the selected expression is expanded in the expression's list on a <double><click>.
Default value ist 1 level down. That means expand the next level down.

=item PTKBD_ALLOW_CALLS_IN_EXPR_LIST

This option allows you to enter in the expression list a call to a subroutine or a message to an object.
Such expression may be very dangerous for the debugging session. Messages and subroutines are designed to be called under specific
conditions. This is not given when the call or the message happens on any breakpoint.
Obviously, this restriction doesn't apply to strict read-only subroutines or methods.

=item PTKDB_AUTOSTEP_DELAY_TIME

This option specifies the time pdtdb should delay the continuation of the process while stepping forward in autostep mode.
The default value is 1500 msec.
While the debugging session the delay time may be changed by means of a dialog issued by menu item 'control/set autostep delay time'.
A value of 0 msec will suppress the autostep mode.

=item PTKDB_BALLOON

This flag activates resp. deactivates the display of the variable
at the cursor position. Default is ON.

=item PTKDB_BALLOON_BACKGROUND

Background color of the Balloon. Default value is '#CCFFFF' .

=item PTKDB_BALLOON_MSG_MAX_LENGTH

The value of this option limits the max length of the displayed data
on the expression's balloon.

Default value is 256 chars.

=item PTKDB_BALLOON_TIME

This option specify the delay the cursor must be on a variable
in order to display the variable's content on a balloon.
Default value is 300 millisec.

=item PTKDB_BOOKMARKS_PATH

This option sets the path of the bookmarks file.
Default is $ENV{'HOME'}/.ptkdb_bookmarks .

=item PTKDB_BOOKMARKS_COLOR

This option sets the background color of a bookmarked line.
Default value is "#CEFFDB" (lightgreen).

=item PTKDB_BRKPT_COLOR

This option sets the background color of a set breakpoint.
Default value is 'red' .

=item PTKDB_TEMP_BRKPT_COLOR

This option sets the background color of an active temporary breakpoint.
Default value is 'lightblue' .


=item PTKDB_BUTTON_FONT

This option sets the Font definition for almost all Buttons in ptkdb dialogs.

Example:

set PTKDB_BUTTON_FONT="-family,'Arial',-size,8,-slant,'italic',-underline,0 ,-overstrike,0"

=item PTKDB_DISABLEDBRKPT_COLOR

This option sets the background color of a disabled breakpoint.
Default value is 'green'.

=item PTKDB_CODE_FONT

This option sets the font of the Text in the code pane.
This value defaults to ('-font',[qw(-family Courier -size 10)]).
Example:
set PTKDB_CODE_FONT="(-family,'Courier',-size,12)"


=item PTKDB_CODE_SIDE

This option sets which side the code pane is packed onto.
It can be set to 'left', 'right', 'top', 'bottom'.
Default value is 'left'.

Overrides the Xresource ptkdb*codeside: I<side>.

=item PTKDB_CTRLC_DISABLE

This option enables (0) or disables(1) the binding of <ctrl-C> to the code page.
The bound callback terminates the degugging session.
This may be dangerous for people who are used to press <ctrl-C> to copy selected text to the clipboard.
The default value is 1.

=item PTKDB_DECORATE_CODE

This option specifies the initial state applied to the decoration of the code windows.
It can be turned ON/OFF while the debugging time at any time by means of the
menu checkbutton 'Data/Decorate code'.
The decoration process consists of the use of foreground colors to emphasize
variables depending on their type : scalar, array, hash, reference and glob.

Default is 0 (disabled).

=item PTKDB_DISPLAY

This option sets the X display that the ptkdb window will appear on when invoked.  Useful for debugging CGI
scripts on remote systems.

=item PTKDB_ENTRY_CLASS

This option sets the class name for the entry widgets : may be 'entry' or 'browseentry'.
Default is 'browseentry'.

=item PTKDB_EVAL_FONT

This option sets the font used in the Expression Eval Window.
Example :
set PTKDB_EVAL_FONT="qw(-family Courier -size 10)"

=item PTKDB_EVAL_DUMP_INDENT

This option sets the value used for Data::Dumper 'indent' setting. See man Data::Dumper

=item PTKDB_EXPRESSION_FONT

This option sets the font used in the expression window.

=item PTKDB_GEOMETRY

This option sets the geometry argument for the ptkdb main window, Default value is 800x600.

=item PTKDB_ICONIFY

This option lets ptkdb iconify its main window when it passes the control back to the application.

=item PTKDB_LINENUMBER_FORMAT

This option sets the format of line numbers on the left side of the code window.
Default value is %05d.
It is useful if you have a script that contains more than 99999 lines.

=item PTKDB_LOG_INTO_STDERR

This option allows to print the ptkdb log items into the stream STDERR instead of stream STDOUT.

=item PTKDB_USE_LOG_PAGE

This option allows to suppress the creation of the page 'Log' onto the Notebook pane of ptkdb.
Default value is 1.

=item PTKDB_VERBOSE

This option allows to suppress any log items of ptkdb.
When this option if off then the option USE_LOG_PAGE is turned off too.

=item PTKDB_RESTART_STATE_FILE

This options saves the file name of the ptkdb state file.
This option is used by ptkdb itself to save/restore the session's state while
the session restart process.

=item PTKDB_SCROLLBARS_ONRIGHT

A non-zero value sets the scrollbars of all windows to be on the
right side of the window. Useful for Windows users using ptkdb in an
XWindows environment.

=item PTKDB_PROXIMITYWINDOWINITIALDEPTH

This options specifies the depth of the items on the proximity window
at refresh time. A value of zero (the default value) means that all items remain closed.
This depth is applied each time the window is refreshed by ptkdb itself.

=item PTKDB_SHOWPROXIMITYWINDOW

This options activates respectively deactivates the display of the proximity.
The proximity consists of the variables involved in the line of the current breakpoint.
Remember that the proximity is always analysed even when this option is off.

=item PTKDB_SIGDIE_DISABLE

This option may be set to non-zero value to disable the ptkdb DIE callback.
The callback simply logs the caught die-exception in DB trace and onto the STDOUT stream
(see subroutine DB::dbDie).
This mechanism doesn't work on Perl/Tk scripts which uses the Tk::Error module.

=item PTKDB_SIGINT_DISABLE

This option instructs ptkdb to activate the callback DB::dbint_handler for interrupts of type INT.

=item PTKDB_STOP_TAG_COLOR

This option sets the color that highlights the line where the debugger is stopped.

=item PTKDB_STOP_TAG_FONT

This option sets the color that highlights the line where the debugger is stopped.
Don't specify the -size option in order to use the one of the source window text.

=item TMP or TEMP or TMPDIR or TMP_DIR or HOME

This option specifies the path to locate the state file during the restart process.

=item PTKDB_TRACE_ARRAY_SIZE

This option specifies the size of the array saving the ptkdb breakpoint trace.
Default value is 512 items.

=item PTKDB_TRACE_EXPRESSIONS

This option activates or deactivates the tracing of the watched expressions into the DB trace area.
Default is 0 (don't trace).
This option may be turned on/off by means of menu item 'Data/DB trace expressions'.

=item PTKDB_TRACE_SUB_ACTIVE

This option activates the trace of subroutine calls into DB-trace.
Default value is 0 (don't trace).
This option may be turned on/off by means of menu item 'Data/DB trace subroutines'.

=back

=head1 FILES

=head2 .ptkdbrc

If this file is present in ~/ or in the directory where PERL is
invoked the file will be read and executed as a Perl script before the
debugger makes its initial breakpoint at startup.

There is a system ptkdbrc file in $PREFIX/lib/perl5/$VERS/Devel/ptkdbrc

CAUTION: ptkdb evaluates the following ptkdbrc files

	- $Config{'installprivlib'}/Devel/ptkdbrc
	- $ENV{'HOME'}/.ptkdbrc
	- ./.ptkdbrc


The ptkdbrc script may do the following

	- set some global variables for the debugging session control,
	- set text tag options for the code page and
	- register callbacks.

=over

=item Variables

- B<$DB::no_stop_at_start>

This variable may be set to non-zero to prevent the debugger from stopping at the first line of the script.
This is useful for debugging CGI scripts.

- B<$DB::no_stop_at_end>

This variable may be set to non-zero to prevent the debugger ptkdb to stop
at the end of the debugging session.
When this flag is on, then a debugging session can be restarted only by means of
the menu item '/Control/Restart'.

- B<$DB::ptkdb::stop_on_warning>

This variable may be set to 1 in order to let the debugger stop the processing
on warnings.

- B<$DB::ptkdb::stop_on_restart>

This variable instructs ptkdb to set up a modal dialog
in order to suspend the restart of the session.
This allows to restore the test environment in the case it has been modified during the terminating
debugging session.
This flag may also be switched using the menu <Control/Stop on restart> .

=item brkpt(?fname?, ?list of lines?)

Sets breakpoints on the list of lines in fname.  A warning message
is generated if a line is not breakable.

=item condbrkpt(?fname?, ?list of (?line?, ?expr?)?)

Sets conditional breakpoints in fname on pairs of (line,expr).
A warning message is generated if a line is not breakable.
NOTE: the validity of the expression will not be determined until execution of
that particular line.

=item brkonsub(?list of names?)

This command sets a breakpoint on each subroutine name found in the list.
A warning message is generated if a subroutine does not exist.  NOTE: for a script with no
other packages the default package is "main::" and the subroutines
would be "main::mySubs".

=item brkonsub_regex(?list of regexp?)

This command uses ?list of regexp? to set breakpoints.
Sets breakpoints on every subroutine that matches any of the listed regular expressions.

=item register_user_window_init(?list of callbacks?)

This command registers a list of subroutine references or eval-strings that will be called whenever
ptkdb sets up it's windows

Example:

	register_user_window_init(
		sub{warn ' I was there...'},
		'warn " I was THERE..."'
		);

=item register_user_window_end (?list of callbacks?)

This command registers a list of subroutine references  or eval-strings that will be called when
ptkdb terminates the debugging session.

=item Coding notes about registered window init and end subroutines

- callbacks take no argument list,

- return values are discarded,

- callbacks are evaluated either as a block or as an expression.

=item register_user_restart_entry (?list of callbacks?)

=item Coding notes about registered window init and end subroutines

- callbacks take no argument list,

- return values are discarded,

- callbacks are evaluated either as a block or as an expression,

- callbacks may access @Devel::ptkdb::script_args to get resp. modify the
  command line arguments used to start resp.restart the debugged script,

- current working directory is restored before the callbacks are called,

- callbacks are called independently of the options controlling the restart facility.

=item register_user_DB_entry(?list of callbacks?)

This command registers a list of subroutine references  or eval-strings  that will be called whenever
ptkdb enters from debugged code into breakpoint processing.

Example:

	register_user_DB_entry(
	sub{warn ' I was there too ...'},
	'warn " I was THERE too ..."'
	);

=item register_user_DB_leave(?list of callbacks?)

This command registers a list of subroutine references  or eval-strings  that will be called whenever
ptkdb leaves breakpoint processing and returns to the debugged code.


=item Coding notes about registered DB entry and leave subroutines

- callbacks take the argument list ($package,$filename,$line),

- return values are discarded,

- callbacks are evaluated either as a block or as an expression.


=item textTagConfigure(tag, ?option?, ?value?)

This command allows the user to format the text in the code window. The option
value pairs are the same values as the option for the tagConfigure
method documented in Tk::Text. Actually, the following tags are in
effect:


	'code'               Format for code in the text pane (obsolete)
	'stoppt'             Format applied to the line where the debugger is currently stopped
	'breakableLine'      Format applied to line numbers where the code is 'breakable'
	'nonbreakableLine'   Format applied to line numbers where the code is no breakable
	'breaksetLine'       Format applied to line numbers were a breakpoint is set
	'breakdisabledLine'  Format applied to line numbers were a disabled breakpoint is set
	'search_tag'         Format applied to text when located by a search.
	'bookmark'           Format of line marked as bookmark

Example: Turns off the overstrike on lines that you can't set a breakpoint on
         and makes the text color green.

	textTagConfigure('nonbreakableLine', -overstrike => 0, -foreground => 'green') ;

=item add_exprs(?list of expr?)

This command adds a list of expressions to the 'Exprs' window.
NOTE: use the single quote character \' to prevent the expression from being "evaluated" in
the string context.


Example: Adds the $_ and @_ expressions to the active list.

	add_exprs('$_', '@_') ;

=back

=head2 Other customizations

=over

=item Callback EnterActions

This method of package Devel::ptkdb is called at the beginning of each breakpoint processing.
It may be overwritten in order to perform some particular processing with
the actual application data.

Arguments:

- ref to instance of the class Devel::ptkdb

- package name of breakpointed package

- filename of breakpointed script

- line number of breakpoint inside the file

Return value

- None

=item Callback LeaveActions

This method of package Devel::ptkdb is called at the and of each breakpoint processing,
that means just before the control goes back to Perl code.
Like the callback mentioned above it may be overwritten in order to perform some
particular post-processing of the actual application data.

Arguments:

- ref to instance of the class Devel::ptkdb
- package name of breakpointed package
- filename of breakpointed script
- line number of breakpoint inside the file

Return value

- None

=back

=head1 NOTES

=head2 Debugging perlTk Applications

ptkdb can be used to debug perlTk applications if some cautions
are observed. Basically, do not click the mouse in the application's
window(s) when you've entered the debugger and do not click in the
debugger's window(s) while the application is running.  Doing either
one is not necessarily fatal, but it can confuse things that are going
on and produce unexpected results.

Be aware that perlTk applications have a central event loop.
User actions, such as mouse clicks, key presses, window exposures, etc
will generate 'events' that the script will process. When a perlTk
application is running, its 'MainLoop' call will accept these events
and then dispatch them to appropriate callbacks associated with the
appropriate widgets.

The debugger ptkdb has its own event loop that runs whenever you've stopped at a
breakpoint and entered the debugger. However, it accepts all events
that are generated by any perlTk windows and dispatch their
callbacks.  The problem here is that the application is supposed to be
'stopped', and logically the application should not be able to process
events.

A future version of ptkdb will have an extension that will 'filter'
events so that application events are not processed while the debugger
is active, and debugger events will not be processed while the target
script is active. (See also menu item 'Control/Event mask')

=head2 Debugging CGI Scripts

One advantage of ptkdb over the builtin debugger(-d or -dt) is that it can be
used to debug CGI Perl scripts as they run on a web server. Be sure
that that your web server's Perl installation includes Tk.

Change your

	#! /usr/local/bin/perl

to

	#! /usr/local/bin/perl -d:ptkdb

HINT: You can debug scripts remotely if you're using a unix based
Xserver and where you are authoring the script has an Xserver.  The
Xserver can be another unix workstation, a Macintosh or Win32 platform
with an appropriate XWindows package.
You may insert in your script insert the following BEGIN subroutine

	sub BEGIN {
	$ENV{'DISPLAY'} = "myHostname:0.0" ;
	}

or set the PTKDB_DISPLAY variable to "myHostname:0.0" in your server run time environment.

Be sure that your web server has permission to open windows on your
Xserver (see the xhost manpage).

Access your web page with your browser and 'submit' the script as
normal.  The ptkdb window should appear on myHostname's monitor. At
this point you can start debugging your script.  Be aware that your
browser may timeout waiting for the script to run.

To expedite debugging you may want to setup your breakpoints in
advance with a .ptkdbrc file and use the $DB::no_stop_at_start
variable.  NOTE: for debugging web scripts you may have to have the
.ptkdbrc file installed in the server account's home directory (~www)
or whatever username your webserver is running under.  Also try
installing a .ptkdbrc file in the same directory as the target script.

=head2 Debugging multithread

ptkdb supports multithreading under the limitations set by the Perl debugger itself.
Of course, the debugger must be started using the line command option -dt:ptkdb .

=head2 Debugging IPC

Under following restrictions IPC scripts may be analysed with ptkdb:

- during a debugging session ptkdb restricts breakpoints to one process
checking the PID.

- forked subprocesses or threads cannot be breakpointed.

- launched child processes run in a separate debugging session, if any is requested
by the specified Perl options in its start command.

- ptkdb doesn't know specialized functionalities to support IPC communications.
Therefore, ptkdb event loop may collide with IPC flow (i.e. timeouts due to breakpoints).

=head2 Debugging graphic application other than PerlTk.

Basically ptkdb may be used to debug graphic applications under the condition that their event loop
doesn't collide with the one of PerlTk.
In some cases the method Devel::ptkdb::EnterActions and Devel::ptkdb::LeaveActions could be used to deactivate
to "freeze and restart" the graphic system during the breakpoint process.
This is absolutely precondition to test time dependent graphics like simulations or games.
(See also considerations 'Debugging PerlTk Applications' mentioned above).

=head3 Tkx

Since Tkx basically works like PerlTk, ptkdb supports  the debugging of Tkx scripts.

=head1 KNOWN PROBLEMS

=over

=item Breakpoint Controls

Usually the notebook widget shows the expression page.
Though, when a breakpoint is set in the code window, the notebook widget
switches to the breakpoint page. When the next breakpoint is shown,
the expression page is automatically redisplayed.
When the list of breakpoints is large, the page switching may take
a little bit time ...

While shrinking the breakpoint page at a certain point suddenly the breakpoints disappears from the page.
Don't fear, the breakpoint definitions did not evaporate. In fact when the page is enlarged again then they reappear.
Simply, Tk::Table cannot yet scroll items.

=item Breakpoint trace

The trace should allow to record what happened during the session.
So, the recorded expressions can be used to inspect the state of variables
at the various breakpoints. This has a major drawback. When the recorded
data get large, then the time to build up the trace display get dramatically long.
I experienced setup times of many seconds for a trace of about 150K.
Clearly, this problem may be controlled in several ways:

- reducing the size of the trace area by means
of the environment option PTKDB_TRACE_ARRAY_SIZE,

- temporary deactivating the trace during non-relevant processing phase,

- emptying the trace area at breakpoints which start the interesting process step.

=item Debugging exceptions

ptkdb sets up these callbacks as simple error handlers :

- a DIE-callback at initial time. It simply notice the user about the receiving of the

- an INT-callback at initial time. It should allow a soft termination on receiving the INT signal.

- a local DIE-callback at entry to each breakpoint. It should inform about die signals
in registered subroutines.

Remember that subsystem, i.e. Perl/Tk, are not forced to care about existing error handlers!

=item Balloons and Tk400

The Balloons in Tk400 will not work with ptkdb.  All other functions
are supported, but the Balloons require Tk800 or higher.

=item Multithreading scripts

The debugging sessions of multithread-scripts must be started with B<-dt:ptkdb>.

Breakpoints inside threads are not supported. Thus, the debugging session
is restricted to the analysis of code outside threads.

=item Forked subprocesses

ptkdb has been changed in order to ignore the flow of forked processes.
Though, it is quite easily to implement a customized functionality ,
for instance to record the subprocess flow in a persistent trace stack.

=item Perl/Tk

Analysis of Perl/Tk scripts may be shaky due to the interference of the additional TK-activities and resource of the ptkdb itself.

=back

=head1 AUTHOR

Marco Marazzi, mmarazzi@users.sourceforge.net 2008,2013
Svetoslav Marinov, svetoslavm@users.sourceforge.net 2007
Andrew E. Page, aepage@users.sourceforge.net 1998, 2007

=head1 ACKNOWLEDGEMENTS

Matthew Persico    For suggestions, and beta testing.
Tony Brummet       For suggestions, and testing.

=head1 BUG REPORTING

Please report bugs through the following URL:

http://sourceforge.net/tracker/?atid=437609&group_id=43854&func=browse

=head1 FEATURE REQUEST

http://sourceforge.net/tracker/?atid=437612&group_id=43854&func=browse

=head1 MAILING LIST

http://lists.sourceforge.net/lists/listinfo/ptkdb-user

=cut

