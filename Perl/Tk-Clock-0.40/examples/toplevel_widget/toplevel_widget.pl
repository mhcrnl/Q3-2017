#! /usr/bin/perl

use Tk;

$mw = MainWindow->new(-background => "red");
$mw->title("MainWindow");
$mw->geometry("400x400+10+20");
$mw->iconbitmap();

$mw->Button(-text=>"Close",-command=>\&do_toplevel)->pack();

MainLoop;

sub do_toplevel{
		if(!Exists($tl)){
				$tl=$mw->Toplevel();
				$tl->title("Toplevel");
			$tl->Button(-text=>"Close", -command=>sub{$tl->withdraw})->pack;
		} else {
				$tl->deiconify();
				$tl->raise();
			}
	}