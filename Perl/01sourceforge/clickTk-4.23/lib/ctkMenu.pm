=pod

=head1 ctkMenu

	This package provides the menu, the toolbar and the
	various popup menus.

=head2 Methods

	_checkState
	activeOnState
	disableMenuItem
	import
	menuItemDef
	normalMenuItem
	resetMenuInitState
	resetMenuState
	saveMenuInitState
	savePopupMenuState
	setupBindings
	setupMenu
	setupPopupMenu
	setupToolbar
	symbolics
	traceMenu
	tracePopupMenu
	updateMenu
	updatePopup

=head2 Programming notes

=over

=item Exported values

	Names of the supported program states.

=back

=head2 Maintenance

	Author:	MARCO
	date:	17.10.2006
	History
			17.10.2006 MO00029 First draft
			21.11.2007 version 1.03
			22.02.2008 version 1.04
			17.04.2008 version 1.05
			04.12.2009 version 1.06
			20.12.2011 version 1.07 P093
			04.11.2013 version 1.08 P106

=cut

package ctkMenu;

use strict;

our $VERSION = 1.08;

my $debug = 0;

my $lastProgramState = 0;

use ctkMenubutton 1.01;

sub import {
	my $class = shift;
	my $pkg = caller;
	my $constant;
	my $i = 1;
	no strict 'refs';
	map {
		$constant = "${pkg}::$_";
		*$constant = eval "sub (){$i}";
		print "\n\tconstant '$constant' set to value '$i'" if ($debug);
		my $w = eval "$constant";
		print "\n\tcheck ".$w if ($debug);
		$i *= 2;
	} (qw/SM_STARTING SM_WORKING SM_CHANGED SM_WAITING SM_PASTE SM_UNDO SM_REDO/);
	map {
		$constant = "${pkg}::$_";
		*$constant = eval "sub (){$i}";
		print "\n\tconstant '$constant' set to value '$i'" if ($debug);
		my $w = eval "$constant";
		print "\n\tcheck ".$w if ($debug);
		$i *= 2;
	} (qw/SM_ET_CHANGED SM_ET_CLIPBOARD SM_ET_NOTMW SM_ET_NOTHIDDEN SM_ET_HIDDEN SM_ET_HAVEGEOM /);
	$constant = "${pkg}::SM_NEVER"; *$constant = sub(){0};
	$constant = "${pkg}::SM_EVER"; *$constant = sub(){8191};
	$constant = "${pkg}::SM_EXACT"; *$constant = sub(){8192};
	$constant = "${pkg}::SM_ALL"; *$constant = sub(){16384};
	$constant = "${pkg}::SM_NOT"; *$constant = sub(){32768};
}

=head2 symbolics

	Return the symbolic names corresponding to the value of given state.

=cut

sub symbolics {
	my $self = shift;
	my ($state) = @_;
	my $rv = '';
	my $i = 1;

	$state &= &SM_EVER;	## because of pragma 'use strict'
;

	map {
		$rv .= "$_ " if ($state & $i);
		$i *= 2
	} (qw/SM_STARTING SM_WORKING SM_CHANGED SM_WAITING SM_PASTE SM_UNDO SM_REDO/);
	map {
		$rv .= " $_" if ($state & $i);
		$i *= 2
	} (qw/SM_ET_CHANGED SM_ET_CLIPBOARD SM_ET_NOTMW SM_ET_NOTHIDDEN SM_ET_HIDDEN SM_ET_HAVEGEOM/);
	$rv =~ s/^\s+//;
	return $rv
	}

BEGIN {
&import();
}

=head2 Class variables

	popup_def
	popup_insert_def

	aMenuInitState
	aMenu
	aToolbar
	menuItemDef

=cut

my $popup_def =[];
my $popup_insert_def=[];

my $aMenuInitState =[];
my $aMenu = [];
my $aToolbar =[];
my $menuItemDef = [ ];

