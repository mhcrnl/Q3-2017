=head1 ctkParser

	This package provides some (RDP) parser mainly to analyze
	options strings.

=head2 Data members

		None

=head2 Class data

		None.

=head2 Methods

	new
	destroy

	parseString
	parseWidgetOptions
	parseWidgetDefinition  (not yet implemented)


=head2 Programming notes

	All methods may also be used as class methods.

=head2 Maintenance

	Author:	marco
	Date:	01.01.2007
	History:
			26.05.2008 version 1.04
			26.05.2008 version 1.05
			14.04.2009 version 1.06 (P072)
			19.12.2011 version 1.07 P093
			21.02.2012 version 1.08

=head1 Methods

=cut

package ctkParser;

use strict;
use base (qw/ctkBase/);

use vars qw($VERSION);

$VERSION = 1.08;


sub new {
	my $class = shift;
	my $self = {};
	return bless $self, $class
}

sub destroy {
	my $self = shift;
	$self = {};
}


=head3 string2Array

	This method converts the given string into an array
	- check wether the string contains a code which represents a ref to array,
	  that means either '[ items,items, ... ]' or '( items,items, ... )'
	- parse the string by means of message ctkParser::parseString
	- quotate the items by means of message ctkParser::quotatY
	- embed the string returned by quotatY into '[]' and evaluate it
	- return the array or the ref to array depending on context

	Arguments

		array in string form

	Return

		array or ref to array depending on context

	Exceptions

		'Could not convert string'
		Unexpected array in string form

=cut

sub string2Array {
	my $self = shift;
	my ($opt) = @_;
	my $rv = [];
	if ($opt =~/^\s*\[\s*([^]]*)\s*\]\s*$/) {
		my @wA = $self->parseString($1);
		my $w = $self->quotatY(\@wA);
		$rv = eval "[$w]";
		die "Could not convert string '$w', $@" if ($@);
	} elsif($opt =~/^\s*\(\s*([^)]*)\s*\)\s*$/) {
		my @wA = $self->parseString($1);
		my $w = $self->quotatY(\@wA);
		$rv = eval "[$w]";
		die "Could not convert string '$w', $@" if ($@);
	} else {
		main::Log("Unexpected array in string form, $opt","argument ignored");
	}

	return wantarray ? @$rv : $rv
}

=head3 quotatX

	Handle optionslist for Scrolled widgets

	Shift out class name if scrolled widget
	call QuotatY
	unshift class name if scrolled widget
	stringify the optionslist
	return stringified optionslist

Arguments

	- ref to array of options list
	- argument type (class name i.e. 'Scrolledlistbox')

Return

	- stringified option's list

Exceptions

	'Missing mandatory argument type'

Notes

	None
=cut

sub quotatX {
	my $self = shift;
	my ($opt,$type) = @_;
	my $rv ;
	my $opt_list ='';
	my $c;
	my $prefix = '';

	&main::trace("quotatX opt_list ",@$opt,"type = $type");

	die "Missing mandatory argument type" unless (defined($type));

	return '' unless (@$opt);

	my $class = shift @$opt if ($type =~ /^Scrolled\w+$/);

	$prefix = "'$class' , " if(defined($class));

	$opt_list = $self->quotatY($opt);

	unshift @$opt, $class if(defined($class));
	$rv = "$prefix$opt_list";
	&main::trace("rv='$rv'");
	return $rv;
}

=head3 quotatZZ

	Parse the given optlist :

		- quotate values keeping existing quotations
		- resolve list values
		- return list or string of options depending on context.

	Arguments
		options list (ref to array)
		quotating char ,(optional, default "'")

	Return

		list of options as array or
		string of options in scalar context.

=cut

