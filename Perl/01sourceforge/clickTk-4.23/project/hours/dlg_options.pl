#!perl.exe
## ctk: description Enter options
## ctk: title Options
## ctk: application 'Hours' 'c:/Dokumente und Einstellungen/marco/Utilities/ClickTk/test/demo/hours'
## ctk: strict  0
## ctk: code  0
## ctk: subroutineName options
## ctk: autoExtractVariables  1
## ctk: autoExtract2Local  0
## ctk: modal 1
## ctk: isolGeom 0
## ctk: version 3.095
## ctk: onDeleteWindow  sub{1}
## ctk: Toplevel  1
## ctk: 2006 12 03 - 18:46:06

## ctk: uselib start

use lib 'c:/Dokumente und Einstellungen/marco/Utilities/ClickTk/test/demo/hours';

## ctk: uselib end

use Tk;
use Tk::Entry;
use Tk::Frame;
use Tk::LabEntry;
use Tk::LabFrame;
use Tk::Label;
use Tk::Listbox;;
use Tk::Radiobutton;
 $mw=MainWindow->new(-title=>'Options');
## ctk: Globalvars

use vars qw/$jan1 $send $typ $url $year/;

## ctk: Globalvars end
&main::init();
my $answer = &main::options($mw,-title => 'Options', -buttons => [qw(Ok Cancel)]);
print "\nanswer = '$answer'";
MainLoop;

sub options {
my $hwnd = shift;
my (%args) = @_;
my $rv;
##
## ctk: Localvars
## ctk: Localvars end
##
my $mw = $hwnd->DialogBox(
	-title=> (exists $args{-title})? $args{-title}:'Options',
	 -buttons=> (exists $args{-buttons}) ? $args{-buttons} : ['OK','Cancel']);
$mw->protocol('WM_DELETE_WINDOW',sub{1});


## ctk: code generated by ctk_w version '3.095' 
## ctk: instantiate and display widgets 

$wr_009 = $mw -> NoteBook (  ) -> pack(-side=>'top', -anchor=>'nw', -fill=>'both', -expand=>1);


$wr_010 = $wr_009 -> add ( 'wr_010', -justify , 'left' , -label , 'General' , -state , 'normal'  );


$wr_011 = $wr_009 -> add ( 'wr_011', -justify , 'left' , -label , 'Projects' , -state , 'normal'  );


$wr_025 = $wr_011 -> LabFrame ( -label , 'Accounting' , -relief , 'ridge' , -labelside , 'acrosstop'  ) -> pack(-side=>'top', -anchor=>'nw', -fill=>'both', -expand=>1);


$wr_027 = $wr_025 -> Scrolled ( 'Listbox' , -background , '#ffffff' , -selectmode , 'single' , -relief , 'sunken' , -scrollbars , 'se'  ) -> pack(-side=>'top', -anchor=>'nw', -pady=>5, -fill=>'both', -expand=>1, -padx=>5);


$wr_026 = $wr_011 -> LabFrame ( -label , 'Documentations' , -relief , 'ridge' , -labelside , 'acrosstop'  ) -> pack(-side=>'top', -anchor=>'nw', -fill=>'both', -expand=>1);


$wr_029 = $wr_026 -> LabEntry ( -background , '#ffffff' , -label , 'Project planning ' , -labelPack , [-side=>'left',-anchor=>'n'] , -state , 'normal' , -borderwidth , 2 , -justify , 'left'  ) -> pack(-side=>'top', -anchor=>'nw', -pady=>5, -fill=>'x', -expand=>1, -padx=>5);


$wr_031 = $wr_026 -> LabEntry ( -background , '#ffffff' , -label , 'Specifications' , -labelPack , [-side=>'left',-anchor=>'n'] , -state , 'normal' , -justify , 'left' , -relief , 'sunken'  ) -> pack(-side=>'top', -anchor=>'nw', -pady=>5, -fill=>'x', -expand=>1, -padx=>5);


$wr_012 = $wr_009 -> add ( 'wr_012', -justify , 'left' , -label , 'Comunication' , -state , 'normal'  );


$wr_013 = $wr_012 -> Radiobutton ( -value , 1 , -relief , 'flat' , -variable , \$send , -font , 'wr_013' , -anchor , 'nw' , -state , 'normal' , -justify , 'left' , -text , 'Sendmail'  ) -> pack(-side=>'top', -anchor=>'nw', -fill=>'x', -expand=>1);


$wr_014 = $wr_012 -> Radiobutton ( -value , 2 , -relief , 'flat' , -variable , \$send , -font , 'wr_014' , -anchor , 'nw' , -state , 'normal' , -justify , 'left' , -text , 'FTP'  ) -> pack(-side=>'top', -anchor=>'nw', -fill=>'x', -expand=>1);


$wr_015 = $wr_012 -> Radiobutton ( -value , 3 , -relief , 'flat' , -variable , \$send , -font , 'wr_015' , -anchor , 'nw' , -state , 'normal' , -justify , 'left' , -text , 'Local file'  ) -> pack(-side=>'top', -anchor=>'nw', -fill=>'x', -expand=>1);


$wr_016 = $wr_012 -> LabEntry ( -background , '#ffffff' , -label , 'URL' , -labelPack , [-side=>'left',-anchor=>'n'] , -state , 'normal' , -justify , 'left' , -relief , 'sunken' , -textvariable , \$url  ) -> pack(-side=>'top', -anchor=>'nw', -fill=>'x', -expand=>1);


$wr_001 = $wr_010 -> Frame ( -relief , 'solid'  ) -> pack(-anchor=>'nw', -side=>'left', -fill=>'both', -expand=>1);


$wr_003 = $wr_001 -> Label ( -anchor , 'nw' , -justify , 'left' , -text , 'Year' , -relief , 'flat'  ) -> pack(-side=>'top', -anchor=>'nw', -fill=>'x', -expand=>1);


$wr_004 = $wr_001 -> Label ( -anchor , 'nw' , -justify , 'left' , -text , 'Spreadsheet type' , -relief , 'flat'  ) -> pack(-side=>'top', -anchor=>'nw', -fill=>'x', -expand=>1);


$wr_005 = $wr_001 -> Label ( -anchor , 'nw' , -justify , 'left' , -text , 'weekday of jan 1st' , -relief , 'flat'  ) -> pack(-side=>'top', -anchor=>'nw', -fill=>'x', -expand=>1);


$wr_002 = $wr_010 -> Frame ( -relief , 'solid'  ) -> pack(-anchor=>'nw', -side=>'left', -fill=>'both', -expand=>1);


$wr_006 = $wr_002 -> Entry ( -justify , 'left' , -relief , 'sunken' , -textvariable , $year , -state , 'normal'  ) -> pack(-anchor=>'nw', -side=>'top', -fill=>'x', -expand=>1);


$wr_007 = $wr_002 -> Entry ( -justify , 'left' , -relief , 'sunken' , -textvariable , \$typ , -state , 'normal'  ) -> pack(-anchor=>'nw', -side=>'top', -fill=>'x', -expand=>1);


$wr_008 = $wr_002 -> Entry ( -justify , 'left' , -relief , 'sunken' , -textvariable , \$jan1 , -state , 'normal'  ) -> pack(-anchor=>'nw', -side=>'top', -fill=>'x', -expand=>1);


## ctk: end of gened Tk-code

$rv =  $mw->Show();

 return $rv;

} ## end of options 

## ctk: end of dialog code
## ctk: callbacks
sub init { 1 }

## ctk: other code
## ctk: eof 2006 12 03 - 18:46:06
1;	## make perl compiler happy...

