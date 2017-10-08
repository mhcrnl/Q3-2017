#######################################
#
#        Assistance � la saisie
#
#        Auto indentation
#
#    Am�liorations : faire l'assistance lors de la suppression ( suppression d'un '}' ou d'un ')' ...)
#    Le nombre de caract�res pour l'indentation doit �tre param�trable au niveau g�n�ral
#       et "for�able" pour l'appel courant (comme le mode insert)
#
#######################################

my %opt = (
    "for"   => \&for,
    "while" => \&if,
    "else"  => \&else,
    "if"    => \&if,
    "elsif" => \&if,
);

my %verif_indent = (
    "}" => 1,
    ")" => 1,
    "]" => 1,
);

sub assist_on_inserted_text {
    my ( $edit_ref, $inserted_text, $text_of_line ) = @_;
    if ( $inserted_text =~ / $/ ) {
        if ( $text_of_line =~ /^(\s*)(\w+) +$/ ) {
            my $pos = length($1) + length($2) + 1;
            if ( $opt{$2} ) {
                $opt{$2}->( $edit_ref, length($1), $pos );
            }
        }
    }
    elsif ( defined $verif_indent{$inserted_text} ) {
        test_suppress_indent( $edit_ref, $text_of_line );
    }
}

sub test_suppress_indent {
    my ( $self, $text_of_line ) = @_;

    if ( $text_of_line =~ /^(\s*)(\}|]|\))$/ ) {

        # Attention, ici on suppose une indentation � 4 : � param�trer
        if ( length($1) > 3 ) {
            $self->cursor->set(0);
            $self->erase(4);
            $self->cursor->set( length($1) - 3 );
        }
    }
}

sub if {
    my ( $self, $length, $pos ) = @_;

    my $indent = " " x $length;

    # Attention, ici on suppose une indentation � 4 : � param�trer
    my ($ref) = $self->insert("(  ) {\n$indent    \n$indent}");
    print "REF TEXT = ", $ref->text, "\n";
    $self->cursor->set( $pos + 2, $ref );
}

sub for {
    my ( $self, $length, $pos ) = @_;

    my $indent = " " x $length;

    # Attention, ici on suppose une indentation � 4 : � param�trer
    my ($ref) = $self->insert("(  ) {\n$indent    \n$indent}");
    $self->cursor->set( $pos, $ref );
}

sub else {
    my ( $self, $length, $pos ) = @_;

    my $indent = " " x $length;
    my ( $ref, $next ) = $self->insert("{\n$indent    \n$indent}");
    $self->cursor->set( length($indent) + 4, $next );
}

my %indent = (
    "{" => 1,
    "(" => 1,
    "[" => 1,
);

sub indent_on_return {
    my ( $self, $text ) = @_;

    # R�cup�ration de l'indentation de la ligne pr�c�dente
    my ($indent) = $text =~ /^(\s+)/;

    # R�cup�ration du dernier caract�re de la ligne pr�c�dente
    my ($last) = $text =~ /(\S)\s*$/;

    #print "$text\nINDENT |", length($indent), "| last |$last|\n";
    # Attention, aussi bien $indent que $last peuvent �tre ind�finis
    if ( $last and $indent{$last} ) {
        $self->insert( " " x length($indent) . "    ", { 'insert' => 1 } );
    }
    elsif ($indent)
    { # A essayer de faire, l'indentation retour en cas de cassure d'une ligne juste avant ), ] ou }
        $self->insert( " " x length($indent), { 'insert' => 1 } );
    }
}

1;
