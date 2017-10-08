package Text::Editor::Easy::Program::Save;

use warnings;
use strict;

=head1 NAME

Text::Editor::Easy::Program::Save - This module makes regular saves of the entire "Text::Editor::Easy" tree under developpement.

This is a temporary module to replace the annulation functionnality which is not yet implemented.
The process of regular save is launched only if the Editor.pl program finds a "../../save" directory.

=head1 VERSION

Version 0.49

=cut

our $VERSION = '0.49';

use Text::Editor::Easy;
use Text::Editor::Easy::Comm;

use File::Find;
use Archive::Zip;
use File::Compare qw( compare compare_text );
use File::Copy;
use File::Basename;
use File::Path;



sub init {
    my ( $self ) = @_;
    #print "Dans le thread ", threads->tid, " : ex�cution de l'ajout de m�thode...\n";
    
    $self->{'current'} = "../../save/regular/current_list.txt";
    $self->{'old'} = "../../save/regular/old_list.txt";
    $self->{'dirs_to_clean'} = "../../save/regular/old_dirs_list.txt";
    
    Text::Editor::Easy->repeat_class_method( 10, 'save_arbo');
    
    #open ( OK, "../save/compil_OK
    save_arbo( $self );
}


my @month = qw( Janvier Fevrier Mars Avril Mai Juin Juillet Aout Septembre Octobre Novembre Decembre );
# find ne renvoie pas toujours la liste des fichiers dans le m�me ordre
# et en plus, sa fonction "wanted" n'accepte ni param�tre et n'en renvoie pas non plus
my $tab_ref;


# La proc�dure "save_arbo" (m�thode de classe) sera lanc�e p�riodiquement par le thread 0 (r�utilisation du "repeat" Tk)
sub save_arbo {
    my ( $self ) = @_;
   
    #print "Dans save_arbo de Save.pm, self $self, tid = ", threads->tid, "\n";
   
    # R�cup�ration de tous les �diteurs "zone1"
    my @refs = Text::Editor::Easy->list_in_zone("zone1");

    # On r�cup�re le file_name complet � chaque fois (il peut changer... m�me si pour l'instant, en cas de changement, Data n'est pas � jour)
    for my $ref ( @refs ) {
        # M�thode pas tr�s propre pour appeler une m�thode d'un objet pas cr�� dont on connait la r�f�rence... �vite le bless et l'AUTOLOAD
        # Thread d�di� => sauvegarde synchrone (pas de gestion de l'attente de fin d'ex�cution)
        Text::Editor::Easy::Comm::ask_named_thread(
            #$ref,
            Text::Editor::Easy->get_from_id( $ref ),
            'Text::Editor::Easy::File_manager::save_internal',
            'File_manager'
        );
    }
    
    # R�cup�ration des noms de r�pertoire et d'archive � cr�er �ventuellement (fonctions de l'heure)
    my ( $short_dir, $long_dir, $prefix ) = give_dirs_and_archive_name();
    
    # Constitution de la liste des fichiers actuellement en cours d'�dition (tous ceux qui se trouvent dans
    # l'arborescence sous le r�pertoire courant sauf le r�pertoire "tmp/"
    my @files = ();
    $tab_ref = \@files;
    find({
        'wanted' => \&wanted,
        'no_chdir' => 1,
        }, 
        '.',
    );
    open (FIC, ">$self->{'current'}") or die "Impossible d'ouvrir $self->{'current'} : $!\n";
    for my $file ( sort @files ) {
        print FIC "$file\n";
    }
    close FIC;

    # Si il n'y a jamais eu de pr�c�dentes sauvegardes (ou que les fichiers d'information ont �t� supprim�s)
    if ( ! -f $self->{'dirs_to_clean'} ) {
        tree_copy( $self, $self->{'current'}, $long_dir, $short_dir, $prefix );
        return;
    }
    
    # R�cup�ration du r�pertoire le plus ancien contenant des fichiers non compress�s (premier elligible � la suppression) : premi�re ligne du fichier
    # et r�cup�ration du r�pertoire correspondant � la sauvegarde la plus r�cente : derni�re ligne du fichier
    open ( OLD,     $self->{'dirs_to_clean'} ) or die "Impossible d'ouvrir $self->{'dirs_to_clean'} en lecture : $!\n";
    my @old_dirs;
    my $to_clean = <OLD>;
    chomp $to_clean;
    my $old_dir = $to_clean;

    while ( <OLD> ) {
        push @old_dirs, $_;
        chomp;
        $old_dir = $_;
    }

    # V�rification des changements �ventuels (comparaison des fichiers �dit�s et des fichiers sauvegard�s)
    my $evolution;
    if ( compare( $self->{'current'}, $self->{'old'} ) != 0) {
        # Changement dans la liste des fichiers �dit�s (ajout ou suppression)
        #print "Diff�rence trouv�e dans la liste des fichiers �dit�s\n";
        $evolution = 1;
    }
    else {
        # Pas de changement de la liste, mais un fichier en �dition peut avoir �t� modifi�
        open ( LIST, $self->{'current'} ) or die "Impossible d'ouvrir $self->{'current'} : $!\n";

        FILE: while (<LIST>) {            
            chomp;
            if ( compare_text( "tmp/$_", "$old_dir/$_" ) != 0) {
                #print "Diff�rence trouv�e sur le fichier $_ entre\n";
                #print "\ttmp/$_\n";
                #print "\t$old_dir/$_\n";
                $evolution = 1;
                last FILE;
            }
        }
        close LIST;
    }
    
    #print "Pas de diff�rence trouv�e\n" if ( ! defined $evolution ); 
    if ( $evolution ) {
        tree_copy( $self, $self->{'current'}, $long_dir, $short_dir, $prefix, \@old_dirs );
    }

    # M�nage �ventuel : on s'autorise 100 historiques non compress�s (moins de 300 Mo)
    if ( scalar ( @old_dirs ) > 100 ) {
        rmtree( $to_clean );
        open ( OLD,     ">$self->{'dirs_to_clean'}" ) or die "Impossible d'ouvrir $self->{'dirs_to_clean'} en �criture : $!\n";
        for ( @old_dirs ) {
            print OLD;
        }
        close OLD;
    }
}

