use Test::More;
use Config;
BEGIN {
    if ( ! $Config{'useithreads'} ) {
        plan skip_all => "Perl not compiled with 'useithreads'";
    }
    elsif ( ! -f 'tk_is_ok' ) {
        plan skip_all => "Tk is not working properly on this machine";
    }
    else {
        plan no_plan;
    }
}

use strict;
use lib '../lib';

use Text::Editor::Easy;
#{
#    'trace' => {
#        'all' => 'tmp/',
#        'trace_print' => 'full',
#    }
#};

my $editor = Text::Editor::Easy->new (
    {
        #'sub'      => 'main',    # Sub for action
        'x_offset' => 60,
        'y_offset' => 170,
        'width'    => 500,
        'height'   => 300,
    }
);

#print "Fin du programme", threads->tid, "\n";
#exit;
#print "Fin du programme ...\n";

#sub main {
#		my ( $editor ) = @_;
		
		
#		use Test::More qw( no_plan );
		
		# Full trace thread creation
		print "Full trace thread creation by trace_print call\n";
		my @first_list = threads->list;
		print "Scakar first ", scalar (@first_list), "\n";
		
		my $tid = $editor->create_new_server(
		   {
				'use' => 'Text::Editor::Easy::Test::Test1', 
				'package' => 'Text::Editor::Easy::Test::Test1',
				'methods' => ['test1'],
				'object' => [] 
		    });
		print "Apr�s create_new_server : ", scalar (threads->list), "\n";
		
		my @second_list = threads->list;		
		is ( scalar(@second_list), scalar(@first_list) + 1, "One more thread");
		
		print "Avant appel add_thread_method : ", scalar (threads->list), "\n";

		$editor->ask_thread(
		    'stop_thread', $tid,
		);
		print "Apr�s appel stop_thread : ", scalar (threads->list), "\n";
		my @third_list = threads->list;
		
		print "Third second ", scalar (@third_list), "\n";
		is (  scalar(@third_list), scalar(@second_list) - 1, "One thread less");
		# Tests de cr�ation de thread nomm�s (m�thodes mises en commun sans augmentation du nombre d'entr�e de %get_tid_from_instance_method

		# V�rifier le bon partage du m�me objet
		# Donner la possibilit� d'avoir un objet personnel ?
		# Si oui tester le bon partage par d�faut, la diff�rence si souhait�e
        # Ajout avec une autre m�thode de classe d�finie pour l'occassion
		# V�rifier l'appel de classe correct
		# V�rifier l'h�ritage automatique
		# V�rifier l'appel de classe incorrect (appel Text::Editor::Easy avec m�thode uniquement d�finie dans la classe h�rit�e)
		# V�rifier l'impl�mentation de "->super"
		# V�rifier le non �crasement de m�thode ? (add et non overload ?)

	#Text::Editor::Easy->exit(0);
#}		