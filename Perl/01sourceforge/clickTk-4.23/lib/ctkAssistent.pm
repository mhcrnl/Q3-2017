#!/usr/bin/perl

=head1 ctkAssistent

	This class models the clickTk code assistent.

=head2 Public interface

	$assistent = ctkAssistent->new(-parent => $mw);

	$code = $assistent->Show();

	if (defined $code) {
		## insert into editor
	}

=head2 Programmin notes

	None

=head2 Maintenance

	Author:	marco
	date:	17.08.2006
	History
			17.08.2006 first draft.
			18.08.2006 version 1.02
			09.02.2007 version 1.03
			06.03.2008 version 1.05
			15.10.2008 version 1.07

=head2 Methods

=over

=item new

=item Show

=item tkFunctions

=back

=head2 Properties

=over

=item parent

=item target

=item assistedValues

=item funcList

=back

=head2 private methods

=over

=item _copyCode

=item _synchHelp

=item _ok

=item _cancel

=item _selectWidget

=item _insertOrReplace

=item loadFuncList

=item compileFuncList

=back

=cut

package ctkAssistent ;

use base (qw/ctkBase/);

use vars qw/$VERSION/;

$VERSION = 1.07;

my $funcListFileName = 'ctkAssistentFuncList.txt';

my $funcList;

my $debug = 0;

=head2 new

		Create a new instance .

=over

=item Argument

		parent widget

=item Return

		ref to instance.

=back

=cut

sub new {
	my $class = shift;
	my (%args) = @_;
	my $self = {};
	$self = bless $self, $class;
	$debug = delete $args{-debug} if (exists $args{-debug});
	$self->{parent} = delete $args{-parent} if (exists $args{-parent});
	$self->{target} = delete $args{-target} if (exists $args{-target});
	$self->{selection} = delete $args{-selection} if (exists $args{-selection});
	$self->{insertion} = delete $args{-insert} if (exists $args{-insert});
	$self->{_toplevel} = undef;

	$funcList = $self->loadFuncList();
	return $self;
}

sub _toplevel{
	my $self = shift;
	$self->{_toplevel} = shift if (@_);
	return $self->{_toplevel};
}
sub funcList {
	my $self = shift;
	$funcList = shift if (@_);
	return $funcList;
}

sub parent {
	my $self = shift;
	my $rv = $self->{parent} if (exists $self->{parent});
	$self->{parent} = shift if (@_);
	return $rv;
}

sub target {
	my $self = shift;
	my $rv = $self->{target} if (exists $self->{target});
	$self->{target} = shift if (@_);
	return $rv;
}

sub selection {
	my $self = shift;
	my $rv = $self->{selection} if (exists $self->{selection});
	$self->{selection} = shift if (@_);
	return wantarray ? @$rv : $rv;
}

sub insertion {
	my $self = shift;
	my $rv = $self->{insertion} if (exists $self->{insertion});
	$self->{insertion} = shift if (@_);
	return $rv;
}

sub assistedValues {
	my $self = shift;

	return {
		'Global variables' => \&_selectGlobalVariables,
		'Local variables' => \&_selectLocalVariables,
		'Widget' => \&_selectWidget,
		'Cursor' => \&_selectCursorfont,
		'Text index' => \&_selectTextIndex,
		'Listbox index' => \&_selectListboxIndex,
		'Font' => \&_genFontCode
		};
}


=head2 Show

	Activate the assistent dialog window.

=over

=item Arguments

	None.

=item Return

	Always undef

=back

=cut

sub Show {
	my $self = shift;
	my $rv;

	return undef if (Tk::Exists($self->_toplevel()));

	## &std::ShowWarningDialog("clickTk code assistent has not yet been released.\n\nMany thanks for your understanding!");

	$self->parent(&main::getmw()) unless ($self->parent);
	$rv = $self->{_toplevel} = $self->tkFunctions($self->parent());
	return $rv;
}

=head2 _popupMenu4Values

	Set up the popup to select values

=over

=item Arguments

	- self,
	- ref to main window,
	- ref to text widget receiving the selected value.

	These args must be passed to the individual selection methods.

=item Return

	Ref to the popup menu

=item Notes

	- Values may be

		global variables
		Widget refs
		Cursor shapes
		Text index
		Listbox index
		Font definitions

	- Set up Menu: $text->toplevel may also be used instead of $mw


=back

=cut

sub _popupMenu4Values_old {		## didn't work for dlg_getOrder
	my $self = shift;
	my ($mw,$text) = @_;
	my $rv=$mw->Menu(-tearoff=>1);
	my $callbacks = $self->assistedValues();

	foreach my $r (sort keys %$callbacks) {
		$rv->add('command',-label=>$r,-command=>[$callbacks->{$r},$self,$mw,$text]);
	}
	return $rv;
}

