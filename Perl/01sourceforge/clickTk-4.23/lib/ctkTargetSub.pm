=pod

=head1 ctkTargetSub

	Class targetSub models the functionality to generate
	the target of type subroutine.
	It derives from class targetCode.

=head2 Syntax


		use ctkTargetSub;

		ctkTargetSub->generate();

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
	genVariablesLocal


=back

=head2 Maintenance

	Author:	Marco
	date:	28.10.2006
	History
			28.11.2007 MO03501 mam refactoring
			28.10.2008 version 1.02
			28.11.2008 version 1.03
			28.07.2010 version 1.04

=cut

package ctkTargetSub;

use strict;

use ctkFile;
use base (qw/ctkTargetCode/);

use Time::localtime;

our $VERSION = 1.04;

our $debug = 0;

my $ctkC ;

our $subroutineArgsName = '';
our $subroutineName  = '';
our $opt_defaultSubroutineArgs = '';

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
	my $file_opt = &main::getFile_opt();
	my $subroutineArgsName = $file_opt->{'subroutineArgsName'};
	$subroutineArgsName = '%args' if (!defined($subroutineArgsName) || $subroutineArgsName =~ /^\s$/);
	my $subroutineArgs = $file_opt->{'subroutineArgs'};
	my $subroutineName = $file_opt->{'subroutineName'};

	$ctkC = $main::ctkC unless defined($ctkC);

	$code = $self->genTestCode($code,$now,$mw);

	push @$code,"sub $subroutineName {";
	push @$code,'my $hwnd = shift;';
	if ($file_opt->{'subroutineArgs'}) {
		push @$code,"my ($subroutineArgsName) = \@_;";
	} else {
		push @$code,"my $subroutineArgsName =();" unless (grep /$subroutineArgsName/ , @ctkProject::user_auto_vars);
	}
	push @$code,"my \$rv;";
	push @$code,"##";

	$self->genVariablesLocal($code,$mw);

	push @$code,"##";


	if ($file_opt->{modal}) {
			my $a = $subroutineArgsName; $a =~ s/^\%/\$/;
			my $buttons = $file_opt->{'buttons'};
			$buttons = 'OK Cancel' if $buttons =~ /^\s*$/;
			push @$code,'my $'.$mw.' = $hwnd->'.$file_opt->{'modalDialogClassName'}.'(';
			push @$code, '	-title=> (exists '.$a.'{-title})? '.$a.'{-title}:'."'$file_opt->{title}',";
			push @$code, '	 -buttons=> (exists '.$a.'{-buttons}) ? '.$a.'{-buttons} : [qw('.$buttons.')]);';
	} else {
			if ($file_opt->{'Toplevel'}) {
				my $a = $subroutineArgsName; $a =~ s/^\%/\$/;
				push @$code,'my $'.$mw.' = $hwnd->Toplevel();';
				push @$code,'$mw->configure(-title=> (exists '.$a.'{-title})? '.$a.'{-title}:'."'$file_opt->{-title}');";
			} else {
				push @$code,'my $'.$mw.' = $hwnd;';
			}
	}
	$code = $self->genOnDeleteWindow($code,$now,$mw);

	push @$code , "\n";

	$code = $self->genGcode($code);

	my $tkCode = $self->gen_TkCode($mw);
	map { push @$code ,$_ } @$tkCode;

	if ($file_opt->{modal}) {
			push @$code, '$rv =  $'.$mw.'->Show();';
	} else {
		if ($file_opt->{'Toplevel'}) {
			push @$code, '$rv = $'.$mw.';';
		} else {
			push @$code, '$rv = 1;';
		}
	}
	push @$code , "\n return \$rv;\n";
	push @$code , "} ## end of $subroutineName \n";
	push @$code , "$ctkC end of dialog code";

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
	&main::trace("genTestCode4subroutine");

	$self->genVariablesGlobal($code,$mw);

	return $code unless ($main::opt_TestCode);

	my $file_opt = &main::getFile_opt();
	my $subroutineArgsName = $file_opt->{'subroutineArgsName'};
	my $subroutineArgs = $file_opt->{'subroutineArgs'};
	my $subroutineName = $file_opt->{'subroutineName'};

	## $self->genVariablesGlobal($code,$mw);
	push @$code ,"&main::init();";
	if ($file_opt->{modal}) {
		my $args = $file_opt->{'subroutineArgs'} ;
		if ($args) {
			push @$code ,"my \$answer = \&main::$subroutineName(\$$mw,$args);";
		} else {
			push @$code ,"my \$answer = \&main::$subroutineName(\$$mw);";
		}
		push @$code ,'print "\nanswer = \'$answer\'";';
	} else {
		my $args = $file_opt->{'subroutineArgs'} ;
		if ($args) {
			push @$code ,"&main::$subroutineName(\$$mw,$args);";
		} else {
			push @$code ,"&main::$subroutineName(\$$mw);";
		}
	}
	$code = $self->genCalls2Test($code,$now,$mw);
	push @$code ,"MainLoop;\n";
	return $code
}

sub genVariablesLocal {
	my $self = shift;
	my ($code, $mw) = @_;
	&main::trace("genVariablesLocal");
	my @w = sort @ctkProject::user_local_vars;
	@w = grep ($_ ne $subroutineArgsName, @w);
	push @$code , "$ctkC Localvars";
	push @$code , "\nmy (".join(',',@w).");\n" if (@w);
	push @$code , "$ctkC Localvars end";
	return $code
}

## sub import {}

BEGIN { 1 }
END {1 }

1; ## -----------------------------------
