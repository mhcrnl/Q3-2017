=head1 ctkDecTab

	Parse, generate and execute decision tables (decTab).

=head2 Syntax

=over

=item Load the table declaration

	use ctkDecTab 1.05;
	my @decl = ctkDecTab::_load(<file name>);

=item Generate and execute code snippet

	if (ctkDecTab::parseAndBuildTable(@decl));
		if ($dt = ctkDecTab::buildSnippet()) {
			eval "$dt ;".'xTable();';
			die "Could not gen or exec decTab, $@" if ($@);
		}
	}

=item Generate and execute code block

	if (ctkDecTab::parseAndBuildTable(@decl));
		if ($dt = ctkDecTab::buildBlock()) {
			eval $dt;
			die "Could not gen decTab, $@" if ($@);
		} else { die "could not exec decTab"}
	}

=item  Generate and execute package, i.e. package xmain

	if (ctkDecTab::parseAndBuildTable(@decl));
		if ($dt = ctkDecTab::buildPackage('xmain')
			eval "$dt";
			die "Could not gen decTab, $@" if ($@);
			xmain::xTable();
		} else { die "could not exec decTab"}
	}

=item  Generate package, save it to file and later on execute it

	unless (-f "xmain.pl") {
		my @decl = ctkParserDT::_load('xmain');
		if (ctkDecTab::parseAndBuildTable(@decl)) {
			$dt = ctkDecTab::save('xmain');
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
	That means there are as many different states as combinations of condition's results.
	Additionally, actions may be independent of specific conditions.
	Thus, the result of a condition can be discarded for specific states.
	That means, the result of a condition may get one of these values
	true, false or irrelevant.
	For instance, 3 conditions yield 9 possible distinct states which may lead
	to 9 different set of actions.
	(See the description of the method 'save' for an example.)

	Conditions and actions are perl statements.
	Conditions consist of Perl expressions which must return
	a boolean value.
	Actions may be any Perl expression, they are typically calls
	to a function (subroutine).
	It is the responsibility of the programmer to make sure that
	these statement can access the data in a proper way.

	The generated code consists of

		- the set of conditions, generated as closures,
		- the set of actions, also generated as closures and
		- the execution method xState. This method first executes
		  all conditions determinating the actual state and
		  then executes the actions defined for the actual state.

	The generated code can be saved into a module,
	which get loaded later on at run time by means of 'require' or 'use' ,
	or immediately executed by means of eval.

	Generated code snippet or anonimous block usually
	execute (eval) in the same package where are the status variables .
	Thus, conditions and actions may directly access these variables.

	By contrast, when the generated code is a package, problems may
	arise accessing variables of other packages and/or namespaces.
	It is the responsibility of the programmer to make these variables
	accessable in the conditions or actions.

	Unlike state machines, decision tables work at a specific time and
	are based on the specific state of the accessed variables.
	Therefore, these variables should not change while the code of the conditions
	are executed. On the other hand, once the state has been computed, the actions can update
	those variable.
	When several actions have to be executed for a specific state, then they are dispatched in the same
	order as they are defined in the decision table.

=over

=item EBNF

	table      ::= (conditions) ('-') (actions) ('-')
	conditions ::= condition '¦' (values) nl
	condition  ::= (<Perl boolean expressions>)
	values     ::= 'Y' | '1' | 'N' | '0' | '-'
	actions    ::= method '¦' (indicators) nl
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
	()         1 - N list of given item

=back

=head2 Programming notes

=item Class data member

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

=item Method's list

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

=head2 Methods

=cut

package ctkDecTab;

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

=head3 _clear

	Clear the content of the  DT class member.

=cut

sub _clear {
	@DT =();
}

=head3 _clearClassData

	Clear the content of all class members.

=cut

sub _clearClassData {
	@conditions = @actions = @decisionTable = @DT = ();
	$state =START;
}

=head3 getDT

	Return the content of the class data member DT
	as array or string depending on the context.

=cut

sub getDT {
	wantarray ? @DT : join ('',@DT);
}

=head3 _load

	Load the given definition into memory and
	return it as array or string depending on the context.
	If no file name is given, STDIN shall be used.

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

=head3 buildPackage

	Generate the Perl package containing the
	generated table and code previously saved into class member @decisionTable.

	Issue exception "Cannot gen an empty table" if class member
	@decisionTable is empty.

	Return the generated code either as an array of lines or as a string of
	concatenated lines depending on the context.


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

=head3 buildBlock

	Generate the Perl block containing the
	generated table and code previously saved into class member @decisionTable
	and the message xTable().

	Issue exception "Cannot gen an empty table" if class member
	@decisionTable is empty.

	Return the generated code either as an array of lines or as a string of
	concatenated lines depending on the context.

=cut

sub buildBlock {
	die "Cannot gen an empty table" unless (@decisionTable);
	&_clear();
	push @DT, ("","##","## Decision table","##");
	push @DT, "{ ## open block";
	push @DT , @decisionTable;
	push @DT , "xTable(); 	## OK, do it ...";
	push @DT , "} ## close block ";
	@DT = map{"$_\n"} @DT;
	return wantarray ? @DT : join('',@DT);
}

=head3 buildSnippet

	Generate the Perl code containing the
	generated table and code previously saved into class member @decisionTable.

	Issue exception "Cannot gen an empty table" if class member
	@decisionTable is empty.

	Return the generated code either as an array of lines or as a string of
	concatenated lines depending on the context.


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

=head3 save

	Build code and either save it to disk or
	put it into STDOUT.
	Thereby, apply the following decision table:

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

=head3 _parseConditionOrAction

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
			last if ($x=~/^[¦]$/);
			$b .= "$x "
	}
	foreach (0..$#w) {
		$w[$_] =~ s/y/1/i;
		$w[$_] =~ s/n/0/i;
	}
	@rv =($b,@w);
	return wantarray ? @rv : scalar(@rv)
}

=head3 prepareDecisions

	Build up and save the conditions into the
	class data member @decisionTable.

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

=head3 prepareActions

	Build up and save the actions into the
	class data member @decisionTable.

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

=head3 buildTable

	Build up the method xTable using the class data members @conditions and @actions
	and save the code into the class data member @decisionTable.

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

=head3 parse

	Parse the declaration and build up the class data
	members decision and actions.

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

=head3 parseAndBuildTable

	Parse the declaration and build up the method xTable,
	save the code into the class data member @decisiontable and
	return its content depending on the context as an array of lines
	or as a string.

	This method takes the same arguments as message ctkDecTab::parse does.

	Arguments are passed 'as is' to the method ctkDecTab::parse .

	In array context the returned array is identical to the class variable @decisiontable
	In scalar context the returned string is the
	concatenation of the class variable @decisiontable

=cut

sub parseAndBuildTable {
	my @rv =();
	if (ctkDecTab::parse(@_)) {
		if (ctkDecTab::buildTable()) {
			@rv = @decisionTable;
		} ## else {}
	} ## else {}
	return wantarray ? @rv : join('',@rv);
}
1; ## make it happy
