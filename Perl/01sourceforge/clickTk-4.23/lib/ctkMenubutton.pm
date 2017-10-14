
package ctkMenubutton;

use vars qw($VERSION);
$VERSION = '1.01';

require Tk::Menubutton;
@ISA = qw(Tk::Menubutton );

Construct Tk::Widget 'ctkMenubutton';

my $debug = 0;

sub InitClass {			# called just once per Mainwindow!
	my $self = shift;
	my ($mw) = @_;
	Trace("ClassInit called (ctkMenubutton)");
	$self->SUPER::InitClass(@_); ## in order to activate the base class (resp widget)!

}

sub InitObject {			# called just once per Mainwindow!
	my $self = shift;
	$self->Trace("InitObject called (ctkMenubutton)");
	$self->SUPER::InitObject(@_); ## in order to activate the base class (resp widget)!
}

sub _debug { shift; @_ ? $debug = shift : $debug }

sub AddItems {
		my $self = shift;
		my (@items) = @_;	## an array of refs to hash
		my @nItems =();
		map {
			my @x = @$_;
			for (my $i = 2; $i < scalar(@x) - 1; $i += 2) {
				if ($x[$i] eq '-activeOnState') {
					splice @x,$i,2;
					last
				}
			}
			push @nItems,[@x];
		} @items ;
		$self->SUPER::AddItems(@nItems)
}

# -----------------------------------------------

sub Trace { &trace(@_);}
sub trace {
	&log(@_) if ($debug);
}

sub Log { &log(@_)}
sub log { 
	map {print STDERR "\n\t",__PACKAGE__, ' ',$_} @_;
}

1; ## make perl happy ...!

=head1 NAME

	ctkMenubutton - Enhanced version of Tk::Menubutton for project clickTk.

=head1 SYNOPSIS

	use ctkMenubutton;
	$widget = $parent->ctkMenubutton(<args for Menubutton>, -activeOnState => <programstate>);

=head1 DESCRIPTION

	This class expands Tk::Menubutton with the ability to define an arguments that
	controls its state. The value of this argument controls the state of the mennuitem itself.

	This arguments is saved in the Menu structure and is checked by ctkMenu::updateMenu, which
	usually get called when the mainloop is idle.

=cut

