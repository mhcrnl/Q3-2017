#! /usr/bin/perl -w

# Copyright (C) 2009 Yitzhak Grossman (celejar@gmail.com)
# foffl-ad is free software, released under the terms of the Perl Artistic
# License, contained in the included file 'License'
# foffl-ad comes with ABSOLUTELY NO WARRANTY
# foffl-ad is part of the Foffl project, whose homepage is http://foffl.sourceforge.net

# Usage: foffl-ad [-a] [url1] [url2] [url3] ...
# For each url given on the command line, foffl-ad will try to output the title
# and url of the linked feed, if any, in a form suitable for adding to the feed
# list file used by foffl.  Only the first feed will be output, unless the -a
# option is used, in which case all feeds found will be output.

use strict;

use LWP::UserAgent;
use HTML::Parser;
use Getopt::Std;
use URI;

my %opts;
getopts('a', \%opts);
my (@feeds, $page_title, $in_title, $flag, $res);
my $ua = LWP::UserAgent->new;
my $p = HTML::Parser->new(
	start_h => [\&start_handler, "tagname, attr"],
	text_h => [sub {$page_title = $_[0] if $in_title}, "dtext"],
	end_h => [sub {undef $in_title if ($_[0] eq 'title')}, "tagname"]);

foreach (@ARGV) {
	undef @feeds;
	undef $flag;
	$_ = new URI($_);
	$res = $ua->get(URI->new("http://" . ($_->authority ? $_->authority : "") . ($_->path_query ? $_->path_query : "")));
	unless ($res->is_success) {warn "Failed to retrieve '$_'\nHTTP status line:\t", $res->status_line, "\n"; next;}
	print "Feeds for '$_':\n";
	$p->parse($res->decoded_content);
	foreach (@feeds) {
		my $output = "# $page_title" . (${$_}[1] ? " - ${$_}[1]" : "") . "\n${$_}[0]\n";
		$output = Encode::encode($res->content_charset, $output) if $res->content_charset;
		print $output;
	}
}

sub start_handler {
	my($tagname, $attr) = @_;
	if ($tagname eq 'title') {$in_title = 1; return}
	if ($tagname eq 'link' && ${$attr}{'rel'} eq 'alternate' && ${$attr}{'type'} =~ /application\/(rss|atom|rdf)\+xml/
	&& (!$flag || $opts{'a'})) {
		push @feeds, [URI->new_abs(${$attr}{'href'}, $res->base), ${$attr}{'title'}];
		$flag = 1;
	}
}

# Note: much of this code is taken from the HTML::LinkExtor documentation.
# I have substituted the URI class syntax for the (old?) URI::URL syntax.
# LinkExtor itself is not usable here, since it apparently only recognizes
# tags like 'a' and 'img'
