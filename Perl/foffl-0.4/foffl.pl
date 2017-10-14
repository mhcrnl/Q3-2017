#! /usr/bin/perl -w

# Copyright (C) 2009-2010 Yitzhak Grossman (celejar@gmail.com)
# Foffl is free software, released under the terms of the Perl Artistic
# License, contained in the included file 'License'
# Foffl comes with ABSOLUTELY NO WARRANTY
# The Foffl homepage is http://foffl.sourceforge.net
# Foffl is fully documented in its README

use strict;

use LWP::UserAgent;
use LWP::ConnCache;

use XML::Parser;
use XML::RSS;
use XML::Atom::Feed;

use HTML::Parser;
use HTML::Tiny;

use Log::Dispatch;
use Log::Dispatch::File;
use Log::Dispatch::Screen;

use File::Type;

use DBI;

use ConfigReader::Simple;

use POSIX qw /strftime/;
use File::Spec;
use File::Temp qw /tempdir/;
use File::Basename;
use File::Path qw /remove_tree/;
use Encode;
use Getopt::Std;
use URI;
#use Data::Dump;

# process command line options

my %opts = (d => File::Spec->catfile($ENV{'HOME'}, 'foffl'));
getopts('c:d:f:l:p:i:DxN', \%opts);
my $default_conf_file = File::Spec->catfile($opts{'d'}, 'foffl.conf');

# process config file

my $conf_file = $opts{'c'} // (-f $default_conf_file ? $default_conf_file : undef);
if (defined $conf_file) {
	my $config = ConfigReader::Simple->new($conf_file);
	my %opts_map = (directory => 'd', feed_list => 'f', log_level => 'l', items => 'i', proxy => 'p', debug => 'D', no_download => 'x');
	$opts{$opts_map{$_}} = $config->get($_) foreach $config->directives;
}

# set defaults for (some) undefined options

my %defaults =	('f' => File::Spec->catfile($ENV{'HOME'}, 'foffl', 'feed_list'), 'l' => 'notice', 'i' => 0);
$opts{$_} = $opts{$_} // $defaults{$_} foreach keys %defaults;

# set some filenames and directories

my $feeds_dir = File::Spec->catfile($opts{'d'}, 'feeds');
mkdir $feeds_dir unless -d $feeds_dir;
my $logfile = File::Spec->catfile($opts{'d'}, 'wget-log');

# set up some variables

my %feedtypes = ('feed' => 'Atom', 'rss' => 'RSS', 'rdf:RDF' => 'RSS', 'rdf' => 'RSS', 'atom' => 'Atom');
my ($prog_name, $prog_version, $feed, $feedtype, $page_title, $in_title, $xml_enc, $base, $url, $res, $fh, $columns,
	@stack, %page_stack, @feed_list, %feed) = ('foffl', 'rc-0.4');
my $h = HTML::Tiny->new;
$XML::Atom::ForceUnicode = 1;

# initialize our database and prepare some SQL statements

my $db_name = File::Spec->catfile($opts{'d'}, 'foffl.sqlite');
my $db_exists = -f $db_name;
my $dbh = DBI->connect("dbi:SQLite:dbname=$db_name", "", "", {AutoCommit => 0});
unless ($db_exists) {
	$dbh->do('CREATE TABLE feed_items(url, filename, subdirectory, fresh)');
	$dbh->do('CREATE TABLE feed_dirs(filename, directory, fresh)');
	$dbh->do('CREATE TABLE output_pages(filename)');
	$dbh->commit;
}
my %sqls = ('insert_feed_item'		=> $dbh->prepare("INSERT INTO feed_items(url, filename, subdirectory, fresh) VALUES (?,?,?,1)"),
			'insert_output_page'	=> $dbh->prepare("INSERT INTO output_pages(filename) VALUES (?)"),
			'find_feed_item'		=> $dbh->prepare("SELECT filename FROM feed_items WHERE url=?"),
			'create_feed_dir'		=> $dbh->prepare("INSERT INTO feed_dirs(filename, directory, fresh) VALUES (?,?,1)"),
			'find_feed_dir'			=> $dbh->prepare("SELECT directory FROM feed_dirs WHERE filename=?"),
			'set_item_fresh'		=> $dbh->prepare("UPDATE feed_items SET fresh=1 WHERE url=?"),
			'set_feed_dir_fresh'	=> $dbh->prepare("UPDATE feed_dirs SET fresh=1 WHERE filename=?"));