sub _popupMenu4Values {
	my $self = shift;
	my ($mw,$text) = @_;
	my $rv=$mw->Toplevel(-popover => 'cursor', -title => &std::_title('Assisted values'));

	my $callbacks = $self->assistedValues();

	foreach my $r (sort keys %$callbacks) {
		$rv->Button(-text=>$r,-command=>[$callbacks->{$r},$self,$mw,$text], -bg => 'white')->pack(-fill, 'x', -expand , 1);
	}
	$rv->overrideredirect(0);
	return $rv;
}

=head2 _execPopupmenu4Values

	Execute the popup menu to select values.

=over

=item Arguments

	- self
	- ref to main window
	- ref to text widget receiving the selected value.

=item Return

	Always undef.

=item Notes

	- Popup has replaced Menubutton which didn't work properly.

=back

=cut

sub _execPopupmenu4Values_old {
	my $self = shift;
	my ($mw,$text) = @_;
	my $rv;
	my $popup = $self->_popupMenu4Values($mw,$text);
	my $x = $popup->Post($mw->pointerxy);
	&main::trace("x = '$x'");
	return $rv
}

sub _execPopupmenu4Values {
	my $self = shift;
	my ($mw,$text) = @_;
	my $rv;
	my $popup = $self->_popupMenu4Values($mw,$text);
	return $rv
}

=head2 tkFunctions

	Set up the non-modal dialog to assist entering of TK code.

=over

=item Arguments

	parent widget

=item Return

	None

=back

=cut

sub tkFunctions {
my $self = shift;
my $hwnd = shift;
my (%args) = @_;
my $class = ref($self);
my $rv;
##
## ctk: Localvars
## ctk: Localvars end
##
my $mw = $hwnd->Toplevel();
$rv = $mw;
$mw->configure(-title=> &std::_title((exists $args{title})? $args{title}:'List of Tk-functions'));
$mw->protocol('WM_DELETE_WINDOW',sub{1});

## ctk: code generated by ctk_w version '3.091'
## ctk: lexically scoped variables for widgets

my $wr_001 ;
my $wr_002 ;
my $wr_011 ;
my $wr_007 ;
my $wr_003 ;
my $wr_004 ;
my $wr_013 ;
my $wr_017 ;
my $wr_005 ;
my $wr_006 ;
my $wr_008 ;
my $wr_009 ;
my $wr_010 ;
my $wr_012 ;

## ctk: instantiate and display widgets

$wr_001 = $mw -> Frame ( -borderwidth , 1 , -relief , 'solid'  ) -> pack(-side=>'top', -anchor=>'nw', -fill=>'x', -expand=>1);
$wr_002 = $mw -> Frame ( -borderwidth , 0 , -relief , 'solid'  ) -> pack(-side=>'bottom', -anchor=>'sw', -fill=>'x', -expand=>1);
$wr_011 = $wr_002->Button(-relief=>'raised',-text => 'Values', -bg , 'white')->pack( -side, 'left', -expand, 1, -fill, 'x', -padx , 2);
$wr_007 = $wr_001 -> Label ( -background , '#837dec' , -justify , 'left' , -relief , 'flat' , -text , 'clickTk Asssitent - Functions'  ) -> pack(-side=>'top', -anchor=>'nw', -fill=>'x', -expand=>1);
$wr_003 = $mw -> Frame ( -borderwidth , 1 , -relief , 'sunken'  ) -> pack(-side=>'top', -anchor=>'nw', -fill=>'both', -expand=>1);
$wr_013 = $wr_003 -> Frame ( -borderwidth , 1 , -relief , 'solid'  ) -> pack(-side=>'top', -anchor=>'nw', -fill=>'both', -expand=>1);
$wr_017 = $wr_003 -> Frame ( -borderwidth , 1 , -relief , 'solid'  ) -> pack(-side=>'top', -anchor=>'nw', -fill=>'both', -expand=>1);
$wr_004 = $wr_002 -> Button ( -background , '#ffffff' , -state , 'normal' , -text , 'Take over'  ) -> pack(-side=>'left', -anchor=>'nw', -fill=>'x', -expand=>1, -padx=>2);
$wr_005 = $wr_002 -> Button ( -background , '#ffffff' , -state , 'normal' , -text , 'OK'  ) -> pack(-side=>'left', -anchor=>'nw', -fill=>'x', -expand=>1, -padx=>2);
$wr_006 = $wr_002 -> Button ( -background , '#ffffff' , -state , 'normal' , -text , 'Cancel'  ) -> pack(-side=>'left', -anchor=>'nw', -fill=>'x', -expand=>1, -padx=>2);
$wr_008 = $wr_013 -> Scrolled ( 'Listbox' , -background , '#e8e8e8' , -selectmode , 'single' , -relief , 'flat' , -scrollbars , 'se'  ) -> pack(-anchor=>'nw', -side=>'left', -fill=>'y', -expand=>1);
$wr_009 = $wr_008 -> packAdjust ( -side , 'left' , -anchor , 'nw' , -fill , 'y' , -expand , 1  );
$wr_010 = $wr_013 -> Scrolled('TextUndo', -state , 'normal' , -wrap , 'none' , -height , 6 , -width, 60) -> pack(-anchor=>'nw', -side=>'left', -pady=>2, -fill=>'both', -expand=>1, -padx=>2);
$wr_012 = $wr_017 -> Scrolled('ROText', -background , '#e6e6e6' , -state , 'normal' , -wrap , 'none', -height, 4  ) -> pack(-anchor=>'nw', -side=>'left', -fill=>'x', -expand=>1);

$wr_004->configure(-command , [\&_takeOver,$self,$mw,$wr_010] );
$wr_005->configure(-command , [\&_ok,$self,$mw,$wr_010] );
$wr_006->configure(-command , [\&_cancel,$self,$mw] );
$wr_011->configure(-command => ["${class}::_execPopupmenu4Values",$self,$mw,$wr_010]);


$wr_008->bind('<1>',[\&_synchHelp,$self,$wr_012]);
$wr_008->bind('<Double-1>',[\&_copyCode,$self,$wr_010]);
## ctk: end of gened Tk-code
$mw->protocol('WM_DELETE_WINDOW',[\&_abandon,$self,$mw,$wr_010]);

my $w;
	map {
		$wr_009->insert('end',$_);
		$w = $_ unless ($w)
	} sort keys %$funcList;

	$wr_009->selectionSet(0);
	&_synchHelp($wr_009,$self,$wr_012);
 return $rv;

} ## end of tkFunctions

