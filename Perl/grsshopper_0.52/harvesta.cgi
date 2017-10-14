#!/usr/bin/perl
print "Content-type: text/html\n\n";
print "Harvester\n";

#    gRSShopper 0.3  Harvest  0.41  -- gRSShopper administration module
#    29 July 2011 - Stephen Downes

#    Copyright (C) <2011>  <Stephen Downes, National Research Council Canada>
#    This program is free software: you can redistribute it and/or modify
#    it under the terms of the GNU General Public License as published by
#    the Free Software Foundation, either version 3 of the License, or
#    (at your option) any later version.

#    This program is distributed in the hope that it will be useful,
#    but WITHOUT ANY WARRANTY; without even the implied warranty of
#    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
#    GNU General Public License for more details.
#    You should have received a copy of the GNU General Public License
#    along with this program.  If not, see <http://www.gnu.org/licenses/>.

# To add a new data type:
# 1. Create the table 'table' in the database, *required fields* include 
#     table_id   (eg., post_id, media_id, etc) primary key unique int(10)
#     table_creator int(10)
#     table_crdate int(10)
#     table_title varchar
# 2. Create link in admin header left colum
#    Eg.
#    			[<a href="admin.cgi?db=lookup&action=edit">New</a>]
#			[<a href="admin.cgi?db=lookup&action=list">List</a>]
#			Lookup <br>
#
# 3. Add to list in admin.cgi, page.cgi under
#    	# Determine Request Table, ID number
# 4. Create view for 'list table' - view title:  table_list
# 5. Add table and desired display elements to edit under
#     # Define Form Contents
#    in admin.cgi, page.cgi
#    Don't forget to include ,"submit" for the submit button
# 6. If 'type' or 'category' fields are used, create dropdown in optlist
#    title:  table_field   (eg. post_type )
#    list: name,value;name,value  (eg. Illustration,Illustration;Enclosure,Enclosure )
# 7. Add additional views as needed. Esp. recommended is an html view




# Forbid agents

if ($ENV{'HTTP_USER_AGENT'} =~ /bot|slurp|spider/) { 
  	print "Content-type: text/html; charset=utf-8\n";
	print "HTTP/1.1 403 Forbidden\n\n";
	print "403 Forbidden\n"; 
	exit; 
}


# Initialize gRSShopper Library

use FindBin qw($Bin);
require "$Bin/grsshopper.pl";
our ($query,$vars) = &load_modules("admin");			# Request Variables
our ($Site,$dbh) = &get_site("admin");				# Site
our $log = "";
our $Person = {}; bless $Person;				# Person  (still need to make this an object)
&get_person($dbh,$query,$Person);		
my $person_id = $Person->{person_id};


my $options = {}; bless $options;		# Initialize system variables
our $cache = {}; bless $cache;	



unless ($vars->{mode} eq "silent") {
	print "Content-type: text/html; charset=utf-8\n\n";
}
	


							# Only Admin Harvest

my $msg = "Permission Denied<br/><a href='$Site->{st_cgi}login.cgi?refer=$Site->{script}'?Login</a>";
&error($dbh,$query,"",$msg) unless (($Person->{person_status} eq "admin") || ($vars->{person_status} eq "cron"));



# Analyze Request --------------------------------------------------------------------

my $format; my $action;

$action = $vars->{action};			# Determine Action
unless ($action) { $action="harvest"; }


$vars->{format} ||= "html";			# Determine Output Format



exit if ($action eq "test");

# Actions ------------------------------------------------------------------------------



$vars->{msg} = "<p>Feed parser report</p><p>";



for ($action) {					# There is always an action

	/queue/ && do { $vars->{source} = "queue"; &harvest($dbh,$query); last; 		};
	/harvest/ && do { &harvest($dbh,$query); last; 		};
	/export/ && do { &export_opml($dbh,$query); last;	};
	/import/ && do { &import_opml($dbh,$query); last;	};
	/opmlopts/ && do { &opmlopts($dbh,$query); last;	};

						# Go to Home Page


	print "Content-type: text/html; charset=utf-8\n\n";
	print "Harvester OK\n\n";
	exit;

}

if ($dbh) { $dbh->disconnect; }		# Close Database and Exit
&log_cron($log);

exit;



#--------------------------------------------------------------------------------
#
#
#                      Harvest Functions
#
#
#---------------------------------------------------------------------------------


# -------   Harvest ---------------------------------------------------------

# Main harvesting function

sub harvest {

	my ($dbh,$query) = @_; my $feed;
	my $vars = $query->Vars;

	unless ($vars->{source}) { 
		if ($vars->{url} && $vars->{url} =~ /^http/i) { $vars->{source} = "url"; }	# Default for feed, url
		elsif ($vars->{feed} && $vars->{feed} =~ /^\d+$/) { $vars->{source} = "feed"; }
		else { $vars->{source} = "queue"; }
	}


							# Print Header
	if (($vars->{format} eq "html") && ($vars->{mode} ne "silent")) { 
		print "Content-type: text/html; charset=utf-8\n\n";
		$Site->{header} =~ s/<PAGE_TITLE>/Harvester/mig;
		print $Site->{header};
		print "<h2>Harvester</h2>";
		if ($vars->{analyze} eq "on") {
			print "<p>This is a feed content analysis only. Data will not be saved to the database.</p>";
		}
	}


							# Select Harvest Type
	for ($vars->{source}) {
		/file/    && do { &harvest_file($dbh,$query); last;  };
		/url/     && do { $feed = &harvest_url($dbh,$query); last;  };
		/feed/    && do { $feed = &harvest_feed($dbh,$query); last; };
		/queue/   && do { $feed = &harvest_queue($dbh,$query); last;};
		/all/	    && do { &harvest_all($dbh,$query); last;	  };
		&error($dbh,$query,"","Source type not specified for harvest."); 
	}


	return 0 unless ($feed);



							# Print Footer
	if (($vars->{format} eq "html") && ($vars->{mode} ne "silent")) { 
		print $Site->{footer}; 
	}

 

}


# -------   Harvest All -------------------------------------------------------

# Like the title says. Don't use this.

sub harvest_all {

	my ($dbh,$options) = @_;
	my $stmt = "SELECT * FROM feed WHERE feed_status = 'A' ORDER BY feed_id";
	my $sth = $dbh->prepare($stmt);
	$sth->execute();
							# Print Title
	$log .= "HARVEST ALL FEEDS: \n";						
	if (($vars->{format} eq "html") && ($vars->{mode} ne "silent")) { 
		print "<h3>Harvesting All Feeds</h3>"; 
	}
	

	while (my $feed_record = $sth->fetchrow_hashref()) {
		$vars->{msg} = "<br/>\n"; $vars->{err} = "";
		$feed_record->{feed_title} ||= "Untitled";
		$vars->{msg} .= "Feed Name: ".$feed_record->{feed_id}.". ".$feed_record->{feed_title}."<br/>\n";
		$feed_record->{feed_type} ||= "Unknown";
		$vars->{msg} .= "Feed Type: ".$feed_record->{feed_type}."<br/>\n";
		$vars->{url} = $feed_record->{feed_link};
		$vars->{url} = $feed_record->{feed_link};
		&harvest_url($dbh,$query,$feed_record);


	}

}

# -------   Harvest Queue ------------------------------------------------------

# Harvests the next feed in the queue. Used by Cron

sub harvest_queue {  # Harvests next item in queue, updates queue

	my ($dbh,$query) = @_;
	my $vars = $query->Vars;
	$vars->{msg} = "Harvesting next in Queue<br/>\n";
	my $qtime = time;
	



						# Find next in queue
	my $stmt = "SELECT * FROM feed WHERE feed_status = 'A' ORDER BY feed_lastharvest LIMIT 0,1";
	my $next = $dbh->selectrow_hashref($stmt);
	my $feedid =  $next->{feed_id};


	if ($feedid) {			# If found, Harvest Feed

		$vars->{msg} .= "Next in queue is feed number $feedid <br/>\n";
		$vars->{feed} = $feedid;
		&harvest_feed($dbh,$query);

	} else {

		$vars->{error} .= "Cannot find next in queue<br/>";
		$log .= "ERROR - Cannot find next in queue\n";
	}

		
	return $feedid;

}



# -------   Harvest Feed ---------------------------------------------------------

# Looks up URL for feed given feed ID, then harvests

sub harvest_feed {

	my ($dbh,$query) = @_;
	my $vars = $query->Vars;
	
	&harvest_url($dbh,$query,$vars->{feed});


}

# -------   Harvest File ------------------------------------------------------

sub harvest_file {

	my ($dbh,$query) = @_;
	my $vars = $query->Vars;

	$vars->{file} = "/var/www/cgi-bin/".$vars->{file};
	$vars->{msg} .= "Harvesting File: ".$vars->{file}."<br>\n";
	$log .= "Harvesting File: ".$vars->{file}."<br>\n";

	my $feed;					
	unless ($feed = Feed->parse($vars->{file})) { 
		$vars->{error} .= "File parse error<br>" .  Feed->errstr ."<br>";
		print "<p>".$vars->{msg}.$vars->{error}."</p>\n";
		return;
	}

	&process_feed($dbh,$query,$feed);

	# Output Result

	&harvest_report($dbh,$query);


}


sub harvest_url {


	my ($dbh,$query,$feedid,$count) = @_;
	my $vars = $query->Vars;
	$vars->{url} =~ s/feed:/http:/ig;				# Fixes a common error
		
	unless ($count) { $count = 0; }
	
	my $feed = gRSShopper::Feed->new();

	my $mapping;		

	$vars->{msg} .=  "--------------------- Harvesting feed $feed <p>\n\n";
									#     Get Feed data


	if ($feedid) {							#     - Existing Feed


		die $feed->{error} unless $feed->load_from_db($dbh,$feedid);
		
		$vars->{url} = $feed->{feed_link};

					
	} else {							#     - Unknown Feed
									# 		Validate Harvest URL
		$vars->{url} =~ s/feed:/http:/ig;
		unless ($vars->{url} && $vars->{url} =~ /^http/)  { 
			$vars->{error} .= "Invalid harvest URL provided.<br/>"; 
			$log .= "Invalid harvest URL provided.<br/>";
			print "<p>".$vars->{msg}.$vars->{error}."</p>\n"; return;	

									#     	Try to find feed
		} elsif (my $feedid = &db_locate($dbh,"feed",{feed_link => $vars->{url}})) {
			$feed = &db_get_record($dbh,'feed',{feed_id => $feedid});
			$vars->{msg} .=  "Existing feed: $feed->{feed_title} <br>\n";

		} else {
			$feed = gRSShopper::Feed->new();
			$feed->{feed_lastharvest} = 0;
			$feed->{feed_link} = $vars->{url};
			$feed->{feed_title} = $vars->{url};
			$feed->{feed_crdate} = time;
			$feed->{creator} = $Person->{person_id};
			$feed->{feed_id} = &db_insert($dbh,$query,"feed",$feed);
			$vars->{msg} .= "Created new feed, $feed->{feed_id}<br>\n"; 
			$log .= "Created new feed, $feed->{feed_id}<br>\n"; 
		}
	}

	$vars->{msg} .= "Feed : ".$feed->{feed_id}.". ".$feed->{feed_title}."<br/>\n";
	



									# Check lastharvest date so we don't slam servers
	my $now = time; my $span = $now - $feed->{feed_lastharvest};
	$vars->{msg} .=  "Last harvested: $feed->{feed_lastharvest}  Span: $span <p>\n";
	my $harv_freq = 1;
	if ($span < (60*60*$harv_freq)) {
		unless ($vars->{force} eq "yes") {	# Allow override for testing
			$vars->{msg} .=  "Last harvest was less than $harv_freq hours ago.";
			$log .= " Last harvest was less than $harv_freq hours ago.\n";
			&harvest_report($dbh,$query);
			return;
		}
	}



	$feed->{feed_lastharvest} = $now;
	my $wh = &db_update($dbh,"feed",{feed_lastharvest=>$feed->{feed_lastharvest}},$feed->{feed_id});		# Update Harvest Date
	$log .= "Harvesting Feed $feed->{feed_id}: $feed->{feed_title} "; 




									#     Get Mapping data

	if ($mapping = &db_get_record($dbh,"mapping",
		{mapping_specific_feed => $feed->{feed_id}, mapping_stype => 'mapping_specific_feed' })) { 
			$vars->{msg} .= "Mapping specific feed.<br> \n"; 
			$mapping->{mapping_priority} = 3;
	} elsif ($mapping = &db_get_record($dbh,"mapping",
		{mapping_feed_type => $feed->{feed_type}, mapping_stype => 'mapping_feed_type'})) { 
			$vars->{msg} .= "Mapping for feed type.<br>\n"; 
	}



									#      Get Data for Entry Mappings
	my $field_list = &map_field_list($dbh);
	my $field_value_pair = &map_field_value_pair($dbh);



									# 	 Retrieve Feed

	$vars->{msg} .= qq|Retrieving URL: <a href="$vars->{url}">$vars->{url}</a><br/>\n|;
	my $feedstring = &get_feed($query,$vars->{url});

	
	$feedstring =~ s/^\s+//;	# Remove leading spaces

									#	Parse Feed
	my $result;
	if ($feedstring =~ /^BEGIN:VCALENDAR/) { 
		$vars->{msg} .= "iCal format detected<br/>";
		$result = &parse_ical($dbh,$feedstring,$feed,$mapping,$field_list,$field_value_pair);			# iCal
	} else {						
		$vars->{msg} .= "XML format detected<br/>";
		$result = &parse_feed($dbh,$feedstring,$feed,$mapping,$field_list,$field_value_pair);			# RSS / Atom
	}
									#      Deal with feed error caused by
									#      use of HTML URL instead of feed
	
									
	if ($result eq "feed error") {
		my $editlink = qq|[<a href="$Site->{st_cgi}admin.cgi?action=edit&feed=$feed->{feed_id}">Edit Feed</a>]|;
		$vars->{msg} .= qq|Feed error, trying autodetect<br>|;
		if (my $foundurl = &try_autodetect($dbh,$query,$feedstring)) {
			$feed->{feed_link} = $foundurl;
			$vars->{msg} .= qq|Trying alternate URL $foundurl<br>|;
			my $foundstring = &get_feed($query,$foundurl);
			my $newresult = &parse_feed($dbh,$foundstring,$feed,$mapping,$field_list,$field_value_pair);
			if ($newresult eq "ok") { $vars->{msg} .= qq|Alternate URL worked ok.<br>|; $log .= " - Alternate URL OK\n";}
			elsif ($newresult eq "feed error") { 
				$vars->{error} = "Feed error persists; I give up. $editlink<br>"; 
				$log .= "Feed error persists; I give up. $editlink\n";}
		} else {
			$vars->{error} = "Feed error, no alternate link found.<br>";
			$log .= "Feed error, no alternate link found. $editlink \n";
		}
	} else {
		$log .= " - OK. \n";
	}



	&harvest_report($dbh,$query);

}

# ---------  Try Autodetect ------------------------------------------------
#
# Given a URL, tries to get an RSS feed address
#
sub try_autodetect {

	my ($dbh,$query,$feedstring) = @_;
	my $vars = $query->Vars;


	my $autofound = "";
	if ($feedstring =~ /<link rel=\"alternate\"(.*?)\/>/) {
		my $relstring = $1;
		if ($relstring =~ /href=\"(.*?)\"/) {
			$autofound = $1;
		}
	}
					# Return if URL not found
	unless ($autofound) {
		$vars->{error} = "Accessed URL, but no autodetect found.<br/>";
		return;
	}

	return $autofound;

}


sub get_feed {

	my ($query,$url) = @_;
	my $vars = $query->Vars;

	my $ua = LWP::UserAgent->new();
	my $response = $ua->get($url,{
		'User-Agent' => 'gRSShopper 0.3',
		'Accept' => '*/*','application/atom+xml',
		'Accept-Charset' => 'iso-8859-1,*,utf-8',
		'timeout' => '30'
	});
  
	if (! $response->is_success) { 
		my $err = $response->status_line;
		my $as_string = $response->as_string;
		my ($r_header,$r_body) = split "<",$as_string;
		$r_header =~ s/\n/<br>\n/g;
		#$err .= $response->head;
		$vars->{msg} .= "<b>Feed error reported.</b><br> $err ".$r_header." <br><br>";
	}
	
	my $content = $response->content;

	
	#my $content = get $url or $vars->{msg} .=  "Error $! <br>";


	$vars->{msg} .=  "Couldn't get $url <br>" unless (defined $content && $content);
	return $content;


}

sub harvest_report {

	my ($dbh,$query) = @_;
	my $vars = $query->Vars;

#	if (
#		($vars->{format} eq "html") 
#		&& ($vars->{mode} ne "silent")
#	) { 
	unless ($vars->{mode} eq "silent") { print "<p>".$vars->{msg}."</p>\n"; }

#	}
	if ($vars->{error}) { 
		print "<p>".$vars->{error}."</p>"; 

	}
}



#--------------------------------------------------------------------------------
#
#
#                      OPML Functions
#
#
#---------------------------------------------------------------------------------



# -------   Export OPML ------------------------------------------------------

