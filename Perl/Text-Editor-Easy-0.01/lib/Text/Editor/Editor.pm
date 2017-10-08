package Editor;

our $VERSION = '0.01';

use strict;
use warnings;
use Scalar::Util qw(refaddr);
use Easy::Abstract;
use threads;

#use Easy::Comm;
use Comm;
use Easy::File_manager;

# Divers attributs cach�s (cl� d'acc�s = refaddr $editor)
my %ref_Abstract;    # Contient l'objet Abstract

#my %file_name;
my %ref_undo;
my %unique_ref;

use Easy::Cursor;
use Easy::Screen;

{

    sub new {
        my ( $classe, $hash_ref ) = @_;

        # Cr�ation du "thread mod�le", g�n�rateur de tous les autres
        Comm::verify_model_thread();

        my $editor = bless \do { my $anonymous_scalar }, $classe;

        my $ref = refaddr $editor;
        $unique_ref{$ref} = $ref;

        my $zone = $hash_ref->{'zone'};
        if ( defined $zone and !CORE::ref $zone ) {
            $hash_ref->{'zone'} = Zone->named($zone);
        }

        $ref_Abstract{$ref} = verify_graphic( $hash_ref, $editor, $ref );

        verify_motion_thread( $ref, $hash_ref );

        return
          if ( !defined $ref_Abstract{$ref} );  # On n'est pas dans le process 0

        #$file_name{ $ref } = $hash_ref->{file};

        if ( defined $hash_ref->{'growing_file'} ) {
            print "GROWING FILE ..$hash_ref->{'growing_file'}\n";
        }

        my $file_tid = $editor->create_server_thread(
            'File_manager',
            [
                'delete_line',
                'get_line',
                'get_text_from_ref',
                'modify_line',
                'new_line',
                'next_line',
                'previous_line',
                'save_internal',
                'query_segments',
                'revert_internal',
                'read_next',
                'read_until',
                'read_until2',
                'create_ref_current',
                'init_read',
                'ref_of_read_next',
                'save_action',
                'save_line_number',
                'get_line_number_from_ref_internal',
                'get_ref_for_empty_structure',
                'line_seek_start',
                'empty_internal',
                'save_info',
                'load_info',
            ],
            $hash_ref->{'file'},
            $hash_ref->{'growing_file'},
            $hash_ref->{'save_info'}
        );

        # R�f�rencement de l'�diteur
        Editor->reference_editor( $ref, $hash_ref->{'zone'},
            $hash_ref->{'file'}, $hash_ref->{'name'} );

        my $new_editor;

        if ( $hash_ref->{sub} ) {

            # On demande la cr�ation d'un thread suppl�mentaire
            my $thread = $editor->create_client_thread( $hash_ref->{sub} );
            $editor->set_synchronize();
            if ( threads->tid == 0 ) {
                Editor->manage_event;
            }
        }
        else {
            $editor->set_synchronize();
        }
        print "Appel de editor on_top pour zone = ",
          $hash_ref->{'zone'}{'name'}, "\n";
        my $focus = $hash_ref->{'focus'};
        if ( !defined $focus ) {
            $editor->on_top($hash_ref);
        }
        elsif ( $focus eq 'yes' ) {
            $editor->focus($hash_ref);
        }
        return $editor;
    }

    sub file_name {
        my ($self) = @_;

        my $ref = $self->ref;
        return $self->data_file_name($ref);
    }

    sub name {
        my ($self) = @_;

        my $ref = $self->ref;
        return $self->data_name($ref);
    }

    sub manage_event {
        if ( !%ref_Abstract ) {
            print
"Il faut au moins un objet �diteur cr�� pour appeler la m�thode manage_event\n";
            exit 1;
        }
        for ( values %ref_Abstract ) {
            Abstract::manage_event($_);
            return;
        }
    }
}

sub get_displayed_editor {
    my ( $self, @editor ) = @_;

    my $Abstract_ref =
      Abstract::get_displayed_editor( $ref_Abstract{ refaddr $editor[0] } );

    for my $ref ( keys %ref_Abstract ) {
        if ( $ref_Abstract{$ref} == $Abstract_ref ) {
            my $indice = 0;
            for my $editor (@editor) {
                if ( $ref == refaddr $editor ) {
                    if (wantarray) {
                        return ( $editor, $indice );
                    }
                    else {
                        return $editor;
                    }
                }
                $indice += 1;
            }
        }
    }
}

