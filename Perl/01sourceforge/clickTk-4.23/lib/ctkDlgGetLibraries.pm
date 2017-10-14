#!/usr/lib/perl
##              -w -d:ptkdb

=pod

=head1 ctkDlgGetLibraries

	Set up and execute dialog to enter 'use lib' libraries

=head2 Programming notes

=over

=item Methods

	dlg_libraries_onAdd()      add a new item and
	                           insert it after the selected item.
	dlg_libraries_onDelete()   delete the selected item.
	dlg_libraries_onMoveUp()   move up the selected item.
	dlg_libraries_onMoveDown() move down the selected item.
	dlg_libraries()            set up dialog a toplevel widget.

=item Notes

	- This package isn't a composite widget.

=back

=head2 Maintenance

	Author:	MARCO
	date:	01.01.2007
	History
			06.12.2007 refactoring
			24.11.2009 version 1.02 (bugfix in dlg_libraries_onAdd)

=cut

package ctkDlgGetLibraries;

our $VERSION = 1.02;

our $debug = 0;

sub dlg_libraries_onAdd {
	my $lb = shift;
	my @x = $lb->curselection;

	my @dirs = $lb->get('0','end');
	my $db = ctkDirDialog::dirDialogModal("",'./');
	my $answ = $db->Show();
	if ($answ =~ /ok/i) {
		my $s = &ctkDirDialog::getdirDialogResult();
		if ($s) {
			my $xS = sub {
				my $dir = shift;
				return undef if  grep ($dir eq $_, @dirs);
				if (@x) {
					$lb->insert($x[0],$dir) ;
				} else {
					$lb->insert('end',$dir);
				}
				return 1
			};
			if (ref($s)) {
				map {
					&$xS($_);
				} @$s;
			} else {
				&xS($s)
			}
		} else {}
	} else {}
	&ctkDirDialog::dirDialogOnDTCancel();
}

sub dlg_libraries_onDelete {
	my $lb = shift;
	my @x = $lb->curselection;
	$lb->delete($x[0]) if (@x);
}

sub dlg_libraries_onMoveUp {
	my $lb = shift;
	my @x = $lb->curselection;
	return unless(@x);
	return unless($x[0]);
	my $i =$x[0]; $i--;
	my $s = $lb->get($x[0]);
	$lb->delete($x[0]) if (@x);
	$lb->insert($i,$s);
}

sub dlg_libraries_onMoveDown {
	my $lb = shift;
	my @x = $lb->curselection;
	return unless(@x);
	return if ($x[0] >= ($lb->index('end') - 1));
	my $s = $lb->get($x[0]);
	my $i = $x[0]; $i++;
	$lb->delete($x[0]);
	$lb->insert($i,$s);
}

sub dlg_libraries {
	my $self = shift;
	my $hwnd = shift;
	my (%args) = @_;
	my $rv;

	&main::trace("dlg_libraries");
	$hwnd = &main::getmw() unless defined($hwnd);

	my ($wr_007,$wr_006,$wr_005,$wr_004,$wr_003,$wr_002,$wr_001);

	my $mw = $hwnd->ctkDialogBox(
		-title=> (exists $args{-title})? $args{-title}:'Get libraries',
		 -buttons=> (exists $args{-buttons}) ? $args{-buttons} : ['OK','Cancel']);
	$mw->protocol('WM_DELETE_WINDOW',sub{1});

	$wr_001 = $mw -> Frame ( -relief , 'flat'  ) -> pack(-anchor=>'nw', -side=>'top', -fill=>'both', -expand=>1);
	$wr_003 = $wr_001 -> Listbox ( -background , '#ffffff' , -selectmode , 'single' , -relief , 'sunken' , -width , 48 ) -> pack(-ipady=>2, -ipadx=>2, -anchor=>'nw', -side=>'top', -fill=>'both', -expand=>1);
	$wr_002 = $mw -> Frame ( -relief , 'flat'  ) -> pack(-anchor=>'nw', -side=>'top', -fill=>'x', -expand=>1);
	$wr_004 = $wr_002 -> Button ( -background , '#ffffff' , -command , [\&dlg_libraries_onAdd,$wr_003] , -state , 'normal' , -relief , 'raised' , -text , 'Add '  ) -> pack(-side=>'left', -anchor=>'nw', -padx=>2, -pady=>2, -fill=>'x', -expand=>1);
	$wr_006 = $wr_002 -> Button ( -background , '#ffffff' , -command , [\&dlg_libraries_onMoveUp,$wr_003] , -state , 'normal' , -relief , 'raised' , -text , 'Up'  ) -> pack(-pady=>2, -padx=>4, -anchor=>'nw', -side=>'left', -fill=>'x', -expand=>1);
	$wr_007 = $wr_002 -> Button ( -background , '#ffffff' , -command , [\&dlg_libraries_onMoveDown,$wr_003] , -state , 'normal' , -relief , 'raised' , -text , 'Down'  ) -> pack(-pady=>2, -padx=>4, -anchor=>'nw', -side=>'left', -fill=>'x', -expand=>1);
	$wr_005 = $wr_002 -> Button ( -background , '#ffffff' , -command , [\&dlg_libraries_onDelete,$wr_003] , -state , 'normal' , -text , 'Delete'  ) -> pack(-side=>'left', -anchor=>'nw', -padx=>2, -pady=>2, -fill=>'x', -expand=>1);
	$wr_002 = $mw -> Label ( -height, 2, -anchor , 'nw' , -justify , 'left' , -relief , 'sunken', -text ,"Current application Folder: \n" . $ctkApplication::applFolder ) -> pack(-pady,2, -anchor=>'nw', -side=>'top', -fill=>'x', -expand=>1);

	#@ctkProject::libraries = ($ctkApplication::applFolder) if (-d $ctkApplication::applFolder && @ctkProject::libraries == 0);
	#$ctkProject::libraries[0] = $ctkApplication::applFolder unless ($ctkProject::libraries[0] eq $ctkApplication::applFolder);
	$wr_003->insert('end',@ctkProject::libraries);

	$mw->bind('<Return>','');
	$rv =  $mw->Show();
		if ($rv =~/ok/i) {
			@ctkProject::libraries = $wr_003->get('0','end');
			&main::changes(1);
			$rv = 1
		} else {
			$rv = 0;
		}
	return $rv;

}		## end of dlg_libraries

1; ## --- eom