my $aToolbar_def = [
	['new',      \&main::file_newx,           'New file', 'normal',SM_WORKING],
	['open',     \&main::file_open,           'Open file', 'normal',SM_WORKING],
	['save',     \&main::file_save,           'Save current file', 'normal',SM_WORKING+SM_CHANGED+SM_ALL],
	[0],
	['before',   [\&main::insert,'before'],   'Insert new widget before', 'normal',SM_WORKING+SM_ET_NOTMW+SM_ALL],
	['after',    [\&main::insert,'after'],    'Insert new widget after', 'normal',SM_WORKING+SM_ET_NOTMW+SM_ALL],
	['underneath',[\&main::insert,'underneath'],'Insert new widget underneath', 'normal',SM_WORKING],
	[0],
	['undo',     \&main::undo,                'Undo last change', 'disabled',SM_UNDO],
	['redo',     \&main::redo,                'Redo last change', 'disabled',SM_REDO],
	[0],
	['delete',   \&main::edit_delete,         'Erase selected', 'normal',SM_WORKING],
	['cut',      \&main::edit_cut,            'Cut selected tree to clipboard', 'normal',SM_WORKING],
	['copy',     \&main::edit_copy,           'Copy selected tree to clipboard', 'normal',SM_WORKING],
	['paste',    \&main::edit_paste,          'Paste from clipboard before selected', 'disabled',SM_PASTE],
	['options',\&main::edit_widgetOptions,    'View & edit options', 'normal',SM_WORKING],
	[0],
	['viewcode', \&main::view_code,           'Preview generated code', 'normal',SM_WORKING],
	[0],
	['exit',     \&main::abandon,             'Exit session', 'normal',SM_EVER],
	];

=head2 menuItemDef

	Return the ref to the menu item definition table

=cut

sub menuItemDef {
	my $self = shift;
	return $menuItemDef
}

=head2 activeOnState

	return the value of the option -activeOnState fro the given item

=cut

sub activeOnState {
	my $self = shift;
	my ($menubutton,$item) = @_;
	## &main::trace("activeOnState $menubutton , $item");
	my $rv;
	my $a = $self->menuItemDef->[$menubutton][$item];
	for (my $i = 2; $i < scalar(@$a) - 1; $i += 2) {
		if ($a->[$i] eq '-activeOnState') {
			$rv = $a->[$i+1];
			last
		}
	}
	## &main::trace("rv = $rv") if (defined($rv));
	return $rv
}

=head2 disableMenuItem

	Disable the given menu item.

=cut

sub disableMenuItem {
	my $self = shift;
	my ($aMenu,$menubutton,$item) = @_;
	&main::trace("disableMenuItem");
	$aMenu =[] unless (defined $aMenu);
	return undef unless (@$aMenu);
	return undef unless (Tk::Exists ($aMenu->[$menubutton]));
	$aMenu->[$menubutton]->entryconfigure($item,-state => 'disabled');
	return 1
}

=head2 normalMenuItem

	Activate the given menuitem setting the status option to normal.

=cut

sub normalMenuItem {
	my $self = shift;
	my ($aMenu,$menubutton,$item) = @_;
	&main::trace("normalMenuItem");
	$aMenu =[] unless (defined $aMenu);
	return undef unless (@$aMenu);
	return undef unless (Tk::Exists($aMenu->[$menubutton]));
	$aMenu->[$menubutton]->entryconfigure($item,-state => 'normal');
	return 1
}

=head2 savePopupMenuState

	This method scan (recursively) the given menubutton definition and saves the state of all menu state in an array.
	Items that doesn't have a state produce an empty string as a kind of placeholder.
	So the returned array is a parallel array of the given menu.

=cut

sub savePopupMenuState {
	my $self = shift;
	my ($m) = @_;
	my $rv = [];
	&main::trace("savePopupMenuState");
		for (my $j = 0;$j <= $m->index('last') ;$j++) {
			my $t = $m->type($j);
			if ( $t eq 'command') {
				push @$rv, $m->entrycget($j,-state);
			} elsif ($t eq 'cascade' ) {
					push @$rv,$self->savePopupMenuState($m->entrycget($j,-menu));
			} elsif ($t eq 'separator' ) {
				push @$rv,'';	## placeholder
			} elsif ($t eq 'tearoff' ) {
				push @$rv,'';	## placeholder
			} elsif ($t eq 'checkbutton' ) {
				push @$rv, $m->entrycget($j,-state);
			} else {
				&main::trace("\t$j ($t)");
			}
		}
	return $rv;
}

=head2 saveMenuInitState

	This method calls savePopupMenuState for all menubuttons of the given menubar.
	The resulting array is returned and
	saved into the class variable aMenuInitState.

=cut

sub saveMenuInitState {
	my $self = shift;
	my ($aMenu) = @_;
	my $rv = [];
	&main::trace("saveMenuInitState");
	for( my $i = 0; $i < @$aMenu ; $i++) {
		my $m = $aMenu->[$i];
		push @$rv,$self->savePopupMenuState($m->menu);
	}
	$aMenuInitState = $rv;
	return $rv
}

=head2 traceMenu

	This method traces the structure of the given menubar .

=cut

