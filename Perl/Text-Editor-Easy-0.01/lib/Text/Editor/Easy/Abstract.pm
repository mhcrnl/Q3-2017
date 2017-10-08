package Abstract;

use warnings;
use strict;

# Affichage
#use Gtk_glue;
use Easy::Graphic::Tk_glue;

# Maybe with version 1.0, here lies the explanation of my ugly re-use of the Editor module (no specific Tk tab...)
#use Graphic::Console_glue;

# Syntaxe
use Easy::Syntax::perl_assist;

# Communication
#use Easy::Comm;
use Comm;

use Scalar::Util qw(refaddr);
use Devel::Size qw(size total_size);

my $origin = 'graphic';    # Gestion de la provenance des actions
my $sub_origin;            # Idem

# Chaque element ligne de la liste cha�n�e fera r�f�rence � un tableau contenant les elements suivants
use constant {

    #------------------------------------
    # LINE_REF : Lignes de texte
    #------------------------------------
    TEXT => 0,             # Texte de la ligne
    NEXT => 1
    , # Element texte qui suit cet element (juste � droite ou premier de la ligne suivante)
    PREVIOUS => 2
    , # Element texte qui prec�de cet element (juste � gauche ou dernier element de la ligne precedente)
    FIRST => 3,   # Premier element texte de la ligne, premi�re ligne du segment
                  #LINE_NUMBER => 4,  # A supprimer
    SIZE  => 5,   # Absisse maximum de la ligne
    PREVIOUS_SAME =>
      6,          # bool�en : la ligne pr�c�dente est "la m�me" : mode "wrap"
    HEIGHT    => 7,
    NEXT_SAME =>,
    10,           # bool�en : la ligne suivante est "la m�me" : mode "wrap"
    DISPLAYED => 8,    # bool�en : la ligne est affich�e � l'�cran
    REF       => 9
    , # R�f�rence � stoker pour communiquer avec le thread gestionnaire du fichier et des mises � jour
    ORD => 11,

    LAST =>
      13,    # R�f�rence au dernier �l�ment texte du segment : jamais utilis� !
     # alors que seulement la 1�re et la derni�re sont utiles pour le positionnement de la scollbar
     #------------------------------------
     # CURSOR_REF
     #------------------------------------
    VIRTUAL_ABS         => 0,
    POSITION_IN_TEXT    => 1,
    POSITION_IN_DISPLAY => 2,
    TEXT_REF            => 3,

    #ABS => 4,
    POSITION_IN_LINE => 5,

#------------------------------------
# TEXT_REF
#------------------------------------
# Element texte (element FIRST de chaque element de ligne, $text_ref ...)
#TEXT          => 0,
#NEXT          => 1, # Element texte suivant (juste � droite ou premier de la ligne suivante)
#PREVIOUS    => 2, # Element texte pr�c�dant (juste � gauche ou dernier element de la ligne precedente)
    ID =>
      3, # Identifiant affect� par Tk � l'element texte du canevas correspondant
    ABS   => 4,
    FONT  => 5,
    WIDTH => 6
    , # Indique la largeur de l'element (compte-tenu de la fonte), �quivalent � :
    LINE_REF =>
      7, # Reference � l'element ligne (c'est-�-dire � une reference de tableau)
    COLOR           => 8,    # Couleur d'affichage
                             #------------------------------------
                             # SCREEN_REF
                             #------------------------------------
    MARGIN          => 0,
    VERTICAL_OFFSET => 1,

    #HORIZONTAL_OFFSET => 2, # Supprim�
    WRAP        => 4,
    LINE_HEIGHT => 8,
    FONT_HEIGHT => 9,

    #HEIGHT => 7,
    #------------------------------------
    # EDIT_REF
    #------------------------------------
    INSER     => 0,
    SCREEN    => 1,
    SEGMENT   => 2,
    SUB_REF   => 3,
    GRAPHIC   => 4,
    REGEXP    => 5,
    CALC_LINE => 6,
    CURSOR    => 7,
    FILE      => 8,
    RETURN    => 10,    # Test de redirection
    UNIQUE    => 11,    # Editor unique identifier
    INIT_TAB  => 12,
    PARENT    => 13,
    REDIRECT  => 14,
    ASSIST    => 15,
};

use Easy::Key;
my %key = (
    'Insert' => \&Key::inser,
    'Prior'  => \&Key::page_up,
    'Next'   => \&Key::page_down,

    'Down'  => \&Key::down,
    'Up'    => \&Key::up,
    'Home'  => \&Key::home,
    'End'   => \&Key::end,
    'Left'  => \&Key::left,
    'Right' => \&Key::right,

# Fonctions d�rout�es vers Editor pour r�cup�rer l'objet Abstract en entr�e des proc�dures
# (utilisation du m�canisme d'AUTOLOAD du package Editor)
    'Return'   => [ \&Editor::enter, { 'indent' => 'auto' } ],
    'KP_Enter' => [ \&Editor::enter, { 'indent' => 'auto' } ],
    'Delete'   => [ \&Editor::erase, 1 ],

    'BackSpace'  => \&Key::backspace,
    'ctrl_End'   => \&Key::end_file,
    'ctrl_Home'  => \&Key::top_file,
    'ctrl_Right' => \&Key::jump_right,
    'ctrl_Left'  => \&Key::jump_left,
    'ctrl_q'     => \&Key::query_segments,
    'ctrl_Q'     => \&Key::query_segments,
    'ctrl_s'     => \&Key::save,
    'ctrl_S'     => \&Key::save,

    'F3' => \&Editor::next_search,

    'ctrl_c' => \&Key::copy_line,
    'ctrl_C' => \&Key::copy_line,

    'ctrl_r' => \&revert,
    'ctrl_R' => \&revert,

    'ctrl_v' => \&Key::paste,
    'ctrl_V' => \&Key::paste,

    'ctrl_w' => \&Key::wrap,
    'ctrl_W' => \&Key::wrap,

    'ctrl_x'    => \&Key::cut_line,
    'ctrl_X'    => \&Key::cut_line,
    'ctrl_Up'   => \&Key::jump_up,
    'ctrl_Down' => \&Key::jump_down,
    'alt_Up'    => \&Key::move_up,
    'alt_Down'  => \&Key::move_down,

    'ctrl_p'    => \&increase_line_space,
    'ctrl_P'    => \&increase_line_space,
    'ctrl_m'    => \&decrease_line_space,
    'ctrl_M'    => \&decrease_line_space,
    'ctrl_plus' => \&increase_font,

    'ctrl_shift_n' => \&Key::print_screen_number,
    'ctrl_shift_N' => \&Key::print_screen_number,
    'ctrl_shift_l' => \&Key::display_cursor_display,
    'ctrl_shift_L' => \&Key::display_cursor_display,
    'ctrl_shift_p' => \&Key::list_display_positions,
    'ctrl_shift_P' => \&Key::list_display_positions,

    'alt_ampersand' => \&Key::sel_first,
    'alt_eacute'    => \&Key::sel_second,
);

my %font;
my %color;
my %abstract
  ;   # A une r�f�rence d'�diteur unique, on fait correspondre un objet Abstract

# Redirection
my %redirect = do "Easy/Data/Events.pm";
my %event_zone;

my %use;

sub new {
    my ( $classe, $hash_ref, $editor, $unique_ref ) = @_;

    #print "Dans Abstract::new : ", $hash_ref->{'zone'}->{'name'}, "\n";

    # D�but construction
    my $edit_ref = bless [], $classe;
    $edit_ref->[UNIQUE] = $unique_ref;

    $abstract{$unique_ref} = $edit_ref;

    #$edit_ref->[QUEUE] = $hash_ref->{graphic_queue};
    $edit_ref->[INSER] = 1;

    if ( $hash_ref->{return} ) {
        $edit_ref->[RETURN] = $hash_ref->{return};
    }

    # Affectation des fonctions de redirection
    for my $redirect ( keys %redirect ) {
        my $redirect_ref = $hash_ref->{$redirect};
        if ( defined $redirect_ref ) {
            if ( $redirect_ref->{'mode'} eq 'async' ) {

                #print "Redirection de $redirect asynchrone...\n";
                $edit_ref->[REDIRECT]{$redirect} = $redirect;
            }
            else {
                my $use = $redirect_ref->{'use'};
                if ( defined $use and !$use{$use} ) {
                    eval "use $use";
                    print "EVAL use $use en erreur\n$@\n" if ($@);
                    $use{$use} = 1;
                }
                my $package = $redirect_ref->{'package'};
                $package = 'main' if ( !defined $package );
                if ( my $sub = $redirect_ref->{'sub'} ) {
                    my $string = "\\&" . $package . "::$sub";

                    #print "STRING $string|$package\n";
                    $edit_ref->[REDIRECT]{$redirect} =
                      eval "\\&${package}::$sub";

                    #$edit_ref->[REDIRECT]{$redirect} = eval $string;
                }
                if ( my $init_ref = $redirect_ref->{'init'} ) {
                    my @init   = @$init_ref;
                    my $string = "\\&" . $package . "::" . shift(@init);

                   #print "STRING $string|$package\n";
                   #$edit_ref->[REDIRECT]{$redirect} = eval "\\&$package::$sub";
                    my $sub_ref = eval $string;
                    $sub_ref->( $editor, @init );
                }
            }
        }
    }
    reference_event_conditions( $unique_ref, $hash_ref );

    #$edit_ref->[FILE] = $ARGV[0] || "../test.hst";
    $edit_ref->[FILE] = $hash_ref->{file} || '*buffer*';

    $edit_ref->[SCREEN][VERTICAL_OFFSET] = 0;
    $edit_ref->[SCREEN][WRAP]            = 0;

    #$edit_ref->[CALC_LINE] = 0;
    $edit_ref->[PARENT] = $editor;

    #print "Edit_ref $edit_ref est li� � $editor (", ref ($editor), ")\n";

    $edit_ref->[ASSIST] = 0;
    if ( my $tab_ref = $hash_ref->{'highlight'} ) {
        if ( my $use = $tab_ref->{'use'} ) {
            eval "use $use";
            print "EVAL use $use en erreur\n$@\n" if ($@);
            if ( $use eq 'Syntax::Perl_glue' ) {
                $edit_ref->[ASSIST] = 1;
            }
        }
        my $package;
        $package = $tab_ref->{'package'};
        $package = 'main' if ( !defined $package );
        my $sub = $tab_ref->{'sub'};
        $edit_ref->[SUB_REF] = eval "\\&${package}::$sub";
    }
    my ( $width, $height, $x_offset, $y_offset ) =
      ( 1272, 740, 0, 0 );    # for my screen
    if ( defined $hash_ref->{'width'} ) {
        $width = $hash_ref->{'width'};
    }
    if ( defined $hash_ref->{'height'} ) {
        $height = $hash_ref->{'height'};
    }
    if ( defined $hash_ref->{'x_offset'} ) {
        $x_offset = $hash_ref->{'x_offset'};
    }
    if ( defined $hash_ref->{'y_offset'} ) {
        $y_offset = $hash_ref->{'y_offset'};
    }
    $edit_ref->[GRAPHIC] = Graphic->new(
        {
            'title'                       => $edit_ref->[FILE],
            'width'                       => $width,
            'height'                      => $height,
            'x_offset'                    => $x_offset,
            'y_offset'                    => $y_offset,
            'vertical_scrollbar_sub'      => \&scrollbar_move,
            'vertical_scrollbar_position' => 'right',
            'background'                  => 'light grey',
            'clic'                        => \&clic_text,
            'mouse_move'                  => \&move_text,
            'resize'                      => \&resize,
            'key_press'                   => \&key_press,
            'mouse_wheel_event'           => \&mouse_wheel_event,

            #'key_release' => \&key_release,
            %{$hash_ref},
            'editor_ref' => $edit_ref,
        }
    );

    $edit_ref->[SCREEN][FONT_HEIGHT] = 15;
    $edit_ref->[SCREEN][LINE_HEIGHT] = $edit_ref->[GRAPHIC]->line_height;
    $edit_ref->[SCREEN][MARGIN]      = $edit_ref->[GRAPHIC]->margin;

    # Gestion des fontes � �tudier ...
    my $default_font = $edit_ref->[GRAPHIC]->create_font(
        {
            'family' => 'courier',
            'size'   => $edit_ref->[SCREEN][FONT_HEIGHT],
            'weight' => 'normal',
        }
    );
    my $bold_font = $edit_ref->[GRAPHIC]->create_font(
        {
            'family' => 'courier',

            #'size'   => $edit_ref->[SCREEN][FONT_HEIGHT] +15,
            'size'   => $edit_ref->[SCREEN][FONT_HEIGHT],
            'weight' => 'bold',
        }
    );
    my $underline_font = $edit_ref->[GRAPHIC]->create_font(
        {
            'family' => 'courier',
            'size'   => $edit_ref->[SCREEN][FONT_HEIGHT],
            'weight' => 'normal',

            #   'underline' => 1,
            'slant' => 'italic',
        }
    );
    my $font_comment = $edit_ref->[GRAPHIC]->create_font(
        {
            'family' => 'lucidabright',
            'size'   => $edit_ref->[SCREEN][FONT_HEIGHT],
            'weight' => 'normal',

            #'slant' => 'italic',
        }
    );

    %font = (
        'default'           => $default_font,
        'comment'           => $font_comment,
        'error'             => $default_font,
        'blue'              => $default_font,
        'dark red'          => $default_font,
        'dark green'        => $default_font,
        'green'             => $default_font,
        'dark blue'         => $default_font,
        'dark purple'       => $default_font,
        'yellow'            => $default_font,
        'black'             => $default_font,
        'red'               => $default_font,
        'pink'              => $default_font,
        'Comment_Normal'    => $font_comment,
        'Comment_POD'       => $font_comment,
        'Directive'         => $bold_font,
        'Label'             => $default_font,
        'Quote'             => $default_font,
        'String'            => $default_font,
        'Subroutine'        => $bold_font,
        'Variable_Scalar'   => $default_font,
        'Variable_Array'    => $bold_font,
        'Variable_Hash'     => $bold_font,
        'Variable_Typeglob' => $bold_font,
        'Whitespace'        => $default_font,
        'Character'         => $default_font,
        'Keyword'           => $bold_font,
        'Builtin_Function'  => $bold_font,
        'Builtin_Operator'  => $bold_font,
        'Operator'          => $default_font,
        'Bareword'          => $default_font,
        'Package'           => $bold_font,
        'Number'            => $default_font,
        'Symbol'            => $bold_font,
        'CodeTerm'          => $bold_font,
        'DATA'              => $default_font,
        'DEFAULT'           => $default_font,
    );
    %color = (
        'default'           => '#000000000000',
        'comment'           => 'blue',
        'error'             => 'red',
        'blue'              => 'blue',
        'dark red'          => 'dark red',
        'dark green'        => 'dark green',
        'green'             => 'green',
        'dark blue'         => 'dark blue',
        'dark purple'       => 'purple',
        'yellow'            => 'orange',
        'black'             => 'black',
        'red'               => 'red',
        'pink'              => 'black',
        'Comment_Normal'    => 'dark green',
        'Comment_POD'       => 'orange',
        'Directive'         => 'dark blue',
        'Label'             => 'dark red',
        'Quote'             => 'firebrick',
        'String'            => 'deep pink',
        'Subroutine'        => 'dark green',
        'Variable_Scalar'   => 'dark blue',
        'Variable_Array'    => 'navy blue',
        'Variable_Hash'     => 'dark green',
        'Variable_Typeglob' => 'purple',
        'Whitespace'        => 'blue',
        'Character'         => 'dark cyan',
        'Keyword'           => 'black',
        'Builtin_Function'  => 'black',
        'Builtin_Operator'  => 'black',
        'Operator'          => 'firebrick',
        'Bareword'          => 'dark red',
        'Package'           => 'gold4',
        'Number'            => 'black',
        'Symbol'            => 'black',
        'CodeTerm'          => 'brown',
        'DATA'              => 'RoyalBlue4',
        'DEFAULT'           => 'violet red',
    );

    $edit_ref->[INIT_TAB] = $hash_ref->{config};

    return $edit_ref;

}    # Fin sub init_ref

