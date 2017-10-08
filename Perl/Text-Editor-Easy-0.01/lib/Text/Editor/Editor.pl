#!/usr/bin/perl
use strict;
use lib '.';
use Editor;

use IO::File;

# Start of launching perl process (F5 key management)
open EXEC, "| perl exec.pl" or die "Fork impossible\n";
autoflush EXEC;

use threads;
use threads::shared;

# ==> perl2exe
use Easy::Trace::Print;
use utf8;
use Easy::Syntax::Perl_glue;

# Main tab "zone", area of the main window (syntax re-used : 'place' of Tk)
my $zone4 = Zone->new(
    {
        '-x'        => 0,
        '-rely'     => 0,
        '-relwidth' => 1,
        '-height'   => 25,
        'name'      => 'zone4',
    }
);

# List of main tab files (loading delayed)
my @files_session;
for my $demo ( 1 .. 9 ) {
    my $file_name = "demo${demo}.pl";
    push @files_session,
      {
        'zone'      => 'zone1',
        'file'      => $file_name,
        'name'      => $file_name,
        'highlight' => {
            'use'     => 'Easy::Syntax::Perl_glue',
            'package' => 'Sup',
            'sub'     => 'syntax',
        },
      };
}

# Main tab
Editor->new(
    {
        'zone'        => $zone4,
        'sub'         => 'main',
        'motion_last' => {
            'use'     => 'Easy::Program::Tab',
            'package' => 'Easy::Program::Tab',
            'sub'     => 'motion_over_tab',
            'mode'    => 'async',
        },
        'save_info' => {
            'file_list' => \@files_session,
            'color'     => 'yellow',
        },
    }
);

# End of launching perl process (F5 key management)
print EXEC "quit\n";

sub main {
    my ( $onglet, @parm ) = @_;

    my $out_tab_zone = Zone->new(
        {
            '-relx'     => 0.5,
            '-y'        => 25,
            '-relwidth' => 0.5,
            '-height'   => 25,
            'name'      => 'out_tab_zone',
        }
    );

    my $out_tab = Editor->new(
        {
            'zone'        => $out_tab_zone,
            'motion_last' => {
                'use'     => 'Easy::Program::Tab',
                'package' => 'Easy::Program::Tab',
                'sub'     => 'motion_over_tab',
                'mode'    => 'async',
            },
            'save_info' => { 'color' => 'green', },
        }
    );

    my $zone1 = Zone->new(
        {
            '-x'                   => 0,
            '-y'                   => 25,
            '-relwidth'            => 0.5,
            '-relheight'           => 0.7,
            '-height'              => -25,
            'name'                 => 'zone1',
            'on_top_editor_change' => {
                'use'     => 'Easy::Program::Tab',
                'package' => 'Easy::Program::Tab',
                'sub'     => [ 'on_main_editor_change', $onglet->ref ],
            }
        }
    );

    Editor->new(
        {
            'zone'      => $zone1,
            'file'      => 'demo1.pl',
            'highlight' => {
                'use'     => 'Easy::Syntax::Perl_glue',
                'package' => 'Sup',
                'sub'     => 'syntax',
            },
        }
    );

# bind_key is (version 0.1 !) a pseudo-class method :
# For key binding, there will be class call (all Editor objects) and instance call (only one)
    $out_tab->bind_key(
        { 'package' => 'main', 'sub' => 'launch', 'key' => 'F5' } );

    # Zone des display
    my $zone2 = Zone->new(
        {
            '-relx'                => 0.5,
            '-y'                   => 50,
            '-relwidth'            => 0.5,
            '-relheight'           => 0.7,
            '-height'              => -50,
            'name'                 => 'zone2',
            'on_top_editor_change' => {
                'use'     => 'Easy::Program::Tab',
                'package' => 'Easy::Program::Tab',
                'sub'     => [ 'on_top_editor_change', $out_tab->ref ],
            }
        }
    );

    # Zone des appels de display, traces
    my $zone3 = Zone->new(
        {
            '-relx'      => 0.5,
            '-rely'      => 0.7,
            '-relwidth'  => 0.5,
            '-relheight' => 0.3,
            'name'       => 'zone3',
        }
    );
    my $who = Editor->new(
        {
            'zone'        => $zone3,
            'name'        => 'stack_calls',
            'motion_last' => {
                'use'     => 'Motion',
                'package' => 'Motion',
                'sub'     => 'cursor_set_on_who_file',
                'mode'    => 'async',

               #'only' => '$origin eq "graphic" or $sub_origin eq "cursor_set"',
                'init' => [ 'init_set', $zone1 ]
            },
        }
    );
    use File::Basename;
    my $name  = fileparse($0);
    my $out_1 = Editor->new(
        {
            'zone'         => $zone2,
            'file'         => "tmp/${name}_trace.trc",
            'name'         => 'Editor_out',
            'growing_file' => 1,
            'motion_last'  => {
                'use'     => 'Motion',
                'package' => 'Motion',
                'sub'     => 'move_over_out_editor',
                'mode'    => 'async',
                'init'    => [ 'init_move', $who->ref, $zone1 ],
            },
        }
    );
    my $out = Editor->new(
        {
            'zone' => $zone2,
            'name' => 'Eval_out',
        }
    );

    my $zone5 = Zone->new(
        {
            '-x'         => 0,
            '-rely'      => 0.7,
            '-relwidth'  => 0.5,
            '-relheight' => 0.3,
            'name'       => 'zone5',
        }
    );
    my $macro = Editor->new(
        {
            'zone'        => $zone5,
            'insert_last' => {
                'use'     => 'Easy::Program::Search',
                'package' => 'Easy::Program::Search',
                'sub'     => 'modify_pattern',
                'mode'    => 'async',
                'only'    => '$origin eq "graphic"',
                'init'    => [ 'init_eval', $out->ref ],
            },
            'highlight' => {
                'use'     => 'Easy::Syntax::Perl_glue',
                'package' => 'Sup',
                'sub'     => 'syntax',
            },
        }
    );

}