$dbh->do("UPDATE feed_items SET fresh=0");
$dbh->do("UPDATE feed_dirs SET fresh=0");

# nuke the database, if requested

if ($opts{'N'}) {
	$dbh->do("DELETE FROM feed_items");
	$dbh->do("DELETE FROM feed_dirs");
	remove_tree($feeds_dir, {keep_root => 1});
}

# wipe any old output pages

foreach (@{$dbh->selectall_arrayref("SELECT filename FROM feed_dirs")}) {unlink ${$_}[0]}
$dbh->do("DELETE FROM output_pages");

# initialize the logger

my $dispatcher = new Log::Dispatch;
$dispatcher->add(Log::Dispatch::Screen->new(name => 'screen', min_level => $opts{'D'} ? 'debug' : 'error'));
$dispatcher->add(Log::Dispatch::File->new(name => 'logfile', min_level => $opts{'l'}, filename => File::Spec->catfile($opts{'d'}, 'foffl.log')));

# initialize the user agent

my $ua = new LWP::UserAgent(conn_cache => new LWP::ConnCache);
$ua->proxy('http', $opts{'p'}) if $opts{'p'};
$ua->default_header('Accept-Encoding' => scalar HTTP::Message::decodable());

# initialize some parsers

my $auto_discover_parser = HTML::Parser->new(
	start_h => [\&auto_discover_html_start_handler, 'tagname, attr'],
	text_h => [sub {$page_title = $_[0] if $in_title}, "dtext"],
	end_h => [sub {undef $in_title if ($_[0] eq 'title')}, "tagname"]
);

my $xml_parser = new XML::Parser;
$xml_parser->setHandlers('Start' => \&xml_start_handler, 'XMLDecl' => sub {$xml_enc = Encode::find_encoding($_[2])});

# begin processing

&log('notice', "$prog_name version $prog_version started.\n");
open (my $fl, $opts{'f'}) or die "Can't open feed list ('$opts{'f'})";

# iterate through each line in the feed list