sub revert {
    my ( $self, $line_number ) = @_;

#print "Demande de restauration du fichier ", $file_name{ refaddr $self }, "\n";
    my $wait = $self->revert_internal;

    if ( $line_number eq 'end' ) {
        return
          $self->previous_line;    # On renvoie la r�f�rence � la derni�re ligne
    }
    else {
        return $self->go_to($line_number)
          ;    # On renvoie la r�f�rence du num�ro de la ligne demad�e
    }
}

sub insert_text {
    my ( $self, $line_text, $text, $pos, $insert, $ref ) = @_;

# Attention, pour efficacit�, $line_text et $ref sont li�s
# Cette fonction devrait rester interne et ne devrait pas �tre dans l'interface ... sauf
# qu'elle se trouve dans le package Editor, donc accessible ... � voir

    if ( $ref_undo{ refaddr $self} ) {    # Gestion de l'annulation, � revoir
        my $line_number = $self->get_line_number_from_ref_internal($ref);

        my $replace = "";
        if ( length($line_text) > $pos ) {
            $replace =
              substr( $line_text, $pos, 1 ); # Longueur sup�rieur � 1 maintenant
        }

        $ref_undo{ refaddr $self}
          ->save_action( $line_number, $pos, $insert, $text, $replace );
    }

    my $start = substr( $line_text, 0, $pos );
    my $end = substr( $line_text, $pos );
    if ($insert) {
        $line_text = $start . $text . $end;
    }
    else {
        if ( length($end) > length($text) ) {
            $line_text = $start . $text . substr( $end, length($text) );
        }
        else {
            $line_text = $start . $text;
        }
    }

    $self->modify_line( $ref, $line_text );
    return $line_text;
}

sub insert_return {
    my ( $self, $text, $pos, $ref ) = @_;

    if ( $ref_undo{ refaddr $self} ) {    # Gestion de l'annulation, � revoir
        my $line_number = $self->get_line_number_from_ref_internal($ref);

#        $ref_undo{refaddr $self}->save_action( $line_number, $pos, $insert, $key, $replace );
    }

    my ( $new_text, $new_ref );
    $new_text =
      substr( $text, $pos )
      ;    # Texte de la nouvelle ligne : c'est ce qu'il y a apr�s le curseur
    $text =
      substr( $text, 0, $pos );    # Texte de la ligne modifi�e (ligne tronqu�e)
    $new_ref = $self->new_line( $ref, "after", $new_text );

    $self->modify_line( $ref, $text );
    return ( $text, $new_text, $new_ref );
}

sub save_action {
    my ( $self, $line_number, $pos, $insert, $key, $replace ) = @_;

    print "Apr�s appel :$line_number:$pos:$insert:$key;$replace:\n";

    #print "Dans save_action :$who:$line_number:$pos:$key:$insert\n";
    $self->append(
        "line $line_number,$pos ,$insert :" . $key . ":, :" . $replace . ":" );
}

sub save {
    my ( $self, $file_name ) = @_;

    $self->save_internal($file_name);

# A revoir dans le principe : il faut r�f�rencer ce changement dans Data qui doit g�n�rer un nouveau type d'�v�nement
# Cet �v�nement doit �tre catch� par le Tab principal qui changera le titre de la fen�tre principale
# Mais Data pourra d�cider de le faire lui-m�me (changer le titre) si il n'y a aucune redirection de cet �v�nement
# et une seule zone (que faire si plusieurs zones sans redirection ?....)

    #if ( $file_name ) {
    #        $self->change_title($file_name);
    #}
}

sub insert_mode {
    my ($self) = @_;

    return $self->ask2('editor_insert_mode');
}

sub set_insert {
    my ($self) = @_;

    return $self->ask2('editor_set_insert');
}

sub set_replace {
    my ($self) = @_;

    return $self->ask2('editor_set_replace');
}

