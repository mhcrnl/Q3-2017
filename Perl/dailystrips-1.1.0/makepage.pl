#!/usr/bin/perl

#
# Program Summary:
#
# Name:             makepage.pl
# Description:      creates an HTML page containing a number of online comics, with an easily exensible framework
# Author:           Andrew Medico <amedico@calug.net>
# Created:          17 Apr 2001, 03:33
# Last Modified:    17 Apr 2001, 03:33
# Current Revision: 1.1.0
#

# Set up
use strict;
no strict qw(refs);

use POSIX qw(strftime);

my (%options, $version, $time_today, @localtime_today, @localtime_yesterday, @localtime_tomorrow, $long_date, $short_date,
    $short_date_yesterday, $short_date_tomorrow, @strips, %defs, $known_strips, %groups, $known_groups, $val, $link_tomorrow,
    $no_dateparse, %logitems);

#BEGIN {
#	unless (eval "use Date::Parse") {
#		print STDERR "Warning: Could not load Date::Parse module. --date option can not be used\n";
#		$no_dateparse = 1;
#	}
#}
use Date::Parse;

# Load common functions
&load_file("shared_functions.pl");


$version = "1.1.0";

$options{'defs_file'} = "strips.def";
$options{'log_file'} = "strips.log";

$time_today = time;

# Parse options - these must be checked first because others depend on their values
for (@ARGV)	{
	if (/^--basedir=(.*)$/o) {
		unless (chdir $1) { die "Error: could not change directory to $1\n" }
	}
	
	if (/^--defs=(.*)$/o) {
		$options{'defs_file'} = $1;
	}
	
	if ($_=~ m/^--date=(.*)$/o) {
		if ($no_dateparse) {die "Error: cannot use --date - Date::Parse not installed\n"}
		unless ($time_today = str2time $1) {die "Error: invalid date specified\n"}
	}
}


# setup time variables...
@localtime_today = localtime $time_today;
$long_date = strftime("\%A, \%B \%-e, \%Y", @localtime_today);
$short_date = strftime("\%Y.\%m.\%d", @localtime_today);
@localtime_yesterday = localtime($time_today - ( 24 * 60 * 60 ));
$short_date_yesterday = strftime("\%Y.\%m.\%d", @localtime_yesterday);
@localtime_tomorrow = localtime ($time_today + 24 * 60 * 60);
$short_date_tomorrow = strftime("\%Y.\%m.\%d", @localtime_tomorrow);

#get strip definitions (do it now because info is used below)
&get_defs;
$known_strips = join('|', sort keys %defs);
$known_groups = join('|', sort keys %groups);