sub launch {

    # Appui sur F5
    my ($self) = @_;

    my $file_name = $self->file_name;
    print "In sub 'launch' : $self|$file_name\n";
    if (   $file_name eq 'demo7.pl'
        or $file_name eq 'demo8.pl'
        or $file_name eq 'demo9.pl' )
    {
        my $macro_instructions;
        if ( $file_name eq 'demo7.pl' ) {
            $macro_instructions = << 'END_PROGRAM';
my $editor = Editor->whose_name('stack_calls');
$editor->empty;
$editor->deselect;
my @lines = $editor->insert("Hello world !\nIs there anybody ? body dy dy y ...");
print "\nWritten lines :\n\t", join ("\n\t", @lines), "\n";
$editor->insert ("\n\n\n\n" . $lines[0]->text);
my $next = $lines[0]->next;
print "\nNEXT LINE =\n\n", $next->text;
$next->select;
END_PROGRAM
        }
        elsif ( $file_name eq 'demo8.pl' ) {
            $macro_instructions = << 'END_PROGRAM';
my $editor = Editor->whose_name('stack_calls');
$editor->add_method('demo8');
print $editor->demo8(4, "bof"); 
END_PROGRAM
        }
        else {    # demo9.pl
            $macro_instructions = << 'END_PROGRAM';
my $editor = Editor->whose_name('Key.pm');
if ( ! $editor ) { $editor = Editor->new({ 'zone' => 'zone1', 'file' => "Easy/Key.pm", 'highlight' => { 'use' => 'Easy::Syntax::Perl_glue', 'package' => 'Sup', 'sub' => 'syntax', },});};
$editor->focus;

print "Incomplete list of zones (names will be changed) :\n";
for ( sort Zone->list ) {
    print "\t$_\n";
}
END_PROGRAM
        }
        my $eval_editor = Editor->get_in_zone( 'zone5', 0 );
        $eval_editor->empty;
        $eval_editor->insert($macro_instructions);
        return;
    }
    if ( defined $file_name ) {
        print "fichier $file_name\n";
        print EXEC "$file_name|start|perl -Mflush $file_name\n";
    }
}

sub demo8 {
    my $editor = Editor->whose_name('demo8.pl');
    Editor->substitute_eval_with_file('demo8.pl');

    #print "THREAD TID : ", threads->tid, "\n";
    my $sub_ref = eval $editor->slurp;
    return $sub_ref->(@_);

    #print "End of execution\n";
}

=head1 COPYRIGHT & LICENSE

Copyright 2008 Sebastien Grommier, all rights reserved.

This program is free software; you can redistribute it and/or modify it
under the same terms as Perl itself.


=cut

