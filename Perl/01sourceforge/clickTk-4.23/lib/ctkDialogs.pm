#!/usr/lib/perl

=pod

=head1 ctkDialogs

	Package ctkDialogs provides standard dialogs which may be used in all
	ctk modules and scripts.


=head2 Programming notes

=over

=item Set up dialogs

	Standard dialogs are set up sending a message to the package std.

	Example:

		&std::ShowErrorDialog("Syntax error");

=back

=head2 Maintenance

	Author:	marco
	date:	29.09.2005
	History
			29.09.2005 take over methods from package main.
			24.02.2006 mam MO02403
			17.11.2007 version 1.05
			13.03.2008 version 1.06
			11.04.2008 version 1.07
			27.05.2008 version 1.08
			10.09.2008 version 1.09
			18.09.2008 version 1.10
			04.04.2011 version 1.11
			04.11.2013 version 1.12

=head1 Methods

=cut

package ctkDialogs;

use strict;

use base (qw/ctkBase/);

use vars qw/$VERSION/;

$VERSION = 1.12;

package std;

my $FS = 'ctkFile'->FS;			##  file separator

my $ctkImages ={};

my $Toplevel_getVariable;

sub exists_getVariableDialog {
	return 0 unless(defined($Toplevel_getVariable));
	return Tk::Exists($Toplevel_getVariable)
}

sub _title {
	my $title = shift;
	($title =~ /^\w+\s+-\s+/) ? $title : &main::ctkTitle." - ". $title
}

=head2 getImage

	Get widget of type Photo of standard clickTk images.
	Images must exists as ctk$image.gif in the current working directory
	Images are stored into class data element images for reuse.

=over

=item Arguments

=item Returns

	None.

=item Notes

	None.

=back

=cut

sub getImage {
	my ($image) = @_;
	$image =~ s/^\s+//;$image =~ s/\s+$//;
	$image =~/^\s*(.)(.+)/;
	my $iName = &main::getImageFolder.$FS.'ctk'.uc($1).$2.'.gif';
	$ctkImages->{$image} = $image unless (-f $iName);
	$ctkImages->{$image} = &main::getmw()->Photo(-file => $iName) unless (exists $ctkImages->{$image});
	return $ctkImages->{$image};
	}

=head2 buildCompoundImage

	Build a compound image consisting of an image, and a text.
	Typically used to build buttons.

	See POD section of module Compound for details about args.

=cut

sub buildCompoundImage {
	my ($widget,%args) = @_;
	my $rv = $widget->Compound;
	$rv->Line;
	$rv->Image(-image => $args{-image}) if (exists $args{-image} && defined $args{-image}); 	## i MO0xx06
	$rv->Space(-width => 8) if (exists $args{-text} && exists $args{-image});
	$rv->Text(-text => $args{-text}) if (exists $args{-text});
	return $rv;
}

=head2 buildAndSetCompoundImage

	Call buildCompoundImage to build the compound image and put
	the returned image into the iven widget.

=cut

sub buildAndSetCompoundImage {
	my ($widget,%args) = @_;
	my $rv = &buildCompoundImage($widget,%args);
	$widget->configure(-image => $rv) if (defined($rv));
	return $rv;
}

=head2 fontExists

=cut

sub fontExists {
	my $hwnd = shift;
	my @fNames = @_;
	&main::trace("fontExists");
	my @fonts = $hwnd->fontNames();
	my @fontNames = map { $_ = ${$_};} @fonts;
	my $i =0;
	map {
		my $f = $_;
		$i++ if (grep /$f/ , @fontNames);
	} @fNames;
	return ($i == scalar(@fNames)) ? 1 : 0;
}

=head2 ShowDialog

	Set up a modal dialog whitout an image.

=over

=item Arguments

=item Returns

	None.

=item Notes

	None.

=back

=cut

sub ShowDialog {
	my (%args) = @_;
	&main::trace("ShowDialog");
	my $title = delete $args{-title} if (exists $args{-title});
	$title = '***' unless (defined $title);
	my $d = &main::getmw -> Dialog(-title => &_title($title),%args);
	&main::recolor_dialog($d);
	return $d->Show;
}

=head2 ShowDialogBox

	Set up a standard dialog box.

=over

=item Arguments

	Same as standard widget Dialogbox.

=item Returns

	Returns the text of the pressed button.

=item Notes

	None.

=back

=cut

sub ShowDialogBox {
	my (%args) = @_ ;
	my $rv;
	&main::trace("ShowDialogBox");
	my $d;
	my $title = delete $args{-title} if (exists $args{-title});
	$title = '***' unless (defined  $title);
	if (exists $args{-bitmap}) {
		my $b = std::getImage(delete $args{-bitmap});
		if (ref($b) =~ /Photo/) {
			my $l = delete $args{-text};
			my $d= &main::getmw->ctkDialogBox(-title ,$title, %args);
			my $f = $d->add('Frame',-borderwidth => 2, -relief => 'ridge')->pack(-padx, 5, -pady,5);
			$f->Label(-image => $b, -bg => 'white')->pack(-side => 'left', -anchor => 'w');
			$f->Label(-text => $l, -bg => 'white')->pack(-side => 'left', -anchor => 'w', -expand => 1, -fill => 'both');
			$rv = $d->Show;
		} else {
			$args{-bitmap} = $b;
			$rv = &ShowDialog(-title ,$title,%args);
		}
	} else {
		$rv = &ShowDialog(-title ,$title,%args);
	}
	return $rv;
}

=head2 ShowErrorDialog

	Show an error dialog.

=over 3

=item Arguments

	Text to be displayed.

=item Returns

	None.

=item Notes

	None.

=back

=cut

sub ShowErrorDialog {
	my ($text) = @_ ;
	&main::Log("Error: $text");
	&std::ShowDialogBox(-bitmap => 'Error', -title => 'Error', -text=>$text, -buttons=>['Continue']);
}

=head2 ShowInfoDialog

	Set up an information dialog.

=over

=item Arguments

	Text to be displayed.

=item Returns

	None.

=item Notes

	None.

=back

=cut

sub ShowInfoDialog {
	my ($text) = @_ ;
	&main::trace("Info: $text");
	&std::ShowDialogBox(-bitmap=>'Info', -title => 'Information', -text=>$text, -buttons=>['Continue']);
}

=head2 ShowWarningDialog

	Set up a warning dialog.

=over

=item Arguments

	Text to be displayed.

=item Returns

	None.

=item Notes

	None.

=back

=cut

sub ShowWarningDialog {
	my ($text) = @_ ;
	&main::Log("Warning: $text");
	&std::ShowDialogBox(-bitmap=>'Warning',-title=>'Warning',-text=>$text,-buttons=>['Continue']);
}

