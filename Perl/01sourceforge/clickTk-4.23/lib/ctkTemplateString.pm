=head1 ctkTemplateString

	This class models template strings.
	Template strings may contain any ASCII text and any number of placeholders.

	Placeholders are identified by %%ident%% where ident is [\w_]+, i.e. %%t_001%% .
	Placeholders are defined in an array of HASH whereby an individual placeholder
	is identified with an HASH {ident => <value>}.
	<Value> may be a scalar or a CODE ref to a callback which is called 
	&<value>($self,<template string processed so far>). 
	The callback must return a scalar which is used to replace the placeholder itself.
	The return value UNDEF is automatically turned to an empty string.

=head2 Syntax

	my $t = ctkTemplateString->new(<options>);

		whereby <options> is

			[fileName => <filepath of the file containing the template>]
			[,template => <templates def string]
			[,debug => debug mode 0|1]
			[,placeHolderList => <array of placeholder definitions>]

	$t->fileName(<file name of the template file>);

	$t->getTemplateStringfromFile([<file name of the template file>]);

	$t->placeHolderList(<array of the placeholder definition>);

	$t->template(<template string>);

	$t->placeHolderValues(<array of the placeholder definition>);

	$t->replacePlaceholder([template string]);

	$t->destroy

=head2 Example

		my $t = ctkTemplateString->new(
		            fileName => 'test_templateString.txt',
		            placeHolderList => [
		               {t000 => 'Marco'},
		               {t001 => 'Marazzi'},
		               {t003 => ' --- %%t004%% ---'},
		               {t004 => 'Zürich'},
		               {t005 => sub {return shift->getDateAndTime()}},
		               {t006 => \&subString}
		               ],
		            debug => $debug);
		my $s = $t->getTemplateStringfromFile();
		$s = $t->replacePlaceHolder($s);

=over

=item Properties

	template
	placeHolderList

=item Methods

	new {
	_init
	getTemplateStringfromFile
	placeHolderValues
	replacePlaceHolder
	verifyTemplate

=items Globals

	debug		(debug mode on/off)

=back

=head2 Programming notes

	- specialized classes : create a package for objects
	  which work with a specific template, whereby the template 
	  is encapsulated in the class (or just its file name), and
	  a specific placeHolder list.

	- specify the placeHolder list at construct time and update
	  it just before the message 'replacePlaceHolder'.

	- callbacks: use callbacks to 
			- force the use of actual values,
			- construct compound replacements,
			- iteration and recursion.

=head2 Maintenance

	Author:	MARCO
	date:	10.01.2007
	History
			11.01.2008 refactoring

=cut

package ctkTemplateString;

use base (qw/ctkFile ctkBase/);

my $debug = 0;

our $VERSION = 1.02;

sub new {
	my $class = shift;
	my (%args) = @_;
	$debug = $args{debug} if exists $args{debug};
	my $self = bless {},__PACKAGE__;

	$self = $self->SUPER::new();
	$self->_init(%args);
	return $self;
}

sub _init {
	my $self = shift;
	my (%args) = @_;
	my $fName = delete $args{fileName} if(exists $args{fileName});
	my $template = delete $args{template} if(exists $args{template});
	my $placeHolderList = delete $args{placeHolderList} if(exists $args{placeHolderList});
	$self->fileName($fName) if(defined($fName));
	$self->template($template) if(defined($template));
	$self->placeHolderList($placeHolderList) if(defined($placeHolderList));
	return 1
}

sub destroy {
	my $self = shift;
	$self->SUPER::destroy();
	$self = {};
	return 1
}

sub placeHolderList {
	my $self = shift;
	$self->{placeHolderList} = shift if (@_);
	return $self->{placeHolderList}
}

sub template {
	my $self = shift;
	$self->{template} = join('',@_) if (@_);
	return $self->{template}
}

sub getTemplateStringfromFile {
	my $self = shift;
	my ($fName) = @_;
	my @rv;
	
	$self->fileName($fName) if(defined($fName));
	if (-f $self->fileName()) {
		$self->open();
		@rv =  $self->get();
		$self->close();
	} else {
		@rv =();
	}
	return wantarray  ? @rv : join '', @rv;
	}

sub verifyTemplate {
	my $self = shift;
	my ($d) = @_;
	$d = $self->template() unless defined($d);
	my $placeHolders = $self->placeHolderList();
	return undef unless @$placeHolders;
	my @plh = map {keys %$_} @$placeHolders;
	while ($d =~ /%%([^%]+)%%/g) {
		return undef unless (grep ($1 eq $_, @plh))
	}
	return 1
}

sub placeHolderValues {
	my $self =shift;
	my (%args) = @_;
	my $list = $self->placeHolderList();

	foreach my $a (keys %args) {
		foreach (@$list) { 
			$_->{$a} = $args{$a} if exists $_->{$a}
		}
	}
	return 1
}

sub replacePlaceHolder {
	my $self = shift;
	my ($d) = @_;
	my $rv = defined($d) ? $d : $self->template();
	my $plh;
	my ($i,$r);
	my @k;

	my $placeHolders = $self->placeHolderList();

	while ($rv =~ /%%([\w\d_]+)%%/g) {
		$plh = $1;
		$self->trace("plh = $plh");
		
		OUTERLOOP: foreach my $p (@{$placeHolders}) {
			INNERLOOP: foreach (keys %$p) {
				if ($_ eq $plh) {
					my $ref = ref($p->{$_});
					if ( $ref eq 'CODE') {
						$r = &{$p->{$_}}($self,$rv);
					} elsif ($ref =~/^\s*$/) {
						$r = $p->{$_};
						$r = '' unless defined($r);
					} else {
						$r = $self->_dump($p->{$_})
					}
					$rv =~ s/%%$plh%%/$r/ ;
					last OUTERLOOP;
					}
				else {}
				}
			}
		}
	return ($rv);
	}
1; 
