#!/usr/lib/perl
##              -w -d:ptkdb

=pod

=head1 ctkBase

	This class is the base class for all clicktTk classes.

=head2 Syntax

	use ctkBase;
	use base (qw/ctkBase/);

	$self->dump(<values>);
	$self->quoteValue(<values>);
	$self->getDateAndTime();

	$self->trace(<array of strings>);
	$self->log(<array of strings>);

=head2 Programming notes

=over

=item Base structure

	Constructor blesses a variable of type HASH.

=item Class member

	None

=item Data member

	None

=item Properties

	debug

=item Constructor

	new(debug => <debug mode>)
	_init

=item Destructor

destroy

=item Methods

	trace
	Log
	log
	getDateAndTime
	_dump
	dump
	quoteValue

=back

=head2 Maintenance

	Author:	Marco
	date:	01.01.2007
	History
			06.12.2007 refactoring
			14.04.2008 version 1.03
			31.05.2008 version 1.04

=cut

package ctkBase;

use Time::localtime;

our $VERSION = 1.04;

my $debug = 0;

sub debug { my $self = shift; $debug = shift if (@_);return $debug }

sub new {
	my $class = shift;
	my (%args) = @_;
	my $self = {};
	$debug = $args{debug} if exists $args{debug};
	$class = ref($class) || $class ;
	bless  $self, $class;
	$self->_init(%args);

	return $self
}

sub destroy {
	my $self = shift;
}

sub _init {
	my $self = shift;
	my (%args) = @_;
	return 1
}

sub Trace { shift->trace(@_);}
sub trace {
	my $self = shift;
	$self->log(@_) if ($self->debug);
}

sub Log { shift->log(@_)}
sub log {
	my $self = shift;
	map {print "\n\t".$self->getDateAndTime()." $_"} @_;
}

sub getDateAndTime {
	my $self = shift;
	my $now = shift;
	$now = localtime unless(defined($now));

	my $rv = sprintf('%04d %02d %02d - %02d:%02d:%02d',
				  $now->year+1900, $now->mon+1,$now->mday,
				  $now->hour, $now->min, $now->sec) ;
	return $rv;
}

sub _dump {
	my $self = shift;
	my ($data) = @_;
	my $rv;
	my $rData = ref($data) ? $data : \$data;

	my $d = Data::Dumper->new([ $_ ]) ;
	$d->Indent(1) ;
	$d->Terse(1) ;
	$Data::Dumper::Purify = 1;
	if( Data::Dumper->can('Dumpxs') ) {
		$rv = $d->Dumpxs( $rdata ) ;
	} else {
		$rv = $d->Dump( $rData ) ;
	}
	return $rv
}

=head2 dump

	Convert the given arguments to its printable
	form using Data::Dumper

	Return depending on the context either an array of elements or a string concatenating all given
	elements .

	Unlike Data::Dumper methods this methods accept a list of variables or ref to variables.
	A parallel array for the var names isn't required.

	Examples

		my $x = ctkBase->dump( 1 2 3)  ## yields 1 \n 2 \n 3 \n
		my @x = ctkBase->dump( 1 2 3)  ## yields (1 2 3)
		my @x = ctkBase->dump( [qw/1 2 3/])  ## yields [\n 1 \n 2 \n 3\n ] \n

=cut

sub dump {
	my $self = shift;
	my @rv;
	require Data::Dumper;
	@rv = map {
		$self->_dump($_)
	} @_;
	return wantarray ? @rv : join ('',@rv)
}

=head2 quoteValue

	This method returns the given string enclosed in quotation's marks.
	So the argument 123 is returned as a strin containing '123'.
	If the argument is an array, so all elements are quotated.

	Pls note that the method doesn't neither scan the argument itself for
	quotations chars nor check if it has already been quotated.

=cut
sub quoteValue {
	my $self = shift;
	if (wantarray) {
		## return map{$self->quoteValue($_)}@_; deep recursion
		return map{'\''.$_.'\''}@_
	} else {
		return '\''.$_[0].'\'';
	}
}

## sub import {}

BEGIN { 1 }
END {1 }

1; ## -----------------------------------
