#!/usr/bin/perl -w
#
# Traverse the h2g2.com website and store the specified articles
# (c) Andrew Flegg 2000. Released under the Artistic Licence.
# v1.51 (25-Jan-2001), see http://www.bleb.org/software/pda/

use strict;
use vars qw($CONTENT_START $CONTENT_END %GOT @MODES
	    $TOMERAIDER_LI_WRAP);
use Getopt::Long;
use POSIX;
use HTML::Entities;

# -- Global variables ----------------------------------------
$CONTENT_START = q{<td align="left" valign="top" width="100%"> <FONT face="arial, helvetica, san-serif" SIZE="3">.*?<font face="Arial, Helvetica, sans-serif" color="white"> <DIV.*?((<BLOCKQUOTE>|<P>|<UL>|<OL>|>\s*\w+)};

$CONTENT_END   = q{</div>\s*(<blockquote>.*?</blockquote>)?)\s*<br clear="all"> <table border="0" width="100%"};
%GOT           = ();                   # Ain't got 'owt yet...
@MODES         = qw{XML TomeRaider TRML_Win32 TRML_Palm HTML Dump Text};
# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - 
$TOMERAIDER_LI_WRAP = 70;
# ------------------------------------------------------------

# -- Find out what we're supposed to do ----------------------
my %options = ();
GetOptions(\%options, "help|?",
	              "local|?",
	              "nr|nonrecursive",
	              "single|s",
	              "mode|o:s");
die <<EOM if $options{"help"};
hhgg2xml [options] [<article> ...]  (c) Andrew Flegg 2000
~~~~~~~~                            Released under the Artistic Licence.
Options:
    -h, --help            This message
    -l, --local           Read articles from local filesystem (unavailable)
    -nr, --nonrecursive   Do not travel from one article to another
    -s, --single          Output to STDOUT rather than <article>.h2g2
    -o, --mode=TYPE       Output a particular format, no TYPE lists options

Root articles you might like to consider are:
    * C72, "Life"
    * C73, "The Universe"
and * C74, "Everything".

Please report bugs to <andrew\@bleb.org>. Thanks.

EOM

