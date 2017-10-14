#!/usr/lib/perl
##              -w -d:ptkdb

=pod

=head1 ctkWidgetTreeView

	Set up and maintain the View which shows the widget's tree.

=head2 Programming notes

=over

=item This class is not a mega widget.

	This is due to the fact that im not sure whether
	a Scrolled widget works fine in a composite.
	Somewhere I have read that it does not!
	TODO: do some test in this respect.

	This class simply encapsulates the activities
	based on the widgets tree.

=item Options

	main::HListDefaultWidth,
	main::HListDefaultHeight
	main::HListSelectMode

=back

=head2 Maintenance

	Author:	MARCO
	date:	01.01.2007
	History
			06.12.2007 refactoring
			28.02.2008 MO03605
			17.04.2008 version 1.03 (tearoff, updatePopup)
			06.01.2012 version 1.04 (P095)

=cut

package ctkWidgetTreeView;

use strict;

use ctkBase;
use base (qw/ctkBase/);

our $VERSION = 1.04;

=head2 Class variables

	$tf			ref to the widget tree
	$tearoff
	$separator

=cut

our $tf;

my $tearoff = 0;

my $separator ='.';


=head2 Properties

=cut

sub Separator {
	return $separator
}


=head2 Methods

=head3 setup

	- Instantiate the Widget tree as Scrolled Tree
	- Save its ref into the class variable $tf

=cut

sub setup {
	my $self = shift;
	my ($parent,$MW,$pic) = @_ ;
	$self->trace("setupTree");

	my $rv= $parent->Scrolled('Tree',-scrollbars => "osoe",
			-drawbranch => 1,
			-header => 1,
			-indicator => 1,
			-itemtype   => 'imagetext',
			-separator  => $separator,
			-selectmode => $main::HListSelectMode,
			-browsecmd  => [sub {},undef],
			-selectbackground => 'blue',
			-selectforeground => 'white',
			-command => [sub {},undef],
			## -opencmd => sub{1},
			## -closecmd => sub{1},
			-ignoreinvoke => 0,
			-bg => '#E5E5E5',
			-width =>  $main::HListDefaultWidth,
			-height => $main::HListDefaultHeight,
			-font => $parent->toplevel->Font(-family => 'Courier', -size => 10, -weight => 'normal')
			);

	$rv->pack(-side=>'left',-anchor => 'nw', -expand => 1, -fill=>'both');

	# $rv->add($separator,-text=>'widget tree') ; # ,-data=>$MW);

	$rv->configure(
				-command  => sub{
						#main::trace("command",@_,"----");
						my @path = $tf->infoSelection();
						#main::trace("command  path",@path);
						&main::set_selected($tf->info('data',shift @path)) if(@path);
						&main::edit_widgetOptions
						},
				-browsecmd=> sub{
						#main::trace("browsecommand",@_,"-----");
						my @path = $tf->infoSelection();
						#main::trace("browsecommand  path",@path);
						&main::set_selected($tf->info('data', shift @path)) if(@path);
						ctkMenu->updateMenu();
						my $editTreeState= &main::computeEditTreeState();
						ctkMenu->updatePopup($main::popup,$editTreeState);
						} );


	$parent->packAdjust(-side=>'left',-anchor => 'nw', -expand => 1, -fill => 'y');

	$rv->bind('<Button-3>',
		sub{
		&main::set_selected($tf->nearest($tf->pointery-$tf->rooty));
		my $editTreeState= &main::computeEditTreeState();
		ctkMenu->updatePopup($main::popup,$editTreeState);
		$main::popup->Post(&main::getmw->pointerxy);
		if ($main::popupmenuTearoff) {
			$main::popup->configure(-tearoffcommand => [sub {shift->trace("tearoffcommand")},$self]);
		}
		return undef
		});
	$tf = $rv;
	return $rv;
}

=head3 setSelected

	Set the tree selection at the current selected widget.

=cut

sub setSelected {
	my $self = shift;
	$tf->anchorClear(); $tf->selectionClear();
	my $s = &main::getSelected;
	if ($s) {
		my $sep = $tf->cget(-separator);
		$s = "$sep$s" ;
		eval {
			$tf->anchorSet($s);
			$tf->selectionSet($s);
			};
		main::log("setSelected : $@") if($@);
	}
	return undef
}

=head3 repaint

	Repaint the widget tree

=cut

sub repaint {
	my $self = shift;
	my ($deleteAll,$pic) = @_;
	&main::trace("tree_repaint");

	$pic = &main::get_picW unless defined($pic);
	$deleteAll = 1 unless defined($deleteAll);

	my $t = $tf->cget(-itemtype);
	my $sep = $tf->cget(-separator);
	my $hidden = $tf->ItemStyle($t , -foreground=>'#FF0000');

	$tf->delete('all') if ($deleteAll);
	my $type;
	my $picN;
	my $MW = &main::getMW();

	$picN = &main::getWidgetIconName(&main::path_to_id($MW));

	$tf->add($sep,
			-text => 'Widget tree',
			-data => '',
			-image => $pic->{$picN}
	)unless $tf->info('exists',$sep);

	map {
		my $path = "$sep$_";
		$picN = &main::getWidgetIconName(&main::path_to_id($_));
		if (&main::isHidden(&main::path_to_id($_))) {
			$tf->add($path,
				-style => $hidden,
				-text => &main::path_to_id($_),
				-data => $_,
				-image => $pic->{$picN}
			) unless $tf->info('exists',$path);
		} else {
			$tf->add($path,
				-text => &main::path_to_id($_),
				-data => $_,
				-image => $pic->{$picN}
			) unless $tf->info('exists',$path);
		}
	} @ctkProject::tree;
	$tf->autosetmode();
	## delete ctkProject->descriptor->{$MW};
	return 1;
}

=head3 Wrappers

	info
	add
	delete
	selectionSet

=cut

sub _addroot {
	my $self = shift;
	my $rv;
	$rv = $self->Separator . $_[0];
	return $rv
}

sub info {
	my $self = shift;
	my $path = $self->_addroot($_[1]);
	$tf->info($_[0],$path);
}

sub add {
	my $self = shift;
	my $path = shift;
	$path = $self->_addroot($path);
	$tf->add($path,@_);
}

sub delete {
	my $self = shift;
	my $entry = shift;
	my $path = $self->_addroot($_[0]);
	$tf->delete($entry,$path);
}

sub selectionSet {
	my $self = shift;
	my $path = $self->_addroot($_[0]);
	$tf->selectionSet($path)
}
1; ## -----------------------------------

