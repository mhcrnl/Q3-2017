=pod

=head1 ctkFontDialog

	This class provides a non modal dialog to generate font statements.

=head2 Methods

	ClassInit
	Populate
	apply_font

=head2 Syntax

	$parent->ctkFontDialod(<options>);

=over

=item Options

		- title		title of the toplevel

		- gen	kind of the emitted code:

				'options'     emitted code is option's string
				'configure'   emitted code is configuration message '$widget->configure(-font => <font defiition>)'  
				none          same as 'configure'

		- target receiving widget (must be of type Entry or Text).

=item Example

		$mw->ctkFontDialog(-title, 'Gen font ',-gen, 'option', -target ,$target);

=back

=cut

package ctkFontDialog;

	require Tk::Derived;
	require Tk::Frame;
	require ctkNumEntry;

	@ISA = (qw/Tk::Derived Tk::Frame/);

my $debug = 0;

our $VERSION = '1.02';

my ($family,$size,$weight,$slant,$underline,$overstrike);

	Construct Tk::Widget 'ctkFontDialog';

my $old_grab ;

sub ClassInit {
	my ($class,$mw) = @_;
	my $rv;
	$rv = $class->SUPER::ClassInit($mw);
	return $rv;
}

sub Populate {
	my ($cw,$args) = @_;

	my $title = delete $args->{-title} if exists $args->{-title};
	my $gen = delete $args->{-gen} if exists $args->{-gen};
	my $target = delete $args->{-target} if exists $args->{-target};

	$title = 'Create Tk::Font constructor code' unless(defined($title));
	$title = &std::_title($title);
	my ($tl,
		$fOptions,$fEmitCode,$fSample,
		$fe,$ze,$we,$se,$ue,$oe,$emit,$code, $sample);

	$cw->SUPER::Populate($args);

	$tl = $cw->Toplevel(-title => $title);


	$fOptions = $tl->LabFrame(-label => '1. Options' , -relief => 'ridge' , -labelside => 'acrosstop');
	$fEmitCode = $tl->LabFrame(-label => '2. Code' , -relief => 'ridge' , -labelside => 'acrosstop');
	$fSample = $tl->LabFrame(-label => '3. Example' , -relief => 'ridge' , -labelside => 'acrosstop');

	$family = 'Courier';

	my $stext ="abcdefghijklmnoqrstuvwxyz\n0123456789\nNABCDEFGHIJKLMNOQRSTUVWXYZ\nהצü+\"*ח*%&/\n()=?טיא£;:_-.,!\n[]{}@#¦|¬<>\n";


	$sample = $fSample->Label (-textvariable => \$stext, -background => '#CCFFCC');

	$fe = $fOptions->BrowseEntry(
		-label     => 'Family: ',
		-variable  => \$family,
		-browsecmd => sub{$cw->apply_font($sample);$code->delete('1.0','end')}
		);
	$fe->configure(-labelWidth => 10);
	$fe->insert('end', sort $cw->MainWindow->fontFamilies);

	$size = 12;

	$ze = &ctkNumEntry::numEntry($fOptions,
		-textvariable => \$size ,
		-minvalue => 8,
		-maxvalue => 32,
		-label => 'Size',
		-labelWidth => 10,
		-width => 9,
		-callback => 	sub {
				$cw->apply_font($sample);$code->delete('1.0','end')}
		);

	$weight = "normal";

	$we = $fOptions->BrowseEntry(
		-label    => 'Weight:  ',
		-variable => \$weight,
		-width => 9,
		-browsecmd  => sub{$cw->apply_font($sample);$code->delete('1.0','end')}
		);
	$we->configure(-labelWidth => 10);
	$we ->insert ('end', qw/ normal bold medium book light demi demibold /);

	$slant = "roman";

	$se = $fOptions->Checkbutton(
		-onvalue => "italic",
		-offvalue => "roman",
		-text => "Slant",
		-variable => \$slant,
		-width => 12,
		-justify => 'left',-anchor => 'nw',
		-command => sub{$cw->apply_font($sample);$code->delete('1.0','end')}
		);

	$underline = 0;

	$ue = $fOptions->Checkbutton(
		-text => "Underline",
		-variable => \$underline,
		-width => 12,
		-justify => 'left',-anchor => 'nw',
		-command => sub{$cw->apply_font($sample);$code->delete('1.0','end')}
		);

	$overstrike = 0;

	$oe = $fOptions->Checkbutton(
		-text => "Overstrike",
		-variable => \$overstrike,
		-width => 12,
		-justify => 'left',-anchor => 'nw',
		-command => sub{$cw->apply_font($sample);$code->delete('1.0','end')}
		);

	$emit = $fEmitCode->Button(
		-text => (defined($target) && Tk::Exists($target)) ? 'Emit code and take over' : 'Emit code',
		-background => '#80FF80',
		-foreground => 'black',
		-width => 12,
		-command => sub{
			my $fOpt = "[-family,'$family',-size,$size,-weight,'$weight',-slant,'$slant',-underline,$underline ,-overstrike,$overstrike]";
			my $fCode;
			if ($gen eq 'options') {
					$fCode ="$fOpt";
			} elsif ($gen eq 'configure') {
					$fCode = "\$widget->configure(-font => $fOpt);";
			} else {
					$fCode = "\$widget->configure(-font => $fOpt);";
			}
			print "\n$fCode";
			$code->delete('1.0','end');
			$code->insert('end',$fCode);
			if (defined($target) && Tk::Exists($target)) {
				$target->delete('0','end');
				$target->insert('end',$fCode);
			} ## else {}
			}
		);

	$code = $fEmitCode->ROText(
		-wrap => 'word',
		-background => 'white',
		-foreground => 'black',
		-width => 32,-height => 4
		);

	foreach ($fOptions,$fEmitCode,$fSample) {
			$_->pack(-side => 'top', -anchor => 'nw', -expand => 1,-fill => 'x', -pady => 5, -padx => 5)
	}

	foreach my $w ($fe,$ze,$we,$se,$ue,$oe,$emit,$code) {
		$w->pack(-side => 'top', -anchor => 'nw', -expand => 1,-fill => 'x', -pady => 5)
		}

	$cw->apply_font($sample);

	$sample->pack(-side => 'bottom', -expand => 1,-fill => 'x',-ipadx => 10);
	$cw->Advertise ('Code' => $code);
	$old_grab = $cw->grabSave;
	$cw->grab;
	$tl->protocol(WM_DELETE_WINDOW => [\&abandon,$cw]);
	return $cw;
}

sub abandon {
	my $cw = shift;
	$cw->grabRelease();
	&$old_grab() if (defined ($old_grab));
	$cw->destroy();
}
sub apply_font {
	my $self = shift;
	map {
	$_->configure(-font =>
		[-family => $family,
		-size => $size,
		-weight => $weight,
		-slant => $slant,
		-underline => $underline,
		-overstrike => $overstrike
		]
		);
	} @_;
}

1;



