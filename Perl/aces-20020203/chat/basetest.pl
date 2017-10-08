#!/usr/bin/perl -w

use strict;
use IRC::Stream 2.00;

$SIG{CHLD} = 'IGNORE';
my $test = IRC::Stream->new( 'irc.openprojects.net' , '6667' );

print <<EOF;
===================================
ACES -- Testing the chat servers...
-----------------------------------
report errors to: Jin-Ho King
 acramon1\@users.sourceforge.net
(c) 2001, Jin-Ho King
This is free software distributed
under the GPL <http://www.gnu.org>
===================================
EOF

my( $child , $line , $handle , $user , $passwd , $msg );

print "LOGIN\n user: ";
chomp( $user = <STDIN> );
print " info: ";
chomp( $passwd = <STDIN> );

$test->login( $user , $passwd );

if( $child = fork( ) ) { # parent deals with user
	while( defined( $line = <STDIN> ) ) {
		if( $line =~ /^s/i ) {
			print "USER: ";
			chomp( $user = <STDIN> );
			print "MESS: ";
			chomp( $msg  = <STDIN> );
			$test->msg( $user , $msg );
		} elsif( $line =~ /^u/i ) {
			print "FILE: ";
			chomp( $user = <STDIN> );
			open( BUDDIES , "$user" );
			chomp( my @ar = <BUDDIES> );
			close BUDDIES;
			$test->list_on( \@ar );
		} else {
			$test->logoff( );
		}
	}
} else { # child deals with server
	die "\n*** Fork! : $! ***\n\n" unless defined( $child );
	$handle = $test->recv_stream( );
	$msg = { };
	while( <$handle> ) {
		chomp;
		$msg = $test->parse( $_ );
#		print "==> $test->{type}\n" if( $msg );
		if( $msg && $msg->{type} =~ /RECV/i ) {
			print "*** FROM: $msg->{name}\n*** $msg->{msg}\n";
		} elsif( $msg && $msg->{type} =~ /UON/i ) {
			print "*** USER: $msg->{name} is online.\n";
		} elsif( $msg && $msg->{type} =~ /UOFF/i ) {
			print "*** USER: $msg->{name} is offline.\n";
		}
	}
	exit( 0 );
}