## ctk: end of dialog code
## ctk: callbacks

=head2 Private methods

	The following methods do the detail processing:

=over

=item _copyCode

=item _synchHelp

=item _ok

=item _cancel

=item _insertOrReplace

=item _insertOrReplaceValue

=back

=cut

sub _copyCode {
	my ($lb,$self,$uT)  = @_ ;
	my $x = $lb->get($lb->curselection);
	my $code = '->'.$x.$funcList->{$x}->{args}.';';
	$self->_insertOrReplaceValue($uT,$code);
}

sub _synchHelp {
	my ($lb,$self,$roT)  = @_ ;
	my $x = $lb->get($lb->curselection);
	$roT->delete('0.1','end');
	$roT->insert('end',$funcList->{$x}->{help}."\n\n");
	$roT->insert('end',"\$rv = <widget> -> $x ".$funcList->{$x}->{args}."\n");
}

sub _takeOver {
	my $self = shift;
	my ($mw,$text) = @_;
	my $code = $text->get('0.1','end');
	unless ($code =~ /^\s*$/) {
		$self->_insertOrReplace($self->target,$code) if (defined $self->target);
	}
	return 1;
}

sub _ok {
	my $self = shift;
	my ($mw,$text) = @_;
	my $code = $text->get('0.1','end');
	unless ($code =~ /^\s*$/) {
		$self->_insertOrReplace($self->target,$code) if (defined $self->target);
	}
	$mw->destroy;
	return 1;
}

sub _cancel {
	my $self = shift;
	shift->destroy;
}

sub _abandon {
	my $self = shift;
	my ($mw,$text) = @_;
	my $code = $text->get('0.1','end');
	if ($code =~ /^\s*$/) {
		$self->_cancel($mw);
	} else {
		(&std::askYN("Insert the generated code into target?")) ? $self->_ok($mw,$text) : $self->_cancel($mw);
	}
}
sub _insertOrReplace {
	my $self = shift;
	my ($uT,$code) = @_;

	return undef unless Tk::Exists($uT);

	my @sel = $self->selection();
	@sel = $uT->tagRanges('sel') unless (@sel == 2);
	my $insert = $self->insertion();
	$insert = $uT->index('insert') unless defined $insert;

	&main::trace("_insertOrReplace - $uT , sel = '@sel' , ins = '$insert'");

	$uT->delete(@sel) if (@sel == 2);
	$uT->insert($insert,$code);

	$self->selection([]);
	$self->insertion(undef);
	return 1;
}

sub _insertOrReplaceValue {
	my $self = shift;
	my ($uT,$code) = @_;

	return undef unless Tk::Exists($uT);

	my @sel;
	@sel = $uT->tagRanges('sel');


	&main::trace("_insertOrReplaceValue - $uT , sel = '@sel'");

	if (@sel == 2) {
		$uT->delete(@sel);
		$uT->insert($uT->index('insert'),$code);
	} else {
		$uT->insert($uT->index('insert'),$code);
	}
	return 1;
}