sub traceMenu {
	my $self = shift;
	my ($aMenu) = @_;

	for( my $i = 0; $i < @$aMenu ; $i++) {
		my $m = $aMenu->[$i];
		&main::trace("$i ".$m->cget(-text));
		&main::tracePopupMenu($m->menu);
	}
	return 1
}

=head2 tracePopupMenu

	This method traces the structure of the given menubutton printing by means
	of messages tracePopupMenu and main::trace .

=cut

sub tracePopupMenu {
	my $self = shift;
	my ($m) = @_;
		for (my $j = 0;$j <= $m->index('last') ;$j++) {
			my $t = $m->type($j);
			if ( $t eq 'command') {
				&main::trace("\t$j ".$m->entrycget($j,-label). " ($t)");
			} elsif ($t eq 'cascade' ) {
					&main::trace("\t$j ".$m->entrycget($j,-label). " ($t)");
					$self->tracePopupMenu($m->entrycget($j,-menu));
			} elsif ($t eq 'separator' ) {
				&main::trace("\t$j --- ($t)");
			} elsif ($t eq 'tearoff' ) {
				&main::trace("\t$j === X ($t)");
			} elsif ($t eq 'checkbutton' ) {
				&main::trace("\t$j ".$m->entrycget($j,-label). " ($t)");
			} else {
				&main::trace("\t$j ($t)");
			}
		}
	return 1
}

=head2 setupMenu

	This method sets up the main menu using the given menubar.
	The menu buttons are of type ctkMenubutton and the items are
	taken from the class variable menuItemDef.

	The instantiated menubuttons are returnd in an array.

=cut

