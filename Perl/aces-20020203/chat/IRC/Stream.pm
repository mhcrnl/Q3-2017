#!/usr/bin/perl -w

# IRC::Stream - connection module to ircbase
# (c) 2001, Jin-Ho King <acramon1@users.sourceforge.net>
# Distributed under the GPL

package IRC::Stream;

###
# Includes
###

use strict;
use vars qw( @ISA $VERSION );
use Exporter;
$VERSION = 3.0;
@ISA = qw( Exporter );

use IO::Socket;
use IO::Handle;
use FileHandle;

###
# Constants
###

my $DEBUG = 0;
*ERRMSG = *STDERR;

###
# Functions
###

# constructor

sub new
{
	my $class = shift;
	my $this = { };
	bless( $this , $class );
	$this->_init( shift , shift );
	return $this;
}

sub _init
{
	my $this = shift;
	$SIG{CHLD} = 'IGNORE'; # forget dead children
	$this->{sock} = IO::Socket::INET->new( Proto => 'tcp' ,
		PeerAddr => shift ,
		PeerPort => shift )
		or die "\n*** _init( ".join( ' , ' , @_ )." ): $! ***\n\n";
	$this->{queue} = new FileHandle;
	if( $this->{child} = open( $this->{queue} , "-|" ) ) { # parent
		print ERRMSG "### Opening catch mechanism ###\n" if( $DEBUG );
		return;
	} else { # child/failed
		die "\n*** Fork! : $! ***\n\n" unless defined( $this->{child} );
		$this->_catch_msg( );
		exit( 0 );
	}
}

sub _catch_msg
{
	my $this = shift;
	my $handle = $this->{sock};
	STDOUT->autoflush( 1 );
	local( *MSGS ) = *STDOUT;
	while( defined( my $line = <$handle> ) ) { # keep reading
		print ERRMSG "### Received Message: $line ###\n" if( $DEBUG );
		if( $line =~ /^ping :(.*?)[\r||\n]/i ) { # server pinging!
			$this->send( "pong $1" );
			print ERRMSG "### Int: pong \"$1\" END ###\n"
				if( $DEBUG );
		} elsif( $line =~
			/^:(.*?)!.*?@.*? PRIVMSG .*? :(.*?)[\r||\n]/ ) {
			# if message!
			print MSGS "RECV \"$1\" \"$2\" END\n";
			print ERRMSG "### Int: RECV \"$1\" \"$2\" END ###\n"
				if( $DEBUG );
		} elsif( $line =~ /^:.*? 311 .*? (.*?) .*?:(.*?)[\r||\n]/ ) {
			# if online!
			print MSGS "UON \"$1\" \"$2\" END\n";
			print ERRMSG "### Int: UON \"$1\" \"$2\" END ###\n"
				if( $DEBUG );
		} elsif( $line =~ /^:.*? 401 .*? (.*?) .*?:.*?[\r||\n]/i ) {
			# if offline!
			print MSGS "UOFF \"$1\" END\n";
			print ERRMSG "### Int: UOFF \"$1\" END ###\n"
				if( $DEBUG );
		} elsif( $line =~ /T [1-9] I \*\*\* Signoff:/ ) { # if signed off!
			print ERRMSG "### Signed Off ###\n" if( $DEBUG );
			print MSGS "SOFF END\n";
		} elsif( $line =~ /\/MOTD/ ) { # if online!
			print ERRMSG "### Signed On ###\n" if( $DEBUG );
			print MSGS "SON END\n";
		}
	}
	exit( 0 );
}

# methods

sub sock
{
	return( $_[0]->{sock} );
}

sub login
{
	my( $this , $user , $userinfo ) = @_;
	my $handle = $this->{sock};
	print $handle "user $user localhost localhost :$userinfo\n";
	print $handle "nick $user\n";
	print ERRMSG "### Logging in: $user ###\n" if( $DEBUG );
}

sub logoff
{
	my( $this ) = shift;
	$this->send( "quit" );
	print ERRMSG "### Logging off ###\n" if( $DEBUG );
}

sub send
{
	my( $this , $message ) = @_;
	my $handle = $this->{sock};
	print $handle "$message\n";
	print ERRMSG "### Sent: $message ###\n" if( $DEBUG );
}

