package WidgetDrag;
use Tk;

# some day, we'll get this to work
# we need an object method "require_version" for this package to be able to do this.
# $VERSION = '0.5';

my ($grabx, $graby);

sub enable_drag {
	my($widget,$object) = @_;

	#Place the callback and name params in the widget's data space
	# this prevents having to use object oriented methods to keep
	# track of everything
#	$widget->{wd_callback} = $callback;
	$widget->{wd_object} = $object;

	$widget->bind("<ButtonPress-1>"		=> [\&button_down, Ev('x'), Ev('y')]);
	$widget->bind("<ButtonRelease-1>"	=> [\&button_up]);
	$widget->bind("<Leave>"					=> [\&motion, Ev('x'), Ev('y')]);
	$widget->bind("<Motion>"				=> [\&motion, Ev('x'), Ev('y')]);
}


sub motion {
	my($widget, $x, $y) = @_;
	#print $widget->{wd_tag} . "\n";
	return unless $grabx;
	my %place_info = $widget->placeInfo();
	my $newx = $place_info{-x} + $x - $grabx;
	my $newy = $place_info{-y} + $y - $graby;

	$widget->place(-x=>$newx, -y=>$newy);
	if ($widget->{wd_object}) {
		$widget->{wd_object}->update_position($newx,$newy);
	}
}

sub button_down {
	my($widget, $x, $y) = @_;
	$widget->focus;
	$grabx = $x;
	$graby = $y;
}

sub button_up {
	return unless $grabx;
	$grabx = 0;
	$graby = 0;
}

1;
