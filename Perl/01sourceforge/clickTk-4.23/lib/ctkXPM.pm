
=pod

=head1 ctkXPM

	This class provides methods to process XPM pictures.

=over

=item Methods

	 new
	 skeleton
	 defaultColor
	 pixels
	 image
	 data

=item class data

	xpmLib	library of standard icons used by clickTk

=item Notes

	See scripts test/ctkXPM_test.pl and test/genXPM.pl for examples.

=back

=cut

package ctkXPM ;

my $xpmLib = {
	'ok' =>[
			'wwwwwwwwwwwwwwwww',
			'w               .',
			'w              b.',
			'w            bb .',
			'w          bbb  .',
			'w        bbb    .',
			'w bb   bbb      .',
			'w bb  bbb       .',
			'w bb bbb        .',
			'w bbbbb         .',
			'w bbbb          .',
			'w bbb           .',
			'w bb            .',
			'w bb            .',
			'w b             .',
			'w................'
			],
	'cancel' =>[
			'wwwwwwwwwwwwwwwww',
			'w               .',
			'w             r .',
			'w             r .',
			'w r         rr  .',
			'w  rr      rr   .',
			'w    rr  rrr    .',
			'w      rrr      .',
			'w    rrrrr      .',
			'w  rrrr   rr    .',
			'w rrrr     rrr  .',
			'wrrrr       rrrr.',
			'wrrrr         rr.',
			'wrrr            .',
			'w               .',
			'w................'
			],
	'arrowUp' => [
			'wwwwwwwwwwwwwwwww',
			'w               .',
			'w       r       .',
			'w      rrr      .',
			'w     rrrrr     .',
			'w    rrrrrrr    .',
			'w   rrrrrrrrr   .',
			'w  rrrrrrrrrrr  .',
			'w rrrrrrrrrrrrr .',
			'w     rrrrr     .',
			'w     rrrrr     .',
			'w     rrrrr     .',
			'w     rrrrr     .',
			'w     rrrrr     .',
			'w     rrrrr     .',
			'w................'
			],
	'arrowDown' => [
			'wwwwwwwwwwwwwwwww',
			'w               .',
			'w     ggggg     .',
			'w     ggggg     .',
			'w     ggggg     .',
			'w     ggggg     .',
			'w     ggggg     .',
			'w     ggggg     .',
			'w ggggggggggggg .',
			'w  ggggggggggg  .',
			'w   ggggggggg   .',
			'w    ggggggg    .',
			'w     ggggg     .',
			'w      ggg      .',
			'w       g       .',
			'w................'
			],
	'plus' => [
			'wwwwwwwwwwwwwwww',
			'w              .',
			'w bbbbbbbbbbbb .',
			'w b          b .',
			'w b    bb    b .',
			'w b    bb    b .',
			'w b    bb    b .',
			'w b bbbbbbbb b .',
			'w b bbbbbbbb b .',
			'w b    bb    b .',
			'w b    bb    b .',
			'w b    bb    b .',
			'w b          b .',
			'w bbbbbbbbbbbb .',
			'w              .',
			'w...............'
			],
	'minus' => [
			'wwwwwwwwwwwwwwww',
			'w              .',
			'w bbbbbbbbbbbb .',
			'w b          b .',
			'w b          b .',
			'w b          b .',
			'w b          b .',
			'w b bbbbbbbb b .',
			'w b bbbbbbbb b .',
			'w b          b .',
			'w b          b .',
			'w b          b .',
			'w b          b .',
			'w bbbbbbbbbbbb .',
			'w              .',
			'w...............'
			],
	'zero' => [
			'wwwwwwwwwwwwwwwwww',
			'w                .',
			'w      bbbb      .',
			'w   bb     bbb   .',
			'w  b        bbb  .',
			'w b          bbb .',
			'w b          bbb .',
			'wb            bbb.',
			'wb            bbb.',
			'wb            bbb.',
			'w b           bbb.',
			'w b          bbb .',
			'w  b        bbb  .',
			'w   bb     bbb   .',
			'w     bbbbb      .',
			'w.................'
			],
	'arrowRight' => [
			'wwwwwwwwwwwwwwwwwwwwwwwww',
			'w        r              .',
			'w        rrr            .',
			'w        rrrrr          .',
			'w        rrrrrrr        .',
			'w        rrrrrrrrr      .',
			'w rrrrrrrrrrrrrrrrrr    .',
			'w rrrrrrrrrrrrrrrrrrrr  .',
			'w rrrrrrrrrrrrrrrrrrrrrr.',
			'w rrrrrrrrrrrrrrrrrrrr  .',
			'w rrrrrrrrrrrrrrrrrr    .',
			'w        rrrrrrrrr      .',
			'w        rrrrrrr        .',
			'w        rrrrr          .',
			'w        rrr            .',
			'w        r              .',
			'w........................'
			],
	'arrowLeft' => [
			'wwwwwwwwwwwwwwwwwwwwwwwww',
			'w              g        .',
			'w            ggg        .',
			'w          ggggg        .',
			'w        ggggggg        .',
			'w      ggggggggg        .',
			'w    gggggggggggggggggg .',
			'w  gggggggggggggggggggg .',
			'wgggggggggggggggggggggg .',
			'w  gggggggggggggggggggg .',
			'w    gggggggggggggggggg .',
			'w      ggggggggg        .',
			'w        ggggggg        .',
			'w          ggggg        .',
			'w            ggg        .',
			'w              g        .',
			'w........................'
			],
	'save' => [
			'wwwwwwwwwwwwwwwwwwwwwww',
			'w                     .',
			'w                     .',
			'w  .................. .',
			'w  .ggg.wwwwwwww.www. .',
			'w  .ggg.wwwwwwww..... .',
			'w  .ggg.wwwwwwww.ggg. .',
			'w  .ggg..........ggg. .',
			'w  .gggggggggggggggg. .',
			'w  .gggggggggggggggg. .',
			'w  .ggg..........ggg. .',
			'w  .ggg........w.ggg. .',
			'w  .ggg........w.ggg. .',
			'w  .................. .',
			'w                     .',
			'w                     .',
			'w......................'
			],
	'default' => [
			'wwwwwwwwwwwwwwwwwwwwwww',
			'w                     .',
			'w                     .',
			'w                     .',
			'w                     .',
			'w                     .',
			'w                     .',
			'w                     .',
			'w                     .',
			'w                     .',
			'w                     .',
			'w                     .',
			'w                     .',
			'w                     .',
			'w                     .',
			'w                     .',
			'w......................'
			],
	'hlist' => [
			'wwwwwwwwwwwwwwwwwwwwwww',
			'w .                   .',
			'w . rrrrrrrrrrr       .',
			'w .                   .',
			'w .... bbbbbbbbbbbbb  .',
			'w .       .           .',
			'w .       .           .',
			'w .       .... bbbbb  .',
			'w .       .           .',
			'w .       .... bbbbb  .',
			'w .                   .',
			'w .... bbbbbbbbbbbbb  .',
			'w .       .           .',
			'w .       .           .',
			'w .       .... bbbbb  .',
			'w .                   .',
			'w......................'
			],

	'tree'=> [
			'wwwwwwwwwwwwwwwwwwwwwwwww',
			'w                       .',
			'w         gggggg        .',
			'w       gggwgggwgg      .',
			'w   ggggwggggwggggwggg  .',
			'w  gggggggggggggggggwgg .',
			'w ggwgggwgggwgggggwggggg.',
			'wggwggggggwgggggwgggggwg.',
			'wggggwgggggggwgggggwgggg.',
			'w gwgggggwgggggggggggwg .',
			'w       .. ... ..       .',
			'w        .......        .',
			'w          ...          .',
			'w          ...          .',
			'w         .....         .',
			'wggggggggggggggggggggggg.',
			'w........................'
			]
	};

