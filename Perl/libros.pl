#!/usr/bin/perl

#
#	Book database
#
# Copyright (C) 2000	  Angel Ortega <angel@triptico.com>
#
# This program is free software; you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation; either version 2 of the License, or
# (at your option) any later version.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.	See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with this program; if not, write to the Free Software
# Foundation, Inc., 675 Mass Ave, Cambridge, MA 02139, USA.
#
#	To MS Windows users:
#
#	To fix the bug in DialogBox.pm:
#
#	replace
#		$cw->transient($cw->toplevel);
#	with
#		$cw->transient($cw->Parent->toplevel);
#

use Tk;
use Tk::DialogBox;

#
# Data
#

$VERSION="1.3";

# main window
$top_window=undef;

# book box
$book_dialog=undef;

# search box
$seek_dialog=undef;

# controls
$btn_new=undef;
$btn_seek=undef;
$btn_all=undef;
$btn_edit=undef;
$btn_del=undef;
$btn_exit=undef;
$ctrl_list=undef;
$ctrl_status=undef;
$btn_sort_by_code=undef;
$btn_sort_by_title=undef;
$btn_sort_by_author=undef;

$book_author=undef;
$book_title=undef;
$book_genre=undef;
$book_where=undef;
$book_notes=undef;

$seek_text=undef;

# complete list
@list_all=();

# search list
@list_seek=();

# database file
$database_file="./biblioteca.dat";

# next code
$next_code=0;

# order
$sort_by="code";

# database title
$database_title=undef;

# saved position
$saved_position=undef;


# locale messages

# Spanish Strings
%spanish_strings=('MAIN_TITLE'	=>	"Base de Datos de Libros",
		  'ALL' 	=>	"Todos",
		  'SEARCH'	=>	"Filtro",
		  'ADD' 	=>	"Añadir",
		  'MODIFY'	=>	"Modificar",
		  'DELETE'	=>	"Borrar",
		  'EXIT'	=>	"Salir",
		  'CODE_SORT'	=>	"Ordenar por código",
		  'AUTH_SORT'	=>	"Ordenar por autor",
		  'TITL_SORT'	=>	"Ordenar por Título",
		  'BOOK_DATA'	=>	"Datos del Libro",
		  'OK'		=>	"Aceptar",
		  'CANCEL'	=>	"Cancelar",
		  'AUTHOR'	=>	"Autor:",
		  'TITLE'	=>	"Título:",
		  'GENRES'	=>	"Géneros:",
		  'LOCATION'	=>	"Ubicación:",
		  'NOTES'	=>	"Notas:",
		  'TXT_SEEK'	=>	"Texto a buscar:",
		  'DELETED'	=>	"(borrado)",
		  'IN_LIST'	=>	"En la lista:"
		);

# English Strings
%english_strings=('MAIN_TITLE'	=>	"Book Database",
		  'ALL' 	=>	"All",
		  'SEARCH'	=>	"Filter",
		  'ADD' 	=>	"Append",
		  'MODIFY'	=>	"Modify",
		  'DELETE'	=>	"Delete",
		  'EXIT'	=>	"Exit",
		  'CODE_SORT'	=>	"Sort by code",
		  'AUTH_SORT'	=>	"Sort by author",
		  'TITL_SORT'	=>	"Sort by title",
		  'BOOK_DATA'	=>	"Book Data",
		  'OK'		=>	"OK",
		  'CANCEL'	=>	"Cancel",
		  'AUTHOR'	=>	"Author:",
		  'TITLE'	=>	"Title:",
		  'GENRES'	=>	"Genres:",
		  'LOCATION'	=>	"Location:",
		  'NOTES'	=>	"Notes:",
		  'TXT_SEEK'	=>	"Text to seek:",
		  'DELETED'	=>	"(deleted)",
		  'IN_LIST'	=>	"In list:"
		);

# LANG
$LANG=\%english_strings;

$LANG=\%spanish_strings if($ENV{'LANG'} eq 'spanish' or
			   $ENV{'LANG'} eq 'ES' or
			   $ENV{'LANG'} eq 'es_ES');

#
#	Code
#

sub load_database
{
	my (@line,$rec);

	@list_all=();

	if(open(DAT,$database_file))
	{
		$_=<DAT>;
		chop;
		s/\r//g;

		($next_code,$database_title)=split(/\|/,$_);

		while(<DAT>)
		{
			chop();
			s/\r//g;

			@line=split(/\|/,$_);

			$rec={};
			$rec->{"code"}=$line[0];
			$rec->{"author"}=$line[1];
			$rec->{"title"}=$line[2];
			$rec->{"genre"}=$line[3];
			$rec->{"where"}=$line[4];
			$rec->{"notes"}=$line[5];

			push(@list_all,$rec);
		}

		close DAT;
	}
}