sub setupMenu {
	my $self = shift;
	my ($menubar) = @_;
	my $rv = [];
	&main::trace("setupMenu");
	$menuItemDef = [
[
	[Button => '~Open',	-command => \&main::file_open, -accelerator => 'Ctrl+o', -activeOnState => SM_WORKING],
	[Button => 'Open previous',-command => \&main::file_openPrevious, -activeOnState => SM_WORKING],
	[Button => '~New',	-command => \&main::file_newx,  -accelerator => 'Ctrl+n', -activeOnState => SM_WORKING],
	[Button => '~Save',	-command => \&main::file_save, -accelerator => 'Ctrl+s', -activeOnState => SM_CHANGED],
	[Button => 'Save ~As', -command => [\&main::file_save_as,undef], -activeOnState => SM_WORKING],
	[Button => 'Close',-command => \&main::file_close, -state =>  'disabled',-activeOnState => SM_WORKING],
	[Button => 'Restart',-command => \&main::do_restartSession, -state =>  'disabled',-activeOnState => SM_WORKING],
	[Separator => ''],
	[Button => 'Save work',	-command => \&main::work_save, -state =>  'disabled', -activeOnState => SM_WORKING+SM_CHANGED+SM_ALL],
	[Button => 'Restore work',-command => \&main::work_restore,-state =>  'disabled' , -activeOnState => SM_WORKING],
	[Separator => ''],
	[Button => 'Save template', -command => \&main::template_save, -state => 'disabled', -activeOnState => SM_WORKING+SM_CHANGED+SM_ALL],
	[Separator => ''],
	[Button => 'Set Application', -command => \&main::setApplication, -state => 'normal'],
	[Cascade => 'Code ~Properties', -tearoff=>1, -menuitems => [
		[Button => 'Options', -command => \&main::dlg_codeOptions],
		[Button => 'Variables', -command => \&main::code_variables],
		[Separator => ''],
		[Button => 'Libraries', -command => \&main::dlg_libraries],
		[Separator => ''],
		[Button => 'Callbacks', -command => \&main::file_callbacks],
		[Button => 'Methods', -command => \&main::file_methods],
		[Button => 'General code', -command => \&main::file_gcode],
		[Button => 'Other code', -command => \&main::file_other_code],
		[Separator => ''],
		[Button => 'Pod section', -command => \&main::file_pod]
		]
	],
	[Separator => ''],
	[Button => 'Import',-command => \&main::file_import,   -state => 'normal', -activeOnState => SM_CHANGED+SM_NOT],
	[Button => 'Export',-command => \&main::file_export,-state => 'normal', -activeOnState => SM_CHANGED+SM_NOT],
	[Separator => ''],
	[Button => '~Quit',-command => \&main::abandon,   -accelerator => 'ESC']
],
[
	[Button => '~Widget Options', -command => \&main::edit_widgetOptions, -activeOnState => SM_WORKING+SM_ET_NOTMW+SM_ALL],
	[Separator=>''],
	[Button => '~Undo', -command => \&main::undo, -accelerator => 'Ctrl+z', -activeOnState => SM_UNDO],
	[Button => '~Redo', -command => \&main::redo, -accelerator => 'Ctrl+r', -activeOnState => SM_REDO],
	[Separator=>''],
	[Button => '~Cut',   -command => \&main::edit_cut, -accelerator => 'Ctrl+x', -activeOnState => SM_WORKING+SM_ET_NOTMW+SM_ALL],
	[Button => 'C~opy',  -command => \&main::edit_copy, -accelerator => 'Ctrl+c', -activeOnState => SM_WORKING+SM_ET_NOTMW+SM_ALL],
	[Button => 'P~aste', -command => \&main::edit_paste, -accelerator => 'Ctrl+v', -activeOnState => SM_PASTE],
	[Separator=>''],
	[Button => 'R~ename', -command => \&main::edit_rename, -activeOnState => SM_WORKING+SM_ET_NOTMW],
	[Button => '~Delete', -command => \&main::edit_delete, -accelerator => 'Delete', -activeOnState => SM_WORKING+SM_ET_NOTMW+SM_ALL],
	[Button => 'Replace', -command => \&main::edit_replace, -activeOnState => SM_WORKING+SM_ET_NOTMW]
],
[
	[Button => '~Before',     -command => [\&main::insert,'before'], -activeOnState => SM_WORKING+SM_ET_NOTMW+SM_ALL],
	[Button => '~After',      -command => [\&main::insert,'after'], -activeOnState => SM_WORKING+SM_ET_NOTMW+SM_ALL],
	[Button => '~Underneath', -command => [\&main::insert,'underneath'], -activeOnState => SM_WORKING],
	[Button => '~Frame', -command => [\&main::insert,'frame'], -activeOnState => SM_WORKING],
	[Button => '~Non-visual', -command => [\&main::insert,'nonVisual'], -activeOnState => SM_WORKING],
	[Button => '~Order',     -command => \&main::do_updateOrder, -activeOnState => SM_WORKING]
],
[
	[Button => '~Repaint',    -command => \&main::preview_repaint, -activeOnState => SM_WORKING],
	[Button => '~Code',       -command => \&main::view_code, -activeOnState => SM_WORKING],
	[Button => 'Pick color', -command=> sub{ &main::pickColor() }, -activeOnState => SM_WORKING],
	[Button => '~Re-color all', -command=> \&main::recolorMySelf , -activeOnState => SM_WORKING],
	[Button => '~Re-color all to default', -command=> \&main::resetToDefault , -activeOnState => SM_WORKING],
	[Button => 'View widget structure', -command => \&main::main_viewWidgetStructure, -activeOnState => SM_WORKING],
	[Button => 'List bindings', -command => \&main::main_listBindings, -activeOnState => SM_WORKING],
	[Button => 'View ctk Logfile', -command => \&main::viewLogFile, -activeOnState => SM_WORKING]
],
[
	[Button => '~Edit code', -command => \&main::tools_edit, -activeOnState => SM_WORKING],
	[Separator => ''],
	[Button => '~Check syntax', -command => \&main::tools_syntax, -activeOnState => SM_WORKING],
	[Button => '~Run code',     -command => \&main::tools_run, -activeOnState => SM_WORKING],
	[Button => 'Gen Font code', -command => \&main::tools_genFontCode, -activeOnState => SM_WORKING],
	[Button => 'Gen cursor font', -command => \&main::tools_cursor, -activeOnState => SM_WORKING],
	[Button => 'Tk variables',  -command => \&main::showTkVariables, -activeOnState => SM_WORKING],
	[Separator => ''],
	[Button => 'Add widget class definition', -command => \&main::addWidgetClassDef, -activeOnState => SM_CHANGED+SM_NOT],
	[Button => 'Update widget class definition', -command => \&main::updateWidgetClassDef, -activeOnState => SM_CHANGED+SM_NOT],
	[Button => 'Delete widget class definition', -command => \&main::deleteWidgetClassDef, -activeOnState => SM_CHANGED+SM_NOT]
],
[
	[Checkbutton => 'Use Toplevel for the preview',
		-variable=>\$ctkPreview::opt_useToplevel, -command=> \&main::initPreview],
	[Checkbutton => 'Suppress callbacks for the preview',
		-variable=>\$ctkPreview::suppressCallbacks, -command=>\&main::preview_repaint],
	[Checkbutton => '~Show widget balloons',
		-variable=>\$main::view_balloons, -command=>\&main::preview_repaint],
	[Checkbutton => '~Blink widget on selection',-variable=>\$main::view_blink],
	[Checkbutton => 'Show ~mouse pointer X,Y coordinates',
		-variable => \$ctkPreview::view_pointerxy, -command=>\&main::preview_repaint],
	[Checkbutton => 'Isolate geometry messages',
		-variable=>\$main::opt_isolate_geom, -command=> [\&main::changes,1] ],
	[Checkbutton => 'Ask for widget ident',
		-variable=>\$main::opt_askIdent, -command=> sub {1} ],
	[Checkbutton => 'Gen test code',
		-variable=>\$main::opt_TestCode, -command=> [\&main::changes,1] ],
	[Checkbutton => 'Gen modal dialog by default',
		-variable=>\$main::opt_modalDialog, -command=> sub {1} ],

	[Checkbutton => 'Copy/paste parent and children',
		-variable=>\$main::opt_copyChildren, -command=> sub {1} ],
	[Checkbutton => 'Use specialized color picker',
		-variable=>\$main::opt_colorPicker, -command=> sub {1} ],
	[Checkbutton => 'Debug mode',
		-variable=>\$main::debug, -command=> sub { ctkBase->debug($main::debug) } ],
	[Checkbutton => 'Save work on changes',
		-variable=>\$main::work_save_temp, -command=> sub { &main::work_save_temp(1) if ($main::work_save_temp)} ]
],
[
	[Button => 'ctk ~help',       -command => \&main::help, -activeOnState => SM_WORKING],
	[Button => '~Context help',    -command => ['ctkHelp::tkpod',$main::help], -activeOnState => SM_WORKING],
	[Button => '~Widget help',    -command => ['ctkHelp::tkpodW',$main::help], -activeOnState => SM_WORKING],
	[Cascade => '~Perl/Tk manuals', -tearoff=>1, -menuitems => [
		[Button => 'Overview',          -command => ['ctkHelp::tkpod',$main::help,'overview','useTk']],
		[Button => 'Standard options',  -command => ['ctkHelp::tkpod',$main::help,'options','useTk']],
		[Button => 'Base class widget',  -command => ['ctkHelp::tkpod',$main::help,'Widget','useTk']],
		[Button => 'Option handling',   -command => ['ctkHelp::tkpod',$main::help,'option','useTk']],
		[Button => 'Tk variables',      -command => ['ctkHelp::tkpod',$main::help,'tkvars','useTk']],
		[Button => 'Grab manipulation', -command => ['ctkHelp::tkpod',$main::help,'grab','useTk']],
		[Button => 'Binding',           -command => ['ctkHelp::tkpod',$main::help,'bind','useTk']],
		[Button => 'Bind tags',         -command => ['ctkHelp::tkpod',$main::help,'bindtags','useTk']],
		[Button => 'Callbacks',         -command => ['ctkHelp::tkpod',$main::help,'callbacks','useTk']],
		[Button => 'Events',            -command => ['ctkHelp::tkpod',$main::help,'event','useTk']],
		[Button => 'Composite widgets',  -command => ['ctkHelp::tkpod',$main::help,'Composite','useTk']],
		[Button => 'Mega widgets',	-command => ['ctkHelp::tkpod',$main::help,'mega','useTk']],
		[Button => 'ConfigSpecs',  	-command => ['ctkHelp::tkpod',$main::help,'ConfigSpecs','useTk']],
		[Button => 'Derived', 	 	-command => ['ctkHelp::tkpod',$main::help,'Derived','useTk']]
		]
	],
	[Button => 'Close all',    -command => ['ctkHelp::killAll',$main::help]],
	[Button => '~About',     -command => \&main::menu_about],
]
] unless @$menuItemDef;

	push @$aMenu,$menubar->ctkMenubutton(-text => 'File', -underline => 0, -tearoff =>0, -menuitems => $menuItemDef->[0])->pack(-side=>'left');
	push @$aMenu,$menubar->ctkMenubutton(-text => 'Edit', -underline => 0, -tearoff => 0, -menuitems => $menuItemDef->[1])->pack(-side=>'left');
	push @$aMenu,$menubar->ctkMenubutton(-text => 'Insert', -underline => 0, -tearoff => 0, -menuitems => $menuItemDef->[2])->pack(-side=>'left');
	push @$aMenu,$menubar->ctkMenubutton(-text => 'View', -underline => 0, -tearoff => 0, -menuitems => $menuItemDef->[3])->pack(-side=>'left');
	push @$aMenu,$menubar->ctkMenubutton(-text => 'Tools', -underline => 0, -tearoff => 0, -menuitems => $menuItemDef->[4])->pack(-side=>'left');
	push @$aMenu,$menubar->ctkMenubutton(-text => 'Options', -underline => 0, -tearoff => 0, -menuitems => $menuItemDef->[5])->pack(-side=>'left');
	push @$aMenu,$menubar->ctkMenubutton(-text => 'Help', -underline => 0, -tearoff => 1, -menuitems => $menuItemDef->[6])->pack(-side=>'right');

	## $self->traceMenu($aMenu);
	$rv = $aMenu;
	return wantarray ? @$rv : $rv
}

