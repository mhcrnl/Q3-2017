package Easy::Program::Tab;

#use Easy::Comm;
use Comm;

#sub anything_for_me {};
use File::Basename;
use strict;
use Data::Dump qw(dump);

my %tab_object;

sub on_main_editor_change {
    my $name = on_top_editor_change(@_);
    print "On main editor change : $name\n";
    $_[0]->change_title($name);
}

sub on_top_editor_change {
    my ( $new_on_top_editor, $tab_ref, $hash_ref ) = @_;

#print "\n\nDans on_top_editor_change de Tab : $new_on_top_editor, $tab_ref\n";
#print "Nom du nouveau fichier on_top : |", $new_on_top_editor->file_name, "|\n";
    my $tab_editor = $tab_object{$tab_ref};
    if ( !$tab_editor ) {
        print "Cr�ation locale l'�diteur correspondant au Tab $tab_ref\n";
        $tab_editor = bless \do { my $anonymous_scalar }, "Editor";
        $tab_editor->reference($tab_ref);
        $tab_object{$tab_ref} = $tab_editor;
    }
    my $info_ref      = $tab_editor->load_info;
    my $file_list_ref = $info_ref->{'file_list'};

    # Attention, file_name peut �tre ind�fini, il faut �galement tester name...
    my $file_name = $new_on_top_editor->file_name;

    my $indice = 0;
    my $start  = 0;
    my $end;
    my $found_ref;
    my $tab_line = "";
  FILE: for my $file_conf_ref ( @{$file_list_ref} ) {
        $indice += 1;
        my $name = $file_conf_ref->{'name'};
        $end += length($name);
        $tab_line .= $name . ' ';
        if ( $file_conf_ref->{'file'} eq $file_name ) {
            print "Trouv� $file_name en position $indice, de $start � $end\n";
            $found_ref = [ $start, $end ];

            #last FILE;
        }
        $start += length( $file_conf_ref->{'name'} ) + 1;
        $end   += 1;
    }
    if ( !$found_ref ) {
        print "PAs trouv� le nom de $file_name";
        my @highlight = ();
        my @file      = ();
        my $name;

        if ( defined $hash_ref ) {
            if ( my $highlight = $hash_ref->{'highlight'} ) {
                @highlight = ( 'highlight', $highlight );
            }
            my $file;
            if ( $file = $hash_ref->{'file'} ) {
                @file = ( 'file', $file );
            }
            $name = $hash_ref->{'name'};
            if ( !defined $name ) {
                if ( defined $file ) {    # Redondance avec Data : � voir ...
                    $name = fileparse($file);
                }
                else {
                    $name = 'buffer';
                }
            }
        }
        else {
            $name = 'buffer';
        }
        push @{$file_list_ref}, { @highlight, @file, 'name' => $name };
        $found_ref = [ $start, $end + length($name) ];
        $tab_line .= $name . ' ';

        $info_ref->{'file_list'} = $file_list_ref;    # Utile ?
        $tab_editor->save_info($info_ref);
    }

    #print "For�age de la ligne 1 de tab_editor � $tab_line\n";
    my $first = $tab_editor->first;
    if ( !$first ) {
        ($first) = $tab_editor->insert($tab_line);
        if ( !$first ) {
            print STDERR "Probl�me de cr�ation de la premi�re ligne pour Tab\n";
        }
    }
    else {
        my $text = $first->text;
        if ( $text ne $tab_line ) {

            #$first->set($tab_line);
            $tab_editor->cursor_set(0);
            $tab_editor->erase( length($text) );
            $tab_editor->insert($tab_line);
        }
    }
    $tab_editor->deselect;

    #print "First $first\n";
    return $first->select( $found_ref->[0], $found_ref->[1],
        $info_ref->{'color'} );
}

sub motion_over_tab {
    my ( $unique_ref, $editor, $hash_ref ) = @_;

    # V�rification que l'on est bien sur la premi�re ligne
    return if ( anything_for_me() );

    my $first_line   = $editor->first;
    my $pointed_line = $hash_ref->{'line'};
    return if ( $first_line != $pointed_line );

    my $pos = $hash_ref->{'line_pos'};

    return if ( anything_for_me() );
    my $info_ref = $editor->load_info;
    return if ( anything_for_me() );
    my $file_list_ref = $info_ref->{'file_list'};

    my $file_ref      = 0;
    my $current_left  = 0;
    my $current_right = 0;
    my $name;
  FILE: for my $file_conf_ref ( @{$file_list_ref} ) {
        $name = $file_conf_ref->{'name'};
        my $length = length($name);
        $current_right += $length;
        if ( $pos >= $current_left and $pos <= $current_right ) {

            #print "POS $pos|$name| left $current_left, right $current_right\n";
            $file_ref = $file_conf_ref;
            last FILE;
        }
        return if ( anything_for_me() );
        $current_left  += $length + 1;
        $current_right += 1;
    }
    return if ( anything_for_me() );
    if ( !defined $file_ref or CORE::ref $file_ref ne 'HASH' ) {

        # Bug � voir
        $file_ref = {};
    }

    #print "FILE _ref |$name|$file_ref->{'file'}\n";
    my $new_on_top = Editor->whose_name($name);
    if ( !$new_on_top ) {

   # L'�diteur n'existe pas on le cr�e � la vol�e
   #print "Cr�ation d'un �diteur par motion sur tab : ", dump ($file_ref), "\n";
        return if ( !$file_ref->{'zone'} );
        $file_ref->{'focus'} = 'yes';
        $new_on_top = Editor->new($file_ref);

    }
    else {

#print "Avant demande de changement de focus |", $new_on_top->ref, $new_on_top->file_name, "|", $new_on_top->name,"|\n";
        $new_on_top->focus;
    }

#print "Fichier du nouveau new_on_top : |", $new_on_top->file_name, "|$new_on_top|", $new_on_top->ref, "|\n";
}

1;
