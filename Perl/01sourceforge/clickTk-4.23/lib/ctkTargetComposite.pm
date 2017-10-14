=pod

=head1 ctkTargetComposite

	Class ctkTargetComposite models the functionality to generate
	the target of type composite.
	It derives from class targetCode.

=head2 Syntax


	use ctkTargetComposite;

	ctkTargetComposite->generate();

=head2 Programming notes

=over

=item Methods

	new
	destroy
	_init
	generate
	genConfigSpecs
	genDelegates
	genAdvertisedWidgets
	genMethods
	genTestCode
	genCallbacks
	parseAndSaveConfigSpec
	parseAndSaveDelegates
	parse (for future use)
	load (for future use)

=back

=head2 Maintenance

	Author:	Marco
	date:	28.10.2006
	History
			28.11.2007 MO03501 mam refactoring
			28.05.2008 mo03801 version 1.02
			02.12.2009 version 1.03
			30.07.2010 version 1.04
			20.02.2013 version 1.05

=cut

package ctkTargetComposite;

use base (qw/ctkTargetCode/);

use Time::localtime;

our $VERSION = 1.05;

our $debug = 0;

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

sub isToplevel {
	my $self = shift;
	my $rv;
	$rv	= (grep (/Tk::Toplevel|Tk::DialogBox/,@ctkProject::baseClass)) ? 1 : 0;
	return $rv;
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
	$mw = 'self' unless (defined($mw));
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

	if ($self->isToplevel) {
		if ($file_opt->{'Toplevel'}) {
			$file_opt->{'Toplevel'} = 0;
			main::Log("Option Toplevel deactivated because of base class.");
		}
	} else {
		unless ($file_opt->{'Toplevel'}) {
			$file_opt->{'Toplevel'} = 1;
			main::Log("Option Toplevel activated because of base class.");
		}
	}

	push @$code ,"require Tk::Derived;";
	push @$code ,"\@$pkg\:\:ISA = qw(Tk::Derived ".join (' ',@ctkProject::baseClass).");";

	push @$code ,"Construct Tk::Widget '$pkg';";

	$code = $self->genGlobalVariablesClassVariables($code,$mw);

	push @$code ,"sub ClassInit {";
	push @$code ,"\tmy \$$mw = shift;";
	push @$code ,"##";
	push @$code ,"## \tinit class";
	push @$code ,"##";
	push @$code ,"\t\$$mw->SUPER::ClassInit(\@_);";
	push @$code ,"";

	$self->genGcode($code,$mw);

	push @$code ,"}";

	push @$code ,"sub Populate {";
	push @$code ,"\tmy (\$$mw,\$args) = \@_;";
	push @$code ,"##";

	$self->genVariablesLocal($code,$mw);

	push @$code ,"## \tmove args to local variables)";
	push @$code ,"##";
 	push @$code ,"\t\$$mw->SUPER::Populate(\$self->arglist(\$args));";
	push @$code ,"##";
	push @$code ,"##";
	push @$code ,'my $'.&main::getMW." = \$$mw;";

	my $tkCode = $self->gen_TkCode($mw);
	map { push @$code ,$_ } @$tkCode;

	$code = $self->genAdvertisedWidgets($code,$now);
	$code = $self->genConfigSpecs($code,$now);
	$code = $self->genDelegates($code,$now);
	if ($self->isToplevel) {
			$code = $self->genOnDeleteWindow($code,$now,'self');
	}
	push @$code ,"\treturn \$self;";
	push @$code ,"}";

	$code = $self->genMethods($code,$now);

	$code = $self->genTestCode($code,$now,&main::getMW);
	$code = $self->genCallbacks($code,$now) ;

	return wantarray ? @$code : $code
}

sub genConfigSpecs {

	my $self = shift;
	my ($code,$now,$mw) = @_;
	&main::trace("genConfigSpecs");
	my $file_opt = &main::getFile_opt();
	$ctkC = $main::ctkC unless defined($ctkC);
	if (exists $file_opt->{'ConfigSpecs'}) {
		push @$code,"$ctkC ConfigSpecs ";
		push @$code,"\t\$self->ConfigSpecs(";
		my $w = eval $file_opt->{'ConfigSpecs'};
		map {
			my $k = $_;
			my $v = $w->{$k};
			map {
				$v->[$_]= undef unless ($v->[$_]);
				$v->[$_] = defined($v->[$_]) ? $self->quoteValue($v->[$_]) : 'undef';
			} 0 .. @$v - 1;
			## my $s = $self->quoteValue($_) .'=>['.$v->{-where}.','.$v->{-classname}.',' . $v->{-dbname}.',' . $v->{-default}.']';
			my $s = $self->quoteValue($k) .'=>['.join (',',@$v).']';
			push @$code, "\t\t$s,";
		} sort keys %$w;
		push @$code,"\t);";
		push @$code,"$ctkC ConfigSpecs end";
	} else {
		push @$code,"## \t$self->ConfigSpecs();";
	}
	return $code
}