if (defined($options{"mode"})) {
    my $valid_mode = 0;
    my $wanted     = lc($options{"mode"});
    foreach my $elt (@MODES) {
	if (lc($elt) eq $wanted) { $valid_mode = 1; last; }
    }

    die <<EOM if (($wanted eq "") || ($valid_mode == 0));
hhgg2xml                           (c) Andrew Flegg 2000
                                   Released under the Artistic Licence.
Output modes supported:
    XML            XML-style (no-DTD available, but it ain't hard) [DEFAULT]
    HTML           HTML version of 'Dump', see below
    TomeRaider     Suitable for import into TomeRaider's convertors
    TRML_Win32     The new TR 2 mark-up language (for the desktop viewer)
    TRML_Palm      TRML suitable for the palmtop viewers (EPOC and PalmOS)
    Dump           Raw dump of the hash tables
    Text           Plain text output (large amounts of formatting lost)

Please report bugs to <andrew\@bleb.org>. Thanks.

EOM
}

$options{"local"} = 0            unless $options{"local"};
$options{"nr"}    = 0            unless $options{"nr"};
$options{"mode"}  = "XML"        unless $options{"mode"};
$options{"single"} = 0           unless $options{"single"};
if ($options{"local"}) {
    warn "WARNING: Enabling --nonrecursive for local pages.\n" if $options{nr};
    $options{"nr"} = 1;
}
# ------------------------------------------------------------

#&dump(0, \%options);

my %blank = (dontsave => 1,
	     number   => 'C0');
$GOT{'C0'} = \%blank;
&main($options{"local"},
      uc($options{"mode"}),
      ($options{"nr"} == 0),
      $options{"single"});
exit;


# -- Process stdin and output simplified format ------------------------
#
sub main {
    my ($nonweb, $opMode, $recurse, $onePage) = @_;

    # -- Unbuffer stderr for messages...
    select((select(STDERR), $| = 1)[0]);

    # -- Read in local pages from disk and process...
    if ($nonweb) {
	die "Unable to support local fetching in this version\n";
	foreach $a (@ARGV) {
	    my $page; ($page = uc($a)) =~ s/\.[^\.]{1,5}$//;
	    $page =~ s!^.*/([^/]+)$!$1!;
	    next if $GOT{$page};

	    warn "INFO: Processing '$page' (local)\n";
	    my $data = "";
	    unless (open(IN, "<$a")) {
		warn "WARN: Unable to open $a: $!\n";
		next;
	    }

	    while (<IN>) { $data .= $_; }
	    close(IN);

	    my $a = &parsePage($page, 1, 0, $data);
	    $GOT{$a->{number}} = $a if $a;
	}

    # -- Read in web pages and possibly recurse...
    } else {
	use LWP::Simple;
	die "No start page specified, try --help.\n" if scalar(@ARGV) == 0;

	foreach $a (@ARGV) {
	    my $page = uc($a);
	    if ($page =~ m!([^/]+)\.h2g2$!i) {
		$page = $1;
		warn "INFO: Adding '$page' to already retrieved list\n";
		
		my %data;
		unless (%data = &readXML($a, $page)) {
		    warn "INFO: Can't read '$a', leaving '$page' alone\n";
		    %data = (dontsave => 1,
			     number   => $page);
		}
		$GOT{$page} = \%data;
		next;
	    }
	    next if $GOT{$page};

	    warn "INFO: Processing '$page' (from web)\n";
	    my $data = get("http://www.h2g2.com/$page?skin=Classic");
	    unless ($data) {
		warn "WARN: Failed retrieving $page: $!\n";
		next;
	    }
	    warn "INFO: Retrieved data...\n";

	    # -- Generate article data ---------------------
	    #
	    my %article = (number => undef,
			   text   => '',
			   title  => '' );

	    if ($page =~ /^A/) {
		# -- We've got an article --------
		my $url  = "http://www.h2g2.com/test".substr($page, 1);
		my $xml  = get($url);
		unless ($xml) {
		    warn "WARN: Failed retrieving $url: $!\n";
		    next;
		}
		warn "INFO: Retrieved XML from $url...\n";

		&parseArticleData(\%article, $data);
		&parseArticle(\%article, $xml);
		$article{number} = $page;

	    } elsif ($page =~ /^C/) {
		# -- We've got a category --------
		&parseCategory(\%article, $data);
		$article{number} = $page;
	    }
	    if ($article{text} eq '') {
		warn "WARN: Article body blank, skipping.\n";
		next;
	    }

	    $article{text} =~ s/<a href="(\w\d+)">/<a href="$1.h2g2">/g;
	    $GOT{$article{number}} = \%article;

	    if (($recurse) && ($article{number} =~ /^C/)) {
		while($article{text} =~ m!<a href="([AC]\d+)\.h2g2">!g) {
		    warn "INFO: Adding '$1' from '$page' to scan list\n";
		    push @ARGV, ($1);
		}
	    }

	    &savePage(\%article, 0, $opMode) unless $onePage;
	}
    }

    &tidy(\%GOT);
    warn "INFO: Outputting as '$opMode'\n";

    my @list = sort { lc($a->{title}) cmp lc($b->{title}) } values(%GOT);
    foreach my $a (@list) {
	&savePage($a, $onePage, $opMode);
    }

    return;
}


# -- Save a page ---------------------------------------------------------
#
sub savePage {
    my ($a, $onePage, $opMode) = @_;

    return if $a->{saved};
    if ($a->{dontsave}) {
	warn "INFO: Skipping '$a->{number}'\n";
	return;
    }

    if ($a->{title} !~ /\w/) {
        warn "INFO: Skipping blank titled $a->{number}\n";
        return;
    }

    warn "INFO: O/p '$a->{title}' ($a->{number})\n";
    my $opFunction = '&output_'.$opMode.'($a)';
    my $op         = '';
    eval("\$op = $opFunction");
    warn "Unable to execute $opFunction: $@" if $@;
    if ($onePage) {
	print $op;
    } else {
	unless (open(OUT, ">$a->{number}.h2g2")) {
	    warn "Unable to open '$a->{number}.h2g2' for writing: $!\n";
	    next;
	}
	print OUT $op;
	close(OUT) or warn "Unable to close '$a->{number}.h2g2': $!\n";
    }

    delete($a->{text}); # Free up memory
    $a->{saved} = 1;
    return;
}


# -- Parse data we can't get from XML ------------------------------------
#
sub parseArticleData {
    my ($h) = shift;
    ($_)    = @_;

    study;
    s/\s+/ /mg;
    # -- Get researcher details
    #
    my ($researchers) = m!<td.*?>Researchers:(.*?)</b></font>!si;
    $h->{research}    = [];

    if (defined($researchers) && ($researchers =~ m/href/i)) {
	while ($researchers =~ m!<a [^>]*?href="[^>]*?(\w\d+)">(.*?)</a>!ig) {
	    my %r;
	    $r{name}    = $2;
	    $r{number}  = $1;
	    push @{ $h->{research} }, \%r;
	}
    }

    # -- Get editor details and date
    #
    my ($editor) = m!<font [^>]+>Editors?:(.*?)</td>!si;
    $h->{editor} = ();

    if (defined($editor) && ($editor =~ m/href/i)) {
	my %e;
	$editor =~ m!<a href="[^>]*?(\w\d+)">([^<]+?)</a>!i;
	$e{name}     = $2;
	$e{number}   = $1;
	$h->{editor} = \%e;
    }
    ($h->{date})   = m!<td.*?>Date:.*?>(\d+&nbsp;\w+&nbsp;\d+)<!si;
    $h->{date} = '' unless $h->{date};
    $h->{date} =~ s/&nbsp;/ /g;

    return;
}


# -- Parse an article into a hash table ----------------------------------
#
sub parseArticle {
    my ($h) = shift;
    ($_)    = @_;
    my %p   = %$h;

    # -- Get article title and number
    #
    study;
    s/\s+/ /mg;
    s!^.*&lt;ARTICLE&gt;!<ARTICLE>!i;
    s!&lt;/ARTICLE&gt;.*$!</ARTICLE>!i;
    decode_entities($_);

    my ($a) = m!<SUBJECT>([^>]+)</SUBJECT>!i;
    unless ($a) {
	warn "WARN: No subject, skipping.\n";
	return;
    }

    # -- Tidy title and just keep body
    #
    $h->{title} = &niceTitle($a);
    s!^.*?<BODY>(.*)</BODY>.*?$!$1!i;

    # -- Ensure all HREFs are local (and external ones are marked)
    #
    s!<link href="([^\"]+)">!<a external href="$1">!ig;
    s!<link h2g2="(\w\d+)">!<a href="$1">!ig;
    s!<link [^>]+>!<a>!ig;
    s!</link>!</a>!ig;

    # -- Pull out the footnotes
    #
    my @footnotes   = m!<FOOTNOTE>(.*?)</FOOTNOTE>!gi;
    for(my $f = 1; $f <= scalar(@footnotes); $f++) {
	my $fn = $footnotes[$f-1];
	s!<FOOTNOTE>\Q$fn</FOOTNOTE>!<a href="#footnotes"><sup>$f</sup></a>!i;
    }
    $h->{footnotes} = \@footnotes;

    # -- Tidy it up a little
    #
    s!(<[^ >]+)([^>]*>)!lc($1).$2!eg;   # Lower case tags (not attributes)
    s!</?(img|picture) ?[^>]*?>!!gi;       # No point having images
    s!\x92!\'!g;                        # Fix dodgy quotes
    s!(<LI>) <P>(.*?)</P>!\n$1$2!gi;    # Tighter lists
    s!(</?font ?[^>]*?>|</?div>)!!gi;   # Don't want FONT or DIV tags
    s!(</P>)!$1\n!gi;                   # Space out paragraphs
    s!(<br[^>]*?>)!$1\n!gi;             # Space out breaks
    s!(<P>) !$1!gi;                     # No spaces after P
    s! (</P>)!$1!gi;                    # No spaces before /P
    s!^ *(.+) *$!$1!mg;                 # Trim leading/trailing spaces
    s!(<p>){2,}!<br>!ig;                # Remove duplicate P tags
    #s'(<p>.*?)(<p>|<.l>)'($1 =~ m!</p>!) ? $1.$2 : "$1</p>$2"'ige;

    $h->{text} = $_;
    return;
}


# -- Parse a category page, format it into a std article and return ----
#
sub parseCategory {
    my ($h) = shift;     # Our entry
    my $b = '';          # Build up the body here
    ($_)  = @_;          # Read in parameters

    # -- Find title and introduction
    #
    study;
    s/\s+/ /mg;
    ($h->{title})   = m!<font [^>]*size="5"[^>]*><b>(.*?)</b></font><br>!i;
    ($b)            = m!<description>(.*?)</description>!i;
    $h->{research}  = [];
    $h->{editor}    = ();
    $h->{date}      = POSIX::strftime("%d %b %Y", gmtime);

    unless ($h->{title}) {
	warn "WARN: No subject, skipping.\n";
	return;
    }
    $h->{title} = &niceTitle($h->{title});

    $b = ($b ? "<p>$b</p>\n" : '');
    m!(<a href="/C0">Top</a>.*?)<HR>!si;
    #$b = "<h2>$1</h2>\n$b";

    # -- Find all category links and add to page
    #
    if (m!<a href=["']?/?C\d+['"]>!i) {
	$b .= "<ul>\n";
	while(m!<a href=["']?/?(\w+)['"]><b><font [^>]+>([^<]+)</font></b></a>\s*<font [^>]+><nobr>\s*\[\s*(\d+)\s*!gi) {
	    $b .= "<li><b><a href=\"$1\">$2</a></b> ($3)</li>\n";
	}
	$b .= "</ul>\n\n";
    }

    # -- Now add the article links
    #
    if (m!<a href=["']?/?A\d+['"]><font!i) {
	$b .= "<ul>";
	while(m!<a href=["']?/?(\w+)['"]><font [^>]+>([^<]+)</font>!gi) {
	    $b .= "<li><a href=\"$1\">$2</a></li>\n";
	}
	$b .= "</ul>\n";
    }

    # -- Ensure all HREFs are local (and external ones are marked)
    #
    $b =~ s!<a [^>]*href=[^>]*?(\w\d+)[^>]>!<a href="$1">!ig;
    $b =~ s!<a [^>]*href="(http|ftp|gopher)(://[^\"]+)"!<a external href="$1$2"!ig;

    $h->{text} = $b;
    return;
}   


# -- Niceify titles ----------------------------------------------------
#
sub niceTitle {
    my ($title) = @_;

    $title =~ s/^The (.*)$/$1, The/ig;
    $title =~ s/^A (\w+) (of|and|to) (.*)/$3, A $1 $2/ig;
    $title =~ s/^A (\w+) (\w+) (of|and|to) (.*)/$4, A $1 $2 $3/ig;
    return $title;
}


# -- Read back in the XML dumped by output_XML -------------------------
#
sub readXML {
    my ($file, $page) = @_;
    my $data          = '';
    my %a             = ();

    unless(open(IN, "<$file")) {
	warn "Unable to open $file for reading: $!\n";
	return ();
    }

    while(<IN>){ $data .= $_; }
    close(IN);
    return () if ($data !~ m!<h2g2\s+article="$page">(.*?)</h2g2>!s);

    $_          = $1; study;
    $a{number}  = $page;
    ($a{title}) = m!<title>(.*)</title>!;
    ($a{date})  = m!<date>(.*)</date>!;
    ($a{text})  = m!<body>(.*)</body>!s;

    $a{title}   = &niceTitle($a{title});

    my ($editor)           = m!<editor>(.*)</editor>!s;
    if (defined($editor)) {
	$a{editor}             = ();
	($a{editor}->{name})   = $editor =~ m!<name>(.*)</name>!;
	($a{editor}->{number}) = $editor =~ m!<number>(.*)</number>!;
    }

    my ($research) = m!<researchers>(.*)</researchers>!s;
    $a{research}   = [];

    while ($research and $research =~ m!<researcher>(.*?)</researcher>!gs) {
	my %r;
	my $rsrch    = $1;
	($r{name})   = $rsrch =~ m!<name>(.*)</name>!;
	($r{number}) = $rsrch =~ m!<number>(.*)</number>!;
	push @{ $a{research} }, \%r;
    }

    my ($footnotes) = m!<footnotes>(.*)</footnotes>!s;
    $a{footnotes}   = [];

    while ($footnotes and $footnotes =~ m!<footnote>(.*?)</footnote>!gs) {
	push @{ $a{footnotes} }, $1;
    }

    return %a;
}


# -- Tidy a hash table, recursively ------------------------------------
#
sub tidy {
    my ($d) = @_;
    my $type = ref($d);

    if ($type eq "HASH") {
	foreach my $i (keys(%{ $d })) {
	    my $ref = ref($d->{$i});
	    if ($ref) {
		&tidy($d->{$i});
	    } else {
		$d->{$i} =~ s/^\s*(.*)\s*$/$1/ if defined($d->{$i});
	    }

	    delete($d->{$i}) unless defined($d->{$i});
	}

    } elsif ($type eq "ARRAY") {
	my @list = @{ $d };
	for(my $i=0; $i < $#list; $i++) {
	    next unless defined($list[$i]);

	    if (ref($list[$i])) {
		&tidy($list[$i]);
	    } else {
		$list[$i] =~ s/^\s*(.*)\s*$/$1/;
	    }
	}
    }
    return;
}


# -- Dump a hash table -------------------------------------------------
#
sub dump {
    my ($indent, $d) = @_;
    my $type = ref($d);

    if ($type eq "HASH") {
	my %tree = %{ $d };
	foreach my $i (keys(%tree)) {
	    #next unless defined($tree{$i});
	    print " " x $indent . "$i\t => $tree{$i}\n";

	    my $ref = ref($tree{$i});
	    next unless $ref;
	    &dump($indent + 4, $tree{$i});
	}

    } elsif ($type eq "ARRAY") {
	my @list = @{ $d };
	foreach my $i (@list) {
	    print " " x $indent . "o $i\n";
	    &dump($indent + 4, $i);
	}
    }

    return;
}


# -- Remove a tag not containing itself ----------------------
#
sub changeLeafTag {
    my ($ref, $start, $end, $replace) = @_;

    my ($initial) = $start =~ m/(<\w+)[ >]/;
    while ($$ref =~ m/$start(.*?)$end/ig) {
	my $text = $1;
	next if $text =~ m/$initial/i;

	$text = $start."(".quotemeta($text).")".$end;
	eval "\$\$ref =~ s!$text!$replace!gi";
    }
    return;
}


# -----------------------------------------------------------------------
# -- Output functions ---------------------------------------------------
# -----------------------------------------------------------------------

# -- Nice, generic XML output --------------------------------
#
sub output_XML {
    my ($ref) = @_;
    my %a     = %{ $ref };
    my $date  = scalar(localtime());

    my $op    = <<EOH;
<?xml version="1.0"/>
<h2g2 article="$a{number}">
<!-- Converted using hhgg2xml, $date -->
<title>$a{title}</title>
<date>$a{date}</date>
EOH

    if (defined($a{editor})) {
	$op .= <<EOH;
<editor>
    <number>$a{editor}->{number}</number>
    <name>$a{editor}->{name}</name>
</editor>
EOH
    }

    if (defined($a{research}) && scalar(@{ $a{research} })) {
	$op .= "<researchers>\n";
	foreach my $i (@{ $a{research} }) {
	    $op .= "    <researcher>\n".
		"        <number>$i->{number}</number>\n".
		    "        <name>$i->{name}</name>\n".
			"    </researcher>\n";
	}
	$op .= "</researchers>\n";
    }

    if (defined($a{footnotes}) && scalar(@{ $a{footnotes} })) {
	$op .= "<footnotes>\n";
	foreach my $i (@{ $a{footnotes} }) {
	    $op .= "    <footnote>$i</footnote>\n";
	}
	$op .= "</footnotes>\n";
    }

    $op .= "\n<body>\n$a{text}\n</body>\n</h2g2>\n";
    return $op;
}


# -- HTML output, eg. for a CGI script -----------------------
#
sub output_HTML {
    my ($ref) = @_;
    my %a     = %{ $ref };

    my $date  = scalar(localtime());
    my $op    = <<EOH;
<html>
<head>
<!-- Converted using hhgg2xml, $date -->
<title>$a{number} : $a{title}</title>
</head>

<body>
<h1>$a{title}</h1>
<p><b>$a{number}, $a{date}</b></p>
EOH

    if (defined($a{editor})) {
	$op .= "<p><b>Editor:</b> $a{editor}->{name} ".
	    "($a{editor}->{number})<br>\n";
    }

    if (defined($a{research}) && scalar(@{ $a{research} })) {
	$op .= "<b>Researchers:</b>";
	my @researcher = @{ $a{research} };
	if (scalar(@researcher) > 1) {
	    $op .= "</p><ul>\n";
	    foreach my $i (@researcher) {
		$op .= "<li>$i->{name} ($i->{number})\n";
	    }
	    $op .= "</ul>\n";
	} elsif (scalar(@researcher) == 1) {
	    my $i = $researcher[0];
	    $op .= "$i->{name} ($i->{number})</p>\n";
	}
    }

    my $body = $a{text};
    $body     =~ s!<header>(.*?)</header>!<h2>$1</h2>!g;
    $body     =~ s!<subheader>(.*?)</subheader>!<h3>$1</h3>!g;
    $op .= "\n$body\n";

    if (defined($a{footnotes}) && scalar(@{ $a{footnotes} })) {
	$op .= "<hr size=1 noshade>\n<a name=\"footnotes\"><ol>";
	foreach my $f (@{ $a{footnotes} }) {
	    $op .= "<li>$f";
	}
	$op .= "</ol></a>\n";
    }

    $op .= "</body>\n</html>\n";
    return $op;
}
    

# -- Just dump the internal structures -----------------------
#
sub output_DUMP {
    my ($ref) = @_;

    &dump(0, $ref);
    return "";
}


# -- TRML suitable for the desktop viewer (includes HTML bits)
#
sub output_TRML_WIN32 {
    return &base_TRML(@_);
}


# -- TRML simplified for the basic viewers -------------------
#
sub output_TRML_PALM {
    $_ = &base_TRML(@_);
    study;

    s!<h2>(.*?)</h2>!<p><b><u>$1</u></b><br>!g;
    s!<h3>(.*?)</h3>!<br><i>$1</i><br>!g;
    s!<(\w+)([^>]*)/>!<$1$2></$1>!g;   # Don't handle XHTML tags
    s/&(lt|gt);/&amp;$1;/g;   # Don't decode &lt; etc.
    decode_entities($_);

    # -- Tidy up anchors...
    s!<a [^>]*></a>!!gi;
    &changeLeafTag(\$_, '<a [^>]*external[^>]*href=[^>]*>','</a>','<<$1>>');
    &changeLeafTag(\$_, '<a [^>]*href="#[^>]*?"[^>]*>', '</a>', '$1');
    &changeLeafTag(\$_, '<a [^>]*name=[^>]*>', '</a>', '$1');

    # -- Misc tags...
    s!<br/? [^>]*>(</br>)?!<br>!g;
    s!<hr/?[^>]*>(</hr>)?!<hr>!g;
    s!<nobr>(.*?)</nobr>!$1!g;
    s!<h2>(.*?)</h2>!<p><b><u>$1</u></b><br>!g;
    s!<cite>(.*?)</cite>!<i>$1</i>!g;      # These shouldn't appear in
    s!<em>(.*?)</em>!<i>$1</i>!g;          # approved guide entries, but
    s!<strong>(.*?)</strong>!<b>$1</b>!g;  # they do :-/
    s!<blockquote>(.*?)</blockquote>!$1!g;
    s!<p +align="center">!<p><center>!gi;
    s!<p +align=[^>]+>!<p>!gi;
    s!<li><p>!<li>!g;
    s!</p>!<br>!g;
    s!</li>!!g;

    # -- Tables need clearing up...
    s!<td[^>]*></td>!!g;
    s!<td[^>]*>(.*?)</td>!$1 <b>|</b>!g;

    s!<tr[^>]*></tr>!!g;
    s!<tr[^>]*>(.*?)</tr>!$1<br>!g;

    s!<table[^>]*></table>!!g;
    s!<table[^>]*>(.*?)</table>!<p>$1!g;

    return $_;
}


# -- Used in both TRML output modes...
#
sub base_TRML {
    my ($ref) = @_;
    my %a     = %{ $ref };

    my $head = "$a{title}\t<b>$a{number}, $a{date}<br>";
    if (defined($a{editor})) {
	$head .= "Editor:</b> $a{editor}->{name}<br>";
    } else {
	$head .= "</b>";
    }

    my $op =  $a{text};
    warn "WARN: Uncaught tabs (corrected)\n"     if $op =~ s/\t/ /g;
    warn "WARN: Uncaught newlines (corrected)\n" if $op =~ s/[\n\r]/ /g;
    $op  =~ s!<a [^>]*href="/?(\w\d+)\.h2g2"[^>]*> *!$GOT{$1}?"<a:$GOT{$1}->{title}>":"<a>"!egi;

    $op  =~ s!<header>(.*?)</header>!<h2>$1</h2>!g;
    $op  =~ s!<subheader>(.*?)</subheader>!<h3>$1</h3>!g;

    if (defined($a{footnotes}) && scalar(@{ $a{footnotes} })) {
	$op .= "\n<hr><ol>\n";
	foreach my $f (@{ $a{footnotes} }) {
	    $op .= "<li>$f\n";
	}
	$op .= "</ol>";
    }
    return $head.$op."\r\n";
}


# -- Plain and simple text o/p -------------------------------
#
sub output_TEXT {
    return simple_text(1, @_);
}


# -- TomeRaider (use text w/o wrapping -----------------------
#
sub output_TOMERAIDER {
    my $op = simple_text(0, @_);
    warn "WARN: Uncaught tabs (corrected)\n" if $op =~ s/\t/ /g;
    $op    =~ s/^(.*)\n/$1\t/;
    $op    =~ s/\@/\(at\)/g;
    $op    =~ s/\n/\@/g;
    return $op."\r\n";
}

# -- Used in both output_TEXT and output_TOMERAIDER...
#
sub simple_text {
    my ($wrap, $ref) = @_;
    my %a            = %{ $ref };
    my $op           = '';

    use Text::Wrap;
    $Text::Wrap::columns = $wrap ? 80 : $TOMERAIDER_LI_WRAP;
	
    $op = "$a{title}\n".
	  "$a{number}, $a{date}\n";
    $op .= "Editor: $a{editor}->{name}\n\n" if defined($a{editor});
          
    my $block = $a{text};

    # -- Tidy up lone tags
    #
    while ($block =~ m!<(hr|br|img)([^>]*)>!is) {
	my $tag = $1;
	my $att = $2;
	my $rpl = '';

	if ($tag eq "hr") {
	    $rpl = "---------------------\0";
	} elsif ($tag eq "br") {
	    $rpl = "\0";
	}

	$block =~ s!<$tag[^>]*>!$rpl!igs;
    }

    # -- Tidy up block tags
    #
    while ($block =~ m!<([^> ]+)([^>]*)>([^>]*?)</\1>!is) {
	my $tag = $1;
        my $att = $2; 
        my $txt = $3; $txt =~ s/^\s*(.*)\s*$/$1/g;
	my $rpl = '';

        if ($tag eq "p") {
	    if ($wrap) {
		$rpl = "\n".wrap("", "", $txt)."\n";
	    } else {
		$rpl = "\n$txt\n";
	    }

	} elsif ($tag =~ /[ou]l/) {
	    $rpl = "\0$txt\n";

	} elsif ($tag eq "li") {
	    my $tmp = $txt; $tmp =~ s/\n/ /g;
	    $rpl = "\0".wrap("  * ",
			     "    ", $tmp);
	
	} elsif ($tag eq "i") {
	    $rpl = "/$txt/";

	} elsif ($tag eq "b") {
	    $rpl = "*$txt*";

	} elsif ($tag eq "a") {
	    if (($att =~ m/href/i) && ($txt ne "")) {
		if ($txt =~ m/^\[\d+\]$/) {
		    $rpl = $txt." ";
		} else {
		    $rpl = "\"$txt\"";
		}
	    } else {
		$rpl = $txt;
	    }

	} elsif ($tag eq "sup") {
	    $rpl = "[$txt]";

	} elsif ($tag eq "header") {
	    $rpl = "\n\n$txt\n"."-" x length($txt)."\0";

	} elsif ($tag eq "subheader") {
	    $rpl = "\n* $txt *\0";

	} elsif ($tag eq "blockquote") {
	    my $tmp = $txt; $tmp =~ s/(\S+)\n/$1 /g;
	    $tmp =~ s/\0+/\0/g;
	    $tmp =~ s/\n\0/\n/g;
	    $tmp =~ s/\0\n/\n/g;
	    $tmp =~ s/\0/\n/sg;
	    
	    $Text::Wrap::columns -= 5;
	    $rpl = "\0".wrap("      ", "      ", $tmp)."\n";
	    $Text::Wrap::columns += 5;
	    $rpl =~ s/([^\n])\n([^\n])/$1\0$2/g;

	} else {
	    $rpl = $txt;
	}

	$txt   =  quotemeta($txt);
	$block =~ s!<$tag[^>]*>\s*$txt\s*</$tag>!$rpl!igs;
    }

    $block =~ s/\0\s*\0/\0/g;
    $block =~ s/\0+/\0/g;        # Fix <BR> temporary tags
    $block =~ s/\n\s*\0/\n/g;
    $block =~ s/\0\s*\n/\n/g;
    $block =~ s/\0/\n/sg;

    decode_entities($block);
    $block =~ s/([^\n])\n\n([^\n])/$1\n$2/g;
    $block =~ s/([^\n])\n{3,}/$1\n\n/g;

    if (defined($a{footnotes}) && scalar(@{ $a{footnotes} })) {
	my @fn  = @{ $a{footnotes} };
	$block .= "\n---------------------------------\n";
	for(my $f = 0; $f < scalar(@fn); $f++) {
	    $fn[$f] =~ s/^\s*(.*)\s*$/$1/;
   	    $fn[$f] =~ s!<([^>]+)>(.*?)</\1>!$2!g;
	    $block .= wrap("[".($f+1)."] ",
			   " " x (length($f+1) + 3),
			   $fn[$f]."\n");
	}
    }
    return $op.$block;
}