my %ref_sub;

sub examine_external_request {
    my ($edit_ref) = @_
      ; # L'�diteur va �tre envoy� lors de chaque requ�te (sous la forme de l'identifiant unique)

    #while ( anything_for_me ) { # Ne marche pas bien sous Linux (?)
    if ( anything_for_me() ) {
        my ( $what, @param ) = get_task_to_do();

        if ( !$ref_sub{$what} ) {

    #warn "La fonction $what ne peut pas �tre g�r�e par ce thread (Abstract)\n";
    #print "On essaie quand m�me (appel ask2 possible...)\n";
            my $ref_sub = eval "\\&$what";
            $ref_sub{$what} = $ref_sub;
            $origin         = $param[0];
            $sub_origin     = $what;
            simple_call( undef, $ref_sub{$what}, @param );
        }
        else {
            $origin     = $param[0];
            $sub_origin = $what;
            simple_call( undef, $ref_sub{$what}, @param );
        }
        $origin     = 'graphic';
        $sub_origin = undef;
    }
}

sub new_editor {
    Comm::new_editor(@_);
}

sub test {
    my ( $self, @param ) = @_;

    # G�n�ration d'un dead lock
    print "D�but test : ", cursor_position_in_display($self), "\n";

    if (wantarray) {
        print "Dans test : Contexte de liste\n";
        $self->[PARENT]->append("Dans test : Contexte de liste");
        return ( $param[4]->{cursor_pos_in_line}, $param[3] );
    }
    elsif ( defined(wantarray) ) {
        print "Dans test : Contexte scalaire\n";
        if ( $param[1] eq 'test undef' ) {
            return;
        }
        else {
            return $param[2];
        }
    }
    else {
        print "Dans TEST : Contexte vide\n";
    }
}

# On donne la main au gestionnaire d'�v�nement : le thread principal n'ex�ctera plus que examine_external_request p�riodiquement
sub manage_event {
    my ($edit_ref) = @_;
    $edit_ref->[GRAPHIC]->manage_event();

}

#-------------------------------------------------
# "From file to memory" functions
#-------------------------------------------------

sub read_next_line {
    my ( $edit_ref, $prev_line_ref ) = @_;

    my $ref;
    if ($prev_line_ref) {
        $ref = $prev_line_ref->[REF];
    }
    my ( $last, $text ) = $edit_ref->[PARENT]->next_line($ref);

    if ( !$last ) {
        return;
    }
    my $line_ref;
    $line_ref->[REF] = $last;

    chomp $text;

# Suppression des \r �ventuels : lecture d'un fichier Windows sous UNIX
# voir aussi l'instruction "read PRG" qui utilise le binmode dans write_file() lors de la sauvegarde du fichier �dit�
    $text =~ s/\r//g;

    # Suppression des tabulations ...
    $text =~ s/\t/    /g;

    $line_ref->[TEXT] = $text;

    if ($prev_line_ref) {
        $line_ref->[PREVIOUS]  = $prev_line_ref;
        $prev_line_ref->[NEXT] = $line_ref;
    }

    create_text_in_line( $edit_ref, $line_ref );

    return $line_ref;
}

sub create_line_ref_from_ref {    # Cr�ation d'une ligne isol�e pour affichage
    my ( $edit_ref, $ref, $text ) = @_;

    if ( !defined($text) ) {
        $text = $edit_ref->[PARENT]->get_text_from_ref($ref);
    }

    return if ( !defined $text );

    my $line_ref;
    $line_ref->[REF] = $ref;

    chomp $text;

# Suppression des \r �ventuels : lecture d'un fichier Windows sous UNIX
# voir aussi l'instruction "read PRG" qui utilise le binmode dans write_file() lors de la sauvegarde du fichier �dit�
    $text =~ s/\r//g;

    # Suppression des tabulations ...
    $text =~ s/\t/    /g;

    $line_ref->[TEXT] = $text;

    create_text_in_line( $edit_ref, $line_ref );

    return $line_ref;
}

sub read_previous_line {
    my ( $edit_ref, $next_line_ref ) = @_;

    my $ref;
    if ($next_line_ref) {
        $ref = $next_line_ref->[REF];
    }

    my ( $first, $text ) = $edit_ref->[PARENT]->previous_line($ref);

    if ( !$first ) {

        # On est au d�but du fichier
        return;
    }
    my $line_ref;
    $line_ref->[REF] = $first;

    chomp $text;

# Suppression des \r �ventuels : lecture d'un fichier Windows sous UNIX
# voir aussi l'instruction "read PRG" qui utilise le binmode dans write_file() lors de la sauvegarde du fichier �dit�
    $text =~ s/\r//g;

    # Suppression des tabulations ...
    $text =~ s/\t/    /g;

    $line_ref->[TEXT] = $text;

    if ($next_line_ref) {
        $line_ref->[NEXT]          = $next_line_ref;
        $next_line_ref->[PREVIOUS] = $line_ref;
    }

    create_text_in_line( $edit_ref, $line_ref );
    return $line_ref;
}

#----------------------------------------------------------
# "In memory" functions
#----------------------------------------------------------

sub create_text_in_line {
    my ( $edit_ref, $line_ref ) = @_;

    # Suppression de tous les �ventuels �l�ments texte contenus dans la ligne
    # Affichage de la m�moire avant / apr�s : gain ?

    my @text_element;
    if ( $edit_ref->[SUB_REF] ) {

# Une proc�dure de gestion de la coloration syntaxique a �t� donn�e : on l'appelle
        @text_element = $edit_ref->[SUB_REF]->( $line_ref->[TEXT] );
    }
    else {

    # Pas de proc�dure de coloration syntaxique r�cup�r�e :
    # il n'y aura qu'un seul �l�ment texte sur la ligne avec la police "default"
        $text_element[0] = [ $line_ref->[TEXT], 'default' ];
    }

    my $previous_element_ref;
    my $abs = $edit_ref->[SCREEN][MARGIN];

    my $total_letters = 0;
  ELT: for my $element_ref (@text_element) {
        my $text_ref
          ; # Cette variable est locale, mais elle subsitera apr�s le 'for' (r�f�rences cr��es)

        $text_ref->[TEXT] = $element_ref->[0];
        if (    ( length( $text_ref->[TEXT] ) == 0 )
            and ( length( $line_ref->[TEXT] ) != 0 ) )
        {
            next ELT;
        }
        $total_letters += length( $text_ref->[TEXT] );
        my $format = $element_ref->[1];
        if ( !$font{$format} ) {
            print "Pas de font pour le format : $format\n";
            exit 1;
        }
        $text_ref->[FONT]  = $font{$format};
        $text_ref->[COLOR] = $color{$format};
        if ( !$color{$format} ) {
            print "Pas de couleur pour le format : $format\n";
            exit 1;
        }

 #print "graphic = $edit_ref->[GRAPHIC],$text_ref->[TEXT]:$text_ref->[FONT]:\n";
        $text_ref->[WIDTH] =
          $edit_ref->[GRAPHIC]
          ->length_text( $text_ref->[TEXT], $text_ref->[FONT] );
        $text_ref->[ABS] = $abs;
        $abs += $text_ref->[WIDTH];
        $text_ref->[LINE_REF] = $line_ref;

        #$line_ref->[SIZE]  += $text_ref->[WIDTH];

        if ($previous_element_ref) {
            $previous_element_ref->[NEXT] = $text_ref;
            $text_ref->[PREVIOUS]         = $previous_element_ref;
        }
        else {
            $line_ref->[FIRST] = $text_ref;
        }
        $previous_element_ref = $text_ref;
    }
    $line_ref->[SIZE] = $abs;
    if ( $total_letters != length( $line_ref->[TEXT] ) ) {
        print
"El�ments renvoy�s incoh�rents pour la ligne |$total_letters|$line_ref->[TEXT]|",
          length( $line_ref->[TEXT] ), "|\n";
        print "\n\n===> pas de coloration syntaxique pour cette ligne\n";
        print "$line_ref->[TEXT]\n";

        # Suppression des �l�ments pr�c�demment cr��s
        my $text_ref = $line_ref->[FIRST];
        print "$text_ref->[TEXT]";
        while ( $text_ref->[NEXT] ) {
            if ( $text_ref->[PREVIOUS] ) {
                undef $text_ref->[PREVIOUS][NEXT];
                undef $text_ref->[PREVIOUS];
            }
            print "$text_ref->[NEXT][TEXT]";

            #undef $text_ref->[LINE_REF];
            $text_ref = $text_ref->[NEXT];
        }
        $line_ref->[FIRST][TEXT] = $line_ref->[TEXT];
        $text_ref->[FONT]        = $font{"default"};
        $text_ref->[COLOR]       = $color{"default"};
        $text_ref->[WIDTH]       =
          $edit_ref->[GRAPHIC]
          ->length_text( $text_ref->[TEXT], $text_ref->[FONT] );
        $text_ref->[ABS]      = $edit_ref->[SCREEN][MARGIN];
        $text_ref->[LINE_REF] = $line_ref;
        $line_ref->[SIZE] = $text_ref->[WIDTH] + $edit_ref->[SCREEN][MARGIN];
    }
    return $line_ref;    # Valeur de retour sans int�r�t ?
}

sub delete_text_in_line {
    my ( $edit_ref, $line_ref ) = @_;

    # On ne sait pas travailler avec des morceaux de lignes (mode wrap)
    # --> concat�nation, il faudra r�afficher...
    while ( $line_ref->[PREVIOUS_SAME] ) {
        $line_ref = $line_ref->[PREVIOUS];
    }
    while ( $line_ref->[NEXT_SAME] ) {
        concat( $edit_ref, $line_ref, 'bottom' );
    }
    my $text_ref = $line_ref->[FIRST];
    my $next_text_ref;
    while ( $text_ref->[NEXT] ) {
        $next_text_ref = $text_ref->[NEXT];
        undef $text_ref->[NEXT];
        undef $next_text_ref->[PREVIOUS];
        $text_ref = $next_text_ref;
    }
    undef $next_text_ref->[PREVIOUS];
    undef $line_ref->[FIRST];
    return $line_ref;
}

#----------------------------------------------------------
# From memory to display functions
#----------------------------------------------------------

sub display_text_from_memory {
    my ( $edit_ref, $text_ref, $ord, $tag_ref ) = @_;

    my @tag;
    if ( defined $tag_ref ) {
        @tag = ( 'tag', $tag_ref );
    }
    else {
        @tag = ( 'tag', [ 'text', 'just_created' ] );
    }
    my ( $width, $height );
    ( $text_ref->[ID], $width, $height ) =
      $edit_ref->[GRAPHIC]->create_text_and_mark_it(
        {
            'abs'    => $text_ref->[ABS] - $edit_ref->[SCREEN][VERTICAL_OFFSET],
            'ord'    => $ord,
            'text'   => $text_ref->[TEXT],
            'anchor' => 'sw',
            'font'   => $text_ref->[FONT],
            'color'  => $text_ref->[COLOR],
            @tag
        }
      );

    #    if (!$text_ref->[WIDTH]) {
    $text_ref->[WIDTH] =
      $edit_ref->[GRAPHIC]->length_text( $text_ref->[TEXT], $text_ref->[FONT] );

#$text_ref->[ORD] = $ord;
#print "|", $text_ref->[TEXT], "|", $width, "|", $text_ref->[WIDTH], "|", $height, "|\n";
#    }
    return ( $text_ref->[WIDTH], $height );
}

sub check_cursor {

    # Une ligne compl�te vient d'�tre affich�e
    my ( $edit_ref, $line_ref ) = @_;

    if (    $edit_ref->[CURSOR]
        and $edit_ref->[CURSOR][LINE_REF]
        and $line_ref->[REF] == $edit_ref->[CURSOR][LINE_REF][REF] )
    {

        # On utilise maintenant [CURSOR][POSITION_IN_LINE]
        my $prev_line_ref = start_line($line_ref);
        my $position      = $edit_ref->[CURSOR][POSITION_IN_LINE];
        while ( $position > length( $prev_line_ref->[TEXT] ) ) {
            $position -= length( $prev_line_ref->[TEXT] );
            $prev_line_ref = $prev_line_ref->[NEXT];
        }
        position_cursor_in_display( $edit_ref, $prev_line_ref, $position );
    }
}

sub trunc {

# Appel�e lorsque l'on est en mode 'wrap' et que la ligne est trop longue par rapport � la largeur de l'�cran
# On vient de lire un �l�ment texte de trop qu'il va falloir tronquer :
#   $current_curs est trop grand (il comprend la totalit� du mot � tronquer),
#   mais on ne sait pas de combien
    my ( $edit_ref, $line_ref, $text_ref, $current_curs, $where ) = @_;

    my $position = 0;
    {
        my $length_substr = 0;
        while ( ( $text_ref->[ABS] + $length_substr ) <
            ( $edit_ref->[SCREEN][WIDTH] - $edit_ref->[SCREEN][MARGIN] ) )
        {
            $position += 1;
            my $substr = substr( $text_ref->[TEXT], 0, $position );
            $length_substr =
              $edit_ref->[GRAPHIC]->length_text( $substr, $text_ref->[FONT] );
        }
    }
    if ($position) {

# On ne peut pas avoir un nombre de caract�res n�gatifs : on sait que le texte pr�c�dent rentre
# (il n'a pas d�pass� la longueur pour d�clencher le trunc avant, mais il peut �tre tomb� sur la limite : �galit�)
# Il est possible de ne mettre aucun caract�re du "$text_ref" actuel mais pas -1
#  ==> Le test de "$position" � vrai est donc pour le cas o� l'on ne rentre m�me pas dans la
# boucle "while" pr�c�dente
# Ce cas tr�s particulier arrive uniquement lorsqu'il y a �galit� entre $text_ref->[ABS] et la partie droite
        $position -= 1;
    }

#print "Dans trunc MT |", length($line_ref->[TEXT]), "| M1 |",  $position, "| M2 |", length($line_ref->[TEXT]) - $position, "|\n";
    return divide_line( $edit_ref, $line_ref, $text_ref,
        $current_curs - length( $text_ref->[TEXT] ) + $position,
        $position, $where );
}

