package Modules::Module;
# Extract data from website blogs.perl.org
require Exporter;

our @ISA     = qw(Exporter);
# symbols to be exported by default (space-separated)
our @EXPORT  = qw(get_time_suffix getTitleM);   
our $VERSION = 1.00;                  # version number
# ------------------------------------------------------------Default modules
use POSIX 'strftime';
use v5.010;
# ------------------------------------------------------------CPAN modules
use Mojo::UserAgent;
#-------------------------------------------------------------Records keeping
my $APP_NAME = "Perl/Tk Text Editor";
my $VERSION = " V0.1";
my $AUTOR = "Mihai Cornel   mhcrnl\@gmail.com";
my $DESCRIPTION = "Text editor application";
my $PERL_VERSION = "v5.24.2"; # $perl -v
my $TK_VERSION = "804.033"; # $perl -MTk -e 'print "$Tk::VERSION\n"

#---------------------------------------------------------------My globals
my $site = 'blogs.perl.org';
my $ua = Mojo::UserAgent->new;

# ---------------------------------------------------------------My Functions
sub getTitleM {
# <h2 class=entry-title><a href="http://blogs.perl.org/users/lichtkind/2017/10/proper-planing-cp-part-iv.html">proper # planing (CP part IV)</a></h2>
    say $ua->get($site)->result->dom->find('h2 > a')->map('text')->join("\n");
    #say $ua->get($site)->result->dom->find('h2 > a')->map('text')->join("\n");
    say $ua->get($site)->result->dom->find('p')->map('text')->join("\n");
    say $ua->get($site)->result->dom->at('h2')->text;
    say $ua->get($site)->result->dom->at('h1')->text;
    say $ua->get($site)->result->dom->at('p')->text;
    say $ua->get($site)->result->dom->at('h3')->text;
}
# get_time_suffix
#----------------

# returns a string formatted like "2008.08.18 / 12:31:56"
# requires "use POSIX 'strftime';"
sub get_time_suffix
{
  return strftime( '%Y.%m.%d / %H:%M:%S', localtime(time()) );
}

1;

