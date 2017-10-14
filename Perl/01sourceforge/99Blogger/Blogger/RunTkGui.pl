#! /usr/bin/perl
use strict;
use warnings;
use Tk;

# my modules and classes
use Modules::Module; 
use Classes::Class;

my $mw = new MainWindow;
$mw->title("Tk window in Perl");
$mw->geometry("450x350+0+0");
$mw->configure(-menu => my $menubar = $mw ->Menu);

my $file = $menubar->cascade(-label => '~File'); 
my $edit = $menubar->cascade(-label => '~Edit'); 
my $help = $menubar->cascade(-label => '~Help'); 

my $new = $file->cascade( -label => 'New', -accelerator=>'Ctrl-n', -underline=>0,);
$file->separator;
$file->command( -label=>'Open', -accelerator=>'Ctrl-o', -underline=>0,);
$file->command( -label=>'Save', -accelerator=>'Ctrl-s', -underline=>0,);
$file->command( -label=>'Save As...', -accelerator=>'Ctrl-a', -underline=>0,);
$file->command( -label=>'Close', -accelerator=>'Ctrl-w', -underline=>0, -command=>\&exitProgram,);
# ============================================================LABEL
my $label = $mw -> Label(-text=>"Hello World") -> pack(-side=>'left');
# ============================================================ENTRY
my $e_start = $mw->Entry()->pack(-side=>'left');
# ==========================================================BUTTONS
my $button = $mw -> Button(-text => "Quit", -command =>\&exitProgram)-> pack(-side=>'left');
    
MainLoop;

sub exitProgram {
    $mw -> messageBox(-message=>"La revedere!");
    exit;
}
1;
__END__
=pod
ABOUT:
    Window with a message box.
RESURSE:
    http://bin-co.com/perl/perl_tk_tutorial/perl_tk_tutorial.pdf
RUN:
    $ perl 02PTk.pl
    
=cut