sub quotatZZ {
	my $self = shift;
	my ($opt,$qc) = @_;
	my $rv ;
	my $opt_list ='';
	my $c;
	my $prefix;

	$qc ="'" unless defined $qc;

	&main::trace("quotatZZ opt_list ",@$opt,"Quotating char $qc");

	return '' unless (@$opt);

	for (my $i = 0; $i < @$opt; $i++) {
		$c = $opt->[$i];
		if ($i % 2) {
			if ($c =~ /\^s*$/) {
				$opt_list .= "$qc$qc , ";
				push @$rv , '';
			} elsif ($c =~ /^\d+$/) {
				$opt_list .= "$c , ";
				push @$rv, $c;
			} elsif ($c =~ /^sub\s*\{/) {
				$opt_list .= "$c , ";
				push @$rv, $c;
			} elsif ($c =~ /^\s*\\*[\$\&]\w+/) {
				$opt_list .= "$c , ";
				push @$rv ,$c;
			} elsif ($c =~ /^\s*\[([^\]])*\]\s*$/)  {	## array def like labelPack => [...]
				$c = $1; $c =~s/\s*=>\s*/,/g;$c =~s/^\s+//;$c =~s/\s+$//;
				my @w = $self->parseString($c);
				$c = $self->quotatZZ(\@w);
				$c = '['.$c.']';
				$opt_list .= "$c , ";
				push @$rv ,$c;
			} elsif ($c =~ /^\s*\'([^\']+)\'\s*$/)  {	## keep quotation
				$opt_list .= "$c , ";
				push @$rv ,$c;
			} elsif ($c =~ /^\s*\"([^\"]+)\"\s*$/)  {	## keep quotation
				$opt_list .= "$c , ";
				push @$rv ,$c;
			} else {
				$c =~ s/^\'/\\\'/;		## escape simple quotation
				while ($c =~ s/([^\\])\'/$1\\\'/){};
				$opt_list .= "$qc$c$qc , ";
				push @$rv ,"$qc$c$qc";
			}
		} else {
			$opt_list .= "$c , ";
			push @$rv ,$c;
		}
	}
	$opt_list =~ s/,\s*$//;
	return (wantarray) ? @$rv : "$opt_list";
}

=head3 quotatZ

	Make the given optlist operational in the clickTk run time environmnt.

	- parse the given optlist by means of main::quotatZZ
	- scan the received optlist:
		- resolve list of option :
			- replace <widget name> with $widgets->{<widget name>}
		- resolve scalar variables:
			- replace ref name with $widgets->{<ref name>} if
			  it exists.

=cut

sub quotatZ {
	my $self = shift;
	my ($opt,$widgets) = @_;
	my $rv ;
	my @wy = &main::quotatZZ($opt);
	map {
		my $w = $_;
		if ($w =~ /^\[/) {
				$w =~ s/[\[\]]//g;
				my @v = $self->parseString($w);
				map {
					if (/^\$/) {
						s/^\$//;
						$_ = "\$widgets->{$_}" if (exists $widgets->{$_})
					} ## else {}
				} @v;
				$_ = '['.join(',',@v).']'
		} else {
				if ($w =~/^\$/) {
					$w =~ s/^\$//;
					$_ = "\$widgets->{$w}" if (exists $widgets->{$w})
				} ## else {}
		}
	} @wy;				## replace variable's name with corresponding widget
	my $wx = join ',',@wy;
	$rv = eval "[ $wx ]";
	if ($@) {
		&main::log("main::quotatZ, syntax error on form options string",$wx,$@),
		$rv = undef
		}
	return $rv;
}

=head3 quotatY

	Parse the given optlist :

		- quotate values
		- resolve list values
		- return string of options .

	Argument

		Ref to array of options
		quotating char (optional, default "'")

	Return

		stringified options separated by commas

	Notes

		- recursive call for arrays
		- empty options values are set to empty string
		- numeric values are never quoted
		- ANON blocks remain unchanged

=cut

sub quotatY {
	my $self = shift;
	my ($opt, $qc) = @_;
	my $rv ;
	my $opt_list ='';
	my $c;
	my $prefix;

	return '' unless (@$opt);

	$qc = "'" unless defined $qc;

	&main::trace("quotatY opt_list ",@$opt,"quotating char $qc");

	for (my $i = 0; $i < @$opt; $i++) {
		$c = $opt->[$i];
		if ($i % 2) {
			if ($c =~ /\^s*$/) {
				$opt_list .= "$qc$qc , "
			} elsif ($c =~ /^\d+$/) {
				$opt_list .= "$c , "
			} elsif ($c =~ /^sub\s*\{/) {
				$opt_list .= "$c , "
			} elsif ($c =~ /^\s*\[\s*\]\s*$/) {
				$opt_list .= "$c , "
			} elsif ($c =~ /^\s*\\*[\$\&]\w+/) {
				$opt_list .= "$c , "
			} elsif ($c =~ /^\s*\\*[\@%]\w+/) {
				$opt_list .= "$c , "
			} elsif ($c =~ /^\s*\[([^\]]+)\]\s*$/)  {	## array def like labelPack => [...]
				$c = $1; $c =~s/\s*=>\s*/,/g;$c =~s/^\s+//;$c =~s/\s+$//;
				$c = $self->convertQxToList($c);
				my @w = $self->parseStringQuotate($c);
				$c = $self->quotatY(\@w);
				$c = '['.$c.']';
				$opt_list .= "$c , "
			} elsif ($c =~ /^\s*\'([^\']+)\'\s*$/)  {	## already quotated
				$opt_list .= "$c , "
			} elsif ($c =~ /^\s*\"([^\"]+)\"\s*$/)  {	## already double quotated
				$opt_list .= "$c , "
			} else {
				$c =~ s/^\'/\\\'/;		## escape simple quotation
				while ($c =~ s/([^\\])\'/$1\\\'/){};
				$opt_list .= "$qc$c$qc , "
			}
		} else {
			$opt_list .= "$c , "
		}
	}
	$opt_list =~ s/,\s*$//;
	$rv = "$opt_list";
	&main::trace("rv='$rv'");
	return $rv;
}


=head3 convertToList

	The given option's string is converted to an array, whereby all
	options values are quotate by means of a call to quotatY.

	Arguments
		string to be converted
		ref to array of error's messages

	Return

		The return value is , depending on the context, an array or
		a ref to array.

	Notes

		TODO : recognize and recurse on options value lists, support qw/ list /


=cut

sub convertToList {
	my $self = shift;
	my ($s,$err) = @_;
	my $rv = [];

	$s = '' unless(defined $s);

	$s =~s/\'//g; $s =~ s/^\s*\[//; $s =~ s/\s*\]\s*$//;$s =~s/=>/,/g;
	my @w = $self->parseStringQuotate($s);
	$s = &main::quotatY(\@w,'"');
	$rv = eval "[$s]";
	push @$err, $@ if ($@);
	return wantarray ? @$rv : $rv
}


=head3 parseString

	Notation see 'parse Tk definition'

	string := substring [separator substring]
	separator := ',' | '=>' | '(' | ')' | '=' | '->'
	substring := nonquotedString | quotedString | list | quotedWords
	nonquotedString := [\S+]
	quotedString := quotedString1 | quotedString2
	quotedString1 := "'" [^\'] "'"
	quotedString2 := '"' [^\"] '"'
	list := '[' [^]]+ ']'
	quotedWords = qw '(' [^)]+ ')'		## not yet implemented

	Examples :

		string = "-text => 'This is a substring!' -bg , #FFFFFF"
		string = "-fg , white , -command => ['main::doExit',$mw,$rc]"
		string = '-fg , white , -command => ["main::doExit",$mw,$rc]'
		string = '$w = $mw->Button(-command => ["main::doExit",$mw,$rc])->pack()'

=cut

sub parseString {
my $self = shift;
my $string = shift;
my @rv;
my $substring ;
my $READNEXT = 1;
my $QUOTEDSTRING1 = 2;
my $QUOTEDSTRING2 = 4;
my $LIST = 8;
my $NONQUOTEDSTRING = 16;
my $ANONBLOCK0 = 32;
my $ANONBLOCK1 = 64;
my $QUOTEDWORDS = 132;

my $state = $READNEXT;
my $c;
my $is;

	for (my $i = 0; $i < length ($string) ; $i++) {
		$c = substr($string,$i,1);
		if ($state == $READNEXT) {
			if ($c eq ' ') {
				next
			} elsif ($c eq "'") {
				$state = $QUOTEDSTRING2
			} elsif ($c eq '"') {
				$state = $QUOTEDSTRING1
			} elsif ($c eq "[") {
				$substring .= $c;
				$state = $LIST;
			} elsif ($c eq ",") {
				push @rv, $substring if defined($substring);
				undef $substring ;
			} elsif ($c eq "=" ) {
				push @rv, $substring if defined($substring);
				undef $substring;
				$i++ if (substr ($string,$i+1,1) eq '>');
			} elsif ($c eq "-" && substr ($string,$i+1,1) eq '>') {
				push @rv, $substring if defined($substring);
				undef $substring;
				$i++;
			} elsif ($c eq "(" ) {
				push @rv, $substring if defined($substring);
				undef $substring;
			} elsif ($c eq ")" ) {
				push @rv, $substring if defined($substring);
				undef $substring;
			} elsif ($c eq 's' ) {
				push @rv, $substring if defined($substring);
				$substring = $c;
				$is = $i;
				$state = $ANONBLOCK0;
			} else {
				push @rv, $substring if defined($substring);
				$substring = $c;
				$state = $NONQUOTEDSTRING
			}
		}elsif ($state == $QUOTEDSTRING1) {
			if ($c eq '"') {
				$state = $READNEXT
			} else { $substring .= $c }
		}elsif ($state == $QUOTEDSTRING2) {
			if ($c eq "'") {
				$state = $READNEXT
			} elsif($c eq '\\' && substr($string,$i+1,1) eq '\'') {
				$substring .= $c.substr($string,$i+1,1);
				$i++;
			} else { $substring .= $c }
		}elsif ($state == $LIST) {
			if ($c eq ']') {
				$substring .= $c;
				## ----------------- 07.12.2009/mam experimental code
				$substring =~ s/^.//;
				$substring =~ s/.$//;
				my @w = $self->parseString($substring);
				$substring = $self->quotatY(\@w,'"');
				$substring = '['.$substring.']';
				## ----------------- 07.12.2009/mam experimental code end
				$state = $READNEXT
			} else { $substring .= $c }
		}elsif ($state == $NONQUOTEDSTRING) {
			if ($c =~ /[,()]/) {
				push @rv , $substring;
				undef $substring;
				$state = $READNEXT
			} elsif($c eq ' ' ) {
				push @rv , $substring;
				undef $substring;
				$state = $READNEXT
			} elsif($c eq '=' ) {
				push @rv , $substring;
				undef $substring;
				$i++ if (substr($string,$i+1,1) eq '>');
				$state = $READNEXT
			} elsif($c eq '-' && substr($string,$i+1,1) eq '>') {
				push @rv , $substring;
				undef $substring;
				$i++;
				$state = $READNEXT
			} elsif ($c eq '\\' && substr($string,$i+1,1) eq '\'') {
				$substring .= $c.substr($string,$i+1,1);
				$i++;
			} else {
				$substring .= $c
			}
		} elsif($state == $ANONBLOCK0) {
			$substring .= $c;
			if (length($substring) == 3) {
				if ($substring !~ /^sub/) {
					$substring = substr($string,$is,1);
					$i = $is;
					undef $is;
					$state = $NONQUOTEDSTRING
				}
			} elsif (length($substring) > 3) {
				if ($c eq '{') {
					$state = $ANONBLOCK1
				} elsif ($c eq ' ') {
					$substring =~ s/\s$//;
				} else {
					$substring = substr($string,$is,1);
					$i = $is;
					undef $is;
					$state = $NONQUOTEDSTRING
				}
			} else {
				# simply stack char
			}
		} elsif($state == $ANONBLOCK1) {
			$substring .= $c;
			if ($c eq '}') {
				push @rv , $substring;
				undef $substring;
				$state = $READNEXT
			} ## else {}
		} else {
			die "Unexpected state '$state',cannot proceed parseString"
		}
	}
	push @rv, $substring if defined($substring);
	return wantarray ? @rv : scalar(@rv);
}

=head3 parseStringQuotate

	Notation see 'parse Tk definition'

	string := substring [separator substring]
	separator := ',' | '=>' | '(' | ')' | '=' | '->'
	substring := nonquotedString | quotedString | list | quotedWords
	nonquotedString := [\S+]
	quotedString := quotedString1 | quotedString2
	quotedString1 := "'" [^\'] "'"
	quotedString2 := '"' [^\"] '"'
	list := '[' [^]]+ ']'
	quotedWords = qw '(' [^)]+ ')'		## not yet implemented

	Example :

	string = "-text => 'This is a substring!' -bg , #FFFFFF"
	string = "-fg , white , -command => ['main::doExit',$mw,$rc]"
	string = '-fg , white , -command => ["main::doExit",$mw,$rc]'
	string = '$w = $mw->Button(-command => ["main::doExit",$mw,$rc])->pack()'

	Unlike parseString, this method carries the quotations marks into output values.

Thus, the string

	string = "-text => 'This is a substring!' -bg , #FFFFFF"

	yields the token list

		-text 'This is a substring!' -bg '#FFFFFF'

=cut

sub parseStringQuotate {
my $self = shift;
my $string = shift;
my @rv;
my $substring ;
my $READNEXT = 1;
my $QUOTEDSTRING1 = 2;
my $QUOTEDSTRING2 = 4;
my $LIST = 8;
my $NONQUOTEDSTRING = 16;
my $ANONBLOCK0 = 32;
my $ANONBLOCK1 = 64;

my $state = $READNEXT;
my $c;
my $is;

	for (my $i = 0; $i < length ($string) ; $i++) {
		$c = substr($string,$i,1);
		if ($state == $READNEXT) {
			if ($c eq ' ') {
				next
			} elsif ($c eq "'") {
				$state = $QUOTEDSTRING2;
				$substring = $c;
			} elsif ($c eq '"') {
				$substring = $c;
				$state = $QUOTEDSTRING1
			} elsif ($c eq "[") {
				$substring .= $c;
				$state = $LIST;
			} elsif ($c eq ",") {
				push @rv, $substring if defined($substring);
				undef $substring ;
			} elsif ($c eq "=" ) {
				push @rv, $substring if defined($substring);
				undef $substring;
				$i++ if (substr ($string,$i+1,1) eq '>');
			} elsif ($c eq "-" && substr ($string,$i+1,1) eq '>') {
				push @rv, $substring if defined($substring);
				undef $substring;
				$i++;
			} elsif ($c eq "(" ) {
				push @rv, $substring if defined($substring);
				undef $substring;
			} elsif ($c eq ")" ) {
				push @rv, $substring if defined($substring);
				undef $substring;
			} elsif ($c eq 's' ) {
				push @rv, $substring if defined($substring);
				$substring = $c;
				$is = $i;
				$state = $ANONBLOCK0;
			} else {
				push @rv, $substring if defined($substring);
				$substring = $c;
				$state = $NONQUOTEDSTRING
			}
		}elsif ($state == $QUOTEDSTRING1) {
			if ($c eq '"') {
				$substring .= $c;
				$state = $READNEXT
			} else { $substring .= $c }
		}elsif ($state == $QUOTEDSTRING2) {
			if ($c eq "'") {
				$substring .= $c;
				$state = $READNEXT
			} elsif($c eq '\\' && substr($string,$i+1,1) eq '\'') {
				$substring .= $c.substr($string,$i+1,1);
				$i++;
			} else { $substring .= $c }
		}elsif ($state == $LIST) {
			if ($c eq ']') {
				$substring .= $c;
				## ----------------- 07.12.2009/mam experimental code
				$substring =~ s/^.//;
				$substring =~ s/.$//;
				$c = $self->convertQxToList($c);
				my @w = $self->parseStringQuotate($substring);
				$substring = $self->quotatY(\@w,'"');
				$substring = '['.$substring.']';
				## ----------------- 07.12.2009/mam experimental code end
				$state = $READNEXT
			} else { $substring .= $c }
		}elsif ($state == $NONQUOTEDSTRING) {
			if ($c =~ /[,()]/) {
				push @rv , $substring;
				undef $substring;
				$state = $READNEXT
			} elsif($c eq ' ' ) {
				push @rv , $substring;
				undef $substring;
				$state = $READNEXT
			} elsif($c eq '=' ) {
				push @rv , $substring;
				undef $substring;
				$i++ if (substr($string,$i+1,1) eq '>');
				$state = $READNEXT
			} elsif($c eq '-' && substr($string,$i+1,1) eq '>') {
				push @rv , $substring;
				undef $substring;
				$i++;
				$state = $READNEXT
			} elsif ($c eq '\\' && substr($string,$i+1,1) eq '\'') {
				$substring .= $c.substr($string,$i+1,1);
				$i++;
			} else {
				$substring .= $c
			}
		} elsif($state == $ANONBLOCK0) {
			$substring .= $c;
			if (length($substring) == 3) {
				if ($substring !~ /^sub/) {
					$substring = substr($string,$is,1);
					$i = $is;
					undef $is;
					$state = $NONQUOTEDSTRING
				}
			} elsif (length($substring) > 3) {
				if ($c eq '{') {
					$state = $ANONBLOCK1
				} elsif ($c eq ' ') {
					$substring =~ s/\s$//;
				} else {
					$substring = substr($string,$is,1);
					$i = $is;
					undef $is;
					$state = $NONQUOTEDSTRING
				}
			} else {
				# simply stack char
			}
		} elsif($state == $ANONBLOCK1) {
			$substring .= $c;
			if ($c eq '}') {
				push @rv , $substring;
				undef $substring;
				$state = $READNEXT
			} ## else {}
		} else {
			die "Unexpected state '$state',cannot proceed parseString"
		}
	}
	push @rv, $substring if defined($substring);
	return wantarray ? @rv : scalar(@rv);
}

=head3 parseStringExtended

	Notation see 'parse Tk definition'

	string := substring [separator substring]
	separator := ',' | '=>' | '(' | ')' | '=' | '->'
	substring := nonquotedString | quotedString | list | quotedWords
	nonquotedString := [\S+]
	quotedString := quotedString1 | quotedString2
	quotedString1 := "'" [^\'] "'"
	quotedString2 := '"' [^\"] '"'
	list := '[' [^]]+ ']'
	quotedWords = qw '(' [^)]+ ')'		## not yet implemented

	Example :

	string = "-text => 'This is a substring!' -bg , #FFFFFF"
	string = "-fg , white , -command => ['main::doExit',$mw,$rc]"
	string = '-fg , white , -command => ["main::doExit",$mw,$rc]'
	string = '$w = $mw->Button(-command => ["main::doExit",$mw,$rc])->pack()'

	Unlike parseSring this method creates a token for '=','(',')','->' and ';'
	when it is in state READNEXT.
	This allow a further process to recognize options lists, type and id as in
	<id> = <parent>-><class>(<optionslist>)-><geom-manager>(<geom-optlist>);


=cut

sub parseStringExtended {
my $self = shift;
my $string = shift;
my @rv;
my $substring ;
my $READNEXT = 1;
my $QUOTEDSTRING1 = 2;
my $QUOTEDSTRING2 = 4;
my $LIST = 8;
my $NONQUOTEDSTRING = 16;
my $ANONBLOCK0 = 32;
my $ANONBLOCK1 = 64;

my $state = $READNEXT;
my $c;
my $is;

	for (my $i = 0; $i < length ($string) ; $i++) {
		$c = substr($string,$i,1);
		if ($state == $READNEXT) {
			if ($c eq ' ') {
				next
			} elsif ($c eq "'") {
				$state = $QUOTEDSTRING2
			} elsif ($c eq '"') {
				$state = $QUOTEDSTRING1
			} elsif ($c eq "[") {
				$substring .= $c;
				$state = $LIST;
			} elsif ($c eq ",") {
				push @rv, $substring if defined($substring);
				undef $substring ;
			} elsif ($c eq "=" ) {
				push @rv, $substring if defined($substring);
				push @rv, $c;
				undef $substring;
				$i++ if (substr ($string,$i+1,1) eq '>');
			} elsif ($c eq "-" && substr ($string,$i+1,1) eq '>') {
				push @rv, $substring if defined($substring);
				push @rv, '->';
				undef $substring;
				$i++;
			} elsif ($c eq "(" ) {
				push @rv, $substring if defined($substring);
				push @rv, $c;
				undef $substring;
			} elsif ($c eq ")" ) {
				push @rv, $substring if defined($substring);
				push @rv, $c;
				undef $substring;
			} elsif ($c eq 's' ) {
				push @rv, $substring if defined($substring);
				$substring = $c;
				$is = $i;
				$state = $ANONBLOCK0;
			} elsif ($c eq ";" ) {
				push @rv, $substring if defined($substring);
				push @rv, $c;
				undef $substring;
			} else {
				push @rv, $substring if defined($substring);
				$substring = $c;
				$state = $NONQUOTEDSTRING
			}
		}elsif ($state == $QUOTEDSTRING1) {
			if ($c eq '"') {
				$state = $READNEXT
			} else { $substring .= $c }
		}elsif ($state == $QUOTEDSTRING2) {
			if ($c eq "'") {
				$state = $READNEXT
			} elsif ($c eq '\\' && substr($string,$i+1,1) eq '\'') {
				$substring .= $c.substr($string,$i+1,1);
				$i++;
			} else { $substring .= $c }
		}elsif ($state == $LIST) {
			if ($c eq ']') {
				$substring .= $c;
				## ----------------- 07.12.2009/mam experimental code
				$substring =~ s/^.//;
				$substring =~ s/.$//;
				my @w = $self->parseStringExtended($substring);
				$substring = $self->quotatY(\@w,'"');
				$substring = '['.$substring.']';
				## ----------------- 07.12.2009/mam experimental code end
				$state = $READNEXT
			} else { $substring .= $c }
		}elsif ($state == $NONQUOTEDSTRING) {
			if ($c =~ /[,()]/) {
				push @rv , $substring;
				push @rv, $c if $c =~/[()]/;
				undef $substring;
				$state = $READNEXT
			} elsif($c eq ' ' ) {
				push @rv , $substring;
				undef $substring;
				$state = $READNEXT
			} elsif($c eq '=' ) {
				push @rv , $substring;
				undef $substring;
				if (substr($string,$i+1,1) eq '>') {
					$i++
				} else {
					push @rv , $c
				}
				$state = $READNEXT
			} elsif($c eq '-' && substr($string,$i+1,1) eq '>') {
				push @rv , $substring;
				push @rv , '->';
				undef $substring;
				$i++;
				$state = $READNEXT
			} elsif ($c eq '\\' && substr($string,$i+1,1) eq '\'') {
				$substring .= $c.substr($string,$i+1,1);
				$i++;
			} else {
				$substring .= $c
			}
		} elsif($state == $ANONBLOCK0) {
			$substring .= $c;
			if (length($substring) == 3) {
				if ($substring !~ /^sub/) {
					$substring = substr($string,$is,1);
					$i = $is;
					undef $is;
					$state = $NONQUOTEDSTRING
				}
			} elsif (length($substring) > 3) {
				if ($c eq '{') {
					$state = $ANONBLOCK1
				} elsif ($c eq ' ') {
					$substring =~ s/\s$//;
				} else {
					$substring = substr($string,$is,1);
					$i = $is;
					undef $is;
					$state = $NONQUOTEDSTRING
				}
			} else {
				# simply stack char
			}
		} elsif($state == $ANONBLOCK1) {
			$substring .= $c;
			if ($c eq '}') {
				push @rv , $substring;
				undef $substring;
				$state = $READNEXT
			} ## else {}
		} else {
			die "Unexpected state '$state',cannot proceed parseString"
		}
	}
	push @rv, $substring if defined($substring);
	return wantarray ? @rv : scalar(@rv);
}

=head3 Method parseWidgetOptions

	Method parseWidgetOptions converts a token list into
	an useable options list.

	In fact the method parseString do not recognize
	compound options like anonymous subroutines.

=over

=item Input

	Token list

=item Output

	Valid options list (array)

=item Precondition

	Method parseString successfully done (lexer)

=back

=cut

sub parseWidgetOptions {
	my $self = shift;
	my (@token) = @_;
	my @rv =();
	my $anon;

	my $state;
	my $ANON = 1;
	my $READNEXT = 0;
	## my $XXX ; ## add here other states

	for (my $i = 0, $state = $READNEXT; $i < @token; $i++) {
		my $c = $token[$i];
		if ($state == $READNEXT) {
			if ($c =~ /^\s*sub\s*$/ && ($i % 2)) {
				$anon = $c;
				$state = $ANON
			#} elsif ($i % 2) {
			#	push @rv, ($c =~ /^[\"\']/ && $c =~/[\"\']$/) ? $c : "'" . $c . "'"
			} else {
				push @rv, $c
			}
		} elsif ($state == $ANON) {
			$anon .= $c;
			if ($c =~ /^\s*\}\s*$/) {
				push @rv,$anon;
				undef $anon;
				$state = $READNEXT
				} ## else
		## } elsif ($state == $XXX) { ## add here other productions
		} else {
			die "parseWidgetOptions: unknown state '$state'"
		}
	}
	return wantarray ? @rv : scalar(@rv);
}

=head3 parseWidgetOptionsQuotate

	Same as parseWidgetOptions but surrounding otions
	which contains \S oe [\\\/] with simple quotations

	Precondition : input tokenlist doesn't contain quotated
	               tokens!

=cut

sub parseWidgetOptionsQuotate {
	my $self = shift;
	my (@token) = @_;
	my @rv =();
	my $anon;

	my $state;
	my $ANON = 1;
	my $READNEXT = 0;
	## my $XXX ; ## add here other states

	for (my $i = 0, $state = $READNEXT; $i < @token; $i++) {
		my $c = $token[$i];
		if ($state == $READNEXT) {
			if ($c =~ /^\s*sub\s*$/ && ($i % 2)) {
				$anon = $c;
				$state = $ANON;
			} elsif ($c =~ /^[\\][\$%@&]/) {		## ref to variable
				push @rv, $c ;
			} else {
				push @rv, ($c =~ /[\s\\\/]/) ? "'". $c . "'" : $c ;
			}
		} elsif ($state == $ANON) {
			$anon .= $c;
			if ($c =~ /^\s*\}\s*$/) {
				push @rv,$anon;
				undef $anon;
				$state = $READNEXT;
				} ## else
		## } elsif ($state == $XXX) { ## add here other productions
		} else {
			die "parseWidgetOptions: unknown state '$state'"
		}
	}
	return wantarray ? @rv : scalar(@rv);
}

=head3 convertQxToList

	Convert  qw() or qw// or or qq() or qq// into a list of values.

	qw/1 2 3/ yields '1','2','3'

	Exception : 'Could not convert qw resp qq list'

	Notes:

	- If no qw command is found, the input string is returned unchanged.
	- Unlike parse_qw_array this method doesn't quotate the items.
	- No recursion!

=cut

sub convertQxToList {
	my $self = shift;
	my ($qx) = @_;
	my $rv;
	if ($qx =~ /^\s*q[qw][\/\(]/) {
		my @w;
		eval "\@w = $qx";
		die "Could not convert qw resp qq list $@" if($@);
		$rv = join(',',@w);
	} else {
		$rv = $qx
	}
	return $rv
}


=head3 parse_qw_array

	This method convert a string containing a qw(list)
	into an array or a string containing a list of quotated
	items as ruled by clickTk.

	the following formats are valid

	'[qw( options list)]'
	'(qw/ options list/)'
	'qq/-option, value , option ,value, .../
	'qq/-option, value , option ,\$var, .../


	Arguments

		string to be converted

	Return

		array of tokens in array context, or
		string of the eval array otherwise.


	Exceptions

		Could not eval

	Notes

		None

=cut

sub parse_qw_array {
	my $self = shift;
	my ($s,$quotation) = @_;
	my @rv;
	my ($w,$dlm1,$dlm2);

	$quotation = 0 unless defined $quotation;
	&main::trace("parse_qw_array quotation = $quotation");

	$s =~ s/^\s+//;	$s =~ s/\s+$//;
	if ($s =~ /^\[([^\]]*)\]$/) {
		$w = $1;
		($dlm1,$dlm2) = ('[',']');
	} elsif ($s =~ /^\(([^\]]*)\)$/) {
		$w = $1;
		($dlm1,$dlm2) = ('(',')');
	} else {
		$w = $s;
		($dlm1,$dlm2) = ('','');
	}

	if ($w =~ /^\s*qw/) {
		@rv = eval $w;
		die "Could not eval '$s' because of $@" if ($@);
		$w = join(',',@rv);
	} elsif($w =~ /^\s*qq/) {
		$w = eval $w;
		die "Could not eval '$s' because of $@" if ($@);
	} else{
	}

	@rv = ctkWidgetOption->_split_opt($w);
	@rv = $self->quotatZZ(\@rv) if ($quotation);

	return wantarray ?
		($dlm1 && $dlm2) ?
		($dlm1,@rv,$dlm2) : ($dlm1) ?
		($dlm1, @rv) : ($dlm2) ?
		(@rv,$dlm2) : @rv :
		$dlm1 . join(' , ',@rv) . $dlm2
}

