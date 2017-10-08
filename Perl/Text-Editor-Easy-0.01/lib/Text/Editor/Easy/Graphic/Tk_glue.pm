use strict;
use warnings;

package Graphic;
use Tk;
use Tk::Scrollbar;    # perl2exe
use Tk::Canvas;       # perl2exe

use Scalar::Util qw(refaddr);

my %editor
  ;    # A un canevas, on fait correspondre un �diteur, l'�diteur qui a le focus

#my %canva; # A un �diteur, on fait correspondre un canevas : inutile, car contenu
# dans l'objet Graphic et accessible par ->[CANVA]
my %graphic;    # Liste des objets graphiques cr��s
my $repeat_id;

my %zone;

use constant {
    TOP_LEVEL => 0,
    CANVA     => 1,
    SCROLLBAR => 2,
    FIND      => 3,
    CTRL      => 4,
    ALT       => 5,
    SHIFT     => 6,
    ZONE      => 7,

    # FIND
    #TOP_LEVEL => 0,
    ENTRY  => 1,
    REGEXP => 2,
};

sub new {
    my ( $class, $hash_ref ) = @_;

    my $zone_ref = $hash_ref->{'zone'};

    my $self = [];
    bless $self, $class;
    $self->initialize($hash_ref);

    # R�f�rencement
    $graphic{ refaddr $self} = $self;
    return $self;
}

sub initialize {
    my ( $self, $hash_ref ) = @_;
    my $mw;
    if ( $hash_ref->{main_window} ) {

        #print "La fen�tre principale a d�j� �t� cr��e\n";
        $mw = $hash_ref->{main_window};
    }
    elsif (%graphic) {    # La mainwindow est d�j� cr��e, on reprend la m�me
        for ( keys %graphic ) {
            if ( $_ != refaddr $self ) {
                $mw = $graphic{$_}->get_mw;

                # Cancel de la boucle provisoire
                $repeat_id->cancel;
                last;
            }
        }
    }
    else {
        $mw = create_main_window(
            $hash_ref->{width},    $hash_ref->{height},
            $hash_ref->{x_offset}, $hash_ref->{y_offset},
            $hash_ref->{title},
        );
    }
    $self->[TOP_LEVEL] = $mw;

    #$self->[SCROLLBAR] = create_scrollbar (
    #  $mw,
    #  $hash_ref->{vertical_scrollbar_sub},
    #    $hash_ref->{vertical_scrollbar_position},
    # );
    my $canva;
    my $zone_ref = $hash_ref->{'zone'};
    if ( $hash_ref->{canvas} ) {

        #print "Le canevas existe d�j�\n";
        $canva = $hash_ref->{canvas};
    }
    else {
        ( $canva, $zone_ref ) = create_canva(
            $mw,
            $hash_ref->{background},
            $hash_ref->{'zone'},
            -xscrollincrement => 0,
            -yscrollincrement => 0,
        );
    }
    $self->[ZONE] = $zone_ref;
    if ( $hash_ref->{editor_ref} ) {
        $editor{ refaddr $canva} = $hash_ref->{editor_ref};
    }
    $self->[CANVA] = $canva;
    $canva->CanvasBind( '<Button-1>',
        [ \&redirect, $hash_ref->{clic}, Ev('x'), Ev('y') ] );
    $canva->CanvasBind( '<Configure>',
        [ \&resize, $hash_ref->{resize}, Ev('w'), Ev('h') ] );
    $canva->CanvasBind( '<KeyPress>' =>
          [ \&key_press, $self, $hash_ref->{key_press}, Ev('K'), Ev('A') ] );
    $canva->CanvasBind( '<4>',
        [ \&redirect, $hash_ref->{mouse_wheel_event}, Ev('D') ] );
    $canva->CanvasBind( '<5>',
        [ \&redirect, $hash_ref->{mouse_wheel_event}, Ev('D') ] );
    $canva->CanvasBind( '<KeyRelease>' => [ \&key_release, $self, Ev('K') ] );

    if ( $hash_ref->{mouse_move} ) {
        $canva->CanvasBind( '<Motion>',
            [ \&redirect, $hash_ref->{mouse_move}, Ev('x'), Ev('y') ] );
    }

    $canva->xviewMoveto(0);
    $canva->yviewMoveto(0);

    #$mw->repeat(10, [ $hash_ref->{repeat}, $editor{refaddr $canva} ] );
}