sub msg
{
	my( $this , $user , $message ) = @_;
	$this->send( "privmsg $user :$message" );
}

sub recv_stream
{
	return( $_[0]->{queue} );
}

sub user_on
{
	$_[0]->send( "whois $_[1]" );
}

sub list_on
{
	my( $this , $rarr ) = @_;
	foreach ( @$rarr ) {
		$this->user_on( $_ );
	}
}

sub parse
{
	my( $this ) = shift;
	my $line = shift;
	my $msg = 0;
	if( !defined( $line ) ) {
		$msg = 0;
	} else {
		chomp( $line );
		print "### Received: $line ###\n" if( $DEBUG );
		if( $line =~ /^RECV "(.*?)" "(.*?)" END/ ) {
			print "### $line ###\n" if( $DEBUG );
			$msg = { };
			$msg->{type} = "RECV";
			$msg->{name} = $1;
			$msg->{msg} = $2;
			print "### $msg->{type} $msg->{name} $msg->{msg} ###\n"
				if( $DEBUG );
		} elsif( $line =~ /^UON "(.*?)" "(.*?)" END/ ) {
			print "### $line ###\n" if( $DEBUG );
			$msg = { };
			$msg->{type} = "UON";
			$msg->{name} = $1;
			$msg->{msg} = $2;
			print "### $msg->{type} $msg->{name} $msg->{msg} ###\n"
				if( $DEBUG );
		} elsif( $line =~ /^UOFF "(.*?)" END/ ) {
			print "### $line ###\n" if( $DEBUG );
			$msg = { };
			$msg->{type} = "UOFF";
			$msg->{name} = $1;
			$msg->{msg} = "offline";
			print "### $msg->{type} $msg->{name} $msg->{msg} ###\n"
				if( $DEBUG );
		} elsif( $line =~ /^SOFF/ ) {
			$msg = { };
			$msg->{type} = "SOFF";
		} elsif( $line =~ /^SON/ ) {
			$msg = { };
			$msg->{type} = "SON";
		}
	}
	return( $msg );
}

sub DESTROY
{
	my $this = shift;
	print ERRMSG "### %$this: finished! ###\n" if( $DEBUG );
	close( $this->{queue} ) if( $this->{queue} );
	
	kill( "TERM" => $this->{child} ); # get rid of children
}

###
# Misc.
###

1;

__END__

=head1 NAME

IRC::Stream - object interface for connection to ircbase

=head1 SYNOPSIS

	use IRC::Stream;
	$is = IRC::Stream->new( 'irc.openprojects.net' , '6667' );

=head1 DESCRIPTION

C<IRC::Stream> provides an object interface for communicating with an IRC
server.

=head1 CONSTRUCTOR

=over 4

=item new( I<address> , I<port> )

Creates an C<IRC::Stream> object, which is a reference to a class containing
methods to manipulate messages to and from the IRC server located on the
provided port and address.

=back

=head1 METHODS

=over 4

=item sock( )

Returns a reference to the actual connection socket. DO NOT USE!

=item send( I<message> )

Sends a message to the server. A simple front end for the server: DO NOT USE!

=item login( I<screenname> , I<userinfo> )

Logs onto the server using I<screenname> and I<userinfo>.

=item logoff( )

Logs off of the server.

=item msg( I<user> , I<message> )

Sends I<message> to I<user>.

=item parse( I<text> )

Returns a reference to a hash containing the parsed version of the text.

=item recv_stream( )

Returns a filehandle to the important server messages (preformatted in a nice
string too).

=item user_on( I<nick> )

Sends a message to the server inquiring about the status of the user I<nick>.

=item list_on( $I<refarray> )

Sends messages to the server inquiring about the status of all the users in the
referenced array.

=back

=head1 AUTHOR

Jin-Ho King. Currently maintained by ACES <http://aces.sourceforge.net>.

=head1 COPYRIGHT

Copyright (c) 2001 Jin-Ho King <acramon1@users.sourceforge.net>. All rights
reserved. This program is free software; you can redistribute it and/or modify
it under the terms of the GNU Public License <http://www.gnu.org>.

=cut
