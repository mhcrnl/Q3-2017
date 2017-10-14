#!/usr/bin/perl -w

=head1 ctkParseDT.pl

	Generate decision table according to the given
	command line arguments.

=head2 Syntax

	perl ctkParseDT.pl [options] [definition]

	options

		-d  debug flag 1/0
		-h  display this help text
		-t  run unit test after table creation

	definition
		name of the definition file (default STDIN)
		name of the generated module (default STDOUT)

	Examples:

	1. gen the module ctkDT_7.pl

	perl ctkParseDT.pl ctkDT_7

	1. Use definition file ctkDT_7.txt ,  gen module ctkDT_7x.pl

	perl ctkParseDT.pl ctkDT_7 ctkDT_7x

	3. Gen inline package from STDIN and write to STDOUT and activate debug mode

	perl ctkParseDT.pl -d

	4. Use definition file ctkDT_7, gen inline package from definition file and write to STDOUT

	perl ctkParseDT.pl ctkDT_7 " "

=head2 Methods

=head3 main line

	- set up script environment,
	- accept command line arguments,
	- call main::main if arguments has been given,
	  main::mainx otherwise,
	- issue exception "Could not gen code" if errors occurred,
	- return status to OS.

=cut

use strict;
use warnings;

use lib './lib';

use ctkDecTab 1.05;
use Getopt::Std;

our $debug = 0;

our $VERSION = 1.04;

print STDERR "\n$0 - v $VERSION is starting ";
print STDERR "\ndebug mode is $debug \n";

my $line;
my $fNameDef;
my $fNamePL;
my $opt = {};

my $rv;

getopts('dh',$opt);

$debug = $opt->{d} if(exists $opt->{d});
&main::help if (exists $opt->{h});

if (@ARGV) {
	$fNameDef = shift(@ARGV);
	$fNameDef = undef if $fNameDef =~ /^\s*$/;
	$fNamePL = shift(@ARGV);
	if (defined $fNameDef) {
		$fNameDef =~ s/\..+$//;
	} else {}
	if (defined $fNamePL) {
		$fNamePL =~ s/\..+$//;
		$fNamePL = undef if ($fNamePL =~ /^\s*$/);
	} else {
		$fNamePL = $fNameDef;
	}

	if (defined $fNamePL) {
		my $pkg = &main::main($fNameDef,$fNamePL);
		$rv = ($pkg > 0) ? 0 : 1;
	} else {
		my $pkg = &main::main($fNameDef);
		$rv = ($pkg > 0) ? 0 : 1;
	}
} else {	## take input from stdin and put output into stdout
		my $pkg = &main::mainx();
		$rv = ($pkg > 0) ? 0 : 1;
}
die "Could not gen code" if ($rv);
exit ($rv);

## ----------------------------------------------------------------------

=head3 main

	This method reads in the definition by means of main::getDefinition.
	Then, it sends the messages 'parseAndBuildTable' and 'save'
	to the class ctkDecTab.
	Finally it returns the number of saved lines of code.

=cut

sub main {
	my ($fNameDef,$fNamePL) = @_;
	my @rv =();
	my @lines = ctkDecTab::_load($fNameDef);
	my $pName = $fNamePL;
	if (defined $pName) {
		$pName =~ s/\..+$//;
	} else {
		## $pName = '';
	}

	if (ctkDecTab::parseAndBuildTable(@lines)) {
		@rv = ctkDecTab::getDT() if (ctkDecTab::save($fNamePL,$pName));
	} ## else {}
	return scalar(@rv);
}

=head3 mainx

	This method reads in the definition by means of ctkDecTab::_load()
	from STDIN
	Then it sends the messages 'parseAndBuildTable' and 'save'
	to the class ctkDecTab.
	Finally, it returns the number of saved lines of code.

=cut

sub mainx {
	my @rv =();
	my @lines = ctkDecTab::_load();
	if (ctkDecTab::parseAndBuildTable(@lines)) {
		@rv = ctkDecTab::getDT() if (ctkDecTab::save());
	} ## else {}
	return scalar(@rv);
}

sub help {	## print the help information
	print STDERR <<EOF;

	Help for test script $0 :

	$0 [options] [definition]

	options

		-d  debug flag 1/0
		-h  display this help text
		-t  run unit test after table creation

	definition
		name of the definition file (default STDIN)
		name of the generated module (default STDOUT)

	Example:

	1. gen the module ctkDT_7.pl

	perl $0 ctkDT_7

	1. Use definition file ctkDT_7.txt ,  gen module ctkDT_7x.pl

	perl $0 ctkDT_7 ctkDT_7x

	3. Gen inline package from STDIN and write to STDOUT and activate debug mode

	perl $0 -d

	4. Use definition file ctkDT_7, gen inline package from definition file and write to STDOUT

	perl $0 ctkDT_7 " "

EOF
	exit(0);
}

