=head1 ctkParseDT

	Parse, generate and execute decision tables.

=head2 Syntax

=over

=item Load the table declaration

	use ctkParseDT 1.05;
	my @decl = ctkParserDT::_load(<file name>);

=item Generate and execute code snippet

	if (ctkParseDT::parseAndBuildTable(@decl));
		if ($dt = ctkParseDT::buildSnippet()) {
			eval "$dt ;".'xTable();';
			die "Could not gen or exec decTab, $@" if ($@);
		}
	}

=item Generate and execute code block

	if (ctkParseDT::parseAndBuildTable(@decl));
		if ($dt = ctkParseDT::buildBlock()) {
			eval $dt;
			die "Could not gen decTab, $@" if ($@);
		} else { die "could not exec decTab"}
	}

=item  Generate and execute package, i.e. package xmain

	if (ctkParseDT::parseAndBuildTable(@decl));
		if ($dt = ctkParseDT::buildPackage('xmain')
			eval "$dt";
			die "Could not gen decTab, $@" if ($@);
			xmain::xTable();
		} else { die "could not exec decTab"}
	}

=item  Generate package, save it to file and later on execute it

	unless (-f "xmain.pl") {
		my @decl = ctkParserDT::_load('xmain');
		if (ctkParseDT::parseAndBuildTable(@decl)) {
			$dt = ctkParseDT::ctkParseDT::save('xmain');
		} else { die "could not exec decTab"}
	}

	## somewhere in the script ...

	require "xmain.pl";
	while (<any loop-conditions>) {
		## do something ...
		xmain::xTable();

	}

=head2 Description

	The goal of the package is to convert the declaration of
	a decision table into executable perl code.

	Thus, a decision table consists of
		- a declaration,
		- a piece of generated code which may be
			- a package
			- an anonimous block
			- a snippet of code

	The declaration may look like this

		condition A   | 1  1  0  0
		condition B   | 1  0  1  0
		--------------+-----------
		action X      | x  x  -  -
		action Y      | x  -  x  -

	The declaration defines the conditions, the actions and their relationships.
	A defined set of actions are executed when the execution of all conditions
	yields a specific and defined result (state).
	That means there are as many different states as
	combinations of condition's results. Additionally, actions may be indipendent of
	specific conditions. Thus, the result of a condition can be discarded for specific states.
	That means, the result of a condition may get one of these values
	true, false and irrelevant.
	For instance, 2 conditions yield 9 possible distinct states which may lead
	to 9 different set of actions.
	(See the description of the method save for an example.)

	Conditions and actions are perl statements.
	Conditions consists of Perl expressions which yield
	a boolean value.
	Actions may be any Perl expression, they are typically calls
	to a function (subroutine).
	It is the responsibility of the programmer to make sure that
	these statement can access the data in a proper way.

	The generated code consists of
		- the set of conditions, generated as closures
		- the set of actions, also generate as closures and
		- the execution method xState, which
		  first executes all conditions determinating the state and
		  then executes the actions defined for the state.

	The generated code can be saved into a module,
	which get required,
	or immediately executed by means of eval.

	There are no problems for generated code snippet or anonimous block,
	then they get executed (eval) in the current package.

	By contrast, when the generated code is a package, problems may
	arise accessing the variables of other namespaces.
	It is the responsibility of the programmer to make the variables
	inspected in the condistion or action acessable in that code.

	Unlike state machines, decision tables work at a specific time and
	are based on the specific state of the accessed variables.
	Therfore, these variables should not change while the code of the conditions
	are executed. On the other hand, once the state has been computed, the actions can update
	those variables.

=over

=item EBNF

	table      ::= (conditions) ('-') (actions) ('-')
	conditions ::= condition '�' (values) nl
	condition  ::= (<Perl boolean expressions>)
	values     ::= 'Y' | '1' | 'N' | '0' | '-'
	actions    ::= method '�' (indicators) nl
	method     ::= (<perl statement>)
	indicators ::= 'X' | '-'
	nl         ::= '\n'

Legend:

	::=        operator 'consists of'
	|          OR operator
	space      AND operator

	word       indicate uniquely an item of the EBNF declaration
	'x'        string constant
	< >        explanatory text, acting as a placeholder for an item
	()         list of given item

=back

=head2 Programming notes

=item Class member

	$state          state while parsing
	@conditions     list of the declared conditions
	@actions        list of the declared actions
	@decisionTable  content of the decision table
	@DT             generated code as saved to target

=item Data member

	None

=item Properties

	debug

=item Constructor

	Send message  _load to load an external declaration.

	Use parse(<array>) to work with a declaration saved
	in a script variable.

=item Destructor

	Send message _clearClassData.

=item Methods

	_clear
	_clearClassData
	_load
	_parseConditionOrAction
	buildBlock
	buildPackage
	buildSnippet
	buildTable
	getDT
	parse
	parseAndBuildTable
	prepareActions
	prepareDecisions
	save

