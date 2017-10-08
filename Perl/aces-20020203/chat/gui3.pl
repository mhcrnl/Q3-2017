#!/usr/bin/perl -w

# gui3.pl - Perl/Tk GUI for chatting over IRC
# (c) 2001, Jin-Ho King <acramon1@users.sourceforge.net>
# Distributed under the GPL

# includes
# if using Tk, can't use strict;
use Tk;
use Tk::DialogBox;
use IRC::Stream 2.00;

# some things to consider (defaults, if you will)
my %this;
$this{name} = "ACES";
$this{version} = "0.0.3";
$this{server} = "irc.openprojects.net";
$this{port} = 6667;
$this{conn} = 0;

my %user;
$user{name} = "aces";
$user{info} = "gui3.pl - Perl/Tk GUI for chatting over IRC";
$user{buddy} = 0;

$SIG{CHLD} = 'IGNORE';

my $main = MainWindow->new( );

my $main_menu_frame = $main->Frame(
	-relief => "raised" ,
	-borderwidth => 2
)->pack(
	-anchor => "nw" ,
	-fill => "x"
);
my $menu_file = $main_menu_frame->Menubutton(
	-text => "File" ,
	-menuitems => [
		[ Button => "Login" , -command => \&Login ] ,
		[ Button => "Logoff" , -command => \&Logoff ] ,
		[ Button => "Quit" , -command => \&Quit ]
	]
)->pack(
	-side => "left"
);
my $menu_help = $main_menu_frame->Menubutton(
	-text => "Help" ,
	-menuitems => [
		[ Button => "About" , -command => \&About ] ,
	]
)->pack(
	side => "right"
);

my $body_frame = $main->Frame( )->pack( );

my $buddy_list = $body_frame->ScrlListbox(
	-width => 25 ,
	-height => 10 ,
)->pack( );

$buddy_list->bind( '<Double-1>' , \&Msg );
# $buddy_list->bind( '<KeyPress-Enter>' , \&Msg );

my $info_frame = $main->Frame( )->pack( -fill => 'x' );

my $info_text = $info_frame->Text(
	-width => 25 ,
	-height => 1 ,
)->pack( -side => 'right' );

$info_text->insert( '1.0' , "Not Logged In" );

&ParseFile( ".gui3rc" );

$this{conn} = IRC::Stream->new( $this{server} , $this{port} );

&loginfunc( );

&ParseBuddies( );

$main->fileevent( $this{conn}->recv_stream( ) , "readable" , \&CatchServer );

MainLoop( );

sub ParseFile
{
	open( F , shift );
	while( <F> ) {
		if( /irc.server: (.*)\n/ ) {
			$this{server} = $1;
		} elsif( /irc.port: (.*)\n/ ) {
			$this{port} = $1;
		} elsif( /session.buddyList: (.*?)\n/ ) {
			$user{buddy} = $1;
		}
	}
	close( F );
}

sub ParseBuddies
{
	return if( ! $user{buddy} );
	if( ! ref $user{buddy} ) {
		open( F , "$user{buddy}" );
		chomp( my @ar = <F> );
		close F;
		$user{buddy} = \@ar;
	}
	$this{conn}->list_on( $user{buddy} );
	$main->after( 20000 , \&ParseBuddies );
	$buddy_list->delete( 0 , 'end' );
}

sub CatchServer
{
	my $handle = $this{conn}->recv_stream( );
	my $msg = { };
	$_ = <$handle>;
	chomp;
	$msg = $this{conn}->parse( $_ );
	if( $msg && $msg->{type} =~ /RECV/i ) {
		&Recv( $msg );
	} elsif( $msg && $msg->{type} =~ /UON/i ) {
		$buddy_list->insert(
			'end' ,
			"$msg->{name}" ,
		);
	} elsif( $msg && $msg->{type} =~ /SON/i ) {
		$info_text->delete( '1.0' , 'end' );
		$info_text->insert( '1.0' , 'Logged on' );
		&ParseBuddies( );
	}
	$main->fileevent( $handle , "readable" , \&CatchServer );
}

