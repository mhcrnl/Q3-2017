=pod

=head1 ctkPreview

	Set up the preview widget.

=head2 Programming notes

=over

=item None

=back

=head2 Maintenance

	Author:	MARCO
	date:	03.12.2007
	History
		03.12.2007 version 1.01
		22.10.2008 version 1.02
		27.10.2008 version 1.03
		02.12.2009 version 1.04 refactoring (eval)
		19.12.2011 version 1.05 P093

=head2 Data member

	Class data members


	VERSION                class maintenance version
	debug                  local debug mode
	wPreview               ref to preview widget
	opt_useToplevel
	initialGeometryPreview size of preview
	view_pointerxy         flag, view mouse position
	widgets                list of widgets in the preview
	xy                     mouse position
	suppressCallbacks      flag, if On then widget's callbacks are not activated
	                       in the preview.

=head2 Methods

	Summary

		clearWidgets
		unbind_xy_move
		bind_xy_move
		_init
		init
		switch2Frame
		clear
		_reorgArg
		repaint

=cut

package ctkPreview;

use strict;
use base (qw/ctkBase/);

our $VERSION = 1.05;

our $debug = 0;

our $wPreview;

our $opt_useToplevel;

our $initialGeometryPreview = '=500x500+420+10';

our $view_pointerxy = 0;

our %widgets =();

our $xy;

our $suppressCallbacks = 1;

sub opt_useToplevel {
	return $opt_useToplevel
}

=head3 clearWidgets

	Clear the list of widgets
	(class data member %widgets).

=cut

sub clearWidgets {
	my $self = shift;
	%widgets = ();
}
=head3 unbind_xy_move

	Unbind the <Motion> callback to show
	the mouse position.
	It is the opposite of ind_xy_move.

=cut

sub unbind_xy_move {
	my $self = shift;
	my ($widget) = @_;
	$widget->bind('<Motion>','') if(defined ($widget->bind('<Motion>')));
}

=head3 bind_xy_move

	Bind the <Motion> callback to show
	the mouse position.
	It is the opposite of unbind_xy_move.

=cut

sub bind_xy_move {
	my $self = shift;
	my ($widget) = @_;
	&main::trace("bind_xy_move");
	if ($view_pointerxy) {
		$widget->bind('<Motion>',
					sub{
						my($x,$y)=$wPreview->pointerxy;
						$x-=$wPreview->rootx;
						$y-=$wPreview->rooty;
						$xy="x=$x y=$y"
						}
				)
	} else {
		$self->unbind_xy_move($widget);
	}
}


=head3 _init

	This method sends  the destroy message to the preview
	widget, sets the data member wPreview to undef and then sends the message clear
	to itself.

=cut

sub _init {
	my $self =shift;
	&main::trace("_init");
	if(defined($wPreview)) {
		$wPreview->destroy ;
		undef $wPreview;
	}
	$self->clear();

}

=head3 init

	This methods sends two messages to itself :
		_init
		repaint

=cut

sub init {
	my $self =shift;
	my $rv;
	&main::trace("init");
	$self->_init();
	$rv = $self->repaint();
	return $rv;
}

=head3 switch2Frame

	This methods first resets the flag opt_useToplevel to false
	and then sends the message init to itsself.

=cut

sub switch2Frame {
	my $self =shift;
	&main::trace("switch2Frame");
	$opt_useToplevel = 0;
	return $self->init()
}

=head3 clear

	This method clean up the preview
		DO get the list of widgets
		For all widgets DO detach all balloons
		For all children of the preview widget DO destroy
		If preview is Modal
			then construct a new preview of type ctkPreviewDialogBox
			     and show it
			else send message clear to it
=cut

sub clear {
	my $self =shift;
	&main::trace("clear");
	my $w_attr = &main::getW_attr;
	my $widgets = &main::getWidgets;

	if (Tk::Exists($wPreview)) {
		# TODO: unbind here ???
		map {
			$main::b->detach($_) if(defined($_) && $_->can('class') && $w_attr->{$_->class}->{balloon})
		} values %$widgets;
		map {$_->destroy} $wPreview->children;
		$self->unbind_xy_move($wPreview);
	}
	map {delete $widgets->{$_}} keys %$widgets;
	$xy = '';
	if (&main::getFile_opt()->{'modal'}) {
		if ($opt_useToplevel) {
			$wPreview->destroy() if(defined($wPreview));
			$wPreview = &main::getmw()->ctkPreviewDialogBox();
			$wPreview->protocol ('WM_DELETE_WINDOW',sub{1});
			$wPreview->geometry($initialGeometryPreview);
			$wPreview->Show();
		} else {
			$opt_useToplevel = 1;
			$wPreview = undef;
			$self->clear();
			return 1
		}
	} else {
		unless(defined($wPreview)) {
			if ($opt_useToplevel) {
				$wPreview = &main::getmw()->Toplevel(-title => &std::_title('preview'));
				$wPreview->protocol ('WM_DELETE_WINDOW',sub{ctkPreview->switch2Frame});
				$wPreview->geometry($initialGeometryPreview);
			} else {
				$wPreview=$main::main_frame->Frame(-relief=>'flat',-borderwidth=>0)
								->pack(-side => 'top',-anchor => 'ne',-fill=>'both',-expand=>1);
			}
			## &main::bind_xy_move($wPreview);
		}
	}
	$self->bind_xy_move($wPreview);
	return 1
}

