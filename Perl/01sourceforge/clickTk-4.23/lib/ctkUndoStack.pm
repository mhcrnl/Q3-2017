#!/usr/lib/perl
##              -w -d:ptkdb

=pod

=head1 ctkUndoStack

	UndoStack saves the state of the project and it allows
	undo and redo functions.

=head2 Programming notes

=over

=item Class variables

	- @undo
	- @redo

=back

=head2 Maintenance

	Author:	MARCO
	date:	01.01.2007
	History
			24.11.2007 refactoring
			30.11.2007 version 1.02
			09.01.2013 version 1.03  (P'slice' argument)

=cut

package ctkUndoStack;
use strict;
use base (qw/ctkBase/);
our $VERSION = 1.03;

my @undo = ();          # Undo buffer
my @redo = ();          # Redo buffer

=head2 Public methods

	clearUndoStack
	redo
	undo
	undo_save

=cut

sub clearUndoStack {
	@undo = ();
	@redo = ();
}


sub undoStackSize {
	return scalar(@undo)
}

sub redoStackSize {
	return scalar(@redo)
}

sub undoAvail {
	return (shift->undoStackSize) ? 1 : 0
}

sub redoAvail {
	return (shift->redoStackSize) ? 1 : 0
}

sub undo_save {
	my $self = shift;
	&main::trace("undo_save");
	my $code = &main::gen_TkCode();		## TODO: save work areas using Dumperx
	@redo=();
	push(@undo,join("\n",@$code));
	return 1
}

sub redo {
	my $self = shift;
	&main::trace("redo");
	return 0 unless @redo;
	my $widgets = &main::getWidgets;
	my $code = &main::gen_TkCode();
	my $sel_save=&main::getSelected;
	push(@undo,join("\n",@$code)); # undo <= current
	&main::struct_new();
	my @w = split("\n",pop(@redo));
	&main::parseTargetCode(\@w,'splice'); ## 09.01.2013/mm
	&main::work_save_temp() if ($main::work_save_temp);  ## 09.01.2013/mm
	&main::preview_repaint();
	&main::tree_repaint();
	$sel_save=&main::getMW unless exists $widgets->{$sel_save};
	&main::set_selected($sel_save);
	&main::changeFlag(1) unless &main::isChanged();
	return 1
}

sub undo {
	my $self = shift;
	&main::trace("undo");
	return 0 unless @undo;
	my $widgets = &main::getWidgets;
	my $sel_save=&main::getSelected;
	# clear current design and restore from backup:
	my $code = &main::gen_TkCode();
	push(@redo,join("\n",@$code)); # redo <= current
	&main::struct_new();
	my @w = split("\n",pop(@undo));
	&main::parseTargetCode(\@w,'splice'); ## 09.01.2013/mm
	&main::work_save_temp() if ($main::work_save_temp);  ## 09.01.2013/mm
	&main::preview_repaint;
	$sel_save=&main::getMW unless exists $widgets->{$sel_save};
	&main::tree_repaint();
	&main::set_selected($sel_save);
	&main::changeFlag(1) unless &main::isChanged();

	return 1
}

1; ## -----------------------------------