sub divide_line {

# On divise une ligne en 2 (cr�ation d'une nouvelle ligne) :
#    - soit parce que l'on est en mode 'wrap' et que la ligne est trop longue (dans
#         ce cas, $new est 'false')
#    - soit parce que l'on en cr�e une (appui sur "return"), $new est 'true'
#
#

    my ( $edit_ref, $line_ref, $text_ref, $position_in_line, $position_in_text,
        $where, $new )
      = @_;

    $edit_ref->[GRAPHIC]->change_text_item_property( $text_ref->[ID],
        substr( $text_ref->[TEXT], 0, $position_in_text ),
    );

    my $new_line_ref;
    $new_line_ref->[TEXT] = substr( $line_ref->[TEXT], $position_in_line );
    $line_ref->[TEXT] = substr( $line_ref->[TEXT], 0, $position_in_line );
    my $first_text_ref;
    @{$first_text_ref} =
      @{$text_ref};    # El�ments �gaux, mais r�f�rence diff�rente
    $first_text_ref->[TEXT] = substr( $text_ref->[TEXT], $position_in_text );
    $text_ref->[TEXT] = substr( $text_ref->[TEXT], 0, $position_in_text );
    undef $first_text_ref->[PREVIOUS];

    if ( $position_in_text == 0 ) {
        undef $text_ref->[PREVIOUS][NEXT];
        undef $text_ref->[PREVIOUS];
    }
    undef $text_ref->[NEXT];

    # Mise � jour de $first_text_ref->[WIDTH] � voir
    if ( $first_text_ref->[NEXT] ) {
        $first_text_ref->[NEXT][PREVIOUS] = $first_text_ref;
    }

    # Recalcul de la hauteur de la ligne fraichement tronqu�e
    $line_ref->[HEIGHT] = 0;
    my $temp_text_ref = $line_ref->[FIRST];
    while ($temp_text_ref) {
        my ( $width, $height ) =
          $edit_ref->[GRAPHIC]->size_id( $temp_text_ref->[ID] );
        $line_ref->[HEIGHT] = $height if ( $height > $line_ref->[HEIGHT] );
        $temp_text_ref = $temp_text_ref->[NEXT];
    }

    $new_line_ref->[FIRST]    = $first_text_ref;
    $new_line_ref->[PREVIOUS] = $line_ref;
    if ( !$new ) {
        $new_line_ref->[PREVIOUS_SAME] = 1;
    }

    $new_line_ref->[NEXT]       = $line_ref->[NEXT];
    $new_line_ref->[NEXT_SAME]  = $line_ref->[NEXT_SAME];
    $line_ref->[NEXT][PREVIOUS] = $new_line_ref;
    $line_ref->[NEXT]           = $new_line_ref;
    if ( !$new ) {
        $line_ref->[NEXT_SAME] = 1;
    }
    else {
        $line_ref->[NEXT_SAME] = 0;
    }
    while ($first_text_ref) {
        $first_text_ref->[LINE_REF] = $new_line_ref;
        $first_text_ref = $first_text_ref->[NEXT];
    }
    if ( length( $text_ref->[TEXT] ) == 0 ) {
        suppress_text( $edit_ref, $text_ref );
    }
    $new_line_ref->[REF] = $line_ref->[REF];

    if ( $edit_ref->[CURSOR][LINE_REF] == $line_ref ) {
        if ( $edit_ref->[CURSOR][POSITION_IN_DISPLAY] >
            length( $line_ref->[TEXT] ) )
        {
            $edit_ref->[CURSOR][POSITION_IN_DISPLAY] -=
              length( $line_ref->[TEXT] );
            $edit_ref->[CURSOR][LINE_REF] = $new_line_ref;

# Impossible de positionner le curseur � ce stade : les �l�ments texte ne sont pas encore cr��s
        }
    }
    return $new_line_ref;
}

sub concat {
    my ( $edit_ref, $line_ref, $where ) = @_;

  # Si l'on concat�ne, c'est que l'on n'a pas encore affich� :
  # par pr�caution, il faut supprimer tous les �l�ments texte canevas
  # des 2 lignes �concat�ner, car si sur une des 2 lignes concat�n�es, il
  # y en a une qui est d�j� affich�e, on va la r�afficher et perdre la r�f�rence
  # des �l�ments texte canevas pr�c�dents (qui ne seront donc plus supprimables)
    suppress_from_screen_line( $edit_ref, $line_ref );
    suppress_from_screen_line( $edit_ref, $line_ref->[NEXT] );

    $line_ref->[TEXT] = $line_ref->[TEXT] . $line_ref->[NEXT][TEXT];

    if ( $line_ref->[NEXT][NEXT] ) {
        $line_ref->[NEXT][NEXT][PREVIOUS] = $line_ref;
    }
    $line_ref->[NEXT_SAME] = $line_ref->[NEXT][NEXT_SAME];
    my $text_ref = $line_ref->[FIRST];
    while ( $text_ref->[NEXT] ) {
        $text_ref = $text_ref->[NEXT];
    }
    $text_ref->[NEXT] = $line_ref->[NEXT][FIRST];
    $line_ref->[NEXT][FIRST][PREVIOUS] = $text_ref;
    while ( $text_ref->[NEXT] ) {
        $text_ref = $text_ref->[NEXT];
        $text_ref->[LINE_REF] = $line_ref;
    }

    if ( $edit_ref->[CURSOR][LINE_REF] == $line_ref->[NEXT] ) {
        $edit_ref->[CURSOR][LINE_REF] = $line_ref;
        $edit_ref->[CURSOR][POSITION_IN_DISPLAY] +=
          length( $line_ref->[TEXT] ) - length( $line_ref->[NEXT][TEXT] );
    }
    $line_ref->[NEXT] = $line_ref->[NEXT][NEXT];

    return $line_ref;

    #        display_everything ( $edit_ref );
}

sub suppress_from_screen_line {
    my ( $edit_ref, $line_ref, $speed ) = @_;

    my $text_ref = $line_ref->[FIRST];

    while ($text_ref) {

        #print "$text_ref->[TEXT]|";
        $edit_ref->[GRAPHIC]->delete_text_item( $text_ref->[ID], $speed );
        delete $text_ref->[ID];
        my $next_ref = $text_ref->[NEXT];
        delete $text_ref->[PREVIOUS];
        delete $text_ref->[NEXT];
        $text_ref = $next_ref;

        #last TEXT if ( !$text_ref );
    }

    #print "\n";
    $line_ref->[DISPLAYED] = 0;

    # Lib�ration de la r�f�rence et m�nage interne � Abstract.pm
}

sub suppress_from_screen_complete_line {
    my ( $edit_ref, $line_ref ) = @_;

    while ( $line_ref->[PREVIOUS_SAME] ) {
        $line_ref = $line_ref->[PREVIOUS];
    }
    suppress_from_screen_line( $edit_ref, $line_ref );
    while ( $line_ref->[NEXT_SAME] ) {
        $line_ref = $line_ref->[NEXT];
        suppress_from_screen_line( $edit_ref, $line_ref );
    }
}

sub suppress_text {
    my ( $edit_ref, $text_ref ) = @_;
    if ( $text_ref->[ID] ) {
        $edit_ref->[GRAPHIC]->delete_text_item( $text_ref->[ID] );
    }
    if ( $text_ref->[PREVIOUS] ) {
        $text_ref->[PREVIOUS][NEXT] = $text_ref->[NEXT];
    }
    if ( $text_ref->[NEXT] ) {
        $text_ref->[NEXT][PREVIOUS] = $text_ref->[PREVIOUS];
    }
}

sub clic_text {
    my ( $edit_ref, $x, $y ) = @_;

    if ( $origin eq 'graphic' and !$sub_origin ) {
        $sub_origin = 'clic';
    }

    my $line_ref = get_line_ref_from_ord( $edit_ref, $y );

    #my $display_ref = get_display_ref_from_ord($edit_ref, $y);
    my $display_ref = get_display_ref_from($line_ref);
    my $pos = get_position_from_line_and_abs( $edit_ref, $line_ref, $x );
    my $ref_under_cursor = $line_ref->[REF];

    if ( my $sub_ref = $edit_ref->[REDIRECT]{'clic_last'} ) {
        $edit_ref->[PARENT]->redirect(
            $sub_ref,
            $edit_ref,
            {
                'line'        => $ref_under_cursor,
                'display'     => $display_ref,
                'display_pos' => $pos,
            }
        );
    }
    else {
        cursor_set( $edit_ref, { 'x' => $x, 'y' => $y } );
        $edit_ref->[GRAPHIC]->canva_focus;
        $edit_ref->deselect;
        cursor_make_visible($edit_ref);
    }
}

sub move_text {
    my ( $edit_ref, $x, $y ) = @_;

    if ( $origin eq 'graphic' and !$sub_origin ) {
        $sub_origin = 'motion';
        print "Move text : $x|$y|\n";
    }

    my $line_ref = get_line_ref_from_ord( $edit_ref, $y );

    #my $display_ref = get_display_ref_from_ord($edit_ref, $y);
    my $display_ref = get_display_ref_from($line_ref);
    my $display_pos =
      get_position_from_line_and_abs( $edit_ref, $line_ref, $x );
    my $line_pos = $display_pos;
    while ( $line_ref->[PREVIOUS_SAME] ) {
        $line_ref = $line_ref->[PREVIOUS];
        $line_pos += length( $line_ref->[TEXT] );
    }

    my $ref_under_cursor = $line_ref->[REF];

# La redirection n'est pas forc�ment r�f�renc�e dans le thread Motion
# Cela aura pour effet d'arr�ter l'ex�cution d'une proc�dure que l'utilisateur souhaite abandonner (effet souhait�)
    $edit_ref->[PARENT]->redirect(
        'motion_last',
        $edit_ref,
        {
            'line'        => $ref_under_cursor,
            'display'     => $display_ref,
            'display_pos' => $display_pos,
            'line_pos'    => $line_pos,
        }
    );

}

sub deselect {
    my ($self) = @_;

    $self->[GRAPHIC]->delete_select;
}

sub get_position_from_line_and_abs {
    my ( $edit_ref, $line_ref, $x ) = @_;

    my $position = 0;
    my $text_ref = $line_ref->[FIRST];
    while (
        $text_ref->[NEXT
        ]   # Ne pas creer de tableau par autovivification si pas d'element NEXT
        and $text_ref->[NEXT][ABS] - $edit_ref->[SCREEN][VERTICAL_OFFSET] < $x
      )
    {
        $position += length( $text_ref->[TEXT] );
        $text_ref = $text_ref->[NEXT];
    }

# On pourrait, pour optimisation, renvoyer $text_ref (on va le rechercher � nouveau par la suite)
    my $text                         = $text_ref->[TEXT];
    my $abs                          = $text_ref->[ABS];
    my $cursor_position_in_text_item = 0;

    # On travaille par moitie de caract�re
    return $position if ( !defined $text );    # Bug � voir
  CAR: for ( 1 .. length($text) ) {
        my $sous_chaine = substr( $text, $_ - 1, 1 );
        my $increment =
          $edit_ref->[GRAPHIC]->length_text( $sous_chaine, $text_ref->[FONT] );
        if ( ( $abs + $increment / 2 ) >
            ( $x + $edit_ref->[SCREEN][VERTICAL_OFFSET] ) )
        {
            last CAR;
        }
        $abs                          += $increment;
        $cursor_position_in_text_item += 1;
    }
    return $position + $cursor_position_in_text_item;
}

sub get_line_number_from_ord {
    my ( $edit_ref, $y ) = @_;

    my $line = $y / $edit_ref->[SCREEN][LINE_HEIGHT];
    return ( int($line) );
}

sub select_text_element {
    my ( $edit_ref, $text_ref, $cursor_position_in_text, $start_text ) = @_;

    $edit_ref->[CURSOR][TEXT_REF] = $text_ref;
    $edit_ref->[CURSOR][LINE_REF] = $text_ref->[LINE_REF];

    $edit_ref->[GRAPHIC]->position_cursor_in_text_item(
        $edit_ref->[CURSOR][TEXT_REF][ID],
        $cursor_position_in_text,

        # Pour GTK2, manipulation du curseur incompr�hensible... ou impossible
        $edit_ref->[CURSOR][ABS],
        $edit_ref->[CURSOR][LINE_REF][ORD],
    );

    if ( defined($start_text) ) {
        $edit_ref->[CURSOR][POSITION_IN_DISPLAY] =
          $cursor_position_in_text + $start_text;
        $edit_ref->[CURSOR][POSITION_IN_LINE] =
          calc_line_position_from_display_position( $edit_ref->[CURSOR] );
    }
    $edit_ref->[CURSOR][POSITION_IN_TEXT] = $cursor_position_in_text;
}

sub calc_line_position_from_display_position {
    my ($cursor_ref) = @_;

    my $line_ref = $cursor_ref->[LINE_REF];
    my $position = $cursor_ref->[POSITION_IN_DISPLAY];
    while ( $line_ref->[PREVIOUS_SAME] ) {
        $line_ref = $line_ref->[PREVIOUS];
        $position += length( $line_ref->[TEXT] );
    }
    return $position;
}

sub resize {
    my ( $edit_ref, $width, $height ) = @_;

    if ( $origin eq 'graphic' and !$sub_origin ) {
        $sub_origin = 'resize';
    }

    $edit_ref->[SCREEN][WIDTH]  = $width;
    $edit_ref->[SCREEN][HEIGHT] = $height;

    if ( !$edit_ref->[SCREEN][FIRST] ) {

        # Au premier resize
        $edit_ref->[PARENT]->get_synchronized;
        init($edit_ref);

# On lance le "serveur" de thread mais uniquement lorsque l'�diteur est affich� enti�rement (revoir dans le cas multi-fichier
# ==> d�sactivation puis r�activation ?)
        $edit_ref->[GRAPHIC]
          ->launch_loop( \&examine_external_request, $edit_ref );
    }

# En cas de resize, on r�affiche en gardant constante la position de d�part de la premi�re ligne enti�re
    my $line_ref = get_first_complete_line($edit_ref);

    $edit_ref->display( $line_ref->[REF], { 'at' => 'top' } );
}

sub init {
    my ($edit_ref) = @_;

    my $ref;
    if ( $edit_ref->[INIT_TAB]{first_line_number} ) {
        my $line =
          $edit_ref->[PARENT]
          ->number( $edit_ref->[INIT_TAB]{first_line_number} );
        $ref = $line->ref if ($line);
    }
    else {
        my $line = $edit_ref->[PARENT]->number(1);
        $ref = $line->ref if ($line);
        $edit_ref->[INIT_TAB]{first_line_pos} = 0;
    }

    my $line_ref;
    if ( !$ref ) {
        $line_ref = read_next_line($edit_ref);
        if ( !$line_ref ) {

            # Fichier vide : en pratique, pour affichage, une ligne vide
            $line_ref->[TEXT] = "";
            $line_ref->[REF] = $edit_ref->[PARENT]->get_ref_for_empty_structure;
            create_text_in_line( $edit_ref, $line_ref );
        }
    }
    else {
        $line_ref = create_line_ref_from_ref( $edit_ref, $ref );

        # Cas o� la ligne est ind�finie � g�rer

    }
    $edit_ref->display( $line_ref->[REF], { 'at' => 'top' } );

    # Positionnement du curseur
    my $ref_cursor;
    if ( $edit_ref->[INIT_TAB]{cursor_line_number} ) {
        $ref_cursor =
          $edit_ref->[PARENT]
          ->go_to( $edit_ref->[INIT_TAB]{cursor_line_number} );
    }
    else {
        $ref_cursor = $line_ref->[REF];
        $edit_ref->[INIT_TAB]{cursor_pos_in_line} = 0;
    }

#print "R�f�rence trouv�e pour le curseur : $ref\n";
# Recherche de la r�f�rence parmi les lignes d�j� cr��es lors du display_from_top_line
    my $cursor_line_ref = $edit_ref->[SCREEN][FIRST];
  REF: while ( $cursor_line_ref->[REF] != $ref_cursor ) {

        #print "R�f�rence courante : ", $cursor_line_ref->[REF], "\n";
        if ( $cursor_line_ref->[NEXT] ) {
            $cursor_line_ref = $cursor_line_ref->[NEXT];
        }
        else {
            last REF;
        }
    }
    if ( $cursor_line_ref->[REF] != $ref_cursor ) {

# A la derni�re sauvegarde de session, le curseur n'�tait pas dans la zone affichable
# Pour l'instant non g�r� : on le place au d�but de la premi�re ligne affich�e � l'�cran
# A modifier �ventuellement lorsque le curseur pourra �tre hors de l'�cran � l'initialisation
        $cursor_line_ref = $line_ref;
        $edit_ref->[INIT_TAB]{cursor_pos_in_line} = 0;
    }
    $edit_ref->[CURSOR][LINE_REF] = $cursor_line_ref;
    cursor_set( $edit_ref, $edit_ref->[INIT_TAB]{cursor_pos_in_line} );
}

