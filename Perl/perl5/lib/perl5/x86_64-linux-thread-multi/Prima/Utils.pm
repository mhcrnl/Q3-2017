#
#  Copyright (c) 1997-2002 The Protein Laboratory, University of Copenhagen
#  All rights reserved.
#
#  Redistribution and use in source and binary forms, with or without
#  modification, are permitted provided that the following conditions
#  are met:
#  1. Redistributions of source code must retain the above copyright
#     notice, this list of conditions and the following disclaimer.
#  2. Redistributions in binary form must reproduce the above copyright
#     notice, this list of conditions and the following disclaimer in the
#     documentation and/or other materials provided with the distribution.
#
#  THIS SOFTWARE IS PROVIDED BY THE AUTHOR AND CONTRIBUTORS ``AS IS'' AND
#  ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE
#  IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE
#  ARE DISCLAIMED.  IN NO EVENT SHALL THE AUTHOR OR CONTRIBUTORS BE LIABLE
#  FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL
#  DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS
#  OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION)
#  HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT
#  LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY
#  OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF
#  SUCH DAMAGE.
#
#  Created by:
#     Vadim Belman   <voland@plab.ku.dk>
#     Anton Berezin  <tobez@plab.ku.dk>
#
#  $Id$

package Prima::Utils;
use strict;
require Exporter;
use vars qw(@ISA @EXPORT @EXPORT_OK);
@ISA = qw(Exporter);
@EXPORT = ();
@EXPORT_OK = qw(
	query_drives_map query_drive_type
	getdir get_os get_gui
	beep sound
	username
	xcolor
	find_image path
	alarm post last_error
);

sub xcolor {
# input: '#rgb' or '#rrggbb' or '#rrrgggbbb'
# output: internal color used by Prima
	my ($r,$g,$b,$d);
	$_ = $_[0];
	$d=1/16, ($r,$g,$b) = /^#([\da-fA-F]{3})([\da-fA-F]{3})([\da-fA-F]{3})/
	or
	$d=1, ($r,$g,$b) = /^#([\da-fA-F]{2})([\da-fA-F]{2})([\da-fA-F]{2})/
	or
	$d=16, ($r,$g,$b) = /^#([\da-fA-F])([\da-fA-F])([\da-fA-F])/
	or return 0;
	($r,$g,$b) = (hex($r)*$d,hex($g)*$d,hex($b)*$d);
	return ($r<<16)|($g<<8)|($b);
}

sub find_image
{
	my $mod = @_ > 1 ? shift : 'Prima';
	my $name = shift;
	$name =~ s!::!/!g;
	$mod =~ s!::!/!g;
	for (@INC) {
		return "$_/$mod/$name" if -f "$_/$mod/$name" && -r _;
	}
	return undef;
}

# returns a preferred path for the toolkit configuration files,
# or, if a filename given, returns the name appended to the path
# and proofs that the path exists
sub path
{
	my $path;
	if ( exists $ENV{HOME}) {
		$path = "$ENV{HOME}/.prima";
	} elsif ( $^O =~ /win/i && exists $ENV{USERPROFILE}) {
		$path = "$ENV{USERPROFILE}/.prima";
	} elsif ( $^O =~ /win/i && exists $ENV{WINDIR}) {
		$path = "$ENV{WINDIR}/.prima";
	} else {
		$path = "/.prima";
	}

	if ( $_[0]) {
		unless ( -d $path) {
			eval "use File::Path"; die "$@\n" if $@;
			File::Path::mkpath( $path);
		}
		$path .= "/$_[0]";
	}

	return $path;
}

sub alarm
{
	my ( $timeout, $sub, @params) = @_;
	return 0 unless $::application;
	my $timer = Prima::Timer-> create( 
		name    => $sub,
		timeout => $timeout, 
		owner   => $::application,
		onTick  => sub {
			$_[0]-> destroy;
			$sub-> (@params);
		}
	); 
	$timer-> start;
	return 1 if $timer-> get_active;
	$timer-> destroy;
	return 0;
}

