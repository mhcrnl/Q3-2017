#!/usr/lib/perl
##              -w -d:ptkdb

=pod

=head1 x_nonVisual

	Demo & test package for non-visual class.

=head2 Syntax

	$t = x_nonVisual->new(-name,'nonVis',-counter, 10, -debug, 0);
	$t->demo();
	$t->test();

=head2 Programming notes

=over

=item None

=back

=head2 Maintenance

	Author:	marco
	date:	08.10.2006
	History
			08.10.2006  mam First draft

=cut

package x_nonVisual;

use Time::localtime;

our $VERSION = 1.01;

our $debug = 0;

sub new {
	my $class = shift;
	my (%args) = @_;
	$class = ref($class) || $class ;
	my $self = {};
	bless  $self, $class;
	$self->_init(%args);

	return $self
}

sub destroy {
	my $self = shift;
	$self->SUPER::destroy(@_);
}

sub _init {
	my $self = shift;
	my (%args) = @_;
	$debug = delete $args{-debug} if exists $args{-debug};
	map {
		my $w = $_;
		$w =~s/^-//;
		$self->{$_} = $args{$_} ;
	} keys %args;
	return 1
}

sub demo {
	shift->Log("x_nonVisual::demo()")
}
sub test {
	my $self = shift;
	$self->Log("x_nonVisual::test(): " . join ' ',sort keys %$self)
}
sub Trace { shift->trace(@_);}
sub trace {
	shift->log(@_) if ($debug);
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

## sub import {}

BEGIN { 1 }
END {1 }

1; ## -----------------------------------
