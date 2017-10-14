#!/usr/bin/perl -w

use strict;
use Tk;

#------------------------------------------------------------------------------#
# perl2exe pragmas                                                             #
#------------------------------------------------------------------------------#

#perl2exe_include "Tk/Menu.pm";
#perl2exe_include "Tk/Scrollbar.pm";
#perl2exe_include "Tk/Text.pm";

#------------------------------------------------------------------------------#
# global settings                                                              #
#------------------------------------------------------------------------------#

my $mainWindow  = MainWindow->new;
my $defaultFont = $mainWindow->fontCreate(-family => 'Courier New', -size => 10);

my $width  = ($mainWindow->screenwidth  / 1.5);
my $height = ($mainWindow->screenheight / 1.5);

$mainWindow->minsize($width, $height);
$mainWindow->title("Visual Perl/Tk 0.01");

$mainWindow->configure(-menu => my $menuBar = $mainWindow->Menu);

#------------------------------------------------------------------------------#
# define menus                                                                 #
#------------------------------------------------------------------------------#

my $file = $menuBar->cascade(
			-label => '~File',
			-tearoff => 0
			);
filemenu();
my $edit = $menuBar->cascade(
			-label => '~Edit',
			-tearoff => 0
			);
editmenu();
my $format = $menuBar->cascade(
			-label => 'F~ormat',
			-tearoff => 0
			);
formatmenu();
my $view = $menuBar->cascade(
			-label => '~View',
			-tearoff => 0
			);
viewmenu();
my $help = $menuBar->cascade(
			-label => '~Help',
			-tearoff => 0
			);
helpmenu();

#------------------------------------------------------------------------------#
# pack widgets                                                                 #
#------------------------------------------------------------------------------#

my $hScrollBar = $mainWindow->Scrollbar(
				-relief => 'sunken',
				-orient => 'horizontal'
				)->pack(
					-side => 'bottom',
					-anchor => 's',
					-fill => 'x'
					);

my $vScrollBar = $mainWindow->Scrollbar(
				-relief => 'sunken',
				-orient => 'vertical'
				)->pack(
					-side => 'right',
					-anchor => 'e',
					-fill => 'y'
					);

my $textBox = $mainWindow->Text(
				-xscrollcommand => ['set' => $hScrollBar],
				-yscrollcommand => ['set' => $vScrollBar],
				-relief => 'sunken',
				-font => $defaultFont,
				-wrap => 'none'
				)->pack(
					-side => 'left',
					-anchor => 'n',
					-fill => 'both',
					-expand => 1
					);

#------------------------------------------------------------------------------#
# configure widgets                                                            #
#------------------------------------------------------------------------------#

$hScrollBar->configure(-command => ['xview' => $textBox]);
$vScrollBar->configure(-command => ['yview' => $textBox]);

#------------------------------------------------------------------------------#
# key bindngs                                                                  #
#------------------------------------------------------------------------------#

$mainWindow->bind('<Control-Key-n>' => \&new);
$mainWindow->bind('<Control-Key-o>' => \&open);
$mainWindow->bind('<Control-Key-s>' => \&save);

MainLoop;

#------------------------------------------------------------------------------#
# build menus                                                                  #
#------------------------------------------------------------------------------#

sub filemenu
{

	$file->command(
		-label => '~New',
		-accelerator => 'Ctrl+N',
		-command => \&new
		);
	$file->command(
		-label => 'Open...',
		-accelerator => 'Ctrl+O',
		-command => \&open
		);
	$file->command(
		-label => 'Save',
		-accelerator => 'Ctrl+S',
		-command => \&save
		);
	$file->command(
		-label => 'Save ~As...',
		-command => \&saveas
		);
	$file->separator;
	$file->command(
		-label => 'Page Set~up...',
		-state => 'disabled'
		);
	$file->command(
		-label => '~Print...',
		-accelerator => 'Ctrl+P',
		-state => 'disabled'
		);
	$file->separator;
		$file->command(
		-label => 'E~xit',
		-command => \&exit
		);
}

