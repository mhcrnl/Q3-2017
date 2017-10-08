#!/usr/bin/perl -w

# WWW module v2
# Allows the simple creation of websites.
# allows for theme-able websites! see the THEME module for the theme format
# usage:
# use lib 'dirof/modules';
# use WWW;
# my $page = WWW->new( );
# $page->setHead( 'COOL!' );
# $page->setBodyData( 'Body of the Page!' );
# $page->setMenuFile( 'file/menu' );
# $page->setTheme( 'file/theme' );
# $page->createPage( );
# __END__

# Jin-Ho King
# acramon1@linux.com.my
# can be freely distributed under the GPL

use THEME;

package WWW;

# static stuff

my $heading = 'Content-type: text/html\n\n
<html>
<head>
	<title>$this->{head}->{title}</title>
	<base target="_top" href="http://www.acramon1.f2s.com/">
	<link rel="stylesheet" href="$this->{css}">
</head>
';
my $closing = '
</html>
';

# member functions

sub new
{
	my $class = shift;
	my $this = { };
	$class = ref( $class ) || $class;
	$this->{head} = { };
	$this->{head}->{title} = undef;
	$this->{body} = undef;
	$this->{menu} = undef;
	$this->{prop} = { };
	$this->{css} = undef;
	$this->{theme} = THEME->new( );
	bless( $this , $class );
	return( $this );
}

sub setHead
{
	my( $this , $title ) = @_;
	$this->{head}->{title} = $title;
	return;
}

sub setBody
{
	my( $this , $fileName ) = @_;
	if( -s $fileName ) {
		open BODY , $fileName || die;
		flock BODY , 1; # shared lock
		$this->{body} = join( '' , <BODY> );
		flock BODY , 8; # unlock
		close BODY;
	} else {
		$this->{body} = "\n* Body $fileName could not be found! *\n\n";
	}
	return;
}

sub setBodyData
{
	my( $this , $data ) = @_;
	$this->{body} = $data;
}
	
sub setMenuFile
{
	my( $this , $fileName ) = @_;
	if( -s $fileName ) {
		$this->{menu} = $fileName;
	} else {
		print "\n* Menu $fileName not found! *\n\n";
		$this->{css} = "$ENV{'DOCUMENT_ROOT'}/dat/menu/main.menu";
	}
}

sub setCSS
{
	my( $this , $fileName ) = @_;
	if( -s $fileName ) {
		$this->{css} = $fileName;
	} else {
		print "\n* CSS $fileName not found! *\n\n";
		$this->{css} = 'dat/css/default.css';
	}
	return;
}

sub setTheme
{
	my( $this , $fileName ) = @_;
	$this->{theme}->loadTheme( $fileName );
	return;
}

sub createPage
{
	my( $this ) = @_;
	$| = 1; # it's faster this way
	$this->{theme}->loadTheme( "$ENV{'DOCUMENT_ROOT'}/dat/themes/default.theme" )
		if( !defined $this->{theme}->returnName( ) );
	$this->{css} = $this->{theme}->returnCSS( )
		if( !defined $this->{css} );
	$this->priv_setMenu( $this->{menu} , $this->{theme}->returnMenu( ) );
	$this->{prop} = $this->{theme}->returnProp( );
	
	eval( "print <<EODOC\n".$heading."\nEODOC\n" );
	eval( "print <<EODOC\n".$this->{theme}->returnData( )."\nEODOC\n" );
	print $@."\n";
	eval( "print <<EODOC\n".$closing."\nEODOC\n" );
	return;
}

sub priv_setMenu # private
{
	my( $this , $fileName , $or ) = @_;
	if( -s $fileName ) {
		open MENU , $fileName || die;
		flock MENU , 1; # shared lock
		CASE: {
		$_ = $or;
		$this->{menu} = ''; # just in case
		( !defined || $_ == 1 ) && do { # horizontal
			while ( <MENU> ) {
				chomp $_;
				$this->{menu} .= "$_ | ";
			}
			$this->{menu} = " | $this->{menu}";
			last CASE;
		};
		( $_ == 2 ) && do {
			while ( <MENU> ) {
				chomp;
				$this->{menu} .= "$_ <br>\n ";
			}
			# $this->{menu} = "<br>\n $this->{menu}";
			last CASE;
		};
		do {
			$this->{menu} = "\n* Orientation $or invalide! *\n\n";
			last CASE;
		}
		} # end case
		flock MENU , 8; # unlock
		close MENU;
	} else {
		$this->{menu} = "\n* Menu $fileName could not be found! *\n\n";
	}
	return;
}

1;