=head3 _reorgArg


	This method reorgs the given arglist.
	It moves the -scrollbars option in front of the list.

	Argument

		list of options to be reordered

	Return value

	reordered arglist or l'list depending on context

=cut

sub _reorgArg {
	my $self = shift;
	my @rv = @_;
	my $item = '-scrollbars';
	main::trace("_reorgArg");

	for (my $i = 0 ;$i < scalar(@rv) ; $i+= 2) {
		if($rv[$i] eq $item) {
			my $val = $rv[$i+1];
			splice @rv,$i,2;
			unshift @rv,($item,$val);
			$i = @rv
		} ## else {}
	}
	return wantarray ? @rv : scalar(@rv);
}

=head3 repaint

	Paint the preview
		DO call clear preview
		DO set up eval subroutine
		DO set my %tmp_vars = ($MW => $wPreview)
		DO scan @ctkProject::tree and adapt some arguments
		DO FOR all widgets on @ctkProject::tree
			DO get id
			DO skip widget if corresponding descriptor doesn't exist
			DO skip non-visual widget
			DO set up standard constructor
			DO set up widget (eval stdConstructor)
			DO set up geometry options
			DO set up balloon
			DO set up bindings (click, double-click, right click)
			DO execute geometry manager
			DO set $widgets{path} := tmp_vars{$id}
		END
		DO set  $widgets{$MW} := $wPreview

	Arguments

		None

	Return

		True if no errors has been detected,
		false otherwise.

	Notes

		None.

=cut