for (@ARGV)	{
	if ($_ eq "" or /^(--help|-h)$/o) {
		print <<END_HELP;
Usage: $0 [OPTION] STRIPS
STRIPS can be a mix of strip names and group names
(group names must be preceeded by an '\@' symbol)
'all' may be used to retrieve all known strips,
or use option --list to list available strips

Options:
  -q  --quiet                turns off progress messages		
      --verbose              turns on extra progress information, overrides -q
      --noindex              disables symlinking current page to index.html
  -a  --archive              generates archive.html as a list of all days,
  -d  --dailydir             creates a separate directory for each day's files
      --stripdir             creates a separate directory for each strip's files
      --date=DATE            Use value DATE instead of local time
                             (DATE is parsed by Date::Parse function
      --defs=FILE            use alternate strips definition file
      --basedir=DIR          work in specified directory instead of current directory
                             (program will look here for strip definitions, previous
                             HTML files, etc. and save new files here)
      --list                 list available strips
      --proxy=host:port      Uses specified HTTP proxy server (overrides environment
                             proxy, if set)
      --proxyauth=user:pass  Sets username and password for proxy server
      --noenvproxy           Ignores the http_proxy environment variable, if set
  -v  --version              Prints version number

Bugs and comments to amedico\@calug.net
END_HELP
		exit;
	} elsif (/^--list$/o) {
format =
@<<<<<<<<<<<<<<<<<<<<<<<< 	@<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
$_, $val
.
		print "Available strips:\n";
		for (split(/\|/, $known_strips)) {
			$val = $defs{$_}{'name'};
			write;
		}
		
		print "\nAvailable groups:\n";
		for (split(/\|/, $known_groups)) {
			$val = $groups{$_}{'desc'};
			write;
		}
		exit;
	} elsif (/^(--archive|-a)$/o) {
		$options{'make_archive'} = 1;
	} elsif (/^(--dailydir|-d)$/o) {
		if (defined $options{'stripdir'}) {die "Error: --dailydir and --stripdir cannot be used together\n"}
		$options{'dailydir'} = 1;
	} elsif (/^(--quiet|-q)$/o) {
		$options{'quiet'} = 1;
	} elsif (/^--verbose$/o) {
		$options{'verbose'} = 1;
	} elsif ($_ =~ m/^--stripdir$/o) {
		if (defined $options{'dailydir'}) {die "Error: --dailydir and --stripdir cannot be used together\n"}
		$options{'stripdir'} = 1;
	} elsif (/^(--version|-v)$/o) {
		print "dailystrips version $version\n";
		exit;
	} elsif ($_ =~ m/^--defs=(.*)$/o or $_ =~ m/^--basedir=(.*)$/o or $_ =~ m/^--date=.*$/o) {
		# nothing done here - just prevent an "unknown option" error (all the more reason to switch to Getopts)
	} elsif (/^($known_strips|all)$/io) {
		if ($_ eq "all") {
			push (@strips, split(/\|/, $known_strips));
		} else {
			push(@strips, $_);
		}
	} elsif (/^@($known_groups)$/io) {
		push(@strips, split(/;/, $groups{$1}{'strips'}));
	} elsif (/^--noenvproxy$/o) {
		$options{'no_env_proxy'} = 1;
	} elsif (/^--proxyauth/o) {
		unless (/^--proxyauth=((.*?):(.*?))$/o) {die "Error: incorrectly formatted proxy username/password\n"}
		$options{'http_proxy_auth'} = $1;
	} elsif (/^--proxy/o) {
		unless (/^--proxy=((.*?):(.*?))$/o) {die "Error: incorrectly formatted proxy server\n"}
		$options{'http_proxy'} = $1;
	} else {
		die "Unknown option: $_\n";
	}
}

# verbose overrides quiet
if ($options{'verbose'} and $options{'quiet'}) {undef $options{'quiet'}}

# Un-needed vars
undef $known_strips; undef $known_groups; undef $val;

unless ($options{'quiet'}) {print STDERR "dailystrips $version starting:\n"}

unless (@strips) {
	die "Error: no strip specified (--list to list available strips)\n";
}

#Set proxy
if (!defined $options{'no_env_proxy'} and !defined $options{'http_proxy'} and defined $ENV{'http_proxy'} ) {
	unless ($ENV{'http_proxy'} =~ m/^(.*?):(.*?)$/o) {die "Error: incorrectly formatted proxy server environment variable\n"}
	$options{'http_proxy'} = $ENV{'http_proxy'};
}
if ($options{'http_proxy'}) {
	unless ($options{'http_proxy'} =~ m/^http:\/\//io) {$options{'http_proxy'} = "http://" . $options{'http_proxy'}}
	if ($options{'verbose'}) { print STDERR "Using proxy server $options{'http_proxy'}\n" }
	if ($options{'verbose'} and $options{'http_proxy_auth'}) { print STDERR "Using proxy server authentication\n" }
}


# open output file	
if (defined $options{'dailydir'}) {
	unless ($options{'quiet'}) { print STDERR "Operating in daily directory mode\n" }
	
	unless (-d $short_date) {
		mkdir ($short_date, 0755) or die "Error: could not create today's directory ($short_date/)\n"
	}
		
	open(STDOUT, ">$short_date/dailystrips-$short_date.html") or die "Error: could not open HTML file ($short_date/dailystrips-$short_date.html) for writing\n";
	
	system("rm -f dailystrips-$short_date.html;ln -s $short_date/dailystrips-$short_date.html dailystrips-$short_date.html");
} else {
	open(STDOUT, ">dailystrips-$short_date.html") or die "Error: could not open HTML file (dailystrips-$short_date.html) for writing\n";
}

unless (defined $options{'no_index'}) { system("rm -f index.html;ln -s dailystrips-$short_date.html index.html") }

# update archive file
if (defined $options{'make_archive'}) {
	
	unless (-e "archive.html") { die "Error: archive.html not found" }
	open(ARCHIVE, "<archive.html") or die "Error: could not open archive.html for reading\n";
	my @archive = <ARCHIVE>;
	close(ARCHIVE);

	unless (grep(/<a href="dailystrips-$short_date.html">/, @archive)) {
		for (@archive) {
			if (s/(<!--insert below-->)/$1\n<a href="dailystrips-$short_date.html">$long_date<\/a><br>/) {
			open(ARCHIVE, ">archive.html") or die "Error: could open archive.html for writing\n";
			print ARCHIVE @archive;
				close(ARCHIVE);
				last;
			}
		}
	}
}
	
# Update previous day's file with a "Next Day" link to today's file
if (open(PREVIOUS, "<dailystrips-$short_date_yesterday.html")) {
	my @previous_page = <PREVIOUS>;
	close(PREVIOUS);

	# Don't bother if no tag exists in the file (because it has already been updated)
	if (grep(/<!--nextday-->/, @previous_page)) {
		my $match_count;
	
		for (@previous_page) {
			if (s/<!--nextday-->/ | <a href="dailystrips-$short_date.html">Next day<\/a>/) {
				$match_count++;
				last if ($match_count == 2);
			}
		}
	
		if (open(PREVIOUS, ">dailystrips-$short_date_yesterday.html")) {
			print PREVIOUS @previous_page;
			close(PREVIOUS);
		} else {
			 warn "Warning: could open dailystrips-$short_date_yesterday.html for writing\n";
		}
	} else {
		warn "Warning: did not find any tag in previous day's file to make today's link\n";
	}
} else {
	warn "Warning: could not open dailystrips-$short_date_yesterday.html for reading\n";
}


if (-e "dailystrips-$short_date_tomorrow.html") {
	$link_tomorrow = " | <a href=\"dailystrips-$short_date_tomorrow.html\">Next day</a>"
} else {
	$link_tomorrow = "<!--nextday-->"
}


&load_log;

# Generate HTML page
print <<END_HEADER;
<html>

<head>
	<title>dailystrips for $long_date</title>
</head>

<body bgcolor=\"#ffffff\" text=\"#000000\" link=\"#ff00ff\">

<center>
	<font face=\"helvetica\" size=\"+2\"><b><u>dailystrips for $long_date</u></b></font>
</center>

<p><font face=\"helvetica\">
&lt; <a href=\"dailystrips-$short_date_yesterday.html\">Previous day</a>$link_tomorrow &gt;
</font></p>

<table border=\"0\">
END_HEADER

#"#kwrite's syntax higlighting is buggy..

for (@strips) {
	my ($name, $homepage) = (split(/;/, &get_strip_info($_)))[1,2];
	my $img_line = $logitems{"$short_date:$_"};
	unless ($img_line =~ m/^\[Error/) {
		$img_line = "<img src=\"$img_line\" alt=\"$name\">";
	}
			
	print <<END_STRIP;
	<tr>
		<td>
			<font face=\"helvetica\" size=\"+1\"><b><a href=\"$homepage\">$name</a></b></font>
		</td>
	</tr>
	<tr>
		<td>
			$img_line
			<p>&nbsp;</p>
		</td>
	</tr>
END_STRIP
}
#"#kwrite's syntax highlighting is buggy..

print <<END_FOOTER;
</table>

<p><font face=\"helvetica\">
&lt; <a href=\"dailystrips-$short_date_yesterday.html\">Previous day</a>$link_tomorrow &gt;
</font></p>

<font face=\"helvetica\">Generated by dailystrips $version</font>

</body>

</html>
END_FOOTER

#"// # kwrite's syntax highlighting is a bit off.. this fixes things

# Misc functions

sub load_file {
	my $file = shift;

	open(FILE, "<$file");
	my @file = <FILE>;
	close(FILE);
	$file = join('', @file);

	eval $file;
}