sub save_database
{
	my ($line,$rec);

	if(open(DAT, ">".$database_file))
	{
		print DAT "$next_code|$database_title|\n";

		foreach $rec (@list_all)
		{
			$line=join("|",(sprintf("%05d",$rec->{'code'}),
					$rec->{'author'},$rec->{'title'},
					$rec->{'genre'},$rec->{'where'},
					$rec->{'notes'}));

			print DAT $line . "\n";
		}

		close DAT;
	}
}


sub create_layout
{
	my ($f,$b);

	$top_window=MainWindow->new(-title => "Libros.pl $VERSION : " .
		($database_title ? "$database_title" : $LANG->{'MAIN_TITLE'}));

	$f=$top_window->Frame(-relief => sunken, -borderwidth => 2);

	$btn_add=$f->Button(-text => text_str('ADD'),
		-command => \&cmd_add)->pack(-side => left);
	$btn_edit=$f->Button(-text => text_str('MODIFY'),
		-command => \&cmd_edit)->pack(-side => left);
	$btn_del=$f->Button(-text => text_str('DELETE'),
		-command => \&cmd_del)->pack(-side => left);

	# separator
	$f->Label(-text => "   ")->pack(-side => left);

	$btn_seek=$f->Button(-text => text_str('SEARCH'),
		-command => \&cmd_seek)->pack(-side => left);
	$btn_all=$f->Button(-text => text_str('ALL'),
		-command => \&cmd_all)->pack(-side => left);

	# separator
	$f->Label(-text => "   ")->pack(-side => left);

	$btn_exit=$f->Button(-text => text_str('EXIT'),
		-command => \&cmd_exit)->pack(-side => left);
	$f->pack();

	$f=$top_window->Frame();

	$ctrl_list=$f->Scrolled('Listbox', -scrollbars => 'e',
		-width => 76, -height => 15, -font => "fixed");
	$ctrl_list->pack(-side => left, -expand => yes, -fill => both);
	$f->pack();

	$f=$top_window->Frame();

	$ctrl_status=$f->Label(-text => "", -relief => sunken, -width => 70);
	$ctrl_status->pack(-side => left, -expand => yes, -fill => both);
	$f->pack();

	$f=$top_window->Frame();

	$btn_sort_by_code=$f->Button(-text => text_str('CODE_SORT'),
		-command => \&cmd_sort_by_code)->pack(-side => left);
	$btn_sort_by_author=$f->Button(-text => text_str('AUTH_SORT'),
		-command => \&cmd_sort_by_author)->pack(-side => left);
	$btn_sort_by_title=$f->Button(-text => text_str('TITL_SORT'),
		-command => \&cmd_sort_by_title)->pack(-side => left);
	$f->pack();

	$book_dialog=$top_window->DialogBox(-title => text_str('BOOK_DATA'),
		-buttons => [text_str('OK'), text_str('CANCEL')]);

	$b=$book_dialog->add('Frame')->pack();

	$f=$b->Frame();
	$f->Label(-text => text_str('AUTHOR'))->pack(-side => left);
	$book_author=$f->Entry(-width => 40,
		-background => white)->pack(-side => right);
	$f->pack(-expand => yes, -fill => both);
	$f=$b->Frame();
	$f->Label(-text => text_str('TITLE'))->pack(-side => left);
	$book_title=$f->Entry(-width => 40,
		-background => white)->pack(-side => right);
	$f->pack(-expand => yes, -fill => both);
	$f=$b->Frame();
	$f->Label(-text => text_str('GENRES'))->pack(-side => left);
	$book_genre=$f->Entry(-width => 40,
		-background => white)->pack(-side => right);
	$f->pack(-expand => yes, -fill => both);
	$f=$b->Frame();
	$f->Label(-text => text_str('LOCATION'))->pack(-side => left);
	$book_where=$f->Entry(-width => 40,
		-background => white)->pack(-side => right);
	$f->pack(-expand => yes, -fill => both);
	$f=$b->Frame();
	$f->Label(-text => text_str('NOTES'))->pack(-side => left);
	$book_notes=$f->Entry(-width => 40,
		-background => white)->pack(-side => right);
	$f->pack(-expand => yes, -fill => both);

	$seek_dialog=$top_window->DialogBox(-title => text_str('SEARCH'),
		-buttons => [text_str('OK'), text_str('CANCEL')]);

	$b=$seek_dialog->add('Frame')->pack();

	$f=$b->Frame();
	$f->Label(-text => text_str('TXT_SEEK'))->pack(-side => left);
	$seek_text=$f->Entry(-width => 40,
		-background => white)->pack(-side => right);
	$f->pack(-expand => yes, -fill => both);
}


sub empty_book
{
	$book_author->delete(0,100);
	$book_title->delete(0,100);
	$book_genre->delete(0,100);
	$book_where->delete(0,100);
	$book_notes->delete(0,100);
}


sub get_book
{
	my ($new)=@_;
	my ($rec);

	$rec={};

	$rec->{'code'}=$next_code++ if $new;
	$rec->{'author'}=$book_author->get();
	$rec->{'title'}=$book_title->get();
	$rec->{'genre'}=$book_genre->get();
	$rec->{'where'}=$book_where->get();
	$rec->{'notes'}=$book_notes->get();

	return($rec);
}