sub loginfunc
{
	my $login = $main->DialogBox(
		-title => "Login" ,
		-buttons => [ "Login" , "Quit" ] ,
	);
	$login->add(
		"Label" ,
		-text => "User Name: "
	)->pack( );
	my $username = $login->add(
		"Entry" ,
		-width => 40
	)->pack( );
	$login->add(
		"Label" ,
		-text => "User Info: "
	)->pack( );
	my $userinfo = $login->add(
		"Entry" ,
		-width => 40
	)->pack( );

	my $button;

	while( !( defined( $name ) && length( $name ) ) ) {
		$button = $login->Show( );
		if( $button eq "Login" ) {
			$name = $username->get( );
			$info = $userinfo->get( );
		} elsif( $button eq "Quit" ) {
			&Quit( );
			# returns to run again if cancelled...
		} else {
			undef $name;
		}
	}
	
	$this{conn}->login( $name , $info );
}

sub Recv
{
	my $msg = shift;
	my $Recv = MainWindow->new( );
	$Recv->title( "From $msg->{name}" );
	$Recv->Label(
		-text => "Received from $msg->{name}: " ,
	)->pack( );
	my $text = $Recv->Entry(
		-width => 50 ,
	)->pack( );
	$text->insert( '1' , "$msg->{msg}" );
	my $bottom_frame = $Recv->Frame( )->pack( );
	$bottom_frame->Button(
		-text => "Reply" ,
		-command => [ \&Reply , $msg->{name} ] ,
	)->pack( anchor => "w" );
}

sub Msg
{
	my $username = $buddy_list->get( 'active' );
	my $Msg = MainWindow->new( );
	$Msg->title( "To $username" );
	$Msg->Label(
		-text => "Sending to $username: " ,
	)->pack( );
	my $text = $Msg->Text(
		-width => 50 ,
		-height => 1 ,
	)->pack( );
	my $bottom_frame = $Msg->Frame( )->pack(
		-fill => 'x'
	);
	$bottom_frame->Button(
		-text => "Send" ,
		-command => sub {
			$this{conn}->msg(
				$username ,
				$text->get( '1.0' , 'end' )
			);
		} ,
	)->pack( -side => 'left' );
	$bottom_frame->Button(
		-text => "Clear" ,
		-command => sub {
			$text->delete( '1.0' , 'end' );
		} ,
	)->pack( -side => 'right' );
}

sub Reply
{
	my $username = shift;

	my $Reply = $main->DialogBox(
		-title => "To: $username" ,
		-buttons => [ "Send" , "Cancel" ] ,
	);
	
	$Reply->add(
		"Label" ,
		-text => "Message: "
	)->pack( );
	my $message = $Reply->add(
		"Entry" ,
		-width => 60
	)->pack( );

	my $button;
	
	my $msg;

	$button = $Reply->Show( );
	if( $button eq "Send" ) {
		$msg = $message->get( );
		$this{conn}->msg( $username , $msg );
	}
}

# menu functions
sub Login
{
	$this{conn}->logoff( );
	$this{conn}->login( $user{name} , $user{info} );
}

sub Logoff
{
	$this{conn}->logoff( );
}

sub Quit
{
	my $quitting = $main->DialogBox(
		-title => "Exit?" ,
		-buttons => [ "Exit" , "Cancel" ] ,
	);
	$quitting->add(
		"Label" ,
		-text => "Are you sure you want to exit?"
	)->pack( );

	my $button = $quitting->Show( );
	if( $button eq "Exit" ) {
		$this{conn}->logoff( );
		exit( 0 );
	}
}

sub About
{
	my $about = $main->DialogBox(
		-title => "About" ,
		-buttons => [ "OK" ] ,
	);
	$about->add(
		"Label" ,
		-text => "$this{name} - $this{version}"
	)->pack( );
	$about->add(
		"Label" ,
		-text => "http://aces.sourceforge.net"
	)->pack( );
	$about->Show( );
}
