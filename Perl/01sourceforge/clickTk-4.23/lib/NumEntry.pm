##
package NumEntry;

require Tk::Derived;
require Tk::Frame;                    # or Tk::Toplevel

use ctkBitmap;

@ISA = (qw/Tk::Derived Tk::Frame ctkBitmap/);    # or Tk::Toplevel
use vars qw/$VERSION/;

use ctkBitmap 1.01;

$VERSION = 1.04;

my $debug = 0;

Construct Tk::Widget 'NumEntry';

sub ClassInit {
	my ($class,$mw) = @_;
	my $rv;
	#... e.g., class bindings here ...
	$rv = $class->SUPER::ClassInit($mw);
	return $rv;
}

sub Populate {
	my ($cw,$args) = @_;

	my $rVar     = delete $args->{-textvariable};
	my $width    = delete $args->{'-width'} if(exists $args->{-width});
	my $minvalue =(exists $args->{'-minvalue'}) ? abs(delete $args->{'-minvalue'}) : 0;
	my $maxvalue =(exists $args->{'-maxvalue'}) ? abs(delete $args->{'-maxvalue'}) : 1;
	my $incvalue =(exists $args->{'-incvalue'}) ? abs(delete $args->{'-incvalue'}) : 1;
	my $decvalue = - abs($incvalue);
	my $callback = delete $args->{'-callback'} if exists $args->{'-callback'};

	$width = int(log($maxvalue)/log(10) + 2) unless(defined($width));

	$cw->SUPER::Populate($args);

	my $numEntry;

#	unless($def_bitmaps) {
#		  my $bits = pack("b8"x5,
#		    "........",
#		    "...11...",
#		    "..1111..",
#		    ".111111.",
#		    "........"
#		  );
#
#		$cw->DefineBitmap('INCBITMAP' => 8,5, $bits);
#
#		# And of course, decrement is the reverse of increment
#
#		$cw->DefineBitmap('DECBITMAP' => 8,5, scalar reverse $bits);
#		$def_bitmaps=1;
#		}

	$cw->ctkBitmap(qw/INCBITMAP DECBITMAP/);

	my $f=$cw->Frame()->pack();
	$numEntry=$f->Entry(-textvariable => $rVar, -width => $width, -background => '#FFFFFF')->pack(-anchor=>'w', -side=>'left');
	$numEntry->bind('<Up>',
					[\&NumEntry::inc_num_controlled,$rVar,$incvalue,$minvalue,$maxvalue]);
	$numEntry->bind('<Down>',
					[\&NumEntry::inc_num_controlled,$rVar,-$incvalue,$minvalue,$maxvalue]);
	$f->Button(-bitmap=>'INCBITMAP',-cursor=>'left_ptr',-command=>
					[\&NumEntry::inc_num_controlled,$rVar,$incvalue,$minvalue,$maxvalue,$numEntry,$callback])
					->pack(-anchor=>'nw', -side=>'top');
	$f->Button(-bitmap=>'DECBITMAP',-cursor=>'left_ptr',-command=>
					[\&NumEntry::inc_num_controlled,$rVar,-$incvalue,$minvalue,$maxvalue,$numEntry,$callback])
					->pack(-anchor=>'nw', -side=>'top');

	$cw->Advertise ('NumEntry' => $numEntry);

	$cw->ConfigSpecs(				## see help for Tk::ConfigSpecs
			'DEFAULT' => [$numEntry],   	## apply to the Frame widget
			'-result' => [METHOD,dbName,dbClass,'default'] 	## pass value to the method having this name
			);
	return $cw;
}

=head2 result

	This method handles the option '-result'. It returns the current value
	of the variable specified by -textvariable.

=cut

sub result {
	my ($cw) = @_;
	my $rv;
	$rv = $cw->Subwidget('NumEntry')->get(); # current value
	return $rv
}

sub inc_num_controlled
{
	shift if ref($_[0]) ne 'SCALAR';
	my ($ptr,$inc,$minvalue,$maxvalue,$entry,$callback)=@_;

	my $value=$$ptr+$inc;

	$value=$minvalue if (defined ($minvalue) && $value < $minvalue);
	$value=$maxvalue if (defined($maxvalue) && $value > $maxvalue);

	## $$ptr=$value;				## didn't work for value real  0 .. 1 increment 0.1 (04.03.2006/mm)

	if(defined($entry)) {
		## $entry->configure(-textvariable => $ptr);
		$entry->delete('0','end');
		$entry->insert('end',$value);
	}
	&$callback() if (defined($callback));
}

1;
__END__

=head1 NAME

    NumEntry

=head1 SYNOPSIS

    use NumEntry;
    $widget = $parent->NumEntry(-textvariable => <ref to scalar>);
	$result = $widget->cget(-result); ## when result variable is aout of scope

=head1 DESCRIPTION

	NumEntry provides a composite widget which allows the user to enter
	integer value by

		- typing a value on the keyboard
		- pressing the increase or decrease buttons
		- pressing the <up> or <down> keys

	The programmer supplies the options

		-textvariable	ref to scalar (mandatory)
		-minvalue	minimum value, optional, default 0, scalar containing decimal value
		-maxvalue	maximum value, optional, default 1, scalar containing decimal value
		-incvalue	increment, optional default 1, scalar containing the decimal value

		all widget options which are applicable to the Entry widget.

	The referenced value should contain the initial value.

	Options may be changed and/or inspected the usual way using configure and/or cget .
	The resulting value may be got by means of

		$widget->Subwidget('NumEntry')->get();

		or

		$widget->cget(-result);		## i.e. when variable is out of current scope!

=cut


