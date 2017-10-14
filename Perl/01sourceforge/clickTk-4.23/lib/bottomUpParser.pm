=pod

=head1 bottomUpParser

	This class implements a simple bottom up parser.

	This class may be used as base class for specialized parsers,
	i.e. to parse Tk commands of different flavours.

=head2 Syntax

	use bottomUpParser;

	my $p = bottomUpParser->new(<options>);
	$self->parse(<options>);
	$self->expected(<list of expected results>);

=head2 Programming notes

=over

=item Base structure

	Constructor blesses a variable of type HASH.

=item Class member

	None

=item Data member

	-tokenList
	-tree
	-expected
	-result

=item Properties

	expected	ref to the expected token structure
	production  iterator to the production (reduce step)
	result      parsed token structure
	tree        ref to definition tree of the expected tokens

=item Constructor

	new (<options)
			whereby options is
				-tokenList, <ref to array>,
				-tree , <ref to array>,
				-production  <callback>

=item Destructor

	destroy

=item Methods

	import           import the constants to the caller' s package
	tokenList        list of the input stream (token)
	new              constructor
	init             instance initiator
	parse            parse process
	optlistMandatory process element of an optional token list (shift step)
	optlistOptional  process element of an mandatory token list (shift step)

=back

=head2 Maintenance

	Author:	Marco
	date:	18.04.2009
	History
			18.04.2009 first draft
			24.04.2009 version 1.02
			30.12.2009 version 1.03
			01.12.2009 version 1.04

=cut

package bottomUpParser;

our $VERSION = 1.04;

=head3 import

	Import the constants in the client's name space

	Imported constants are

		NOTHING
		NEXTTOKEN
		SHIFT
		REDUCE
		TRYNEXTDEF
		TRYAGAIN
		RETURN
		DONE
		SHIFTANDREDUCE
		REDUCEANDSHIFT
		ALL
		OPTLISTOPTIONAL
		OPTLISTMANDATORY

=cut

sub import {
	my $class = shift;
	my $pkg = caller;
	my $constant;
	no strict 'refs';
	## print "\nimporting $class , $pkg\n";
	$constant = "${pkg}::NOTHING";        *$constant = sub(){0};
	$constant = "${pkg}::NEXTTOKEN";      *$constant = sub(){1};
	$constant = "${pkg}::SHIFT";          *$constant = sub(){2};
	$constant = "${pkg}::REDUCE";         *$constant = sub(){4};
	$constant = "${pkg}::TRYNEXTDEF";     *$constant = sub(){8};
	$constant = "${pkg}::TRYAGAIN";       *$constant = sub(){16};
	$constant = "${pkg}::RETURN";         *$constant = sub(){32};
	$constant = "${pkg}::EOL";            *$constant = sub(){64};
	$constant = "${pkg}::DONE";           *$constant = sub(){128};
	$constant = "${pkg}::SHIFTANDREDUCE"; *$constant = sub(){6};
	$constant = "${pkg}::REDUCEANDSHIFT"; *$constant = sub(){6};
	$constant = "${pkg}::ALL";            *$constant = sub(){255};
	$constant = "${pkg}::OPTLISTOPTIONAL";*$constant = sub(@){&optlistOptional(@_)};
	$constant = "${pkg}::OPTLISTMANDATORY";*$constant = sub(@){&optlistMandatory(@_)};
	return 1;
}

=head3 BEGIN

	This sub is used to 'import' the constants
	in the class package itself.

=cut

BEGIN {
	__PACKAGE__->import();
}


=head3 tokenList

	This method copies the tokenlist into a local array
	and save a ref to it into the property tokenList.

=cut

sub tokenList {
	my $self = shift;
	if (@_) {
		my $r = shift;
		$self->{-tokenList} = [ map{"$_"} @$r ];
	}
	return $self->{-tokenList}
}

sub tree {my $self = shift; $self->{-tree} = shift if @_; return $self->{-tree}};
sub production {my $self = shift; $self->{-production} = shift if @_; return $self->{-production}};
sub result {my $self = shift; $self->{-result} = shift if @_; return $self->{-result}};
sub expected {my $self = shift; $self->{-expected} = shift if @_; return $self->{-expected}};

=head3 new

	Instantiate a new parser object.

=cut

sub new {
	my $class = shift;
	my (%args) = @_;
	my $self = bless {} ,$class;
	$self->init(%args);
	return $self;
}