=head2 showMessage

	Show the given message in a modal dialog.

=over

=item Arguments

	- title
	- message to be sent

=item Returns

	Always 1 .

=item Notes

	None.

=back

=cut

sub showMessage {
	my ($hwnd,$title,$message,$buttons) = @_;
	$buttons = [qw/Continue/] unless(defined $buttons);
	my $db = $hwnd->ctkDialogBox(-title => $title,-buttons => $buttons);
	$db->add('Message',-text =>	$message,
				-aspect => 200,
				-justify => 'left',
				-relief => 'ridge',
				-font => 'C_normal',
				-bg => '#FFFFFF',
	-padx => 5, -pady => 5)->pack(-fill => 'x', -expand => 1);

	my $replay = $db->Show();
	return 1
}

=head2 askYN

	Set up a dialog to request the user to accept or dismiss a question.

=over

=item Arguments

=item Returns

	True if the user press the Ok button, false otherwise.

=item Notes

	None.

=back

=cut

sub askYN {
	my $msg = shift;
	my $rv = 0;
	&main::trace("askYn: $msg");
	my $reply=&std::ShowDialogBox(-bitmap=>'question',
							-text=>"$msg",
							-title => 'Decision',
							-buttons => ["Yes", "No"]);
	$rv = 1 if ($reply =~ /^yes/i);
	&main::trace("askYn: ".($rv) ? 'yes' : 'no');
	return $rv;
}

=head2 selectFileForOpen

	Open a modal dialog to select files for subsequent open process.

	Arguments

		- initial file
		- title

	Return

		Selected file or undef on 'cancel'

=cut

sub selectFileForOpen {
	my ($file,$title) = @_;
	$title = 'Project to open' unless( defined($title));
	my $mw = &main::getmw();
	&main::trace("selectFileForOpen");
	my $rv;
	if($^O =~ /(^mswin)|(^$)/i) {			## u MO03603
		$file =~ s/\//\\/g;
		my @types = ( ["Perl files",'.pl'], ["Perl modules",'.pm'],["All files", '*'] );
		$rv = $mw->getOpenFile(-filetypes => \@types,
			-initialfile => $file,
			-defaultextension => '.pl',
			-title=> &_title($title));
	} else {
		$file =~ s/\\/\//g;		## i MO03602
		my $initialDir = ctkFile->head($file);
		$rv = $mw->FileSelect(-directory => $initialDir,
			-initialfile => $file,
			-title=> &_title($title))->Show;
	}
	return $rv
}


=head2 selectFileForSave

	Open a modal dialog to delect files for subsequent save process.

	Arguments

		- initial file
		- title

	Return

	Selected file or undef on 'cancel'

=cut

sub selectFileForSave {
	my ($file,$title) = @_;
	$title = 'Project to save' unless( defined($title));
	my $mw = &main::getmw();
	&main::trace("selectFileForSave");
	my $rv;
	if($^O =~ /(^mswin)|(^$)/i) {			## u MO03603
		$file =~ s/\//\\/g;
		my @types = ( ["Perl files",'.pl'], ["Perl modules",'.pm'],["All files", '*'] );
		$rv = $mw->getSaveFile(-filetypes => \@types,
			-initialfile => $file,
			-defaultextension => '.pl',
			-title=> &_title($title));
	} else {
		$file =~ s/\\/\//g;		## i MO03602
		my $initialDir = ctkFile->head($file);
		$rv = $mw->FileSelect(-directory => $initialDir,
			-initialfile => $file,
			-title=> &_title($title))->Show;
	}
	return $rv
}

=head2 dlg_getSingleValue

=cut

sub dlg_getSingleValue {
	my $hwnd = shift;
	my ($var,$title) = @_; ## init value
	my $rv;
	&main::trace("dlg_getSingleValue");

	$hwnd = &main::getmw() unless(defined($hwnd));
	$title = 'Get Single Variable.' unless defined ($title);
	$var = '' unless defined($var);

	my $db = $hwnd->ctkDialogBox(-title=> &_title($title), -buttons=> ['OK','Cancel']);

	my $w_Frame_001 ;
	my $rW003 ;

	$w_Frame_001 = $db -> Frame ( -borderwidth=>1, -relief=>'ridge' ) -> pack(-anchor=>'nw', -pady=>3, -fill=>'both', -side=>'top', -expand=>1, -padx=>3);
	$rW003 = $w_Frame_001 -> LabEntry ( -textvariable => \$var, -background=>'#ffffff', -label=>'Value', -labelPack=>[-side,'left',-anchor,'n'], -state=>'normal', -width=>32, -justify=>'left', -relief=>'sunken' ) -> pack(-anchor=>'nw', -pady=>10, -fill=>'x', -side=>'top', -expand=>1, -padx=>10);

	&main::recolor_dialog($db);
	$rv =  $db->Show();

	if ($rv =~/ok/i) {
		$rv = $rW003->get();
	} else {
		$rv = undef
	}
	return $rv;
}

=head2 dlg_getWidgetClass

	Get the name of a widget class.

=over

=item Arguments

=item Returns

	None.

=item Notes

	None.

=back

=cut

sub dlg_getWidgetClass {
my $hwnd = shift;
my (%args) = @_;
my $rv;
##
$args{-title} =  'Get widget class' unless exists $args{-title};
my $mw = $hwnd->ctkDialogBox(
		-title=> $args{-title},
		-buttons=> (exists $args{-buttons}) ? $args{-buttons} : ['OK','Cancel']);

## ctk: gcode

## ctk: gcode
## ctk: code generated by ctk_w version '2.019'
## ctk: instantiate and display widgets
my $wM = 0;
foreach (@{$args{-widgets}}) {
	$wM = length if ($wM < length)
}

my $rW001 = $mw -> Frame ( -borderwidth=>1, -relief=>'sunken' ) -> pack(-anchor=>'nw', -fill=>'both', -side=>'top', -expand=>1,-padx, 3, -pady,3);

my $rW002 = $rW001 -> Scrolled ( 'Listbox', -width=>$wM, -selectmode=>'single', -relief=>'sunken', -scrollbars=>'osoe' ) -> pack(-anchor=>'nw', -pady=>3, -fill=>'x', -side=>'top', -expand=>1, -padx=>3);

my $rW003 = $rW001 -> Label ( -justify=>'left', -text=>'Select the widget class.', -relief=>'flat' ) -> pack(-anchor=>'nw', -fill=>'x', -side=>'top', -expand=>1, -padx=>3, -pady => 3);

## ctk: end of gened Tk-code

	map { $rW002->insert('end',$_)} @{$args{-widgets}};

	$rv =  $mw->Show();
	return undef if ($rv =~/Cancel/i);
	my @sel = $rW002->curselection();
	$rv = $args{-widgets}->[$sel[0]];
	return $rv;
}