sub tree_copy {
    my ( $self, $file_list, $cible, $short_dir, $prefix, $old_dir_ref ) = @_;
    
    my $zip = Archive::Zip->new();
    open ( LIST, $file_list ) or die "Impossible d'ouvrir $file_list : $!\n";

    FILE: while (<LIST>) {            
        chomp;
        copy_with_dir_check ("tmp/$_", "$cible/$_" ) or print STDERR "Erreur lors de la copie de tmp/$_ vers $cible/$_ : $!\n";        
        $zip->addFile( "tmp/$_", $_ );
    }
    close LIST;
    $zip->addString( "Emplacement initial de l'archive :\n\n\t$cible", '.aaa_date.txt' );
    $zip->addDirectory( 'tmp/' );
    $zip->writeToFileNamed( "$short_dir/$prefix.zip" );
    
    mkpath( "$cible/tmp" );    

    open ( OLD,     ">>$self->{'dirs_to_clean'}" ) or die "Impossible d'ouvrir $self->{'dirs_to_clean'} en append : $!\n";
    print OLD "$cible\n";
    close OLD;
    push @$old_dir_ref, "$cible\n" if ( defined $old_dir_ref );
    
    copy( $self->{'current'}, $self->{'old'} );
}

sub copy_with_dir_check {
    my ( $source, $cible ) = @_;

    return 1 if ( copy ( $source, $cible) );

    my ($file_name, $path ) = fileparse( $cible );
    mkpath( $path );    
    
    return copy ( $source, $cible);
}

sub wanted {
    return if ( /tmp\// or -d $_ );

    # On laisse $_ inchang�...
    my $file = $_;
    $file =~ s/^\.\///;
    
    copy_with_dir_check ($_,"tmp/$file") or print STDERR "Erreur lors de la copie de $file vers tmp/$file : $!\n";
    push @$tab_ref, $file;
}

sub give_dirs_and_archive_name {
    my ($sec,$min,$hour,$mday,$mon,$year) = localtime(time);
    $year += 1900;    
    $mday = sprintf("%02d", $mday);
    $hour = sprintf("%02d", $hour);
    $min = sprintf("%02d", $min);
    $sec = sprintf("%02d", $sec);
    
    my $num_mon = sprintf("%02d", $mon + 1);
    
    my $short_dir = "../../save/regular/$year/${num_mon}__$month[$mon]/$mday/${hour}_h/${min}_min";
    my $long_dir = $short_dir . "/${sec}_sec";
    
    return ( 
        $short_dir, 
        $long_dir,
        "${sec}_sec",
    );
}



=head1 COPYRIGHT & LICENSE

Copyright 2008 - 2009 Sebastien Grommier, all rights reserved.

This program is free software; you can redistribute it and/or modify it
under the same terms as Perl itself.

=cut

1;
