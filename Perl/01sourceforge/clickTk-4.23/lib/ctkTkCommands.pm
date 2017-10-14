=head1 ctkTkCommands

	This module contains some classes
	which model various Tk constructor messages used
	by clickTk.
	These classes are used mainly to decode
	generated widget constructor's messages during the
	open process of a project.

	Therefore they are not applicable to any Tk constructor commands.

=head3 Summary

=over

=item tkCommand

=item tkCommandAnon

=item tkCommandScrolled

=item menuCommand

=back

=head2 Notes

	None.

=head2 Maintenance

	Author:	Marco
	date:	18.04.2009
	History
			18.04.2009 first draft
			01.12.2009 version 1.02

=head2 Classes

=head3 menuCommand

	This class defines the parser to handle with a specific Tk command sequence
	which is used by clickTk to define Menu items.

	These sequencies may look like this skeleton

		<$id> = <virtual_parent> -> Menu_class (<optional list>); <parent> = configure(-menu => <$menuConfig> ) ;

	whereby the items

		<$id>, <virtual_parent> <menu_class>, <parent> and <$menuConfig>

	are returned in a list.

=cut

package ctkTkCommands ;
{
our $VERSION = '1.02';

1; # eop
}


package menuCommand;
{
	use bottomUpParser 1.02;
	use base qw(bottomUpParser) ;

our $VERSION = '1.01';

sub new {
	my $class = shift;
	my (%args) = @_;

	die "missing mandatory tokenList" unless exists $args{-tokenList};

	return $class->SUPER::new(%args);
}

sub init {
	my $self = shift;
	my (%args) = @_;
	my $tokenList = $args{-tokenList} if exists $args{-tokenList};

	my $productions = [
		['id',        sub { my $v = shift; return 1 if ($v =~ /^\$\w+$/); return 0}],
		['vparent',   sub { my $v = shift; return 1 if ($v =~ /^\$\w+$/); return 0}],
		['class',     sub { my $v = shift; return 1 if ($v =~ /^menu$/i); return 0}],
		['parent',    sub { my $v = shift; return 1 if ($v =~ /^\$\w+$/); return 0}],
		['menuConfig',sub { my $v = shift; return 1 if ($v =~ /^\$\w+$/); return 0}]
		] ;

	my $tree = [
		sub{ my $tok = shift; return SHIFT if $tok =~ /^\$\w+/ || die "missing id"},
		sub{ my $tok = shift; return NEXTTOKEN if $tok eq '='  || die "missing ="},
		sub{ my $tok = shift; return SHIFT if $tok =~ /^\$\w+/ || die"missing parent"},
		sub{ my $tok = shift; return NEXTTOKEN if $tok eq '->' || die "missing ->"},
		sub{ my $tok = shift; return SHIFT if $tok =~/^Menu$/i || die "invalid class"},
		sub{ my $tok = shift; return NEXTTOKEN if ($tok eq '(') || die "missing ("},
		sub{ return NEXTTOKEN+TRYAGAIN if (OPTLISTOPTIONAL(@_)); return TRYNEXTDEF},
		sub{ my $tok = shift; return NEXTTOKEN if ($tok eq ')') || die "missing )" },
		sub{ my $tok = shift; return NEXTTOKEN if $tok eq ';'; die "missing ;"},
		[
			sub{ my $tok = shift; return SHIFT if $tok =~ /^\$\w+$/; die "missing parent"},
			sub{ my $tok = shift; return NEXTTOKEN if $tok eq '->' ; die "missing ->"},
			sub{ my $tok = shift; return NEXTTOKEN if $tok eq 'configure' ; die "missing message configure"},
			sub{ my $tok = shift; return NEXTTOKEN if $tok eq '(' ; die "missing ("},
			sub{ my $tok = shift; return NEXTTOKEN if $tok eq '-menu' ;  die "missing -menu"},
			sub{ my $tok = shift; return NEXTTOKEN if $tok =~ /^(,|=>)$/ ; return TRYNEXTDEF},
			sub{ my $tok = shift; return SHIFT if $tok =~ /^\$\w+$/ ; die "missing menuConfig"},
			sub{ my $tok = shift; return NEXTTOKEN if $tok eq ')' ;  die "missing "},
			sub{ my $tok = shift; return DONE if $tok eq ';' ;  die "missing "},
			#[
			#	sub{return DONE unless (@$tokenList); die "too much token"}
			#]
		]
	];

	my $id = 0;
	my $prod = sub {
		return wantarray ? @{$productions->[$id++]} : scalar ($productions->[$id++]);
	};

	$self->SUPER::init(-tokenList, $tokenList, -tree => $tree, -production => $prod);
	$self->expected(["id vparent class parent menuConfig"]);
	return 1
}

sub parse {
	my $self = shift;
	my ($tokenList,$tree,$prod) = @_;

	return $self->SUPER::parse($tokenList,$tree,$prod);
}
1;
} ## eop