=head2 setupBindings

	Set up the bindings of the for the menu accelerator keys.

=cut

sub setupBindings {
	my $self = shift;
	my ($hwnd) = @_;
	&main::trace("setupBindings");

	$hwnd->bind('<Control-o>',\&main::file_open);
	$hwnd->bind('<Control-s>',\&main::file_save);
	$hwnd->bind('<Control-n>',\&main::file_newx);
	$hwnd->bind('<Control-z>',\&main::undo);
	$hwnd->bind('<Control-r>',\&main::redo);
	$hwnd->bind('<Delete>',\&main::edit_delete);
	$hwnd->bind('<Control-x>',\&main::edit_cut);
	$hwnd->bind('<Control-c>',\&main::edit_copy);
	$hwnd->bind('<Control-v>',\&main::edit_paste);

	$hwnd->bind('<F1>',\&main::help);
	$hwnd->bind("<Escape>", \&main::abandon);
	return 1
}

=head2 setupToolbar

	Set up the main toolbar.

=cut

sub setupToolbar {
	my $self = shift;
	my ($parent,$balloon,$pic) = @_ ;

	&main::trace("setupToolbar");
	return undef if (@$aToolbar);

	foreach my $i (0 .. scalar(@$aToolbar_def)-1) {
		my $button = $aToolbar_def->[$i];
		my $b = 0;
		if($button->[0] ne '0') {
			$b = $parent->Button(-image=>$pic->{$button->[0]}, -command=>$button->[1], -state => $button->[3]);
			$b->pack(-side=>'left',-expand=>0);
			$balloon->attach($b,-balloonmsg=>$button->[2]);
		} else {
			$parent->Label(-text=>' ')->pack(-side=>'left',-expand=>0);
		}
		push @$aToolbar, $b;
	}
	return 1
}