sub export_opml {

	my ($dbh,$query) = @_;
	my $vars = $query->Vars;

						# Load OPML Module
	&error($dbh,"","",$vars->{error}) unless (&new_module_load($query,"XML::OPML"));

						# Create an OPML File Shell
	my $opml = new XML::OPML(version => "1.1");
	my $date = &rfc822_date(time);

						# Create the Head
 	$opml->head(
             title => $Site->{st_name}." OPML",
             dateCreated => $date,
             dateModified => $date,
             ownerName => $Site->{st_pub},
             ownerEmail => $Site->{em_from},
             expansionState => '',
             vertScrollState => '',
             windowTop => '',
             windowLeft => '',
             windowBottom => '',
             windowRight => '',
           );

						# Insert Feeds
	my $stmt = "SELECT * FROM feed";
	my $sth = $dbh->prepare($stmt);
	$sth->execute();
	while (my $feed_record = $sth->fetchrow_hashref()) {

		# XML::OPML doesn't properly escape yet
		$feed_record->{feed_description} =~ s/&/&amp;/mig;
		$feed_record->{feed_title} =~ s/&/&amp;/mig;
		$feed_record->{feed_description} =~ s/"/&quot;/mig;
		$feed_record->{feed_title} =~ s/"/&quot;/mig;

		$opml->add_outline(
         		text => $feed_record->{feed_title},
       			description => $feed_record->{feed_description},
                	title => $feed_record->{feed_title},
                	type => $feed_record->{feed_type},
                	version => $feed_record->{feed_type},
                	htmlUrl => $feed_record->{feed_html},
                	xmlUrl => $feed_record->{feed_link},
               );

	}

	my $filename = $Site->{st_urlf} . "feeds.xml";
	my $fileurl = $Site->{st_url} . "feeds.xml";
	$opml->save($filename);
	
	if ($vars->{format} eq "opml") {
		print $opml->as_string();
	} elsif ($vars->{internal} eq "import") {
		# No output; called from import_opml
	} else {
		$vars->{msg} .= qq|
			Your OPML file has been created and saved to<br/>
			<a href="$fileurl">$fileurl</a>\n|;

		print "Content-type: text/html; charset=utf-8\n\n";
		$Site->{header} =~ s/<PAGE_TITLE>/Export OPML/mig;
		print $Site->{header};
		print qq|<p>[<a href="|.$Site->{st_cgi}.qq|admin.cgi">Back to Admin</a>]</p>|;
		print "<h2>Export OPML</h2>";
		print $vars->{msg};
		print $Site->{footer};
	}

	return $fileurl;

}

# -------   OPML Opts -------------------------------------------------------

sub opmlopts {

						# Load OPML Module
	&error($dbh,"","",$vars->{error}) unless (&new_module_load($query,"XML::OPML"));
	
	print "Content-type: text/html; charset=utf-8\n\n";
	$Site->{header} =~ s/<PAGE_TITLE>/Import OPML/mig;
	print $Site->{header};	
	print qq|<p>[<a href="|.$Site->{st_cgi}.qq|admin.cgi">Back to Admin</a>]</p>
		<h2>Import OPML</h2><p>An OPML file is a list of feeds used
		by an aggregator. You can import an OPML file and use this as
		a list of feeds to aggregate here.</p>
		<p>Please use caution as these actions cannot be undone. We
		recommend that you export your current OPML file and save it
		before importing any OPML file.</p>
		<p><a href="|.$Site->{st_cgi}.qq|harvest.cgi?action=export">Export
		OPML File</a></p>
		<p>Enter the URL of the OPML file to be harvested and submit:</p>
		<form method="post" action="|.$Site->{st_cgi}.qq|harvest.cgi">
		<input name="url" type="text" size="60">
		<input type="hidden" name="action" value="import">
		<input type="submit" value="Submit URL"></form></p>
	|;
	print $Site->{fopoter};
}



# -------   Import OPML ------------------------------------------------------

sub import_opml {

	my ($dbh,$query) = @_;
	my $vars = $query->Vars;

	unless ($vars->{url})  { &error($dbh,$query,"","No URL specified for import"); 	}


						# If ?append=no
						# Wipes out existing feeds
						# caution caution caution
	my $backupfile = "";
	if ($vars->{append} eq "no") {
		$vars->{internal} = "import";
		$backupfile = &export_opml($dbh,$query);
		$dbh->do('DELETE FROM feed WHERE feed_id > 0');
		$vars->{msg} .= qq|All existing feeds have been removed. 
				   This list has been backed up (as OPML) at
				   <a href="$backupfile">$backupfile</a> .<br/><br/>\n|;
	}


						# Get OPML file from URL

	my $browser = LWP::UserAgent->new;
	my $page = $browser->get($vars->{url});
	&error($dbh,$query,"","Error: ", $page->status_line) unless $page->is_success;
	&error($dbh,$query,"","Error: ", "No content found in $vars->{url} ") unless $page->content;	
	my $opml = $page->content; my $opmlcategory;

						# Parse OPML file 

	while ($opml =~ m/<outline (.*?)>(.*?)<\/outline>/sig) {
		my $opmlitem = $1;
		if ($opmlitem =~ m/xmlUrl/) { &save_opml($dbh,$query,$opmlitem,"none"); }
		else { if ($opmlitem =~ m/title="(.*?)"/) { $opmlcategory = $1; } else { $opmlcategory = "none"; } }
		$vars->{msg} .= "<p><b>".$opmlcategory."</b><br>";
		my $inneropml = $2;
		while ($inneropml =~ m/<outline (.*?)\/>/sig) {
			my $saveopml = $1;
			&save_opml($dbh,$query,$saveopml,$opmlcategory);

		}
		$vars->{msg} .= "</p>";
	}
	


						# Print results page
	print "Content-type: text/html; charset=utf-8\n\n";
	$Site->{header} =~ s/<PAGE_TITLE>/Import OPML/mig;
	print qq|<p>[<a href="|.$Site->{st_cgi}.qq|admin.cgi">Back to Admin</a>]</p>|;
	print $Site->{header};
	print "<h2>Import OPML</h2>";
	print $vars->{msg};
	print $Site->{footer};

}


sub save_opml {

	my ($dbh,$query,$opml,$category) = @_;
	my $vars = $query->Vars;
	
						# Define Feed Vars
	my $feed = ();
	if ($opml =~ m/title="(.*?)"/i) { $feed->{feed_title} = $1; }
	if ($opml =~ m/xmlUrl="(.*?)"/i) { $feed->{feed_link} = $1; }
	if ($opml =~ m/htmlUrl="(.*?)"/i) { $feed->{feed_html} = $1; }
	$feed->{feed_status} = $vars->{feed_status} || "A";
	$feed->{feed_category} = $category;
	$feed->{feed_crdate} = time;
	$feed->{feed_creator} = $Person->{person_id};
	
						# Add new feeds to DB from OPML
	unless ($feed->{feed_title}) { $vars->{msg} .= "Feed rejected; no title.<br/>"; return; }
	unless ($feed->{feed_link}) { $vars->{msg} .= "Feed rejected; no URL.<br/>"; return; }
	if (&db_locate($dbh,"feed",{feed_link => $feed->{feed_link}})) { $vars->{msg} .= "Feed already exists.<br/>"; return; }
	my $feedid;
	$feedid = &db_insert($dbh,$query,"feed",$feed);
	if ($feedid) {
		$vars->{msg} .= "Inserted feed number $feedid: ".$feed->{feed_title} . "(". $feed->{feed_link} . ") Category: $category<br/>\n";
	} else { $vars->{msg} .= "Feed insert failed, don't know why.<br/>"; }

	return;

}







#--------------------------------------------------------------------------------
#
#
#                      Parsing Functions
#
#
#---------------------------------------------------------------------------------


# Parse iCal

sub parse_ical {

	my ($dbh,$feedstring,$feed,$mapping,$field_list,$field_value_pair,) = @_;
	unless ($mapping->{mapping_title}) { $mapping = &map_ical($dbh,$query,$feed->{feed_type}); }

	my $cdata = ""; my @recordslist;
	$feedstring =~ s/\s\n\s//g; # Repair split lines
	my @lines; my @lines = split /\n/,$feedstring; 
	my $event = ();
	foreach my $l (@lines) {

		my $last = chop($l);					# remove trailing line feed or garbarge char
    		if ($last =~ /a-zA-Z0-9/) { $l .= $last; }	# if it exists (it might not)



										# ignore tz definition info (redundant)
		if ($event->{tzdef} eq "yes") {
			if ($l =~ /END:VTIMEZONE/) { $event->{tzdef} = "no"; }
			next;
		} elsif ($l =~ /BEGIN:VTIMEZONE/) { 
			$event->{tzdef} = "yes"; next;

		} elsif ($event->{defined} eq "yes") {		# Processing event
			if ($l =~ /END:VEVENT/) {
				$event->{event_crdate} = time;
				$event->{event_creator} = $Person->{person_id} || 1;
				$event->{event_feedid} = $feed->{feed_id};
				$event->{event_feedname} = $feed->{feed_title};
				unless ($event->{event_link}) { $event->{event_link} = $feed->{feed_html}; }
				unless ($event->{event_link}) { $event->{event_link} = "none"; }
				unless ($event->{event_title}) { $event->{event_title} = $feed->{feed_title}; }
				unless ($event->{event_identifier}) { 
					$event->{event_identifier} = $feed->{feed_title} . " " . $event->{event_start}; 
				}

				if ($event->{event_start} > time) {			# We only save future events
					&save_item($dbh,$query,\%$event,$cdata,$feed,$mapping,$field_list,$field_value_pair,\@recordslist);
				}
				$event->{defined} = "no";
			} else {
				my $temp = "";
#if ($l =~ /LOCATION/) { print "LINE: $l <br>"; }
				my @eventarr = split ":",$l;
				my $key = shift @eventarr;
#if ($l =~ /LOCATION/) { print "Key: $key <br>"; }
				my $val = join ":",@eventarr;
#if ($l =~ /LOCATION/) { print "Val: $val <br>"; }
				if ($key =~ /^DTSTART/) { 
					$event->{event_icalstart} = $val;
					($event->{event_localtz},$event->{event_start}) = &ical_to_epoch($val,$feed->{feed_timezone}); 
				}  # Note, dates stored as epoch
				elsif ($key =~ /^DTEND/) { 
					$event->{event_icalend} = $val;
					($temp,$event->{event_finish}) = &ical_to_epoch($val,$feed->{feed_timezone});
				}
				elsif ($key =~ /^DTSTAMP/) { $event->{event_stamp} = $val; }
				elsif ($key =~ /^UID/) { $event->{event_uid} = $val; }
				elsif ($key =~ /^ATTENDEE/) { 
					if ($event->{event_attendee}) { $event->{event_attendee} .= "\n"; }
					$event->{event_attendee} .= $key . $val; 
				}
				elsif ($key =~ /^CLASS/) { $event->{event_type} = $val; }
				elsif ($key =~ /^LOCATION/) { 
					$val =~ s/To register for all DE webinars\\, visit://g;   # Because DE doesn't play nice 
#print "Location: $val <br>";
					if ($val =~ /^http|^https/) { $event->{event_link} = $val; $event->{event_location} = "Online"; }
					else { $event->{event_location} = $val; }
				}
				elsif ($key =~ /^CREATED/) { $event->{event_issued} = $val; }
				elsif ($key =~ /^LAST-MODIFIED/) { $event->{event_modified} = $val; }
				elsif ($key =~ /^SEQUENCE/) { $event->{event_sequence} = $val; }
				elsif ($key =~ /^STATUS/) { $event->{event_status} = $val; }
				elsif ($key =~ /^SUMMARY/) { $event->{event_title} = $val; }
				elsif ($key =~ /^DESCRIPTION/) { 
					$val =~ s/\\,/,/g;
					$val =~ s/\\n/<br>/g;
					$event->{event_description} = $val; 
				}
				elsif ($key =~ /^TRANSP/) { $event->{event_transp} = $val; }
				elsif ($key =~ /^RECURRENCE-ID/) { next; }
				elsif ($key =~ /^RRULE/) { next; }
				elsif ($key =~ /^EXDATE/) { next; }
				elsif ($key =~ /^CATEGORIES/) { 
					if ($event->{event_category}) { $event->{event_category}.=";"; }
					$event->{event_category} .= $val; }
				else { $vars->{msg} .= qq|<p class="red">iCal exception, not sure what to do with key $key </p>|; }
			}
		} elsif ($l =~ /BEGIN:VCALENDAR/) { 
			next; 
		} elsif ($l =~ /END:VCALENDAR/) {
			last;
		} else {
			if ($l =~ /BEGIN:VEVENT/) { 
				$event = ();
				$event->{defined} = "yes"; 
			} else {
				my ($fkey,$fval) = split ":",$l;
				if ($fkey =~ /^PRODID/) { $feed->{feed_prodid} = $fval; }
				elsif ($fkey =~ /^VERSION/) { $feed->{feed_version} = $fval; }
				elsif ($fkey =~ /^CALSCALE/) { $feed->{feed_calscale} = $fval; } 	
				elsif ($fkey =~ /^METHOD/) { $feed->{feed_method} = $fval; }		
				elsif ($fkey =~ /^X-WR-TIMEZONE/) { $feed->{feed_timezone} = $fval; }	
				elsif ($fkey =~ /^X-WR-CALDESC/) { $feed->{feed_description} = $fval; }	
				elsif ($fkey =~ /^X-WR-CALNAME/) { $feed->{feed_title} = $fval; }	
				else { $vars->{msg} .= qq|<p class="red">iCal exception, not sure what to do with key $fkey </p>|; }
			}
		}

	}

	&save_feed($dbh,$query,$feed);
	$vars->{msg} .= "Saved iCal feed $feed->{feed_title}<br>";

}



# Parse_Feed
# Because I can't stand to fight with Perl XML Modules Any More

# Receives input feed document as string
# Returns a Feed Hash
# with an array of post hashes


#------------------------------- Parse Feed -----------------------------
#
#   Main feed parsing function
#
#

sub parse_feed {


	my ($dbh,$feedstring,$feed,$mapping,$field_list,$field_value_pair) = @_;
	my @cdata; my @tags;




	# Remove all the CDATA stuff and store it, replacing with a simple token

	my $cdatacounter = 0; my $xxxx="CDATA(".$cdatacounter.")";
	$feedstring =~ s/\[/OPENBLOCK/g;	# Really annoying to have to do these first
	$feedstring =~ s/\]/CLOSEBLOCK/g;	# but Perl won't escape [ and ] properly
	while ($feedstring =~ s/<!OPENBLOCKCDATAOPENBLOCK(.*?)CLOSEBLOCKCLOSEBLOCK>/$xxxx/s) {
		$cdata[$cdatacounter] = $1;
		$cdatacounter++; $xxxx="CDATA(".$cdatacounter.")";
	}


	
	
#	$feedstring =~ s/<(.*?) (.*?)\/>/<$1 $2><\/$1>/g;
	
	
	$vars->{msg} .= "<p>Parsing $feed->{feed_title} ($feed->{feed_id})</p>";		# Initialize objects that will be needed
	my $author = gRSShopper::Record->new;							# Feed or item author	
	my $item; my $itemcount=0;								# Individual item or entry
	my $media = gRSShopper::Record->new;							# Enclosed or referenced media
	my @recordslist;									# Array we use to store records associated
												# with the current item
	my $con ="";										# Variable we'll use to pass the content
												# from the open to close line 
	my $linecount = 0;									# Line counter
 	my $attributes = ();
	

	
	my @lines = split "<",$feedstring; my @stack;						# Split the entire feed into a series of lines
												# one element open or closefor each line, and

	my @object_stack;


	foreach my $l (@lines) {								# For each line

 		if ($linecount == 1) {								# First line, make sure we don't have a feed error
#			$vars->{msg} .= "First line: $l <br>";

			return "feed error" unless ($l =~ /\?xml/i || $l =~ /rss/i);		#     which would be indicated if the first line isn't xml
												#     (note Google alert starts with <rss...> )
		}
		$linecount++;



		my ($element,$content) = split ">",$l;

		my @elementitems = split " ",$element;					# Carve off attributes to find element
		my $tag = shift @elementitems;

		
		if ($tag =~ s/^\///) {								# If it's a close element tag
			
			if ($vars->{content} eq "on" && $tag !~ /(^content$|^description$)/) {				# If we are inside a content tag
													# and not at the end of that tag
				$con .= "<".$l;								#     tack on to the content 
			
			} else {									# Otherwise
													# Close Element
				&element_close($dbh,\@object_stack,\@stack,\@cdata,$feed,$item,$author,$media,$con,$mapping,$field_list,$field_value_pair,\@recordslist);
				shift @stack; $con="";
				shift @object_stack;
			}

		} else {									# if it's an open element tag
	

			
			if ($vars->{content} eq "on") {							# If we are inside a content tag
				$con .= "<".$l;								#     tack on to the content 
				
				
				
			} else {									# Otherwise, open a new tag
			
				unshift @stack,$tag;
				$con = $content;
			
				if ($tag =~ /(^feed$|^channel$)/i) { 
					
					unshift @object_stack,$feed;
					
				} else {
					my $feeditem = gRSShopper::Record->new("tag",$tag);
					unshift @object_stack,$feeditem;
				}
				
				

print "Object type: ".$object_stack[0]->{type}." <br>";
print "Object tag: ".$object_stack[0]->{tag}." <p>";
print "Object id: ".$object_stack[0]->{$object_stack[0]->{type}."_id"}." <p>";	

				
				#my $feeditem = gRSShopper::Record->new("tag",$tag);
				#$feeditem->{type}="test";
				#unshift @object_stack,$feeditem;
				
				if ($stack[0] =~ /(^item$|^entry$)/i) { 
					$itemcount++; $vars->{msg} .= "\n\n<h2>Processing Entry $itemcount</h2> \n\n";
					$item = gRSShopper::Record->new("count",$itemcount);
				} else {
					&element_open(\@stack,\@cdata,$feed,$item,$author,$media,\@recordslist,$linecount); 
				}
			
				&process_attributes($dbh,$query,$tag,\@elementitems,\@stack,\@cdata,$attributes,$feed,$item,\@recordslist,$author,$media,$l);
	
				if ($element =~ /(.*?)\/$/) {						# Single-line element, close here
				
					shift @object_stack;
					shift @stack; $con="";
					if ($element =~ /(description|content)/) { $vars->{content} = "off"; } # In case of <description />
				}
			}
		}
	}
	
	
	foreach my $link (@{$feed->{links}}) {
		print $link->{link_title}."<br>";
	}
}


