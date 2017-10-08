#
# Program Summary:
#
# Name:             shared_functions.pl
# Description:      shared functions for dailystrips scripts
# Author:           Andrew Medico <amedico@calug.net>
# Created:          16 Apr 2001, 14:29
# Last Modified:    16 Apr 2001, 14:29
# Current Revision: 1.1.0
#

use LWP::UserAgent;
use HTTP::Request;


sub http_get {
	my ($url, $referer) = @_;

	my $headers = new HTTP::Headers;;
	my $request = HTTP::Request->new('GET', $url, $headers);
	my $ua = LWP::UserAgent->new;
	#$ua->agent("dailystrips $version: " . $ua->agent());
	$ua->agent("");
	$ua->proxy('http', $options{'http_proxy'});
	$headers->authorization_basic(split(/:/, $options{'http_proxy_auth'}));
	$headers->referer($referer);
				
	my $response = $ua->request($request);
	(my $status = $response->status_line()) =~ s/^(\d+)/$1:/;

	if ($response->is_error()) {
		if ($options{'verbose'}) { print STDERR "Error: could not download $url: $status\n" }
		return "ERROR: $status";
	} else {
		return $response->content;
	}
}

sub get_strip_info {
	my ($strip) = @_;
	my ($page, $addr);
	
	if ($defs{$strip}{'type'} eq "search") {
		$page = &http_get($defs{$strip}{'searchpage'});

		if ($page =~ m/^ERROR/) {
			if ($options{'verbose'}) { print STDERR "Error: $strip: could not download searchpage $defs{$strip}{'searchpage'}\n" }
			$addr = "unavail-server";
		} else {
			$page =~ m/$defs{$strip}{'searchpattern'}/i;
			
			unless (${$defs{$strip}{'matchpart'}}) {
				if ($options{'verbose'}) { print STDERR "Error: $strip: searchpattern $defs{$strip}{'searchpattern'} did not match anything in searchpage $defs{$strip}{'searchpage'}\n" }
				$addr = "unavail-nomatch";
			} else {
				$addr = $defs{$strip}{'baseurl'} . "${$defs{$strip}{'matchpart'}}";
			}
		}
		
	} elsif ($defs{$strip}{'type'} eq "generate") {
		$addr = $defs{$strip}{'imageurl'};
		$addr = $defs{$strip}{'baseurl'} . $addr;
	}
	
	unless ($addr =~ m/^http:\/\//io || $addr =~ m/^unavail/io) { $addr = "http://" . $addr }
	
	return("$strip;$defs{$strip}{'name'};$defs{$strip}{'homepage'};$addr;$defs{$strip}{'updated'};$defs{$strip}{'referer'}");
}

sub get_defs {
	my ($strip, $class, $sectype, %classes, $group);
	my $line = 1;
	
	open(DEFS, "<$options{'defs_file'}") or die "Error: could not open strip definitions file\n";
	my @defs_file = <DEFS>;
	close(DEFS);
	
	@defs_file = grep(!/^\s*#/, @defs_file);		# weed out comment-only lines
	@defs_file = grep(!/^\s*\n/, @defs_file);		# get rid of blank lines
	
	for (@defs_file) {
		chomp;
		s/^\s+//o; s/\s+$//o; s/#(.*)//o;

		if (!$sectype) {
			if (/^strip\s+(\w+)$/io)
			{
				$strip = $1;
				$sectype = "strip";
			}
			elsif (/^class\s+(.*)$/io)
			{
				$class = $1;
				$sectype = "class";
			}
			elsif (/^group\s+(.*)$/io)
			{
				$group = $1;
				$sectype = "group";
			}
			elsif (/^(.*)/io)
			{
				die "Unknown keyword '$1' at $options{'defs_file'} line $line\n";
			}
		}
		elsif (/^end$/io)
		{
			if ($sectype eq "class")
			{
				undef $class
			}		
			elsif ($sectype eq "strip")
			{
				if ($defs{$strip}{'useclass'}) {
					my $using_class = $defs{$strip}{'useclass'};
					
					for (qw(homepage searchpage searchpattern baseurl imageurl referer)) {
						if ($classes{$using_class}{$_} and !$defs{$strip}{$_}) {
							my $classvar = $classes{$using_class}{$_};
							$classvar =~ s/(\$[0-9])/$defs{$strip}{$1}/g;
							$classvar =~ s/\$strip/$strip/g;
							$defs{$strip}{$_} = $classvar;
						}
					}
				
					for (qw(type matchpart updated)) {
						if ($classes{$using_class}{$_} and !$defs{$strip}{$_}) {
							$defs{$strip}{$_} = $classes{$using_class}{$_};
						}
					}	
				}	
						
				#substitute auto vars for real vals here/set defaults
				unless ($defs{$strip}{'updated'})    {$defs{$strip}{'updated'} = "daily"}
				unless ($defs{$strip}{'searchpage'}) {$defs{$strip}{'searchpage'} = $defs{$strip}{'homepage'}}
				unless ($defs{$strip}{'referer'})    {
					if ($defs{$strip}{'searchpage'}) {
						$defs{$strip}{'referer'} = $defs{$strip}{'searchpage'}
					} else {
						$defs{$strip}{'referer'} = $defs{$strip}{'homepage'}
					}
				}
				
				for (qw(homepage searchpage searchpattern imageurl baseurl referer)) {
					#other vars in definition
					# could do without 'if defined..' if not running under -w
					if ($defs{$strip}{$_}) {$defs{$strip}{$_} =~ s/\$(name|homepage|searchpage|searchpattern|imageurl|baseurl|referer)/$defs{$strip}{$1}/g}
				}			
				
				for (qw(homepage searchpage searchpattern imageurl baseurl referer)) {
					#dates
					# could do without 'if defined..' if not running under -w
					if ($defs{$strip}{$_}) { $defs{$strip}{$_} =~ s/(\%(-?)[a-zA-Z])/strftime("$1", @localtime_today)/ge }
				}
				
				
				#sanity check vars
				for (qw(name homepage type)) {
					unless ($defs{$strip}{$_})     { die "Error: strip $strip has no '$_' value\n" }
				}
				
				for (qw(homepage searchpage baseurl imageurl)){	
					if ($defs{$strip}{$_} and $defs{$strip}{$_} !~ m/^http:\/\//io) {
						die "Error: strip $strip has invalid $_\n"
					}
				}
				
				if ($defs{$strip}{'type'} eq "search") {
					unless ($defs{$strip}{'searchpattern'}) { die "Error: strip $strip has no 'searchpattern' value\n" }
					unless ($defs{$strip}{'matchpart'})     { die "Error: strip $strip has no 'matchpart' value\n" }
				} else {
					unless ($defs{$strip}{'imageurl'})      { die "Error: strip $strip has no 'imageurl' value\n" }
				}
				
				#foreach my $strip (keys %defs) {
				#	foreach my $key (qw(homepage searchpage searchpattern imageurl baseurl referer)) {
				#		print STDERR "DEBUG: $strip:$key=$defs{$strip}{$key}\n";
				#	}
				#	print STDERR "DEBUG: $strip:name=$defs{$strip}{'name'}\n";
				#}
			
				undef $strip;
			}
			elsif ($sectype eq "group")
			{
				chop $groups{$group}{'strips'};
				
				unless ($groups{$group}{'desc'}) { $groups{$group}{'desc'} = "[No description]"}
				
				undef $group;
			}
			
			undef $sectype;
		}
		elsif ($sectype eq "class") {
			if (/^homepage\s+(.+)$/io) {
				my $val = $1;
				$classes{$class}{'homepage'} = $val;
			}
			elsif (/^type\s+(.+)$/io)
			{
				my $val = $1;
				unless ($val =~ m/^(search|generate)$/io) { die "Error: invalid types at $options{'defs_file'} line $line\n" }
				$classes{$class}{'type'} = $val;
			}
			elsif (/^searchpage\s+(.+)$/io)
			{
				my $val = $1;
				$classes{$class}{'searchpage'} = $val;
			}
			elsif (/^searchpattern\s+(.+)$/io)
			{
				$classes{$class}{'searchpattern'} = $1;
			}
			elsif (/^matchpart\s+(.+)$/o)
			{
				my $val = $1;
				unless ($val =~ m/^\d+$/io) { die "Error: invalid matchpart at $options{'defs_file'} line $line\n" }
				$classes{$class}{'matchpart'} = $val;
			}
			elsif (/^baseurl\s+(.+)$/io)
			{
				my $val = $1;
				$classes{$class}{'baseurl'} = $val;
			}
			elsif (/^imageurl\s+(.+)$/io)
			{
				my $val = $1;
				$classes{$class}{'imageurl'} = $val;
			}
			elsif (/^referer\s+(.+)$/io)
			{
				$classes{$class}{'referer'} = $1;
			}
			elsif (/^updated\s+(.+)$/io)
			{
				$classes{$class}{'updated'} = $1;
			}
			elsif (/^(.+)(\s+?)/io)
			{
				die "Unknown keyword '$1' at $options{'defs_file'} line $line\n";
			}
		}
		elsif ($sectype eq "strip") {
			if (/^name\s+(.+)$/io)
			{
				$defs{$strip}{'name'} = $1;
			}
			elsif (/^useclass\s+(.+)$/io)
			{
				$defs{$strip}{'useclass'} = $1;
			}
			elsif (/^homepage\s+(.+)$/io) {
				my $val = $1;
				$defs{$strip}{'homepage'} = $val;
			}
			elsif (/^type\s+(.+)$/io)
			{
				my $val = $1;
				unless ($val =~ m/^(search|generate)$/io) { die "Error: invalid type at $options{'defs_file'} line $line\n" }
				$defs{$strip}{'type'} = $val;
			}
			elsif (/^searchpage\s+(.+)$/io)
			{
				my $val = $1;
				$defs{$strip}{'searchpage'} = $val;
			}
			elsif (/^searchpattern\s+(.+)$/io)
			{
				$defs{$strip}{'searchpattern'} = $1;
			}
			elsif (/^matchpart\s+(.+)$/o)
			{
				my $val = $1;
				unless ($val =~ m/^\d+$/io) { die "Error: invalid matchpart at $options{'defs_file'} line $line\n" }
				$defs{$strip}{'matchpart'} = $val;
			}
			elsif (/^baseurl\s+(.+)$/io)
			{
				my $val = $1;
				$defs{$strip}{'baseurl'} = $val;
			}
			elsif (/^imageurl\s+(.+)$/io)
			{
				my $val = $1;
				$defs{$strip}{'imageurl'} = $val;
			}
			elsif (/^updated\s+(.+)$/io)
			{
				$defs{$strip}{'updated'} = $1;
			}
			elsif (/^referer\s+(.+)$/io)
			{
				$defs{$strip}{'referer'} = $1;
			}
			elsif (/^(\$[0-9])\s+(.+)$/io)
			{
				$defs{$strip}{$1} = $2;
			}
			elsif (/^(.+)(\s+?)/io)
			{
				die "Unknown keyword '$1' at $options{'defs_file'} line $line, in strip $strip\n";
			}
		} elsif ($sectype eq "group") {
			if (/^desc\s+(.+)$/io)
			{
				$groups{$group}{'desc'} = $1;
			}
			elsif (/^include\s+(.+)$/io)
			{
				$groups{$group}{'strips'} .= join(';', split(/\s+/, $1)) . ";";
			}
			elsif (/^(.+)(\s+?)/io)
			{
				die "Unknown keyword '$1' at $options{'defs_file'} line $line, in group $group\n";
			}
		}
			
		
		
		$line++;
	}
	
	# Post-processing validation
	for $group (keys %groups) {
		for ( split(/;/, $groups{$group}{'strips'}) ) {
			unless ($defs{$_}) {
				die "Error: group $group includes non-existant strip $_\n";
			}
		}
	}
	
}

sub load_log {
	open(LOG,"<$options{'log_file'}");
	my @log = <LOG>;
	close(LOG);
		
	for (@log) {
		chomp;
		#print STDERR "DEBUG: Reading log - have line: $_\n";
		my ($date_name, $filename) = split(/-/, $_, 2);
		$logitems{$date_name} = $filename;
	}
}

sub save_log {
	open(LOG, ">$options{'log_file'}");
	for (keys %logitems) {
		print LOG "$_-$logitems{$_}\n";
		#print STDERR "DEBUG: Writing log - have line: $_-$logitems{$_}\n";
	}
	close(LOG);
}

1;