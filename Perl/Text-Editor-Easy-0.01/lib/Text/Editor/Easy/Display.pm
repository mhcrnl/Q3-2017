package Display;

# Ce package n'est qu'une interface orient�e objet � des fonctions de File_manager.pm rendues inaccessibles (ne se trouvent
# pas dans les hachages g�r�s par AUTOLOAD de Editor) car susceptibles de changer

# Les fonctions de File_manager.pm r�alisant toutes les m�thodes de ce package commencent par "line_" puis reprennent
# le nom de la m�thode

use strict;
use Scalar::Util qw(refaddr weaken);

#use Easy::Comm;
use Comm;

# 2 attributs pour un objet "Line"
my %ref_Editor;    # Une ligne appartient � un �diteur unique
my %ref_id;        # A une ligne, correspond un identifiant

# Recherche d'un identifiant pour un �diteur donn�
my %ref_line
  ; # Il y aura autant de hachage de r�f�rences que de threads demandeurs de lignes

sub new {
    my ( $classe, $ref_Editor, $ref_id ) = @_;

    return if ( !$ref_id );
    my $line = $ref_line{$ref_Editor}{$ref_id};
    if ($line) {
        return $line;
    }
    my $unique_ref = $ref_Editor->ref;
    $line = bless \do { my $anonymous_scalar }, $classe;

    my $ref = refaddr $line;
    $ref_Editor{$ref}               = $ref_Editor;
    $ref_id{$ref}                   = $ref_id;
    $ref_line{$ref_Editor}{$ref_id} = $line;
    weaken $ref_line{$ref_Editor}{$ref_id};

    return $line;
}

sub next {
    my ($self) = @_;

    my $ref        = refaddr $self;
    my $ref_editor = $ref_Editor{$ref};
    my $next_id    = $ref_editor->display_next( $ref_id{$ref} );
    return Display->new(
        $ref_editor
        , # Cette r�f�rence n'est renseign�e que pour l'objet editeur du thread principal (tid == 0)
        $next_id,
    );
}

sub previous {
    my ($self) = @_;

    my $ref         = refaddr $self;
    my $ref_editor  = $ref_Editor{$ref};
    my $previous_id = $ref_editor->display_previous( $ref_id{$ref} );
    return Display->new(
        $ref_editor
        , # Cette r�f�rence n'est renseign�e que pour l'objet editeur du thread principal (tid == 0)
        $previous_id,
    );
}

sub next_in_file {
    my ($self) = @_;

    my $ref = refaddr $self;
    my ( $id, $num ) = split( /_/, $ref_id{$ref} );
    my $ref_editor = $ref_Editor{$ref};
    my ($next_id) = $ref_editor->next_line($id);
    return Line->new(
        $ref_editor
        , # Cette r�f�rence n'est renseign�e que pour l'objet editeur du thread principal (tid == 0)
        $next_id,
    );
}

sub previous_in_file {
    my ($self) = @_;

    my $ref = refaddr $self;
    my ($id) = split( /_/, $ref_id{$ref} );
    my $ref_editor = $ref_Editor{$ref};
    my ($previous_id) = $ref_editor->previous_line($id);

    return Line->new(
        $ref_editor
        , # Cette r�f�rence n'est renseign�e que pour l'objet editeur du thread principal (tid == 0)
        $previous_id,
    );
}

sub line {
    my ($self) = @_;

    my $ref = refaddr $self;
    my ( $id, $num ) = split( /_/, $ref_id{$ref} );
    my $ref_editor = $ref_Editor{$ref};

    return Line->new(
        $ref_Editor{$ref}
        , # Cette r�f�rence n'est renseign�e que pour l'objet editeur du thread principal (tid == 0)
        $id,
    );
}

sub ref {
    my ($self) = @_;

    return $ref_id{ refaddr $self };
}

sub DESTROY {
    my ($self) = @_;

    my $ref = refaddr $self;

    #print "Destructions de ", $ref_id{ $ref }, ", ", threads->tid, "\n";

    # A revoir : pas rigoureux
    return if ( !$ref );
    if ( defined $ref_Editor{$ref} ) {
        if ( defined $ref_line{ $ref_Editor{$ref} } ) {
            if ( defined $ref_line{ $ref_Editor{$ref} }{ $ref_id{$ref} } ) {
                delete $ref_line{ $ref_Editor{$ref} }{ $ref_id{$ref} };
            }
            delete $ref_line{ $ref_Editor{$ref} };
        }
        delete $ref_Editor{$ref};
    }
    delete $ref_id{$ref};
}

my %sub = (
    'text'             => [ 'graphic', \&Abstract::display_text ],
    'next_is_same'     => [ 'graphic', \&Abstract::display_next_is_same ],
    'previous_is_same' => [ 'graphic', \&Abstract::display_previous_is_same ],
    'ord'              => [ 'graphic', \&Abstract::display_ord ],
    'height'           => [ 'graphic', \&Abstract::display_height ],
    'number'           => [ 'graphic', \&Abstract::display_number ],
    'abs'              => [ 'graphic', \&Abstract::display_abs ],
    'select'           => [ 'graphic', \&Abstract::display_select ],
);

sub AUTOLOAD {
    return if our $AUTOLOAD =~ /::DESTROY/;

    my ( $self, @param ) = @_;

    my $what = $AUTOLOAD;
    $what =~ s/^(\w+):://;

    if ( !$sub{$what} ) {
        print "La m�thode $what n'est pas connue de l'objet Display\n";
        return;
    }

    my $ref        = refaddr $self;
    my $ref_editor = $ref_Editor{$ref};

    return $ref_editor->ask2( 'display_' . $what, $ref_id{$ref}, @param );
}

# M�thode de paquetage : compte le nombre d'objets "Line" en m�moire pour ce thread
sub count {
    my $total = 0;

    for my $edit ( keys %ref_line ) {
        $total += scalar( keys %{ $ref_line{$edit} } );
    }
    return $total;
}

1;