#------------------------  Process Attributes  --------------------
#


sub process_attributes {

	my ($dbh,$query,$element,$elementitems,$stack,$cdata,$attributes,$feed,$item,$recordslist,$author,$media,$l) = @_;
	my $vars = $query->Vars;
	
	return if ($vars->{content} eq "on");					# Do not process contents (these are scraped instead)
	
	# $vars->{msg} .= "Processing attributes...<br/>";
	my $att = (); my $del;

	my $attline = join " ",@$elementitems;					# Create attribute line
	return unless ($attline);							


	$attline =~ s/\/$//;								# Carve closing /
	if ($attline =~ /=("|')/) { $del = $1; }					# Find delimeter ' or "
	my @attitems = split /$del /,$attline;					# Split at the delimeter

	foreach my $ai (@attitems) {							# For each attribute				
		my ($attkey,$attval) = split/=$del/,$ai;				# Split at the delimiter
		$attval =~ s/$del$//;							# Carve trailing delimeter
		$att->{$attkey} = $attval;						# Store values
	}

	
												# Process attributes for elements:

	if ($element =~ /^link$/i || $element =~ /^atom:link$/i) {						# Link

		if ($att->{rel} =~ /^self$/i) { 
			if ($stack->[1] =~ /(^channel$|^feed$)/i) {
				# $feed->{feed_link} = $att->{href};  # Don't update feed link
			} elsif ($stack->[1] =~ /(^item$|^entry$)/i){
				$item->{link_self} = $att->{href};
			}
		} elsif ($att->{rel} =~ /^alternate$/i) { 
			if ($stack->[1] =~ /(^channel$|^feed$)/i) {
				$feed->{feed_html} = $att->{href};
			} elsif ($stack->[1] =~ /(^item$|^entry$)/i){
				$item->{link_link} = $att->{href};
			}
		} elsif ($att->{rel} =~ /^replies$/i) { 
			if ($stack->[1] =~ /(^item$|^entry$)/i){
				if ($att->{type} =~ /text\/html/i) {
					$item->{link_commentURL} = $att->{href};
				} elsif ($att->{type} =~ /atom|rss/i) {
					$item->{link_commentFeed} = $att->{href};
				}
			}
		} elsif ($att->{rel} =~ /^hub$/i) { $vars->{msg} .= "D <br>";
	
			if ($stack->[1] =~ /(^channel$|^feed$)/i){
				$feed->{feed_hub} = $att->{href};
			}
			
				
		} elsif ($att->{rel} =~ /^enclosure$/i) {				# enclosure in Atom
			
												# Initialize Media Object, as appropriate
			$media = gRSShopper::Record->new;     						# Set values                          
			$media->{media_url} = $att->{href};
			$media->{media_size} = $att->{length};
			$media->{media_mimetype} = $att->{type};
			my @mtitlearr = split "/",$att->{href};
			$media->{media_title} = pop @mtitlearr;
			$media->{type} = "media";
		
$vars->{msg} .= "<p><b>Processing Enclosure</b><br>";
$vars->{msg} .=  " - Title: $media->{media_title} <br> ";
$vars->{msg} .=  " - URL: $media->{media_url}  </p>";

		#       push @{$item->{records}},$media;
			push @$recordslist,$media;							# Add enclosure to associated records list
			$item->{media} = $media;
			
		} elsif ($att->{type} =~ "image") {					# Twitter Images
			$item->{link_thumbnail} = $att->{href};
			
		} elsif ($att->{href}) {						# PHPBB style links
			
			$item->{link_link} = $att->{href};
		}
	
	
		
	} elsif ($element =~ /^atom10:link$/i) {						# Atom Links	
		if ($att->{rel} eq "self") {							# rel = self
			# do nothing; we already know who we are
		} elsif ($att->{rel} eq "hub") {						# rel = hub
			$feed->{feed_hub} = $att->{href};
		} else {
			$vars->{msg} .= qq|<p class="red">Exception, not sure what to do with atom10:link rel = $att->{rel} <br>\n </p>|;
		}
		
	} elsif ($element =~ /^cloud$/i) {									# Cloud
		if ($stack->[1] =~ /(^channel$|^feed$)/i){
			$feed->{feed_cloudDomain} = $att->{domain};
			$feed->{feed_cloudPort} = $att->{port};
			$feed->{feed_cloudPath} = $att->{path};
			$feed->{feed_cloudRegister} = $att->{registerProcedure};
			$feed->{feed_cloudProtocol} = $att->{protocol};
		}

	} elsif ($element =~ /^content$/i) {
		# $item->{link_type} = $att->{type};

	} elsif ($element =~ /^category$/i) {									# Category, Blogger style

		if ($item->{link_category} && $att->{term}) { $item->{link_category} .= ";" }
		$item->{link_category} = $att->{term};
		if ($item->{link_categoryScheme} && $att->{scheme}) { $item->{link_categoryScheme} .= ";"; }
		$item->{link_categoryScheme} = $att->{scheme}; 
		
	} elsif ($element =~ /^enclosure$/i) {									# Enclosure

		# Initialize Media Object, as appropriate


		$media = gRSShopper::Record->new;     						# Set values                          
		$media->{media_url} = $att->{url};
		$media->{media_size} = $att->{length};
		$media->{media_mimetype} = $att->{type};
		my @mtitlearr = split "/",$att->{url};
		$media->{media_title} = pop @mtitlearr;
		$media->{type} = "media";
		
$vars->{msg} .= "<p><b>Processing Enclosure</b><br>";
$vars->{msg} .=  " - Title: $media->{media_title} <br> ";
$vars->{msg} .=  " - URL: $media->{media_url}  </p>";

        #       push @{$item->{records}},$media;
		push @$recordslist,$media;							# Add enclosure to associated records list
		$item->{media} = $media;
		
	} elsif ($element =~ /^entry$/i) {								

		$item->{link_gdetag} = $att->{'gd:etag'};							
			
	} elsif ($element =~ /^feedburner:info$/i) {								

		$feed->{feed_feedburnerurl} = $att->{uri};


	} elsif ($element =~ /^generator$/i) {								# Feed Generator

		$feed->{feed_genver} = $att->{version};
		$feed->{feed_genurl} = $att->{url};
		
	} elsif ($element =~ /^itunes:category$/i) {							# itunes: category
		if ($feed->{feed_topic}) { $feed->{feed_topic} .= ";"; }				#  goes into feed_topic
		if ($feed->{current_cat}) {
			$feed->{feed_topic} .= $feed->{current_cat} . "/" . $att->{text};
		} else {
			$feed->{current_cat} = $att->{text};
			$feed->{feed_topic} .= $feed->{current_cat};
		} 
$vars->{msg} .= "Category string: $feed->{feed_topic} <br>";	
		
	} elsif ($element =~ /^itunes:image$/i) {							# itunes: image		
		unless ($feed->{feed_imgURL}) { $feed->{feed_imgURL} = $att->{href}; }

		
	} elsif ($element =~ /^gd:extendedProperty$/i) {						# Google Docs
		if ($att->{name} eq "OpenSocialUserId") {
			$item->{author_opensocialuserid} = $att->{value};
		}  else {
			$vars->{msg} .= qq|<p class="red">Google Docs Attribute $att->{name} unknown in $element : <br/>\n|;				
		}
	} elsif ($element =~ /^media:content$/i) {							# Media
		$media->{media_url} = $att->{url};
		$media->{media_type} = $att->{medium};
$vars->{msg} .= " - URL is $media->{media_url}<br/> - Type is $media->{media_type}<br/>";	

	} elsif ($element =~ /^media:credit$/i) {
		$media->{current_role} = $att->{role}; # Save for element_close
			
	} elsif ($element =~ /^media:thumbnail$/i) {
		$media->{media_thurl} = $att->{url};
		$media->{media_thheight} = $att->{height};
		$media->{media_thwidth} = $att->{width};


													# Ignoring these...


	} elsif ($element =~ /^blogChannel:blogRoll$/i) {
		# doing nothing;
		# can scan for xmlns attributes here
													
	} elsif ($element =~ /^app:edited$/i) {
		# doing nothing;
		# can scan for xmlns attributes here	

	} elsif ($element =~ /^dc:creator$/i) {
		# doing nothing;
		# can scan for xmlns attributes here

	} elsif ($element =~ /^dc:publisher$/i) {
		# doing nothing;
		# can scan for xmlns attributes here
				
	} elsif ($element =~ /^dc:title$/i) {
		# doing nothing;
		# can scan for xmlns attributes here	
				
	} elsif ($element =~ /^feedburner:feedflare$/i) {
		# doing nothing;
		# can scan for subscription link attributes here
		
	} elsif ($element =~ /^feedburner:emailServiceId$/i) {
		# doing nothing;
		# can scan for xmlns attributes here
		
	} elsif ($element =~ /^feedburner:feedburnerHostname$/i) {
		# doing nothing;
		# can scan for xmlns attributes here		

	} elsif ($element =~ /^guid$/i) {
		# doing nothing;
		# can scan for ispermalink attributes here
		
	} elsif ($element =~ /^geo:lat$/i) {
		# doing nothing;
		# can scan for xmlns attributes here	
				
	} elsif ($element =~ /^geo:long$/i) {
		# doing nothing;
		# can scan for xmlns attributes here			
		
	} elsif ($element =~ /^media:category$/i) {
		# doing nothing;
		# can scan for xmlns attributes here

	} elsif ($element =~ /^openSearch/i) {
		# doing nothing;
		# namespace for various opensearch values can be found here

	} elsif ($element =~ /^pingback:server/i) {
		# doing nothing;
		# namespace for various opensearch values can be found here
		
	} elsif ($element =~ /^pingback:target/i) {
		# doing nothing;
		# namespace for various opensearch values can be found here		
		
	} elsif ($element =~ /^slash:comments$/i) {
		# doing nothing;
		# can scan for xmlns attributes here		
		
	} elsif ($element =~ /^thespringbox:skin$/i) {
		# doing nothing;
		# can scan for xmlns attributes here	
		
	} elsif ($element =~ /^sy:updatePeriod$/i) {
		# doing nothing;
		# can scan for xmlns attributes here
		
	} elsif ($element =~ /^sy:updateFrequency$/i) {
		# doing nothing;
		# can scan for xmlns attributes here				
		
	} elsif ($element =~ /^thr:total$/i) {
		# doing nothing;
		# can scan for xmlns attributes here		
		
	} elsif ($element =~ /^title$|^subtitle$|^media:title$|^summary$/i) {
		# doing nothing;
		# can scan for type attributes here (don't see why title, etc has a type, but there you go)

	} elsif ($element =~ /^trackback:ping$/i) {
		# doing nothing;
		# can scan for xmlns attributes here		
		
	} elsif ($element =~ /^rss$|^feed$/i) {
		# doing nothing;
		# can scan for xmlns, rss and atom version attributes here

	} elsif ($element =~ /^wfw:comment$/i) {
		# doing nothing;
		# can scan for xmlns, rss and atom version attributes here
		
	} elsif ($element =~ /^wfw:commentRss$/i) {
		# doing nothing;
		# can scan for xmlns, rss and atom version attributes here		

		
	} elsif ($element =~ /^\?xml/i) {
		# doing nothing;
		# can scan for xml ver, encoding attributes here
		
#exit;	
	} else {
		$vars->{msg} .= qq|<p class="red">Attributes unknown in $element : <br/>\n|;
 		while (my ($attx,$atty) = each %$att) { $vars->{msg} .= "   $attx = $atty <br/>\n"; }
 		$vars->{msg} .= "</p>\n";
	}

}

#-------------------------- Element Open -------------------------------


sub element_open {


	my ($stack,$cdata,$feed,$item,$author,$media,$recordslist,$icount) = @_;
	
	
	
# $vars->{msg} .= " > 2 $stack->[2]  > 1 $stack->[1]  > 0 $stack->[0] <br>";	

	if ($stack->[0] =~ /(^feed$|^channel$)/i) {
 
		$vars->{msg} .= "\n\n<h2>Processing Feed</h2> \n\n";
#		while (my($ix,$iy) = each %$feed) { $feed->{$ix} = ""; }					# Initialize feed
	} elsif ($stack->[0] =~ /(^item$|^entry$)/i) { 
		$vars->{msg} .= "\n\n<h2>Processing Entry</h2> \n\n";

		$item = gRSShopper::Record->new;
		while (my($ix,$iy) = each %$item) { $item->{$ix} = ""; }					# Initialize item
		
		$item->{count} = $icount; $icount++;		
# print "Init item $item->{count}<br>";

	} elsif ($stack->[0] =~ /(^content$|^description$)/i) { 						# Initialize content
		$vars->{content} = "on";
		
	} elsif ($stack->[0] =~ /(^author$|^dc:creator$)/i) { 
#		$vars->{msg} .= "\n\nProcessing Author \n\n";
		$author = gRSShopper::Record->new;
		while (my($ix,$iy) = each %$author) { $author->{$ix} = ""; }					# Initialize author
	} elsif ($stack->[0] =~ /(^media$|^media:content$)/i) { 
		$vars->{msg} .= "<p>\n\nProcessing Media <br/>\n\n";
		$media = gRSShopper::Record->new;
		while (my($ix,$iy) = each %$media) { $media->{$ix} = ""; }					# Initialize media


	}



}

#--------------------- Element Close  -----------------------------------------


sub element_close {

	my ($dbh,$object_stack,$stack,$cdata,$feed,$item,$author,$media,$con,$mapping,$field_list,$field_value_pair,$recordslist) = @_;


	$con =~ s/&gt;/>/sig;  # Unescape HTML content
	$con =~ s/&lt;/</sig;
	$con =~ s/&amp;/&/sig;	
 
	my $parent = $object_stack->[1];
	my $child = $object_stack->[0];
	my $ftag = $parent->{type} . ":" . $child->{tag};
 
print "Parent type $parent->{type}"; 
print "Parent id $parent->{feed_id}"; 

	for ($ftag) {									# Tag
	
	
		# Child Objects
		
		
		/:item$/ && do { push @{$parent->{links}},$child; last;	};	

		/:author$/ && do { push @{$parent->{authors}},$child; last;	};		
		
		
		
		
		# Elements


		/:atom:updated$/ && do {		$parent->set_value("updated",$con); 		last;	};
		
		/:atom:id$/ && do { 			$parent->set_value("blogID",$con);  		last;	};
		
		/:app:edited$/ && do { 			$parent->set_value("updated",$con);		last;	};		
		
		/:blogChannel:blogRoll$/ && do {	$parent->set_value("blogroll",$con);  		last;	};

		/:category$/ && do { 			$parent->extend_list("category",$con); 		last;   };
		
		/:comments$/ && do { 		$parent->set_value("commentURL",$con); 		last;	};			
		
		/:content$/ && do 			$parent->set_value("content",$con); 	
							$vars->{content} = "off";			last;	};	
							
		/:content:encoded$/ && do 		$parent->set_value("content",$con); 	
							$vars->{content} = "off";			last;	};								
			
		/:copyright$/ && do { 			$parent->extend_list("copyright",$con); 	last;   };
		
		/:creativeCommons:license$/ && do { 	$parent->extend_list("copyright",$con);		last;	};		
		
		/:description$/ && do {			$parent->set_value("description",$con); 	
							$vars->{content} = "off";			last;	};
							
		/:dc:creator$/ && do { 			$parent->extend_list("authorname",$con);	last;	};							
	
		/:dc:date$/ && do { 			$parent->do_not_replace("published",$con);	last;	};
		
		/:dc:publisher$/ && do { 		$parent->do_not_replace("publisher",$con);	last;	};		
		
		/:dc:subject$/ && do { 			$parent->extend_list("subject",$con); 		last;   };				
		
		/:dc:title$/ && do { 			$parent->do_not_replace("title",$con);		last;	};			
		
		/:docs$/ && do { 			$parent->set_value("docs",$con);		last;	};	
		
		/:feedburner:browserFriendly$/ && do { 							last;	};	
		
		/:feedburner:emailServiceId$/ && do { 	$parent->set_value("feedburnerid",$con); 	last;	};
		
		/:feedburner:feedburnerHostname$/ && do{$parent->set_value("feedburnerhost",$con); 	last;	};

		/:feedburner:origEnclosureLink$/ && do {$parent->set_value("origEnclosureLink",$con); 	last;	};
				
		/:feedburner:origLink$/ && do { 	$parent->set_value("link",$con); 		last;	};				
	
		/:generator$/ && do { 			$parent->set_value("genname",$con); 		last;	};
		
		/:geo:lat$/ && do { 			$parent->set_value("geo_lat",$con); 		last;	};	

		/:geo:long$/ && do { 			$parent->set_value("geo_long",$con); 		last;	};
		
		/:georss:point$/ && do { 		$parent->set_value("geo","point:".$con); 	last;	};		
		
		/:guid$/ && do { 			$parent->set_value("guid",$con); 		last;	};					

		/:icon$/ && do { 			$parent->set_value("imgURL",$con); 		last;	};			
	
		/:id$/ && do { 				$parent->set_value("blogID",$con); 		last;	};

		/:itunes:author$/ && do { 		$parent->extend_list("authorname",$con);	last;	};

		/:itunes:block$/ && do { 								last;	};   
		
		/:itunes:category$/ && do { 		$parent->extend_list("category",$con); 		last;   };
		
		/:itunes:duration$/ && do {		$parent->set_value("duration",$con); 		last;	};				
			
		/:itunes:explicit$/ && do {		$parent->set_value("explicit",$con); 		last;	};												

		/:itunes:image$/ && do { 		$parent->do_not_replace("imgURL",$con);		last;	};
		
		/:itunes:keywords$/ && do { 		$parent->extend_list("topic",$con); 		last;   };	

		/:itunes:subtitle$/ && do { 		$parent->do_not_replace("subtitle",$con);	last;	};
		
		/:itunes:summary$/ && do { 		$parent->do_not_replace("description",$con);	last;	};
			
		/:id$/ && do { 				$parent->set_value("imgURL",$con); 		last;	};
		
		/:issued$/ && do { 			$parent->set_value("published",$con); 		last;	};
		
		/:link$/ && do { 			unless ($parent->{type} eq "feed") { 
							$parent->set_value("link",$con); } 		last;	};
							
		/:language$/ && do { 			$parent->set_value("language",$con); 		last;	};							
		
		
		/:lastBuildDate$/ && do { 		$parent->set_value("modified",$con); 		last;	};	

		/:managingEditor$/ && do { 		$parent->set_value("managingEditor",$con); 	last;	};	
				
		/:media:content$/ && do { 		$parent->set_value("media_content",$con); 	last;   };
						
		/:media:copyright$/ && do { 		$parent->extend_list("copyright",$con); 	last;   };			

		/:media:category$/ && do { 		$parent->extend_list("category",$con); 		last;   };

		/:media:keywords$/ && do { 		$parent->extend_list("topic",$con); 		last;   };
			
		/:media:credits$/ && do { 		$parent->do_not_replace("author",$con);		last;	};	

		/:media:rating$/ && do { 		$parent->set_value("rating",$con); 		last;	};
		
		/:modified$/ && do { 			$parent->set_value("updated",$con);		last;	};		

		/:openSearch:totalResults$/ && do { 	$parent->set_value("OStotalResults",$con); 	last;	};

		/:openSearch:startIndex$/ && do { 	$parent->set_value("OSstartIndex",$con); 	last;	};

		/:openSearch:itemsPerPage$/ && do { 	$parent->set_value("OSitemsPerPage",$con); 	last;	};

		/:pingback:server$/ && do { 		$parent->set_value("pingserver",$con); 		last;	};
		
		/:pingback:target$/ && do { 		$parent->set_value("pingtarget",$con); 		last;	};				
		
		/:pubDate$/ && do { 			$parent->set_value("published",$con); 		last;	};									
			
		/:published$/ && do { 			$parent->set_value("published",$con); 		last;	};
		
		/:publisher$/ && do {			$parent->set_value("publisher",$con); 		last;	};				
						
		/:rights$/ && do { 			$parent->extend_list("copyright",$con); 	last;   };
		
		/:slash:comments$/ && do { 		$parent->set_value("commentURL",$con); 		last;	};		
		
		/:summary$/ && do { 			$parent->do_not_replace("description",$con);	last;	};		
				
		/:subtitle$/ && do { 			$parent->set_value("subtitle",$con); 		last;	};		

		/:sy:updatePeriod$/ && do { 		$parent->set_value("updatePeriod",$con); 	last;	};		

		/:sy:updateFrequency$/ && do { 		$parent->set_value("updateFrequency",$con); 	last;	};
		
		/:sy:updateBase$/ && do { 		$parent->set_value("updateBase",$con); 		last;	};

		/:tagline$/ && do { 			$parent->set_value("tagline",$con); 		last;	};
		
		/:thr:total$/ && do { 			$parent->set_value("thrTotal",$con); 		last;	};		
				
		/:thr:commentURL$/ && do { 		$parent->set_value("commentURL",$con); 		last;	};
		
		/:title$/ && do { 			$parent->set_value("title",$con); 		last;	};
		
		/:trackback:ping$/ && do { 		$parent->set_value("pingtrackback",$con); 	last;	};		

		/:ttl$/ && do { 			$parent->set_value("ttl",$con); 		last;	};
		
		/:updated$/ && do { 			$parent->set_value("updated",$con);		last;	};	
		
		/:webMaster$/ && do { 			$parent->set_value("webMaster",$con); 		last;	};			

		/:wfw:comment$/ && do { 		$parent->extend_list("comment",$con); 		last;	};	
				
		/:wfw:commentRSS$/ && do { 		$parent->set_value("commentRSS",$con); 		last;	};	

		/:wfw:comments$/ && do { 		$parent->set_value("commentURL",$con); 		last;	};		

	}

	

  
	print "<h2>Object Stack report:</h2>";
	print "Parent type: ".$parent->{type}."<p>";
	print "Child tag: ".$child->{tag}."<p>";
	

	if ($stack->[0] =~ /(^content$|^description$)/i) { 						# Close content	
		$vars->{content} = "off";
		
	}
	
	return if ($vars->{content} eq "on");								# Do not process contents 
													# (these are scraped instead)
	
	if ($stack->[1] =~ /(^feed$|^channel$)/i) {							# Feed or Channel



		if ($stack->[0] =~ /^author$/i) { 							# author

			if ($con) { $feed->{feed_authorname} = $con; } 					#    - rss
			else {										#    - atom
				$feed->{feed_authorname} = $author->{name};
				$feed->{feed_authorurl} = $author->{uri};
				$feed->{feed_authoremail} = $author->{email};

			}
		}	



																	
		
		elsif ($stack->[0] =~ /^entry$/i) {  }							# entry		
		elsif ($stack->[0] =~ /^item$/i) {  }							# item
		elsif ($stack->[0] =~ /^items$/i) {  }							# items, from old RSS 1.0
		elsif ($stack->[0] =~ /^image$/i) {  }							# image
		elsif ($stack->[0] =~ /^itunes:owner$/i) {  }						# itunes: owner
		elsif ($stack->[0] =~ /^feedburner:feedflare$/i) {  }					# feedflare
		elsif ($stack->[0] =~ /^thespringbox:skin$/i) {  }					# thespringbox:skin		
		elsif ($stack->[0] =~ /^!--$/i) {  }							# comment

		else { $vars->{msg} .= qq|<p class="red">Exception 1291, 
			not sure what to do with $stack->[1] -> $stack->[0] = $con \n</p>|; }
																	



	
		
	} elsif ( $stack->[1] =~ /(^entry$|^item$)/i ) {						# Item or Entry
		
# $vars->{msg} .= "Item > $stack->[0] <br>";
		
		if ($stack->[0] =~ /^itunes/) {								# If iTunes element detected, then
			if ($item->{media}->{media_url}) {						# If necessary
				#$vars->{msg} .= "<p><b>Found Initialized media object in $stack->[0]</b></p>";			
			} else {
				$media = gRSShopper::Record->new;					# Initialize media object
				$item->{media} = $media;
				#$vars->{msg} .= "<p><b>Initialized media object in $stack->[0]</b></p>";				
			}				
		}		
		
		# Note that atom links are processed under process_attributes()
#		$vars->{msg} .= "Item > $stack->[0] <br>";
	
	
	
	
													# Core
													


		elsif ($stack->[0] =~ /^content$/i) { 							# content
			if ($item->{link_type} =~ /^html$/i) {
				$con =~ s/&gt;/>/sig;  # Unescape HTML content
				$con =~ s/&lt;/</sig;
			}	
			$item->{link_content} = $con; 
			
		} 
		elsif ($stack->[0] =~ /^content:encoded$/i) { $item->{link_content} = $con; }		# content:encoded
		elsif ($stack->[0] =~ /^description$/i) { $item->{link_description} = $con; }		# description		
		elsif ($stack->[0] =~ /^id$/i) { $item->{link_guid} = $con; }				# guid 
		elsif ($stack->[0] =~ /^guid$/i) { $item->{link_guid} = $con; }				# guid (RSS)		
		elsif ($stack->[0] =~ /^issued$/i) { $item->{link_issued} = $con; }			# issued
		elsif ($stack->[0] =~ /^published$/i) { $item->{link_issued} = $con; }			# issued
		elsif ($stack->[0] =~ /^pubDate$/i) { $item->{link_issued} = $con; }			# issued	
			
		elsif ($stack->[0] =~ /^link$/i) { if ($con) { $item->{link_link} = $con; } }		# link (RSS)		
		elsif ($stack->[0] =~ /^modified$/i) { $item->{link_modified} = $con; }			# modified
		elsif ($stack->[0] =~ /^updated$/i) { $item->{link_modified} = $con; }			# modified
		
		elsif ($stack->[0] =~ /^summary$/i) { $item->{link_description} = $con; }		# summary
	
		elsif ($stack->[0] =~ /^title$/i) { $item->{link_title} = $con; }			# title		
		


													# App
		elsif ($stack->[0] =~ /^app:edited$/i) { $item->{link_modified} = $con; }		# app:edited
													
													

													# Atom
													
		elsif ($stack->[0] =~ /^atom:updated$/i) { $item->{link_modified} =  $con; } 		# Atom: updated

		

		
		elsif ($stack->[0] =~ /^author$/i) { 							# Author
			
			# Author data will have been stored in an $author object
			my $listflag=""; if ($item->{link_author}) { $listflag=";"; } 	
			$author = &save_author($dbh,$query,$author,$feed,$item);			#   - find author ID	
		
			if ($author) {
				if ($listflag) {
					$item->{link_authorname} .= $listflag . $author->{author_name};
					$item->{link_author} .= $listflag .$author->{author_id};
					$item->{link_authorurl} .= $listflag .$author->{author_link};	
				} else {
					$item->{link_authorname} = $author->{author_name};
					$item->{link_author} = $author->{author_id};
					$item->{link_authorurl} = $author->{author_link};					
				}	
				$author->{type} = "author";  $author->{source} = "author tag";
				push @$recordslist,$author;		
			}


		}		
		
		elsif ($stack->[0] =~ /^creativeCommons:license$/i) { 					# creativeCommons:license
			$item->{link_copyright} = $con; 
			unless ($feed->{feed_copyright}) {  # trickle up copyright
				$feed->{feed_copyright} = $item->{link_copyright};  
			}
		}					
		

		
		
													# Dublin Core

		elsif ($stack->[0] =~ /^dc:date$/i) { $item->{link_issued} = $con; }			# dc:date
		elsif ($stack->[0] =~ /^dc:creator$/i) {  						# dc:creator 	
		
			# Item author information could be a list, delimited by ;
			my $listflag=""; if ($item->{link_author}) { $listflag=";"; } 			
		
			my $dcauthor = gRSShopper::Record->new;
			$dcauthor->{author_name} = $con;
			$dcauthor = &save_author($dbh,$query,$dcauthor,$feed,$item);			#   - find author ID	
		
			if ($dcauthor) {
				if ($listflag) {
					$item->{link_authorname} .= $listflag . $dcauthor->{author_name};
					$item->{link_author} .= $listflag .$dcauthor->{author_id};
					$item->{link_authorurl} .= $listflag .$dcauthor->{author_link};	
				} else {
					$item->{link_authorname} = $dcauthor->{author_name};
					$item->{link_author} = $dcauthor->{author_id};
					$item->{link_authorurl} = $dcauthor->{author_link};					
				}	
				$dcauthor->{type} = "author";  $author->{source} = "dc:creator tag";
				push @$recordslist,$dcauthor;			
			}
		
		} 
		
		
		elsif ($stack->[0] =~ /^dc:subject$/i) {  						# dc:subject - could be list
			if ($item->{link_subject}) { $item->{link_subject} .= ";"; }
			$item->{link_subject} .= $con;
		}
		elsif ($stack->[0] =~ /^dc:publisher$/i) { $item->{link_publisher} = $con; }		# dc:publisher
			
				
		
		
				
													# Feedburner
													
		elsif ($stack->[0] =~ /^feedburner:origLink$/i) { 					# Feedburner: original link 
			$item->{link_feedburner} = $item->{link_link};
			$item->{link_link} = $con; 
		}
		elsif ($stack->[0] =~ /^feedburner:origEnclosureLink$/i) { 				# feedburner:origEnclosureLink
			$item->{link_origEnclosureLink} = $con; 
		}		
		
		elsif ($stack->[0] =~ /^georss:point$/i) { 						# geoRSS:point
			$item->{link_geo} = "point:".$con; 
		}
				
				
													# iTunes
		elsif ($stack->[0] =~ /^itunes:author$/i) {  						# itunes: author 	

			my $itauthor = gRSShopper::Record->new; 
			$itauthor->{author_name} = $con;
			$itauthor->{type} = "author"; 
			$itauthor->{source} = "itunes:author tag";
								
			$itauthor = &save_author($dbh,$query,$itauthor,$feed,$item);			#   - find author ID


			push @$recordslist,$itauthor;							#    - associate author with link
			if ($item->{link_authorname}) { $item->{link_authorname} .= ";"; } 
			$item->{link_authorname} = $con; 
	
													#    - associate author with media
			$media->{media_authorname} = $itauthor->{author_name};
			$media->{media_author} = $itauthor->{author_id};
			
		} 	
		
		elsif ($stack->[0] =~ /^itunes:block$/i) { $item->{media}->{media_block} = $con; }			# itunes: block
		elsif ($stack->[0] =~ /^itunes:duration$/i) { $item->{media}->{media_duration} = $con; }		# itunes: duration												
		elsif ($stack->[0] =~ /^itunes:explicit$/i) { $item->{media}->{media_explicit} = $con; }		# itunes: explicit
		elsif ($stack->[0] =~ /^itunes:keywords$/i) { $item->{media}->{media_keywords} = $con; }		# itunes: keywords		
		elsif ($stack->[0] =~ /^itunes:subtitle$/i) { $item->{media}->{media_subtitle} = $con; }		# itunes: subtitle
		elsif ($stack->[0] =~ /^itunes:summary$/i) { $item->{media}->{media_description} = $con; }		# itunes: summary
		
													
				
				
													# Media
		elsif ($stack->[0] =~ /^media:content$/i) {	
			
			# Media data will have been stored in a $media object					
			# $vars->{msg} .= "Processing media<br>";
			# while (my($mx,$my) = each %$media) { $vars->{msg} .= "* $mx = $my <br>"; }
			$media->{type} = "media";							# Media: content
			push @$recordslist,$media;
			
		}
		
													# Pingback
		
		elsif ($stack->[0] =~ /^pingback:server$/i) { $item->{link_pingserver} = $con; }	# pingback:server
		elsif ($stack->[0] =~ /^pingback:target$/i) { $item->{link_pingtarget} = $con; }	# pingback:target			 
				
		
													# Threads
													
		elsif ($stack->[0] =~ /^thr:total$/i) { $item->{link_thrTotal} = $con; }		# thr: total 
		elsif ($stack->[0] =~ /^thr:total$/i) { $item->{link_commentURL} = $con; }		# thr: comments
		elsif ($stack->[0] =~ /^slash:comments$/i) { $item->{link_commentURL} = $con; }		# slash: comments
		elsif ($stack->[0] =~ /^comments$/i) { $item->{link_commentURL} = $con; }		# comments
		

													# WFW

		elsif ($stack->[0] =~ /^wfw:comment$/i) { $item->{link_comment} = $con; }		# wfw: comment API 		
		elsif ($stack->[0] =~ /^wfw:comments$/i) { $item->{link_comments} = $con; }		# wfw: number of comments 	
		elsif ($stack->[0] =~ /^wfw:commentRss$/i) { $item->{link_commentRSS} = $con; }		# wfw: comments Feed


													# Trackback

		elsif ($stack->[0] =~ /^trackback:ping$/i) { $item->{link_pingtrackback} = $con; }	# trackback:ping


		else { $vars->{msg} .= qq|<p class="red">Exception 1420 
			Link, not sure what to do with $stack->[1] -> $stack->[0] = $con</p>\n|; }

	}  elsif ( $stack->[2] =~ /(^feed$|^channel$)/i) {					
	
		if ($stack->[1] =~ /(^image$)/i){							# Image
			if ($stack->[0] =~ /^url$/i) { $feed->{feed_imgURL} = $con; }				# image url
			elsif ($stack->[0] =~ /^title$/i) { $feed->{feed_imgTitle} = $con; }			# image title
			elsif ($stack->[0] =~ /^link$/i) { $feed->{feed_imgLink} = $con; }			# image link
			elsif ($stack->[0] =~ /^width$/i) { $feed->{feed_imgwidth} = $con; }			# image width
			elsif ($stack->[0] =~ /^height$/i) { $feed->{feed_imgheight} = $con; }			# image height
			elsif ($stack->[0] =~ /^description$/i) { $feed->{feed_imgDescription} = $con; }	# image desc
			else { $vars->{msg} .= qq|<p class="red">Exception 1305, 
				not sure what to do with $stack->[2] -> $stack->[1] -> $stack->[0] \n</p>|; }
				
		} elsif ($stack->[1] =~ /(^itunes:owner$)/i) {						# Itunes
	
			if ($stack->[0] =~ /^itunes:email$/i) { $feed->{author_email} = $con; }			# itunes email
			elsif ($stack->[0] =~ /^itunes:name$/i) { 						# itunes name
				unless ($feed->{feed_authorname}) { $feed->{feed_authorname} = $con; }
			}
			else { $vars->{msg} .= qq|<p class="red">Exception 1314, 
				not sure what to do with $stack->[2] -> $stack->[1] -> $stack->[0] \n</p>|; }				
				
		
		}
		
	} elsif ($stack->[1] =~ /(^media$|^media:content$)/i) {				# Extracting Data for media
 
		if ($stack->[0] =~ /^title$|^media:title$/i) { 				# title
			$media->{media_title} = $con;
			
		} else { $vars->{msg} .= qq|<p class="red">Exception 1451 
			Media, not sure what to do with $stack->[1] -> $stack->[0] </p>\n|; }



		
	} elsif ($stack->[1] =~ /(^author$)/i) {					# Extracting Data for author
 
		if ($stack->[0] =~ /^name$/i) { $author->{author_name} = $con; }		
		elsif ($stack->[0] =~ /^uri$/i) { $author->{author_link} = $con; }
		elsif ($stack->[0] =~ /^email$/i) { $author->{author_email} = $con; }		
		else { $vars->{msg} .= qq|<p class="red">Exception 1462 
			Author, not sure what to do with $stack->[1] -> $stack->[0] </p>\n|; }

# 		$author->{$stack->[0]} = $con;

		
	} elsif ($stack->[1] =~ /(^?xml$)/i) {				# XML tag

		$vars->{msg} .= "Feed type is $stack->[0]";

	} elsif ($stack->[1] =~ /(^rss$)/i) {				# RSS tag

		# Nothing

	} elsif ($stack->[1] =~ /(^?xml-stylesheet$)/i) {				# XML tag

		# Nothing
	
	} else {

		$vars->{msg} .= qq|<p class="red">Exception 1482 
			Feed. Don't know what to do with $stack->[2] -> $stack->[1] -> $stack->[0] </p>\n|; #'

	}

	if ($stack->[0] =~ /(^channel$|^feed$)/i) {

		#print "Closing a channel item"; 

		&save_feed($dbh,$query,$feed,$item,$cdata,$field_list,$field_value_pair);



	} elsif ($stack->[0] =~ /(^item$|^entry$)/i) {			# Saving Item from Rss:item or Feed:entry


		my $medialist = $item->{link_media};
		my $itemid = &save_item($dbh,$query,\%$item,$cdata,$feed,$mapping,$field_list,$field_value_pair,$recordslist);
		if ($itemid) {											# If new item...
			my @medialist = split ",", $medialist;						# Associate item with media
			foreach my $m (@medialist) {	
				my $t = time;	
				&db_insert($dbh,$query,"lookup",{
					lookup_taba => "media",
					lookup_ida => $m, 
					lookup_tabb => "link", 
					lookup_idb => $itemid,
					lookup_create => $t,
					lookup_creator => "1",
					lookup_type => "Media" });
													
				$vars->{msg} .= "Associating item $itemid with media $m <br>"; 
			}
		}		
		$feed->{medialist} = "";											


	} 
	
	# Not really needed but a good way to check
	# These are all elements that are dealt with elsewhere, as subelements of feed, entry, etc
	elsif ($stack->[0] =~ /(^?openSearch)/i) {		}		# Open Search - see Feed
	# else { $vars->{msg} .= qq|<p class="red">Totally unknown primary element $stack->[0] </p>\n|; }

	return "ok";


}