sub get_first_complete_line {
    my ($edit_ref) = @_;

# A partir de quelle ligne afficher et � quelle position : on regarde la position de $edit_ref->[SCREEN][FIRST]
    if ( !$edit_ref->[SCREEN][FIRST] ) {
        return;
    }
    my $line_ref = $edit_ref->[SCREEN][FIRST];
    while ($line_ref->[ORD] + $line_ref->[HEIGHT] < 0
        or $line_ref->[PREVIOUS_SAME] )
    {

# Tr�s rare de ne pas avoir de NEXT==> uniquement si la ligne occupe plus d'un �cran
        if ( !$line_ref->[NEXT] ) {
            return $edit_ref->[SCREEN][FIRST];
        }
        $line_ref = $line_ref->[NEXT];
    }
    return $line_ref;
}

sub clear_screen {
    my ($edit_ref) = @_;

    my $line_to_suppress_ref = $edit_ref->[SCREEN][FIRST];
    return if ( !$line_to_suppress_ref );

    #SUPP: while ($line_to_suppress_ref->[DISPLAYED] ) {
  SUPP: while ( $line_to_suppress_ref->[NEXT] ) {
        suppress_from_screen_line( $edit_ref, $line_to_suppress_ref );
        $line_to_suppress_ref = $line_to_suppress_ref->[NEXT];
        last SUPP if ( !$line_to_suppress_ref );
    }

    # V�rification pour traquer le bug des lignes qui ne s'effacent pas

    $edit_ref->[GRAPHIC]->clear_screen;
}

sub key_press {
    my ( $edit_ref, $key, $ascii, $options_ref ) = @_;

    if ( $origin eq 'graphic' and !$sub_origin ) {
        $sub_origin = 'key_press';
    }

    #clear_screen ( $edit_ref );
    #$edit_ref->[GRAPHIC]->clear_screen;
    #print "KEY |$key| ASCII |", ord($ascii), "| CTRL |";
    my $key_code;
    if ( $options_ref->{'ctrl'} ) {

        #print "OUI";
        $key_code = 'ctrl';
    }
    else {

        #print "NON";
    }

    #print "| ALT |";
    if ( $options_ref->{'alt'} ) {

        #print "OUI";
        $key_code .= '_' if ($key_code);
        $key_code .= 'alt';
    }
    else {

        #print "NON";
    }

    #print "| SHIFT |";
    if ( $options_ref->{'shift'} ) {

        #print "OUI";
        $key_code .= '_' if ($key_code);
        $key_code .= 'shift';
    }
    else {

        #print "NON";
    }
    $key_code .= '_' if ($key_code);
    $key_code .= $key;

    #print "$key_code\n";
    #return;

    if ( $key{$key_code} ) {

        # Une touche speciale a ete appuyee
        if ( ref( $key{$key_code} ) eq "CODE" ) {

            #print "Touche sp�ciale...\n";
            #$key{$key_code}->( $edit_ref );
            $key{$key_code}->( $edit_ref->[PARENT] );
        }
        else {
            my @tab      = @{ $key{$key_code} };
            my $code_ref = shift @tab;

            #$code_ref->( $edit_ref, @tab );
            $code_ref->( $edit_ref->[PARENT], @tab );
        }

        return;
    }

    #print "|$key|$ascii|" if ( $alt_key );
    #print "|$key|$ascii|";
    return if ( length($ascii) != 1 );

    # assist doit pointer sur une r�f�rence � un package ou une fonction
    return insert( $edit_ref, $ascii,
        { 'assist' => $edit_ref->[ASSIST], 'indent' => 'auto' } );
}

sub cursor_make_visible {
    my ($edit_ref) = @_;

    #print "Dans cursor_make_visible $edit_ref|", $edit_ref->[UNIQUE], "|\n";
    verify_if_cursor_is_visible_horizontally($edit_ref);
    verify_if_cursor_is_visible_vertically($edit_ref);
}

sub verify_if_cursor_is_visible_horizontally {
    my ($edit_ref) = @_;

    # bottom
    my ( $top, $bottom, $displayed );
    my $cursor_line_ref = $edit_ref->[CURSOR][LINE_REF];

# V�rification que la ligne qui porte le curseur fait bien partie des lignes affich�es
    if ( $cursor_line_ref == $edit_ref->[SCREEN][FIRST] ) {
        $top       = 1;
        $displayed = 1;
    }
    else {
        my $line_ref = $edit_ref->[SCREEN][FIRST];
      LINE: while ( $line_ref->[NEXT] ) {
            $line_ref = $line_ref->[NEXT];
            if ( $line_ref == $cursor_line_ref ) {
                $displayed = 1;
                last LINE;
            }
        }
        if ( $edit_ref->[SCREEN][LAST] == $cursor_line_ref ) {
            $bottom = 1;
        }
    }
    if ( !$displayed ) {
        print "Ligne non affich�e : display\n";
        return $edit_ref->display( $cursor_line_ref->[REF],
            { 'at' => 'middle' } );
    }

    # La ligne qui contient le curseur est d�j� affich�e sur le 'canevas'
    # ==> il est possible qu'elle ne soit pas visible ou qu'elle soit tronqu�e

# Inutile d'essayer de caser la ligne si l'�cran est trop petit : tests suppl�mentaires � faire

# On suppose maintenant que l'�cran est assez grand pour positionner au moins 2 lignes enti�res en hauteur

    # V�rification en haut
    if ( !$cursor_line_ref->[PREVIOUS] ) {
        my $previous_line_ref =
          read_previous_line( $edit_ref, $cursor_line_ref );
        if ( !$previous_line_ref ) {

            # On positionne la ligne qui contient le curseur en haut de l'�cran
            my $ord = $cursor_line_ref->[ORD];
            return screen_move( $edit_ref, 0,
                $cursor_line_ref->[HEIGHT] - $ord );
        }
        $edit_ref->[SCREEN][FIRST] =
          display_line_from_bottom( $edit_ref, $previous_line_ref,
            $cursor_line_ref->[ORD] - $cursor_line_ref->[HEIGHT] );
    }

# On a une ligne pr�c�dente
# Le curseur est bien positionn� vis-�-vis du haut si la ligne pr�c�dente est vue enti�rement
    my $previous_line_ref = $cursor_line_ref->[PREVIOUS];
    if ( $previous_line_ref->[ORD] - $previous_line_ref->[HEIGHT] < 0 ) {
        screen_move( $edit_ref, 0,
            $previous_line_ref->[HEIGHT] - $previous_line_ref->[ORD] );
    }

    # Le curseur est assez loin du haut, on regarde en bas
    my $next_line_ref = $cursor_line_ref->[NEXT];
    if ( !$next_line_ref ) {
        $next_line_ref = read_next_line( $edit_ref, $cursor_line_ref );
        if ( !$next_line_ref ) {

            # On positionne la ligne qui contient le curseur en bas de l'�cran
            my $shift = $edit_ref->[SCREEN][HEIGHT] - $cursor_line_ref->[ORD];
            return if ( $shift > 0 );
            return screen_move( $edit_ref, 0, $shift );
        }
        $edit_ref->[SCREEN][LAST] =
          display_line_from_top( $edit_ref, $next_line_ref,
            $cursor_line_ref->[ORD] );
    }

# On a une ligne suivante
# Le curseur est bien positionn� vis-�-vis du bas si la ligne suivante est vue enti�rement
    if ( $next_line_ref->[ORD] > $edit_ref->[SCREEN][HEIGHT] ) {
        return screen_move( $edit_ref, 0,
            $edit_ref->[SCREEN][HEIGHT] - $next_line_ref->[ORD] );
    }
}

sub verify_if_cursor_is_visible_vertically {
    my ($edit_ref) = @_;

    if ( $edit_ref->[SCREEN][WRAP] ) {

#                # On fait confiance au mode "wrap" pour ne pas �tre oblig� de se d�caler � droite ou � gauche
#                if ( $edit_ref->[SCREEN][VERTICAL_OFFSET] ) {
#                # On annule donc tout �ventuel d�calage
#                    my $decalage = -$edit_ref->[SCREEN][VERTICAL_OFFSET];
#                    $edit_ref->[CURSOR][ABS] -= $decalage;
#                    $edit_ref->[SCREEN][VERTICAL_OFFSET] = 0;
#                    $canva->move( 'text', -$decalage, 0 );
#                }
        return;
    }
    if ( $edit_ref->[CURSOR][ABS] + 20 > $edit_ref->[SCREEN][WIDTH] ) {
        my $decalage =
          $edit_ref->[CURSOR][ABS] + 20 - $edit_ref->[SCREEN][WIDTH];
        $edit_ref->[CURSOR][ABS]         -= $decalage;
        $edit_ref->[CURSOR][VIRTUAL_ABS] -= $decalage;
        $edit_ref->[SCREEN][VERTICAL_OFFSET] += $decalage;
        $edit_ref->[GRAPHIC]->move_tag( 'text', -$decalage, 0 );
    }
    if ( $edit_ref->[CURSOR][ABS] < $edit_ref->[GRAPHIC]->margin ) {
        my $decalage = 10 - $edit_ref->[CURSOR][ABS];
        $edit_ref->[CURSOR][ABS]         += $decalage;
        $edit_ref->[CURSOR][VIRTUAL_ABS] += $decalage;
        $edit_ref->[SCREEN][VERTICAL_OFFSET] -= $decalage;
        $edit_ref->[GRAPHIC]->move_tag( 'text', $decalage, 0 );
    }
}

sub update_vertical_scrollbar {
    my ($edit_ref) = @_;
    return ( 0.2, 0.4 );

# Seules les positions dans le fichier nous interesse
# Non, impossible : les positions dans le fichier sont trop lourdes � mettre � jour en cas de saisie
# Il faut utiliser le nombre de lignes. Lorsque ce nombre n'est pas connu au d�part (lecture d'un
# morceau de fichier) il faut calculer la taille moyenne d'une ligne en caract�res et faire une
# estimation du nombre total de lignes � partir de cette taille moyenne

    my $start_cursor = get_line_number_from_ord( $edit_ref, 0 );
    my $end_cursor =
      get_line_number_from_ord( $edit_ref, $edit_ref->[SCREEN][HEIGHT] ) - 2;
    if ( $end_cursor < $start_cursor ) {
        $end_cursor = $start_cursor + 1;
    }
    my ( $first_ln, $last_ln ) = get_extreme_line_number();

    my $real_end = $last_ln - $first_ln;
    return $edit_ref->[GRAPHIC]->set_scrollbar(
        ( $start_cursor - $first_ln ) / $real_end,
        ( $end_cursor - $first_ln ) / $real_end,
    );
}

sub scrollbar_move {
    my ( $edit_ref, $action, $value, $unit ) = @_;

    #    print "Action $action, value $value, unit $unit\n";

    if ( $action eq "moveto" ) {
        my ( $x, $y ) = $edit_ref->[GRAPHIC]->get_scrollbar();
        if ( $value < 0 ) {
            $value = 0;
        }
        if ( $value > 1 ) {
            $value = 1;
        }

# Il ne faut pas forc�ment agir : si l'on veut descendre alors que l'on est d�j� en bas...
        $edit_ref->[GRAPHIC]->set_scrollbar( $value, $value + $y - $x );
        print "Action $action, value $value\n";

        move_to($value);
    }
    else {

        # $action = 'scroll'
        if ( ( $value == 1 ) and ( $unit eq 'units' ) ) {
            screen_move( $edit_ref, 0, 1 );
        }
        if ( ( $value == -1 ) and ( $unit eq 'units' ) ) {
            screen_move( $edit_ref, 0, -1 );
        }
    }
}

sub suppress_top_invisible_lines {
    my ($edit_ref) = @_;

    my $screen_ref = $edit_ref->[SCREEN];

# On ne suprrime les "lignes fichier" qu'enti�rement (avec le mode wrap, certaines "lignes fichiers" s'�talent sur
# plusieurs "lignes �cran")
    my $line_ref = $screen_ref->[FIRST];
    while ( $line_ref->[NEXT_SAME] ) {
        $line_ref = $line_ref->[NEXT];
    }
    if ( $line_ref->[ORD] < 0 ) {
        $screen_ref->[FIRST] =
          $line_ref->[NEXT]
          ;    # Attention, bug subtil si pas de next (�cran minuscule)
        suppress_from_screen_line( $edit_ref, $line_ref, 'for_speed' );
        $line_ref->[NEXT][PREVIOUS] = undef;

        # Peut-�tre plusieurs lignes � supprimer ...
        while ( $line_ref->[PREVIOUS] ) {
            $line_ref = $line_ref->[PREVIOUS];
            suppress_from_screen_line( $edit_ref, $line_ref, 'for_speed' );
            $line_ref->[NEXT][PREVIOUS] = undef;
        }
    }
}

sub suppress_bottom_invisible_lines {
    my ($edit_ref) = @_;

    my $screen_ref = $edit_ref->[SCREEN];

# On ne suprrime les "lignes fichier" qu'enti�rement (avec le mode wrap, certaines "lignes fichiers" s'�talent sur
# plusieurs "lignes �cran")
    my $line_ref = $screen_ref->[LAST];
    while ( $line_ref->[PREVIOUS_SAME] ) {
        $line_ref = $line_ref->[PREVIOUS];
    }
    if ( $line_ref->[ORD] - $line_ref->[HEIGHT] > $screen_ref->[HEIGHT] ) {
        $screen_ref->[LAST] = $line_ref->[PREVIOUS];
        $line_ref->[PREVIOUS][NEXT] = undef;

        # Peut-�tre plusieurs lignes � supprimer ...
        suppress_from_screen_line( $edit_ref, $line_ref, 'for_speed' );
        while ( $line_ref->[NEXT] ) {
            $line_ref = $line_ref->[NEXT];
            suppress_from_screen_line( $edit_ref, $line_ref, 'for_speed' );
            $line_ref->[PREVIOUS][NEXT] = undef;
        }
    }
}

sub mouse_wheel_event {
    my ( $edit_ref, $obj, $d ) = @_;

    my $unit = 1;
    if ( $d == 4 ) {
        $unit = -1;
    }
    scrollbar_move( $edit_ref, 'scroll', $unit, 'units' );
}

sub screen_set_wrap {
    my ($edit_ref) = @_;

    return if ( $edit_ref->[SCREEN][WRAP] );

    wrap($edit_ref);
}

sub screen_unset_wrap {
    my ($edit_ref) = @_;

    return if ( !$edit_ref->[SCREEN][WRAP] );

    wrap($edit_ref);
}

