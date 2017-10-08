#!/usr/bin/perl -w

# THEME module v1
# For implementing the theming ability of WWW

# Jin-Ho King
# acramon1@linux.com.my
# freely distributable under the GPL

package THEME;

sub new
{
	my $class = shift;
	my $this = { };
	$class = ref( $class ) || $class;
	$this->{name} = undef;
	$this->{css} = undef;
	$this->{menu} = undef;
	$this->{prop} = { };
	$this->{prop}->{bgcolor} = undef;
	$this->{prop}->{fgcolor} = undef;
	$this->{prop}->{brcolor} = undef;
	$this->{prop}->{lncolor} = undef;
	$this->{prop}->{vlcolor} = undef;
	$this->{data} = undef;
	bless( $this , $class );
	return( $this );
}

sub returnName
{
	my $this = shift;
	return( $this->{name} );
}

sub returnCSS
{
	my $this = shift;
	return( $this->{css} );
}

sub returnMenu
{
	my $this = shift;
	return( $this->{menu} );
}

sub returnProp
{
	my $this = shift;
	return( $this->{prop} );
}

sub returnData
{
	my $this = shift;
	return( $this->{data} );
}

sub loadTheme
{
	my( $this , $fileName ) = @_;
	if( !( -s $fileName ) ) {
		print "\n* File $fileName does not exist! *\n\n";
		return( 0 );
	}
	open( FILE , $fileName );
	flock( FILE , 1 );
	$_ = join( '', <FILE> );
	flock( FILE , 8 );
	close( FILE );
#	print "\n* TEST: *\n$_\n* END TEST *\n\n";
	if( !m{<theme>(.*)</theme>}is ) {
		print "\n* No theme found in $fileName! *\n\n";
		return( 0 );
	}
	$_ = $1;
	if( !m{<name>(.*?)</name>}is ) {
		print "\n* No <name></name> in $fileName *\n\n";
		return( 0 );
	}
	$this->{name} = $1;
	if( !m{<css>(.*?)</css>}is ) {
		print "\n* No <css></css> in $fileName *\n\n";
		return( 0 );
	}
	$this->{css} = $1;
	if( !m{<menu>(.*?)</menu>}is ) {
		print "\n* No <menu></menu> in $fileName *\n\n";
		return( 0 );
	}
	$this->{menu} = $1;
	if( !m{<properties>(.*?)</properties>}is ) {
		print "\n* No <properties></properties> in $fileName *\n\n";
		return( 0 );
	}
	my $tmpprop = $1;
	$this->{prop}->{bgcolor} = $1 if( $tmpprop =~ /bgcolor => '(.*)'/i );
	$this->{prop}->{fgcolor} = $1 if( $tmpprop =~ /fgcolor => '(.*)'/i );
	$this->{prop}->{brcolor} = $1 if( $tmpprop =~ /brcolor => '(.*)'/i );
	$this->{prop}->{lncolor} = $1 if( $tmpprop =~ /lncolor => '(.*)'/i );
	$this->{prop}->{vlcolor} = $1 if( $tmpprop =~ /vlcolor => '(.*)'/i );
	if( !m{<data>(.*?)</data>}is ) {
		print "\n* No <data></data> in $fileName *\n\n";
		return( 0 );
	}
	$this->{data} = $1;
	return( 1 );
}

1;
