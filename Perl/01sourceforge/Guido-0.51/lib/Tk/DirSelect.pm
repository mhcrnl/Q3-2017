package Tk::DirSelect;
use vars qw($VERSION);
$| = 1;

$VERSION = '1.02';
#  first two versions had no version number

BEGIN {
	$is_win32 = 0;
	
	if($^O eq 'MSWin32') {
		require Win32API::File;
		Win32API::File->import(':Func');
		$is_win32 = 1;
	}
}

#require Tk::Derived;
use Tk qw(Ev);

use strict;

use vars qw( @ISA $is_win32 );
use Tk::Derived;
use Tk::Toplevel;
@ISA = qw( Tk::Derived Tk::Toplevel );

#use base qw(Tk::Derived Tk::Toplevel);

use Tk::widgets qw(Frame Label DirTree Toplevel Radiobutton Button);
use Cwd;

Construct Tk::Widget 'DirSelect';

sub Populate {
	my ($cw, $args) = @_;   
	$cw->SUPER::Populate($args);
	my @drives;
	if ($is_win32) {
		@drives = getLogicalDrives();
	}
	
	$cw->{'dir'} = undef;
	
	my $top = $cw->Frame->pack(-fill=>'x', -expand=>'1');
	my $bottom = $cw->Frame->pack(-fill=>'x', -expand=>'1',-side=>'bottom');
	my $mid = $cw->Frame->pack(-fill=>'both', -expand=>'1');

	my $v;
	my $state;

	no strict 'refs';
	
	if ($is_win32) {
		foreach my $d (@drives){

		my $drive = sprintf "%-2.2s", $d;
		# soft reference; turned off strict refs
		$$d=$top->Radiobutton(	-state=>$state,
			-selectcolor => $top->cget(-background),
			-indicatoron => '0',
			-text => $drive, 
			-command=>[\&Browse, $mid, $d],
			-value=>$d, 
			-variable =>\$v, 
			-width=>'3')->pack(-side=>'left', -padx=>'.5m', -pady=>'1m' );
		}
	}
	
	my $cancel_button = $bottom->Button(
	   	-width=>'7', 
	   	-text=>'Cancel', 
	   	-command=> sub{
	   		$cw->{'dir'} = undef
	   	}
	)->pack(
		-anchor=>'e', 
		-side =>'right', 
		-pady=>'1m'
	);
   
	my $ok_button = $bottom->Button(
		-width=>'7',
		-text=>'OK', 
		-command=> sub{
			print "Hi there\n";
			$cw->{'dir'} = $mid->packSlaves->selectionGet();
			print "Hi there again\n";
		}, 
		-justify=>'right'
	)->pack(
		-anchor=>'e', 
		-side =>'right', 
		padx=>'1m', 
		-pady=>'1m'
	);
	
	my $startdrive;
	
	unless ($startdrive){
		my $currentdir  = cwd;	
		$startdrive = substr($currentdir, 0, 2);
	}

	if ($is_win32) {	
	  	foreach my $d (@drives) {
	  		if (substr($d, 0, 2) =~ /$startdrive/i) {
		   		$$d->invoke;
		   		last;
			}
		}
	} 	
	else {
		Browse($mid, '/');
	}
}

sub Browse {
	my ($mid, $d) = @_;	
	
	print "Starting browse\n";
	
	my $drive = uc $d;
	my @children = $mid->packSlaves;

	foreach my $c (@children){
	  $c->packForget;
	}

	print "Starting chdir\n";

	unless (chdir $d){
		$mid->Label(-text=>"$drive not available.")->pack(-anchor=>'w', -side=>'top');
	  	return;
	}  

	print "Done with chdir\n";
	
	if ($is_win32) {	
		my %drives = (	'0' =>'Unknown', '1'=> 'No root drive', 
		         		'2'=>'Removable disk', '3'=>'Fixed disk',
		         		'4'=>'Network', '5'=>'CD-Rom', 
		     			'6'=>'RAM Disk');
	
		#my $drivetype = GetDriveType( $d );

 
		my $volumelabel;
		GetVolumeInformation( $d, $volumelabel, [], [], [], [], [], [] );
		my $drivetype= GetDriveType( $d );
		my $drive = uc $d;
		$mid->Label(-text=>"$drive $drives{$drivetype} $volumelabel")->pack(-anchor=>'w', -side=>'top');
	}
	
	#print "Creating scrolled item\n";
	
	my $browse = $mid->Scrolled(
		'DirTree', 
		-directory => $d, 
		-scrollbars=>'ose', 
		-bg=>'white'
	)->pack(
		-side=>'bottom', 
		-fill=>'both', 
		-expand=>'1'
	);
	
	#print "Done with browse\n";
}

sub Wait {
   my $cw = shift;
   $cw->waitVariable(\$cw->{'dir'});
   #print "Got variable change\n";
   $cw->grabRelease;
   $cw->withdraw;
   #$cw->Callback(-command => $cw->{'dir'});
   #print "set callback\n";
}

sub Show {
   my ($cw, $grab) = @_;
   my $old_focus = $cw->focusSave;
   my $old_grab = $cw->grabSave;
   $cw->Popup();
   Tk::catch {
      if (defined $grab && length $grab && ($grab =~ /global/)) {
	 $cw->grabGlobal;
      } 
      else {
	 $cw->grab;
      }
   };
   $cw->focus;
   $cw->Wait;
   &$old_focus;
   &$old_grab;
   return $cw->{'dir'};
}
