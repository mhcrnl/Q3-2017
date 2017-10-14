=pod

=head1 ctkTargetScript

	Class targetScript models the functionality to generate
	the target of type script.
	It derives from class targetCode.

=head2 Syntax


		use ctkTargetScript;;

		ctkTargetScript->generate();

=head2 Programming notes

=over

=item Methods

	new
	destroy
	_init
	generate
	parse
	load
	genTestCode


=back

=head2 Maintenance

	Author:	Marco
	date:	28.10.2006
	History
			28.11.2007 MO03501 mam refactoring

=cut

package ctkTargetScript;

use ctkFile;
use base (qw/ctkTargetCode/);

use Time::localtime;

our $VERSION = 1.01;

our $debug = 0;

my $ctkC;

sub new {
	my $class = shift;
	my (%args) = @_;
	$class = ref($class) || $class ;
	my $self = $class->SUPER::new(%args);
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
	## $self->SUPER::_init(%args);

	return 1
}

sub generate {
	my $self = shift;
	my (%args) = @_;
	my $code = $args{-code};
	my $mw = $args{-mw};
	my $now = $args{-now};

	$ctkC = $main::ctkC unless defined($ctkC);

	$code = $self->genAllVariablesGlobal($code,$mw);

	push @$code , "&main::init();\n";
	push @$code , "\n";

	$self->genGcode($code);

	my $tkCode = $self->gen_TkCode($mw);
	map { push @$code ,$_ } @$tkCode;
	$code = $self->genTestCode($code,$now,$mw);
	push @$code , "\nMainLoop;\n";

	$code = $self->genCallbacks($code,$now);

	return wantarray ? @$code : $code
}

sub parse {
	my $self = shift;
	my (%args) = @_;
	my $rv;
	return $rv
}

sub load {
	my $self = shift;
	my (%args) = @_;
	my $rv;
	return $rv
}

sub genTestCode {
	my $self = shift;
	my ($code,$now,$mw) = @_;
	&main::trace("genTestCode");
	$code = $self->genCalls2Test($code,$now,$mw) if ($main::opt_TestCode);
	return $code
}

## sub import {}

BEGIN { 1 }
END {1 }

1; ## -----------------------------------