=head2 dlg_getOrder

	Set up and execute the dialog to enter the metadata element 'order'

=over

=item Arguments

	- widget id,
	- widget class name,
	- existing order

=item Returns

	- new order
	- undef if cancel depressed

=item Notes

	None.

=back

=cut

sub dlg_getOrder {
my $hwnd = shift;
my ($id,$type,$order) = @_;
my $rv = '';
my $height = 4 ;
my $assistent;
##
my $db = $hwnd->ctkDialogBox( -title=> "Get order for $id, $type",-buttons=> ['OK','Cancel','Assistent','Syntax','Help']);

my $rW002 = $db -> Scrolled ( 'TextEdit',-background=>'#ffffff', -width=>60,-height => $height, -relief=>'sunken', -scrollbars=>'osoe' ) -> pack(-anchor=>'nw', -pady=>5, -fill=>'both', -side=>'top', -expand=>1, -padx=>5);

	$rW002->insert('end',$order);
	$rW002->SetGUICallbacks ([]);
	$db->Subwidget('B_Assistent')->configure(-command => [sub {
						my ($parent, $target) = @_;
						if (defined $assistent) {
							return undef if (Tk::Exists($assistent->_toplevel()))
						} else {}
						$assistent = ctkAssistent->new(-parent,$parent);
						$assistent->target($target);
						$assistent->selection([$target->tagRanges('sel')]);
						$assistent->insertion($target->index('insert'));
						$assistent->Show();
						return 1
						},$db,$rW002]);
	$db->bind('<Return>','');
	$rW002->focus();

	while ($rv !~ /^(OK|Cancel)/i) {
		$rv = $db->Show();
		if ($rv =~ /Syntax/i) {
			my $code = $rW002->get('1.0','end');
			eval "$code" ;
			if ($@ =~/^\s*$/) {
				&std::ShowInfoDialog("Syntax is OK")
			} else {
				&std::ShowWarningDialog("Syntax check:\n\n'$@'")
			}
		} elsif ($rv =~ /Help/i) {
			&std::showMessage($db,'Help',"An order is a snipped of code that is inserted right after the contructor of the widget.\nTypically it sends a configure messages to widgets.\n\nActually it can contains only messages to widgets, so each line should starts with a valid ref to a widget.");
		} elsif ($rv =~/Cancel/i) {
			$db->destroy();
			return undef
		} elsif ($rv =~/ok/i) {
			last;
		} else {}
	}
	$rv = $rW002->get('1.0','end');
	my $w = 0;
	foreach (split(/\n/, $rv)) {
		next if (/^\s*$/);
		$w++ unless (/^\s*\$\w+/)
	}
	$db->destroy();
	&std::ShowWarningDialog("One or more lines do not contain message to widgets,\n\npls check this order before save.") if($w);
	return $rv;
}

sub dlg_selectFromList {
my $hwnd = shift;
my (%args) = @_;
my $rv;
$args{-title}= 'Select from List' unless exists $args{-title};
my $mw = $hwnd->ctkDialogBox(
	-title=> $args{-title},
	-buttons=> (exists $args{-buttons}) ? $args{-buttons} : ['OK','Cancel']);
$mw->protocol('WM_DELETE_WINDOW',sub{1});
my $wr_002 ;


$wr_002 = $mw -> Scrolled('Listbox', -scrollbars => 'osoe',
			-background , '#ffffff' , -selectmode , 'extended' , -relief , 'sunken'  ) -> pack(-side=>'top', -anchor=>'nw', -pady=>2, -fill=>'both', -expand=>1, -padx=>2);

if (exists $args{-list}) {
	map {
		$wr_002->insert('end',$_);
	} sort @{delete $args{-list}};
}

$rv =  $mw->Show();

if ($rv =~ /OK/i) {
	$rv =[];
	my @sel = $wr_002->curselection();
	map {
		my $var = $wr_002->get($_);
		push @$rv,$var
	} @sel;
} else {
	$rv =[];
}
 return wantarray ? @$rv : scalar(@$rv);

} ## end of dlg_selectFromList

sub ask_new_nonVisual {
	my ($w_attr) = @_;
	&main::trace("ask_new_nonVisual");
	my $se;
	my $type='';
	do {
		my $db=main::getmw()->ctkDialogBox(
			-title=> "New non visual-class",
			-buttons=>['Proceed','Cancel']);
		$db->LabEntry(-textvariable=>\$type,-labelPack=>[-side=>'left',-anchor=>'w'],
						-label=>'Class name')->pack(-pady=>20,-padx=>30);
		$db->resizable(1,0);
		&main::recolor_dialog($db);
		return undef  if($db->Show() eq 'Cancel');

		$type =~ s/^\s+//; $type =~ s/\s+$//;
		if (exists $w_attr->{$type}) {
			if (main::nonVisual($type)) {
				&std::ShowWarningDialog("Entered type accepted although it already exists,\npls check.");
				last
			} else {
				&std::ShowErrorDialog("Entered type already exists and is not a non-visual calss,\npls check and reenter.");
			}
			$se = 1
		} else {
			eval "my \$$type = 0;";
			if ($@) {
				&main::trace("eval syntax error checking '$type':", $@);
				&std::ShowErrorDialog("Syntax error,\n entered type is invalid,\n\npls correct.");
				$se = 1;
			} else {
				$se = 0
			}
		}
	} while($se || exists $w_attr->{$type} || $type =~ /^\s*$/);
	&main::trace("class name = '$type'");
	return $type;
}

