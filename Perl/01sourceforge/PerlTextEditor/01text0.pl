#! /usr/bin/perl
use Tk;
#------------------------------------------------------------------------
#                                                         Records keeping
my $APP_NAME = "Perl/Tk Text Editor";
my $VERSION = " V0.1";
my $AUTOR = "Mihai Cornel   mhcrnl\@gmail.com";
my $DESCRIPTION = "Text editor application";
my $PERL_VERSION = "v5.24.2"; # $perl -v
my $TK_VERSION = "804.033"; # $perl -MTk -e 'print "$Tk::VERSION\n"'
# -----------------------------------------------------------------------
#                                                                  Window 
$mw = MainWindow->new;
$mw->title($APP_NAME.$VERSION);

#my $defaultFont = $mw->fontCreate(-family => 'Courier New', -size => 14);
#-------------------------------------------------------------------------
#                                              Adding menubar to the frame
$mw ->configure(-menu=>my $menuBar = $mw->Menu);
# ------------------------------------------------------------------------
#                                              Adding menu File to menubar
my $file= $menuBar->cascade(-label=>'~File', -tearoff=>0);
fileMenu();
# ------------------------------------------------------------------------
#                                                                Help menu
my $help= $menuBar->cascade(-label=>'~Help', -tearoff=>0);
helpMenu();
# ------------------------------------------------Create necessary widgets
$f = $mw->Frame->pack(-side => 'top', -fill => 'x');
$f->Label(-text => "Filename:")->pack(-side => 'left', -anchor => 'w');

$f->Entry(-textvariable => \$filename)->pack(-side => 'left', 
   -anchor => 'w', -fill => 'x', -expand => 1);
   
$f->Button(-text => "SourceForge", -command => \&git_push)->
  pack(-side => 'right', -anchor => 'e');
$f->Button(-text => "Exit", -command => sub { exit; } )->
  pack(-side => 'right');
$f->Button(-text => "Save", -command => \&save_file)->
  pack(-side => 'right', -anchor => 'e');
$f->Button(-text => "Load", -command => \&load_file)->
  pack(-side => 'right', -anchor => 'e');
  
$mw->Label(-textvariable => \$info, -relief => 'ridge')->
  pack(-side => 'bottom', -fill => 'x');
$t = $mw->Scrolled("Text")->pack(-side => 'bottom', 
  -fill => 'both', -expand => 1);

MainLoop;

sub helpMenu {
  $help->command(-label=>'~SourceForge',-accelerator=>'Ctrl+F',-command=>\&git_push);
}
# ----------------------------------------------------------------------------fileMenu                              
sub fileMenu {
    $file->command(-label=>'~New', -accelerator=>'Ctrl+N', -command=>\&new);
    $file->separator;
    $file->command(-label=>'~Open', -accelerator=>'Ctrl+O', -command=>\&load_file);
    $file->command(-label=>'~Save', -accelerator=>'Ctrl+S', -command=>\&save_file);
    $file->separator;
    $file->command(-label=>'~Exit', -accelerator=>'Ctrl+E', -command=>sub {exit;});
}
# -----------------------------------------------Creates a new window of this program
sub new {
    system("perl 01text0.pl");
}
# load_file checks to see what the filename is and loads it if possible
sub load_file {
  $filename=$mw->getOpenFile();
  $info = "Loading file '$filename'...";
  $t->delete("1.0", "end");
  if (!open(FH, "$filename")) {
    $t->insert("end", "ERROR: Could not open $filename\n"); 
    return; 
  }
  while (<FH>) { $t->insert("end", $_); }
  close (FH);
  $info = "File '$filename' loaded";
}

# save_file saves the file using the filename in the Entry box.
sub save_file {
  $filename=$mw->getSaveFile();
  $info = "Saving '$filename'";
  open (FH, ">$filename");
  print FH $t->get("1.0", "end");
  $info = "Saved.";
}

sub git_push {
        my $gitpush = cwd;
        system("./gitpush.sh");
}
