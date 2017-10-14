=head1 ctkDescriptor

	The class ctkDescriptor models a widget which has been defined by the user
	as an element of the project.

=head2 Properties

	id
	parent
	type
	opt
	geom
	order


=head2 Methods

	new
	destroy
	trace

=cut

package ctkDescriptor;

use strict;

use base (qw/ctkBase/);

use vars qw/$VERSION/;

$VERSION = 1.02;

sub new {
	my $class = shift;
	my (%args) = @_;
	my $self = {} ;
	map {$self->{$_} = delete $args{$_}} keys %args;
	$self->{'scrolledclass'} = 'Text' if ($self->{'type'} eq 'Scrolled' && ! exists $self->{'scrolledclass'});
	bless $self, $class;

	return $self
}

sub scrolledclass {
	my $self = shift;
	my $rv;
	$self->{'scrolledclass'} = shift if (@_);
	$rv = $self->{'scrolledclass'} if (exists $self->{'scrolledclass'});
	return  $rv;
}
sub id {
	my $self = shift;
	my $rv;
	$self->{'id'} = shift if (@_);
	$rv = $self->{'id'} if (exists $self->{'id'});
	return  $rv;
}
sub parent {
	my $self = shift;
	my $rv;
	$self->{'parent'} = shift if (@_);
	$rv = $self->{'parent'} if (exists $self->{'parent'});
	return  $rv;
}
sub type {
	my $self = shift;
	my $rv;
	$self->{'type'} = shift if (@_);
	$rv = $self->{'type'} if (exists $self->{'type'});
	return  $rv;
}
sub opt {
	my $self = shift;
	my $rv;
	$self->{'opt'} = shift if (@_);
	$rv = $self->{'opt'} if (exists $self->{'opt'});
	return  $rv;
}
sub geom {
	my $rv;
	my $self = shift;
	$self->{'geom'} = shift if (@_);
	$rv = $self->{'geom'} if (exists $self->{'geom'});
	return  $rv;
}
sub order {
	my $self = shift;
	my $rv;
	$self->{'order'} = shift if (@_);
	$rv = $self->{'order'} if (exists $self->{'order'});
	return  $rv;
}

sub destroy {
	my $self = shift;
	$self = {};
}
sub stringify {
	my $self = shift;
	return defined($_[0]) ? "'$_[0]'" : 'UNDEF';
}

sub dump {
	my $self = shift;
	my $s = '';
	map {
		$s .= "$_ = ".$self->stringify($self->$_())." "
	} sort keys %$self;
	return $s;
}

BEGIN {1}
END{1}
1; ## make perl happy ...