=back

=head2 Maintenance

	Author:	Marco
	date:	19.09.2008
	History
			19.09.2008 first draft
			24.09.2008 version 1.05

=cut

package ctkParseDT;

use strict;
use warnings;

our $VERSION ='1.05';

use constant START      => 0;
use constant CONDITIONS => 1;
use constant ACTIONS    => 2;

my $DEC = '$dec_';
my $ACT = '$act_';

my $state = START;
my @conditions =();
my @actions=();
my @decisionTable=();
my @DT;

=head2 _clear

	Clear the content of the  DT class member.

=cut

sub _clear {
	@DT =();
}

=head2 _clearClassData

	Clear the content of all class members.

=cut

sub _clearClassData {
	@conditions = @actions = @decisionTable = @DT = ();
	$state =START;
}

=head2 getDT

	Return the content of the class data member DT
	as array or string depending on the context.

=cut

sub getDT {
	wantarray ? @DT : join ('',@DT);
}

=head2 _load

	Load the given definition into memory and
	return it as array or string deending on the context.
	If no file name is given, STDIN will used.

=cut

sub _load {
	my ($fName) = @_;
	my @rv = ();
	local *IN;
	my $line;
	if (defined $fName) {
		$fName .='.txt' unless $fName =~/\.txt$/;
		open(IN,"<$fName") || die "Could not open '$fName'";
		while ($line = <IN>) {
			push @rv,$line
		}
		close IN;
	} else {
		while ($line = <>) {
			push @rv,$line
		}
	}
	return wantarray ? @rv : join ('',@rv);
}

=head2 buildPackage

=cut

sub buildPackage {
	my ($pName) = @_;
	die "Cannot gen an empty table" unless (@decisionTable);
	&_clear();
	push @DT, ("","=head2 ","","\t Decision table","","=cut","");
	push @DT, "package $pName; {";
	push @DT , @decisionTable;
	print push @DT , "1;} ## make the compiler happy";
	@DT = map{"$_\n"} @DT;
	wantarray ? @DT : join('',@DT);
}

=head2 buildBlock

=cut

sub buildBlock {
	die "Cannot gen an empty table" unless (@decisionTable);
	&_clear();
	push @DT, ("","##","## Decision table","##");
	push @DT, "{ ## open block";
	push @DT , @decisionTable;
	push @DT , "xTable(); 	## OK, do it ...";
	print push @DT , "} ## close block ";
	@DT = map{"$_\n"} @DT;
	return wantarray ? @DT : join('',@DT);
}

=head2 buildSnippet

=cut

sub buildSnippet {
	die "Cannot gen an empty table" unless (@decisionTable);
	&_clear();
	push @DT, ("","##","## Decision table","##");
	push @DT , @decisionTable;
	push @DT, "##";
	@DT = map{"$_\n"} @DT;
	return wantarray ? @DT : join('',@DT);
}

=head2 save

	Build code and save it current table to disk:

		module name given     | y  y  y  n  n  n
		package name given    | y  y  n  y  y  n
		package name is empty | n  y  -  n  y  -
		----------------------+------------------
		gen package           | x  x  x  x  -  -
		gen package main      | -  x  -  -  x  -
		gen block             | -  -  -  -  -  x
		write to file         | x  x  x  -  -  -
		write to STDOUT       | -  -  -  x  x  x
		----------------------+------------------

	Return the number of written lines.

=cut

sub save {
	my ($fName,$pName) = @_;
	my $rv;
	my @w =();

	if (defined $pName) {
		@w = ($pName =~/\w+/) ? &buildPackage($pName): &buildPackage('main');
	} else {
		@w = &buildBlock();
	}

	if (defined $fName) {
		local *DT;
		$fName .='.pl' unless $fName =~/\.pl$/;
		open DT,">$fName" || die "Could not open $fName";
		map { print DT $_} @w;
		close DT;
		$rv = scalar(@w);
	} else {
		map { print STDOUT $_} @w;
		$rv = scalar(@w);
	}
	return $rv;
}

=head2 _parseConditionOrAction

	Parse the given declaration's line and return
	depending on the context  the list of the tokens
	or their number.

=cut

sub _parseConditionOrAction {
	my ($line) = @_;
	my @rv;
	my @w = split /\s+/,$line;
	my $b ='';
	while (@w)  {
			my $x = shift(@w);
			last if ($x=~/^[�]$/);
			$b .= "$x "
	}
	foreach (0..$#w) {
		$w[$_] =~ s/y/1/i;
		$w[$_] =~ s/n/0/i;
	}
	@rv =($b,@w);
	return wantarray ? @rv : scalar(@rv)
}

=head2 prepareDecisions

	Build up and save the conditions into the
	class data member decisionTable.

	Return the number of conditions.

=cut