while (<$fl>) {
	next if /^\s*(#|$)/; # ignore blank lines and lines whose first non-whitespace character is a '#' (comments);
	chomp;
	&log('notice', "Retrieving $_\t");
	$url = URI->new($_);
	$res = $ua->get(URI->new("http://" . ($url->authority ? $url->authority : "") . ($url->path_query ? $url->path_query : "")));
	unless ($res->is_success) {
		$dispatcher->log(level => 'notice', message => "[Failed!]\n");
		&log('debug', "HTTP status line:\t", $res->status_line, "\n");
		next;
	}
	&bzip_fix($res);
	
	$dispatcher->log(level => 'notice', message => "[Retrieved]\n");
	undef $feedtype; # reset feedtype
		
	# the second clause in the following statement is a workaround for broken
	# (Wordpress) installations that sometimes send 'text/html' response
	# headers for their XML feeds:
	# http://core.trac.wordpress.org/ticket/11060
	# http://www.mail-archive.com/squid-users@squid-cache.org/msg68179.html
	# An XMLDecl is not strictly required,
	# but it 'should' exist, and all feeds that I've seen have them
	# http://www.w3.org/TR/REC-xml/#NT-prolog
	
	if ($res->content_type eq 'text/html' && $res->decoded_content !~ /^<\?xml/s) {
		&log('notice', "Received HTML - doing autodiscovery\n");
		next unless defined ($res = auto_discover($res));
		$feedtype = $feed{'type'};
	}
	$feed = $res->decoded_content;

	# parse feed to guess feed type
	
	unless (defined $feedtype) {
		undef $xml_enc;
		&log('debug', "Parsing ...\n");
		$xml_parser->parse($feed);
		&log('debug', "Parsing complete\n");
		unless (defined $feedtype) {&log('error', "Unrecognized feed type\n"); next}
	}

	my (@feed_entries, $feed_title);

	# process RSS feed

	if ($feedtype eq 'RSS') {
		&log('debug', "Parsing RSS feed\n");
		my $rss = new XML::RSS;
		$rss->parse($feed);
		&log('debug', "Parsing complete\n");
		$feed_title = $rss->channel('title');
		#$feed_title = decoded_xml($rss->channel('title'));
		my $n;
		foreach (@{$rss->{'items'}}) {
			push @feed_entries, {title => $_->{'title'}, url => URI->new($_->{'link'}), content => $_->{'description'}};
			last if ++$n == $opts{'i'}
		}
	} # end RSS code

	# process Atom feed
	# Atom spec: http://www.ietf.org/rfc/rfc4287.txt
	
	elsif ($feedtype eq 'Atom') {
		&log('debug', "Parsing Atom feed\n");
		my $atom = new XML::Atom::Feed(\$feed);
		&log('debug', "Parsing complete\n");
		$feed_title = $atom->title;
		my @entries = $atom->entries;
		my ($n, $title, $content);
		foreach (@entries) {
			push @feed_entries, {title => $_->title};
			
			# Atom feed entries may have a non-empty 'content' (which may not be text),
			# or a 'summary', or neither (4.1.2 - 4.1.3)
			
			if (defined $_->content && $_->content->type =~ /^text\//)
				{$feed_entries[-1]{'content'} = $_->content->body; $feed_entries[-1]{'content_type'} = $_->content->type}
			elsif (defined $_->summary) {$feed_entries[-1]{'content'} = $_->summary}
			foreach ($_->link) {

				# Atom feed entries can apparently have either exactly
				# one 'link' tag, possibly without a 'rel' attribute, or
				# several, in which case the one with "rel='alternate'"
				# contains the permalink (4.2.7.2)
				
				if (!defined $_->rel || $_->rel eq 'alternate')	{$feed_entries[-1]{'url'} = URI->new($_->href); last}
			}
			last if ++$n == $opts{'i'};
		}
	} # end Atom code

	# create a subdirectory off the main feeds directory for this feed's entries, or reuse an existing one

	my $filename = $res->filename ? $res->filename : $url->authority . '.html';
	&log('debug', "Checking whether we already have a directory for $filename ... ");
	$sqls{'find_feed_dir'}->execute($filename);
	$columns = $sqls{'find_feed_dir'}->fetchrow_arrayref;
	my $feed_subdirectory;
	if ($columns) {
		$feed_subdirectory = ${$columns}[0];
		$sqls{'set_feed_dir_fresh'}->execute($filename);
		$dispatcher->log(level => 'debug', message => "yes - reusing $feed_subdirectory\n");
	}
	else {
		$dispatcher->log(level => 'debug', message => "no\n");
		$feed_subdirectory = tempdir("${filename}XXXX", DIR => $feeds_dir, UNLINK => 0);
		$sqls{'create_feed_dir'}->execute($filename, $feed_subdirectory);
		&log('debug', "Created subdirectory:\t$feed_subdirectory\n");
	}
	
	# save feed content for each feed entry
	
	foreach (@feed_entries) {
		
		# check if this item is in the database, and if so, reuse it and iterate the loop
		
		&log('debug', "Looking up $_->{'url'} in database ... ");
		$sqls{'find_feed_item'}->execute($_->{'url'});
		$columns = $sqls{'find_feed_item'}->fetchrow_arrayref;
		if ($columns) {
			$dispatcher->log(level => 'debug', message => "[Found]\n");
			&log('debug', "Filename:\t${$columns}[0]\n");
			#dd($columns);
			${$_}{'filename'} = ${$columns}[0];
			$sqls{'set_item_fresh'}->execute($_->{'url'});
			next;
		}
		$dispatcher->log(level => 'debug', message => "[Not found]\n");
		unless ($opts{'x'}) {
			(${$_}{'filename'}, ${$_}{'subdirectory'}) = save_page($_->{'url'}, $feed_subdirectory, 1);
			if (${$_}{'filename'}) {
				&log('notice', "Saved $_->{'url'} to ${$_}{'filename'}\n");
				$sqls{'insert_feed_item'}->execute($_->{'url'}, ${$_}{'filename'}, ${$_}{'subdirectory'});
			}
		}
		unless (${$_}{'filename'} || (defined ${$_}{'content_type'} && ${$_}{'content_type'} !~ /^text\//)) {
			$fh = new File::Temp(TEMPLATE => "${filename}XXXX", DIR => $feed_subdirectory, UNLINK => 0);
			print $fh Encode::encode('utf8', $h->html([
				"\n\n", $h->head([
					"\n\n", $h->title("$prog_name v$prog_version - ${$_}{'title'}"), "\n",
					$h->meta({'http-equiv' => "Content-Type", content => (${$_}{'content_type'} // 'text/html; charset=utf-8')}), "\n\n"
				]), "\n",
				$h->body([
					"\n\n", $h->h1($h->a({href => "${$_}{'url'}"}, ${$_}{'title'})), "\n\n",
					$h->div(["\n\n", ${$_}{'content'}, "\n\n"]), "\n"
				]), "\n"
		    ]));
			close $fh;
			${$_}{'filename'} = $fh->filename;
			$sqls{'insert_output_page'}->execute($fh->filename);
		}
	}

	# create an HTML page for this feed's entries
	
	$fh = new File::Temp(TEMPLATE => 'indexXXXX', DIR => $feed_subdirectory, UNLINK => 0, SUFFIX => '.html');
	
	print $fh Encode::encode('utf8', $h->html([
		"\n\n", $h->head([
			"\n\n", $h->title("$prog_name version $prog_version - $feed_title"), "\n",
			$h->meta({'http-equiv' => "Content-Type", content => "text/html; charset=utf-8"}), "\n\n"
		]), "\n",
		$h->body([
			"\n\n", $h->h1($feed_title), "\n\n",
			$h->ul(["\n\n",
				(map {$h->li($h->a({href => ${$_}{'filename'} // ${$_}{'url'}},
				 ${$_}{'title'} // 'Untitled')), "\n"} @feed_entries),
			"\n"]), "\n\n"
		]), "\n"
    ]));
    
    &log('debug', "Saved entries of '$feed_title' to '" . $fh->filename . "'\n");
    close $fh;
    push @feed_list, {title => $feed_title, href => $fh->filename};
    $sqls{'insert_output_page'}->execute($fh->filename);
} # end feed entries loop

close $fl;

# create an HTML page for the feed list

my $filename = File::Spec->catfile($feeds_dir, 'index.html');
unless (open ($fl, ">$filename")) {
	&log('error', "Failed to open '$filename'\n");
	exit 1;
}
print $fl Encode::encode('utf8', $h->html([
	"\n\n", $h->head([
		"\n\n", $h->title("$prog_name version $prog_version - Feeds List"), "\n",
		$h->meta({'http-equiv' => "Content-Type", content => "text/html; charset=utf-8"}), "\n\n"
	]), "\n",
	$h->body([
		"\n\n", $h->h1("$prog_name version $prog_version - Feeds List"), "\n\n",
		$h->ul(["\n\n", (map {$h->li($h->a({href => ${$_}{'href'}}, ${$_}{'title'})), "\n"} @feed_list), "\n"]), "\n\n"
	]), "\n"
]));

&log('debug', "Saved feed list to '$filename'\n");
$sqls{'insert_output_page'}->execute($filename);

# wipe unfresh feed directories

foreach (@{$dbh->selectall_arrayref("SELECT directory FROM feed_dirs WHERE fresh=0")}) {
	if (defined ${$_}[0]) {
		&log('debug', "Unfresh directory:\t${$_}[0] - ");
		if (-d ${$_}[0]) {
			$dispatcher->log(level => 'debug', message => "removing\n");
			remove_tree(${$_}[0]);
		}
		else {$dispatcher->log(level => 'debug', message => "nonexistent on disk!\n")}
	}
}
$dbh->do("DELETE FROM feed_dirs WHERE fresh=0");

# wipe unfresh individual feed items

foreach (@{$dbh->selectall_arrayref("SELECT filename,subdirectory FROM feed_items WHERE fresh=0")}) {
	if (defined ${$_}[0]) {
		&log('debug', "Unfresh feed item:\t${$_}[0] - ");
		if (-f ${$_}[0]) {
			$dispatcher->log(level => 'debug', message => "removing\n");
			unlink ${$_}[0];
		}
		else {$dispatcher->log(level => 'debug', message => "nonexistent on disk\n")}
	}
	if (defined ${$_}[1]) {
		&log('debug', "Unfresh feed item subdirectory:\t${$_}[1] - ");
		if (-d ${$_}[1]) {
			$dispatcher->log(level => 'debug', message => "removing\n");
			remove_tree(${$_}[1]);
		}	
		else {$dispatcher->log(level => 'debug', message => "nonexistent on disk\n")}
	}
}
$dbh->do("DELETE FROM feed_items WHERE fresh=0");

# commit and close database

$dbh->commit;
$sqls{'find_feed_item'}->finish;
$sqls{'find_feed_dir'}->finish;
$dbh->disconnect;

# The End!

# Subroutines:

# XML::Parser handler for guessing whether the feed is RSS or Atom

sub xml_start_handler {
	my ($parser, $element) = @_;

	# we use a very simple heuristic to guess whether the feed is RSS
	# or Atom - if we see an XML 'rss' or 'rdf:RDF' tag, we assume it's RSS,
	# and if we see a 'feed' tag, we assume it's Atom

	if ($feedtypes{$element}) {
		&log('debug', "Found XML tag '$element' - assuming it's $feedtypes{$element}\n");
		$feedtype = $feedtypes{$element};
		}
}

# wrapper for Log::Dispatch to add time / pid prefix to all log entries - first argument is log level, everything else is the message

sub log {$dispatcher->log(level => shift, message => strftime("%b %d %H:%M:%S", localtime) . " [$$] @_")}

# recursively save a webpage, including images, css, scripts, frames - returns the filename

sub save_page {
	my ($url, $directory, $recurse) = @_;
	if (exists $page_stack{$url}) {&log('warning', "$url:\talready visited - aborting to avoid infinite loop.\n"); return undef}
	&log('debug', "Retrieving $url ... ");
	my $res = $ua->get($url);
	unless ($res->is_success) {
		$dispatcher->log(level => 'debug', message => "[Failed!]\n");
		&log('debug', "HTTP status line:\t", $res->status_line, "\n");
		return undef;
	}
	$dispatcher->log(level => 'debug', message => "[Retrieved]\n");
	my $filename = $res->filename ? $res->filename : (($url->path && (fileparse($url->path))[0]) ? (fileparse($url->path))[0] : "unnamed");
	my $fhp = new File::Temp(TEMPLATE => "${filename}XXXX", DIR => $directory, UNLINK => 0);
	
	# we need to decode everything, even non-html/css that we aren't going to
	# process, since it may have come in gzipped, and we want to save it as plaintext
	
	&bzip_fix($res);
	my $content = $res->decoded_content;
	die "Content isn't defined!\n$@" unless defined $content;
	my $subdirectory;
	
	if ($recurse) {
		my $type;
		my $ft = new File::Type;
		my %subs = ('text/html' => \&do_html, 'text/css' => \&do_css);
		if (defined $subs{$res->content_type}) {
		
			# the following craziness is necessary since I've seen a site that 
			# misidentifies its images as 'Content-Type: text/html; charset=ISO-8859-1':
			# http://1.bp.blogspot.com/_e966vsQhLfE/SP1cVU0I-xI/AAAAAAAAANM/AV4GByOyx_Y/S220/08-23-2008+Annes+Parents+049.JPG
		
			$type = $ft->checktype_contents($content);
			#print "filename:\t$filename\ntype by header:\t", $res->content_type, "type by filetype:\t$type\n";
			if (defined $subs{$type} || $type eq 'application/octet-stream') {
				$subdirectory = tempdir("${filename}XXXX", DIR => $directory, UNLINK => 0);
				$page_stack{$url} = 1;
				$content = $subs{$res->content_type}->($content, $res->base, $subdirectory);
				delete $page_stack{$url};
			}
		}
	}
	&log('debug', "Saving $url to $directory\n");
	$content = Encode::encode($res->content_charset, $content) if defined $res->content_charset;
	print $fhp $content;
	close $fhp;
	return wantarray ? ($fhp->filename, $subdirectory) : $fhp->filename;
}

# process html

sub do_html {
	my ($html, $base, $directory) = @_;
	&log('debug', "Processing html: directory is '$directory'\n");
	my (@rewritten_html, @links);
	push @stack, {rhtml => \@rewritten_html, links => \@links, base => $base, directory => $directory};
	my $parser = HTML::Parser->new(
		start_h => [\&rewrite_html_start_handler, 'tagname, attr, tokenpos, text'],
		default_h => [sub {push @{$stack[-1]{'rhtml'}}, @_}, 'text'],
		end_h => [\&rewrite_html_end_handler, 'tagname, text'],
		text_h => [\&rewrite_html_text_handler, 'text']
	);
	$parser->unbroken_text(1);
	$parser->parse($html);
	pop @stack;
	&log('debug', "Html processing complete\n");
	return "@rewritten_html";
}

# look for certain links, download the content and rewrite the html accordingly

sub rewrite_html_start_handler {
	my($tagname, $attr, $pos, $text) = @_;
	my ($link, $new_v, $recurse);
	{
		if ($tagname eq 'img' || (($tagname eq 'input' || $tagname eq 'script') && ${$attr}{'src'})) {$link = ${$attr}{'src'}}
		if ($tagname eq 'link' && defined ${$attr}{'rel'} && ${$attr}{'rel'} eq 'stylesheet') {$link = ${$attr}{'href'}; $recurse = 1}
		if (($tagname eq 'iframe' || $tagname eq 'frame') && ${$attr}{'src'}) {$link = ${$attr}{'src'}; $recurse = 1}
		
		# the 'style' tag is *supposed* to have a 'type' attribute:
		# http://www.w3schools.com/tags/tag_style.asp
		# http://www.w3.org/TR/html4/present/styles.html#edef-STYLE
		# but some don't: http://api.recaptcha.net/noscript?k=6LeVjgYAAAAAAFCRGrsa02lml-4Ct0cGP-sTyjUE
		
		if ($tagname eq 'style' &&  (!defined ${$attr}{'type'} || ${$attr}{'type'} eq "text/css")) {${stack[-1]}{'in_css'} = 1; last}

		# abort if we haven't found a link that we need to download.  The
		# second condition prevents trying to download null links, which
		# leads to recursion: http://brian.pontarelli.com/2006/05/02/is-your-browser-requesting-a-page-twice/

		last unless (defined $link && $link ne "");
		my ($seen, $url);

		# check if we've seen this link (on this page) yet

		foreach (@{$stack[-1]{'links'}}) {if ($link eq ${$_}{'link'}) {$seen = $_; last}}
		if (defined $seen) {$new_v = ${$seen}{'file'}}
		else {
			$url = URI->new_abs($link, $stack[-1]{'base'});
			$new_v = save_page($url, $stack[-1]{'directory'}, $recurse);
		}
		if (defined $new_v) {

			# replace url with a pointer to the locally saved file - code adapted
			# from /usr/share/doc/libhtml-parser-perl/examples/hrefsub

			while (4 <= @$pos) {
				my($k_offset, $k_len, $v_offset, $v_len) = splice(@$pos, -4);
				my $attrname = lc(substr($text, $k_offset, $k_len));
				next unless ((($tagname eq 'img' || $tagname eq 'input' || $tagname eq 'script' || $tagname eq 'frame' || $tagname eq 'iframe') && $attrname eq 'src') ||
							($tagname eq 'link' && $attrname eq 'href'));
				$new_v =~ s/\"/&quot;/g;  # since we quote with ""
				substr($text, $v_offset, $v_len) = qq("$new_v");
				#print "replacing $link with $new_v\n";
			}
			push @{$stack[-1]{'links'}}, {link => $link, file => $new_v} unless defined $seen;
		}
	}
	push @{$stack[-1]{'rhtml'}}, $text;
}

sub rewrite_html_end_handler {
	my ($tagname, $text) = @_;
	if ($tagname eq 'style') {undef ${$stack[-1]}{'in_css'}}
	push @{$stack[-1]{'rhtml'}}, $text;
}

sub rewrite_html_text_handler {
	my ($text) = @_;
	if (defined ${$stack[-1]}{'in_css'}) {$text = do_css($text, ${$stack[-1]}{'base'}, ${$stack[-1]}{'directory'})}
	push @{$stack[-1]{'rhtml'}}, $text;
}

# process css

sub do_css {
	my ($css, $base, $directory) = @_;
	&log('debug', "Processing CSS: directory is '$directory'\n");
	my (@links, $filename, $seen, $url, $pos, $url_pos);

	# strip comments: this regex is adapted from the one in CSS.pm, modified
	# to match against multi-line comments: http://bugs.debian.org/552401
	
	$css =~ s!/\*.*?\*\/!!gs;
	
	# Find '@import' rules and and 'url' properties and try to download
	# and replace the urls appropriately
	# WARNING: This is almost certainly not quite correct, but will hopefully
	# work in most real world cases
	
	while ($css =~	/(?:(?:\@import(\s+url\s*\()?) | (url\s*\()) \s*	# '@import' rule [with optional 'url('] or 'url(' property
						("|')?											# optional quotes
						((?:\\.|[^\3])+?)	# [possibly multi-line] string [regex taken from the Text::Balanced doc]
						(?(3)\3)			# matching quote
						(?(1)\))(?(2)\))	# matching parenthesis
						/gsx) {
		($url, $pos, $url_pos) = ($4, pos $css, $-[4]);
		undef $seen; foreach (@links) {if ($url eq ${$_}{'link'}) {$seen = $_; last}}
		$filename = defined $seen ? ${$seen}{'file'} : save_page(URI->new_abs($url, $base), $directory);
		if (defined $filename) {
			push @links, {'link' => $url, 'file' => $filename};
			#print "replacing '$url' with '$filename'\n";
			substr ($css, $url_pos, length $url) = $filename;
			pos $css = $pos + (length $filename) - (length $url);
		}
	}

	&log('debug', "CSS processing complete\n");
	return $css;
}

sub auto_discover {
	my $res = shift;
	$base = $res->base;
	undef %feed;
	$auto_discover_parser->parse($res->decoded_content);
	if (%feed) {
		&log('notice', "Retrieving $feed{url}\t");
		$res = $ua->get($feed{'url'});
		unless ($res->is_success) {
			$dispatcher->log(level => 'notice', message => "[Failed!]\n");
			&log('debug', "HTTP status line:\t", $res->status_line, "\n");
			return undef;
		}
		$dispatcher->log(level => 'notice', message => "[Retrieved]\n");
		&bzip_fix($res);
		return $res;
	}
	&log('notice', "No feed found\n");
	return undef;
}

sub auto_discover_html_start_handler {
	my($tagname, $attr) = @_;
	if ($tagname eq 'title') {$in_title = 1; return}
	if ($tagname eq 'link' && ${$attr}{'rel'} eq 'alternate' && ${$attr}{'type'} =~ /application\/((rss|atom|rdf)\+xml)/ && !%feed) {
		%feed = (type => $feedtypes{$2}, url => URI->new_abs(${$attr}{'href'}, $base), title => ${$attr}{'title'});
		&log('notice', "Found feed \($2\):\t$feed{url}\n");
	}
}

# a workaround for http://bugs.debian.org/cgi-bin/bugreport.cgi?bug=553345

sub bzip_fix {$_[0]->content_encoding('x-bzip2') if (defined $_[0]->content_encoding) && ($_[0]->content_encoding eq 'bzip2')}