sub genDelegates {

	my $self = shift;
	my ($code,$now,$mw) = @_;
	&main::trace("genDelegates");
	my $file_opt = &main::getFile_opt();
	$ctkC = $main::ctkC unless defined($ctkC);
	if (exists $file_opt->{'Delegates'}) {
		push @$code,"$ctkC Delegates ";
		push @$code,"\t\$self->Delegates(";
		my $w = eval $file_opt->{'Delegates'};
		map {
			my $v = $w->{$_};
			my $s = $self->quoteValue($_) .' => ';
			if ($v->{'-subwidgetname'} =~ /\S/) {
				$s .= $self->quoteValue($v->{'-subwidgetname'});
			} elsif ($v->{'-subwidgetref'} =~/\S/) {
				$s .= $v->{'-subwidgetref'};
				$s =~s/\\\$/\$/;
			} else {}
			push @$code, "\t\t$s,";
		} sort keys %$w;
		push @$code,"\t);";
		push @$code,"$ctkC Delegates end";
	} else {
		push @$code,"## \t\$self->Delegates(); \t(optional)";
	}
	return $code
}

sub genAdvertisedWidgets  {
	my $self = shift;
	my ($code,$now,$mw) = @_;
	&main::trace("genAdvertisedWidgets");
	my $file_opt = &main::getFile_opt();
	$ctkC = $main::ctkC unless defined($ctkC);
	if (@{$file_opt->{'subWidgetList'}}) {
		push @$code,"$ctkC public subwidgets";
		map {
			push @$code, '$self->Advertise(\''.$_->{name}.'\'=>$'.$_->{ident}.');' if ($_->{public});
		} @{$file_opt->{'subWidgetList'}};
		push @$code,"$ctkC public subwidgets end";
	} else {}
	return $code
}

sub genMethods {
	my $self = shift;
	my ($code,$now) = @_;
	&main::trace("genMethods");
	my $file_opt = &main::getFile_opt();
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

sub genTestCode {
	my $self = shift;
	my ($code,$now,$mw) = @_;
	&main::trace("genTestCode");

	return $code unless ($main::opt_TestCode);

	my $file_opt = &main::getFile_opt();
	$ctkC = $main::ctkC unless defined($ctkC);

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
		push @$code ,"\$$mw->protocol('WM_DELETE_WINDOW',sub{Tk::exit(0)});"; ## just do terminate the test
	} elsif ($file_opt->{'Toplevel'}) {
		push @$code ,"my \$toplevel = \$$mw->Toplevel();";
		if ($self->isToplevel) {
			push @$code ,"my \$instance = \$toplevel->$pkg(\%args);"; ## do not pass to geom mgr!
		} else {
			push @$code ,"my \$instance = \$toplevel->$pkg(\%args)->pack();";
		}
		push @$code ,"\$toplevel->protocol('WM_DELETE_WINDOW',sub{\$toplevel->destroy});"; ## just do terminate the Toplevel
	} else {
		if ($self->isToplevel) {
			push @$code ,"my \$instance = \$$mw->$pkg(\%args);"; ## do not pass to geom mgr!
		} else {
			push @$code ,"my \$instance = \$$mw->$pkg(\%args)->pack();";
		}
	}
	if ($file_opt->{'modal'}) {
				push @$code ,"my \$answer = \$instance->Show();";
	}
	$code = $self->genCalls2Test($code,$now,'instance');
	push @$code ,"MainLoop;";
	push @$code ,"##";
	push @$code, "$ctkC testCode end";
	push @$code ,"";
	return $code
}

sub genCallbacks {
	my $self = shift;
	my ($code,$now) = @_;
	my $file_opt = &main::getFile_opt();
	$code = $self->SUPER::genCallbacks($code,$now) if ($main::opt_TestCode);
	return $code;
}

sub parseAndSaveConfigSpec {
	my $self = shift;
	my ($data) = @_;
	my $file_opt = &main::getFile_opt;
	if ($data) {
		$data =~s/\n//g;;
		$data =~ s/\s+/ /g;
		$data =~s /\$self\s*\-\>\s*ConfigSpecs//;
		$data =~ s/\(/\{/;
		$data =~ s/\)/\}/;
	} else {
		$data ='{}'
	}
	my $x = eval $data;
	$file_opt->{'ConfigSpecs'} = ctkBase->dump($x)
}

sub parseAndSaveDelegates {
	my $self = shift;
	my ($data) = @_;
	my $file_opt = &main::getFile_opt;
	if ($data) {
		$data =~ s/\n//g;
		$data =~ s/\s+/ /g;
		$data =~s /\$self\s*\-\>\s*Delegates//;
		$data =~ s/\(/\{/;
		$data =~ s/\)/\}/;
		$data =~ s/(\$\w+)/\'$1\'/g;
	} else {
		$data ='{}'
	}
	my $x = eval $data;
	my $y = {};
	map {
		if ($x->{$_} =~ /^\$/) {
			$y->{$_} = {-subwidgetref => $x->{$_}, -subwidgetname => ' '}
		} elsif ($x->{$_} =~ /^\w+$/){
			$y->{$_} = {-subwidgetname => $x->{$_}, -subwidgetref => ' '}
		} else {
			$y->{$_} = {-subwidgetname => ' ', -subwidgetref => ' '}
		}
	} keys %$x;

	$file_opt->{'Delegates'} = ctkBase->dump($y);
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
