=pod

=head1 ctkClipboard

	Clipboard functions for manipulations on the widget's tree.
	
=head2 Programming notes

=over

=item Class data

	clipboard content (array of items)

=item Member data

	signature

=item Properties

	clipboard	content (array of items)
	signature

=item Methods

	new	(-clear => 1|0, -debug => 0|1)
	destroy 

	clipboard ()

	checkClipboard()
	clipboardClear ()
	clipboardAppend (array of items) 

=back

=head2 Maintenance

	Author:	Marco
	date:	04.01.2007
	History 
			04.01.2007 MO03202 mam First draft

=cut

package ctkClipboard;

use base (qw/ctkBase/);

our $VERSION = 1.01;

my $debug = 0;

my @clipboard=();

use constant SIGNATURE => '#CTK_W';

sub new {
	my $class = shift;
	my (%args) = @_;
	$args{-clear} = 0 unless (exists $args{-clear});
	$debug  = delete $args{-debug} if (exists $args{-debug});
	$class = ref($class) || $class ;
	my $self = {};
	bless  $self, $class;
	$self = undef unless ($self->_init(%args));
	return $self
}

sub destroy {
	my $self = shift;
	@clipboard =();
	$self = undef;
}

sub _init {
	my $self = shift;
	my (%args) = @_;
	my $signature = (exists $args{-signature}) ? $args{-signature}: SIGNATURE;
	$self->signature($ignature);
	return undef unless($args{-clear} || $self->checkClipboard);
	$self->clipboardClear() if ($args{-clear});
	return 1
}

sub signature {
	my $self = shift;
	$self->{_signature} = shift if (@_);
	return $self->{_signature}
}

sub checkClipboard {
	my $self = shift;
	my $signature = $self->signature;
	my $rv = $clipboard[0] =~ /^$signature/;
	return $rv
}

sub clipboard {
	my $self = shift;
	my @rv;
	if (@_) {
		map {
			die "Invalid clipboard item's index '$_'" unless ($_ > 0 && $_ <= $#clipboard)
		} @_;
		@rv = map{$clipboard[$_]} @_
	} else {
		@rv = map{$clipboard[$_]}(1 .. $#clipboard) if (@clipboard > 1)
	}
		return wantarray ?  @rv : scalar(@rv);
}

sub clipboardClear {
	my $self = shift;
	@clipboard = ($self->signature)
}
sub clipboardAppend {
	my $self = shift;
	map {
		push @clipboard, $_;
	} @_;
}

## sub import {}

BEGIN { 1 }
END {1 }

1; ## -----------------------------------
