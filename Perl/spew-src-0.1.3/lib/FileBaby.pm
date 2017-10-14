package FileBaby;


use strict;

###################################################################
### SUB ROUTINE:  new						###
###################################################################
### Author:  Ben Garvey                                      	###
### Date:  September, 2002					###
###								###
### DESCRIPTION:						###
### 								###
### ARGUMENTS:							###
### 								###
### RETURNS:		FileBaby $self				###
###################################################################
sub new
{
	my $self 		= {};

	bless $self;
	return ($self);
}

sub getText
{	my $self = shift;

	# Get the passed in file path
	my $path = $_[0];

	# Get the contents
	my $contents = $self->_getFileText( $path );

	# Return the contents
	return $contents;
}

sub writeText
{	my $self = shift;

	# Get the passed file path
	my $path = $_[0];

	# Get the passed conents
	my $contents = $_[1];

	# Write the data
	$self->_writeFileText( $path, $contents );
}

# Private subroutine that accepts a filename as a string and returns the contents of that file
sub _getFileText
{
	my $self = shift;
	my $filepath = $_[0];

	# Open the file
	open(FILEHANDLE, "<$filepath") or
		die ("Cannot open $filepath");

	my $text = "";
	my $newtext = "";

	# Read the file
	while (read (FILEHANDLE, $newtext, 1))
	{
		$text .= $newtext;
	}

	return $text;	

	close FILEHANDLE;
}

# Private subroutine that accepts a filename as a string and returns the contents of that file
sub _writeFileText
{
	my $self = shift;
	my $filepath = $_[0];
	my $contents = $_[1];

	# Open the file
	open(FILEHANDLE, ">$filepath") or
		die ("Cannot open $filepath");

	my $text = "";
	my $newtext = "";

	print FILEHANDLE $contents;
	print $contents;

	close FILEHANDLE;
	
	print "You are saved!\n"
}

return 1;