sub _viewCode {
	my ($t) =@_;

	my $code = &main::gen_TkCode();
	my $tok;
	foreach my $line(@$code) {
		if ($line =~ /^\s*$/) {
			$t->insert ('end',"\n");
			next
		}
		if($line =~ /^(\s*)(my|local|our|use|require|eval)\s+/) {
			$tok = $2;
			$t->insert('end',"$1$tok ",'keyword'); ## add other keyword like for, next, ...
			$line =~ s/^\s*$tok\s+//;
		}

		while(length($line)) {
			if ($line=~/^(\s+)/) {
				$tok =$1;
				$t->insert('end',$tok);
				$line = substr($line,length($tok));
			} elsif ($line=~/^([\$%@*]\w+)/) {
				$tok=$1;
				$t->insert('end',$tok,'variable');
				$line = substr($line,length($tok));
			} elsif ($line=~/^(::\w+)/) {
				$tok=$1;
				$t->insert('end',$tok,'variable');
				$line = substr($line,length($tok));
			} elsif ($line=~/^([\$%@]\$\w+)/) {
				$tok= $1;
				$t->insert('end',$tok,'variable');
				$line = substr($line,length($tok));
			} elsif ($line=~/^('[^']*')/) {
				$tok=$1;
				$t->insert('end',$tok,'constant');
				$line = substr($line,length($tok));
			} elsif ($line=~/^("[^"]*")/) {
				$tok=$1;
				$t->insert('end',$tok,'constant');
				$line = substr($line,length($tok));
			} elsif ($line=~/^(-\w+|'[^']*')/) {
				($tok)=$1;
				$t->insert('end',$tok,'keyword');
				$line = substr($line,length($tok));
			} elsif ($line=~/^(\s*(?:->)?[^-\$']+)/){
				($tok)= $1;
				$line = substr($line,length($tok));
				$tok =~ s/->\s*/->\n  /;
				$t->insert('end',$tok);
			} else {
				$t->insert('end',$line);
				$line = '';
			}
		}
		$t->insert('end', "\n");
	}
	$t->mark(qw/set insert 0.0/);
}

sub viewCode {
	my ($hwnd,$lastFile) = @_;

	my $db=$hwnd->Toplevel(-title =>  &_title("Code preview - $lastFile"));
	&main::recolor_dialog($db);
	my $t = $db->Scrolled('ROText', -scrollbars => 'osoe',
							-wrap => 'none',
							-background => 'white',
							-font => 'C_normal'
							);
	$t->pack(qw/-expand 1 -fill both/);

	my $f2 = $db->Frame()->pack(qw/-expand 1 -fill x/);

	$f2->Button(-text => 'Close', -command => sub{$db->destroy})->pack(qw/-side left -anchor nw -expand 1 -fill x/) ;
	$f2->Button(-text => 'Refresh', -command => sub{$t->delete('1.0','end');&std::_viewCode($t)})->pack(qw/-side left -anchor nw -expand 1 -fill x/) ;

	$t->tag(qw/configure variable -foreground darkgreen/);
	$t->tag(qw/configure keyword -foreground blue -font C_bold/);
	$t->tag(qw/configure constant -foreground violetRed2/);
	$t->tag(qw/configure ctkdelimiter -foreground gray/);
	&std::_viewCode($t);
	$db->resizable(1,0);
	return 1
}

sub dlg_getApplicationParms {
	my $hwnd = shift;
	my ($w1,$w2) = @_;
	my $rv;
	my $mw = $hwnd->ctkDialogBox(
		-title=> 'Get application\'s parameters',
		-buttons=> [qw/OK Cancel/]);
	$mw->protocol('WM_DELETE_WINDOW',sub{1});

	my $wr_001 ;
	my $wr_003 ;
	my $wr_002 ;
	my $wr_005 ;

	$wr_001 = $mw -> LabEntry ( -background , '#ffffff' , -label , 'Name' , -labelPack , [-side=>'left',-anchor=>'n'] , -state , 'normal' , -justify , 'left' , -relief , 'sunken' , -textvariable , $w1  ) -> pack(-anchor=>'nw', -side=>'top', -pady=>5, -fill=>'x', -expand=>1, -padx=>5);
	$wr_003 = $mw -> Frame ( -relief , 'solid'  ) -> pack(-anchor=>'nw', -side=>'top', -pady=>5, -fill=>'x', -expand=>1, -padx=>5);
	$wr_002 = $wr_003 -> LabEntry ( -background , '#ffffff' , -label , 'Folder' , -labelPack , [-side=>'left',-anchor=>'n'] , -state , 'normal' , -justify , 'left' , -relief , 'sunken' , -textvariable , $w2  ) -> pack(-anchor=>'nw', -side=>'left', -pady=>5, -fill=>'x', -expand=>1, -padx=>5);
	$wr_005 = $wr_003 -> Button ( -background , '#ffffff' , -state , 'normal' , -relief , 'raised' , -text , 'Browse'  ) -> pack(-anchor=>'nw', -side=>'left', -pady=>5, -padx=>5);
	$wr_005->configure(-command, [sub{&ctkDirDialog::dirDialogModal->Show},"Select application's folder", '.',$wr_002]);

	$rv =  $mw->Show() ;
	$rv = ($rv =~ /ok/i) ? 1 : 0;
	return $rv;
} ## end of dlg_getApplication

=head2 dlg_selectCursor

	Obsolete see required script selectCursor.pl

=cut

sub dlg_selectCursor {
my $hwnd = shift;
my %args =();
my $rv;
$args{-title}= 'Select cursor.' unless exists $args{-title};
##
## ctk: Localvars
## ctk: Localvars end
##
my $mw = $hwnd->ctkDialogBox(
	-title=> $args{-title},
	 -buttons=> (exists $args{-buttons}) ? $args{-buttons} : ['OK','Cancel']);
$mw->protocol('WM_DELETE_WINDOW',sub{1});


## ctk: code generated by ctk_w version '3.099'
## ctk: instantiate and display widgets

my $wr_001 = $mw -> Scrolled ( 'Listbox' , -background , '#ffffff' , -selectmode , 'single' , -relief , 'sunken' , -scrollbars , 'e'  ) -> pack(-anchor=>'nw', -side=>'top', -pady=>5, -fill=>'both', -expand=>1, -padx=>5);
&dlg_selectCursorInit($wr_001);

my $wr_002 = $mw -> Button ( -background , '#ffffff' , -command , [\&_testCursor , $wr_001 ] , -state , 'normal' , -relief , 'raised' , -text , 'Test cursor'  ) -> pack(-side=>'top', -anchor=>'nw', -pady=>5, -fill=>'both', -expand=>1, -padx=>5);


## ctk: end of gened Tk-code

$rv =  $mw->Show();

if ($rv =~/^OK/i) {
		my @sel = $wr_001->curselection();
		$rv = $wr_001->get($sel[0]);
} else {
		undef $rv
}

return $rv;

} ## end of dlg_selectCursor

## ctk: end of dialog code
## ctk: callbacks
sub dlg_selectCursorInit {
my ($lb) = @_;
my @cursors = (qw/X_cursor
arrow
based_arrow_down
based_arrow_up
boat
bogosity
bottom_left_corner
bottom_right_corner
bottom_side
bottom_tee
box_spiral
center_ptr
circle
clock
coffee_mug
cross
cross_reverse
crosshair
diamond_cross
dot
dotbox
double_arrow
draft_large
draft_small
draped_box
exchange
fleur
gobbler
gumby
hand1
hand2
heart
icon
iron_cross
left_ptr
left_side
left_tee
leftbutton
ll_angle
lr_angle
man
middlebutton
mouse
num_glyphs
pencil
pirate
plus
question_arrow
right_ptr
right_side
right_tee
rightbutton
rtl_logo
sailboat
sb_down_arrow
sb_h_double_arrow
sb_left_arrow
sb_right_arrow
sb_up_arrow
sb_v_double_arrow
shuttle
sizing
spider
spraycan
star
target
tcross
top_left_arrow
top_left_corner
top_right_corner
top_side
top_tee
trek
ul_angle
umbrella
ur_angle
watch
xterm/);
map { $lb->insert('end',$_) } @cursors;
}
sub _testCursor {
	my ($lb) = @_;
	my $cursor = $lb->toplevel->cget(-cursor);
	my $x = $lb->curselection();
	if ($x) {
		my $tl = $lb->toplevel;
		$tl->configure(-cursor, $lb->get($x));
		$tl->update();
		$tl->Busy();
		sleep 3;
		$tl->Unbusy();
		$tl->configure(-cursor, $cursor);
		$tl->update();
	} else {}
}


sub dlg_codeOptions {
	my ($hwnd) = shift;
	my ($file_opt)= @_;

	&main::trace("dlg_codeOptions");

	$hwnd = &main::getmw() unless(defined($hwnd));

	my $db = $hwnd->ctkDialogBox(-title=>'Edit options',-buttons=>['Ok','Cancel']);
	my @p0=(qw/-sticky we -padx 2 -pady 2 -column 0/);
	my @p1=(qw/-sticky we -padx 2 -pady 2 -column 1/);
	my (%new_file_opt) = (%$file_opt);

	my $frm0 =$db->LabFrame(-labelside=>'acrosstop',-label=>'Target type')->pack(-side => 'top', -anchor => 'nw', -expand => 1, -fill => 'both', -padx => 5, -pady => 5);
	my $row = 0;
	$frm0->Radiobutton(-text=>'Subroutine',-anchor=>'w', -variable=>\$new_file_opt{'code'}, -value=> 0)->grid(@p1, -row => 0);
	$frm0->Radiobutton(-text=>'Script',-anchor=>'w', -variable=>\$new_file_opt{'code'}, -value=> 1)->grid(@p1, -row => 1);
	$frm0->Radiobutton(-text=>'Package',-anchor=>'w', -variable=>\$new_file_opt{'code'}, -value=> 2 )->grid(@p1, -row => 2);
	$frm0->Radiobutton(-text=>'Composite', -anchor=>'w', -variable=>\$new_file_opt{'code'}, -value=> 3 )->grid(@p1, -row => 3);
	my $frm1=$db->LabFrame(-labelside=>'acrosstop',-label=>'Options')
	  ->pack(-side => 'top', -anchor => 'nw', -expand => 1, -fill => 'both', -padx => 5, -pady => 5);
	my $frm2=$frm1->Frame()->pack(-side => 'top', -anchor => 'nw', -expand => 1, -fill => 'both', -padx => 5, -pady => 5);
	my $frm3 = $frm1->Frame()->pack(-side => 'top', -anchor => 'nw', -expand => 1, -fill => 'both', -padx => 5, -pady => 5);
	my $frm4 = $frm1->Frame()->pack(-side => 'top', -anchor => 'nw', -expand => 1, -fill => 'both', -padx => 5, -pady => 5);

	$row=0;
	$frm2->Label(-text=>'Description:',-anchor=>'w')->grid(@p0,-row=>$row);
	$frm2->Entry(-width=>45, -bg => 'white', -textvariable=>\$new_file_opt{'description'})->grid(@p1,-row=>$row++);
	$frm2->Label(-text=>'Title:',-anchor=>'w')->grid(@p0,-row=>$row);
	$frm2->Entry(-width=>45, -bg => 'white', -textvariable=>\$new_file_opt{'title'})->grid(@p1,-row=>$row++);

	$frm2->Label(-text=>'onDeleteWindow:',-anchor=>'w')->grid(@p0,-row=>$row);
	$frm2->Entry(-width=>32, -bg => 'white', -textvariable=>\$new_file_opt{'onDeleteWindow'})->grid(@p1,-row=>$row++);
	$frm2->Label(-text=>'Subroutine name:',-anchor=>'w')->grid(@p0,-row=>$row);
	$frm2->Entry(-width=>32, -bg => 'white', -textvariable=>\$new_file_opt{'subroutineName'})->grid(@p1,-row=>$row++);
	$frm2->Label(-text=>'Subroutine argList:',-anchor=>'w')->grid(@p0,-row=>$row);
	$frm2->Entry(-width=>32, -bg => 'white', -textvariable=>\$new_file_opt{'subroutineArgs'})->grid(@p1,-row=>$row++);
	$frm2->Label(-text=>'Modal dialog:',-anchor=>'w')->grid(@p0,-row=>$row);
	$frm2->Entry(-width=>32, -bg => 'white', -textvariable=>\$new_file_opt{'modalDialogClassName'})->grid(@p1,-row=>$row++);
	$frm2->Label(-text=>'Buttons:',-anchor=>'w')->grid(@p0,-row=>$row);
	$frm2->Entry(-width=>32, -bg => 'white', -textvariable=>\$new_file_opt{'buttons'})->grid(@p1,-row=>$row++);
	$frm2->Label(-text=>'Base class:',-anchor=>'w')->grid(@p0,-row=>$row);
	$frm2->Entry(-width=>32, -bg => 'white', -textvariable=>\$new_file_opt{'baseClass'})->grid(@p1,-row=>$row++);

	$frm3->Button(-text=>'Advertise',-relief => 'raised',
		-command => [sub{
			my $hwnd= shift;
			return undef unless $new_file_opt{'code'} == 3;
			my $a = &std::dlg_getAdvertisedWidgets($hwnd,\%new_file_opt);
			$new_file_opt{'subWidgetList'} = $a if(defined ($a));
			&main::trace("$a");
			},$db],-bg => '#FFFFFF')->pack(-side, 'left', -expand ,1 , -fill , 'x');
	$frm3->Button(-text=>'ConfigSpecs',-relief => 'raised',
		-command => [sub{
			my $hwnd = shift;
			return undef unless $new_file_opt{'code'} == 3;
			my $a = $hwnd->ctkDlgConfigSpec(-buttons =>[qw/Ok Cancel/]);
			my $w = exists $new_file_opt{'ConfigSpecs'} ? $new_file_opt{'ConfigSpecs'} : '{}';
			$w = eval "$w";
			$a->optionsList($w);
			my $reply = $a->Show();
			if ($reply =~ /ok/i) {
				$new_file_opt{'ConfigSpecs'} = ctkBase->dump($a->optionsList);
				&main::trace("ConfigSpecs = ".$new_file_opt{'ConfigSpecs'})
			} else {}
			},$db],-bg => '#FFFFFF')->pack(-side, 'left', -expand ,1 , -fill , 'x');
	$frm3->Button(-text=>'Delegates',-relief => 'raised',
		-command => [sub{
			my $hwnd = shift;
			return undef unless $new_file_opt{'code'} == 3;
			my $a = $hwnd->ctkDlgDelegate(-buttons =>[qw/Ok Cancel/]);
			my $w = exists $new_file_opt{'Delegates'} ? $new_file_opt{'Delegates'} : '{}';
			$w = eval "$w";
			$a->delegateList($w);
			my $reply = $a->Show();
			if ($reply =~ /ok/i) {
				$new_file_opt{'Delegates'} = ctkBase->dump($a->delegateList);
				&main::trace("Delegates = ".$new_file_opt{'Delegates'});
				} else {}
			},$db],-bg => '#FFFFFF')->pack(-side, 'left', -expand ,1 , -fill , 'x');
	$row = 0;
	$frm4->Checkbutton(-text=>'Widget tree walk DF',-justify=>'left',-anchor=>'w',
	  -variable=>\$new_file_opt{'treewalk'}, -offvalue, 'B', -onvalue, 'D')->grid(@p0,-row=>$row++);

	$frm4->Checkbutton(-text=>'Modal dialog',-justify=>'left',-anchor=>'w',
	  -variable=>\$new_file_opt{'modal'})->grid(@p0,-row=>$row++);

	$frm4->Checkbutton(-text=>'Generate Toplevel widget',-justify=>'left',-anchor=>'w',
	  -variable=>\$new_file_opt{'Toplevel'})->grid(@p0,-row=>$row++);
	$frm4->Checkbutton(-text=>'Extract variables from widget options',-justify=>'left',-anchor=>'w',
	  -variable=>\$new_file_opt{'autoExtractVariables'})->grid(@p0,-row=>$row++);
	$frm4->Checkbutton(-text=>'Extracted variables become local',-justify=>'left',-anchor=>'w',
	  -variable=>\$new_file_opt{'autoExtract2Local'})->grid(@p0,-row=>$row++);
	$frm4->Checkbutton(-text=>'Use strict output syntax',-justify=>'left',-anchor=>'w',
	  -variable=>\$new_file_opt{'strict'})->grid(@p0,-row=>$row++);

	$db->resizable(1,0);
	&main::recolor_dialog($db);
	my $reply;
	while(1) {
		my $reply=$db->Show();
		return undef if $reply eq 'Cancel';
		if ($new_file_opt{'onDeleteWindow'} =~ /^\s*$/) {
			last
		} elsif ($new_file_opt{'onDeleteWindow'} =~ /^\s*none\s*$/i) {
			main::Log("onDeleteWindow explicitly suppressed.");
			last
		} elsif (&main::checkCallbackOption($new_file_opt{'onDeleteWindow'})) {
			main::Log("onDeleteWindow option is OK");
			last
		} else {
			last if ($new_file_opt{'onDeleteWindow'} =~/^\s*sub\{\s*1\s*\}\s*$/);
			&std::ShowWarningDialog("Could not recognize format of onDeleteWindow callback,\npls correct.");
			next
		}
	}
	(%$file_opt) = (%new_file_opt);
	return 1
}

sub dlg_geomInfo {
	my $hwnd = shift;
	my (%args) = @_;
	&main::trace("dlg_geomInfo");
	my $rv;
	my $info = $args{info};
	my $mw = $hwnd->ctkDialogBox(
  		 -title=> (exists $args{title})? $args{title}:"View gemetry manager's info.",
  		 -buttons=> (exists $args{buttons}) ? $args{buttons} : ['OK']);
	my $w_Frame_001 = $mw -> Frame () -> pack(-anchor=>'nw', -fill=>'both', -side=>'top', -expand=>1);

	my $w_ScrolledROText_002 = $w_Frame_001 -> Scrolled ( 'ROText',-background=>'#ffffff', -state=>'normal', -relief=>'sunken', -scrollbars=>'se', -wrap=>'none' ) -> pack(-anchor=>'nw', -fill=>'both', -side=>'top', -expand=>1);

	my $x = 0;
	my $line;
	map {
		$x %= 2;
		$line = '' unless($x);
		$line .= "\t$_";
		$w_ScrolledROText_002->insert('end',"$line\n") if ($x);
		$x++;
	} @$info;

	$mw->bind('<Return>','');

	$rv =  $mw->Show();

 	return $rv;

}

sub _refreshLogView {
	my ($t,$fName) = @_;
	&main::trace("refreshLogView");
	$t->delete('0.1','end');
	map {
		$t->insert('end',"$_\n");
	} @main::cacheLog;
	$t->see('end');
	return 1;
}

sub dlg_viewLogFile {
	my ($hwnd,$fName) = @_;
	&main::trace("dlg_viewLogFile");

	$hwnd = &main::getmw unless defined $hwnd;
	$fName = $main::ctkLogFileName unless defined $fName;

	use Tk::ROText;
	use Tk::Font;

	$hwnd->fontCreate('C_normal',qw/-family courier -weight normal -size 11/) unless (&std::fontExists($hwnd,'C_normal'));

	my $tl = $hwnd->Toplevel(-title => &std::_title("log file '$fName'"));

	my $f1 = $tl->Frame()->pack(-side => 'top',-anchor => 'nw', -expand => 1, -fill => 'both');
	my $f2 = $tl->Frame()->pack(-side => 'bottom',-anchor => 'sw', -expand => 1, -fill => 'x');

	my $t = $f1->Scrolled('ROText', -bg => '#EEEEEE',-font => 'C_normal'
		)->pack(-side => 'top',-anchor => 'nw', -expand => 1, -fill => 'both');
	my $r = $f2->Button(-text => 'Refresh',-bg => 'white',
		-command => [\&_refreshLogView,$t,$fName])->pack(-side => 'left',-anchor => 'nw', -expand => 1, -fill => 'x');

	my $c = $f2->Button(-text => 'Close',-bg => 'white',
		-command => sub{$tl->DESTROY()})->pack(-side => 'left',-anchor => 'nw', -expand => 1, -fill => 'x');

	&_refreshLogView($t,$fName);
	return 1;
	}


sub dlg_getVariables {
my $hwnd = shift;
my (%args) = @_;
my $rv;

return $rv if (&exists_getVariableDialog);

my $mw = $hwnd->Toplevel();
   $mw->configure(-title=> &std::_title((exists $args{title})? $args{title}:'Get variables'));

my $rTopFrame ;
my $rW006 ;
my $rBottomFrame ;
my $rW018 ;
my $rLeftFrame ;
my $rW025 ;
my $rW026 ;
my $rW012 ;
my $rW013 ;
my $rW016 ;
my $rW024 ;
my $rRightFrame ;
my $rW021 ;
my $rW013x ;
my $rW019 ;
my $rW014x ;
my $rW020 ;
my $rW014 ;
my $rW027 ;

## ctk: instantiate and display widgets

$rTopFrame = $mw -> Frame ( -relief=>'flat' ) -> pack(-anchor=>'nw', -side=>'top', -fill=>'x', -expand=>1);
$rW006 = $rTopFrame -> Label ( -background=>'#ffcaca', -justify=>'left', -relief=>'flat', -text=>'Enter variables' ) -> pack(-anchor=>'nw', -side=>'top', -fill=>'x', -expand=>1);
$rBottomFrame = $mw -> Frame ( -borderwidth=>1, -relief=>'ridge' ) -> pack(-anchor=>'sw', -side=>'bottom', -fill=>'x', -expand=>1);
$rW018 = $rBottomFrame -> Label ( -background=>'#ff8080', -justify=>'left', -text=>'Ready', -relief=>'flat' ) -> pack(-anchor=>'sw', -side=>'left', -fill=>'x', -expand=>1);
$rLeftFrame = $mw -> LabFrame ( -borderwidth=>1, -label=>'Global variables', -relief=>'ridge', -labelside=>'acrosstop' ) -> pack(-anchor=>'nw', -side=>'left', -fill=>'both', -expand=>1);
$rW025 = $mw -> Frame ( -relief=>'flat' ) -> pack(-anchor=>'nw', -side=>'left', -fill=>'y', -expand=>1);
$rW026 = $rW025 -> Button ( -command => sub{&main::moveLocal2Global($rW020,$rW024)}, -background=>'#ffffff', -text=>'Move to Global', -state=>'normal' ) -> pack(-anchor=>'center', -side=>'top', -pady=>5, -fill=>'x', -expand=>1, -padx=>5);
$rW012 = $rLeftFrame -> Frame ( -relief=>'flat' ) -> pack(-anchor=>'sw', -side=>'bottom', -fill=>'x', -expand=>1);
$rW013 = $rW012 -> Button ( -command => sub{&main::addGlobal($rW024)},-background=>'#ffffff', -text=>'Add', -state=>'normal' ) -> pack(-anchor=>'nw', -side=>'left', -fill=>'x', -expand=>1);
$rW016 = $rW012 -> Button ( -command => sub{&main::editGlobal($rW024)},-background=>'#ffffff', -text=>'Edit', -state=>'normal' ) -> pack(-anchor=>'nw', -side=>'left', -fill=>'x', -expand=>1);
$rW014 = $rW012 -> Button ( -command => sub{&main::deleteGlobal($rW024)}, -background=>'#ffffff', -text=>'Delete', -state=>'normal' ) -> pack(-anchor=>'nw', -side=>'left', -fill=>'x', -expand=>1);
$rW024 = $rLeftFrame -> Scrolled ( 'Listbox', -background=>'#ffffff', -selectmode=>'single', -relief=>'sunken', -scrollbars=>'se' )->pack(-side => 'top', -anchor =>  'nw', -expand => 1, -fill => 'both');
$rRightFrame = $mw -> LabFrame ( -borderwidth=>1, -label=>'Local variables', -relief=>'ridge', -labelside=>'acrosstop' ) -> pack(-anchor=>'ne', -side=>'right', -fill=>'both', -expand=>1);
$rW021 = $rRightFrame -> Frame ( -relief=>'flat' ) -> pack(-anchor=>'sw', -side=>'bottom', -fill=>'x', -expand=>1);
$rW013x = $rW021 -> Button (-command => sub{&main::addLocal($rW020)}, -background=>'#ffffff', -text=>'Add', -state=>'normal' ) -> pack(-anchor=>'nw', -side=>'left', -fill=>'x', -expand=>1);
$rW019 = $rW021 -> Button ( -command => sub{&main::editLocal($rW020)},-background=>'#ffffff', -text=>'Edit', -state=>'normal' ) -> pack(-anchor=>'nw', -side=>'left', -fill=>'x', -expand=>1);
$rW014x = $rW021 -> Button ( -command => sub{&main::deleteLocal($rW020)},-background=>'#ffffff', -text=>'Delete', -state=>'normal' ) -> pack(-anchor=>'nw', -side=>'left', -fill=>'x', -expand=>1);
$rW020 = $rRightFrame -> Scrolled ( 'Listbox',-background=>'#ffffff', -selectmode=>'single', -relief=>'sunken', -scrollbars=>'se' )->pack(-side => 'top', -anchor =>  'nw', -expand => 1, -fill => 'both');
$rW027 = $rW025 -> Button ( -command => sub{&main::moveGlobal2Local($rW024,$rW020)},-background=>'#ffffff', -text=>'Move to local', -state=>'normal' ) -> pack(-anchor=>'center', -side=>'bottom', -pady=>5, -fill=>'x', -expand=>1, -padx=>5);

## ctk: end of gened Tk-code

	@ctkProject::user_auto_vars = sort @ctkProject::user_auto_vars;
	@ctkProject::user_local_vars = sort @ctkProject::user_local_vars;
	&main::changes(1); # can't store undo info so far!

	map {
		$rW024->insert('end',$_)
	} @ctkProject::user_auto_vars;
	map {
		$rW020->insert('end',$_)
	} @ctkProject::user_local_vars;
		$Toplevel_getVariable = $mw;
	$mw->protocol('WM_WINDOWS_DELETE',sub{$Toplevel_getVariable->destroy;$Toplevel_getVariable = undef;});
	return $rv;
} ## end of dlg_getVariables

sub dlg_getAdvertisedWidgets {
	my $hwnd = shift;
	my ($file_opt) = @_;
	my $rv;
	&main::trace("dlg_getAdvertisedWidgets");
	my $subWidgets = $file_opt->{'subWidgetList'};

	my @wList = sort &main::getWidgetIdList();

	my $mw = $hwnd->ctkDialogBox(-title=> 'Advertised subwidgets',-buttons=> ['OK','Cancel']);
	my $tl = $mw->Scrolled('Tiler', -columns => 1, -rows => 6, -scrollbars=>'oe')->pack();
	my ($x,$w);
	my @aList = ();
	my $width = length($wList[0]);
	map {
		my $w = $_;
		my @a = grep ($w eq $_->{ident},@$subWidgets);
		push @aList, (@a) ? $a[0] : {name => '',public => '', ident => $w};
		$width = length($w) if (length($w) > $width);
	} @wList;

	for (my $i = 0 ; $i <= $#aList; $i++) {
		my $f = $mw->Frame(-borderwidth => 1, -relief => 'flat')->pack(-padx => 5, -pady => 2,-ipadx => 5, -ipady => 2);
		$x = "{-state=>'normal', -justify=>'left',-anchor => 'nw', -width => $width, -padx => 1,-text=>\$aList[$i]->{ident}, -relief=>'flat', -variable=>\\\$aList[$i]->{public} } ";
		$w = eval "\$w = $x";
		next if ($@);
		$f->Checkbutton(%$w)-> grid(-row=>0, -column=>0, -sticky=>'nw');
		$x = "{-textvariable =>\\\$aList[$i]->{name}, -state=>'normal', -justify=>'left', -relief=>'sunken' , -width => $width}";
		$w = eval "\$w = $x";
		next if ($@);
		$f -> Entry (%$w) -> grid(-row=>0, -column=>1, -sticky=>'nw');
		$tl->Manage($f);
		}
	$rv = $mw->Show();
	return undef unless ($rv =~ /ok/i);
	for (my $i = scalar(@aList)-1; $i >= 0; $i--) {
		if ($aList[$i]->{public}) {
			$aList[$i]->{name} = $aList[$i]->{ident} unless ($aList[$i]->{name});
		} else {
			splice @aList,$i,1 ;
		}
	}
	return wantarray ? @aList : \@aList
}

sub dlg_about {
	&main::trace("dlg_about");
	my $d = &main::getmw->ctkDialogBox(-title=>'About');
	my $fName = &main::getImageFolder.ctkFile->FS.'ctkAbout.gif';
	my $photo;
	$photo = &main::getmw->Photo(-file => $fName) if (-f $fName);
	my ($v,$r,$m) = $main::VERSION =~/(\d)\.(\d)(\d+)/;
	$d->Label(-text=>&main::ctkTitle."\nVersion $v  Release $r Modification $m")->pack();
	if(defined($photo)) {
		$d->Label(-image=>$photo)->pack();
	} else {
		$d->Label(-text => 'Standard edition')->pack();
	}
	$d->resizable(0,0);
	&main::recolor_dialog($d);
	return $d;
}

sub dlg_ask_new_id {
	my ($id,$type) = @_;
	my $rv;
	my $db = &main::getmw->ctkDialogBox(-title=>"Ident for $type widget",-buttons=>['Proceed','Cancel']);
	$db->LabEntry(-textvariable=>\$id,
			-labelPack=>[-side=>'left',-anchor=>'w'],
			-label=>'Widget ident ')->pack(-pady=>20,-padx=>30);
	$db->resizable(1,0);
	&main::recolor_dialog($db);
	$rv = $db->Show();
	$rv = ($rv =~ /cancel/i) ? undef : $id;
	return $rv;
}


=head2 pickColor

=cut

sub pickColor {
my ($hwnd) = @_;
	&main::trace("pickColor");
	$hwnd = &main::getmw unless(defined($hwnd));
	my $MW = &main::getMW;
	my @cursor = qw(top_left_arrow);
	my $w = $hwnd->ColorEditor(-title => std::_title('Select color'), -cursor => @cursor);

	$w->configure(-widgets => [$ctkPreview::widgets{$MW}->Descendants]);

	my $wColor = $w->Show();
	&main::trace("wColor = '$wColor'");
	return $wColor;
}

=head2 getColor

=cut

sub getColor {
my ($hwnd, $title) = @_;
	&main::trace("getColor");
	$hwnd = &main::getmw unless(defined($hwnd));
	my $wColor = $hwnd->chooseColor(-title => std::_title("Select color for $title"), -initialcolor => 'white',-parent => $hwnd);
	&main::trace("wColor = '$wColor'") if (defined($wColor));
	return $wColor
}

=head2 ColorPicker

=cut

sub ColorPicker {
	my($f,$text,$p,$checkbutton) = @_;

	&main::trace("ColorPicker");

	my $cl=$f->Menubutton(-text=>$text,-relief=>'raised')
	  ->pack(-side=>'right', -padx => 2, -fill => 'x', -expand => 1);
	my $m = $cl->Menu(qw/-tearoff 0/);
	my $var=($$p)?1:0;
	my $i=1;

	foreach (qw/Brown Red pink wheat2 orange Yellow DarkKhaki
				LightSeaGreen Green DarkSeaGreen
				green4 DarkGreen
				Cyan LightSkyBlue Blue NavyBlue plum
				magenta1 Magenta3 purple3
				White
				gray90 gray75 gray50
				Black/) {
		$m->command(-label => $_, -columnbreak=>(($i-1) % 5)?0:1,
					-command => [sub{$$p=shift;$var=1;$cl->configure(-background=>$$p)},$_]);

	  my $i1 = $m->Photo(qw/-height 16 -width 16/);

	  $i1->put(qw/gray50 -to 0 0 16 1/);
	  $i1->put(qw/gray50 -to 0 1 1 16/);
	  $i1->put(qw/gray75 -to 0 15 16 16/);
	  $i1->put(qw/gray75 -to 15 1 16 15/);
	  $i1->put($_, qw/-to 1 1 15 15/);
	  $m->entryconfigure($i, -image => $i1);
	  $i++;
	}
	$cl->configure(-menu => $m);
	$cl->configure(-background=>$$p) if $$p;
	if ($checkbutton) {
		$f->Checkbutton(-text => 'enabled',
						-relief => 'solid',-variable=>\$var,-borderwidth=>0,
						-command => sub{ $$p = '' unless $var; }
						)->pack(-side=>'right', -padx=>7);
	}
}

=head2 color_Picker

=cut

sub color_Picker {
	&main::trace("color_Picker");
	if ($main::opt_colorPicker) {
		&std::ColorPicker(@_);
	} else {
		my($f,$text,$p,$checkbutton) = @_;
		my $var = ($$p) ? 1 : 0;

		$f->Button(-text => $text , - relief => 'raised',
					-command => sub {
							my $color = &std::getColor($f,$text);
							$$p = $color if(defined($color))
							})->pack(-side=>'right', -padx=>2);
		if($checkbutton) {
			$f->Checkbutton(-text => 'enabled',
							 -relief => 'solid',-variable=>\$var,-borderwidth=>1,
							 -command => sub{ $$p='' unless $var; }
							)->pack(-side=>'right', -padx=>7);
		} ## else {}
	}
	return 1;
}

sub dlg_recolorMySelf {
	my ($mw,$bg_color,$fg_color) = @_;
	my $db=$mw->ctkDialogBox(-title=>'Choose color scheme',
			-buttons=>[qw/Ok Default Dismiss/]);
	my $f;
	$f=$db->Frame->pack( -padx => 5, -pady => 5);
	&color_Picker($f,'Background',$bg_color,0);
	$f=$db->Frame->pack( -padx => 5, -pady => 5);
	&color_Picker($f,'Foreground',$fg_color,0);
	&main::recolor_dialog($db);
	my $reply =$db->Show;
	return $reply
}

1; ## make perl happy ...!
