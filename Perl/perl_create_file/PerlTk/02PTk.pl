#! /usr/bin/perl
use strict;
use warnings;
use Tk;
=pod
ABOUT:
    Window with a message box.
RESURSE:
    http://bin-co.com/perl/perl_tk_tutorial/perl_tk_tutorial.pdf
RUN:
    $ perl 02PTk.pl
    
=cut
my $mw = new MainWindow;
$mw->title("Tk window in Perl");
$mw->geometry("450x350+0+0");

my $label = $mw -> Label(-text=>"Hello World") -> pack();
my $button = $mw -> Button(-text => "Quit", 
        -command =>\&exitProgram)
    -> pack();
MainLoop;

sub exitProgram {
    $mw -> messageBox(-message=>"La revedere!");
    exit;
}