#--------------------------------------------------------------------------------
#
#
#                      Scraping Functions
#
#
#---------------------------------------------------------------------------------

#--------------------------Scrape Item Metadata --------------------------------
#
# Looks for RDFa, eventa metadata, etc., in the description and content

sub scrape_item_metadata {

	my ($dbh,$query,$feed,$sc_table,$sc_data,$cdata,$recordslist) = @_;
	my $vars = $query->Vars;
	$vars->{msg} .= "<p><b>Scraping item metadata...</b><br>";

									# Prepare Scrape Data

	my $descfield = $sc_table."_description";	
	my $contfield = $sc_table."_content"; 
	my $sumfield = $sc_table."_summary";
	my $scrapedata = $sc_data->{$descfield};
	if ($sc_data->{$descfield} ne $sc_data->{$contfield}) { $scrapedata .= $sc_data->{$contfield}; }
	if ($sc_data->{$descfield} ne $sc_data->{$sumfield}) { $scrapedata .= $sc_data->{$sumfield}; }
	
	$scrapedata =~ s/&gt;/>/g; $scrapedata =~ s/&lt;/</g;	$scrapedata =~ s/&amp;/&/g; $scrapedata =~ s/&quot;/"/g; #"
	$scrapedata =~ s/\n//; $scrapedata =~ s/\r//; $scrapedata =~ s/&nbsp;/ /g; 

													# Execute Scrapes

	&scrape_links($dbh,$query,$feed,$sc_table,$sc_data,\$scrapedata,$recordslist);			# Links 
	&scrape_images($dbh,$query,$feed,$sc_table,$sc_data,\$scrapedata,$recordslist);			# Images
	&scrape_embeds($dbh,$query,$feed,$sc_table,$sc_data,\$scrapedata,$recordslist);			# Images	
	&scrape_iframes($dbh,$query,$feed,$sc_table,$sc_data,\$scrapedata,$recordslist);		# iFrames	
	
# foreach my $r (@$recordslist) { $vars->{msg} .= "<i>ss $r->{media_url} </i>"; }	
	$vars->{msg} .=  "<p>Scrape result ".@$recordslist."</p>";

	# Scrape ALT event metadata - pretty ugly stuff
	my $edate = ""; my $start = ""; my $end = "";
	if ($scrapedata =~ m/<span class="date-display-start">(.*?)<\/span>/) {
		$start = $1;
		my $event = ();
		if ($scrapedata =~ m/<span class="date-display-end">(.*?)<\/span>/) {
			$end = $1;
		}
		if ($scrapedata =~ m/<span class="date-display-single">(.*?) -/) {
			$edate = $1; 
			$start = $edate . " - ". $start;
			$end = $edate . " - ". $end;
		}

		# Start
		my $dtstart = &convert_alt_dates($start);
		my $estart = $dtstart->epoch;
		$sc_data->{$sc_table."_start"} = $estart;

		# End
		my $dtend = &convert_alt_dates($end);
		my $eend = $dtend->epoch;
		$sc_data->{$sc_table."_finish"} = $eend;	
		$sc_data->{$sc_table."_localtz"} = "Europe/London";
		$sc_data->{$sc_table."_identifier"} = $sc_data->{$sc_table."_link"};



#	my $record = gRSShopper::Record->new;
#	$record->{type} = "event";
#	$record->{event_start} = $event->{event_start};
#	push @{$sc_data->{$sc_table."_records"}},$record;


	}
}