=head2 Generate specialized strings

	The following methods generate specialized strings, like
	widget's variables, option's values or even option's lists.

=over

=item _selectGlobalVariables

=item _selectLocalVariables

=item _selectWidget

=item _selectCursorfont

=item _selectTextIndex

=item _genFontCode

=back

	Arguments

		- self,
		- parent widget,
		- target text widget, which will receive the generated value.

	Return

		None.

	Exception

		None.

	Note

		- mandatory: the dialog must be modal and it must return
		  the generated value as a string or undef.

		- mandatory: call _insertOrReplace to place the selected
		  value into the given target text-widget.

		- install a new method:
			- code a new method which do the job
			- add an item to the hash $callbacks
					<menu name> => \&method

=cut

sub _selectGlobalVariables {
	my $self = shift;
	my ($mw,$text) = @_;

	my @list =  &main::getGlobalVariables();

	return undef unless (@list);

	my @rv = &std::dlg_selectFromList($mw,-list => \@list);
	chomp @rv;
	map {
		$self->_insertOrReplaceValue($text,"$_");
	} @rv;
	return undef
}

sub _selectLocalVariables {
	my $self = shift;
	my ($mw,$text) = @_;

	my @list =  &main::getLocalVariables();

	return undef unless (@list);

	my @rv = &std::dlg_selectFromList($mw,-list => \@list);
	chomp @rv;
	map {
		$self->_insertOrReplaceValue($text,"$_");
	} @rv;
	return undef
}

sub _selectWidget { 	## select and insert at current pos
	my $self = shift;
	my ($mw,$text) = @_;
	my @list =  &main::getWidgetIdList();

	return undef unless (@list);

	my @rv = &std::dlg_selectFromList($mw,-list => \@list);
	chomp @rv;
	map {
		$self->_insertOrReplaceValue($text,"\$$_");
	} @rv;
	return undef
}

sub _selectCursorfont {
	my $self = shift;
	my ($parent,$target) = @_;
	require "selectCursor.pl";
	my $cursor = &dlg_selectCursor($parent) ; ## -text => $target);
	if (defined $cursor) {
		chomp $cursor;
		$self->_insertOrReplaceValue($target,"'$cursor'");
	} else {
		## dismissed
	}
	return undef
}

sub _selectTextIndex {
	my $self = shift;
	my ($parent,$target) = @_;
	my @list =  ('end','@<x>,<y>','<n>.<m>','1.0','current','insert','<tag>.first','<tag>.last');

	my @rv = &std::dlg_selectFromList($parent,-list => \@list);
	chomp @rv;
	map {
		$self->_insertOrReplaceValue($target,$_);
	} @rv;
	return undef
}

sub _selectListboxIndex {
	my $self = shift;
	my ($parent,$target) = @_;
	my @list =  ('active','anchor','end','@<x>,<y>','<number>');

	my @rv = &std::dlg_selectFromList($parent,-list => \@list);
	chomp @rv;
	map {
		$self->_insertOrReplaceValue($target,$_);
	} @rv;
	return undef
}

sub _genFontCode {
	my $self = shift;
	my ($parent,$target) = @_;
	require ctkFontDialog;
	my $font = $parent->ctkFontDialog(-title => "Font constructor", -gen => 'options');
	my $f = $font->Subwidget('Code')->get ('1.0','end');
	if ($f) {
		chomp $f;
		$self->_insertOrReplaceValue($target,$f);
	} ## else {} intentionally left empty
	return undef
}

=head3 compileFuncList

	Compile the given array of lines and return a ref to HASH.

	Arguments

		ref to array of lines (of perl code)

	Return

		ref to HASH

	Exception

		compile error $@ (message to log)

	Note

		will always return a ref to hash

=cut

sub compileFuncList {
	my $self = shift;
	my ($code) = @_;
	my $rv;
	eval '$rv = '. join ('',@$code).';';
	if ($@) {
		&main::Log("Could not successfully compile funcList because of '$@'.");
		$rv = {};
	}
	return $rv;
}

=head3 loadFuncList

	Load the funcList definition into memory, compile it and
	return a ref to HASH.

	Argument
		- name of the version/release  i.e. '3.095'

	Returns
		- file definition structure as ref to HASH

=cut

sub loadFuncList {
	my $self = shift;
	my ($fName) = @_;
	my $rv = {};
	$fName = $funcListFileName unless defined($fName);
	unless (-f $fName) {
		&main::log(__PACKAGE__.'::loadFuncList, Missing funcList.');
		return $rv ;
	}
	my $f = ctkFile->new(fileName => $fName,debug => $debug);
	$f->open();
	my @code =  $f->get;
	$f->close;
	$rv = $self->compileFuncList(\@code);
	return $rv;
}


1; ## make perl happy ...
