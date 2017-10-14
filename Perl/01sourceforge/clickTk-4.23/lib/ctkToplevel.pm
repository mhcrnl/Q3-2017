=pod

=head1 ctkToplevel

	Same as Toplevel

	Toplevel can be positioned at 5 standard locations
	ul,ur,dl,dr, center.

=cut

package ctkToplevel;

use vars qw($VERSION);
$VERSION = '1.01';

require Tk::Toplevel;
@ISA = qw(Tk::Toplevel);

Construct Tk::Widget 'ctkToplevel';

my $debug = 0;

my ($X0,$Y0) =(0,0);

my $hightTitle = 20;

sub InitClass {			# called just once per Mainwindow!
	my $self = shift;
	## $self->Trace("InitClass called");
	##
	$self->SUPER::InitClass(@_); ## in order to activate the base class (resp widget)!

}

sub InitObject {
	my $self = shift;
	##  $self->Trace("ObjectInit called");
	$self->SUPER::InitObject(@_); ## in order to activate the base class (resp widget)!
}

sub Populate {
	my $self = shift;
	my($args) = @_;		## <==== $args is of ref to HASH
	$self->Trace("Populate");
	
	## take out specific args

	$debug = delete $args->{-debug} if exists $args->{-debug};
	my $popover = delete $args->{-popover} if exists $args->{-popover};
	die "invalid -popover value" unless (grep(lc($popover) eq $_, (qw/center ul ur dl dr/)));
	$self->SUPER::Populate($args);

	$self->moveTo(lc($popover)) if(defined ($popover));
	return $self;
}

sub _debug { shift; @_ ? $debug = shift : $debug }

sub X0 {
	return $X0;
}

sub Y0 {
	return $Y0;
}

sub moveToCENTER {
	shift->moveTo('center');
}
sub moveToUL {
	shift->moveTo('ul');
}
sub moveToUR {
	shift->moveTo('ur');
}
sub moveToDL {
	shift->moveTo('dl');
}
sub moveToDR {
	shift->moveTo('dr');
}
sub moveAround {
	my $self = shift;
	for (1..5) {
		return unless (Tk::Exists($self));
		sleep 1;
		$self->moveToUL;
		sleep 1;
		$self->moveToUR;
		sleep 1;
		$self->moveToDR;
		sleep 1;
		$self->moveToDL;
		sleep 1;
	}
		$self->moveToCENTER;
}

=head2 moveTo

	Move the given window to the given position

B<Arguments>

	position : 'ul',ur','dl','dr','center'

B<Notes>

	None

=cut

sub _moveTo {
	my $self = shift;
	my $rv;
	my ($x,$y) = $self->pointerxy();
	my $geom = "+$x+$y";
	if (Tk::Exists($self)) {
		$self->geometry($geom);
		$self->raise();
		$self->update();
		$rv = 1;
	} else {}
	return $rv;
}

sub moveTo {
	my $self = shift;
	my ($pos) = @_;
	my $rv;
	my $geom = $self->getXYForMove($pos);
	if (Tk::Exists($self)) {
		$self->withdraw();
		$self->update();
		$self->geometry($geom);
		$self->deiconify();
		$self->raise();
		$self->update();
		$rv = 1;
	} else {}
	return $rv;
}

=head2 getXY

	Compute the left upper corner coordinates of the
	given windows (widget of type Topelevel) and build the corresponding
	geometry string.

B<Arguments>

	width       desired width (optional)
	height      desired height (optional)
	position    'center','ul','ur','dl','dr' (mandatory)

B<Returns>

	geometry string (ready to be used for method widget->geometry)

=cut

sub getXY {
	my $self = shift;
	my ($width,$height,$opt) = @_;
	$width = $self->reqwidth unless ($width);
	$height = $self->reqheight unless ($height);
	my $rv = $width.'x'.$height.'-%x-%y';
	my $sh = $self->screenheight;
	my $sw = $self->screenwidth;
	my ($x0,$y0) = (0,0);

	if ($opt eq 'center') {
		$x0 = int(($sw - $width ) / 2);
		$y0 = int(($sh - $height) / 2);
	} elsif ($opt eq 'ul') {
		$x0 = $sw- $width - 5; $y0 = $sh - $height - $hightTitle ;
	} elsif ($opt eq 'ur') {
		$x0 = 0; $y0 = $sh - $height - $hightTitle  ;
	} elsif ($opt eq 'dl') {
		$x0 = $sw - $width -5;$y0 = 0;
	} elsif ($opt eq 'dr') {
		$x0 = 0; $y0 = 0;
	} else {
		$rv = ($width.'x'.$height);
	}
	$rv =~ s/%x/$x0/;
	$rv =~ s/%y/$y0/;
	return $rv
}