sub regexp {

# entr�e :
#        - regexp : expression r�guli�re perl � rechercher
#        - line_start : ligne fichier de d�but de recherche
#        - pos_start : position de d�but de la recherche dans la ligne fichier de d�but de recherche
#        - line_stop : ligne fichier de fin de recherche (si �gale � line_start, on fait un tour complet : pas d'arr�t imm�diat)
#        - pos_stop : position de fin de la recherche dans la ligne fichier de fin de recherche

    my ( $self, $exp, $options_ref ) = @_;

    return if ( !defined $exp );

    #print "Demande de recherche de $exp\n";
    my $ref;
    my $cursor = $self->cursor;
    my $line   = $options_ref->{'line_start'};
    if ( defined $line ) {
        $ref = $line->ref if ( ref $line eq 'Line' );
    }
    if ( !defined $ref ) {
        $line = $cursor->line;
        $ref  = $line->ref;
    }

    #print "LINE $line\n";
    my $text = $self->get_text_from_ref($ref);
    return
      if ( !defined $text )
      ;    # La ligne indiqu�e a �t� supprim�e ... on ne peut pas s'y r�f�rer
           #print "Ligne de d�part de la recherche |$text|\n";

    my $pos = $options_ref->{'pos_start'};
    if ( !defined $pos ) {
        $pos = $cursor->get;
    }
    else {    # V�rification de la coh�rence
        if ( $pos > length($text) ) {
            $pos = length($text);
        }
    }

    #print "Position de d�part de la recherche |$pos|\n";

    my $regexp = qr/$exp/i;
    print "REGEXP $regexp\n";

    my $end_ref;
    my $line_stop;
    if ( defined( $line_stop = $options_ref->{'line_stop'} ) ) {
        if ( ref $line_stop eq 'Line' ) {
            $end_ref = $line_stop->ref;
        }
    }
    if ( !defined $line_stop ) {
        $line_stop = $line;
    }

    #print "LINE_STOP : $line_stop\n";
    my $ref_editor = refaddr $self;
    pos($text) = $pos;
    if ( $text =~ m/($regexp)/g ) {
        my $length    = length($1);
        my $end_pos   = pos($text);
        my $start_pos = $end_pos - $length;

#print "Trouv� dans la ligne de la position $start_pos � la position $end_pos\n";

        #print "SELF $self\n";
        my $line = Line->new( $self, $ref, );

        return ( $line, $start_pos, $end_pos );
    }

    #print "Pas trouv� � partir de la position souhait�e\n";

    $end_ref = $ref if ( !defined $end_ref );
    $text =
      $self->read_until2( { 'line_start' => $ref, 'line_stop' => $end_ref } );

    pos($text) = 0;
    while ( defined($text) ) {

        #print "$text\n";
        if ( $text =~ m/($regexp)/g ) {
            my $length    = length($1);
            my $end_pos   = pos($text);
            my $start_pos = $end_pos - $length;

#print "Trouv� dans la ligne de la position $start_pos � la position $end_pos\n";
# R�cup�ration de la r�f�rence de la ligne � faire
#print "TEXTE de la ligne trouv�e : $text\n";
            my $new_ref = $self->create_ref_current;

            #print "R�f�rence de la ligne trouv�e : $new_ref\n";

            my $line = Line->new( $self, $new_ref, );
            return ( $line, $start_pos, $end_pos );
        }
        $text = $self->read_until2( { 'line_stop' => $end_ref } );
    }

    # D�but de la ligne $ref � faire ici...

    return;    # Rien trouv�...
}

sub search {
    my ( $self, $exp, $options_ref ) = @_;

    $exp =~ s/\\/\\\\/g;
    $exp =~ s/\//\\\//g;
    $exp =~ s/\(/\\\(/g;
    $exp =~ s/\[/\\\[/g;
    $exp =~ s/\{/\\\{/g;
    $exp =~ s/\)/\\\)/g;
    $exp =~ s/\]/\\\]/g;
    $exp =~ s/\}/\\\}/g;
    $exp =~ s/\./\\\./g;
    $exp =~ s/\^/\\\^/g;
    $exp =~ s/\$/\\\$/g;

    return $self->regexp( $exp, $options_ref );
}

sub next_search {
    my ($self) = @_;

    my $ref_editor = refaddr $self;
    my $hash_ref   = $self->ask2('load_search');

    return if ( !defined $hash_ref );
    my $ref_start = $hash_ref->{'line_start'};
    $hash_ref->{'line_start'} =
      Line->new( $unique_ref{$ref_editor}, $ref_start, );
    my $ref_stop = $hash_ref->{'line_stop'};
    $hash_ref->{'line_stop'} =
      Line->new( $unique_ref{$ref_editor}, $ref_stop, );

    my ( $line, $start, $end ) = $self->regexp( $hash_ref->{'exp'}, $hash_ref );
    if ($line) {
        $self->display($line);
        $self->cursor->set( $end, $line );
    }
}

sub number {

# Horrible sub not yet optimized : very, very long ! So lazy mode (return if anything_for_me) for server thread
# Still longer as all method calls are traced and one method call is made for each single line of the file read
# Will be integrated in File_manager.pm (only one call) and optimized
    my ( $self, $line ) = @_;

    $self->init_read;
    my $text = $self->read_next;

    my $current;
    while ( defined($text) ) {
        $current += 1;
        if ( $current == $line ) {
            my $new_ref = $self->create_ref_current;
            $self->save_line_number( $new_ref, $line );
            my $ref = refaddr $self;
            return Line->new( $self, $new_ref, );
        }
        return if ( anything_for_me() );
        $text = $self->read_next;
    }

# La ligne n'a pas �t� trouv�e : elle n'existe pas (pas assez de lignes dans le fichier)
    return;
}