sub post
{
	my ( $sub, @params) = @_;
	return 0 unless $::application;
	my $id;
	$id = $::application-> add_notification( 'PostMessage', sub {
		my ( $me, $parm1, $parm2) = @_;
		if ( defined($parm1) && $parm1 eq 'Prima::Utils::post' && $parm2 == $id) { 
			$::application-> remove_notification( $id);
			$sub-> ( @params);
			$me-> clear_event;
		}
	}); 
	return 0 unless $id;
	$::application-> post_message( 'Prima::Utils::post', $id);
	return 1;
}

1;

__DATA__

=head1 NAME

Prima::Utils - miscellanneous routines

=head1 DESCRIPTION

The module contains several helper routines, implemented in both C and perl. 
Whereas the C-coded parts are accessible only if 'use Prima;' statement was issued
prior to the 'use Prima::Utils' invocation, the perl-coded are always available.
This makes the module valuable when used without the rest of toolkit code.

=head1 API

=over

=item alarm $TIMEOUT, $SUB, @PARAMS

Calls SUB with PARAMS after TIMEOUT milliseconds.

=item beep [ FLAGS = mb::Error ] 

Invokes the system-depended sound and/or visual bell, 
corresponding to one of following constants:

	mb::Error
	mb::Warning
	mb::Information
	mb::Question

=item get_gui

Returns one of C<gui::XXX> constants, reflecting the graphic
user interface used in the system:

	gui::Default
	gui::PM  
	gui::Windows
	gui::XLib 
	gui::GTK2

=item get_os

Returns one of C<apc::XXX> constants, reflecting the platfrom.
Currently, the list of the supported platforms is:

	apc::Win32  
	apc::Unix

=item ceil DOUBLE

Obsolete function.

Returns stdlib's ceil() of DOUBLE

=item find_image PATH

Converts PATH from perl module notation into a file path, and
searches for the file in C<@INC> paths set. If a file is
found, its full filename is returned; otherwise C<undef> is
returned.

=item floor DOUBLE

Obsolete function.

Returns stdlib's floor() of DOUBLE

=item getdir PATH 

Reads content of PATH directory and 
returns array of string pairs, where the first item is a file
name, and the second is a file type.

The file type is a string, one of the following:

	"fifo" - named pipe
	"chr"  - character special file
	"dir"  - directory
	"blk"  - block special file
	"reg"  - regular file
	"lnk"  - symbolic link
	"sock" - socket
	"wht"  - whiteout

This function was implemented for faster directory reading, 
to avoid successive call of C<stat> for every file.

=item last_error

Returns last system error, if any

=item path [ FILE ]

If called with no parameters, returns path to a directory,
usually F<~/.prima>, that can be used to contain the user settings
of a toolkit module or a program. If FILE is specified, appends
it to the path and returns the full file name. In the latter case 
the path is automatically created by C<File::Path::mkpath> unless it
already exists.

=item post $SUB, @PARAMS

Postpones a call to SUB with PARAMS until the next event loop tick.

=item query_drives_map [ FIRST_DRIVE = "A:" ]

Returns anonymous array to drive letters, used by the system.
FIRST_DRIVE can be set to other value to start enumeration from.
Some OSes can probe eventual diskette drives inside the drive enumeration
routines, so there is a chance to increase responsiveness of the function
it might be reasonable to set FIRST_DRIVE to C<C:> string.

If the system supports no drive letters, empty array reference is returned ( unix ).

=item query_drive_type DRIVE

Returns one of C<dt::XXX> constants, describing the type of drive,
where DRIVE is a 1-character string. If there is no such drive, or
the system supports no drive letters ( unix ), C<dt::None> is returned.

	dt::None
	dt::Unknown
	dt::Floppy
	dt::HDD
	dt::Network
	dt::CDROM
	dt::Memory

=item sound [ FREQUENCY = 2000, DURATION = 100 ]

Issues a tone of FREQUENCY in Hz with DURATION in milliseconds.

=item username

Returns the login name of the user. 
Sometimes is preferred to the perl-provided C<getlogin> ( see L<perlfunc/getlogin> ) .

=item xcolor COLOR

Accepts COLOR string on one of the three formats:

	#rgb
	#rrggbb
	#rrrgggbbb

and returns 24-bit RGB integer value.

=back

=head1 AUTHOR

Dmitry Karasik, E<lt>dmitry@karasik.eu.orgE<gt>.

=head1 SEE ALSO

L<Prima>

