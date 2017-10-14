#! /usr/bin/perl

use strict;
use warnings;
use v5.010;
# ---------------------------------------------------------------------------------CPAN Programs
use Mojo::UserAgent;
# -------------------------------------------------------------------------------------My modules
use Modules::Module; 
use Classes::Class;

#----------------------------------------------------------------------------------Records keeping
my $APP_NAME = "Perl/Tk Text Editor";
my $VERSION = " V0.1";
my $AUTOR = "Mihai Cornel   mhcrnl\@gmail.com";
my $DESCRIPTION = "Text editor application";
my $PERL_VERSION = "v5.24.2"; # $perl -v
my $TK_VERSION = "804.033"; # $perl -MTk -e 'print "$Tk::VERSION\n"'
# ----------------------------------------------------------------------------External paths and files
# my $BIN_DIR = "$BASE_DIR/bin/";
# my $DOCS_DIR = "$BASE_DIR/docs/";
# my $IMAGES_DIR = "$BASE_DIR/images/";
# my $SOURCE_DIR = "$BASE_DIR/source/";
#---------------------------------------------------------------My globals
my $site = 'www.perl.org';
my $ua = Mojo::UserAgent->new;

# ---------------------------------------------------------------Run Program
print "WELLCOME TO PERL CONSOLE SCRIPT\n";
#Snake->new('Sammy the Python')->move(5);
print &get_time_suffix();
getTitle();
getTitleM();
say $ua->get($site)->result->dom->at('p')->text;
# ---------------------------------------------------------------My Functions
sub getTitle {
    say $ua->get($site)->result->dom->at('title')->text;
    say $ua->get($site)->result->dom->at('h2')->text;
    say $ua->get($site)->result->dom->at('h1')->text;
    say $ua->get($site)->result->dom->at('p')->text;
    say $ua->get($site)->result->dom->at('h3')->text;
}

=pod



=cut 