sub new {
	my $class = shift;
	my (%args) = @_ ;
	$class = $class || ref $class ;
	my $self = {};
	$self = bless $self , $class;
	$debug = delete $args{-debug} if (exists $args{-debug});
	return $self;
}

sub skeleton {
	my $self = shift;
	return [
		"/* XPM */\n",
		"static char * duplicate_xpm[] = {\n",
		"/* width height ncolors chars_per_pixel */\n",
		"\"%%width%% %%height%% %%ncolors%% %%chars_per_pixel%%\\n",
		"/* colors */\n",
		"%%colors%%\n",
		"/* pixels */\n",
		"%%pixels%%};\n"
		]
}

sub defaultColor {
	my $self = shift;
	return	[
				"  s None c None",
				". c #000000",
				"r c #FF0000",
				"g c #00FF00",
				"b c #0000FF",
				"w c #FFFFFF"
			];
}

sub pixels {
	my $self = shift;
	my ($name) = @_;
	return $xpmLib->{$name} if exists $xpmLib->{$name};
	return $xpmLib->{'default'};
}

sub image {
	my $self = shift;
	my (%args) = @_;
	my $hwnd = delete $args{-hwnd};
	my $data = $self->pixels(delete $args{-pixels}) if exists $args{-pixels};
	if (defined($data)) {
		$args{-data} = $data;
	}
	return $hwnd->Photo(%args);
}

sub data {
	my $self = shift;
	my ($colors, $pixels,$chars_per_pixel) = @_;
	my $rv ;
	my $width = 1;
	my $height = 1;
	my $nColor = 0;

	$chars_per_pixel = 1 unless(defined($chars_per_pixel));

	$colors = $self->defaultColor unless (defined($colors));
	$pixels = $self->pixels('default') unless (@$pixels);

	$nColor = scalar(@$colors);
	$height = scalar(@$pixels);
	$width = length($pixels->[0]) / $chars_per_pixel;
	map {
		return undef if (length($_) != $width)
	} @$pixels;

	my $skeleton = '';
	map {
			s/\n/%%nl%%/;
			$skeleton .= $_;
	} @{$self->skeleton};

	$rv = $skeleton;

	$rv =~ s/%%width%%/$width/;
	$rv =~ s/%%height%%/$height/;
	$rv =~ s/%%ncolors%%/$nColor/;
	$rv =~ s/%%chars_per_pixel%%/$chars_per_pixel/;

	$v = '';
	map { $v .= "\"$_\",%%nl%%"} @$colors;

	$rv =~ s/%%colors%%/$v/;
	$v =~ s/%%nl%%$//;

	$v = '';
	map { $v .= "\"$_\",%%nl%%" } @$pixels;
	$v =~ s/,%%nl%%$//;

	$rv =~ s/%%pixels%%/$v/;

	$rv =~ s/%%nl%%/\n/g;

	return $rv;
}

1; ## end of package ctkXPM