sub wrap {
    my ($edit_ref) = @_;

# A partir de quelle ligne afficher et � quelle position : on regarde la position de screen_ref->[FIRST]
    my $line_ref = get_first_complete_line($edit_ref);

    clear_screen($edit_ref);

    if ( $edit_ref->[SCREEN][WRAP] ) {
        $edit_ref->[SCREEN][WRAP] = 0;
    }
    else {
        $edit_ref->[SCREEN][WRAP] = 1;

        # Suppression de l'�ventuel d�calage vertical
        $edit_ref->[SCREEN][VERTICAL_OFFSET] = 0;
    }

    $edit_ref->display( $line_ref->[REF], { 'at' => 'top' } );

    #cursor_make_visible ( $edit_ref );
}

sub change_title {
    my ( $edit_ref, $title ) = @_;

    print "Dans change title : $title\n";
    $edit_ref->[GRAPHIC]->change_title($title);
}

sub inser {
    my ($edit_ref) = @_;

    if ( $edit_ref->[INSER] ) {
        $edit_ref->[INSER] = 0;
    }
    else {
        $edit_ref->[INSER] = 1;
    }
}

sub editor_insert_mode {
    my ($edit_ref) = @_;

    return $edit_ref->[INSER];
}

sub editor_set_insert {
    my ($edit_ref) = @_;

    $edit_ref->[INSER] = 1;
}

sub editor_set_replace {
    my ($edit_ref) = @_;

    $edit_ref->[INSER] = 0;
}

sub start_line {
    my ($line_ref) = @_;

    while ( $line_ref->[PREVIOUS_SAME] ) {
        $line_ref = $line_ref->[PREVIOUS];
    }
    return $line_ref;
}

sub return_complete_line {
    my ($line_ref) = @_;

    $line_ref = start_line($line_ref), my $text = $line_ref->[TEXT];
    while ( $line_ref->[NEXT_SAME] ) {
        $line_ref = $line_ref->[NEXT];
        $text .= $line_ref->[TEXT];
    }
    return $text;
}

sub get_line_number {
    my ( $edit_ref, $line_ref ) = @_;

    return $edit_ref->[PARENT]->get_line_number_from_ref( $line_ref->[REF] );
}

sub get_displayed_editor {
    my ($edit_ref) = @_;

    #print "Dans Abstract : $edit_ref\n";
    return $edit_ref->[GRAPHIC]->get_displayed_editor();
}

sub get_screen_size {
    my ($edit_ref) = @_;

    return ( $edit_ref->[SCREEN][WIDTH], $edit_ref->[SCREEN][HEIGHT] );
}

sub change_reference {
    my ($edit_ref) = @_;

    $edit_ref->[GRAPHIC]->change_reference( $edit_ref, $edit_ref->[FILE] );
}

sub increase_font {
    my ($edit_ref) = @_;

    print "Taille de la fonte actuelle : $edit_ref->[SCREEN][FONT_HEIGHT]\n";
    $edit_ref->[SCREEN][FONT_HEIGHT] += 1;
    my %distinct_fonts;
    for my $font ( values %font ) {
        $distinct_fonts{$font} = $font;
    }
    for my $font ( keys %distinct_fonts ) {
        $edit_ref->[GRAPHIC]->set_font_size( $distinct_fonts{$font},
            $edit_ref->[SCREEN][FONT_HEIGHT] );
    }
    $edit_ref->[SCREEN][LINE_HEIGHT] =
      17 * $edit_ref->[SCREEN][FONT_HEIGHT] / 13;
}

#sub get_positions {
#    return {
#        "first_line_number"  => $top_true_line_number,
#        "first_line_pos"     => $top_screen_line_number,
#        "cursor_line_number" => $cursor_true_line_number,
#        "cursor_pos_in_line" => $edit_ref->[CURSOR][POSITION_IN_DISPLAY]
#    };
#}

######################################################################
#
#  INTERFACE
#
######################################################################