sub launch_loop {
    my ( $self, $sub, $editor ) = @_;

    $repeat_id = $self->[TOP_LEVEL]->repeat( 15, [ $sub, $editor ] );

    #$self->[TOP_LEVEL]->repeat(600, [ $sub, $editor ] );
}

sub redirect {
    my ( $canva, $sub_ref, @data ) = @_;

    my $editor_ref = $editor{ refaddr $canva};
    $sub_ref->( $editor_ref, @data );
}

sub key_press {
    my ( $canva, $self, $sub_ref, $key, $ascii ) = @_;
    my $editor_ref = $editor{ refaddr $canva};

    if ( $key eq "Control_L" or $key eq "Control_R" ) {
        $self->[CTRL] = 1;
        return;
    }
    if ( $key eq "Alt_L" ) {
        $self->[ALT] = 1;
        return;
    }
    if ( $key eq "Shift_L" or $key eq "Shift_R" ) {
        $self->[SHIFT] = 1;
        return;
    }

    $sub_ref->(
        $editor_ref,
        $key, $ascii,
        {
            'ctrl'  => $self->[CTRL],
            'alt'   => $self->[ALT],
            'shift' => $self->[SHIFT],
        }
    );

    # Tk->break ne marche pas car le d�placement du canevas s'effectue avant :
    # touches up, down, right et left
    $canva->xviewMoveto(0);
    $canva->yviewMoveto(0);
}

sub create_main_window {
    my ( $width, $height, $x, $y, $title ) = @_;
    my $mw = MainWindow->new( -title => $title );
    $mw->geometry("${width}x$height+$x+$y");
    return $mw;
}

sub get_geometry {
    my ($self) = @_;

    my $geometry = $self->[TOP_LEVEL]->geometry;
    my ( $width, $height, $x, $y ) = $geometry =~ /(\d+)x(\d+)\+(\d+)\+(\d+)/;
    return ( $width, $height, $x, $y );
}

sub set_geometry {
    my ( $self, $width, $height, $x, $y ) = @_;

    $self->[TOP_LEVEL]->geometry("${width}x$height+$x+$y");
}

sub change_title {
    my ( $self, $title ) = @_;

    $self->[TOP_LEVEL]->configure( -title => $title );
}

sub create_scrollbar {
    my ( $mw, $call_back_ref, $position ) = @_;

    my $scrollbar =
      $mw->Scrollbar( -command => $call_back_ref, )
      ->pack( -side => $position, -fill => 'y' );
    return $scrollbar;    # inutile mais plus prudent en cas d'ajout...
}

sub create_canva {
    my ( $mw, $color, $zone_ref ) = @_;
    my %zone_local;
    if ( !defined $zone_ref ) {
        %zone_local = (
            -x         => 0,
            -y         => 0,
            -relwidth  => 1,
            -relheight => 1,
            'name'     => 'none'
        );
        $zone_ref = \%zone_local;
    }
    else {
        %zone_local = %$zone_ref;
    }

    #print "DAns create canva : ", $zone_ref->{'name'}, "\n";
    delete $zone_local{'name'};
    delete $zone_local{'on_top_editor_change'};

    my $canva = $mw->Canvas(
        -background => $color,

        #)->pack( -expand => 1, -fill => 'both' );
    )->place( -in => $mw, %zone_local );
    return ( $canva, $zone_ref );
}