=head3 tkCommandx

	This class defines the parser to handle with widget
	constructor messages.
	These messages may look like this skeleton

	<$id> = <$parent> -> <widget class> ([<options>])[ -> <geom magr> [([<geom options>])] ;

	whereby the items

	<$id>, <$parent>, <widget class> <options>, <geom magr> and <geom options>

	are returned in a list.

=cut


package tkCommand ;
{
	use bottomUpParser 1.04;
	use base qw(bottomUpParser) ;

sub new {
	my $class = shift;
	my (%args) = @_;

	die "missing mandatory tokenList" unless exists $args{-tokenList};

	return $class->SUPER::new(%args);
}

sub init {
	my $self = shift;
	my (%args) = @_;
	my $tokenList = $args{-tokenList} if exists $args{-tokenList};
	my $productions = [
		['id',     sub { my $v = shift; return 1 if ($v =~ /^\$\w+$/); return 0}],
		['parent', sub { my $v = shift; return 1 if ($v =~ /^\$\w+$/); return 0}],
		['class',  sub { my $v = shift; return 1 if ($v =~ /^\w+$/); return 0}],
		['opt',    sub { my $v = shift; return 1 if ($v =~ /\S*/); return 0}],
		['geom',   sub { my $v = shift; return 1 if ($v =~ /^(pack|grid|format|place)$/); return 0}],
		['geomopt',sub { my $v = shift; return 1 if ($v =~ /\S*/); return 0}]
		] ;

	my $tree = [
		sub{ my $tok = shift; return SHIFT if $tok =~ /^\$\w+/ || die "missing id"},
		sub{ my $tok = shift; return NEXTTOKEN if $tok eq '='  || die "missing ="},
		sub{ my $tok = shift; return SHIFT if $tok =~ /^\$\w+/ || die"missing parent"},
		sub{ my $tok = shift; return NEXTTOKEN if $tok eq '->' || die "missing ->"},
		sub{ my $tok = shift; return SHIFT if $tok =~/\w+/     || die "missing class"},
		sub{ my $tok = shift; return DONE if $tok eq ';'; return TRYNEXTDEF},
		[
			sub{ my $tok = shift; return NEXTTOKEN if ($tok eq '(') ; return DONE},
			sub{ return SHIFT+TRYAGAIN if OPTLISTMANDATORY(@_); return TRYNEXTDEF},
			sub{ my $tok = shift; return DONE+EOL if ($tok eq ')') || die "missing )" },
		],
		sub{ my $tok = shift; return DONE if $tok eq ';'; return TRYNEXTDEF},
		sub{ my $tok = shift; return NEXTTOKEN if $tok eq '->'; return TRYNEXTDEF},
		sub{ my $tok = shift; return SHIFT if $tok =~ /^pack|grid|format|place/i; return TRYNEXTDEF},
		sub{ my $tok = shift; return DONE if $tok eq ';'; return TRYNEXTDEF},
		[
			sub{ my $tok = shift; return NEXTTOKEN if $tok eq '('; return DONE },
			sub{ return SHIFT+TRYAGAIN if OPTLISTOPTIONAL(@_); return TRYNEXTDEF},
			sub{ my $tok = shift; return DONE+EOL if $tok eq ')' || die "missing )" },
		],
		sub{ my $tok = shift; return DONE if $tok eq ';'; die "missing ';'"},
	] ;

	my $id = 0;
	my $prod = sub {
		return wantarray ? @{$productions->[$id++]} : scalar ($productions->[$id++]);
	} ;

	$self->SUPER::init(-tokenList, $tokenList, -tree => $tree, -production => $prod);
	$self->expected([
		"id parent class",
		"id parent class opt",
		"id parent class opt geom",
		"id parent class opt geom geomopt"
		]);
  	return 1
}

sub parse {
	my $self = shift;
	my ($tokenList,$tree,$prod) = @_;

	return $self->SUPER::parse($tokenList,$tree,$prod);
}
1;
} ## eop


=head3 tkCommand_first_edition

	This class defines the parser to handle with widget
	constructor messages.
	These messages may look like this skeleton

	<$id> = <$parent> -> <widget class> ([<options>])[ -> <geom magr> [([<geom options>])] ;

	whereby the items

	<$id>, <$parent>, <widget class> <options>, <geom mgr> and <geom options>

	are returned in a list.

=cut

package tkCommand_first_edition;
{
	use bottomUpParser 1.03;
	use base qw(bottomUpParser) ;

our $VERSION = '1.03';

sub new {
	my $class = shift;
	my (%args) = @_;

	die "missing mandatory tokenList" unless exists $args{-tokenList};

	return $class->SUPER::new(%args);
}

sub init { shift->SUPER::init(@_) }

sub init0 {
	my $self = shift;
	my (%args) = @_;
	my $tokenList = $args{-tokenList} if exists $args{-tokenList};
	my $productions = [
		['id',     sub { my $v = shift; return 1 if ($v =~ /^\$\w+$/); return 0}],
		['parent', sub { my $v = shift; return 1 if ($v =~ /^\$\w+$/); return 0}],
		['class',  sub { my $v = shift; return 1 if ($v =~ /^\w+$/); return 0}],
		['geom',   sub { my $v = shift; return 1 if ($v =~ /^(pack|grid|format|place)$/); return 0}],
		] ;

	my $tree = [
		sub{ my $tok = shift; return SHIFT if $tok =~ /^\$\w+/ || die "missing id"},
		sub{ my $tok = shift; return NEXTTOKEN if $tok eq '='  || die "missing ="},
		sub{ my $tok = shift; return SHIFT if $tok =~ /^\$\w+/ || die"missing parent"},
		sub{ my $tok = shift; return NEXTTOKEN if $tok eq '->' || die "missing ->"},
		sub{ my $tok = shift; return SHIFT if $tok =~/\w+/     || die "missing class"},
		sub{ my $tok = shift; return DONE if $tok eq ';'; return TRYNEXTDEF},
		#[
		#	sub {return DONE unless (@$tokenList); return TRYNEXTDEF}
		#],
		sub{ my $tok = shift; return NEXTTOKEN if $tok eq '->'; die "missing ->"},
		sub{ my $tok = shift; return SHIFT if $tok =~ /^pack|grid|format|place/i; die "missing geom manager"},
		sub{ my $tok = shift; return DONE if $tok eq ';'; die "missing ';'"},
		#sub{ my $tok = shift; return NEXTTOKEN if $tok eq ';'; return TRYNEXTDEF},
		#[
		#	sub {return DONE unless (@$tokenList); return TRYNEXTDEF}
		#]
	] ;

	my $id = 0;
	my $prod = sub {
		return wantarray ? @{$productions->[$id++]} : scalar ($productions->[$id++]);
	} ;

	$self->SUPER::init(-tokenList, $tokenList, -tree => $tree, -production => $prod);
	$self->expected([
		"id parent class",
		"id parent class geom",
		]);
  	return 1
}

sub init0x {
	my $self = shift;
	my (%args) = @_;
	my $tokenList = $args{-tokenList} if exists $args{-tokenList};
	my $productions = [
		['id',     sub { my $v = shift; return 1 if ($v =~ /^\$\w+$/); return 0}],
		['parent', sub { my $v = shift; return 1 if ($v =~ /^\$\w+$/); return 0}],
		['class',  sub { my $v = shift; return 1 if ($v =~ /^\w+$/); return 0}],
		['geom',   sub { my $v = shift; return 1 if ($v =~ /^(pack|grid|format|place)$/); return 0}],
		] ;

	my $tree = [
		sub{ my $tok = shift; return SHIFT if $tok =~ /^\$\w+/ || die "missing id"},
		sub{ my $tok = shift; return NEXTTOKEN if $tok eq '='  || die "missing ="},
		sub{ my $tok = shift; return SHIFT if $tok =~ /^\$\w+/ || die"missing parent"},
		sub{ my $tok = shift; return NEXTTOKEN if $tok eq '->' || die "missing ->"},
		sub{ my $tok = shift; return SHIFT if $tok =~/\w+/     || die "missing class"},
		sub{ my $tok = shift; return DONE if $tok eq ';'; return TRYNEXTDEF},
		sub{ my $tok = shift; return NEXTTOKEN if $tok eq '(' || die "missing ("},
		sub{ my $tok = shift; return NEXTTOKEN if $tok eq ')' || die "missing )" },
		sub{ my $tok = shift; return DONE if $tok eq ';'; return TRYNEXTDEF},
		sub{ my $tok = shift; return NEXTTOKEN if $tok eq '->'; return TRYNEXTDEF},
		sub{ my $tok = shift; return SHIFT if $tok =~ /^pack|grid|format|place/i; return TRYNEXTDEF},
		sub{ my $tok = shift; return DONE if $tok eq ';'; return TRYNEXTDEF},
		sub{ my $tok = shift; return NEXTTOKEN if $tok eq '('; return TRYNEXTDEF },
		sub{ my $tok = shift; return NEXTTOKEN if $tok eq ')' || die "missing )" },
		sub{ my $tok = shift; return DONE if $tok eq ';'; die "missing ';'"}
	] ;

	my $id = 0;
	my $prod = sub {
		return wantarray ? @{$productions->[$id++]} : scalar ($productions->[$id++]);
	} ;

	$self->SUPER::init(-tokenList, $tokenList, -tree => $tree, -production => $prod);
	$self->expected([
		"id parent class ",
		"id parent class geom",
		]);
  	return 1
}

sub init1 {
	my $self = shift;
	my (%args) = @_;
	my $tokenList = $args{-tokenList} if exists $args{-tokenList};
	my $productions = [
		['id',     sub { my $v = shift; return 1 if ($v =~ /^\$\w+$/); return 0}],
		['parent', sub { my $v = shift; return 1 if ($v =~ /^\$\w+$/); return 0}],
		['class',  sub { my $v = shift; return 1 if ($v =~ /^\w+$/); return 0}],
		['opt',    sub { my $v = shift; return 1 if ($v =~ /\S*/); return 0}],
		['geom',   sub { my $v = shift; return 1 if ($v =~ /^(pack|grid|format|place)$/); return 0}],
		['geomopt',sub { my $v = shift; return 1 if ($v =~ /\S*/); return 0}]
		] ;

	my $tree = [
		sub{ my $tok = shift; return SHIFT if $tok =~ /^\$\w+/ || die "missing id"},
		sub{ my $tok = shift; return NEXTTOKEN if $tok eq '='  || die "missing ="},
		sub{ my $tok = shift; return SHIFT if $tok =~ /^\$\w+/ || die"missing parent"},
		sub{ my $tok = shift; return NEXTTOKEN if $tok eq '->' || die "missing ->"},
		sub{ my $tok = shift; return SHIFT if $tok =~/\w+/     || die "missing class"},
		sub{ my $tok = shift; return DONE if $tok eq ';'; return TRYNEXTDEF},

	sub{ my $tok = shift; return NEXTTOKEN if $tok eq '(' || die "missing ("},
		sub{ return SHIFT+TRYAGAIN if OPTLISTMANDATORY(@_); return TRYNEXTDEF+EOL},
		sub{ my $tok = shift; return NEXTTOKEN if $tok eq ')' || die "missing )" },
		sub{ my $tok = shift; return DONE if $tok eq ';'; return TRYNEXTDEF},

		sub{ my $tok = shift; return NEXTTOKEN if $tok eq '->'; return TRYNEXTDEF},
		sub{ my $tok = shift; return SHIFT if $tok =~ /^pack|grid|format|place/i; return TRYNEXTDEF},
		sub{ my $tok = shift; return DONE if $tok eq ';'; return TRYNEXTDEF},

		sub{ my $tok = shift; return NEXTTOKEN if $tok eq '('; return TRYNEXTDEF },
		sub{ return SHIFT+TRYAGAIN if OPTLISTOPTIONAL(@_); return TRYNEXTDEF+EOL},
		sub{ my $tok = shift; return NEXTTOKEN if $tok eq ')' || die "missing )" },
		sub{ my $tok = shift; return DONE if $tok eq ';'; die "missing ';'"}

	] ;

	my $id = 0;
	my $prod = sub {
		return wantarray ? @{$productions->[$id++]} : scalar ($productions->[$id++]);
	} ;

	$self->SUPER::init(-tokenList, $tokenList, -tree => $tree, -production => $prod);
	$self->expected([
		"id parent class",
		"id parent class opt",
		"id parent class opt geom",
		"id parent class opt geom geomopt"
		]);
  	return 1
}

sub parse {
	my $self = shift;
	my ($tokenList,$tree,$prod) = @_;
	$tokenList = $self->tokenList unless defined $tokenList;
	$tree = $self->tree unless defined $tree;
	$prod = $self->production unless defined $prod;

	my $patternList = [ \&init0, \&init0x, \&init1 ];

	my @rv;
	foreach my $pattern (@$patternList) {
		$self->$pattern(-tokenList, $tokenList);
		eval {@rv = $self->SUPER::parse();};
		return (@rv) unless ($@);
	}
	die "$@";
}
1;
} ## eop


=head3 tkCommand_old

	This class defines the parser to handle with widget
	constructor messages.
	These messages may look like this skeleton

	<$id> = <$parent> -> <widget class> ([<options>])[ -> <geom magr> [([<geom options>])] ;

	whereby the items

	<$id>, <$parent>, <widget class> <options>, <geom magr> and <geom options>

	are returned in a list.

=cut


package tkCommand_old ;
{
	use bottomUpParser 1.02;
	use base qw(bottomUpParser) ;

sub new {
	my $class = shift;
	my (%args) = @_;

	die "missing mandatory tokenList" unless exists $args{-tokenList};

	return $class->SUPER::new(%args);
}

sub init {
	my $self = shift;
	my (%args) = @_;
	my $tokenList = $args{-tokenList} if exists $args{-tokenList};
	my $productions = [
		['id',     sub { my $v = shift; return 1 if ($v =~ /^\$\w+$/); return 0}],
		['parent', sub { my $v = shift; return 1 if ($v =~ /^\$\w+$/); return 0}],
		['class',  sub { my $v = shift; return 1 if ($v =~ /^\w+$/); return 0}],
		['opt',    sub { my $v = shift; return 1 if ($v =~ /\S*/); return 0}],
		['geom',   sub { my $v = shift; return 1 if ($v =~ /^(pack|grid|format|place)$/); return 0}],
		['geomopt',sub { my $v = shift; return 1 if ($v =~ /\S*/); return 0}]
		] ;

	my $tree = [
		sub{ my $tok = shift; return SHIFT if $tok =~ /^\$\w+/ || die "missing id"},
		sub{ my $tok = shift; return NEXTTOKEN if $tok eq '='  || die "missing ="},
		sub{ my $tok = shift; return SHIFT if $tok =~ /^\$\w+/ || die"missing parent"},
		sub{ my $tok = shift; return NEXTTOKEN if $tok eq '->' || die "missing ->"},
		sub{ my $tok = shift; return SHIFT if $tok =~/\w+/     || die "missing class"},
		sub{ my $tok = shift; return NEXTTOKEN if $tok eq ';'; return TRYNEXTDEF},
		[
				sub {return DONE unless (@$tokenList); return TRYNEXTDEF}
		],
		sub{ my $tok = shift; return NEXTTOKEN if ($tok eq '(') || die "missing ("},
		sub{ return SHIFT+TRYAGAIN if OPTLISTMANDATORY(@_); return TRYNEXTDEF},
		sub{ my $tok = shift; return NEXTTOKEN if ($tok eq ')') || die "missing )" },
		sub{ my $tok = shift; return NEXTTOKEN if $tok eq ';'; return TRYNEXTDEF},
		[
				sub {return DONE unless (@$tokenList); return TRYNEXTDEF}
		],
		sub{ my $tok = shift; return NEXTTOKEN if $tok eq '->'; return TRYNEXTDEF},
		sub{ my $tok = shift; return SHIFT if $tok =~ /^pack|grid|format|place/i; return TRYNEXTDEF},
		sub{ my $tok = shift; return NEXTTOKEN if $tok eq ';'; return TRYNEXTDEF},
		[
			sub{return DONE unless (@$tokenList); return TRYNEXTDEF}
		],
		sub{ my $tok = shift; return NEXTTOKEN if $tok eq '('; return TRYNEXTDEF },
		sub{ return SHIFT+TRYAGAIN if OPTLISTOPTIONAL(@_); return TRYNEXTDEF},
		sub{ my $tok = shift; return NEXTTOKEN if $tok eq ')' || die "missing )" },
		sub{ my $tok = shift; return NEXTTOKEN if $tok eq ';'; return TRYNEXTDEF},
		[
			sub{return DONE unless (@$tokenList); die"too much token"}
		]
	] ;

	my $id = 0;
	my $prod = sub {
		return wantarray ? @{$productions->[$id++]} : scalar ($productions->[$id++]);
	} ;

	$self->SUPER::init(-tokenList, $tokenList, -tree => $tree, -production => $prod);
	$self->expected([
		"id parent class",
		"id parent class opt",
		"id parent class opt geom",
		"id parent class opt geom geomopt"
		]);
  	return 1
}

sub parse {
	my $self = shift;
	my ($tokenList,$tree,$prod) = @_;

	return $self->SUPER::parse($tokenList,$tree,$prod);
}
1;
} ## eop


=head3 tkCommandScrolled

	This class defines the parser to handle with scrolled widget
	constructor messages.
	These messages may looks like this skeleton

	<$id> = <$parent> -> Scrolled(<scrolled class> [, <options>])[ -> <geom magr> [([<geom options>])] ;


	whereby the items

	<$id>, <$parent>, <scrolled class> <options>, <geom magr> and <geom options>

	are returned in a list.

=cut

package tkCommandScrolled;
{
	use bottomUpParser 1.02;
	use base qw(bottomUpParser) ;

our $VERSION = '1.01';

sub new {
	my $class = shift;
	my (%args) = @_;

	die "missing mandatory tokenList" unless exists $args{-tokenList};

	return $class->SUPER::new(%args);
}

sub init {
	my $self = shift;
	my (%args) = @_;
	my $tokenList = $args{-tokenList} if exists $args{-tokenList};

	my $productions = [
		['id',       sub { my $v = shift; return 1 if ($v =~ /^\$\w+$/); return 0}],
		['parent',   sub { my $v = shift; return 1 if ($v =~ /^\$\w+$/); return 0}],
		['scrolled', sub { my $v = shift; return 1 if ($v =~ /^Scrolled$/i); return 0}],
		['class',    sub { my $v = shift; return 1 if ($v =~ /^'*\w+'*$/); return 0}],
		['opt',      sub { my $v = shift; return 1 if ($v =~ /^.+$/); return 0}],
		['geom',     sub { my $v = shift; return 1 if ($v =~ /^(pack|grid|format|place)$/); return 0}],
		['geomopt',  sub { my $v = shift; return 1 if ($v =~ /\S*/); return 0}]
		] ;

	my $tree = [
		sub{ my $tok = shift; return SHIFT if $tok =~ /^\$\w+/ || die "missing id"},
		sub{ my $tok = shift; return NEXTTOKEN if $tok eq '=' || die "missing ="},
		sub{ my $tok = shift; return SHIFT if $tok =~ /^\$\w+/ || die"missing parent"},
		sub{ my $tok = shift; return NEXTTOKEN if $tok eq '->' || die "missing ->"},
		sub{ my $tok = shift; return SHIFT if $tok =~ /\w+/ || die "missing class Scrolled"},
		[
			sub{ my $tok = shift; return NEXTTOKEN if ($tok eq '('); return DONE},
			sub{ my $tok = shift; return SHIFT if ($tok =~ /^'*\w+'*/) || die "missing scrolled class"},
			sub{ return SHIFT+TRYAGAIN if OPTLISTOPTIONAL(@_); return TRYNEXTDEF},
			sub{ my $tok = shift; return DONE+EOL if ($tok eq ')') || die "missing )" },
		],
		sub{ my $tok = shift; return DONE if $tok eq ';'; return TRYNEXTDEF},
		sub{ my $tok = shift; return NEXTTOKEN if $tok eq '->'; return TRYNEXTDEF},
		sub{ my $tok = shift; return SHIFT if $tok =~ /^pack|grid|format|place/i; return TRYNEXTDEF},
		sub{ my $tok = shift; return DONE if $tok eq ';'; return TRYNEXTDEF},
		[
			sub{ my $tok = shift; return NEXTTOKEN if $tok eq '('; return DONE },
			sub{ return SHIFT+TRYAGAIN if OPTLISTOPTIONAL(@_); return TRYNEXTDEF},
			sub{ my $tok = shift; return DONE+EOL if $tok eq ')' || die "missing )" },
		],
		sub{ my $tok = shift; return DONE if $tok eq ';'; die "missing ';'"}
	] ;

	my $id = 0;
	my $prod = sub {
		return wantarray ? @{$productions->[$id++]} : scalar ($productions->[$id++]);
	};

	$self->SUPER::init(-tokenList, $tokenList, -tree => $tree, -production => $prod);
	$self->expected([
		"id parent scrolled class" ,
		"id parent scrolled class opt",
		"id parent scrolled class opt geom",
		"id parent scrolled class opt geom geomopt"
		]);
	return 1
}

sub parse {
	my $self = shift;
	my ($tokenList,$tree,$prod) = @_;

	return $self->SUPER::parse($tokenList,$tree,$prod);
}
1;
} ## eop

=head3 tkCommandAnon

	This class defines the parser to handle with anonimous widget
	constructor messages. Thereby, the specification 'anonimous' means that
	the result of the messages doesn't get saved, and then the widget remains
	anonimous.

	These messages may look like this skeleton

	<$parent> -> <widget class> ([<options>])[ -> <geom magr> [([<geom options>])] ;

	whereby the items

	<$parent>, <widget class> <options>, <geom magr> and <geom options>

	are returned in a list.

=cut

package tkCommandAnon;
{
	use bottomUpParser 1.02;			## force import of constant (mandatory)
	use base qw(bottomUpParser) ;

our $VERSION = '1.01';

sub new {
	my $class = shift;
	my (%args) = @_;

	die "missing mandatory tokenList" unless exists $args{-tokenList};

	return $class->SUPER::new(%args);
}

sub init {
	my $self = shift;
	my (%args) = @_;
	my $tokenList = $args{-tokenList} if exists $args{-tokenList};
	my $productions = [
		['parent', sub { my $v = shift; return 1 if ($v =~ /^\$\w+$/); return 0}],
		['class',  sub { my $v = shift; return 1 if ($v =~ /^\w+$/); return 0}],
		['opt',    sub { my $v = shift; return 1 if ($v =~ /\S*/); return 0}],
		['geom',   sub { my $v = shift; return 1 if ($v =~ /^(pack|grid|format|place)$/); return 0}],
		['geomopt',sub { my $v = shift; return 1 if ($v =~ /\S*/); return 0}],
		] ;

	my $tree = [
		sub{ my $tok = shift; return SHIFT if $tok =~ /^\$\w+/ || die"missing parent"},
		sub{ my $tok = shift; return NEXTTOKEN if $tok eq '->' || die "missing ->"},
		sub{ my $tok = shift; return SHIFT if $tok =~/\w+/     || die "missing class"},
		sub{ my $tok = shift; return DONE if $tok eq ';'; return TRYNEXTDEF},
		[
			sub{ my $tok = shift; return NEXTTOKEN if ($tok eq '('); return DONE},
			sub{ return SHIFT+TRYAGAIN if OPTLISTMANDATORY(@_); return TRYNEXTDEF},
			sub{ my $tok = shift; return DONE+EOL if ($tok eq ')') || die "missing )" },
		],
		sub{ my $tok = shift; return DONE if $tok eq ';'; return TRYNEXTDEF},
		sub{ my $tok = shift; return NEXTTOKEN if $tok eq '->'; return TRYNEXTDEF},
		sub{ my $tok = shift; return SHIFT if $tok =~ /^pack|grid|format|place/i; return TRYNEXTDEF},
		sub{ my $tok = shift; return DONE if $tok eq ';'; return TRYNEXTDEF},
		[
			sub{ my $tok = shift; return NEXTTOKEN if $tok eq '('; return DONE },
			sub{ return SHIFT+TRYAGAIN if OPTLISTOPTIONAL(@_); return TRYNEXTDEF},
			sub{ my $tok = shift; return DONE+EOL if $tok eq ')' || die "missing )" },
		],
		sub{ my $tok = shift; return DONE if $tok eq ';'; die "missing ';'"},
	];

	my $id = 0;
	my $prod = sub {
		return wantarray ? @{$productions->[$id++]} : scalar ($productions->[$id++]);
	};
	$self->SUPER::init(-tokenList, $tokenList, -tree => $tree, -production => $prod);
	$self->expected(
		["parent class",
		"parent class opt",
		"parent class opt geom",
		"parent class opt geom geomopt"]
		);
	return 1;
}

sub parse {
	my $self = shift;
	my ($tokenList,$tree,$prod) = @_;

	return $self->SUPER::parse($tokenList,$tree,$prod);
}
1;
} ## eop