sub insert {
    my ( $edit_ref, $text, $options_ref ) = @_;

    $text =~ s/\t/    /g;    # Suppression des tabulations

    cursor_make_visible($edit_ref) if ( $origin eq 'graphic' );

#-----------------------------------------------------
# Gestion des "\n" :
# ---->  Appels r�cursifs � changer pour optimisation mais tr�s efficace pour le codage
#-----------------------------------------------------
    my (@lines) =
      split( /(\n)/, $text )
      ;    # Parenth�ses pour ne pas ignorer les  "empty trailing fields"
    if ( scalar(@lines) > 1 ) {
        my @ref;    # Liste des r�f�rences des lignes modifi�es ou cr��es
      INSERT: for my $index ( 0 .. $#lines ) {
            if ( $lines[$index] eq "\n" ) {

                # Envoi d'un "\n" : cr�ation d'une ligne
                my @ref1 =
                  enter( $edit_ref, $options_ref )
                  ;    # R�cup�ration en contexte de liste

     # Gestion du code retour (construction du tableau des r�f�rences modifi�es)
                if ( !@ref or $ref[$#ref] ne $ref1[0] ) {
                    push @ref, @ref1;    # 1 ou 2 �l�ments ins�r�s dans @ref
                }
                else
                { # Ici, on est s�r d'avoir 2 lignes retourn�es par "enter" (l'�l�ment $ref1[1] existe)
                    push @ref, $ref1[1];
                }
            }

            else {

                # Le texte a ins�rer ici ne contient plus aucun "\n"
                my ($ref) =
                  insert( $edit_ref, $lines[$index], $options_ref )
                  ;    # Appel r�cursif

     # Gestion du code retour (construction du tableau des r�f�rences modifi�es)
                next INSERT if ( !defined $ref );
                if ( !@ref or $ref[$#ref] ne $ref ) {
                    push @ref, $ref
                      ; # Mise dans le tableau seulement si pas d�j� (insertion retour chariot d'avant, m�me ref)
                }
            }
        }

        # Gestion du code retour pour une demande qui contenait des "\n";
        if (wantarray) {

            # En contexte liste, on renvoie la liste des r�f�rences modif�es
            return @ref;
        }
        else {

            # En contexte scalaire, on renvoie le nombre de lignes modifi�es
            return scalar(@ref);
        }
    }

    #-----------------------------------------------------
    # Fin de la gestion des "\n" :
    #   Si on est ici, c'est que $text ne contient pas de "\n";
    #-----------------------------------------------------
    if ( !defined( $options_ref->{'insert'} ) ) {

# R�cup�ration du "mode inser" courant de l'�diteur si pas d�fini par l'appelant
        $options_ref->{'insert'} = $edit_ref->[INSER];
    }

    my $line_ref = $edit_ref->[CURSOR][LINE_REF];
    my ( $top_ord, $bottom_ord ) = get_line_ords($line_ref);
    suppress_from_screen_line( $edit_ref, $line_ref );

    $line_ref = delete_text_in_line( $edit_ref, $line_ref );
    my $initial_text = $line_ref->[TEXT];

# On a ici tout ce qu'il faut : le texte complet de la ligne, la position dans cette ligne enti�re
# La position du bas de la ligne pour le mode wrap et le mode "inser"

    ( $line_ref->[TEXT] ) = $edit_ref->[PARENT]->insert_text(
        $initial_text, $text,
        $edit_ref->[CURSOR][POSITION_IN_LINE],
        $options_ref->{'insert'},
        $line_ref->[REF],
    );

    $edit_ref->[CURSOR][POSITION_IN_LINE] += length($text);

    create_text_in_line( $edit_ref, $line_ref );

    my $bottom_line_ref =
      display_line_from_top( $edit_ref, $line_ref, $top_ord );
    my ( $new_top_ord, $new_bottom_ord ) = get_line_ords($bottom_line_ref);

    if ( $bottom_line_ref->[ORD] != $bottom_ord ) {

        #print "Move de ", $bottom_line_ref->[ORD] - $bottom_ord, "\n";
        move_bottom( $edit_ref, $bottom_line_ref->[ORD] - $bottom_ord,
            $bottom_line_ref );
    }

#print "TOP derni�re ligne =",  $bottom_line_ref->[ORD] - $bottom_line_ref->[HEIGHT], "\n";
#print "bottom derni�re ligne =",  $bottom_line_ref->[ORD] , "\n";
    ( $new_top_ord, $new_bottom_ord ) = get_line_ords($bottom_line_ref);

# Assistance � la saisie # = �v�nement de fin de transfert, origin 'graphic' seulement
    if ( $options_ref->{'assist'} ) {
        assist_on_inserted_text( $edit_ref->[PARENT], $text,
            $edit_ref->[CURSOR][LINE_REF][TEXT] );
    }
    if ( my $sub_ref = $edit_ref->[REDIRECT]{'insert_last'} ) {

        # Redirection vers une fonction utilisateur
        #$sub_ref = 'cursor_set_last' if ( $sub_ref eq '1' ); # Asynchrone
        return $edit_ref->[PARENT]->redirect(
            $sub_ref,
            $edit_ref,
            {
                'line'       => $edit_ref->[CURSOR][LINE_REF][REF],
                'line_pos'   => $edit_ref->[CURSOR][POSITION_IN_LINE],
                'text'       => $text,
                'initial'    => $initial_text,
                'origin'     => $origin,
                'sub_origin' => $sub_origin,
            }
        );
    }

# Optimisation des insertions 'programm�' � voir (un seul appel � la fin � faire... � voir)
    cursor_make_visible($edit_ref) if ( $origin eq 'graphic' );

# Gestion du code retour : attention, l'insertion ne modifie pas forc�ment la ligne
    if ( $line_ref->[TEXT] eq $initial_text ) {
        if (wantarray) {
            return
              ; # Aucune r�f�rence de ligne � renvoyer car aucune ligne modifi�e
        }
        else {
            return 0;    # Aucune ligne modifi�e
        }
    }
    else {
        if (wantarray) {
            return ( $line_ref->[REF] );    # R�f�rence de la ligne modifi�e
        }
        else {
            return 1;                       # 1 ligne modifi�e
        }
    }
}

sub enter {                                 # <=> insert("\n")

    my ( $edit_ref, $options_ref ) = @_;

    cursor_make_visible($edit_ref) if ( $origin eq 'graphic' );

    my $line_ref = $edit_ref->[CURSOR][LINE_REF];

    # Pour repositionnement � la fin
    my ( $top_ord, $bottom_ord ) = get_line_ords($line_ref);

    # Suppression de la ligne ... �cran ! ===> � corriger ?
    suppress_from_screen_line( $edit_ref, $line_ref );
    $line_ref = delete_text_in_line( $edit_ref, $line_ref );

    # Optimisation
    my $initial_text = $line_ref->[TEXT];
    my $pos = $edit_ref->[CURSOR][POSITION_IN_DISPLAY];    # Ligne �cran !!!
    my $ref = $line_ref->[REF];

# Pour assistance � la saisie (auto-indentation �ventuelle apr�s insertion du "\n")
    my $initial_left_text = substr( $initial_text, 0, $pos );

# Modification de l'ancienne ligne et cr�ation de la nouvelle pour l'objet �diteur
    my ( $text, $new_text, $new_ref ) =
      $edit_ref->[PARENT]->insert_return( $initial_text, $pos, $ref, );

#---------------------------------------------------------------------------------------
# Affichage des 2 lignes (modifi�e et cr��e)
#---------------------------------------------------------------------------------------
# Modification de la liste cha�n�e
    my $new_line_ref;
    $new_line_ref->[PREVIOUS] = $line_ref;
    $new_line_ref->[TEXT]     = $new_text;
    $new_line_ref->[NEXT]     = $line_ref->[NEXT];
    $new_line_ref->[REF]      = $new_ref;

    if ( $line_ref->[NEXT] ) {
        $line_ref->[NEXT][PREVIOUS] = $new_line_ref;
    }
    $line_ref->[NEXT] = $new_line_ref;
    $line_ref->[TEXT] = $text;

    # Cr�ation des �l�ments texte dans les 2 lignes (coloration syntaxique)
    create_text_in_line( $edit_ref, $line_ref );
    create_text_in_line( $edit_ref, $new_line_ref );

    # Affichage de la ligne modifi�e
    my $before_ref = display_line_from_top( $edit_ref, $line_ref, $top_ord );

    # Affichage de la ligne cr��e
    my $after_ref =
      display_line_from_top( $edit_ref, $new_line_ref, $before_ref->[ORD] );

# Fin de l'affichage des 2 lignes (modifi�e et cr��e)
#---------------------------------------------------------------------------------------
    if ( !$after_ref->[NEXT] ) {

 # Il n'y a rien apr�s $after_ref ===> elle devient donc la derni�re ligne �cran
        $edit_ref->[SCREEN][LAST] = $after_ref;
    }

    # D�placement des lignes du bas
    my $how_much = $after_ref->[ORD] - $bottom_ord;
    move_bottom( $edit_ref, $how_much, $after_ref );

# On d�place le curseur au d�but de la nouvelle ligne : optimisation possible : pas de r�actualisation du tag 'bottom' n�cessaire ... � faire
    cursor_set( $edit_ref, 0, $new_ref );

    # Aide � la saisie (si indentation automatique)
    if ( defined( $options_ref->{'indent'} ) ) {
        indent_on_return( $edit_ref, $initial_left_text );
    }

    cursor_make_visible($edit_ref) if ( $origin eq 'graphic' );

    # Gestion du code retour
    if ( $text ne $initial_text ) {    # La premi�re ligne a �t� modifi�e
        if (wantarray) {
            return ( $ref, $new_ref );    # R�f�rence de la ligne cr��e
        }
        else {
            return 2;                     # 1 ligne modifi�e, 1 ligne cr��e
        }
    }
    else
    {    # La premi�re ligne est intacte (on �tait � la fin lors de l'insertion)
        if (wantarray) {
            return $new_ref;
        }
        else {
            return 1;    # 1 seule ligne cr��e
        }
    }
}

# Valeurs de retour � g�rer pour les 2 fonctions suivantes
sub delete_return {
    my ($edit_ref) = @_;

    cursor_make_visible($edit_ref) if ( $origin eq 'graphic' );

    my $cursor = $edit_ref->[CURSOR];

    # On supprimer un retour charriot : il y a donc forc�ment une ligne qui suit
    my $line_ref = $cursor->[LINE_REF];

    # Erreurs � l'appel, on renvoie undef
    return if ( !$line_ref );
    return if ( $cursor->[POSITION_IN_DISPLAY] != length( $line_ref->[TEXT] ) );
    return if ( $line_ref->[NEXT_SAME] );
    return if ( !$line_ref->[NEXT] );

    my ( $top_ord, undef ) = get_line_ords($line_ref);
    my ( undef, $bottom_ord ) = get_line_ords( $line_ref->[NEXT] );

    suppress_from_screen_line( $edit_ref, $line_ref );
    $line_ref = delete_text_in_line( $edit_ref, $line_ref );

# line_ref est une ligne enti�re (mode wrap annul� provisoirement pour cette ligne)

    suppress_from_screen_line( $edit_ref, $line_ref->[NEXT] );
    $line_ref->[NEXT] = delete_text_in_line( $edit_ref, $line_ref->[NEXT] );
    my ( $text, $concat ) =
      $edit_ref->[PARENT]
      ->delete_key( $line_ref->[TEXT], $edit_ref->[CURSOR][POSITION_IN_DISPLAY],
        $line_ref->[REF], );
    $line_ref->[TEXT] =
      $text;    # Le texte vaut le cumul des 2 lignes (travail de delete_key)
    die "Pas de concat�nation sur suppression de \\n\n" if ( $concat ne "yes" );

    $line_ref->[NEXT][TEXT] =
      "";       # Le texte a d�j� �t� concat�n� par la proc�dure delete_key
                # concat (modif liste cha�n�e) le ferai � nouveau
    concat( $edit_ref, $line_ref, 'bottom' );

    create_text_in_line( $edit_ref, $line_ref );

    my $bottom_line_ref =
      display_line_from_top( $edit_ref, $line_ref, $top_ord );

    # D�placement des lignes du bas
    my $how_much = $bottom_line_ref->[ORD] - $bottom_ord;
    move_bottom( $edit_ref, $how_much, $bottom_line_ref );
}

sub erase {
    my ( $edit_ref, $number ) = @_;

    return if ( $number == 0 );

    cursor_make_visible($edit_ref) if ( $origin eq 'graphic' );

    my $line_ref = $edit_ref->[CURSOR][LINE_REF];

# line_ref est une ligne enti�re (mode wrap annul� provisoirement pour cette ligne)

    # Par d�faut, il faut supprimer un caract�re, sauf...
    my $cursor_pos  = $edit_ref->[CURSOR][POSITION_IN_DISPLAY];
    my $length_line = length( $line_ref->[TEXT] );
    if ( $cursor_pos + $number > $length_line ) {

        # Appels r�cursifs
        while ($number) {
            my $suppress;
            if ( $number > $length_line - $cursor_pos ) {
                $suppress = $length_line - $cursor_pos;
                erase( $edit_ref, $suppress );
                delete_return($edit_ref);
                $length_line = length( $edit_ref->[CURSOR][LINE_REF] );
                $number -= $suppress + 1;
                $cursor_pos = 0;
            }
            else {
                $suppress = $number;
                erase( $edit_ref, $suppress );
                $number = 0;
            }
        }
        return;
    }

    my ( $top_ord, $bottom_ord ) = get_line_ords($line_ref);

    suppress_from_screen_line( $edit_ref, $line_ref );
    $line_ref = delete_text_in_line( $edit_ref, $line_ref );

    my $ref = $line_ref->[REF];
    my ($text) =
      $edit_ref->[PARENT]->erase_text( $number, $line_ref->[TEXT],
        $edit_ref->[CURSOR][POSITION_IN_DISPLAY],
        $line_ref->[REF], );
    $line_ref->[TEXT] = $text;

    create_text_in_line( $edit_ref, $line_ref );

    my $bottom_line_ref =
      display_line_from_top( $edit_ref, $line_ref, $top_ord );

    # D�placement des lignes du bas
    my $how_much = $bottom_line_ref->[ORD] - $bottom_ord;
    move_bottom( $edit_ref, $how_much, $bottom_line_ref );

    if (wantarray) {
        return 1;
    }
    else {
        return $ref;
    }
}

sub display {
    my ( $edit_ref, $ref, $options_ref ) = @_;

    my $at = $options_ref->{'at'};
    my $ord;
    if ( defined $at and $at =~ /^ord_(\d+)/ ) {
        $ord = $1;
    }
    elsif ( defined $at ) {
        if ( $at eq 'top' ) {
            $ord = 0;
        }
        elsif ( $at eq 'bottom' ) {
            $ord = $edit_ref->[SCREEN][HEIGHT];
        }
        elsif ( $at eq 'middle' ) {
            $ord = $edit_ref->[SCREEN][HEIGHT] / 2;
        }
        else {
            $ord = $edit_ref->[SCREEN][HEIGHT] / 4;
        }
    }
    else {

        # On positionne la ligne vers le haut (middle_top)
        $ord = $edit_ref->[SCREEN][HEIGHT] / 4;
    }

    # V�rification de la validit� de la ligne avant effacement de l'�cran
    my $top_line_ref;
    if ( $ref =~ /^(\d+)_/ ) {
        ($top_line_ref) = get_line_ref_from_display_ref( $edit_ref, $ref );
    }
    else {
        $top_line_ref = create_line_ref_from_ref( $edit_ref, $ref );
    }
    return if ( !$top_line_ref );

# Si on veut optimiser et ne pas tout supprimer, alors il ne faut pas appeler display
# Pour �tre propre, il faudrait supprimer toutes les r�f�rences utilis�es actuellement
    clear_screen($edit_ref);

    display_reference( $edit_ref, $ref, $ord, $options_ref->{'from'} );

    #Appel en boucle pour affichage de toutes les lignes
    # Recuperation de la derniere ligne qui devrait etre affichee
    display_bottom_of_the_screen($edit_ref);

# On a fini l'affichage du bas, mais il reste peut-�tre des lignes � afficher en haut de $top_line_ref
    display_top_of_the_screen($edit_ref);

    return update_vertical_scrollbar($edit_ref);
}

sub display_reference {
    my ( $edit_ref, $ref, $ord, $from ) = @_;

    if ( $ref =~ /^(\d+)_/ ) {
        display_reference_line( $edit_ref, $1, $ord, $from );
        my ($line_ref) = get_line_ref_from_display_ref( $edit_ref, $ref );
        if ( !$line_ref )
        {    # On avait v�rifi�  avant ! Impossible, normalement ...
            print "Curieux...\n";
            $line_ref = $edit_ref->[SCREEN][LAST];
        }
        my $y;
        if ( !$from or $from eq 'top' ) {
            $y = $ord - $line_ref->[ORD] + $line_ref->[HEIGHT];
        }
        elsif ( $from eq 'middle' ) {
            $y = $ord - $line_ref->[ORD] + int( $line_ref->[HEIGHT] / 2 );
        }
        else {
            $y = $ord - $line_ref->[ORD];
        }
        screen_move( $edit_ref, 0, $y );
        return;
    }
    display_reference_line( $edit_ref, $ref, $ord, $from );
    if ( defined $from and $from eq 'middle' ) {
        my ( $top_ord, $bottom_ord ) =
          get_line_ords( $edit_ref->[SCREEN][LAST] );
        my $y = $ord - $bottom_ord + int( ( $bottom_ord - $top_ord ) / 2 );
        screen_move( $edit_ref, 0, $y );
    }
}

sub display_reference_line {
    my ( $edit_ref, $ref, $ord, $from ) = @_;

    my $top_line_ref = create_line_ref_from_ref( $edit_ref, $ref );
    if ( !$from or $from eq 'top' ) {
        $edit_ref->[SCREEN][LAST] =
          display_line_from_top( $edit_ref, $top_line_ref, $ord );
        $edit_ref->[SCREEN][FIRST] = $top_line_ref;
    }
    else {
        $edit_ref->[SCREEN][FIRST] =
          display_line_from_bottom( $edit_ref, $top_line_ref, $ord );
        $edit_ref->[SCREEN][LAST] = $edit_ref->[SCREEN][FIRST];
        while ( $edit_ref->[SCREEN][LAST][NEXT_SAME] ) {
            $edit_ref->[SCREEN][LAST] = $edit_ref->[SCREEN][LAST][NEXT];
        }
    }
}

#-------------------------------------------------------------------
# Gestion des m�thodes de l'objet interne "cursor"
#-------------------------------------------------------------------

sub cursor_position_in_display {
    my ($self) = @_;

    return $self->[CURSOR][POSITION_IN_DISPLAY];
}

sub cursor_position_in_text {
    my ($self) = @_;

    return $self->[CURSOR][POSITION_IN_TEXT];
}

sub cursor_abs {
    my ($self) = @_;

    return $self->[CURSOR][ABS];
}

sub cursor_virtual_abs {
    my ($self) = @_;

    return $self->[CURSOR][VIRTUAL_ABS];
}

sub cursor_line {
    my ($self) = @_;

    if (wantarray) {
        my $line_ref = $self->[CURSOR][LINE_REF];
        return ( return_complete_line($line_ref), $line_ref->[REF] );
    }
    else {
        return $self->[CURSOR][LINE_REF][REF];
    }
}

sub cursor_display {
    my ($self) = @_;

    return get_display_ref_from( $self->[CURSOR][LINE_REF] );
}

sub cursor_set {
    my ( $edit_ref, $options_ref, $ref ) = @_;

# Cas � traiter le plus rapidement car le plus fr�quent : positionnement sur la m�me ligne fichier (pas de $ref)
    if ( !defined($ref) and !ref $options_ref ) {
        return position_cursor_in_line( $edit_ref,
            $edit_ref->[CURSOR][LINE_REF], $options_ref );
    }

    # Recherche du positionnement vertical (ligne fichier ou ligne �cran)
    my ( $line_ref, $type ) =
      search_line_ref_and_type( $edit_ref, $options_ref, $ref );
    return if ( !$line_ref );

    if ( $type eq 'call' ) {

      #print STDERR "On n'a pas trouv� la ligne dans les lignes affich�es...\n";
        my ( $top, $bottom ) =
          display( $edit_ref, $line_ref, { 'at' => 'middle' } );

# Attention, le positionnement peut planter si $ref est bidon ==> tester le code retour
        return if ( !defined $top );

#print "R�affichage pour positionnement �loign� |$top|$bottom|\n";
# Maintenant que la ligne est affich�, on peut positionner normalement (appel r�cursif)
        return cursor_set( $edit_ref, $options_ref, $ref );
    }

# La ligne de positionnement et le type de positionnement sont connus ici (ordonn�e 'y' connue)

    # Recherche de l'abscisse ('x')
    my $position;
    my $keep_virtual;
    if ( !ref $options_ref ) {
        $position = $options_ref;
    }
    else {
        $keep_virtual = $options_ref->{'keep_virtual'};
    }
    if ( !defined $position and ref $options_ref ) {
        if ( my $char = $options_ref->{'char'} ) {
            $position = $char;
        }
        if ( !defined $position and my $x = $options_ref->{'x'} ) {
            $position =
              get_position_from_line_and_abs( $edit_ref, $line_ref, $x );
            $type = 'display'; # On force le mode display puisque l'on a calcul�
              # la position du curseur par rapport � une ligne affich�e et � une abscisse (visuel)
        }
    }

    if ( $type eq 'display' ) {
        return position_cursor_in_display( $edit_ref, $line_ref, $position,
            $keep_virtual );
    }
    else {
        return position_cursor_in_line( $edit_ref, $line_ref, $position,
            $keep_virtual );
    }
}

sub search_line_ref_and_type {
    my ( $edit_ref, $options_ref, $ref ) = @_;

    my $line_ref;

    # Recherche d'une ligne �cran ...
    # ...dans les options (prioritaires)
    if ( ref $options_ref eq 'HASH'
        and my $display = $options_ref->{'display'} )
    {
        ($line_ref) = get_line_ref_from_display_ref( $edit_ref, $display );
        return if ( !$line_ref );
        return ( $line_ref, 'display' );
    }

    # ...dans le 3�me param�tre $ref
    if ( defined $ref and $ref =~ /_/ ) {
        ($line_ref) = get_line_ref_from_display_ref( $edit_ref, $ref );
        return if ( !$line_ref );
        return ( $line_ref, 'display' );
    }

    # Recherche d'une ligne fichier ...
    # ... dans les options
    if ( ref $options_ref eq 'HASH' and my $line = $options_ref->{'line'} ) {
        $line_ref = get_line_ref_from_ref( $edit_ref, $line );
        return ( $line, 'call' )
          if ( !$line_ref );    # La r�f�rence n'est pas � l'�cran
        return ( $line_ref, 'line' );
    }

    # ... dans la r�f�rence (3�me param�tre)
    if ( defined $ref and $ref =~ /^\d+$/ ) {
        $line_ref = get_line_ref_from_ref( $edit_ref, $ref );
        return ( $ref, 'call' )
          if ( !$line_ref );    # La r�f�rence n'est pas � l'�cran
        return ( $line_ref, 'line' );
    }

    # Recherche d'un positionnement par ordonn�e � l'�cran
    if ( ref $options_ref eq 'HASH' and my $ord = $options_ref->{'y'} ) {
        my $line_ref = get_line_ref_from_ord( $edit_ref, $ord );

        return ( $line_ref, 'display' );
    }

    # On n'a pas r�ussi � r�cup�rer une ligne du param�trage
    # ==> on se positionne sur la ligne courante
    $line_ref = $edit_ref->[CURSOR][LINE_REF];
    return ( $edit_ref->[CURSOR][LINE_REF], 'line' );
}

sub get_line_ref_from_ord {
    my ( $self, $ord ) = @_;

    my $line_ref = $self->[SCREEN][FIRST];
    while ($line_ref) {
        if ( $line_ref->[ORD] > $ord ) {
            return $line_ref;
        }
        $line_ref = $line_ref->[NEXT];
    }
    return;    # Pas trouv�
}

sub get_display_ref_from_ord {
    my ( $self, $ord ) = @_;

    my $line_ref = $self->[SCREEN][FIRST];
    my $indice   = 1;
    while ($line_ref) {
        if ( $line_ref->[ORD] > $ord ) {
            return $line_ref->[REF] . '_' . $indice;
        }
        if ( $line_ref->[NEXT_SAME] ) {
            $indice += 1;
        }
        else {
            $indice = 1;
        }
        $line_ref = $line_ref->[NEXT];
    }
    return;    # Pas trouv�
}

sub position_cursor_in_line {
    my ( $edit_ref, $line_ref, $position_in_line, $keep_virtual ) = @_;

    $position_in_line = 0 if ( !$position_in_line );
    my $position = $position_in_line;

    $line_ref = start_line($line_ref);
  LINE: while ( length( $line_ref->[TEXT] ) < $position ) {
        if ( !$line_ref->[NEXT_SAME] ) {
            $position = length( $line_ref->[TEXT] );
            last LINE;
        }
        $position -= length( $line_ref->[TEXT] );
        $line_ref = $line_ref->[NEXT];
    }
    return position_cursor_in_display( $edit_ref, $line_ref, $position,
        $keep_virtual, $position_in_line );
}

sub position_cursor_in_display {
    my ( $edit_ref, $line_ref, $position, $keep_virtual, $position_in_line ) =
      @_;

    $position = 0 if ( !defined $position );
    my $cursor_ref        = $edit_ref->[CURSOR];
    my $previous_line_ref = $cursor_ref->[LINE_REF];

    $cursor_ref->[LINE_REF]            = $line_ref;
    $cursor_ref->[POSITION_IN_DISPLAY] = $position;

    if ( !defined $position_in_line ) {
        $cursor_ref->[POSITION_IN_LINE] =
          calc_line_position_from_display_position($cursor_ref);
    }
    else {
        $cursor_ref->[POSITION_IN_LINE] = $position_in_line;
    }

    my $text_ref    = $line_ref->[FIRST];
    my $length_text = length( $text_ref->[TEXT] );
  TXT: while ( $length_text < $position ) {
        $position -= $length_text;
        if ( !$text_ref->[NEXT] ) {

     # Il n'y a pas assez de caract�res pour effectuer le positionnement demand�
     # ==> on se positionne sur le dernier �l�ment texte de la ligne
            $position = $length_text;
            last TXT;
        }
        else {
            $text_ref = $text_ref->[NEXT];
        }
        $length_text = length( $text_ref->[TEXT] );
    }

    select_text_element( $edit_ref, $text_ref, $position );

    my $increment =
      $edit_ref->[GRAPHIC]->length_text(
        substr( $text_ref->[TEXT], 0, $cursor_ref->[POSITION_IN_TEXT] ),
        $text_ref->[FONT], );
    $cursor_ref->[ABS] =
      $text_ref->[ABS] + $increment - $edit_ref->[SCREEN][VERTICAL_OFFSET];

    if ( !defined $keep_virtual or !$keep_virtual ) {
        $cursor_ref->[VIRTUAL_ABS] = $cursor_ref->[ABS];
    }

    # Positionnement correct du tag "bottom'
    # ==>  Couteux : � ne faire que si la "hauteur" du curseur � chang�
    if ( $line_ref != $previous_line_ref ) {

#print "Tag BOTTOM de $cursor_ref->[LINE_REF][ORD] � $edit_ref->[SCREEN][LAST][ORD]\n";
        $edit_ref->[GRAPHIC]->position_bottom_tag_for_text_lower_than(
            $cursor_ref->[LINE_REF][ORD],
            $edit_ref->[SCREEN][LAST][ORD],
        );
    }

    if ( my $sub_ref = $edit_ref->[REDIRECT]{'cursor_set_last'} ) {

        # Redirection vers une fonction utilisateur
        #$sub_ref = 'cursor_set_last' if ( $sub_ref eq '1' ); # Asynchrone
        return $edit_ref->[PARENT]->redirect(
            $sub_ref,
            $edit_ref,
            {
                'line'        => $line_ref->[REF],
                'display'     => get_display_ref_from($line_ref),
                'display_pos' => $cursor_ref->[POSITION_IN_DISPLAY],
                'line_pos'    => $cursor_ref->[POSITION_IN_LINE],
                'origin'      => $origin,
                'sub_origin'  => $sub_origin,
            }
        );
    }

    # On renvoie toujours la position dans la ligne fichier
    elsif (wantarray) {
        my $ref = $line_ref->[REF];
        return ( $ref, $cursor_ref->[POSITION_IN_LINE] );
    }
    else {
        return $cursor_ref->[POSITION_IN_LINE];
    }
}

sub cursor_get {
    my ($self) = @_;

    my $cursor   = $self->[CURSOR];
    my $position = $cursor->[POSITION_IN_DISPLAY];
    my $line_ref = $cursor->[LINE_REF];
    while ( $line_ref->[PREVIOUS_SAME] ) {
        $line_ref = $line_ref->[PREVIOUS];
        $position += length( $line_ref->[TEXT] );
    }

    if (wantarray) {
        return (
            $cursor->[LINE_REF][REF],       $position,
            $cursor->[POSITION_IN_DISPLAY], $cursor->[POSITION_IN_TEXT],
            $cursor->[ABS],                 $cursor->[VIRTUAL_ABS],
        );
    }
    else {
        return $position;
    }
}

#-------------------------------------------------------------------
# Gestion des m�thodes de l'objet interne "screen"
#-------------------------------------------------------------------

sub screen_first {
    my ($self) = @_;

    return get_display_ref_from( $self->[SCREEN][FIRST] );
}

sub screen_font_height {
    my ($self) = @_;

    return $self->[SCREEN][FONT_HEIGHT];
}

sub screen_height {
    my ($self) = @_;

    return $self->[SCREEN][HEIGHT];
}

sub screen_x_offset {
    my ($self) = @_;

    return $self->[SCREEN][VERTICAL_OFFSET];
}

sub screen_last {
    my ($self) = @_;

    return get_display_ref_from( $self->[SCREEN][LAST] );
}

sub screen_margin {
    my ($self) = @_;

    return $self->[SCREEN][MARGIN];
}

sub screen_width {
    my ($self) = @_;

    return $self->[SCREEN][WIDTH];
}

sub screen_wrap {
    my ($self) = @_;

    return $self->[SCREEN][WRAP];
}

sub screen_set_width {
    my ( $self, $width ) = @_;

    my ( undef, $height, $x, $y ) = $self->[GRAPHIC]->get_geometry;
    $self->[GRAPHIC]->set_geometry( $width, $height, $x, $y );

# Le set_width va �tre g�n�rateur d'un resize
# Ce resize va commencer au moment o� le thread qui a lanc� set_width aura a nouveau la main
# (les threads travaillent "simultan�ment")
#
    return "Fin de set_width";
}

sub screen_set_height {
    my ( $self, $height ) = @_;

    my ( $width, undef, $x, $y ) = $self->[GRAPHIC]->get_geometry;
    $self->[GRAPHIC]->set_geometry( $width, $height, $x, $y );
}

sub screen_set_x_corner {
    my ( $self, $x ) = @_;

    my ( $width, $height, undef, $y ) = $self->[GRAPHIC]->get_geometry;
    $self->[GRAPHIC]->set_geometry( $width, $height, $x, $y );
}

sub screen_set_y_corner {
    my ( $self, $y ) = @_;

    my ( $width, $height, $x, undef ) = $self->[GRAPHIC]->get_geometry;
    $self->[GRAPHIC]->set_geometry( $width, $height, $x, $y );
}

sub screen_number {
    my ( $self, $number ) = @_;

  # Renvoie le nombre de lignes affich�es dans la zone visible :
  #Attention ! Parfois [SCREEN][FIRST] et/ou [SCREEN][LAST] ne sont pas visibles
  # Les lignes peuvent avoir des hauteurs diff�rentes

    # Si $number est renseign�, renvoie la '$number' ligne �cran

    my $line_ref = $self->[SCREEN][FIRST];
    while ( $line_ref->[ORD] < 0 and $line_ref->[NEXT] ) {
        $line_ref = $line_ref->[NEXT];
    }
    if ( $line_ref->[ORD] < 0 ) {    # En principe impossible !
        return if ( defined $number );
        return 0;
    }
    my $current_number;
    while ( $line_ref->[ORD] - $line_ref->[HEIGHT] < $self->[SCREEN][HEIGHT] ) {
        $current_number += 1;
        if ( defined $number and $number == $current_number ) {
            return get_display_ref_from($line_ref);
        }
        $line_ref = $line_ref->[NEXT];
        last if ( !$line_ref );
        last if ( !$line_ref );
    }
    return $current_number;
}

sub get_line_ref_from_ref {
    my ( $self, $ref ) = @_;

    my $line_ref = $self->[SCREEN][FIRST];
    while ( $line_ref->[REF] != $ref and $line_ref->[NEXT] ) {
        $line_ref = $line_ref->[NEXT];
    }
    if ( $line_ref->[REF] == $ref ) {
        return $line_ref;
    }
    else {
        return;
    }
}

sub line_displayed {
    my ( $self, $ref ) = @_;

    #print "Dans line_displayed : $ref\n";
    my $count = 0;
    my @ref;
    my $indice   = 1;
    my $line_ref = $self->[SCREEN][FIRST];
    while ( $line_ref != $self->[SCREEN][LAST] ) {
        if ( $line_ref->[REF] == $ref ) {
            push @ref, $ref . "_" . $indice++;
            $count += 1;
        }
        $line_ref = $line_ref->[NEXT];
    }
    if ( $self->[SCREEN][LAST][REF] == $ref ) {
        $count += 1;
        push @ref, $ref . "_" . $indice++;
    }

    #print "COUNT $count, @ref\n";
    if (wantarray) {
        return @ref;
    }
    else {
        return $count;
    }
}

sub line_select {
    my ( $self, $ref, $first, $last, $color ) = @_;

    return if ( !defined $ref );

    #print "In  line_select : $self|$ref|$first|$last|\n";
    my $line_ref = get_line_ref_from_ref( $self, $ref );

    if ( !$line_ref )
    {    # La ligne fichier n'est pas � l'�cran, on ne peut pas la s�lectionner
        print STDERR "S�lection impossible, ligne non � l'�cran\n";
        return;
    }
    if ( !defined $first ) {
        $first = 0;
    }
    my $text   = $self->[PARENT]->get_text_from_ref($ref);
    my $length = length($text);
    $last = $length if ( !defined $last );

    if ( $first > $last ) {
        my $temp = $last;
        $last  = $first;
        $first = $temp;
    }
    if ( $first < 0 ) {
        if ( my $previous_ref = $line_ref->[PREVIOUS] ) {
            my $new_ref     = $previous_ref->[REF];
            my $length_text =
              length( $self->[PARENT]->get_text_from_ref($new_ref) );
            my $new_first = $length_text + $first;
            my $new_last  = $length_text + $last;
            return $self->line_select( $new_ref, $new_first, $new_last,
                $color );
        }
        else {
            $first = 0;
        }
    }
    if ( $first > $length ) {
        my $next_ref = $line_ref->[NEXT];
        while ( $next_ref and $next_ref->[NEXT_SAME] ) {
            $next_ref = $next_ref->[NEXT];
        }
        if ($next_ref) {
            my $new_ref = $next_ref->[REF];
            return $self->line_select(
                $new_ref,
                $first - $length,
                $last - $length, $color
            );
        }
        else {
            return;
        }
    }

    #print "4 |$first|$last|\n";
    return if ( $last == $first );

    #print "OK, on va s�lectionner...|$first|$last|\n";

    my $return_value = q{};

    #print "Line select : 1 |$return_value|\n";
    my $offset = $self->[SCREEN][VERTICAL_OFFSET];
  DISPLAY: while ($last) {

        # On ne r�utilise pas display_select pour un peu plus d'efficacit�
        if ( !defined $line_ref ) {
            print STDERR
              "Probl�me de coh�rence entre Abstract et File_manager\n";
            return $return_value;
        }
        my $text   = $line_ref->[TEXT];
        my $length = length($text);
        if ( $first > $length ) {
            $line_ref = $line_ref->[NEXT];
            $first -= $length;
            $last  -= $length;
            next DISPLAY;
        }
        my $left   = line_ref_abs( $self, $line_ref, $first );
        my $bottom = $line_ref->[ORD];
        my $top    = $bottom - $line_ref->[HEIGHT];

        my $right;

        #print "Line select : 2 |$return_value|\n";
        if ( $last <= $length ) {
            $right = line_ref_abs( $self, $line_ref, $last );
            $return_value .= substr( $text, $first, $last - $first );
            $last = 0;
        }
        else {
            $right = line_ref_abs( $self, $line_ref, $length );
            $first = 0;
            $last -= $length;
            if ( $line_ref->[NEXT] and !$line_ref->[NEXT_SAME] ) {
                $return_value .=
                  substr( $text, $first, $length - $first ) . "\n";
            }

            #print "Line select : 3 |$return_value|\n";
        }
        $self->[GRAPHIC]
          ->select( $left - $offset, $top, $right - $offset, $bottom, $color );
        $line_ref = $line_ref->[NEXT];
    }

    #print "Line select : retourne $return_value\n";
    return $return_value;
}

sub bind_key {
    my ( $self, $hash_ref ) = @_;

    my $use = $hash_ref->{'use'};
    eval "use $use"                       if ( defined $use );
    print "EVAL use $use en erreur\n$@\n" if ($@);

    my $sub     = $hash_ref->{'sub'};
    my $package = $hash_ref->{'package'};
    my $key     = $hash_ref->{'key'};

    #print "Dans bind key...$sub, $package, $key, $use\n";
    if ( !defined $sub and $key{$key} ) {
        delete $key{$key};
        return;
    }

    # V�rification de la bonne valeur de key_code � faire (ctrl, alt et shift)
    my $string = "\\&" . $package . "::$sub";

    #print "STRING $string|$package\n";
    #$edit_ref->[REDIRECT]{$redirect} = eval "\\&$package::$sub";
    $key{$key} = eval $string;

    #$key{$key} = eval "\\&$package::$sub";
    print "key_code =$key{$key}\n";
    return;
}

sub display_text {
    my ( $self, $ref_display ) = @_;

    #print "REF NUM dans <text ; $ref_display\n";
    my ( $line_ref, $ref, $count ) =
      get_line_ref_from_display_ref( $self, $ref_display );
    if ($line_ref) {
        return $line_ref->[TEXT];
    }
    print "Pas trouv�\n";
    return;
}

sub display_next {
    my ( $self, $ref_display ) = @_;

    my ( $line_ref, $ref, $count ) =
      get_line_ref_from_display_ref( $self, $ref_display );
    if ( $line_ref and $line_ref->[NEXT] ) {
        return get_display_ref_from( $line_ref->[NEXT] );
    }
    return;
}

sub display_ord {
    my ( $self, $ref_display ) = @_;

    my ($line_ref) = get_line_ref_from_display_ref( $self, $ref_display );
    if ($line_ref) {
        return $line_ref->[ORD];
    }
    return;
}

sub display_height {
    my ( $self, $ref_display ) = @_;

    my ($line_ref) = get_line_ref_from_display_ref( $self, $ref_display );
    if ($line_ref) {
        return $line_ref->[HEIGHT];
    }
    return;
}

sub display_number {
    my ( $self, $ref_display ) = @_;

    # Renvoie le num�ro de la ligne �cran (peut �tre n�gatif)

    my ($search_ref) = get_line_ref_from_display_ref( $self, $ref_display );
    return if ( !$search_ref );

    # Si $number est renseign�, renvoie la '$number' ligne �cran

    my $trouve;
    my $current_number = 0;
    my $line_ref       = $self->[SCREEN][FIRST];
    if ( $search_ref == $line_ref ) {
        $trouve = $current_number;
    }
    while ( $line_ref->[ORD] < 0 and $line_ref ) {
        $current_number += 1;
        $line_ref = $line_ref->[NEXT];
        if ( $search_ref == $line_ref ) {
            $trouve = $current_number;
        }
    }
    if ( defined $trouve ) {
        return $trouve - $current_number + 1;
    }
    $current_number = 0;
    while ($line_ref) {
        $current_number += 1;
        if ( $search_ref == $line_ref ) {
            return $current_number;
        }
        $line_ref = $line_ref->[NEXT];
    }
    return;
}

sub display_previous {
    my ( $self, $ref_display ) = @_;

    my ( $line_ref, $ref, $count ) =
      get_line_ref_from_display_ref( $self, $ref_display );
    if ( $line_ref and $line_ref->[PREVIOUS] ) {
        return get_display_ref_from( $line_ref->[PREVIOUS] );
    }
    return;
}

sub get_line_ref_from_display_ref {
    my ( $self, $ref_display ) = @_;

    my ( $ref, $num ) = split( /_/, $ref_display );

    my $count    = 0;
    my $line_ref = $self->[SCREEN][FIRST];
    my $next;
    while ($line_ref) {
        if ( $line_ref->[REF] == $ref ) {
            $count += 1;
            if ( $count == $num ) {
                return ( $line_ref, $ref, $count );
            }
        }
        $line_ref = $line_ref->[NEXT];
    }
    return;
}

sub get_display_ref_from {
    my ($line_ref) = @_;

    return if ( !$line_ref );
    my $ref   = $line_ref->[REF];
    my $count = 1;
    while ( $line_ref->[PREVIOUS_SAME] ) {
        $line_ref = $line_ref->[PREVIOUS];
        $count += 1;
    }
    return $ref . '_' . $count;
}

sub display_next_is_same {
    my ( $self, $ref_display ) = @_;

    my ( $line_ref, $ref, $count ) =
      get_line_ref_from_display_ref( $self, $ref_display );
    if ($line_ref) {
        if ( $line_ref->[NEXT_SAME] ) {    # peut ne pas �tre d�fini
            return 1;
        }
        return 0;
    }
    return;
}

sub display_previous_is_same {
    my ( $self, $ref_display ) = @_;

    my ( $line_ref, $ref, $count ) =
      get_line_ref_from_display_ref( $self, $ref_display );
    if ($line_ref) {
        if ( $line_ref->[PREVIOUS_SAME] ) {    # peut ne pas �tre d�fini
            return 1;
        }
        return 0;
    }
    return;
}

sub display_abs {
    my ( $edit_ref, $display_ref, $pos ) = @_;

    my ($line_ref) = get_line_ref_from_display_ref( $edit_ref, $display_ref );
    return if ( !$line_ref );
    if ( !defined $pos ) {
        $pos = length( $line_ref->[TEXT] );
    }
    return line_ref_abs( $edit_ref, $line_ref, $pos );
}

sub line_ref_abs {
    my ( $edit_ref, $line_ref, $pos ) = @_;

    my $text_ref = $line_ref->[FIRST];
    while ( $text_ref and $pos > length( $text_ref->[TEXT] ) ) {
        $pos -= length( $text_ref->[TEXT] );
        $text_ref = $text_ref->[NEXT];
    }
    print "Hors display!\n" if ( !$text_ref );
    return                  if ( !$text_ref );  # position demand�e hors display

    #print "$pos|", $text_ref->[TEXT], "\n";

    my $abs = $text_ref->[ABS];
    return $abs if ( $pos == 0 );

    my $sous_chaine = substr( $text_ref->[TEXT], 0, $pos );
    my $increment =
      $edit_ref->[GRAPHIC]->length_text( $sous_chaine, $text_ref->[FONT] );
    return $increment + $abs;
}

sub display_select {
    my ( $self, $display_ref, $first, $last, $mode ) = @_;

    my ($line_ref) = get_line_ref_from_display_ref( $self, $display_ref );
    return if ( !$line_ref );

    $first = 0 if ( !defined $first );
    my $max = length( $line_ref->[TEXT] );
    $last = $max if ( !defined $last or $last > $max );

# Bug � voir : si l'on ne met pas � jour la ligne de l'onglet, la ligne existe dans Abstract mais pas dans Tk ?
#print "DISPLAY ", $line_ref->[TEXT], "|$first|$last|\n";

    my $left = line_ref_abs( $self, $line_ref, $first );

    #print "last = $last\n";
    my $right = line_ref_abs( $self, $line_ref, $last );

    #print "right = $right\n";
    my $bottom = $line_ref->[ORD];
    my $top    = $bottom - $line_ref->[HEIGHT];

    $self->[GRAPHIC]->select( $left, $top, $right, $bottom, $mode );
}

sub parent {
    my ($self) = @_;

    return $self->[PARENT];
}

sub move_bottom {
    my ( $self, $how_much, $previous_line_ref ) = @_;

    return if ( $how_much == 0 );

    $self->[GRAPHIC]->move_tag( 'bottom', 0, $how_much );
    while ( $previous_line_ref->[NEXT] ) {
        $previous_line_ref = $previous_line_ref->[NEXT];
        $previous_line_ref->[ORD] += $how_much;
    }
    if ( $how_much > 0 ) {
        suppress_bottom_invisible_lines($self);
    }
    else {
        display_bottom_of_the_screen($self);
    }
}

sub screen_move {
    my ( $self, $x, $y ) = @_;

    return if ( $x == 0 and $y == 0 );
    $self->[GRAPHIC]->move_tag( 'all', $x, $y );
    my $line_ref = $self->[SCREEN][FIRST];
    while ($line_ref) {
        $line_ref->[ORD] += $y;
        $line_ref = $line_ref->[NEXT];
    }
    if ( $y > 0 ) {
        suppress_bottom_invisible_lines($self);
        display_top_of_the_screen($self);
    }
    else {
        suppress_top_invisible_lines($self);
        display_bottom_of_the_screen($self);
    }
}

sub display_bottom_of_the_screen
{    # Parall�le de la fonction "suppress_bottom_invisible_lines"
    my ($edit_ref) = @_;

    my $screen_ref = $edit_ref->[SCREEN];
    my $last_ref   = $screen_ref->[LAST];

  DISPLAY: while ( $last_ref->[ORD] < $screen_ref->[HEIGHT] ) {
        my $line_ref = read_next_line( $edit_ref, $last_ref );

        #print "Lu :$line_ref->[TEXT]\n";

        if ($line_ref) {
            $last_ref =
              display_line_from_top( $edit_ref, $line_ref, $last_ref->[ORD] );
            $screen_ref->[LAST] = $last_ref;

            # Ajout du tag 'bottom'
            add_tag_complete( $edit_ref, $last_ref, 'bottom' );
        }
        else {
            return;
        }
    }
}

sub display_top_of_the_screen
{    # Parall�le de la fonction "suppress_bottom_invisible_lines"
    my ($edit_ref) = @_;

    my $screen_ref = $edit_ref->[SCREEN];
    my $first_ref  = $screen_ref->[FIRST];

  DISPLAY: while ( $first_ref->[ORD] - $first_ref->[HEIGHT] > 0 ) {
        my $line_ref = read_previous_line( $edit_ref, $first_ref );

        if ($line_ref) {
            $first_ref =
              display_line_from_bottom( $edit_ref, $line_ref,
                $first_ref->[ORD] - $first_ref->[HEIGHT] );
            $screen_ref->[FIRST] = $first_ref;
        }
        else {
            return;
        }
    }
}

sub display_line_from_top {

    # ord est le bas de la ligne en-dessous de laquelle il faut �crire
    my ( $edit_ref, $line_ref, $ord ) = @_;

    my $graphic = $edit_ref->[GRAPHIC];
    $line_ref->[HEIGHT] = 0;

    my ( $overwrite_ref, $still_to_display_ref ) =
      display_with_tag( $edit_ref, $line_ref, $ord, ['just_created'] );
    while ( defined $still_to_display_ref ) {
        $graphic->move_tag( 'just_created', 0, $overwrite_ref->[HEIGHT] );
        $graphic->delete_tag('just_created');
        $ord += $overwrite_ref->[HEIGHT];
        $overwrite_ref->[ORD] = $ord;

        ( $overwrite_ref, $still_to_display_ref ) =
          display_with_tag( $edit_ref, $still_to_display_ref, $ord,
            ['just_created'] );
    }
    $graphic->move_tag( 'just_created', 0, $overwrite_ref->[HEIGHT] );
    $graphic->delete_tag('just_created');
    $overwrite_ref->[ORD] = $ord + $overwrite_ref->[HEIGHT];

    #		print "D|", $overwrite_ref->[ORD] - $overwrite_ref->[HEIGHT], "|",
    #		    $overwrite_ref->[HEIGHT], "|", $overwrite_ref->[ORD], "|",
    #			$overwrite_ref->[TEXT], "\n";

    check_cursor( $edit_ref, $line_ref );
    return $overwrite_ref;
}

sub display_line_from_bottom {

    # ord est le haut de la ligne au-dessus de laquelle il faut �crire
    my ( $edit_ref, $line_ref, $ord ) = @_;

    $line_ref->[HEIGHT] = 0;

    my ( $overwrite_ref, $still_to_display_ref ) =
      display_with_tag( $edit_ref, $line_ref, $ord, ['just_created'] );
    while ( defined $still_to_display_ref ) {
        $overwrite_ref->[ORD] = $ord;

        ( $overwrite_ref, $still_to_display_ref ) =
          display_with_tag( $edit_ref, $still_to_display_ref, $ord );

        $edit_ref->[GRAPHIC]
          ->move_tag( 'just_created', 0, -$overwrite_ref->[HEIGHT] );
        my $previous_line_ref = $overwrite_ref;
        while ( $previous_line_ref->[PREVIOUS_SAME] ) {
            $previous_line_ref = $previous_line_ref->[PREVIOUS];
            $previous_line_ref->[ORD] -= $overwrite_ref->[HEIGHT];
        }
        if ($still_to_display_ref) {
            add_tag( $edit_ref, $overwrite_ref, 'just_created' );
        }
    }
    $edit_ref->[GRAPHIC]->delete_tag('just_created');
    $overwrite_ref->[ORD] = $ord;

    check_cursor( $edit_ref, $line_ref );
    return $line_ref;
}

sub add_tag {
    my ( $self, $line_ref, $tag ) = @_;

    my $text_ref = $line_ref->[FIRST];
    while ($text_ref) {
        $self->[GRAPHIC]->add_tag( $tag, $text_ref->[ID] );
        $text_ref = $text_ref->[NEXT];
    }
}

sub add_tag_complete {
    my ( $self, $line_ref, $tag ) = @_;

    while ( $line_ref->[PREVIOUS_SAME] ) {
        $line_ref = $line_ref->[PREVIOUS];
    }
    add_tag( $self, $line_ref, $tag );
    while ( $line_ref->[NEXT_SAME] ) {
        $line_ref = $line_ref->[NEXT];
        add_tag( $self, $line_ref, $tag );
    }
}

sub display_with_tag {
    my ( $edit_ref, $line_ref, $ord, $tag_ref ) = @_;

    if ( !defined $tag_ref ) {
        $tag_ref = 'text';
    }
    else {
        push @{$tag_ref}, 'text';
    }
    my $text_ref = $line_ref->[FIRST];
    $line_ref->[HEIGHT] = 0;
    my $current_abs  = $edit_ref->[SCREEN][MARGIN];
    my $current_curs = 0;

  TEXT: while ($text_ref) {
        $text_ref->[ABS] = $current_abs;
        my ( $width, $height ) =
          display_text_from_memory( $edit_ref, $text_ref, $ord, $tag_ref );
        $current_abs += $width;
        $line_ref->[HEIGHT] = $height if ( $height > $line_ref->[HEIGHT] );
        $current_curs += length( $text_ref->[TEXT] );

        if (    $edit_ref->[SCREEN][WRAP]
            and $current_abs >
            ( $edit_ref->[SCREEN][WIDTH] - $edit_ref->[SCREEN][MARGIN] ) )
        {
            my $new_line_ref =
              trunc( $edit_ref, $line_ref, $text_ref, $current_curs, 'bottom' );
            return ( $line_ref, $new_line_ref );
        }
        $text_ref = $text_ref->[NEXT];
    }
    return $line_ref;
}

sub get_line_ords {
    my ($line_ref) = @_;

    my $previous_ref = $line_ref;
    while ( $previous_ref->[PREVIOUS_SAME] ) {
        $previous_ref = $previous_ref->[PREVIOUS];
    }
    while ( $line_ref->[NEXT_SAME] ) {
        $line_ref = $line_ref->[NEXT];
    }
    return ( $previous_ref->[ORD] - $previous_ref->[HEIGHT], $line_ref->[ORD] );
}

sub save_search {
    my ( $self, $exp, $line_start, $line_stop, $pos_start ) = @_;

    print "POS START = $pos_start\n";
    $self->[REGEXP] = {
        'line_start' => $line_start,
        'line_stop'  => $line_stop,
        'pos_start'  => $pos_start,
        'exp'        => $exp,
    };
}

sub load_search {
    my ($self) = @_;

    return $self->[REGEXP];
}

sub focus {
    my ( $self, $hash_ref ) = @_;

    on_top( $self, $hash_ref );

    #$self->deselect;
    $self->[GRAPHIC]->focus;
}

sub on_top {
    my ( $self, $hash_ref ) = @_;    # hash_ref est d�fini qu'en cr�ation
    my $zone = $self->[GRAPHIC]->get_zone;

    print "Dans abstract on_top : zone = $zone, $self->[PARENT]|",
      $self->[PARENT]->ref, "|\n";

    my $graphic = Graphic->get_graphic_focused_in_zone($zone);
    if ( defined $graphic and ref $graphic eq 'Graphic' ) {
        return if ( $graphic == $self->[GRAPHIC] );

        #print "R�el changement de on_top...\n";
        $graphic->forget;
    }

    $self->[GRAPHIC]->on_top;

# Recherche de tous les �diteurs qui ont "on_top" comme �v�nements : � revoir (un peu long)
# Appel en asynchrone (modification pour pourvoir partager des variables compliqu�es dans Tab.pm)
#for my $abstract_ref ( values %abstract ) {
#		if ( my $sub_ref = $abstract_ref->[REDIRECT]{'on_top_last'} ) {
#				$abstract_ref->[PARENT]->redirect( $sub_ref, $abstract_ref, {
#						'editor' => $self->[UNIQUE],
#						'zone' => $zone,
#						}
#				);
#		}
#}
    my $event_ref = $event_zone{$zone};
    if ( defined $event_ref
        and my $data_ref = $event_ref->{'on_top_editor_change'} )
    {
        $data_ref->{'sub_ref'}
          ->( $self->[PARENT], $data_ref->{'tab_ref'}, $hash_ref );
    }
}

sub empty {    # Vidage de l'�diteur
    my ($self) = @_;

    # Horribles fuites m�moires !!
    # ------------------------------
    #sleep 2;

    clear_screen($self);

    $self->[PARENT]->empty_internal;

    #print "Taille self avant nettoyage :", total_size($self) , "\n";
    clean($self);

    #print "Taille self apr�s nettoyage :", total_size($self), "\n";

    my $line_ref;
    $line_ref->[TEXT] = "";
    $line_ref->[REF]  = $self->[PARENT]->get_ref_for_empty_structure;
    create_text_in_line( $self, $line_ref );
    $self->display( $line_ref->[REF], { 'at' => 'top' } );

    # Positionnement du curseur
    cursor_set( $self, 0, $line_ref->[REF] );

    #sleep 2;

}

sub clean {
    my ($self) = @_;

    my $to_delete_ref = $self->[SCREEN][FIRST];
    $self->[SCREEN][FIRST] = 0;
    while ($to_delete_ref) {
        my $next_ref = $to_delete_ref->[NEXT];
        $to_delete_ref->[NEXT]     = 0;
        $to_delete_ref->[PREVIOUS] = 0;
        $to_delete_ref             = $next_ref;
    }
    $self->[SCREEN][LAST] = 0;
}

sub abstract_eval {
    my ( $self, $program ) = @_;

    print "\n\n$program\n", threads->tid, "$origin, $sub_origin\n";
    eval "$program";
    print $@ if ($@);
}

sub abstract_size {
    my $total;
    for my $self ( sort keys %abstract ) {
        my $size = total_size( $abstract{$self} );
        print "Taille $self : $size\n";
        $total += $size;
    }
    print "=> Taille totale : $total\n";
}

sub increase_line_space {
    my ($self) = values %abstract;

    print "In increase_line_offset\n";
    $self->[GRAPHIC]->increase_line_offset;
    resize_all();
}

sub decrease_line_space {
    my ($self) = values %abstract;

    print "In increase_line_offset\n";
    $self->[GRAPHIC]->decrease_line_offset;
    resize_all();
}

sub resize_all {

    #my @zones = Zone->list;
    #ZONE: for my $zone ( @zones ) {
    #print "Zone $zone\n";
    #my $graphic = Graphic->get_graphic_focused_in_zone ( $zone );
    for my $abstract_ref ( values %abstract ) {

        #if ( $graphic == $abstract_ref->[GRAPHIC] ) {
        print "Editor $abstract_ref->[UNIQUE]\n";
        $abstract_ref->deselect;
        resize(
            $abstract_ref,
            $abstract_ref->[SCREEN][WIDTH],
            $abstract_ref->[SCREEN][HEIGHT]
        );

        #next ZONE;
        #}
    }

    #}
}

sub reference_zone_event {
    my ( $self, $name, $event, $hash_ref ) = @_;

    print "Dans reference_zone_event $name,$event, ", $hash_ref->{sub}[0],
      $hash_ref->{sub}[1], "\n";
    my $use = $hash_ref->{'use'};
    if ( defined $use and !$use{$use} ) {
        eval "use $use";
        print "EVAL use $use en erreur\n$@\n" if ($@);
        $use{$use} = 1;
    }
    my $package = $hash_ref->{'package'};
    $package = 'main' if ( !defined $package );
    if ( my $sub = $hash_ref->{'sub'}[0] ) {
        $event_zone{$name}{$event}{sub_ref} = eval "\\&${package}::$sub";
        $event_zone{$name}{$event}{tab_ref} = $hash_ref->{sub}[1];
    }
}

1;