sub prepareDecisions {
	push @decisionTable,"## conditions";
	my $i =0;
	map  {
		##$_->[0] =~s/\s+/_/g;
		## push @decisionTable, "sub $_->[0] {\n\tmy \$rv =0;\n\t# \n\treturn \$rv\n}"
		push @decisionTable, 'my ' . $DEC . $i++ . ' = sub{' . $_->[0] . '};';
	} @conditions;
	return $i
}

=head2 prepareActions

	Build up and save the acttions into the
	class data member decisionTable.

	Return the number of conditions.

=cut

sub prepareActions {
	push @decisionTable,"## actions";
	my $i =0;
	map {
		##$_->[0] =~s/\s+/_/g;
		#push @decisionTable, "sub $_->[0] {\n\tmy \$rv =0;\n\t# \n \treturn \$rv\n}"
		push @decisionTable, 'my '. $ACT . $i++ .' = sub{' . $_->[0] . '};';
	} @actions;
	return $i
}

=head2 buildTable

	Build up the methode xTable using the class data members decisions and actions
	and save the code into the class data member decisionTable.

	Return the number of processed states.

=cut

sub buildTable {
	my $rv = 0;
	push @decisionTable, 'sub xTable {';
	push @decisionTable,'my $rv = 0;';
	push @decisionTable,'my @state=();';

	my $h = scalar(@{$conditions[0]});
	map { die "Missing values at conditions $_." unless (scalar($conditions[$_]) != $h)} 1..$#conditions;
	map { die "Missing values at actions $_." unless (scalar($actions[$_]) != $h)} 0..$#actions;
	#foreach (@conditions) {
	#	push @decisionTable,'push @state,&'.$_->[0].'();';
	#}
	foreach (0..$#conditions) {
		push @decisionTable,'push @state,&' . $DEC .$_ . '();';
	}
	for (my $i = 1; $i < $h;$i++) {
		my $a='';
		for (my $j =0; $j < scalar(@conditions);$j++) {
			my $c = $conditions[$j]->[$i];
			if ($c =~/^y/) {
				$c =~ s/y+/1/i;
			} elsif ($c =~/^n/) {
				$c =~ s/n+/0/i;
			} elsif ($c =~/^0+/) {
				$c = '0'
			} elsif ($c =~/^1+/) {
				$c = '1'
			} elsif ($c =~/^\-/) {
				next
			} else {
				die "Unexpected value '$c' $j $i"
			}
			$c = ($c) ? ' $state['.$j.']' . ' &&'
						:
						' !($state['.$j.'])' . ' &&';
			$a .= $c ;
		}
		$a =~ s/&&$//;
		my $x='';
		#for (my $j =0; $j < scalar(@actions);$j++) {
		#	if ($actions[$j]->[$i] =~ /x/i) {
		#		$x .= '&'.$actions[$j]->[0].'();';
		#	}
		#}
		for (my $j =0; $j < scalar(@actions);$j++) {
			if ($actions[$j]->[$i] =~ /x/i) {
				$x .= '&'.$ACT.$j.'();';
			}
		}
		if ($a) {
			push @decisionTable,"if ($a) {";
			if ($x) {
				push @decisionTable,"\t$x";
			} else {
				warn "No actions for $a";
				push @decisionTable, "\twarn 'no actions' "
			}
			push @decisionTable,"}";
		} else {
			if ($x) {
				push @decisionTable,"{ ## unconditional action";
				push @decisionTable,"\t$x";
				push @decisionTable,"}";
			} else {
				warn "empty item"
			}
		}
		$rv++
	}
	push @decisionTable, 'return $rv;';
	push @decisionTable, '}';
	return $rv;
}

=head2 parse

	Parse the declaration and build upt teh class data
	members decision and actions

	Return the number of declared actions.

=cut

sub parse {
	my @definition = @_;
	my $rv = 0;
	my $line;
	&_clearClassData();
	while ($line = shift (@definition)) {
		next if ($line =~ /^\s*$/);		## empty line
		next if ($line =~ /^\s*\#/);		## comment
		if ($state == START) {
			if ($line =~ /^\s*[\-]+/) {
				&prepareDecisions();
				$state = ACTIONS;
			} else {
				my @w = &_parseConditionOrAction($line);
				push @conditions, [@w];
			}
		} elsif ($state == ACTIONS) {
			last if ($line =~ /^\s*[\-]+/);
			my @w = &_parseConditionOrAction($line);
			push @actions, [@w];
		}
	}
	$rv = &prepareActions();
	return $rv
}

=head2 parseAndBuildTable

	Parse the declaration and build up the method xTable,
	save the code into the class data member decisiontable and
	return its content depending on the context as an array of lines
	or as a string.

=cut

sub parseAndBuildTable {
	my @rv =();
	if (ctkParseDT::parse(@_)) {
		if (ctkParseDT::buildTable()) {
			@rv = @decisionTable;
		} ## else {}
	} ## else {}
	return wantarray ? @rv : join('',@rv);
}
1; ## make it happy