sub repaint {
	my $self =shift;
	my $rv;
	&main::trace("repaint");

	$self->clear();
	my @err = ();
	my $MW = &main::getMW;
	my $widgets = &main::getWidgets;
	my %tmp_vars=($MW => $wPreview); # those variables exist only for 'redraw' window
		if(ref($wPreview) =~ /ctkPreviewDialogBox/) {
			$tmp_vars{$MW} = $wPreview->Subwidget('ctkTop');
		} ## else {}
	my $id;
	my $targetWidget = '$tmp_vars{$id}';
	my $stdConstructor ;
	my $x;
	my $d;
	my @arg;
	my @narg;

	my $eval = sub {
		my $constructor = shift;
		$constructor = $stdConstructor unless defined $constructor;
		my $rv;
		eval "\$rv = $constructor";
		push @err, $@ if ($@);
		main::trace("eval $constructor : rv = $rv") unless ($@);
		return $rv
		};

	foreach my $path (@ctkProject::tree[1..$#ctkProject::tree]) {
		$id=&main::path_to_id($path);
		next unless defined $id;
		next unless exists ctkProject->descriptor->{$id};
		next if (&main::nonVisual(&main::getType($id)));
		&main::trace("path='$path'","id='$id'");
		$d=ctkProject->descriptor->{$id};
		$x=$tmp_vars{$d->parent};
		@arg=&main::split_opt($d->opt);
		@narg=();
		if (grep /^-image/,@arg) {				## temp 24.07.2005 MO01001
			if (grep /^-text/,@arg) {
				for (my $i = 0;$i < scalar(@arg) ; $i+= 2) {
					if ($arg[$i] =~ /-text/) {
						splice @arg,$i,2;
						last
					}
				}
			} ## else {}
			for (my $i = 0;$i < scalar(@arg) ; $i+= 2) {	## i MO1001 temp 24.07.2005
				if ($arg[$i] =~ /-image/) {
					for (my $i = 0;$i < scalar(@arg) ; $i+= 2) {
						if ($arg[$i] =~ /-text/) {
							splice @arg,$i,2;
							last
						}
					}
					my $w = $arg[$i+1];
					$w =~ s/^\$//;
					if (exists $tmp_vars{$w}) {
						$arg[$i+1] = $tmp_vars{$w};
					} else {
						$arg[$i] = '-text';
						$arg[$i+1] ="<image $arg[$i+1]>";
					}
					last;
				} ## else{}
			}

		} ## else{}
		for (my $i = 0;$i < scalar(@arg) ; $i++) {
				if ($arg[$i] =~/^-font$/) {
					my $w = &main::string2Array($arg[$i+1]);
					$arg[$i+1] = $w if (@$w);
					last
				}
		}

		## overwrite callback options if any has been given

		if(grep(/(-command|-\w+cmd)/,@arg)) {
			my (%arg)=@arg;
			foreach my $par(qw/command createcmd raisecmd validatecommand/){ 	## overwrite callbacks option to edit the callbacks itself (mam)
				if ($suppressCallbacks) {
					$arg{"-$par"}=sub{1} if(exists $arg{"-$par"});
				} else {
					$arg{"-$par"}=[\&main::callback,$arg{"-$par"}] if(exists $arg{"-$par"});
				}
			}
			(@arg)=(%arg);
		}

##		set up standard constructor (for scrolled or non-scrolled widgets)

		$stdConstructor = "$targetWidget = ";
		if ($d->type =~ /^Scrolled$/) {
			my $scrolledclass = $d->scrolledclass();
			$stdConstructor .= "\$x->Scrolled('$scrolledclass',\@narg)"; ## temp 19.12.2011/P093
		} elsif ($d->type =~ /^Scrolled([a-zA-Z]+)/) {
			$stdConstructor .= "\$x->Scrolled('$1',\@narg)";
		} else {
			$stdConstructor .= "\$x->$d->{type}(\@arg)";
		}
		&main::trace("stdConstructor = '$stdConstructor'");

##
##		check class for special handling :
##		some widget class need pre- or post-processing
##

		if ($d->type eq 'ScrolledText') {
			@narg = $self->_reorgArg(@arg); ## may be this preprocess is now obsolete perl 5.8 + Tk 804.027
			if (&$eval()) {
				$tmp_vars{$id}->menu(undef);
			} else {}
		} elsif($d->type eq 'ScrolledROText')  {
			@narg = $self->_reorgArg(@arg);
			if (&$eval()) {
				$tmp_vars{$id}->menu(undef);
			} else {}
		} elsif($d->type eq 'ScrolledTextUndo') {
			@narg = $self->_reorgArg(@arg);
			if (&$eval()) {
				$tmp_vars{$id}->menu(undef);
			} else {}
		} elsif($d->type eq 'ScrolledTextEdit') {
			@narg = $self->_reorgArg(@arg);
			if (&$eval()) {
				$tmp_vars{$id}->menu(undef);
				$tmp_vars{$id}->SetGUICallbacks([sub{1}]);
			} else {}
		} elsif($d->type eq 'ScrolledTree') {
			@narg = $self->_reorgArg(@arg);
			if (&$eval()) {
				$tmp_vars{$id}->menu(undef);
			} else {}
		} elsif($d->type eq 'TextEdit')  {
			if (&$eval()) {
				$tmp_vars{$id}->menu(undef);
				$tmp_vars{$id}->SetGUICallbacks([sub{1}]);
			} else {}
		} elsif($d->type eq 'ScrolledListbox') {
			@narg = $self->_reorgArg(@arg);
			&$eval();
		} elsif($d->type eq 'ScrolledTiler') {
			@narg = $self->_reorgArg(@arg);
			&$eval();
		} elsif ($d->type eq 'ProgressBar') {
			my $w;
			my (%arg)=@arg;
			if (exists $arg{-colors}) {
				$w = &main::convertToList(delete $arg{'-colors'},\@err);
			} else {}
			if (exists $arg{-variable}) {				 ## temp fix P078  02.12.2009/mam
				my $v = delete $arg{-variable} ;
				main::Log("ProgressBar option '-variable' ($v) discarded on preview.")
			} else {}
			if (main::getFile_opt()->{'strict'}) {
					use strict ;
					$tmp_vars{$id} = $x->ProgressBar(%arg, -colors=>$w);
			} else {
					no strict ;
					$tmp_vars{$id} = $x->ProgressBar(%arg, -colors=>$w);
			}
		} elsif($d->type eq 'BrowseEntry') {
			my $w;
			my (%arg)=@arg;
			if (exists $arg{-choices}) {
				$w = $arg{-choices};
				$arg{-choices} = eval $w ;
			} else {
				$arg{-choices} = [qw/dummy_1 dummy_2 dummy_3/]		## dummy
			}
			$w = &main::convertToList(delete $arg{'-labelPack'},\@err);
			if (exists $arg{-variable}) {				 ## temp fix P078  02.12.2009/mam
				my $v = delete $arg{-variable} ;
				main::Log("BrowseEntry option '-variable' ($v) discarded on preview.")
			} else {}
			if (main::getFile_opt()->{'strict'}) {
					use strict ;
					$tmp_vars{$id} = $x->BrowseEntry(%arg, -labelPack=>$w);
			} else {
					no strict ;
					$tmp_vars{$id} = $x->BrowseEntry(%arg, -labelPack=>$w);
			}
		} elsif($d->type eq 'LabEntry'){
			my (%arg)=@arg;
			my $w = &main::convertToList(delete $arg{'-labelPack'},\@err);
			$w = [] unless defined($w);
			$tmp_vars{$id} = $x->LabEntry(%arg,-labelPack=>$w);
		} elsif($d->type eq 'Listbox') {
			if (&$eval()) {
				$tmp_vars{$id}->insert('end', qw/item_1 item_2 item_3/);
			} else {}
		} elsif($d->type eq 'Optionmenu') {
			$tmp_vars{$id} = $x->Optionmenu(-options=>[qw/item_1 item_2 item_3/]);
		} elsif($d->type eq 'NoteBookFrame')  {
			$tmp_vars{$id} = $x->add($id,@arg);
		} elsif($d->type eq 'Menu')  {
			# For cascade-based Menu use root menu widget in place of $x:
			my $root_menu=$x;
			if (ctkProject->descriptor->{$d->parent}->type eq 'cascade') {
				$root_menu=$tmp_vars{ctkProject->descriptor->{$d->parent}->parent} ;
				$tmp_vars{$id} = $root_menu->Menu(@arg);
				$x->configure(-menu=>$tmp_vars{$id});
			} else {
				$tmp_vars{$id} = $root_menu->Menu(@arg);
				$root_menu->configure(-menu=>$tmp_vars{$id});
			}
			##    $x->configure(-menu=>$tmp_vars{$id});
		} elsif ($d->type eq 'cascade'){
			&$eval();
		} else {
			&$eval();
			## &std::ShowDialog(-title=>"Error:",-text=>"ERROR: widget of type ".$d->type." can't be displayed!");
			## &main::Log("ERROR: widget of type ".$d->type." can't be displayed!");
		}

		unless (defined($tmp_vars{$id})) {
			&main::log("Could not repaint '$id', skipped");
			next
		}

		if (&main::haveGeometry($d->type)) {

			next if (&main::isHidden($id));

			my ($geom,$geom_opt)=(split '[)(]',$d->geom);
			map {s/^\s+//;s/\s+$//}($geom,$geom_opt);
			my $balloonmsg;

			$balloonmsg=ctkTargetCode->genWidgetCode($path);
			$balloonmsg =~ s/ -> / ->\n/g;
			&main::trace("id='$id'",ref($tmp_vars{$id}),"balloonmsg='$balloonmsg'"," ");


			$main::b->attach($tmp_vars{$id},-balloonmsg=>$balloonmsg) if ($main::view_balloons &&
									&main::getW_attr ->{$d->type}->{balloon});
			$tmp_vars{$id}->Tk::bind('<Button-3>', sub{&main::set_selected(ctkWidgetTreeView->info('data',$path));$main::popup->Post(&main::getmw->pointerxy)});
			$tmp_vars{$id}->Tk::bind('<Button-1>', sub{&main::set_selected(ctkWidgetTreeView->info('data',$path))});
			$tmp_vars{$id}->Tk::bind('<Double-1>', sub{&main::set_selected(ctkWidgetTreeView->info('data',$path));&main::edit_widgetOptions});

			$self->bind_xy_move($tmp_vars{$id});

			if($geom eq 'pack') {
				$tmp_vars{$id}->pack(&main::split_opt($geom_opt));
			} elsif($geom eq 'grid') {
				$tmp_vars{$id}->grid(&main::split_opt($geom_opt));
			} elsif($geom eq 'place') {
				$tmp_vars{$id}->place(&main::split_opt($geom_opt));
			} elsif($geom eq 'form') {
				my @w = &main::split_opt($geom_opt);
				my $wx = &main::quotatZ(\@w,\%tmp_vars);
				if (defined $wx) {
					$tmp_vars{$id}->form(@$wx);
				} else {
					push @err, $@ if ($@);
				}

			} else {
				die "Unexpected geometry manager '$geom'"
			}
		}
		$widgets->{$path}=$tmp_vars{$id};
	}
	$widgets->{$MW}=$wPreview;
	if (@err) {
		&std::ShowWarningDialog("Syntax error occurred while repainting preview:\n\n".join ("\n",@err));
		@err =();
		$rv = 0
	} else {
		$rv = 1
	}
	return $rv;
}

1; ## -----------------------------------

