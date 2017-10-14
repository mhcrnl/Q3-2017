#!/usr/lib/perl
##              -w -d:ptkdb

=pod

=head1 ctkDirDialog

	Set up a non-modal dialog to select a subdir

=head2 Syntax

		my $db = ctkDirDialog::dirDialog('Select one subdir','./');

		my $db = ctkDirDialog::dirDialog('Select one subdir','./',$wEntry);

		if ($myFolder = ctkDirDialog::getdirDialogResult()) {
			## Process selected folder
		} else {
			##
		}

=head2 Programming notes

=over

=item Non standard widget!

=item Class variables

	DTW, DTL, DT, DTOK, DTCancel	work
	dirDialog
	dirDialogSubdir
	dirDialogEntry

=item Methods

	cleanPath
	createOneDir

	dirDialog
	dirDialogModal
	dirDialogOnCreateSubdir
	dirDialogOnDTCancel
	dirDialogOnDTCancelModal
	dirDialogOnDTOK
	dirDialogOnDTOKModal
	dirDialogOnDTTree
	dirDialogOnDTTreeModal
	getdirDialogResult

=back

=head2 Maintenance

	Author:	marco
	date:	05.10.2006
	History
			05.10.2006 mam First draft

=cut

package ctkDirDialog;

use strict;

use base (qw/ctkBase/);

our $VERSION = 1.01;

my ($DTW,$DTL,$DT,$DTOK,$DTCancel);
my $dirDialog;
my $dirDialogSubdir;
my $dirDialogEntry;

=head2 dirDialogModal

	This method provides the same functionality as dirDialog
	but in modal mode.

=cut

sub dirDialogModal {
	my ($title,$start_dir,$entry) = @_;
	my $rv;

	$dirDialogSubdir = '';
	$dirDialogEntry = $entry;

	$DTW = &main::getmw()->DialogBox(-title=> $title, -buttons=> ['OK','Cancel']);

	$DTW->protocol(WM_DELETE_WINDOW => sub {&dirDialogOnDTCancelModal()});

	$DT  = $DTW->Scrolled('DirTree',
					-directory=>$start_dir,
					-command=> \&dirDialogOnDTTreeModal,
					-bg => 'white',
					-scrollbars =>"e");
	$DT->pack(-expand => 1 , -fill => 'both', -expand => 1, -padx => 5, -pady => 5);

	$DTOK = $DTW->Button(
					-text => "Select Directory",
					-command => \&dirDialogOnDTOKModal,
					-borderwidth => 2,
					-relief => 'raised',
					-width => 30,
					-bg => 'white');
	$DTOK->pack(-side=>'left',-fill => 'x', -expand => 1);
	return $DTW;
}

=head2 dirDialog

	Set up non-modal dialog

	Arguments

		- title		title
		- start dir	starting folder
		- entry		receiving entry widget, optional

	Return

	- ref to toplevel widget or undef.

	Example :

		$button->configure (-command [sub {
			my $w =&ctkDirDialog::dirDialogModal;
			$w->Show;
			},
			"Select folder",
			'.',
			$entry
			]);

	Note: result of the selection must be withdraw with
	      ctkDirDialog::getdirDialogResult

=cut

sub dirDialog {
	my ($title,$start_dir,$entry) = @_;

	return undef if(defined($dirDialog));
	$dirDialog = 1;


	$dirDialogSubdir = '';
	$dirDialogEntry = $entry;

	$DTW = &main::getmw()->Toplevel(-title => 'Select subdir');
	$DTW->protocol(WM_DELETE_WINDOW => sub {&dirDialogOnDTCancel()});

	$DT  = $DTW->Scrolled('DirTree',
					-directory=>$start_dir,
					-command=> \&dirDialogOnDTTree,
					-bg => 'white',
					-scrollbars =>"e");
	$DT->pack(-expand => 1 , -fill => 'both', -expand => 1, -padx => 5, -pady => 5);

	$DTOK = $DTW->Button(
					-text => "Select Directory",
					-command => \&dirDialogOnDTOK,
					-borderwidth => 2,
					-relief => 'raised',
					-width => 30,
					-bg => 'white');
	$DTOK->pack(-side=>'left',-fill => 'x', -expand => 1);

	$DTCancel = $DTW->Button(
					-text => "Cancel",
					-command => \&dirDialogOnDTCancel ,
					-borderwidth => 2,
					-relief => 'raised',
					-width => 30,
					-bg => 'white');
	$DTCancel->pack(-side=>'left',-fill => 'x', -expand => 1);
	return $DTW
}