=head3 Parse Tk widget definition

	Notation :

		{}			iteration of 0..1 items
		[]			iteration of 0..n items
		()			iteration of 1..n items
		|			selection (inclusive or)
		& or none	sequence (mandatory)
		.			concatenation (subsequence)
		word		non terminal token \w+
		'x'			ascii char (terminal token)
		"x"			ascii char (terminal token)
		"\'"		ascii char (terminal token)
		\w,\d,		perl regexp elements
		/regexp/

	Definition

		def := (widgetDef | variable)  {'->' geometryDef} ';'
		widgetDef :=  variable '=' variable '->' className {'(' {widgetOptions} ')'} ';'

		variable := '$'.\w+
		classname := \w+

		widgetOptions = [optionsName '=>' | ',' value]
		optionsname := '-' \w

		value := baseValue | variable | reference | array
		simpleValue := numeric | string
		numeric := \d+
		string := delimiter (chars) delimiter
		delimiter := ''' | '"'
		chars := \S | '\'chars
		reference := '\' variable | 'sub' '{' code '}' | '\'.entry
		code := '&'.entry {'(' list ')'}
		entry {{\w+]}.'::'}.\w+
		array :=  staticArray | dynamicArray
		staticArray := '(' list  ')'
		dynamicArray := '[' list ']'

		list := [value [',' value]]

		geometryDef := geometryManager {'(' geometryOptions ')'}
		geometryOptions := [optionsName '=>' | ',' baseValue]

=cut

sub parseWidgetDefinition {
	my ($line) = @_;
	my %rv =();
	## TODO: see parseWidgetOptions
	return %rv
}

BEGIN {1}
END{1}
1; ## make perl happy ...