=head2 getXYForMove

	Compute the down right corner coordinates of the
	given windows (widget of type Toplevel) and build the corresponding
	geometry string.
	Thereby the nullpoint (0,0) is at the corner down right.

B<Arguments>

	hwnd    	widget of type Toplevel of Mainwindow  (mandatory)
	width    	desired width (optional)

B<Returns>

	geometry string (ready to be used for method widget->geometry)

B<Notes>

	Do not consider the size of the window

=cut

sub getXYForMove {
	my $self = shift;
	my ($opt) = @_;
	my $X0 = $self->X0();
	my $Y0 = $self->Y0();
	my $width = $self->width();
	my $height = $self->height();
	my $rv = '-%x-%y';
	my $sh = $self->screenheight;
	my $sw = $self->screenwidth;
	my ($x0,$y0) = (0,0);
	if ($opt eq 'center') {
		$x0 = int(($sw - $width ) / 2);
		$y0 = int(($sh - $height) / 2);
	} elsif ($opt eq 'ul') {
		$x0 = $sw - $width - $X0; $y0 = $sh - $height - ($Y0+$hightTitle) ;
	} elsif ($opt eq 'ur') {
		$x0 = $X0; $y0 = $sh - $height - ($Y0+$hightTitle)  ;
	} elsif ($opt eq 'dl') {
		$x0 = $sw - $width - $X0; $y0 = $Y0+$hightTitle;
	} elsif ($opt eq 'dr') {
		$x0 = $X0; $y0 = $Y0+$hightTitle;
	} else {
		$rv = ($width.'x'.$height);
	}
	$rv =~ s/%x/$x0/;
	$rv =~ s/%y/$y0/;
	$self->trace("getXYForMove, opt=$opt");
	$self->trace("getXYForMove, sh=$sh,sw=$sw");
	$self->trace("getXYForMove, height=$height,width=$width");
	$self->trace("getXYForMove, rv = $rv");
	return $rv;
}

=head2 _getXY

	Same as getXYforMove but the nullpoint (0,0) is
	the upper left corner.

B<Notes>

	None.

=cut

sub _getXY {
	my $self = shift;
	my ($width,$height,$opt) = @_;
	my $X0 = $self->X0();
	my $Y0 = $self->Y0();
	$width = $self->width unless ($width);
	$height = $self->height unless ($height);
	my $rv = $width.'x'.$height.'+%x+%y';
	my $sh = $self->screenheight;
	my $sw = $self->screenwidth;
	my ($x0,$y0) = (0,0);

	if ($opt eq 'center') {
		$x0 = int(($sw - $width ) / 2);
		$y0 = int(($sh - $height) / 2);
	} elsif ($opt eq 'ul') {
		$x0 = $X0; $y0 = $Y0 ;
	} elsif ($opt eq 'ur') {
		$x0 = $sw-$width; $y0 = $Y0;
	} elsif ($opt eq 'dl') {
		$x0 = $X0; $y0 = $sh - $height - ($Y0+$hightTitle);
	} elsif ($opt eq 'dr') {
		$x0 = $sw - $width - $X0; $y0 = $sh - $height - ($Y0+$hightTitle);
	} else {
		$rv = ($width.'x'.$height);
	}
	$rv =~ s/%x/$x0/;
	$rv =~ s/%y/$y0/;
	return $rv
}

# -----------------------------------------------

sub Trace { trace(@_);}
sub trace {
	my $self = shift;
	log(@_) if ($self->_debug);
}

sub Log { log(@_)}
sub log { 
	my $self = shift;
	map {print STDERR "\n\t",__PACKAGE__, ' ',$_} @_;
}

1; ## make perl happy ...!