=head2 getdirDialogResult

	This method returns the value of the selected folder.

=cut

sub getdirDialogResult {
	return ($dirDialogSubdir);
	}

sub dirDialogOnDTOK {
	my $dir = "";
	$dir = $DT->selection('get');
	if ($dir eq "") {
		&main::getmw->bell;
	} else {
		&dirDialogOnDTTree($dir);
	}
	undef $dirDialog;
}

sub dirDialogOnCreateSubdir {
	my $dir = $DT->selection('get');
	if (!defined ($dir) || $dir eq "") {
			&std::ShowInfoDialog("Please select first the subdir into which allocate the new folder");
	} else {
		## create a new subdir in $dir
	    ## setup first the Dialog to get the name of the new subdir -> $newSubdir
		## check if this name is already a subdir
	    ## create the new subdir 	->
		$dir = &cleanPath($dir);
		if (-d $dir) {
			my $newSubdir = &getSubDirName('name of the subdir');
			if (defined($newSubdir)) {
				my $oldcwd = cwd();		# save working dir
				chdir $dir;
				if (-d $newSubdir) {
					&std::ShowInfoDialog("this subdir already exists, cannot create a new one");
					}
				else {
					&std::ShowInfoDialog("subdir '$newSubdir' on '$dir' should be created");
					&createOneDir($newSubdir);
					}
				chdir($oldcwd); # restore working dir
				}
			}
		else {
			&warnUser("Sorry, something did wrong in dirTree, create subdir by hand ...");
			}
		## reinit dirTree
	}
}

sub dirDialogOnDTCancel {
	$dirDialogSubdir = '';
	undef $dirDialog;
	$DTW->destroy;
}

sub dirDialogOnDTTree {
	($dirDialogSubdir) = @_;
	$dirDialogSubdir = &cleanPath($dirDialogSubdir);
	$dirDialogEntry->delete('0.0','end') if defined ($dirDialogEntry) && Tk::Exists($dirDialogEntry);
	$dirDialogEntry->insert('0.0', $dirDialogSubdir) if defined ($dirDialogEntry) && Tk::Exists($dirDialogEntry);
	## $dirDialogEntry->see('end');
	undef $dirDialog;
	$DTW->destroy;
}

sub dirDialogOnDTCancelModal {
	$dirDialogSubdir = '';
	$DTW->destroy;
}

sub dirDialogOnDTOKModal {
	my $dir = "";
	$dir = $DT->selection('get');
	if ($dir eq "") {
		&main::getmw->bell;
	} else {
		&dirDialogOnDTTreeModal($dir);
	}
}

sub dirDialogOnDTTreeModal {
	($dirDialogSubdir) = @_;
	$dirDialogSubdir = &cleanPath($dirDialogSubdir);
	$dirDialogEntry->delete('0.0','end') if defined ($dirDialogEntry) && Tk::Exists($dirDialogEntry);
	$dirDialogEntry->insert('0.0', $dirDialogSubdir) if defined ($dirDialogEntry) && Tk::Exists($dirDialogEntry);
	## $dirDialogEntry->see('end');
}

=head2 cleanPath

	Performs some edit operations on the given folder:

		- eliminate double separators replacing them with a single separator,
		- replace '/' with the separator used by the runnning OS,
		- change case of drive letter to low case.

=cut

sub cleanPath {
	my($path) = @_;
	my $FS = ctkFile->FS;
	# print "\npath=$path";
	$path =~ s/^$FS$FS/$FS/;
	$path =~ s/[\/]/$FS/g if ($FS ne '/');
	$path =~ s/^(.):/\l$1:/;
	# print "\npath=$path";
	return $path;
}

=head2 createOneDir

	This method allocates the given folder using mkdir.
	It returns the return code of mkdir.

=cut

sub createOneDir {
	my ($thisdir) = @_;
	my $mode = 0777;
	mkdir ($thisdir,$mode);
	}

1; ## -----------------------------------