sub create_font {
    my ( $graphic, $hash_ref ) = @_;
    my @underline;
    if ( $hash_ref->{underline} ) {
        @underline = ( "-underline", 1 );
    }
    my @slant = ( "-slant", "roman" );
    if ( $hash_ref->{slant} ) {
        @slant = ( "-slant", $hash_ref->{slant} );
    }
    return $graphic->[TOP_LEVEL]->fontCreate(
        -family => $hash_ref->{family},
        -size   => $hash_ref->{size},
        -weight => $hash_ref->{weight},
        @underline,
        @slant,
    );
}

sub manage_event {

    #my ( $self ) = @_;
    #print "On rentre dans la mainloop\n";
    MainLoop;
}

# After initialisation

sub length_text {
    my ( $self, $text, $font ) = @_;

    return $self->[CANVA]->fontMeasure( $font, $text );
}

sub set_scrollbar {
    my ( $self, $top, $bottom ) = @_;

    #$self->[SCROLLBAR]->set ( $top, $bottom);
    return ( $top, $bottom );
}

sub get_scrollbar {
    my ($self) = @_;

    #return $self->[SCROLLBAR]->get;
}

my $line_offset = 3;

sub create_text_and_mark_it {
    my ( $self, $hash_ref ) = @_;

    my $id = $self->[CANVA]->createText(
        $hash_ref->{abs},
        $hash_ref->{ord},

        #-tag    => ['text', 'just_created'] ,
        -tag    => $hash_ref->{tag},
        -text   => $hash_ref->{text},
        -anchor => $hash_ref->{anchor},
        -font   => $hash_ref->{font},
        -fill   => $hash_ref->{color},
    );
    my ( $x1, $y1, $x2, $y2 ) = $self->[CANVA]->bbox($id);

    #return ( $id, $x2 - $x1 - 2, $y2 - $y1 - 2);
    return ( $id, $x2 - $x1 - 2, $y2 - $y1 + $line_offset );

}

sub size_id {
    my ( $self, $id ) = @_;

    my ( $x1, $y1, $x2, $y2 ) = $self->[CANVA]->bbox($id);

    #return ( $x2 - $x1 - 2, $y2 - $y1 - 2);
    return ( $x2 - $x1 - 2, $y2 - $y1 + $line_offset );
}

sub increase_line_offset {
    $line_offset += 1;
}

sub decrease_line_offset {
    $line_offset -= 1;
}

sub create_text {
    my ( $self, $hash_ref ) = @_;

    my $id = $self->[CANVA]->createText(
        $hash_ref->{abs},
        $hash_ref->{ord},
        -tag    => 'text',
        -text   => $hash_ref->{text},
        -anchor => $hash_ref->{anchor},
        -font   => $hash_ref->{font},
        -fill   => $hash_ref->{color},
    );
    my ( $x1, $y1, $x2, $y2 ) = $self->[CANVA]->bbox($id);
    return ( $id, $x2 - $x1 - 2, $y2 - $y1 - 2 );

}

sub delete_mark_from_text {
    my ($self) = @_;

    $self->[CANVA]->dtag( 'just_created', 'just_created' );
}

sub delete_tag {
    my ( $self, $tag ) = @_;

    $self->[CANVA]->dtag( $tag, $tag );
}

sub change_text_item_property {
    my ( $self, $text_id, $text ) = @_;

    $self->[CANVA]->itemconfigure( $text_id, -text, $text );
}

sub delete_text_item {
    my ( $self, $text_id ) = @_;

    $self->[CANVA]->delete($text_id);
}

sub position_cursor_in_text_item {
    my ( $self, $text_id, $position ) = @_;

    #$self->[CANVA]->CanvasFocus;
    $self->[CANVA]->focus($text_id);
    $self->[CANVA]->icursor( $text_id, $position );
}

sub canva_focus {
    my ($self) = @_;

    $self->[CANVA]->CanvasFocus;
}

sub on_top {
    my ($self) = @_;

    my %local_zone = %{ $self->[ZONE] };

    $zone{ $local_zone{'name'} } = $self;

    delete $local_zone{'name'};
    delete $local_zone{'on_top_editor_change'};
    $self->[CANVA]->place( -in => $self->[TOP_LEVEL], %local_zone );

    #$self->[CANVA]->CanvasFocus;
}

