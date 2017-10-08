#!/usr/bin/perl

#
# Program Summary:
#
# Name:             dailystrips.pl
# Description:      creates an HTML page containing a number of online comics, with an easily exensible framework
# Author:           Andrew Medico <amedico@calug.net>
# Created:          23 Nov 2000, 23:33
# Last Modified:    17 Apr 2001, 02:30
# Current Revision: 1.1.0
#

# Set up
use strict;
no strict qw(refs);

use POSIX qw(strftime);

my (%options, $version, $time_today, @localtime_today, @localtime_yesterday, $long_date, $short_date,
    $short_date_yesterday, @get, @strips, %defs, $known_strips, %groups, $known_groups, $val,
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
@localtime_yesterday = localtime($time_today - ( 86400 ));
$short_date_yesterday = strftime("\%Y.\%m.\%d", @localtime_yesterday);


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
  -d  --dailydir             creates a separate directory for each day's files
      --stripdir             creates a separate directory for each strip's files
  -s  --save                 if it appears that a particular strip has been
                             downloaded, does not attempt to re-download it
      --date=DATE            Use value DATE instead of local time
                             (DATE is parsed by Date::Parse function
  -n  --new                  if today's file and yesterday's file for a strip
                             are the same, does not symlink to save space
                             (local mode only, required on non-*NIX platforms
      --defs=FILE            use alternate strips definition file
      --basedir=DIR          work in specified directory instead of current directory
                             (program will look here for strip definitions, previous
                             HTML files, etc. and save new files here)
      --list                 list available strips
      --proxy=host:port      Uses specified HTTP proxy server (overrides environment
                             proxy, if set)
      --proxyauth=user:pass  Sets username and password for proxy server
      --noenvproxy           Ignores the http_proxy environment variable, if set
      --nospaces             Removes spaces from image filenames
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
	} elsif (/^(--dailydir|-d)$/o) {
		if (defined $options{'stripdir'}) {die "Error: --dailydir and --stripdir cannot be used together\n"}
		$options{'dailydir'} = 1;
	} elsif (/^(--quiet|-q)$/o) {
		$options{'quiet'} = 1;
	} elsif (/^--verbose$/o) {
		$options{'verbose'} = 1;
	} elsif (/^(--save|-s)$/o) {
		$options{'save_existing'} = 1;
	} elsif ($_ =~ m/^--stripdir$/o) {
		if (defined $options{'dailydir'}) {die "Error: --dailydir and --stripdir cannot be used together\n"}
		$options{'stripdir'} = 1;
	} elsif (/^(--new|-n)$/o) {
		$options{'new'} = 1;
	} elsif (/^(--nospaces)$/o) {
		$options{'nospaces'} = 1;
	} elsif (/^(--version|-v)$/o) {
		print "dailystrips version $version\n";
		exit;
	} elsif ($_ =~ m/^--defs=(.*)$/o or $_ =~ m/^--basedir=(.*)$/o or $_ =~ m/^--date=.*$/o) {
		# nothing done here - just prevent an "unknown option" error (all the more reason to switch to Getopts)
	} elsif (/^($known_strips|all)$/io) {
		if ($_ eq "all") {
			push (@get, split(/\|/, $known_strips));
		} else {
			push(@get, $_);
		}
	} elsif (/^@($known_groups)$/io) {
		push(@get, split(/;/, $groups{$1}{'strips'}));
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

unless (@get) {
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

if (defined $options{'dailydir'}) {
	unless ($options{'quiet'}) { print STDERR "Operating in daily directory mode\n" }
	
	unless (-d $short_date) {
		mkdir ($short_date, 0755) or die "Error: could not create today's directory ($short_date/)\n"
	}
	
}


# Download image URLs
unless ($options{'quiet'}) {
	if ($options{'verbose'}) {
		print STDERR "\nRetrieving URLS:\n"
	} else {
		print STDERR "\nRetrieving URLS..."
	}
}
for (@get) {
	if ($options{'verbose'}) { print STDERR "Retrieving URL for $_\n" }
	push(@strips,&get_strip_info($_));
}
unless ($options{'quiet'}) {
	if ($options{'verbose'}) {
		print STDERR "\nRetrieving URLS: done\n"
	} else {
		print STDERR "done\n"
	}
}

if ($options{'verbose'}) {
	print STDERR "\nDownloading strip files:\n"
} else {
	unless ($options{'quiet'}) {print STDERR "Downloading strip files..."}
}

# Load log
&load_log;

for (@strips) {
	my ($strip, $name, $homepage, $img_addr, $updated, $referer) = split(/;/, $_);
	my ($img_line, $local_name, $image, $ext);
	my ($local_name_yesterday);
	
	if ($options{'verbose'} and $options{'local_mode'}) { print STDERR "Downloading strip file for " . lc((split(/;/, $_))[0]) . "\n" }
	
	if ($img_addr =~ "^unavail") {
		if ($options{'verbose'}) { print STDERR "Error: $strip: could not retrieve URL\n" }
		$local_name = "[Error - unable to retrieve URL]";
	} else {
		$img_addr =~ m/http:\/\/(.*)\/(.*)\.(.*)$/o;
		if (defined $3) { $ext = ".$3" }
		
		$local_name_yesterday = $logitems{"$short_date_yesterday:$strip"};
		if ($options{'stripdir'}) {
			$local_name = "$name/$short_date$ext";
			unless ( -d $strip) { mkdir $name, 0755; }
		} elsif ($options{'dailydir'}) {
			$local_name = "$short_date/$name-$short_date$ext";
		} else {
			$local_name = "$name-$short_date$ext";
		}
			
		if ($options{'nospaces'}) { $local_name =~ s/\s+//g }

		unless ($options{'save_existing'} and  -e $local_name) {
			# need to download
			$image = &http_get($img_addr,$referer);
			if ($image =~ m/^ERROR/o) {
				if ($options{'verbose'}) { print STDERR "Error: $strip: could not download strip\n" }
				$local_name = "[Error - unable to download image]";
			} else {
				if (-l $local_name) {unlink $local_name} # in case today's file is a symlink to yesterday's
				
				open(IMAGE, ">$local_name");
				print IMAGE $image;
				close(IMAGE);
					
				# Check to see if this is the same file as yesterday
				if (system("diff \"$local_name_yesterday\" \"$local_name\" >/dev/null 2>&1") == 0) {
					
					if ($updated eq "daily") {
						#don't save the same strip as yesterday if it's supposed to be updated daily
						system("rm -f \"$local_name\"");
						$local_name = "[Error - new strip not available]";
					} else {
						#semidaily strips are allowed to be duplicates
						unless ($options{'new'}) {
							if (system("diff \"$local_name_yesterday\" \"$local_name\" >/dev/null 2>&1") == 0) {
								system("rm -f \"$local_name\"");
								if (defined $options{'dailydir'} or defined $options{'stripdir'} ) {
									system("ln -s \"../$local_name_yesterday\" \"$local_name\" >/dev/null 2>&1");
								} else {
									system("ln -s \"$local_name_yesterday\" \"$local_name\" >/dev/null 2>&1");
								}
							}
						}
					}
				}
			}
		}
	}
	
	# update with log info about strip
	$logitems{"$short_date:$strip"} = $local_name;
}

# save log
&save_log;


if ($options{'verbose'}) {
	print STDERR "\nDownloading strip files: done\n"
} else {
	print STDERR "done\n"
}


# Misc functions

sub load_file {
	my $file = shift;

	open(FILE, "<$file");
	my @file = <FILE>;
	close(FILE);
	$file = join('', @file);

	eval $file or warn "$!";
}