sub get_line_number_from_ref {
    my ( $self, $ref ) = @_;

    $| = 1;

    #print "Recherche du num�ro de la ligne ayant pour r�f�rence $ref\n";
    my $current = $self->get_line_number_from_ref_internal($ref);
    if ($current) {
        return $current;
    }

    my $ok          = $self->init_read;
    my $current_ref = $self->ref_of_read_next;
    while ( defined($current_ref) ) {

        #while ( defined ($ref)  ) {
        $current += 1;
        if ( $current_ref == $ref ) {
            return $current;
        }
        $current_ref = $self->ref_of_read_next;
    }
    return;
}

sub append {
    my ( $self, $text ) = @_;

    my ( $ref, $new_text ) = $self->previous_line();
    my $OK = $self->new_line( $ref, "after", $text );
}

sub AUTOLOAD {
    return if our $AUTOLOAD =~ /::DESTROY/;

    my ( $self, @param ) = @_;

    my $what = $AUTOLOAD;
    $what =~ s/^(\w+):://;
    print( "Dans AUTOLOAD  |", $self->file_name, "|$self|", $self->ref, "|\n" )
      if ( $what eq 'focus' );

    return Comm::ask2( $self, $what, @param );
}

sub delete_key {
    my ( $self, $text, $pos, $ref ) = @_;

    if ( $pos == length($text) ) {

        # Caract�re supprim� : <Return>
        my ( $next_ref, $next_text ) = $self->next_line($ref);

        $text .= $next_text;

        $self->modify_line( $ref, $text );

        $self->delete_line($next_ref);
        my $concat = "yes";
        return ( $text, $concat );
    }
    else {
        $text = substr( $text, 0, $pos ) . substr( $text, $pos + 1 );

        $self->modify_line( $ref, $text );
        return ( $text, "false" );    # $concat vaut "false"
    }
}

sub erase_text {                      # On supprime un ou plusieurs caract�res
    my ( $self, $number, $text, $pos, $ref ) = @_;

    if ( length($text) - $pos > $number ) {
        $text = substr( $text, 0, $pos ) . substr( $text, $pos + $number );

        $self->modify_line( $ref, $text );
        return ( $text, "false" );    # $concat vaut "false"
    }
    else {
        $text = substr( $text, 0, $pos );
        $self->modify_line( $ref, $text );
        return ( $text, "false" );    # $concat vaut "false"
    }
}

my %cursor;                           # R�f�rence au "sous-objet" cursor

sub cursor {
    my ($self) = @_;

    my $ref    = refaddr $self;
    my $cursor = $cursor{$ref};
    return $cursor if ($cursor);

#print "CURSOR abstract de editor = |", $ref_Abstract{ $ref}, '|', $unique_ref{ $ref }, '|\n';
    $cursor = Cursor->new( $self );

    $cursor{$ref} = $cursor;
    return $cursor;
}

my %screen;    # R�f�rence au "sous-objet" cursor

sub screen {
    my ($self) = @_;

    my $ref    = refaddr $self;
    my $screen = $screen{$ref};
    return $screen if ($screen);

    $screen = Screen->new( $self );

    $screen{$ref} = $screen;
    return $screen;
}

# M�thode insert : renvoi d'objets "Line" au lieu de r�f�rences num�riques (cas du wantarray)
sub insert {
    my ( $self, @param ) = @_;

    my $ref = refaddr $self;

    if ( !wantarray ) {
        return $self->ask2( 'insert', @param );
    }
    elsif ( CORE::ref($self) eq 'Async_Editor' )
    {    # Appel asynchrone, insert ne renvoie pas une r�f�rence de ligne
        return $self->ask2( 'insert', @param );
    }
    else {
        my @refs = $self->ask2( 'insert', @param );
        my @lines;
        for (@refs) {

# Cr�ation d'un objet ligne pour chaque r�f�rence (dans le thread de l'appelant)
            push @lines, Line->new(

#$unique_ref{ $ref },         # Cette r�f�rence n'est renseign�e que pour l'objet editeur du thread principal (tid == 0)
                $self,
                $_,
            );
        }
        return @lines;
    }
}

sub display {
    my ( $self, $line, $options_ref ) = @_;

    my $ref = refaddr $self;

    #print $line->ref, "\n";

    $self->ask2( 'display', $line->ref, $options_ref );
}