sub focus {
    my ($self) = @_;

    on_top($self);
    $self->[CANVA]->CanvasFocus;
}

sub get_zone {
    my ($self) = @_;

    return $self->[ZONE]->{'name'};
}

sub get_graphic_focused_in_zone {
    my ( $self, $zone ) = @_;

    return $zone{$zone};
}

sub forget {
    my ($self) = @_;

    $self->[CANVA]->placeForget;
}

sub resize {
    my ( $canva, $sub_ref, $height, $width ) = @_;

    #$canva->configure( -scrollregion => [ 2, 2, $width - 2, $height - 2] );
    $canva->configure( -scrollregion => [ 1, 1, $width - 1, $height - 1 ] );

    my $editor_ref = $editor{ refaddr $canva};

    #print "Avant appel resize : $editor_ref\n";
    #print "\t$editor_ref->[8]\n";
    #print "\t$editor_ref\n";
    $sub_ref->( $editor_ref, $height, $width );
}

sub move_tag {
    my ( $self, $tag, $x, $y ) = @_;

    $self->[CANVA]->move( $tag, $x, $y );
}

sub destroy_find {
    my ( $find, $self ) = @_;

    undef $self->[FIND][TOP_LEVEL];
}

sub change_reference {

    # Avant d'appeler cette fonction, faire le m�nage sur le canevas
    my ( $self, $edit_ref, $file_name ) = @_;

    $editor{ refaddr $self->[CANVA] } = $edit_ref;
    $self->[TOP_LEVEL]->configure( -title => $file_name );
}

sub get_displayed_editor {
    my ($editor) = @_;

    my $canva = $editor->[CANVA];
    return $editor{ refaddr $canva };
}

sub set_font_size {
    my ( $self, $font, $size ) = @_;

    $font->delete;
    $font->configure( -size => $size );
}

sub line_height {
    return 30;
}

sub margin {
    return 10;
}

sub clear_screen {
    my ($self) = @_;

    $self->[CANVA]->delete('text');
}

sub key_release {
    my ( undef, $self, $key ) = @_;

    if ( $key eq "Control_L" or $key eq "Control_R" ) {
        $self->[CTRL] = 0;
        return;
    }
    if ( $key eq "Alt_L" ) {
        $self->[ALT] = 0;
        return;
    }
    if ( $key eq "Shift_L" or $key eq "Shift_R" ) {
        $self->[SHIFT] = 0;
        return;
    }
}

sub position_bottom_tag_for_text_lower_than {
    my ( $self, $top, $bottom ) = @_;

    # D'abord supprimer le tag 'bottom'
    $self->[CANVA]->dtag( 'bottom', 'bottom' );
    return if ( $bottom <= $top );

    #print "Tag bottom � positionner entre $top et $bottom\n";
    $self->[CANVA]
      ->addtag( 'bottom', 'enclosed', 0, $top - 4, 1000, $bottom + 17 );

}

sub move_bottom {
    my ( $self, $how_much ) = @_;

    #print "TK glue : move bottom de $how_much\n";
    $self->[CANVA]->move( 'bottom', 0, $how_much * 17 );
}

sub add_tag {
    my ( $self, $tag, $id ) = @_;

    $self->[CANVA]->addtag( $tag, 'withtag', $id );
}

sub select {
    my ( $self, $x1, $y1, $x2, $y2, $color ) = @_;

    if ( !defined $color ) {
        $color = 'yellow';
    }

    #print "$x1|$y1|$x2|$y2|\n";

    $self->[CANVA]->createRectangle(
        $x1, $y1, $x2, $y2,
        -fill => $color,
        -tag  => 'select'
    );
    $self->[CANVA]->lower( 'select', 'text' );

}

sub delete_select {
    my ($self) = @_;

    #print "Suppression des zones s�lectionn�es...\n";

    $self->[CANVA]->delete('select');
}

sub get_mw {
    my ($self) = @_;

    return $self->[TOP_LEVEL];
}

1;