#-------------------------- Scrape Iframes --------------------------------

sub scrape_iframes {

	my ($dbh,$query,$feed,$sc_table,$sc_data,$scrapedata,$recordslist) = @_;
	my $vars = $query->Vars;
	$vars->{msg} .= "<p>Scraping iframes...<br>";

	# Get Media Types by URL from Box titled 'URL Types'
	my $urltypes = &db_get_record($dbh,"box",{box_title=>"URL Types"});
	$urltypes->{box_content} =~ s/\r/\n/g;	# Normalize line feeds
	$urltypes->{box_content} =~ s/\n\n/\n/g;
	
	my @urltypeslist = split /\n/,$urltypes->{box_content};
	
# $vars->{msg} .= "<form><textarea cols='80' rows='10'>$$scrapedata</textarea></form>";


	my $urltypename;	
	while($$scrapedata =~ m/<iframe(.*?)>/ig) {
		
										# Get tag data & initialize record object
		my $ifdata = $1;
		my $record = gRSShopper::Record->new;
		$record->{type} = "other";
		

								# Get and verify URL
		next unless ($ifdata =~ m/src="(.+?)"/);
		$record->{media_url} = $1; 
		$record->{media_url} =~ s/utm=(.*?)$//;	# Wipe out utm parameters 
		next unless (&good_graph_url($query,$record->{media_url}));
		

								# Set type & mimetype defaults
								
		$record->{media_mimetype} = &mime_type($record->{media_url});	
		unless ($record->{media_mimetype}) { $record->{media_mimetype} = "text/html"; }
			
								# Identify as media per se (or not)
								

		if ($record->{media_mimetype} =~ /audio/) { $record->{media_type} = "audio"; $record->{type} = "media"; }
		elsif ($record->{media_mimetype} =~ /video/) { $record->{media_type} = "video"; $record->{type} = "media";}
		elsif ($record->{media_mimetype} =~ /pdf|msword|powerpoint/) { $record->{media_type} = "document"; $record->{type} = "media";}					
		elsif ($record->{media_mimetype} =~ /image/) { $record->{media_type} = "image"; $record->{type} = "image"; }
		elsif ($record->{media_mimetype} =~ /zip|tar|binhex/) { $record->{media_type} = "archive"; $record->{type} = "archive"; }
		elsif ($record->{media_mimetype} =~ /text/) { $record->{media_type} = "text"; $record->{type} = "text"; }	
		else  { $record->{media_type}="other"; $record->{type} = "other"; }
		
								# Define media type by known URLs
		if ($record->{type} = "other") {		# Ie., if it's html or some such thing
			foreach my $urltypeitem (@urltypeslist) {
				if ($urltypeitem =~ /:$/) { 
					$urltypeitem =~ s/://;
					$urltypename = $urltypeitem;
				} else {
					if ($record->{media_url} =~ /$urltypeitem/) {
						$record->{type} = "media";				
						$record->{media_type} = $urltypename;
					}
				}	
			}	
		}		
						

			
		if ($record->{media_url} =~ /$feed->{feed_html}/) { next; } 	# - don't scrape internal links
		if ($record->{media_url} =~ /#!/) { next; }			# - Don't scrape hashbang links	

										# Get other parameters

		if ($ifdata =~ m/height="(.+?)"/) { $record->{media_height} = $1; }	
		if ($ifdata =~ m/width="(.+?)"/) { $record->{media_width} = $1; }
		
		$record->{media_crdate} = time;
		$record->{media_creator} = $Person->{person_id} || 1;
		

		
				
			
	
		
		
								# Guarantee and display title
								
		my @dirarr = split "/",	$record->{media_url};	
		my $filename = pop @dirarr;
		$filename =~ s/\?(.*?)$//;
		if ($record->{media_title}) { $vars->{msg} .= "Iframe: $record->{media_title} - $filename <br/>"; }
		else { $record->{media_title} = $filename; $vars->{msg} .= "Iframe: $filename <br/>"; }
				
								# Set default system parameters
														
		$record->{media_crdate} = time;
		$record->{media_creator} = $Person->{person_id} || 1;	
		
				
	
#		$vars->{msg} .= "Found: $record->{media_url} <br>";
#		$vars->{msg} .= "Record type: ".$record->{type} ."<br>";
		# Save record to the list
		push @$recordslist,$record;
	

	}
# foreach my $r (@recordslist) { $vars->{msg} .= "<i> $r->{media_url} </i>"; }
$vars->{msg} .= "Done</p>";
}

#-------------------------- Scrape Embeds --------------------------------

sub scrape_embeds {
	
	my ($dbh,$query,$feed,$sc_table,$sc_data,$scrapedata,$recordslist) = @_;
	my $vars = $query->Vars;
	$vars->{msg} .= "<p>Scraping embeds...<br>";	
	
	while($$scrapedata =~ m/<embed(.*?)>/ig) {
		
								# Get tag data & initialize record object
		my $emdata = $1;
		my $record = gRSShopper::Record->new;
		$record->{type} = "media";
				
								# Get and verify URL
		next unless ($emdata =~ m/src="(.+?)"/);
		$record->{media_url} = $1; 
		$record->{media_url} =~ s/utm=(.*?)$//;	# Wipe out utm parameters 
		next unless (&good_graph_url($query,$record->{media_url}));
		

								# Set type & mimetype defaults
								
		$record->{media_mimetype} = &mime_type($record->{media_url});	
		unless ($record->{media_mimetype}) { $record->{media_mimetype} = "embed"; }	
		$record->{media_type} = "embed";

								# Get other parameters
									 
		if ($emdata =~ m/type="(.+?)"/) { $record->{media_mimetype} = $1; }		
		if ($emdata =~ m/alt="(.+?)"/) { $record->{media_description} = $1; }	
		if ($emdata =~ m/height="(.+?)"/) { $record->{media_height} = $1; }	
		if ($emdata =~ m/width="(.+?)"/) { $record->{media_width} = $1; }	
		if ($emdata =~ m/lang="(.+?)"/) { $record->{media_language} = $1; }	
		if ($emdata =~ m/id="(.+?)"/) { $record->{media_identifier} = $1; }		
		
								# Guarantee and display title
								
		my @dirarr = split "/",	$record->{media_url};	
		my $filename = pop @dirarr;
		$filename =~ s/\?(.*?)$//;		
		if ($record->{media_title}) { $vars->{msg} .= "Embed: $record->{media_title} - $filename <br />"; }
		else { $record->{media_title} = $filename; $vars->{msg} .= "Embed: $filename <br/>"; }

								# Set default system parameters
														
		$record->{media_crdate} = time;
		$record->{media_creator} = $Person->{person_id} || 1;	
		
		
		# Save record to the list
		push @$recordslist,$record;
	}
	
	$vars->{msg} .= "Done </p>";
	

	
}



#-------------------------- Scrape Links --------------------------------

sub scrape_images {
	
	my ($dbh,$query,$feed,$sc_table,$sc_data,$scrapedata,$recordslist) = @_;
	my $vars = $query->Vars;
	$vars->{msg} .= "<p>Scraping Images...<br>";	
	
	while($$scrapedata =~ m/<img(.*?)>/ig) {
		
								# Get tag data & initialize record object
		my $imgdata = $1;
		my $record = gRSShopper::Record->new;
		$record->{type} = "media";

		
								# Get and verify URL
		next unless ($imgdata =~ m/src="(.+?)"/);
		$record->{media_url} = $1; 
		$record->{media_url} =~ s/utm=(.*?)$//;	# Wipe out utm parameters 
		$record->{media_url} =~ s/\?(.*?)$//;	# Wipe out parameters (images only; not sure I want this, but we'll see)
		next unless (&good_graph_url($query,$record->{media_url}));
				
								# Set type & mimetype defaults
								
		$record->{media_mimetype} = &mime_type($record->{media_url});	
		unless ($record->{media_mimetype}) { $record->{media_mimetype} = "image"; }		
		$record->{media_type} = "image";		
		
								# Get other parameters

		if ($imgdata =~ m/title="(.+?)"/) { $record->{media_title} = $1; }		
		if ($imgdata =~ m/alt="(.+?)"/) { $record->{media_description} = $1; }	
		if ($imgdata =~ m/height="(.+?)"/) { $record->{media_height} = $1; }	
		if ($imgdata =~ m/width="(.+?)"/) { $record->{media_width} = $1; }	
		if ($imgdata =~ m/lang="(.+?)"/) { $record->{media_language} = $1; }	
		if ($imgdata =~ m/id="(.+?)"/) { $record->{media_identifier} = $1; }		
		
								# Guarantee and display title
								
		my @dirarr = split "/",	$record->{media_url};	
		my $filename = pop @dirarr;
		$filename =~ s/\?(.*?)$//;		
		if ($record->{media_title}) { $vars->{msg} .= "Image: $record->{media_title} - $filename <br/>"; }
		else { $record->{media_title} = $filename; $vars->{msg} .= "Image: $filename/>"; }

								# Set default system parameters
		$record->{media_crdate} = time;
		$record->{media_creator} = $Person->{person_id} || 1;	
		
		
								# Save record to the list
		push @$recordslist,$record;
	}
	
	$vars->{msg} .= "Done </p>";
	

	
}

#-------------------------- Scrape Links --------------------------------

sub scrape_links {

	my ($dbh,$query,$feed,$sc_table,$sc_data,$scrapedata,$recordslist) = @_;
	my $vars = $query->Vars;
	$vars->{msg} .= "<p>Scraping Links...<br>";

	# Get Media Types by URL from Box titled 'URL Types'
	my $urltypes = &db_get_record($dbh,"box",{box_title=>"URL Types"});
	$urltypes->{box_content} =~ s/\r/\n/g;	# Normalize line feeds
	$urltypes->{box_content} =~ s/\n\n/\n/g;
	
	my @urltypeslist = split /\n/,$urltypes->{box_content};
	
# $vars->{msg} .= "<form><textarea cols='80' rows='10'>$$scrapedata</textarea></form>";


	my $urltypename;	
	while($$scrapedata =~ m/href="(.+?)"(.*?)>(.*?)</ig) {
		my $href = $1; my $title = $3;
	

		# Set up media record data
		my $record = gRSShopper::Record->new;
		$record->{media_url} = $href;
		
		# make sure it's an acceptable link
		next unless ($record->{media_url});
		next unless (&good_graph_url($query,$record->{media_url}));
		
		$record->{media_url} =~ s/utm=(.*?)$//;	# Wipe out utm parameters 		
		$record->{media_title} = $title;
		$record->{media_crdate} = time;
		$record->{media_creator} = $Person->{person_id} || 1;
		
		# Identify href media type
		$record->{media_mimetype} = &mime_type($record->{media_url});
		unless ($record->{media_mimetype}) { $record->{media_mimetype} = "text/html"; }
		unless ($record->{media_type}) { $record->{media_type} = "text/html"; }



		
		# Identify as media per se (or not)
		if ($record->{media_mimetype} =~ /audio|video|pdf|msword|powerpoint/) { 
			$record->{type} = "media";
			if ($record->{media_mimetype} =~ /audio/) { $record->{media_type} = "audio"; }
			if ($record->{media_mimetype} =~ /video/) { $record->{media_type} = "video"; }
			if ($record->{media_mimetype} =~ /pdf|msword|powerpoint/) { $record->{media_type} = "document"; }					
		}
		elsif ($record->{media_mimetype} =~ /image/) { $record->{media_type} = "image"; $record->{type} = "image"; }
		elsif ($record->{media_mimetype} =~ /zip|tar|binhex/) { $record->{media_type} = "archive"; $record->{type} = "archive"; }
		elsif ($record->{media_mimetype} =~ /text/) { $record->{media_type} = "text"; $record->{type} = "text"; }	
		else  { $record->{media_type}="other"; $record->{type} = "other"; }				
			
	
		if ($record->{type} = "other") {			# Ie., if it's html or some such thing
			if ($href =~ /$feed->{feed_html}/) { next; } 	# - don't scrape internal links
			if ($href =~ /#!/) { next; }			# - Don't scrape hashbang links

			foreach my $urltypeitem (@urltypeslist) {
				if ($urltypeitem =~ /:$/) { 
					$urltypeitem =~ s/://;
					$urltypename = $urltypeitem;
				
				} else {
					if ($record->{media_url} =~ /$urltypeitem/) {
						$record->{type} = "media";				
						$record->{media_type} = $urltypename;
					}
				}	
			}	
		}		
	
#		$vars->{msg} .= "Found: $record->{media_url} <br>";
#		$vars->{msg} .= "Record type: ".$record->{type} ."<br>";
		# Save record to the list
		push @$recordslist,$record;
	

	}
# foreach my $r (@recordslist) { $vars->{msg} .= "<i> $r->{media_url} </i>"; }
$vars->{msg} .= "Done.</p>";
}


sub mime_type {
	
	my ($filename) = @_;
	
	my $mime_table = {
	      ai => "application/postscript",
	      aiff => "audio/x-aiff",
	      au => "audio/basic",
	      avi => "video/x-msvideo",
	      bck => "application/VMSBACKUP",
	      bin => "application/x-octetstream",
	      bleep => "application/bleeper",
	      class => "application/octet-stream",
	      com => "text/plain",
	      crt => "application/x-x509-ca-cert",
	      csh => "application/x-csh",
	      dat => "text/plain",
	      doc => "application/msword",
	      docx => "application/msword",
	      dot => "application/msword",
	      dvi => "application/x-dvi",
	      eps => "application/postscript",
	      exe => "application/octet-stream",
	      gif => "image/gif",
	      gtar => "application/x-gtar",
	      gz => "application/x-gzip",
	      hlp => "text/plain",
	      hqx => "application/mac-binhex40",
	      htm => "text/html",
	      html => "text/html",
	      htmlx => "text/html",
	      htx => "text/html",
	      imagemap => "application/imagemap",
	      jpe => "image/jpeg",
	      jpeg => "image/jpeg",
	      jpg => "image/jpeg",
	      mcd => "application/mathcad",
	      mid => "audio/midi",
	      midi => "audio/midi",
	      mov => "video/quicktime",
	      movie => "video/x-sgi-movie",
		mp3 => "audio/mpeg",
	      mpeg => "video/mpeg",
	      mpe => "video/mpeg",
	      mpg => "video/mpeg",
	      pdf => "application/pdf",
	      ppt => "application/vnd.ms-powerpoint",
	      pptx => "application/vnd.ms-powerpoint",
	      ps => "application/postscript",
	      'ps-z' => "application/postscript",
	      qt => "video/quicktime",
	      rtf => "application/rtf",
	      rtx => "text/richtext",
	      sh => "application/x-sh",
	      sit => "application/x-stuffit",
	      tar => "application/x-tar",
	      tif => "image/tiff",
	      tiff => "image/tiff",
	      txt => "text/plain",
	      ua => "audio/basic",
	      wav => "audio/x-wav",
	      xls => "application/vnd.ms-excel",
	      xbm => "image/x-xbitmap'",
	      zip => "application/zip"
	     };	
	
	
	my @harray = split /\./,$filename; 
	my $ext = pop @harray; $ext = lc($ext);
	$ext =~ s/\?//;

	return $mimetype;
	
}

#-------------------------- Convert ALT Dates --------------------------------
#
# Converts ALT dates into proper date-time strings

sub convert_alt_dates {

	my ($indate) = @_;
	print "Indate: $indate<p>";

	my ($wd,$m,$y,$d,$h,$mm,$s);
	if ($indate =~ m/^(.*?), (.*?) (.*?), (.*?) - (.*?):(.*?)$/) {
		$wd = $1, $m = $2; $d = $3; $y = $4; $h = $5; $mm = $6; $s = 0;
	}
	my @months = qw|00 January February March April May June July August September October November December|;	
	$m = &index_of($m,\@months); 
	my $tz = "Europe/London";
	my $dt = DateTime->new(
 	     year       => $y,
 	     month      => $m,
 	     day        => $d,
 	     hour       => $h,
 	     minute     => $mm,
 	     second     => $s,
 	     time_zone  => $tz,
 	);
	return $dt;

}







#--------------------------------------------------------------------------------
#
#
#                      Data Storage Functions
#
#
#---------------------------------------------------------------------------------


#-------------------------- Save Item --------------------------------

sub save_item {

	my ($dbh,$query,$item,$cdata,$feed,$mapping,$field_list,$field_value_pair,$recordslist) = @_;
	my $linkauthor;
	

	#$vars->{analyze} = "on";
#$vars->{msg} .= "<p><b>Save Item</b><br/>";
#$vars->{msg} .= "Field list = $field_list";
#while (my ($flx,$fly) = each %$field_list) { $vars->{msg} .= " $flx=$fly ; <br> "; }
#print "Item $item->{hold}(save_item) <br>";	
	$vars->{msg} .= " - Link $item->{link_link} (save_item)<br>\n";
	$vars->{msg} .= "mapping is $mapping->{mapping_title} <br>\n";

	unless ($item->{link_link}) {
		$vars->{msg} .= qq|<span style="color:red;">Warning, no URL found for this item.</span><br>|; 
	}
	
	while (my($lx,$ly) = each %$item) { 				# Replace CDATA
		if ($ly =~ /CDATA\((.*?)\)/) { 		
#			$vars->{msg} .= "Restoring CDATA";
			$ly =~ s/CDATA\((.*?)\)/$cdata->[$1]/g; 
			$ly =~ s/OPENBLOCK/\[/g;	# Really annoying to have to do 
			$ly =~ s/CLOSEBLOCK/\]/g;
		}
		$ly =~ s/&gt;/>/g;				# Unescape tags
		$ly =~ s/&lt;/</g;
		$item->{$lx} = $ly;

# unless ($vars->{flag} eq "flag") { $vars->{msg} .= "$lx  \n";  }

	}
	
							# Clean Crap Out of Description, Content, Summary
	foreach my $it (qw(link_content link_description link_summary)) {
		$item->{$it} =~ s/<(div|script|span|font)(.*?)>//g;
		$item->{$it} =~ s/<\/(div|script|span|font)>//g;
		$item->{$it} =~ s/  / /g;
		$item->{$it} =~ s/\r//g;		
		$item->{$it} =~ s/\n\n/ /g;
	}



	
									# Check Tag Constraint
									# If feed_tag_req = "yes" then item
									# must contain $Site->{st_tag} to be saved
	if ($Site->{st_tag} && $feed->{feed_tag_req} && $feed->{feed_tag_req} eq "yes") {  
		return unless (
			($item->{link_link} =~ /$Site->{st_tag}/i) ||		
			($item->{link_title} =~ /$Site->{st_tag}/i) ||
			($item->{link_description} =~ /$Site->{st_tag}/i) ||
			($item->{link_category} =~ /$Site->{st_tag}/i) );
	}	
	
							# Set Up Link Data
	$item->{link_title} =~ s/<(.*?)$//ig;	# This is a plusfeed.appspot.com Google Plus feed special
	$item->{link_title} =~ s/&ly;(.*?)$//ig;	# This is a plusfeed.appspot.com Google Plus feed special						
	unless ($item->{link_type}) { 	$item->{link_type} = "text/html\n\n"; }
	$item->{link_crdate} = time;
	$item->{link_crdate} ||= "Untitled";
	$vars->{msg} .= "Item title is: $item->{link_title} <br/>\n";		
	$item->{link_creator} = $Person->{person_id};
	$item->{link_feedid} = $feed->{feed_id};
	$item->{link_feed} = $feed->{feed_id};	
	$item->{link_feedname} = $feed->{feed_title};
	unless ($item->{link_link}) { $item->{link_link} = $item->{link_alternate}; }
	$vars->{msg} .= "URL is $item->{link_link}<br/>\n";	
	$vars->{msg} .= "Feed id is $item->{link_feed}<br/>\n";
	$item->{link_feedname} = $feed->{feed_title};
	if ($item->{link_summary}) { unless ($item->{link_description}) { $item->{link_description} = $item->{link_summary}; } }
	if ($item->{link_content}) { unless ($item->{link_description}) { $item->{link_description} = $item->{link_content}; } }
	unless ($item->{link_content})  { $item->{link_content} = $item->{link_description}; }
	$item->{link_status} = "Fresh";
	$item->{link_class} = $feed->{feed_class};	
	$item->{link_genre} = $feed->{feed_genre};
	if ($item->{link_category}) { $item->{link_category} .= ";".$feed->{feed_category}; }
	else { $item->{link_category} = $feed->{feed_category}; }
	

	
	# Trickle down copyright
	unless ($item->{link_copyright}) { if ($feed->{feed_copyright}) { $item->{link_copyright} = $feed->{feed_copyright}; } }
 
 #   Mappings not working? Special function to process twitter
    
    
    if ($item->{link_link} =~ /twitter\.com/) {
    	$vars->{msg} .= "Spotted Twitter post<br/>";
        $item->{link_type} = "twitter";
        
        my ($authorurl,$stuff) = split "/statuses",$item->{link_link};
        my ($stuffa,$authorname) = split "com/",$authorurl;
        $item->{link_authorname} = $authorname;
        $item->{link_authorurl} = $authorurl;
        my $authtemp = &save_author($dbh,$query,{author_name=>$item->{link_authorname},
		author_url=>$item->{link_authorurl}},$feed,$item); 
        $item->{link_author} = $authtemp->{author_id};		
    	$vars->{msg} .= "Identified Twitter Author ID: $item->{link_author}  Name: $item->{link_authorname} <br>";
        
    } else {
        $item->{link_type} = "text/html";
    }


$vars->{flag} = "flag";



							# Get Entry Mapping

	$mapping = &map_entry_mapping($dbh,$item,$field_list,$field_value_pair,$mapping);
	unless ($mapping->{mapping_title}) { $mapping = &map_default($dbh,$query,$feed->{feed_type}); }
	my $maphash = &map_maphash($mapping); 
	$vars->{msg} .= "Mapping: ".$mapping->{mapping_title}."</p>\n"; 
	my $mapoutput = &map_to_output($mapping,$maphash,$item);
	&sanitize($mapoutput);

    
						
        
    
							# Uniqueness Constraint
	unless (&unique($dbh,$query,$mapping,$mapoutput)) { return; }
	
							# Good time to scrape?

	&scrape_item_metadata($dbh,$query,$feed,"link",$item,$cdata,$recordslist);

	my $entryid = 0;


#$vars->{msg} .= "SAVING $mapping->{mapping_dtable} <br>";
#while (my($mx,$my) = each %$mapoutput) { $vars->{msg} .=  "$mx = $my <br>"; }

 while (my ($flx,$fly) = each %$mapoutput) { $vars->{msg} .= " $flx=$fly ; <br> "; }
    

						# Insert Entry into the Database
#	if ($vars->{analyze} eq "on") { $entryid = "42"; }					
#	else { 
		$entryid = &db_insert($dbh,$query,$mapping->{mapping_dtable},$mapoutput); 
#	}
	my $entryurl = $item->{link_link};
	
	if ($entryid) { $vars->{msg} .= "<p>Entry inserted into $mapping->{mapping_dtable} id number $entryid</p>\n"; }
	else { 
		$vars->{msg} .= "<p>Entry insert failed.</p>\n";
		unless ($item->{link_link}) { $vars->{msg} .= "<p>No link value found.</p>"; } 
	}



	
	
	# Save assication between feed and link
	&save_graph($dbh,$query,{
		graph_type => "link",
		graph_tableone => "feed",
		graph_urlone => $feed->{feed_html},
		graph_idone => $feed->{feed_id},
		graph_tabletwo => $mapping->{mapping_dtable},
		graph_urltwo => $entryurl,
		graph_idtwo => $entryid});
	
	
	# Cycle through assicated records and save them
	
	$vars->{msg} .= "<p><b>Saving Associated Links and Media</b><br/>";
	
	my $graphid;
	foreach my $r (@$recordslist) { 
		# $vars->{msg} .= "$r->{type}  $r->{media_title} <br>";
		if ($r->{type} eq "text" || $r->{type} eq "other") {
			
			# Is it an existing link?
			my $lid = &db_locate($dbh,"link",{link_link => $r->{media_url}});

			&save_graph($dbh,$query,{
				graph_type => "link",
				graph_tableone => $mapping->{mapping_dtable},
				graph_urlone => $entryurl,
				graph_idone => $entryid,
				graph_tabletwo => "link",
				graph_urltwo => $r->{media_url},
				graph_idtwo => $lid});
				
		} elsif ($r->{type} eq "media") {				# media
			
			# Save or Get Media ID

			$r->{media_id} = &save_media($dbh,$query,$r,$feed,$item);
	
			if ($r->{media_id}) {

				&save_graph($dbh,$query,{
					graph_type => "link",
					graph_tableone => $mapping->{mapping_dtable},
					graph_urlone => $entryurl,
					graph_idone => $entryid,
					graph_tabletwo => "media",
					graph_urltwo => $r->{media_url},
					graph_idtwo => $r->{media_id}});
					
		
			}

		} elsif ($r->{type} eq "author") {


			# Save or Get Author ID & Update author data
			my $new_author = &find_author($dbh,$query,$r,$feed,$item);						
			# Associate Author information with the item
			if ($new_author->{author_id}) {
				$item->{link_author} = $new_author->{author_id};
				&save_graph($dbh,$query,{
					graph_type => "link",
					graph_tableone => $mapping->{mapping_dtable},
					graph_urlone => $entryurl,
					graph_idone => $entryid,
					graph_tabletwo => "author",
					graph_urltwo => $new_author->{author_link},
					graph_idtwo => $new_author->{author_id}});
				
			}
			
			# Save some additional author data in link table, as a shortcut
			if ($mapping->{mapping_dtable} eq "link") {
				unless ($item->{link_authorname}) {
					$vars->{msg} .= "Attributing feed author $r->{author_name} ($r->{author_id}) as author<br/> ";	
					$item->{link_author} = $r->{author_id};
					$item->{link_authorname} = $r->{author_name};
					$item->{link_authorurl} = $r->{author_link};	
				}
			}
		} else {
			$vars->{msg} .= "Not sure what to do with association of type $r->{type}<br/> ";
		}
	}

	# Wait! Do we have an author for this entry? Did we assign one somewhere?
	$vars->{msg} .= "<p>";
	my $foundauthor;
	if ($item->{link_author}) {
		# I can't think of any other author info I'd find in plain link xml but if I did it would go here
		$foundauthor = &db_get_record($dbh,"author",{author_id => $item->{link_author}});
		$vars->{msg} .= "Processing link_author $foundauthor->{author_name} ($foundauthor->{author_id}) as author<br/> ";
	}	
	
	# No? Can we get one from the feed?
	if (!$linkauthor && !$item->{link_author}) {
		$foundauthor = &find_feed_author($dbh,$query,$feed,$item);
		if ($foundauthor) { 
			$vars->{msg} .= "Attributing feed author $foundauthor->{author_name} ($foundauthor->{author_id}) as author<br/> ";	
			$item->{link_author} = $foundauthor->{author_id};
			$item->{link_authorname} = $foundauthor->{author_name};
			$item->{link_authorurl} = $foundauthor->{author_link};	
					
		} 
	}
	
	# Update the link author information
	if ($entryid) {
		if ($vars->{analyze} eq "on") { $vars->{msg} .= "Adding extra author data to item<br>"; }
		else { &db_update($dbh,"link",
			{link_authorname => $item->{link_authorname},
			link_authorurl => $item->{link_authorurl},
			link_author => $item->{link_author}},
			$entryid,"2169");
		}
	}
	
	if ($foundauthor) { # Yay, we found one. Associate with this record
		$vars->{msg} .= "Associating found author with item<br/> ";

		&save_graph($dbh,$query,{
			graph_type => "link",
			graph_tableone => $mapping->{mapping_dtable},
			graph_urlone => $entryurl,
			graph_idone => $entryid,
			graph_tabletwo => "author",
			graph_urltwo => $foundauthor->{author_link},
			graph_idtwo => $foundauthor->{author_id}});
		
	} else {
		$vars->{msg} .= "Was never able to find an author for this item<br>";
	}		
		
	$vars->{msg} .= "<p><b>Done</b></p>";



	# Autopost & Rules
	#
	# Multiple reules are separated with ;
	# Rules are expressed: [else] condition => action
	# Rules preceded with [else] are run only if no previous rule has been run
	# condition is expressed: field~value,$field~value for a disjunction of values
	# action is expressed: field=value,field=value  for a list of values to set
	# action is expressed: autopost  to post link as a post
	#
	# eg.
	# title~Moncton,description~Moncton => category=City,autopost;


	
	my @rules = split ";",$feed->{feed_rules};			# Match
	my $triggered = 0;
	foreach my $rule (@rules) {
		next if ($rule =~ /^else/i && $triggered);			# Skip if else & triggered
		$rule =~ s/else//i; $rule =~ s/^\s*//;
		my ($if,$then) = split /\s*=>\s*/i,$rule;			# Rule
		my $result = "true";
	
										#   If	(series of & conditions)	
		 my @conditions = split /\s*&\s*/,$if;
		 foreach my $cond (@conditions) {				#     & Conditions  (try to prove false)
		 	my $fieldmatch=0;
			if ($cond =~ /=/) {					#          =
				my ($fieldlist,$match) = split "=",$cond;
				my @fields = split /\s*\|\s*/,$fieldlist;			
				foreach my $field (@fields) {			#     , Fields (true if match, false if no match)
					if ($item->{$field} eq "$match") { $fieldmatch = 1; }
					if ($item->{"link_".$field} eq "$match") { $fieldmatch = 1; }					
				}
			} elsif ($cond =~ /~/) {					#          ~
				my ($fieldlist,$match) = split "~",$cond;
				my @fields = split /\s*\|\s*/,$fieldlist;

				foreach my $field (@fields) {			#     , Fields (true if match, false if no match)
					if ($item->{$field} =~ /$match/i) { $fieldmatch = 1; }
					if ($item->{"link_".$field} =~ /$match/i) { $fieldmatch = 1; }					
				}
			}
			if ($fieldmatch == 0) { $result = "false"; last; }				
		}


					
					
				
		if ($result eq "true") {						# Then
print "Result = true<p>";		
			$triggered = 1;
#			do {} while ($then =~ s/\((.*?),(.*?)\)/COMMA/g);   # screen commas in brackets
			my @actions = split /(?![^(]+\)),/, $then;

#			my @actions = split ",",$then;			
			foreach my $a (@actions) {
				if ($a =~ /autopost/i) {
					$postid = &auto_post($dbh,$query,$entryid);
				} elsif ($a =~ /extract/) {
					$a =~ s/extract\(//; $a =~ s /\)//;
print "Extracting - $a <br>";					
					my ($f,$s,$e) = split /,/,$a;
					my $llf = "link_".$f;
					
print "Parameters: $f,$s,$e <br>";
print qq|Before: $item->{"link_".$f} <br>|;
					if ($s && $e) { 
						if ($item->{$f} =~ /$s(.*?)$e/) { 
							$item->{$f} = $1; 
							my $lid = &db_update($dbh,"link",{$f=>$item->{$f}},$entryid);
						} elsif ($item->{$llf} =~ /$s(.*?)$e/) { 
							$item->{$llf} = $1; 
							my $lid = &db_update($dbh,"link",{$llf=>$item->{$llf}},$entryid);										
						}
					}

print qq|After: $item->{$f} $item->{$llf} <br>|;					
				} else {						
					my ($f,$m) = split "=",$a;		
					$item->{$f}=$m;
					my $llf = "link_".$f;$item->{$llf} = $m;
					my $lid = &db_update($dbh,"link",{$f=>$m,$llf=>$m},$entryid);
				}
			}
		}
	}


	# Clean up

	splice( @$recordslist );					# Clear records list for next item
	$recordslist = ();
	$item = {};							# Clear item record for next item
	return $entryid;
}

#--------------------------- Find Feed Author  ----------------------------------------

sub find_feed_author {
	
	my ($dbh,$query,$feed,$item) = @_;
	my $vars = $query->Vars;
	my $author;
	
	$vars->{msg} .= "Attempting to find feed author<br>";
	
	my $author = gRSShopper::Record->new;
	if ($feed->{feed_author}) { $author->{author_id} = $feed->{feed_author}; }
	if ($feed->{feed_authorname}) { $author->{author_name} = $feed->{feed_authorname}; }
	if ($feed->{feed_managingEditor}) { 
		if ($feed->{feed_managingEditor} =~ /@/) {  	# extract data of the form:  name@email (firstname lastname)
			my @mearr = split " ",$feed->{feed_managingEditor};
			my $email = shift @mearr;
			my $name = join " ",@mearr;
			
			unless ($email =~ /noreply/) { $author->{author_email} = $email; }
			$name =~ s/\(|\)//g;
			$author->{author_name} = $name;
		} else {
			$author->{author_name} = $feed->{feed_managingEditor}; 
		}
	}
	$vars->{msg} .= "Extracted the following from the feed:<br/>";
	while (my($ax,$ay) = each %$author) { $vars->{msg} .= " -- $ax = $ay <br>"; }
	
	unless ($author->{author_id} || $author->{author_name}) {		# If we got nothing from the feed data, try item data
		$vars->{msg} .= "Trying to find feed author from an item record: $item->{item_title} <br>";
		if ($item->{link_author}) { $author->{author_id} = $item->{link_author}; }
		if ($item->{link_authorname}) { $author->{author_name} = $item->{link_authorname}; }	
		if ($item->{link_authorurl}) { $author->{author_link} = $item->{link_authorurl}; }		
		$vars->{msg} .= "Found $author->{author_name} <br>";	
	}
			
	my $author_record = &save_author($dbh,$query,$author,$feed,$item);	
	if ($author_record) { return $author_record; }
	else { $vars->{msg} .= "Feed author not found.<br>"; return 0; }
	
		
}

#---------------------------Save Feed  ----------------------------------------


sub save_feed {

	my ($dbh,$query,$feed,$item,$cdata,$field_list,$field_value_pair) = @_;
	my $vars = $query->Vars;
	
	
	if ($feed->{feed_title} =~ /CDATA\((.*?)\)/) { 		
#		$vars->{msg} .= "Restoring CDATA";
		$feed->{feed_title} =~ s/CDATA\((.*?)\)/$cdata->[$1]/g; 
	}
	
	$vars->{msg} .= "<h2>Saving feed $feed->{feed_id} - $feed->{feed_title}</h2><br>\n";	
	
	my $feedauthor;
	if ($feed->{feed_author}) { 
		$feedauthor = db_get_record($dbh,"author",{author_id => $feed->{feed_author}}); 
		$vars->{msg} .= "Feed author $feedauthor->{author_name} ($feedauthor->{author_id}) located in database.<br>"; 
	} else {
		$feedauthor = &find_feed_author($dbh,$query,$feed,$item); 
	} 	# This will save author data if the author is new
	
	
	
	if ($feedauthor && $feedauthor->{author_id}) {
		
		$vars->{msg}.= "Updating feed author info<p>";
		$feed->{feed_author} = $feedauthor->{author_id};
		$feed->{feed_authorname} = $feedauthor->{author_name};
		$feed->{feed_authorurl} = $feedauthor->{author_link};		

	
		# Associate feed with author (should happen only once)
		&save_graph($dbh,$query,{
			graph_type => "link",
			graph_tableone => "feed",
			graph_urlone => $feed->{feed_html},
			graph_idone => $feed->{feed_id},
			graph_tabletwo => "author",
			graph_urltwo => $feedauthor->{author_link},
			graph_idtwo => $feedauthor->{author_id}});
	}

	# Assign feed URL as default feed author url
	unless ($feed->{feed_authorurl}) { $feed->{feed_authorurl} = $feed->{feed_html}; }


	
	while (my($lx,$ly) = each %$feed) { 
		if ($ly =~ /CDATA\((.*?)\)/) { 		# Replace CDATA
			$feed->{$lx} =~ s/CDATA\((.*?)\)/$cdata->[$1]/; 
			$feed->{$lx} =~ s/OPENBLOCK/\[/g;	# Really annoying to have to do 
			$feed->{$lx} =~ s/CLOSEBLOCK/\]/g;
		}

		if ($vars->{analyze} eq "on") { $vars->{msg} .= " - Feed: $lx = $ly <br>"; }
	
	
	}
	
	# Special for Plusfeed
	if ($feed->{feed_link} =~ /plusfeeds/) {
		$feed->{feed_link} =~ s/plusfeeds/plusfeed/i;
	}
	


	my $feedid;
	if ($vars->{analyze} eq "on") { $vars->{msg} .= "Analysis mode; feed not actually saved here<br>"; $feedid = "242"; }
	else { 
		$vars->{msg}.= "<p>Updating $feed->{feed_id} <br>"; 
		while (my($fx,$fy) = each %$feed) { $vars->{msg} .= " -- $fx = $fy <br>"; }
		&db_update($dbh,"feed",$feed,$feed->{feed_id},"2299"); 
	}
	$vars->{msg} .= "</p>";



}

#----------------------------- Is Author ------------------------------

sub is_author {
	
	# Weed out authors with no names, authors named 'admin', etc
	
	my ($dbh,$query,$author,$feed,$item) = @_;
	my $vars = $query->Vars;
		
	unless ($author->{author_name} || $author->{author_email} || $author->{author_link} || $author->{author_id}) { 
		$vars->{msg} .= "<p>Author from $author->{source} rejected; it has no name, email, url or id</p>"; return 0; }
	if ($author->{author_name} =~ /^admin$/i) { 
		$vars->{msg} .= "<p>Author from $author->{source} rejected; 'admin' is not an author name</p>"; return 0; }	
	if ($author->{author_name} =~ /^guest$/i) { 
		$vars->{msg} .= "<p>Author from $author->{source} rejected; 'guest' is not an author name</p>"; return 0; }		
	return 1;
	
}

#----------------------------- Find Author ------------------------------

sub find_author {
	
	my ($dbh,$query,$author,$feed,$item) = @_;
	my $vars = $query->Vars;
		
	return unless (&is_author($dbh,$query,$author,$feed,$item)); 
	$vars->{msg} .= "Searching for an author $author->{author_name}...<br/> ";
	my $author_record; my $found;
	
								# Life is easier if we have an author ID
	if ($author->{author_id}) {
		$author_record = &db_get_record($dbh,"author",{author_id => $author->{author_id}}); $found = "id";
	}
	
								# If we have an author name, and it's the same as the
								# feed author name, then return the feed author ID if it exists
								# (Saves lots of lookups)
	if ($author->{author_name} && ($author->{author_name} eq $feed->{author_name}) && $feed->{author}) {
		$author_record = &db_get_record($dbh,"author",{author_link => $feed->{feed_author}}); $found = "url";
	}							
								
								# If there's an author URL, it's easy
								# Unless it's a blog that uses multiple authors
								
	if (!$author_record && $author->{author_link}) {				
		$vars->{msg} .= "Searching for author by URL, URL is $author->{author_link} <br>";		
		my $ar = &db_get_record($dbh,"author",{author_link => $author->{author_link}}); $found = "url";
		unless ($author->{author_name} && ($author->{author_name} ne $ar->{author_name})) {
			$author_record = &db_get_record($dbh,"author",{author_link => $author->{author_link}}); $found = "url";
		}
	} 		
	
	return if ($feed->{feed_link} =~ /twitter/);			# Bail here if it's a Twitter author
								# (& any multi-author feed)
								
								
								# Next, try by author email address

	if (!$author_record && $author->{author_email}) {				
		$vars->{msg} .= "Searching for author by Email address: $author->{author_email}<br> ";	
		unless ($author->{author_email} =~ /noreply/) {		# Skip place-holder emails
			$author_record = &db_get_record($dbh,"author",{author_email => $author->{author_email}}); $found = "email";
		}
	} 
	
	
		
	if (!$author_record && $author->{author_name}) {	# Next, search by Name
		if ($author->{author_name} =~ /@/) {			# Name is an email address?
			$vars->{msg} .= "Searching for author by name as email address, name is $author->{author_name} <br>";	
			$author_record = &db_get_record($dbh,"author",{author_email => $author->{author_name}}); $found = "name as email";
		} 
		if (!$author_record) {
			$vars->{msg} .= "Searching for author by name, name is $author->{author_name} <br>";		
			$author_record = &db_get_record($dbh,"author",{author_name => $author->{author_name}}); $found = "name";
		}
	}
	
							
	if (!$author_record && $feed->{feed_author}) {		# No author found, let's default to feed author id, if it exists
		$vars->{msg} .= "Defaulting to feed author id, if it exists <br>";	
		$author_record = &db_get_record($dbh,"author",{author_id => $feed->{feed_author}}); $found = "feed author id";
		$found = "feed author id";
	}
	
							
	if (!$author_record && $feed->{feed_authorname}) {		# Maybe feed author ID isn't known yet? Search by feed author name
		$vars->{msg} .= "Defaulting to feed author name, if it exists <br>";
		$author_record = &db_get_record($dbh,"author",{author_name => $feed->{feed_authorname}}); 
		$found = "feed author name";
	}
	
								# Try using the author's nickname as a desperate last measure	
	if (!$author_record) {
		$vars->{msg} .= "Desperately trying to find author by nickname <br>";
		$author_record = &db_get_record($dbh,"author",{author_nickname => $author->{author_name}}); 
		if ($author_record) {
			if ($item) { $item->{link_authorname} = $author_record->{author_name};  } # Stop propagation of nickname
			if ($feed) { $feed->{feed_authorname} = $author_record->{author_name};  } 
			$found = "nickname: $author_record->{author_name}";	
		}
	} 

	if ($author_record) { $vars->{msg} .= "Found by $found <br/>";	return $author_record; }
	else { $vars->{msg} .= "Not found<br/>"; return 0;}
	
	
}
#----------------------------- Save Author ------------------------------

#	Save author is not only used to save author information, but is actually a pretty smart
#	tool for checking to see whether we've already found this author before, to avoid
#	duplicate saves. It returns the author_id of the saved $author

sub save_author {

	my ($dbh,$query,$author,$feed,$item) = @_;
	my $vars = $query->Vars;	
	$vars->{msg} .=  "<p><b>Saving Author</b>: $author->{author_name}<br /><i>$author->{author_link} </i><br/>";

								# Try to Locate Author
								
	return unless (&is_author($dbh,$query,$author,$feed,$item)); 							
	my $author_record = &find_author($dbh,$query,$author,$feed,$item); 
						
	
		
	if ($author_record) {					# If found, update the record if new info was found

		if ($item->{author_opensocialuserid}) {		# Transfer data from $item record
			$author->{author_opensocialuserid} = $item->{author_opensocialuserid}; 
		}	
		
		my $updateflag = 0;
		while (my ($ax,$ay) = each %$author) {				# Looking for new data
			next if ($ax eq "author_name");
			unless ($author->{$ax} eq $author_record->{$ax}) { $updateflag = 1; }
		}
		if ($author->{author_name} ne $author_record->{author_name}) { $updateflag = 0; } # Don't change names, ever
		
		if ($updateflag == "1") {					# New data found
			$vars->{msg} .= "Updating author data: $author_record->{author_name} ($author_record->{author_id}) <br/>";
			if ($vars->{analyze} eq "on") {  }
			else { &db_update($dbh,"author",$author,$author_record->{author_id},"2443"); }

		}
		return $author_record;	
		
								# If author doesn't exist, Save It
	} else {
		
		$vars->{msg} .=  "<i>Saving New Author</i>: $author->{author_name}<br /><i>$author->{author_link} </i><br/>";	

								# Assign default values	
		unless ($author->{author_crdate}) { $author->{author_crdate} = time;  }
		unless ($author->{author_creator}) { $author->{author_creator} = $Person->{person_id} || 1;  }
		if ($author->{author_name} =~ /@/) {
			unless ($author->{author_email}) {
				$author->{author_email} = $author->{author_name};
			}
		}
		if ($author->{author_name} =~ /http/) {
			unless ($author->{author_link}) {
				$author->{author_link} = $author->{author_name};
			}
		}
				
		unless ($author->{author_link}) { 
			$author->{author_link} = $feed->{feed_html};
			$vars->{msg} .= "Author URL set to feed URL $feed->{feed_html}<br/>"; 
		}	
		
		if ($vars->{analyze} eq "on") { 
			while (my ($mx,$my) = each %$author) { $vars->{msg} .= " - $mx = $my <br>"; }
			$vars->{msg} .= "Returning phony author id number for analysis 342</p>\n";
			$author_record = ();
			$author_record->{author_id} = "342"; }
		else { 
			my $authorid = &db_insert($dbh,$query,"author",$author); 
			$vars->{msg} .= "Entry inserted into author id number $authorid</p>\n"; 
			$author_record = &db_get_record($dbh,"author",{author_id => $authorid});
			
		}
		return $author_record;
	}
			
									
}


#----------------------------- Save Media ------------------------------

sub save_media {

	my ($dbh,$query,$media,$feed,$item) = @_;
	
	my $mediaid = 0;
	$media->{media_id}="";				# clear id, to prevent accidental overwrites

		# Step ??
	# Create the media table
	my @tables = $dbh->tables();
	my $tableName = "media";
	if ((grep/$tableName/, @tables) <= 0) {
		print "<p>Creating Media Table</p>";
#	      print "Content-type: text/html; charset=utf-8\n\n";
#		my $initurl = $ENV{'SERVER_NAME'} . $ENV{'SCRIPT_NAME'};
#		$initurl =~ s/admin\.cgi/initialize\.cgi/;
#	      print "Location: $initurl\n\n";

	      my $sql = qq|CREATE TABLE media (
			  media_id int(10) NOT NULL auto_increment,
			  media_type varchar(40) default NULL,
			  media_mimetype varchar(40) default NULL,
			  media_title varchar(256) default NULL,
			  media_url varchar(256) default NULL,
			  media_description text default NULL,
                    media_size varchar(32) default NULL,
                    media_link varchar(256) default NULL,
                    media_post varchar(256) default NULL,
                    media_feed varchar(256) default NULL,
			  KEY media_id (media_id)
		)|;
		$dbh->do($sql);
	} 
	
	$vars->{msg} .=  "<p><b>Saving Media</b>: $media->{media_title}<br /><i>$media->{media_url} </i><br/>";
	
								# Check for Feedburner original enclosure link
	if ($item->{link_origEnclosureLink}) { $media->{media_url} = $item->{link_origEnclosureLink} ; }
	
								# Check for required input
	unless ($media->{media_title}) { $vars->{msg} .= "Media rejected; it has no title.<br/>"; return; }
	unless ($media->{media_url}) { $vars->{msg} .= "Media rejected; it has no url.<br/>"; return; }


								# Assign default values	
	unless ($media->{media_crdate}) { $media->{media_crdate} = time;  }
	unless ($media->{media_creator}) { $media->{media_creator} = $Person->{person_id} || 1;  }
	$media->{media_link} = $item->{link_id};
	
	
								# Try to Locate Media

	if (my $l = &db_locate($dbh,"media",{media_url => $media->{media_url}})) {
		$vars->{msg} .= "Media item $l already exists.</p>"; return $l; 
		
								# or Save It
	} else {

		if ($vars->{analyze} eq "on") { 
			while (my ($mx,$my) = each %$media) { $vars->{msg} .= " - $mx = $my <br>"; }
			$mediaid = "142"; 
		}
		else { $mediaid = &db_insert($dbh,$query,"media",$media); }

		if ($mediaid) { $vars->{msg} .= "Entry inserted into media id number $mediaid</p>\n"; }
		else { $vars->{msg} .= "Media entry insert failed.</p>\n"; return 0; }

	}
	
							
	return $mediaid;
}

#----------------------------- Save Event ------------------------------

sub save_event {

	my ($dbh,$query,$event,$cdata) = @_;
	my $eventid = 0;
	



	$event->{event_id}="";				# clear id, to prevent accidental overwrites
	while (my($lx,$ly) = each %$event) { 
		if ($ly =~ /CDATA\((.*?)\)/) { 		# Replace CDATA
			$ly =~ s/CDATA\((.*?)\)/$cdata->[$1]/; 
			$ly =~ s/OPENBLOCK/\[/g;	# Really annoying to have to do 
			$ly =~ s/CLOSEBLOCK/\]/g;
		}
		print "$lx = $ly <br>"; 
	
	}

							# Check for required input
	unless ($event->{event_title}) { $vars->{msg} .= "Event rejected; it has no title.<br/>";  }
	unless ($event->{event_url}) { $vars->{msg} .= "Event rejected; it has no url.<br/>";  }
	unless ($event->{event_start}) { $vars->{msg} .= "Event rejected; it has no start date.<br/>";  }
	unless ($event->{event_title} && $event->{event_url} && $event->{event_start}) { return; }

							# Assign default values	
	unless ($event->{event_crdate}) { $event->{event_crdate} = time;  }
	unless ($event->{event_creator}) { $event->{event_creator} = $Person->{person_id} || 1;  }
		
	if (my $l = &db_locate($dbh,"event",{event_url => $event->{event_url},event_start => $event->{event_start}})) {
		$vars->{msg} .= "Event item $l already exists.<br/>"; return; 
	} else {

		$eventid = &db_insert($dbh,$query,"event",$event);

		if ($eventid) { $vars->{msg} .= "Entry inserted into event id number $eventid<br>\n"; }
		else { $vars->{msg} .= "Event entry insert failed.<br>\n"; return 0; }

	}
	
	return $eventid;
}

#----------------------------- Save Graph ------------------------------

sub good_graph_url {
	
	my ($query, $url) = @_;
	my $vars = $query->Vars;
		
	# No relative URLs
	unless ($url =~ /http:\/\//) {	$vars->{msg} .= "Relative links rejected.<br/>"; return 0; }
		
		
							# Content Constraints		
							# Would like to make this a loadable list at some point
	my @avoid = ('api.tweetmeme.com/','feeds.wordpress.com','api.postrank.com','feeds.feedburner.com','www.diigo.com/user/','http://academicacareers.ca/');	
	foreach my $a (@avoid) {
		if ($url =~ /$a/i) {
			$vars->{msg} .= "Link rejected; do not link $a<br />"; return 0;
		}
	}
	
	return 1;
}

sub save_graph {

	my ($dbh,$query,$graph) = @_;
	my $vars = $query->Vars;
	my $graphid = 0;
	$vars->{msg} .= "<p><i>Save Graph... </i>...";

	# Step ??
	# Create the graph table
	my @tables = $dbh->tables();
	my $tableName = "graph";
	if ((grep/$tableName/, @tables) <= 0) {
		$vars->{msg} .=  "<b>Creating Graph Table</b>";
		my $sql = qq|CREATE TABLE graph (
			  graph_id int(15) NOT NULL auto_increment,
			  graph_type varchar(64) default NULL,
  			  graph_typeval varchar(40) default NULL,
  			  graph_tableone varchar(40) default NULL,
  			  graph_urlone varchar(256) default NULL,
  			  graph_idone varchar(40) default NULL,
  			  graph_tabletwo varchar(40) default NULL,
  			  graph_urltwo varchar(256) default NULL,
  			  graph_idtwo varchar(40) default NULL,  			  
  			  graph_crdate varchar(15) default NULL, 
  			  graph_creator varchar(15) default NULL,   			  
			  KEY graph_id (graph_id)
		)|;
		$dbh->do($sql);
	} 
	


	$graph->{graph_id}="";				# clear id, to prevent accidental overwrites

							# Verify Data
	if ($graph->{graph_urlone}) { return unless (&good_graph_url($query,$graph->{graph_urlone})); } 
	else { unless ($graph->{graph_idone}) { $vars->{msg} .= "Graph rejected; it needs either a first url or id.</p>"; return; } }
	if ($graph->{graph_urltwo}) { 
		return unless (&good_graph_url($query,$graph->{graph_urltwo})); 
		if ($graph->{graph_urlone} eq $graph->{graph_urltwo}) {
			$vars->{msg} .= "Graph rejected; don't graph link to itself.</p>"; return; 
		}
	} 
	else { unless ($graph->{graph_idtwo}) { $vars->{msg} .= "Graph rejected; it needs either a second url or id.</p>"; return; } }	

	
							# Uniqueness Constraints

	my $base; if ($graph->{graph_urlone} =~ m/http:\/\/(.*?)\//) { $base = $1; }	
	if ($graph->{graph_tableone} eq $graph->{graph_tabletwo}) {
		if ($graph->{graph_urltwo} =~ /$base/) {
			$vars->{msg} .= "Graph rejected; do not graph links from the same site.</p>"; return; }	
	}
	
	my $gmsgone = $graph->{graph_tableone}." ".($graph->{graph_idone} || $graph->{graph_urlone});
	my $gmsgtwo = $graph->{graph_tabletwo}." ".($graph->{graph_idtwo} || $graph->{graph_urltwo});	
	
	
						
							
							# Assign default values
	unless ($graph->{graph_type}) { $graph->{graph_type} = "link";  }
	unless ($graph->{graph_crdate}) { $graph->{graph_crdate} = time;  }
	unless ($graph->{graph_creator}) { $graph->{graph_creator} = $Person->{person_id} || 1;  }
	unless ($graph->{graph_idone}) { $graph->{graph_idone} = "-1"; }
	unless ($graph->{graph_idtwo}) { $graph->{graph_idtwo} = "-1"; }
	
	if (&db_locate($dbh,"graph",{
		graph_tableone=>$graph->{graph_tableone},
		graph_idone=>$graph->{graph_idone},
		graph_urlone=>$graph->{graph_urlone},
		graph_tabletwo=>$graph->{graph_tabletwo},
		graph_idtwo=>$graph->{graph_idtwo},
		graph_urltwo=>$graph->{graph_urltwo}})) {
		$vars->{msg} .= "Graph: $gmsgone to $gmsgtwo <br>Graph rejected; graph entry previously recorded.</p>"; return; }



	if ($vars->{analyze} eq "on") { $graphid = "242"; }
	else { $graphid = &db_insert($dbh,$query,"graph",$graph); }
	

	if ($graphid) { $vars->{msg} .= "Graph: $gmsgone to $gmsgtwo </p> \n"; }
	else { $vars->{msg} .= "Graph insert failed. Don't know why. </p>\n"; return 0; }

	
	
	return $graphid;
}

# ---------  Unique ------------------------------------------------

sub unique {

	my ($dbh,$query,$mapping,$mapoutput) = @_;
	my $vars = $query->Vars;

	my $linkfield = $mapping->{mapping_dtable}."_link";
	my $locator_link = $mapoutput->{$linkfield};
	my $titlefield = $mapping->{mapping_dtable}."_title";
	my $locator_title = $mapoutput->{$titlefield};

#	$vars->{msg} .= "Testing for uniqueness in $mapping->{mapping_dtable}<br>\n";

	if ($mapping->{mapping_dtable} eq "event") {
		my $uidfield = $mapping->{mapping_dtable}."_identifier";
		my $locator_uid = $mapoutput->{$uidfield};
		$vars->{msg} .= "<p>$uidfield = $locator_uid<br>\n";
		if (my $l = &db_locate($dbh,$mapping->{mapping_dtable},{$uidfield => $locator_uid})) {
			$vars->{msg} .=  qq|Existing entry, $mapping->{mapping_dtable} $l found.</p>\n|;
			return 0;
		} else {
			$vars->{msg} .=  "$locator_uid not found </p>\n";
		}
	} else {
		$vars->{msg} .= "<p> $linkfield = $locator_link <br />\n";
		if ($locator_link) {
			if (my $l = &db_locate($dbh,$mapping->{mapping_dtable},{$linkfield => $locator_link})) {
				$vars->{msg} .=  qq|Existing entry, $mapping->{mapping_dtable} $l found.</p>\n|;
				return 0;
			} else {
				$vars->{msg} .=  "$locator_link not found </p>\n";
			}
		
		}

		$vars->{msg} .= "<p> $titlefield = $locator_title <br>\n";
		if ($locator_title) {
			if (&db_locate($dbh,$mapping->{mapping_dtable},{$titlefield => $locator_title})) {
				$vars->{msg} .=  "Existing entry (title found).</p>\n";
				return 0;
			} else {
				$vars->{msg} .= "$locator_title not found </p>\n";
			}
		} 

	}

	unless ($locator_link || $locator_title) {
	
		# No link? No title? Stay away from this one
		$vars->{msg} .=  "Entry rejected, no link and no title found.<br/>\n";
		return 0;
		
	}

	return 1;
}

#--------------------------------------------------------------------------------
#
#
#                      Mapping Functions
#
#
#---------------------------------------------------------------------------------

# ---------  Default Mapping ------------------------------------------------

sub map_default {

	my ($dbh,$query,$feed_type) = @_;

	
	my $mapping = {
		mapping_prefix => "link",
		mapping_priority => "0",
		mapping_dtable => "link",
		mapping_stype => "default",
		mapping_title => "Default: link -> link",
		mapping_mappings => qq| 			
			link_hits,link_hits;
			link_title,link_title;
			link_type,link_type;
			link_link,link_link;
			link_topics,link_topics;
			link_author,link_author;
			link_description,link_description;
			link_content,link_content;
			link_category,link_category;
			link_status,link_status;
			link_genre,link_genre;
			link_class,link_class;
			link_crdate,link_crdate;
			link_issued,link_issued;
			link_modified,link_modified;
			link_authorurl,link_authorurl;
			link_authorname,link_authorname;
			link_feedid,link_feedid;
			link_feed,link_feed;			
			link_feedname,link_feedname|,
		mapping_values => ""
	};
	$mapping->{mapping_mappings} =~ s/\s//g;
	return $mapping;

}

# ---------  iCal Mapping ------------------------------------------------

sub map_ical {

	my ($dbh,$query,$feed_type) = @_;


	my $mapping = {
		mapping_prefix => "event",
		mapping_priority => "0",
		mapping_dtable => "event",
		mapping_stype => "default",
		mapping_title => "Default: iCal -> event",
		mapping_mappings => qq| 
			event_hits,event_hits;
			event_title,event_title;
			event_type,event_type;
			event_link,event_link;
			event_topics,event_topics;
			event_start,event_start;
			event_icalstart,event_icalstart;
			event_finish,event_finish;
			event_icalend,event_icalend;
			event_localtz,event_localtz;
			event_identifier,event_identifier;
			event_identifier,event_identifier;
			event_stamp,event_stamp;
			event_uid,event_uid;
			event_location,event_location;
			event_attendee,event_attendee;
			event_created,event_created;
			event_modified,event_modified;
			event_sequence,event_sequence;
			event_description,event_description;
			event_transp,event_transp;	
 			event_author,event_author;
			event_content,event_content;
			event_category,event_category;
			event_crdate,event_crdate;
			event_issued,event_issued;
			event_modified,event_modified;
			event_authorurl,event_authorurl;
			event_authorname,event_authorname;
			event_feedid,event_feedid;
			event_feedname,event_feedname;
			event_category,event_category|,
		mapping_values => ""
	};
	$mapping->{mapping_mappings} =~ s/\s//g;
	return $mapping;

}

# ---------  Map Maphash ------------------------------------------------

sub map_maphash {

	my ($mapping) = @_;
	

	my $maphash = {};
	my @maplist = split ";",$mapping->{mapping_mappings};
	foreach my $mapitem (@maplist) { 
		my ($mapfrom,$mapto) = split /,/,$mapitem;
		$maphash->{$mapfrom} = $mapto;
	}
	$mapping->{maphash} = $maphash;
	return $maphash;	


}

# ---------  Map to Output ------------------------------------------------

sub map_to_output {

	my ($mapping,$maphash,$ldata) = @_;

	# Map to Output via Mapping Hash
	my $mapoutput = {};
	while (my($ldx,$ldy) = each %$ldata) {
		next unless ($maphash->{$ldx});
		$mapoutput->{$maphash->{$ldx}} = $ldy;
	}

	# Map specified field values
	my @field_values = split ";",$mapping->{mapping_values};
	foreach my $fv (@field_values) {
		my ($fkey,$fval) = split ",",$fv;
		$mapoutput->{$fkey}=$fval;
	}

	# Creator, crdate
	my $crfield = $mapping->{mapping_dtable}."_crdate";
	my $crid = $mapping->{mapping_dtable}."_creator";
	$mapoutput->{$crfield}=time;
	$mapoutput->{$crid}=1;

	return $mapoutput;


}

# ---------  Mapping Field List ------------------------------------------------

#	Gets a list of mappings to entries with given fields
#	Returns a hash with the field name as key and mapping id as value

sub map_field_list {

	my ($dbh) = @_;
	my $field_list = {};

 	my $sql = qq|SELECT mapping_id,mapping_feed_fields FROM mapping WHERE mapping_stype = 'mapping_feed_fields' ORDER BY mapping_priority|;
	my $sth = $dbh -> prepare($sql);
	$sth -> execute();
	while (my $maps = $sth -> fetchrow_hashref()) {
		$field_list->{$maps->{mapping_feed_fields}} = $maps->{mapping_id};
	}
	return $field_list;


}

# ---------  Mapping Field Pair List ------------------------------------------------

#	Gets a list of mappings to entries with given values in given fields
#	Returns a hash with the field name and value (field:value) as key and mapping id as value

sub map_field_value_pair {

	my ($dbh) = @_;
	my $field_value_pair = {};

 	my $sql = qq|SELECT mapping_id,mapping_field_value_pair FROM mapping WHERE mapping_stype = 'mapping_field_value_pair' ORDER BY mapping_priority|;
	my $sth = $dbh -> prepare($sql);
	$sth -> execute();
	while (my $maps = $sth -> fetchrow_hashref()) {
		$field_value_pair->{$maps->{mapping_feed_fields}} = $maps->{mapping_id};
	}
	return $field_value_pair;


}

# ---------  Map Entry Mapping ------------------------------------------------

sub map_entry_mapping {

	my ($dbh,$ldata,$field_list,$field_value_pair,$mapping) = @_;

	# Mapping Feed Fields - Applies a mapping is entry has a value in the field
	while (my ($fx,$fy) = each %$field_list) {
		if ($ldata->{$fx}) {
			my $mapping_priority = $mapping->{mapping_priority} || 1;
			my $temp_mapping = &db_get_record($dbh,"mapping",{mapping_id=>$fy});
			if ($temp_mapping->{mapping_priority} >= $mapping_priority) {
				$mapping = $temp_mapping;
				$vars->{msg} .= "Mapping for field type detection. \n";
			}
			last;
		}
	}


	# Mapping Field Value Pairs - Applies a mapping is entry has a value in the field
	while (my ($fx,$fy) = each %$field_value_pair) {
		my ($cfield,$cvalue) = split ":",$fx;
		if ($ldata->{$cfield} eq $cvalue) {
			my $mapping_priority = $mapping->{mapping_priority} || 1;
			my $temp_mapping = &db_get_record($dbh,"mapping",{mapping_id=>$fy});
			if ($temp_mapping->{mapping_priority} >= $mapping_priority) {
				$mapping = $temp_mapping;
				$vars->{msg} .= "Mapping for field value pair. \n";
			}
			last;
		}
	}

	return $mapping;
}




# -------   Header ------------------------------------------------------------

sub header {

	my ($dbh,$query,$table,$format,$title) = @_;
	my $template = "admin_header";

	return &template($dbh,$query,$template,$title);

}

# -------   Footer -----------------------------------------------------------

sub footer {

	my ($dbh,$query,$table,$format,$title) = @_;
	my $template = "admin_footer";
	return &template($dbh,$query,$template,$title);

}

# -------  Make Admin Links -------------------------------------------------------
#


sub make_admin_links {

	my ($input) = @_;



}