sub last {
    my ($self) = @_;

    my ($id) = $self->previous_line;

    return Line->new( $self, $id, );
}

sub first {
    my ($self) = @_;

    my ( $id, $text ) = $self->next_line;

    #print "Dans first : |$id|$text|\n";
    return Line->new(
        $self
        , # Cette r�f�rence n'est renseign�e que pour l'objet editeur du thread principal (tid == 0)
        $id,
    );
}

sub get_unique_ref {
    my ($self) = @_;

    return $unique_ref{ refaddr $self };
}

sub reference {
    my ( $self, $unique_ref ) = @_;

    return if ( !defined $unique_ref );    # Impossible de r�f�rencer undef

    # %unique_ref de Editor.pm doit dispara�tre au profit de %com_unique de Comm
    # ==> Migration � finaliser
    $unique_ref{ refaddr $self } = $unique_ref;
    $self->set_ref($unique_ref);
}

sub reference_Abstract {
    my ( $ref, $object ) = @_;

    $ref_Abstract{$ref} = $object;
}

# Ecrasement de la m�thode async du package thread mais pas moyen de la
# d�simporter (no threads 'async') et pas de meilleur nom que async...
# ==> Avertissement prototype mismatch
no warnings;

sub async {
    my ($self) = @_;

    my $async = bless \do { my $anonymous_scalar }, 'Async_Editor';
    $unique_ref{ refaddr $async} = $unique_ref{ refaddr $self};
    return $async;
}
use warnings;

sub slurp {
    my ($self) = @_;

    # This function is not safe in a multi-thread environnement
    # But if you know what you are doing...
    #print "Dans slurp de $self\n";
    my $file;

    my $number = 0;
    my $line   = $self->first;
    while ($line) {
        $number += 1;
        $file .= $line->text . "\n";
        $line = $line->next;
    }

    #print "Total lignes lues : $number\n";
    return $file;

}

#sub print_self {
#        my ( $self ) = @_;
#
#        print "SELF $self, ref self = ", CORE::ref($self), "\n";
#}

sub get_in_zone {
    my ( $self, $zone, $number ) = @_;

    my @ref = Editor->list_in_zone($zone);
    if ( scalar @ref < $number + 1 ) {
        return;
    }
    my $editor = bless \do { my $anonymous_scalar }, "Editor";
    $editor->reference( $ref[$number] );
    return $editor;
}

sub whose_name {
    my ( $self, $name ) = @_;

    my $ref = Editor->data_get_editor_from_name($name);
    if ($ref) {

        #print "R�f�rence r�cup�r�e de data |$ref|\n";
        my $editor = bless \do { my $anonymous_scalar }, "Editor";
        $editor->reference($ref);
        return $editor;
    }
    return;
}

sub whose_file_name {
    my ( $self, $file_name ) = @_;

    my $ref = Editor->data_get_editor_from_file_name($file_name);
    if ($ref) {
        my $editor = bless \do { my $anonymous_scalar }, "Editor";
        $editor->reference($ref);
        return $editor;
    }
    return;
}

sub substitute_eval_with_file {
    my ( $self, $file ) = @_;

    return if ( !defined $file );

    # Les eval sont compt�s par thread
    eval "{{;";
    my $message = $@;
    my $number  = 0;
    if ( $message =~ /eval (\d+)/ ) {
        $number = $1;

        #print "NUMBER = $number\n";
    }
    Editor->data_substitute_eval_with_file( $file, $number + 1 );
}

package Zone;
use Scalar::Util qw(refaddr);

# A modifier en un r�f�rence de scalaire...
sub new {
    my ( $classe, $hash_ref ) = @_;

    my $zone = bless $hash_ref, $classe;
    my $name = $hash_ref->{'name'};
    if ( defined $name ) {

        # le thread Data n'est peut �tre pas op�rationnel
        Async_Editor->reference_zone($hash_ref);
    }
    if ( my $new_hash_ref = $hash_ref->{'on_top_editor_change'} ) {
        Editor->reference_zone_event( $name, 'on_top_editor_change',
            $new_hash_ref, undef );
    }
    return $zone;
}

sub named {
    my ( $self, $name ) = @_;

    return if ( !defined $name );
    return Editor->zone_named($name);
}

sub list {
    my ($self) = @_;

    return Editor->zone_list;
}

package Async_Editor;
our @ISA = 'Editor';

=head1 COPYRIGHT & LICENSE

Copyright 2008 Sebastien Grommier, all rights reserved.

This program is free software; you can redistribute it and/or modify it
under the same terms as Perl itself.


=cut

1;