=head2 setupPopupMenu

	Set up the popup menu to operate on the selected widget.

=cut


sub setupPopupMenu {
	my $self = shift;
	my ($hwnd) = @_;
	&main::trace("setupPopupMenu");

	my $popup=$hwnd->Menu(-tearoff=>$main::popupmenuTearoff);
	my $popup_insert=$popup->Menu(-tearoff=>0);

	$popup_insert_def =[
	['command',-label=>'Before',-underline=>0,-command=>[\&main::insert,'before'], -activeOnState => SM_ET_NOTMW],
	['command',-label=>'After',-underline=>0,-command=>[\&main::insert,'after'], -activeOnState => SM_ET_NOTMW],
	['command',-label=>'Underneath',-underline=>0,-command=>[\&main::insert,'underneath'], -activeOnState => SM_EVER],
	['command',-label=>'Frame',-underline=>0,-command=>[\&main::insert,'frame'], -activeOnState => SM_EVER],
	['command',-label=>'Order',-underline=>0,-command => \&main::do_updateOrder, -activeOnState => SM_ET_NOTMW]
	] unless (@$popup_insert_def);
	$popup_def = [
	['cascade',-label=>'Insert',-underline=>0,-menu=>$popup_insert, -activeOnState => SM_EVER],
	['command',-label=>'Options',-underline=>0,-command=>\&main::edit_widgetOptions, -activeOnState => SM_ET_NOTMW],
	['command',-label=>'All options',-underline=>0,-command=>\&main::edit_updateAllOptions, -activeOnState => SM_ET_NOTMW],
	['command',-label=>'View all options',-underline=>0,-command=>\&main::viewAllOptions, -activeOnState => SM_ET_NOTMW],
	['command',-label=>'View default options',-underline=>0,-command=>\&main::view_defaultOptions, -activeOnState => SM_ET_NOTMW],
	['command',-label=>'List bindings',-underline=>0,-command=>\&main::main_listBindings, -activeOnState => SM_EVER],
	['command',-label=>'Context help',-underline=>8,-command=>['ctkHelp::tkpod',$main::help], -activeOnState => SM_EVER],
	['command',-label=>'Cut',-underline=>0,-command=>\&main::edit_cut,-accelerator => 'Ctrl+x', -activeOnState => SM_ET_NOTMW],
	['command',-label=>'Copy',-underline=>1,-command=>\&main::edit_copy,-accelerator => 'Ctrl+c', -activeOnState => SM_ET_NOTMW],
	['command',-label=>'Paste',-underline=>0,-command=>\&main::edit_paste,-accelerator => 'Ctrl+v', -activeOnState => SM_ET_CLIPBOARD],
	['command',-label=>'Rename',-underline=>0,-command=>\&main::edit_rename, -activeOnState => SM_ET_NOTMW],
	['command',-label=>'Delete',-underline=>0,-command=>\&main::edit_delete,-accelerator => 'Delete', -activeOnState => SM_ET_NOTMW],
	['command',-label=>'Replace',-underline=>0,-command=>\&main::edit_replace, -activeOnState => SM_ET_NOTMW],
	['command',-label=>'Hide widget',-underline=>0,-command=>\&main::hideWidget, -activeOnState => SM_ET_HAVEGEOM+SM_ET_NOTHIDDEN+SM_ET_NOTMW+SM_ALL],
	['command',-label=>'Show widget',-underline=>0,-command=>\&main::unhide, -activeOnState => SM_ET_HAVEGEOM+SM_ET_HIDDEN+SM_ET_NOTMW+SM_ALL],
	['command',-label=>'View geometryInfo',-underline=>0,-command=>\&main::view_geomInfo, -activeOnState => SM_ET_HAVEGEOM+SM_ET_NOTMW+SM_ALL],
		['command',-label=>'Switch Scrolled',-underline=>0,-command=>\&main::edit_switchScrolled, -activeOnState => SM_ET_HAVEGEOM+SM_ET_NOTMW+SM_ALL]
	] unless (@$popup_def);

	my @w;
	map {
		@w = @$_;
		splice(@w,$#w - 1,2) if ($w[$#w-1] =~ /activeOnState/i);
		$popup_insert->add(@w);
	} @$popup_insert_def;

	@w = @{$popup_def->[0]};
	splice(@w,$#w - 1,2) if ($w[$#w-1] =~ /activeOnState/i);
	$popup->add(@w);

	map {
		@w = @{$popup_def->[$_]};
		splice(@w,$#w - 1,2) if ($w[$#w-1] =~ /activeOnState/i);
		$popup->add(@w);
		} 1.. scalar(@$popup_def) - 1;

	## &main::tracePopupMenu($popup);

	return $popup
}

=head2 resetMenuState

	Reset the state of the menu items using the given
	table.

=cut

sub resetMenuState {
	my $self = shift;
	my ($m,$state) = @_;
	&main::trace("resetMenuState");

	$state = [] unless (defined $state);
	return undef unless (Tk::Exists ($m));
	return undef unless ((@$state));

	for (my $j = 0;$j <= $m->index('last') ;$j++) {
			next unless ($state->[$j]);
			my $t = $m->type($j);
			if ( $t eq 'command') {
				$m->entryconfigure($j,-state => $state->[$j]);
			} elsif ($t eq 'cascade' ) {
					my $state = $aMenuInitState->[$j];
					main::resetMenuState($m->entrycget($j,-menu),$state);
			} elsif ($t eq 'separator' ) {
				##
			} elsif ($t eq 'tearoff' ) {
				##
			} elsif ($t eq 'checkbutton' ) {
				$m->entryconfigure($j,-state => $state->[$j]);
			} else {
				&main::trace("\t$j ($t)");
			}
	}
	return 1
}

=head2 resetMenuInitState

	Reset the state of the menu items as saved by
	saveMenuInitState

=cut

sub resetMenuInitState {
	my $self = shift;
	my ($aMenu) = @_;
	my $rv ;
	&main::trace("resetmenuInitState");

	$aMenu = [] unless defined $aMenu;
	return undef unless (@$aMenu);

	for( my $i = 0; $i < @$aMenu ; $i++) {
		my $state = $aMenuInitState->[$i];
		my $m = $aMenu->[$i];
		&resetMenuState($m->menu,$state);
	}
	return $rv
}

=head2 _checkState

	check the given state against the current program state
	and return the result of the compare as a boolean value.

	Arguments

		required state (including check options)
		program state

	Return

		true if the states match,
		false otherwise

	Notes

		compare options are:

		SM_EXACT  required is the exact match of the values,
		SM_ALL    all states set in the required state must match,
		SM_NOT    is the opposite of SM_ALL,
		none      at least one state of the required state must match.

		Of course the options are mutually exclusive.

=cut

sub _checkState {
	my $self = shift;
	my ($x,$state) = @_;
	my $rv;
	&main::trace("_checkState x= $x state :",$self->symbolics($state));
	if ($x & SM_EXACT) {
			$x &= SM_EVER;
			$rv = ($x == $state);
	} elsif ($x & SM_ALL) {
			$x &= SM_EVER;
			$rv =  ($x == ($x & $state) )
	} elsif ($x & SM_NOT) {
			$x &= SM_EVER;
			$rv =  not($x == ($x & $state))
	} else {
			$rv = ($x & $state)
	}
	return $rv
}

=head2 updateMenu

	This method updates the state of the main menu items depending on the
	program state computed by main::computeState.

	It always returns the value undef.

	Notes:

		- main menu consists of menuBar and toolbar.
		- TODO: also handle accelerator keys (bindings)

=cut

sub updateMenu {
	my $self = shift;
	# my ($aMenu) = @_ ;
	&main::trace("updateMenu");
	return undef unless (@$aMenu);

	my $def = $self->menuItemDef;
	my $programState = &main::computeState();

	return undef if ($lastProgramState == $programState);

	map  {
		my $i = $_;
		map {
			my $x = $self->activeOnState($i,$_);
			if (defined ($x)) {
				if ($self->_checkState($x,$programState)) {
					$self->normalMenuItem($aMenu,$i,$_);
				} else {
					$self->disableMenuItem($aMenu,$i,$_);
				}
			} else{}
		} (0 .. scalar(@{$def->[$i]}) - 1) ;
	} (0 .. scalar(@$def) -1);

	map {
		if ($aToolbar->[$_]) {
			my $def = $_;
			my $x = $aToolbar_def->[$def][4];
			if (defined ($x)) {
				if ($self->_checkState($x,$programState)) {
						$aToolbar->[$def]->configure(-state => 'normal');
					} else {
						$aToolbar->[$def]->configure(-state => 'disabled');
					}
			} else {}
		} else {}
	} 0 .. scalar(@$aToolbar) - 1;
	$lastProgramState = $programState;
	return undef;
}

=head2 updatePopup

	This method updates the popup menu resulting of <right click>
	on the selected widget definition in the widgets tree.

	Unlike updatemenu it sets the state just once and it
	allows multiple conditions for a single item.

	It takes three args

		- the popup widget itself,
		- the current state of the widget tree and
		- the definition of the definition of the popup menu.

	It always returns the value UNDEF.

	Important notes (17.04.2008/mm):

	- This method doesn't apply to any
	  menu definition due to the use of globals $popup_def
	  and $popup_insert_def.

	- Option tearoff leads to multiple popups because the
	  <right click>-binding callbacks cannot recognize the existence of the
	  tearoff popup

	- The callback defined with option -tearoffcommand doesn't
	  received any arguments , despite the description in various docs!

	-- Methods Tk::Exists() and ismapped() doesn't return useable values!

	- tearoff popup get not automatically updated on widget selection,
	<right click> must be done on the selected widget.

	- Unfortunately there are little information abaut this issue!

	- Conclusions: set the option popupmenuTearoff to 0 !

=cut

sub updatePopup {
	my $self = shift;
	my ($m,$editTreeState,$def) = @_;
	&main::trace("updatePopup");
	$def = $popup_def unless defined $def;
	my $x;
	my $state;
	for (my $i = 0,my $j = 0;$j <= $m->index('last') ;$j++) {
			my $t = $m->type($j);
			next if ($t =~ /tearoff/ || $t =~ /separator/i);
			if ($i < @$def) {
				$x = pop @{$def->[$i]};
				my $y = pop @{$def->[$i]};
				push @{$def->[$i]},($y,$x);
				$x = SM_EVER unless($y =~ /activeOnState/i);
				$state = ($self->_checkState($x,$editTreeState)) ? 'normal' : 'disabled';
			} else {
				$state = 'disabled'
			}
			if ( $t eq 'command') {
				## &main::trace("entryconfigure ($j , -state , $state)");
				$m->entryconfigure($j,-state => $state);
			} elsif ($t eq 'cascade' ) {
					ctkMenu->updatePopup($m->entrycget($j,-menu),$editTreeState,$popup_insert_def); ## TODO take new $def out of actual $def
			} elsif ($t eq 'separator' ) {
				##
			} elsif ($t eq 'tearoff' ) {
				##
			} elsif ($t eq 'checkbutton' ) {
				$m->entryconfigure($j,-state => $state);
			} else {
				&main::trace("\t$j ($t)");
			}
			$i++;
	}
	return undef
}

1; ## -----------------------------------