sub editmenu
{
	$edit->command(
		-label => '~Undo',
		-accelerator => 'Ctrl+Z',
		-state => 'disabled'
		);
	$edit->separator;
	$edit->command(
		-label => 'Cu~t',
		-accelerator => 'Ctrl+X',
		-state => 'disabled'
		);
	$edit->command(
		-label => '~Copy',
		-accelerator => 'Ctrl+C',
		-state => 'disabled'
		);
	$edit->command(
		-label => '~Paste',
		-accelerator => 'Ctrl+V',
		-state => 'disabled'
		);
	$edit->command(
		-label => 'De~lete',
		-accelerator => 'Del',
		-state => 'disabled'
		);
	$edit->separator;
	$edit->command(
		-label => '~Find...',
		-accelerator => 'Ctrl+F',
		-state => 'disabled'
		);
	$edit->command(
		-label => 'Find ~Next',
		-accelerator => 'F3',
		-state => 'disabled'
		);
	$edit->command(
		-label => '~Replace...',
		-accelerator => 'Ctrl+H',
		-state => 'disabled'
		);
	$edit->command(
		-label => '~Go To...',
		-accelerator => 'Ctrl+G',
		-state => 'disabled'
		);
	$edit->separator;
	$edit->command(
		-label => 'Select ~All',
		-accelerator => 'Ctrl+A',
		-state => 'disabled'
		);
	$edit->command(
		-label => 'Time/~Date',
		-accelerator => 'F5',
		-state => 'disabled'
		);
}

sub formatmenu
{
	$format->command(
		-label => '~Word Wrap',
		-state => 'disabled'
		);
	$format->command(
		-label => '~Font',
		-state => 'disabled'
		);
}

sub viewmenu
{
	$view->command(
		-label => '~Status Bar',
		-state => 'disabled'
		);
}

sub helpmenu
{
	$help->command(
		-label => '~Help Topics',
		-state => 'disabled'
		);
	$help->separator;
	$help->command(
		-label => '~About Perl/Tk Notepad',
		-state => 'disabled'
		);
}

#------------------------------------------------------------------------------#
# menu commands                                                                #
#------------------------------------------------------------------------------#

sub new
{
	$textBox->delete('1.0', 'end');
}

sub open
{
   my $filename = $mainWindow->getOpenFile();

   $textBox->delete('1.0', 'end');

   if (open(FILE, "<$filename")) {

      while (<FILE>) {
         $textBox->insert('end', $_);
      }

      close(FILE);
   }
}

sub save
{
	my $filename = $mainWindow->appname . ".pl";
=pod
	if (open(FILE, ">$filename")) {
		print FILE $textBox->get('1.0', 'end');
		close(FILE);
	} 
=cut
}

sub saveas
{
	my $filename = $mainWindow->getSaveFile();

	if (open(FILE, ">$filename")) {
		print FILE $textBox->get('1.0', 'end');
      		close(FILE);
   	}
}

__END__

=head1 NAME

	Visual Perl 0.01

=head1 SYNOPSIS

=head1 DESCRIPTION

=head1 AUTHOR

	Julian Moors

=head1 BUGS

=head1 SEE ALSO

=head1 COPYRIGHT

	Visual Perl 0.01 Copyright (C) 2005 Julian Moors


	This program is free software; you can redistribute it and/or modify
	it under the terms of the GNU General Public License as published by
	the Free Software Foundation; either version 2 of the License, or
	(at your option) any later version.


	This program is distributed in the hope that it will be useful,
	but WITHOUT ANY WARRANTY; without even the implied warranty of
	MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
	GNU General Public License for more details.


	You should have received a copy of the GNU General Public License
	along with this program; if not, write to the Free Software
	Foundation, Inc., 51 Franklin St, Fifth Floor, Boston, MA  02110-1301 USA