sub str_format
{
	my ($str,$max)=@_;
	my ($fmt);

	if (length($str)>$max)
	{
		$str=substr($str,0,$max-3)."...";
	}

	$fmt="%-${max}s";
	return(sprintf($fmt,$str));
}


sub display_book
{
	my ($rec)=@_;
	my ($line);

	return(0) if $rec->{'notes'} eq text_str('DELETED');

	$line=sprintf("%05d %s %s %s",$rec->{'code'},
		str_format($rec->{'author'},20),
		str_format($rec->{'title'},38),
		str_format($rec->{'where'},10));

	$ctrl_list->insert(end,$line);
	return(1);
}


sub get_list_code
{
	my (@l,$n,$line);

	@l=$ctrl_list->curselection();
	$n=$l[0];
	return(undef) if $n eq "";

	# gets only the first element, the code
	$line=$ctrl_list->get($n);
	($n)=split(" ",$line);

	return($n);
}


#
#	commands
#

sub cmd_add
{
	my ($res,$rec);

	$saved_position=$ctrl_list->curselection();

	empty_book();

	if($book_dialog->Show() eq text_str('OK'))
	{
		$rec=get_book(1);

		push(@list_all, $rec);
		push(@list_seek, $rec->{'code'});
		refresh_list(1);
	}
}


sub cmd_seek
{
	my ($t,$rec);

	if($seek_dialog->Show() eq text_str('OK'))
	{
		# vacía la lista
		@list_seek=();

		$t=$seek_text->get();

		foreach $rec (@list_all)
		{
			if($rec->{'author'} =~ /$t/i ||
			   $rec->{'title'} =~ /$t/i ||
			   $rec->{'genre'} =~ /$t/i ||
			   $rec->{'where'} =~ /$t/i ||
			   $rec->{'notes'} =~ /$t/i)
			{
				push(@list_seek, $rec->{'code'});
			}
		}
	}

	refresh_list();
}


sub cmd_all
{
	my ($n);

	$n=@list_all;
	@list_seek=(0 .. $n-1);

	refresh_list();
}


sub cmd_edit
{
	my ($code,$rec);

	$saved_position=$ctrl_list->curselection();

	$code=get_list_code();
	return unless defined($code);

	$rec=$list_all[$code];

	empty_book();

	$book_author->insert(0,$rec->{'author'});
	$book_title->insert(0,$rec->{'title'});
	$book_genre->insert(0,$rec->{'genre'});
	$book_where->insert(0,$rec->{'where'});
	$book_notes->insert(0,$rec->{'notes'});

	if($book_dialog->Show() eq text_str('OK'))
	{
		$rec=get_book(0);
		$rec->{'code'}=$code;

		$list_all[$code]=$rec;

		refresh_list(1);
	}
}


sub cmd_del
{
	my ($code,$rec);

	$code=get_list_code();
	return unless defined($code);

	$rec=$list_all[$code];
	$rec->{'notes'}=text_str('DELETED');
	$list_all[$code]=$rec;

	refresh_list();
}


sub cmd_exit
{
	save_database();

	exit(0);
}


sub cmd_sort_by_code
{
	$sort_by="code";
	refresh_list();
}


sub cmd_sort_by_author
{
	$sort_by="author";
	refresh_list();
}


sub cmd_sort_by_title
{
	$sort_by="title";
	refresh_list();
}


sub list_resort
{
	my (%aux,$rec);

	%aux=();
	foreach my $i (@list_seek)
	{
		$rec=$list_all[$i];
		$aux{$rec->{$sort_by}." ".$rec->{'code'}}=$rec->{'code'};
	}

	@list_seek=();
	foreach my $i (sort keys %aux)
	{
		push(@list_seek, $aux{$i});
	}
}


sub refresh_list
{
	my ($reset_pos)=@_;
	my ($i,$rec,$line,$total);

	list_resort();

	# borra todo lo que haya
	$i=$ctrl_list->size();
	$ctrl_list->delete(0,$i);

	$total=0;

	foreach $i (@list_seek)
	{
		$rec=$list_all[$i];

		$total+=display_book($rec);
	}

	if($reset_pos && defined($saved_position))
	{
		$ctrl_list->selection(set,$saved_position);
		$ctrl_list->yview('scroll',$saved_position,units);
	}

	$ctrl_status->configure( -text => text_str('IN_LIST').$total);
}


sub text_str
{
	my ($label)=@_;
	my ($ret);

	$ret=$LANG->{$label};

	return($ret);
}


# ################
#	Main
# ################

if($ARGV[0] eq "--english")
{
	$LANG=\%english_strings;
	shift;
}
if($ARGV[0] eq "--spanish")
{
	$LANG=\%spanish_strings;
	shift;
}

$database_file=$ARGV[0] if $ARGV[0];

load_database();

create_layout();

MainLoop();
