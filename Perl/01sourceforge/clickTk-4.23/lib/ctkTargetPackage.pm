=pod

=head1 ctkTargetPackage

	Class ctkTargetPackage models the functionality to generate
	the target of type Package.
	It derives from class targetCode.

=head2 Syntax


		use ctkTargetPackage;

		ctkTargetPackage->generate();

=head2 Programming notes

=over

=item Methods

	new
	destroy
	_init
	generate
	genTestCode
	genCallbacks
	genMethods
	parse
	load


=back

=head2 Maintenance

	Author:	Marco
	date:	28.10.2006
	History
			28.11.2007 MO03501 mam refactoring
			02.12.2009 version 1.02
			02.08.2010 Version 1.03

=cut

package ctkTargetPackage;

use base (qw/ctkTargetCode/);

use Time::localtime;

our $VERSION = 1.03;

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
	&main::trace("generate");
	my $file_opt = &main::getFile_opt();
	$ctkC = $main::ctkC unless defined($ctkC);

	$mw = '$self' unless (defined($mw));
	@ctkProject::baseClass = split /\s+/, $file_opt->{'baseClass'} if ($file_opt->{'baseClass'});
	my $pkg = &main::tail($main::projectName);

	$pkg =~ s/\..+$//;
	push @$code ,"\n";
	push @$code ,"package $pkg;";
	push @$code ,"use vars qw(\$VERSION);";
	push @$code ,"\$VERSION = '1.01';";
	map {
		push @$code ,"require $_;";
	} @ctkProject::baseClass;

	if (grep (/Tk::Toplevel|Tk::DialogBox/,@ctkProject::baseClass)) {
		if ($file_opt->{'Toplevel'}) {
			$file_opt->{'Toplevel'} = 0;
			main::Log("Option 'Toplevel' deactivated because of base class.");
		}
	} else {
		unless ($file_opt->{'Toplevel'}) {
			$file_opt->{'Toplevel'} = 1;
			main::Log("Option 'Toplevel' activated because of base class.");
		}
	}

	push @$code ,"require Tk::Derived;";
	push @$code ,"\@$pkg\:\:ISA = qw(Tk::Derived ".join (' ',@ctkProject::baseClass).");";

	push @$code ,"Construct Tk::Widget '$pkg';";

	$code = $self->genGlobalVariablesClassVariables($code,$mw);

	push @$code ,"sub ClassInit {";
	push @$code ,"\tmy \$self = shift;";
	push @$code ,"##";
	push @$code ,"## \tinit class";
	push @$code ,"##";
	push @$code ,"\t\$self->SUPER::ClassInit(\@_);";
	push @$code ,"";
	$code = $self->genGcode($code,$mw);
	push @$code ,"}";

	push @$code ,"sub Populate {";
	push @$code ,"\tmy (\$self,\$args) = \@_;";
	push @$code ,"##";

	$self->genVariablesLocal($code,$mw);

	push @$code ,"## \tmove args to local variables";
	push @$code ,"##";
 	push @$code ,"\t\$self->SUPER::Populate(\$self->arglist(\$args));";
	push @$code ,"##";
	push @$code ,"## \t set up ConfigSpecs \t(optional)";
	push @$code ,"##";
	push @$code ,"\tmy \$mw = \$self;";

	my $tkCode = $self->gen_TkCode($mw);
	map { push @$code ,$_ } @$tkCode;
	push @$code ,"##";
	push @$code ,"\treturn \$self;";
	push @$code ,"}";

	$code = $self->genMethods($code,$now);

	$code = $self->genTestCode($code,$now,&main::getMW);

	$code = $self->genCallbacks($code,$now);
	return wantarray ? @$code : $code
}

sub genTestCode {
	my $self = shift;
	my ($code,$now,$mw) = @_;
	&main::trace("genTestCode");

	return $code unless ($main::opt_TestCode);

	my $file_opt = &main::getFile_opt();
	my $pkg = &main::tail($main::projectName);
	$pkg =~ s/\..+$//;
	push @$code ,"";
	push @$code, "$ctkC testCode";
	push @$code ,"# -----------------------------------------------";
	push @$code ,"##";
	push @$code ,"package main;";
	push @$code ,"&main::init();";
	if ($file_opt->{'subroutineArgs'}) {
		push @$code ,"my (\%args) =(".$file_opt->{'subroutineArgs'}.");";
	} else {
		push @$code ,"my (\%args) =();";
	}
	if ( $file_opt->{'modal'}) {
		push @$code ,"my \$instance = \$$mw->$pkg(\%args);";
		$code = $self->genOnDeleteWindow($code,$now,'instance');
	} elsif ($file_opt->{'Toplevel'}) {
			push @$code ,"my \$toplevel = \$$mw->Toplevel();";
			push @$code ,"my \$instance = \$toplevel->$pkg(\%args)->pack();";
			$code = $self->genOnDeleteWindow($code,$now,'toplevel');
	} else {
			push @$code ,"my \$instance = \$$mw->$pkg(\%args)->pack();";
			## $code = $self->genOnDeleteWindow($code,$now,'instance');
	}
	$code = $self->genOnDeleteWindow($code,$now,$mw);
	$code = $self->genCalls2Test($code,$now,'$instance');
	push @$code ,"MainLoop;\n";
	push @$code ,"##";
	push @$code, "$ctkC testCode";
	push @$code ,"";
	return $code
}

sub genCallbacks {
	my $self = shift;
	my ($code,$now) = @_;
	$code = $self->SUPER::genCallbacks($code,$now) if ($main::opt_TestCode);
	return $code;
}

sub genMethods {
	my $self = shift;
	my ($code,$now) = @_;
	&main::trace("genMethods");
	$ctkC = $main::ctkC unless defined($ctkC);

	if(@ctkProject::user_methods_code){
		push @$code , "$ctkC methods";
		map{push @$code , $_ } @ctkProject::user_methods_code;
	} else {
		push @$code , "$ctkC methods";
		push @$code , "sub arglist { shift; return shift}";
	}
	push @$code , "$ctkC methods end";
	return $code;
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

## sub import {}

BEGIN { 1 }
END {1 }

1; ## -----------------------------------
