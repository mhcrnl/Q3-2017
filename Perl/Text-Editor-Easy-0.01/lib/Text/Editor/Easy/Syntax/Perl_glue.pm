package Sup;

use strict;
use Syntax::Highlight::Perl ':FULL';
my $formatter = new Syntax::Highlight::Perl;

$formatter->define_substitution( 'Z' => 'Z&' );

my $subst_ref = $formatter->substitutions();

my %format = (
    'Comment_Normal'    => [ 'Za' => 'Z:' ],
    'Comment_POD'       => [ 'Zb' => 'Z:' ],
    'Directive'         => [ 'Zc' => 'Z:' ],
    'Label'             => [ 'Zd' => 'Z:' ],
    'Quote'             => [ 'Ze' => 'Z:' ],
    'String'            => [ 'Zf' => 'Z:' ],
    'Subroutine'        => [ 'Zg' => 'Z:' ],
    'Variable_Scalar'   => [ 'Zh' => 'Z:' ],
    'Variable_Array'    => [ 'Zi' => 'Z:' ],
    'Variable_Hash'     => [ 'Zj' => 'Z:' ],
    'Variable_Typeglob' => [ 'Zk' => 'Z:' ],
    'Whitespace'        => [ 'Zl' => 'Z:' ],
    'Character'         => [ 'Zm' => 'Z:' ],
    'Keyword'           => [ 'Zn' => 'Z:' ],
    'Builtin_Function'  => [ 'Zo' => 'Z:' ],
    'Builtin_Operator'  => [ 'Zp' => 'Z:' ],
    'Operator'          => [ 'Zq' => 'Z:' ],
    'Bareword'          => [ 'Zr' => 'Z:' ],
    'Package'           => [ 'Zs' => 'Z:' ],
    'Number'            => [ 'Zt' => 'Z:' ],
    'Symbol'            => [ 'Zu' => 'Z:' ],
    'CodeTerm'          => [ 'Zv' => 'Z:' ],
    'DATA'              => [ 'Zw' => 'Z:' ],
    'DEFAULT'           => [ 'Zx' => 'Z:' ],
);

$formatter->set_format(%format);

my %name;
for ( keys %format ) {
    my $element = $format{$_}[0];
    if ( $element =~ /Z(.)/ ) {
        $name{$1} = $_;
    }

    #print "name { $1 } = ", $name{$1}, "\n";
}

sub syntax {
    my ($text) = @_;

    my $print = 0;

    #  if ( $text =~ /0/ ) {
    #    $print = 1;
    #  }

    if ( !$text ) {
        return [ $text, "comment" ];
    }

    my @format = ();

    $formatter->reset();
    my $prg = $formatter->format_string($text);

    #print "$prg\n", $name{a}, "\n";;
    print "$prg\n" if $print;
    my $string  = 0;
    my $comment = 0;

    # Par d�faut, format 'DEFAULT'
    my $format_courant = "";
  MATCH: while ( $prg =~ /(.*?)Z([^&]{1})/g ) {
        if ($comment) {

            #print "$1 : $name{a}\n";
            my $element = $1;
            $element =~ s/Z&/Z/g;
            print "$element\n" if $print;
            push @format, [ $element, $name{a} ];
        }
        else {
            if ( defined($1) ) {

                #print "$1 : ", $name{$format_courant}, "\n";
                my $element = $1;
                $element =~ s/Z&/Z/g;
                print "$element\n" if $print;
                push @format, [ $element, $name{$format_courant} ];
            }
        }

        if ( $2 eq ':' ) {
            if ( $format_courant eq "f" or $format_courant eq "a" ) {
                $string         = 0;
                $comment        = 0;
                $format_courant = "";
                next MATCH;
            }
            if ( $string or $comment ) {
                $format_courant = "a" if ($comment);
                $format_courant = "f" if ($string);
                next MATCH;
            }
            if ( $format_courant eq "" ) {
                die "Syntaxe highlight::perl � voir:\n\n$text\n\n, pos = ",
                  pos($text), "\n";
            }
            else {
                $format_courant = "";
            }
        }
        else {
            if ( $2 eq "f" or $2 eq "a" ) {
                $string  = 1 if ( $2 eq "f" );
                $comment = 1 if ( $2 eq "a" );
            }
            $format_courant = "$2";
        }
    }
    return @format;
}

1;
