#!/usr/bin/perl

=head1 ctkParseDT_variables.pl

	Generate module ctkDTvar.pl containing package ctkDTvar

=head2 Syntax

	perl ctkParseDT_variables.pl [options]

	options

		-h     help file
		-d     activate debug mode

=head2 Description

	This script is a specialized copy of ctkParseDT.pl.
	It generates the decition table for the assigment of variables.

	To do that it does the following:

		- it provides the definition of the table,
		- it sets up the arguments for module ctkDecTab
		- it sends messages to that class and finally
		- it launchs perl to check the resulted code.

=head2 Methods

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
my $fNameDef = 'ctkDTvar';
my $fNamePL = $fNameDef.'.pl';
my $opt = {};

my $rv;

=head3 main line

	The mainline does the following actions

		- set up the global variables
			name of the package is 'ctkDTvar'
			name of the file is 'ctkDTvar.pl'
		- accept command line arguments
		- call main for processing
		- check syntax of generated file

=cut

getopts('dh',$opt);

$debug = $opt->{d} if(exists $opt->{d});
&main::help if (exists $opt->{h});

my $pkg = &main::main($fNameDef,$fNamePL);
$rv = ($pkg > 0) ? 0 : 1;
die "Could not gen code" if ($rv);
print "\n";
$rv = system("perl -c $fNamePL");
$rv >>= 8;
exit ($rv);

## ----------------------------------------------------------------------

=head3 main

	This method reads in the definition by means of main::getDefinition
	and sends the messages 'parseAndBuildTable' and 'save'
	to the class ctkDecTab.

	It returns the number of saved lines of code.

=cut

sub main {
	my ($fNameDef,$fNamePL) = @_;
	my @rv =();
	my @lines = &main::getDefinition();
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

=head3 getDefinition

	This method returns the decTab definition either
	as an array of lines or as a string of concatenated lines
	depending on the context.

=cut

sub getDefinition {
	my @rv = ();
	my $s = <<EndOfString;
\'\$\'.main::getMW() ne \$ctkProject::arg1                                ¦   1  1  1  1   1  1  1  1    1  1  1  1   1  1  1  1    1  1  1  1   1  1  1  1  -
main::getFile_opt->{'code'} == 0                                          ¦   1  1  1  1   1  1  1  1    0  0  0  0   0  0  0  0    0  0  0  0   0  0  0  0  -
main::getFile_opt->{'code'} == 1                                          ¦   0  0  0  0   0  0  0  0    1  1  1  1   1  1  1  1    0  0  0  0   0  0  0  0  -
main::getFile_opt->{'code'} == 2 || main::getFile_opt->{'code'} == 3      ¦   0  0  0  0   0  0  0  0    0  0  0  0   0  0  0  0    1  1  1  1   1  1  1  1  -
main::getFile_opt->{'autoExtract2Local'}                                  ¦   1  1  1  1   0  0  0  0    1  1  1  1   0  0  0  0    1  1  1  1   0  0  0  0  -
scalar(grep(\$_ eq \$ctkProject::arg1,\@ctkProject::user_local_vars)) > 0 ¦   Y  Y  N  N   Y  Y  N  N    Y  Y  N  N   Y  Y  N  N    Y  Y  N  N   Y  Y  N  N  -
scalar(grep(\$_ eq \$ctkProject::arg1,\@ctkProject::user_auto_vars)) > 0  ¦   Y  N  Y  N   Y  N  Y  N    Y  N  Y  N   Y  N  Y  N    Y  N  Y  N   Y  N  Y  N  -
--------------------------------------------------------------------------+--------------------------------------------------------------------------------
ctkProject->insertLocal(\$ctkProject::arg1)                               ¦   -  -  X  X   -  -  -  -    -  -  X  X   -  -  -  -    -  -  X  X   -  -  -  -  -
ctkProject->insertGlobal(\$ctkProject::arg1)                              ¦   -  -  -  -   -  X  -  X    -  -  -  -   -  X  -  X    -  -  -  -   -  X  -  X  -
ctkProject->removeLocal(\$ctkProject::arg1)                               ¦   -  -  -  -   -  -  -  -    -  -  -  -   -  -  -  -    -  -  -  -   -  -  -  -  -
ctkProject->removeGlobal(\$ctkProject::arg1)                              ¦   -  -  -  -   -  -  -  -    -  -  -  -   -  -  -  -    -  -  -  -   -  -  -  -  -
push \@ctkProject::DTmessage,"\$ctkProject::arg2 \$ctkProject::arg1"      ¦   X  -  -  -   -  X  -  -    -  -  X  -   X  X  -  -    -  -  X  -   X  X  -  -  -
&main::Log("\$ctkProject::arg2 \$ctkProject::arg1")                       ¦   -  -  -  -   -  -  -  -    -  -  -  -   -  -  -  -    -  -  -  -   -  -  -  -  X
EndOfString
	@rv = split /\n/,$s;
	wantarray ? @rv : scalar(@rv)
}

sub help {	## print the help information
	system "perl ctkParseDT.pl -h";
	exit(0);
}

