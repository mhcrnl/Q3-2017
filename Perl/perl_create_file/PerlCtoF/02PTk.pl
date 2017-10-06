#! /usr/bin/perl
use strict;
use warnings;
use Tk;
use CtoF;
=pod
ABOUT:
    Window with a message box.
RESURSE:
    http://bin-co.com/perl/perl_tk_tutorial/perl_tk_tutorial.pdf
RUN:
    $ perl 02PTk.pl
    
=cut
my $mw = new MainWindow;
$mw->title("Tk Convertor window in Perl");
$mw->geometry("450x350+0+0");
# ========================================================= LABELS
my $label = $mw -> Label(-text=>"Celsius: ") -> pack();
my $label1 = $mw -> Label(-text=>"Fahrenheit: ");
# ========================================================= ENTRY
my $cels = $mw -> Entry()->pack();
$label1->pack();
my $fahr = $mw -> Entry()->pack();
# ========================================================= BUTTONS
my $button = $mw -> Button(-text => "Quit", 
        -command =>\&exitProgram)
    -> pack();
my $button1 = $mw -> Button(-text => "Calculeaza", 
        -command =>\&calculeaza)
    -> pack();  
    
MainLoop;

sub exitProgram {
    $mw -> messageBox(-message=>"La revedere!");
    exit;
}

sub calculeaza{
    my $celsius = $cels->get();
    my $conv = new CtoF($celsius);
    my $convert = $conv->convertCtoF();
    $fahr->insert('end', $convert);
    print "$convert\n"; 
}