=head3 init

	This method initialize the data members of instance.
	Therefore, it takes the same arglist as the constructor.

=cut

sub init {
	my $self = shift;
	my (%args) = @_;
	$self->tokenList($args{-tokenList}) if exists $args{-tokenList};
	$self->tree($args{-tree}) if exists $args{-tree};
	$self->production($args{-production}) if exists $args{-production};
	$self->result('');
	return 1 ;
}

=head3 parse

	This method parses recursively the tokenlist and
	returns the list of the parsed tokens which are saved
	while the shift steps.

=cut

sub parse {
	my $self = shift;
	my ($tokenList,$actions,$prod) = @_;

	$tokenList = $self->tokenList unless defined $tokenList;
	$actions = $self->tree unless defined $actions;
	$prod = $self->production unless defined $prod;

	main::trace(__PACKAGE__.':: parse');

	my @rv;
	my @values =();
	my $nextStep;
	my $token;

	my $nextToken = sub {$tokenList->[0] };

	my $reduceStep = sub {
			my $token = shift;
			main::trace("reduce $token ");
			my ($id,$production) = &$prod();
			die ("could not reduce token $token") unless &$production($token);
			my $result = $self->result();
			die "token already found" if($result =~ /^$id$/);
			$result = ($result) ? "$result $id" : $id;
			$self->result($result);
			return 1
		};
	my $shiftStep = sub {
		my $token = shift;
		main::trace("shift $token");
		push @values, $token;
		return 1;
	};
	ACTIONS:
	foreach (@$actions) {
		my $action = $_;
		if (ref $action eq 'ARRAY') {
			## TODO instantiate a new parser for the substructure
			my @w = $self->parse($tokenList,$action,$prod); ## dont' forget to specify all arguments !!!
			push @rv, @w;
			$nextStep = NOTHING;
		} else {
			$nextStep = ALL;
			LIST:
			while (($nextStep & TRYAGAIN) && @$tokenList) {
				$token = &$nextToken();
				$nextStep = &$action($token);
				next ACTIONS if ($nextStep == TRYNEXTDEF);
				die "unexpected next step code '$nextStep'" unless($nextStep & ALL || $nextStep == NOTHING);
				&$shiftStep($token) if ($nextStep & SHIFT);
				shift @$tokenList if (($nextStep & NEXTTOKEN) || ($nextStep & SHIFT) || ($nextStep & REDUCE) || $nextStep & EOL);
				last LIST if ($nextStep & DONE || $nextStep & RETURN || $nextStep & TRYNEXTDEF);
			}
			if ($nextStep & EOL) {
				if (@values == 0) {
					push @rv , '' if(&$reduceStep(''));
				} elsif (@values == 1) {
					push @rv , shift (@values) if(&$reduceStep(join ( ' ', @values)));
					@values = ();
				} elsif (@values > 1) {
					push @rv , join (' , ',@values) if(&$reduceStep(join ( ' ', @values)));
					@values = ();
				} else {
					## nothing to do
				}
			} else {
				if (@values == 1) {
					push @rv , shift (@values) if(&$reduceStep(join ( ' ', @values)));
					@values = ();
				} elsif (@values > 1) {
					push @rv , join (' , ',@values) if(&$reduceStep(join ( ' ', @values)));
					@values = ();
				} else {
					## nothing to do
				}
			}
		}
		last ACTIONS unless (@$tokenList);
		last ACTIONS if ($nextStep & DONE || $nextStep & RETURN);
	}
	if (@$tokenList == 0 ) {
		my $e = $self->expected;
		my $r = $self->result;
		main::trace("r = '$r'");
		die "unexpected result '$r'" unless (grep $r eq $_, @$e);
	}
	return wantarray ? @rv : scalar (@rv);
}

=head3 optlistMandatory

	This is a minimal handler for a list element.
	It return true if the element is valid, and
	false when the end of list is encountered.

	TODO : check the existence of the list.

=cut

sub optlistMandatory {
	my $token = shift;
	return 0 if ($token eq ')');
	return 1;
}

=head3 optlistOptional

	This is a minimal handler for a list element.
	It return true if the element is valid, and
	false when the end of list is encountered.

=cut

sub optlistOptional {
	my $token = shift;
	return 0 if ($token eq ')');
	return 1;
}

1; ## make perl happy!

## eop buttomUpParser
