package CreateClass;

=pod

=head1 NAME

CreateClass - My author was too lazy to write an abstract

=head1 SYNOPSIS

  my $object = CreateClass->new(
      foo  => 'bar',
      flag => 1,
  );
  
  $object->dummy;

=head1 DESCRIPTION

The author was too lazy to write a description.

=head1 METHODS

=cut

use 5.010;
use strict;
use warnings;

our $VERSION = '0.01';

=pod

=head2 new

  my $object = CreateClass->new(
      foo => 'bar',
  );

The C<new> constructor lets you create a new B<CreateClass> object.

So no big surprises there...

Returns a new B<CreateClass> or dies on error.

=cut

sub new {
	my $class = shift;
	my $self  ={
			_fileName => shift,
		 }; 
	
	bless $self, $class;
	return $self;
}

=pod

=head2 dummy

This method does something... apparently.

=cut

sub createClass {
	my $self = shift;
	
	my @strTxt = ( "#! /usr/bin/perl\n", "package $self->{_fileName};\n", "use 5.010;\n",
		"use strict;\n", "use warnings;\n", "our \$VERSION = '0.01';\n", "=pod\nCONSTRUCTOR\n=cut\n",
		"sub new {\n",  "my \$class = shift;\n",  "my \$self  ={\n", "_fileName => shift,\n", "};\n", "bless \$self, \$class;\n",
		"return \$self;\n", "}\n"

		);
	my $fh1;
	my $fname = $self->{_fileName}.".pm"; 
	open($fh1, '>', $fname) or die "Could not open '$self->{_fileName}' $!";
	print $fh1 @strTxt;
	# Do something here
	print "Exit success!";
	return 1;
}

1;

=pod

=head1 SUPPORT

No support is available

=head1 AUTHOR

Copyright 2011 Anonymous.

=cut
