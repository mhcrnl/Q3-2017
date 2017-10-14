#!/usr/bin/perl

#    gRSShopper 0.3  Page  0.41  -- gRSShopper administration module
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
#
#-------------------------------------------------------------------------------
#
#	    gRSShopper 
#           Public Page Script 
#
#-------------------------------------------------------------------------------

#print "Content-type: text/html\n\n";
				


# Initialize gRSShopper Library

use FindBin qw($Bin);
require "$Bin/grsshopper.pl";
our ($query,$vars) = &load_modules("page");





# Initialize Session --------------------------------------------------------------



my $options = {}; bless $options;		# Initialize system variables
our $cache = {}; bless $cache;	
						
our ($Site,$dbh) = &get_site("page");		# Get Site Information
unless (defined $Site) { die "Site not defined."; }

our $Person = {}; bless $Person;		# Get User Information
&get_person($dbh,$query,$Person);		
my $person_id = $Person->{person_id};
# print "You are person number $Person->{person_id} <br>";



						# Redirect old-style Requests 

if ($vars->{q}) {
	my ($toss,$crdate) = split "=",$vars->{q};
	my $stmt = qq|SELECT post_id FROM post WHERE post_crdate=?|;
	my $sth = $dbh -> prepare($stmt);
	$sth -> execute($crdate);
	my $ref = $sth -> fetchrow_hashref();
	print "Content-type: text/html; charset=utf-8\n";
	print "Location: http://www.downes.ca/cgi-bin/page.cgi?post=",$ref->{post_id},"\n\n";
	exit;
}




# Analyze Request --------------------------------------------------------------------

my $table; my $id; my $format; my $action;



$action = $vars->{action};			# Determine Action
if ($vars->{button} eq "Submit") {
	$action = "update"; 
	$vars->{post_type} = "comment";
	$vars->{force} = "yes";
} elsif ($vars->{button} eq "Preview") {
	$action = "update";
	$vars->{post_type} = "comment";
	$vars->{force} = "yes";
}

						# Determine Request Table, ID number
foreach my $req ("link",
		"post",
		"page",
		"chat",
		"journal",
		"media",
		"presentation",
		"publication",
		"topic",
		"author",
		"person",
		"event",
		"feed",
		"thread") {
	if ($vars->{$req}) { 
		$table = $req; 
		$id = $vars->{$req}; 
		last; 
	}
}

						# Direct DB and list requests
if ($vars->{db} || $vars->{table}) {
	$table = $vars->{table} || $vars->{db};
	if ($vars->{id}) {
		$id = $vars->{id};
	} else {
		unless ($action) { 
			$action = "list"; 
		}
	}
}

if ($vars->{format}) {				# Determine Output Format
	$format = $vars->{format};
} else {
	$format = "html";
}


# API
my $api = $vars->{api};

# 	Diagnostic
#	print "Action: $action Table $table <p>";

unless ($table || $action || $api) {				# Default to Home

	print "Content-type: text/html; charset=utf-8\n";
	print "Location:".$Site->{st_url}."\n\n";
	exit; 
}



# Actions ------------------------------------------------------------------------------

	
if ($api) {

	for ($api) {
		
		/graph/ && do { &api_graph($dbh,$query); last;  };	
			
									# Go to Home Page
		if ($dbh) { $dbh->disconnect; }			# Close Database and Exit
		print "Content-type: text/html; charset=utf-8\n";
		print "Location:".$Site->{st_url}."\n\n";
		exit;
		
	}
	exit;
	
} elsif ($action) {						# Perform Action, or


	for ($action) {
		/rd/ && do { &redirect($dbh,$query,$table,$id); last; 	};
		/search/ && do { &search($dbh,$query); last; 	};
		/list/ && do { &list_records($dbh,$query,$table); last;		};
		/edit/ && do { &edit_record($dbh,$query,$table,$id); last; 		};
		/update/ && do { $id = &update_record($dbh,$query,$table,$id);
			&received($dbh,$query,$table,$id); last; 			};
		/viewer/ && do { &viewer($dbh,$query,$table,$format); last; 	};
		/meetings/ && do { &meetings($dbh,$query); last; 	};		
		/join_meeting/ && do { &join_meeting($dbh,$query); last; 	};	
		/moderate_meeting/ && do { &moderate_meeting($dbh,$query); last;	};		
		/unsub/ && do { &comment_unsubscribe($dbh,$query,$table,$format); last; 	};



							# Go to Home Page
		if ($dbh) { $dbh->disconnect; }			# Close Database and Exit
		print "Content-type: text/html; charset=utf-8\n";
		print "Location:".$Site->{st_url}."\n\n";
		exit;

	}


} else {					# Default Data Output

	&output_record($dbh,$query,$table,$id,$format);

}
						


# TEMPORARY
#
# Logging requests for diagnostics
#

#open POUT,">>/var/www/cgi-bin/logs/page_access_log.txt" || print "Error opening log: $! <p>";
#print POUT "$ENV{'REMOTE_ADDR'}\t$table\t$id\t$format\t$action\t$ENV{'HTTP_USER_AGENT'}\n" 
#	 || print "Error printing to log: $! <p>";
#close POUT;



if ($dbh) { $dbh->disconnect; }			# Close Database and Exit
exit;




#-------------------------------------------------------------------------------
#
#           Functions 
#
#-------------------------------------------------------------------------------
	
sub redirect {

	my ($dbh,$query,$table,$id) = @_;
	&db_increment($dbh,$table,$id,"hits");
	&db_increment($dbh,$table,$id,"total");
	my $linkfield = $table."_link";
	my $url = db_get_single_value($dbh,$table,$linkfield,$id);
	unless ($url) { $url = $Site->{st_url}.$table."/".$id; }
	print "Content-type:text/html\n";
	print "Location: $url\n\n";
	exit;
}

# -------   Header ------------------------------------------------------------

sub header {

	my ($dbh,$query,$table,$format,$title) = @_;
	my $template = $Site->{lc($format) . "_header"} || lc($format) . "_header";

	return &get_template($dbh,$query,$template,$title);

}

# -------   Footer -----------------------------------------------------------

sub footer {

	my ($dbh,$query,$table,$format,$title) = @_;
	my $template = $Site->{lc($format) . "_footer"} || lc($format) . "_footer";
	return &get_template($dbh,$query,$template,$title);


}






#-------------------------------------------------------------------------------
#
#           Menu Functions 
#
#-------------------------------------------------------------------------------



#-------------------------------------------------------------------------------
#
# -------   List Records -------------------------------------------------------
#
#           List records of a certain type
#	      Edited: 27 March 2010
#-------------------------------------------------------------------------------

sub list_records {

	my ($dbh,$query,$table) = @_;
	my $vars = ();
	if (ref $query eq "CGI") { $vars = $query->Vars; }
	$vars->{force} = "yes";




						# Troubleshoot Input, normally commented out
#	print "Content-type: text/html; charset=utf-8\n\n";	
#	while (my($lx,$ly) = each %$vars) { print "$lx = $ly <br>"; }


						# Output Format
	my $format = $table ."_list";

						# Print Page Header
	if ($vars->{format} =~ /html/i) {	

		print "Content-type: text/html; charset=utf-8\n\n";				
		print $Site->{header};
		print "<h2>List ".$table."s</h2>";
		if ($vars->{msg}) {
			print qq|<p class="notice">$vars->{msg}</p>|;
		}
	} elsif ($vars->{format} =~ /json/i) {
		print "Content-type: application/json; charset=utf-8\n\n";
		my $jsontitle = $table."s";
		print qq|{"$jsontitle":[\n|;
	}
						# Init SQL Parameters

	my $count; my $sort; my $start; my $number; my $limit;
	my $where = "WHERE ";

						# Admin Display

	if ($Person->{person_status} eq "admin") {			
		$count = &db_count($dbh,$table);
		($sort,$start,$number,$limit) = &sort_start_number($query,$table);

						# User Display
	} else {									
		my $owner = $Person->{person_id}; 
		my $owh = $table.qq|_creator='$owner'|;
		if ($table eq "thread") { $owh .= " OR thread_status='active'"; }
		$count = &db_count($dbh,$table,$owh);
		($sort,$start,$number,$limit) = &sort_start_number($query,$table);
 		$where .= $owh;
	}

						

						# Execute SQL search

	if ($where eq "WHERE ") { $where = ""; }
	my $stmt = qq|SELECT * FROM $table $where $sort $limit|;	
#	print "SQL: $stmt <p>";
	my $sthl = $dbh->prepare($stmt);
	$sthl->execute();

						# Print Search Summary
	my $stname = "";
	if ($Person->{person_status}) { $stname = "everyone"; }
	else { $stname .= $Person->{person_name}; }
	my $status = "<p>Listing $start to ".($start+$number)." of $count ".$table."s belonging to $stname<br/>";
	$status .= "You are person number: $Person->{person_id} <script language=\"Javascript\">login_box();</script></p>";

	if ($vars->{format} =~ /html/) {	
		print &pr_status($status);
		print "<p>\n";
	}
						# Process Records

	my $recordlist = "";
	while (my $list_record = $sthl -> fetchrow_hashref()) {

						# Troubleshoot Search (Normally commented out)

#		print "<hr>";
#		while (my($lx,$ly) = each %$list_record) { 
#			print "$lx = $ly <br>"; 
#		}
	

						# Format Record
						
		my $record_text = &format_record($dbh,
			$query,
			$table,
			$vars->{format},
			$list_record,1);
			
		&make_admin_links(\$record_text);	
		&autodates(\$record_text);

						# Print Record
		$recordlist .= $record_text . "\n";

	}
	$recordlist =~ s/ *$//g;
	$recordlist =~ s/,$//g;		# Remove trailing comma from list

	print $recordlist;


	if ($vars->{format} =~ /html/) {
		print "</p>";
	
						# Print Page Footer
		print "<p>";
		print &next_button($query,$table,"list",$start,$number,$count);
		$sthl->finish( );
		print $Site->{footer};
	
		return 1;
	} elsif ($vars->{format} =~ /json/) {
		print " ]}\n";
	}
}


#-------------------------------------------------------------------------------
#
# -------   Meetings --------------------------------------------------------
#
#           List BBB Meetings
#	      Edited: 16 September 2011
#
#-------------------------------------------------------------------------------



sub meetings {
	
	
	my ($dbh,$query) = @_;
	$vars = $query->Vars; 
	
	
	print "Content-type: text/html; charset=utf-8\n\n";
	print $Site->{header};
	
	print "<h1>Live Meetings</h1>";
	
	my $meeting_con = &bbb_get_meetings();
	my $meetingcount = 0;
	
	$Person->{person_name} ||= $Person->{person_title};
	$content .= qq|<h3>Current Live Meetings</h3>
		<form method="post" action="$Site->{st_cgi}page.cgi">
		<p>These are the live meetings currently running ion $Site->{st_name}. If you would
		like to enter the confreencing environment and join the meeting, please provide a 
		name and then select the meeting you would like to join.<br/><br/>
		
		Enter your name: <input size="40" type="text" name="username" value="$Person->{person_name}"></p>
		
		<input type="hidden" name="action" value="join_meeting">

		<ul><table cellpadding="5" cellspacing="0" border="0">|;
	
	while ($meeting_con =~ /<meeting>(.*?)<\/meeting>/g) {
		$meetingcount++; my $meeting = (); my @moderators;
		my $meet_data = $1; my $meeting_id; my $meeting_name; my $meeting_started;

		while ($meet_data =~ /<meetingName>(.*?)<\/meetingName>/g) { $meeting->{name} = $1; }	
		next if ($meeting->{name} eq "Administrator Meeting");
		
		while ($meet_data =~ /<meetingID>(.*?)<\/meetingID>/g) { $meeting->{id} = $1; }
		$meeting->{info} = &bbb_getMeetingInfo($meeting->{id});
		
		while ($meeting->{info} =~ /<participantCount>(.*?)<\/participantCount>/g) { $meeting->{count} = $1; }
		while ($meeting->{info} =~ /<attendee>(.*?)<\/attendee>/g) { 
			my $attendee = $1; my $a = ();
			while ($attendee =~ /<role>(.*?)<\/role>/g) { $a->{role} = $1; }
			while ($attendee =~ /<fullName>(.*?)<\/fullName>/g) { $a->{fn} = $1; }
			if ($a->{role} =~ /moderator/i) {			
				if ($meeting->{mods}) { $meeting->{mods} .= ", "; }
				$meeting->{mods} .= $a->{fn};	
			}
		}
			
		while ($meet_data =~ /<createTime>(.*?)<\/createTime>/g) { $meeting_started = $1; }	
		$content .= qq|<tr><td align="right"><b>$meeting->{name}</b> - $meeting->{count} participant(s)<br/>
				Moderator(s): $meeting->{mods} </td>
				<td valign="top">
				<input type="submit" name="meeting_id" 
				value="Join Meeting $meeting->{id}"></td></tr>|;	
 # $content .= qq|<form><textarea cols="50" rows="10">$meet_data\n\n$meet_info</textarea></form><p>|;	
	}
	$content .= "</table></ul></p></form>";
	if ($meetingcount ==0) {
		$content .= "<p><ul>There are currently no live meetings taking place.</ul></p>";
	}

	if ( ( $Person->{person_id} > 2  ) ||
		( $Person->{person_status} eq "admin" ) ) {
		my $newid = time;	
		$content .= qq|<h3>Create and Join a Meeting</h3>
			<form method="post" action="$Site->{st_cgi}page.cgi">
			<p><ul>
			<input type="hidden" name="action" value="moderate_meeting">
			<table cellpadding="2" cellspacing="0" border="0">
			<tr><td align="right">Meeting Name:</td><td><input type="text" name="meeting_name" size="40"></td></tr>
			<tr><td align="right">Meeting Ident:</td><td><input type="text" name="meeting_id" value="$newid" size="40"></td></tr>
			<tr><td align="right" colspan="2"><input type="submit" value="Create Meeting and Join It"></td></tr>
			</table></ul></p></form>|;
	} else {
		
		$content .= "<p>If you are registered and logged in, you may create your
			own live meetings right here any time you want.</p>";
	}
		
		
	$content .= qq|<h3>Meeting System Help</h3>
		<p><ul><a href="http://www.bigbluebutton.org/sites/all/videos/join/index.html">  
		<img src="http://bigbluebutton.org/sites/default/files/images/student_vid_0.png" 
		alt="Video Student" title="Video Student" class="image image-_original " 
		style="padding: 3px; border: 1px solid rgb(175, 175, 175); margin-top: -5px;" 
		height="108" width="163"></a><br>
		Viewer Overview</strong> [3:35] How to use BigBlueButton as a viewer.<br/>
		<a href="http://www.bigbluebutton.org/sites/all/videos/join/index.html">Play Video</a></ul></p>|;
	
	print $content;	
		
	print $Site->{footer};
	exit;


}

#-------------------------------------------------------------------------------
#
# -------   Join Meeting --------------------------------------------------------
#
#           Join BBB Meetings
#	      Edited: 16 September 2011
#
#-------------------------------------------------------------------------------

sub join_meeting {
	
	my ($dbh,$query) = @_;
	my $vars = $query->Vars;
	
	$vars->{meeting_id} =~ s/Join Meeting //;
	my $uname = $vars->{username} || $Person->{person_name}; 
	
#	unless ($vars->{meeting_name}) { $vars->{meeting_name} = "Administrator Meeting"; }	
#	unless ($vars->{meeting_id}) { $vars->{meeting_id} = "12345"; }		

	&bbb_join_meeting($vars->{meeting_id},$uname,$Person->{person_title});

	exit;


	
}

#-------------------------------------------------------------------------------
#
# -------   Moderate Meeting --------------------------------------------------------
#
#           Create BBB Meetings
#	      Edited: 17 September 2011
#
#-------------------------------------------------------------------------------
sub moderate_meeting {
	
	my ($dbh,$query) = @_;
	my $vars = $query->Vars;
	
	unless ($vars->{meeting_name}) { $vars->{meeting_name} = "Generic Meeting"; }	

	unless ($vars->{meeting_id}) { $vars->{meeting_id} = "12345"; }		


	&bbb_join_as_moderator($vars->{meeting_id},$Person->{person_name},$Person->{person_title});

	exit;


	
}

#-------------------------------------------------------------------------------
#
# -------   Edit Record --------------------------------------------------------
#
#           Edit records of a certain type
#	      Edited: 27 March 2010
#
#-------------------------------------------------------------------------------



sub edit_record {

						# Get variables
						
	my ($dbh,$query,$table,$id_number) = @_;
	my $vars = ();
	if (ref $query eq "CGI") { $vars = $query->Vars; }
	$vars->{force} = "yes";		# Never use cache on edit


						# Autoblog Redirect
						# if already commented upon

	if ($vars->{autoblog}) {
		my $ref = &db_get_record($dbh,"link",{link_id=>$vars->{autoblog}});
		my $url = $ref->{link_link};
		my $linkpostid = &db_locate($dbh,"post",{post_link => $url});
		if ($linkpostid) {
			my $newurl = $Site->{st_url}."post/".$linkpostid;
			print "Content-type: text/html; charset=utf-8\n";
			print "Location: $newurl\n\n";
		}
	}


	print "Content-type: text/html; charset=utf-8\n\n";
# while (my($vx,$vy) = each %$vars) { print "$vx = $vy <br/>"; }
	print $Site->{header};

						# Troubleshoot Input, normally commented out

#	while (my($lx,$ly) = each %$vars) { print "$lx = $ly <br>"; }

	
						# Define Form Contents

	my $showcols;
	
	if ($Person->{person_status} eq "admin") {
						
	   $showcols = {
		event => ["title","identifier","link","type","group","start","finish","starttime","finishtime","location","description","environment","star","host","owner_url","sponsor","sponsor_url","access","parent","crdate","creator","submit"],
		feed => ["title","link","html","type","author","creator","country","journal","category","status","description","submit"],
		post => ["title","link","author","journal","type","thread","offset","crdate","description","submit","content"],
		thread => ["title","description","tag","refresh","textsize","updated","current","srefresh","supdated","active","status","submit"]
		};

	} else {

	   $showcols = {
		event => ["title","identifier","link","start","finish","location","description","environment","star","host","owner_url","sponsor","sponsor_url","access","parent","submit"],
		feed => ["title","link","html","type","author","country","category","status","description","submit"],
		post => ["title","description","submit"],
		thread => ["title","description","tag","refresh","textsize","updated","current","srefresh","supdated","active","status","submit"]
		};
	}

	if ($vars->{autoblog}) {
		$showcols->{post} = ["title","link","journal","author","description","submit"];
	}

	my $form_text = &form_editor($dbh,$query,$table,$showcols,$id_number);


	
	print $form_text;
	print $Site->{footer};
	


}


# -------   Output Record ------------------------------------------------------

sub output_record {

	my ($dbh,$query,$table,$id_number,$format) = @_;

	print "Content-type: text/html\n\n";


	&error($dbh,"","","Output Table is not defined.") unless (defined $table && $table);
	
 if ($table eq "topic") {
	print "Content-type: text/html; charset=utf-8\n\n";
	print "Access to topics is disabled for the moment while I fix the code.";
	exit;
}

	my $vars = $query->Vars;
	$vars->{comment} = "yes";

											# If ID is specified as text
	unless ($id_number =~ /^[+-]?\d+$/) {					# Try to find by title
		$id_number = &find_by_title($dbh,$table,$id_number);
		if ($vars->{table} eq "feed") { $table = "feed"; }
	}
	

	my $fields = &set_fields($table);


						# Remove from Unread list
					
	 my $toread = $table . "toread";
	 my $totable = "lr_".$table;
	 my $toperson = "lr_person";
	 my $tstmt = "DELETE FROM $toread WHERE $totable = '$id_number' AND lr_person = '$Person->{person_id}'";
	# $dbh->do($tstmt);
	

						# Get and Print Record Cache

	my $cacheformat = uc($vars->{format}) || "htm";
	my $cache_title = "PAGE_".$table."_".$id_number."_".$cacheformat;
	
	


	my $record_cache;
#	$record_cache = &db_get_record_cache($dbh,$cache_title);
	unless ($vars->{force} eq "yes") {				# Allow cache override
		if (  ($record_cache->{cache_text}) 
			&& ($record_cache->{cache_update} gt (time-$Site->{pg_update})) 
			&& ($record_cache->{cache_text} ne "NULL" ) 
			&& ($vars->{force} ne "yes") ) {
	
		 								# Fill special Admin links
			&make_admin_links(\$record_cache->{cache_text});		
			&make_login_info($dbh,$query,\$record_cache->{cache_text},$table,
				$id_number);
	
			print $record_cache->{cache_text};		# print cached version			
			return;
		}
	}
	
						# Not in the Cache? Then...
						# Get Record from DB


	my $wp = &db_get_record($dbh,$table,{$fields->{id}=>$id_number});

	unless ($wp) { &error($dbh,$query,"","404",
			qq|Looking for $table number $id_number, but it was not found, sorry.|); }



						# Title and Feed
	$wp->{page_title} = $wp->{$fields->{title}} || $wp->{$fields->{name}};
	unless ($table =~ /post|link/i) {
		$wp->{page_feed} = $Site->{st_cgi}."page.cgi?".$table."=".
			$id_number."&format=rss";
	}
	#$Site->{header} =~ s/\Q[*page_title*]\E/$wp->{$title}/g;

	
						# Set Formats

	my ($page_format,$record_format,$mime_type) =
		&set_formats($dbh,$query,$wp,$table);


						# Put Record Data Into Template 

	$wp->{page_content} = &format_record($dbh,$query,$table,$record_format,$wp);


						# For non-Page Records, Add Header and Footer

	if ($page_format =~ /thread/i) { $page_format = "html"; }
	$page_format ||= "html";
	unless ($table eq "page" || $format eq "viewer") {

		my $header_template = "page_header";
		my $footer_template = "page_footer";
		
		if ($page_format && ($page_format ne "html")) { 
			
print "<b>Defining</b>: $page_format --<p>";			
			$header_template = $Site->{lc($page_format) . "_header"} || lc($page_format) . "_header";
			$footer_template = $Site->{lc($page_format) . "_footer"} || lc($page_format) . "_footer";
		}


		if (defined $wp->{page_content}) {
			$wp->{page_content} =
				&db_get_template($dbh,$header_template) . $header_template .
				$wp->{page_content} . $footer_template . &db_get_template($dbh,$footer_template);	
		} else {
			$wp->{page_content} =
				&db_get_template($dbh,$header_template) .
				"This page has no content." . &db_get_template($dbh,$footer_template);	
		}


	}


						# Format Record Content

	$wp->{table} = $table;
	&format_content($dbh,$query,$options,$wp);

		
						# Save To Cache
				 
	my $cache_update = time;
	$cache_title = "PAGE_".$table."_".$id_number."_".$page_format;
	my $cache_text = "Content-type: ".$mime_type."\n\n";
	$cache_text .= $wp->{page_content};

	&db_save_record_cache($dbh,$cache_update,$cache_title,$cache_text);
# print "Saving $cache_title <br>";	

	 					# Fill special Admin links and post-cache content
	&make_pagedata($query,\$wp->{page_content});	
	&make_admin_links(\$wp->{page_content});
	&make_login_info($dbh,$query,\$wp->{page_content},$table,$id_number);
	

						# Increment Hit Counter
	my $field = "hits";
	if ($table eq "post" || $table eq "link") {    # Temporary, will eventuially be for all data
		&db_increment($dbh,$table,$id,"hits");
		&db_increment($dbh,$table,$id,"total");
	}	
						# Print Record

	$wp->{page_content} =~ s/\Q]]]\E/] ]]/g;   # Fixes a Firefox XML CDATA bug
	print "Content-type: ".$mime_type."\n\n";
						# Fill timezone dates
	&autotimezones($query,\$wp->{page_content});
	print $wp->{page_content};


}

#-------------------------------------------------------------------------------
#
# -------   Update Record ------------------------------------------------------
#
#           Receives Form Input
#		Creates New Record or and Updates Existing Record
#	      Edited: 28 March 2010
#
#-------------------------------------------------------------------------------


sub update_record {


						# Define Import Variables
					
	my ($dbh,$query,$table,$id_number) = @_;
	&error($dbh,$query,"","Database not ready") unless ($dbh);
	my $vars = $query->Vars;

 #print "Content-type: text/html; charset=utf-8\n\n";


						# Validate Input

	&error("nil",$query,"","Database not ready") unless ($dbh);
	&error($dbh,$query,"","Table not specified") unless ($table);
	&error($dbh,$query,"","Fishy ID") unless ($id_number);


						# Permissions
	
	if ($id =~ /new/i) {	return unless (&is_allowed("create",$table)); } 
	else { 	
		my $id_field = $table."_id";
		my $record = &db_get_record($dbh,$table,{$id_field=>$id_number});
		return unless (&is_allowed("edit",$table,$record)); 
	}

						# Filter and process acceptable content types

	if ($table eq "event") {
		return unless (&is_allowed("create","event")); 
		unless ($vars->{event_title}) { &error($dbh,"","","Event must have a title."); }
		unless ($vars->{event_owner_url}) { &error($dbh,"","","Event must have an owner URL."); }
		unless ($vars->{event_link}) { &error($dbh,"","","Event must have an information URL."); }
		unless ($vars->{event_access}) { &error($dbh,"","","Event must have an access URL."); }
		unless ($vars->{event_start}) {	# Create dates from special form
			($vars->{event_start},$vars->{event_finish}) = &process_event_dates($dbh,$query);
		}						# Then create unix start and finish times
		$vars->{event_starttime} = &rfc3339_to_epoch($vars->{event_start});
		$vars->{event_finishtime} = &rfc3339_to_epoch($vars->{event_finish});
		&in_anti_spam($dbh,$query);		# No Spam!



	} elsif ($table eq "feed") {

		unless ($vars->{feed_title}) { &error($dbh,"","","Feed must have a title."); }
		unless ($vars->{feed_link}) { &error($dbh,"","","Feed must have an information URL."); }
		$vars->{feed_status} = "O";

	} elsif ($table eq "post") {
										# Establish Post Type

 	# Default to Comment

		if ($vars->{newautoblog}) {				# Autoblog, first input, default to Link
			$vars->{post_type} = "link";
			$id_number = "new";

		} elsif ($id_number eq "new") {
			unless ($Person->{person_status} eq "admin") { 
				$vars->{post_type} = "comment"; 
			}
		} 

 										# Error Check
		if ($vars->{post_type} eq "link") {
			unless ($vars->{post_link}) { &error($dbh,"","","Autoblog Error."); }
		} else {
			unless ($vars->{post_description}) { &error($dbh,"","","Empty Post Disallowed"); }
			&in_anti_spam($dbh,$query);			# No Spam!
		}

	} elsif ($table eq "thread") {
		unless ($vars->{thread_title}) { &error($dbh,"","","Thread must have a title."); }
		unless ($vars->{thread_description}) { &error($dbh,"","","Thread must have an information URL."); }

	} else {
		&error($dbh,"","","Invalid submission type.");
	}

						# Set Field Names

	my $fields = &set_fields($table);
		

						# Clean Input

	while (my ($vkey,$vval) = each %$vars) {
		$vars->{$vkey} =~ s/#!//g;				# No programs!
		$vars->{$vkey} =~ s/“/"/g;	# "
		$vars->{$vkey} =~ s/”/"/g;	# "
		$vars->{$vkey} =~ s/—/-/g;	# '
		$vars->{$vkey} =~ s/‘/'/g;	# '
		$vars->{$vkey} =~ s/’/'/g;	# '
		$vars->{$vkey} =~ s/…/.../g;	# ...
		$vars->{$vkey} =~ s/'/&apos;/g;	#     No SQL injections

		$vars->{$vkey} =~ s/<(\/|)(a|e|t)(.*?)>//sig;	# No links, embeds, tables
	}
	$vars->{$fields->{description}} =~ s/\n/<br\/>/g;
	
	

					# Submit Data

	if ($id_number eq "new") {	# Create Record, or

		$vars->{$fields->{crdate}} = time;
		if ($vars->{newautoblog}) { $vars->{$fields->{source}} = "autoblog"; }
		else  { $vars->{$fields->{source}} = "page"; }
		$vars->{$fields->{creator}} = $Person->{person_id};
		$vars->{$fields->{author}} = $Person->{person_name} || $Person->{person_title};
		$vars->{$fields->{crip}} = $ENV{'REMOTE_ADDR'};
		$id_number = &db_insert($dbh,$query,$table,$vars);

		$vars->{msg} .= "Created new $table ($id_number)";

		if ((!$vars->{post_thread}) || ($vars->{post_thread} =~ /new/i)) {
				my $ok = &db_update($dbh,$table, {post_thread => $id_number}, $id_number);
		}

	} else {				# Update Record

		unless ($vars->{$fields->{author}}) { $vars->{$fields->{author}} = $Person->{person_name} || $Person->{person_title}; }

		my $where = { $fields->{id} => $id_number};
		$id_number = &db_update($dbh,$table, $vars, $id_number);
		$vars->{msg} .= ucfirst($table)." $id_number successfully updated";

 	}

						# Finish here is it's an autopost

	return $id_number if ($vars->{post_type} eq "link");


					# Remove Cache 
					# (So people can see their comments)

	my $emptycache = "NULL";
	if ($table eq "post") {
		my $cachepost = &db_get_record($dbh,"post",{post_id=>$id_number});
		&db_update($dbh,"post", {post_cache => $emptycache}, $cachepost->{post_thread});
	}

					# Send Email notifications
					# (If user has finished editing)
						
	return $id_number unless ($vars->{button} eq "Submit");

	if ($table eq "event") {

		$vars->{msg} .= "Event number $id_number successfully added";
		return $id_number;
	}	

					# Update email notification list
	if ($vars->{anon_email}) {						# Detect anonymous email
		$vars->{post_email_checked} = "checked";
		$Person->{person_email} = $vars->{anon_email};
	}
				
	if ($vars->{post_email_checked} eq "checked") {			
		&add_to_notify_list($dbh,$Person->{person_email},$vars->{$fields->{thread}});
	} else {
		&del_from_notify_list($dbh,$Person->{person_email},$vars->{$fields->{thread}});	
	}

					# Create Email Body

	# Get Thread Title
	my $ttitle = &db_get_single_value($dbh,"post","post_title",$vars->{$fields->{thread}});
	$ttitle = "Comment on: ".$ttitle;

	# Get Record Content
	my $wp = &db_get_record($dbh,$table,{$fields->{id}=>$id_number});

	# Put Into HTML Email Template
	$wp->{page_content} = "<p>A new comment has been posted on " .
		"$Site->{st_name} in response to \"$ttitle\"</p>" . $wp->{page_content};	
	$wp->{page_content} .= &format_record($dbh,$query,"post","post_comment_notify",$wp);
	$wp->{page_content} .= qq|<a href="$Site->{st_cgi}page.cgi?action=unsub&email=<SUBSCRIBEE>&thread=$vars->{$fields->{thread}}">
		Click here to unsubscribe</a> from comments to this post.|;

	# Put Inside Email header, Footer
	my $hdr = &get_template($dbh,$query,"email_html_comment_header",$ttitle);
	my $ftr = &get_template($dbh,$query,"email_html_comment_footer",$ttitle);
	$wp->{page_content} = $hdr . $wp->{page_content} . "<admin/>". $ftr;

	# Dates
	my $today = &nice_date(time);
	$wp->{page_content} =~ s/#TODAY#/$today/;
	&autodates(\$wp->{page_content});

	# Comment Form
	&make_comment_form($dbh,\$wp->{page_content});
	
					# Get Email Addresses
	my $elist = &db_get_single_value($dbh,"post","post_emails",$vars->{$fields->{thread}});

	my @earray = split ",",$elist;
		
					# Send Emails
					# To Email List
	my $adr = $Site->{em_discussion};
	my $eml = "";
	foreach my $e (@earray) {
		my $emailcontent = $wp->{page_content};
		$emailcontent =~ s/<SUBSCRIBEE>/$e/g;
		$eml .= $e." <br/>\n";
		last if ($e eq "none");
		&send_email($e,$adr,$ttitle,$emailcontent,"htm");
	}	
	
					# To Admin, with Editing Options
	my $admintext = qq|
		<p>Distributed to: <br/><dl>$eml</dl><br/><br/>
		[<a href="$Site->{st_cgi}admin.cgi?post=$id_number&action=edit">Edit</a>]
		[<a href="$Site->{st_cgi}admin.cgi?post=$id_number&action=Delete">Delete</a>]
		[<a href="$Site->{st_cgi}admin.cgi?post=$id_number&action=Spam">Spam</a>]</p>|;

	$wp->{page_content}=~ s/<admin\/>/$admintext/;
	
	&send_email($adr,$adr,$ttitle,$wp->{page_content},"htm");

	return $id_number;
}


#-------------------------------------------------------------------------------
#
# -------   Received ------------------------------------------------------
#
#           Landing page after content submitted
#           Acknowledges receipt and gives options
#	      Edited: 15 January 2011
#
#-------------------------------------------------------------------------------

sub received {

	my ($dbh,$query,$table,$id_number) = @_;

						# Verify Input
	unless ($table) { &error($dbh,"","","Submission failed; table not found."); }
	unless ($id_number) { &error($dbh,"","","Submission failed; input record number not found."); }

	# Get Record
	my $fields = &set_fields($table);
	my $record = &db_get_record($dbh,$table,{$fields->{id} => $id_number});
	unless ($record) { &error($dbh,"","","Submission failed; can't find record"); }

						# Title and Feed
	print "Content-type: text/html; charset=utf-8\n\n";
	my $item_name = ucfirst($table);
	if ($item_name eq "Thread") { $item_name = "Backchannel"; }  # Yeah, I know, hack 
	$Site->{header} =~ s/\Q[*page_title*]\E/$item_name Submitted/g;
	print $Site->{header};
	print "<h1>Your $item_name has been submitted</h1>";

						# Options

	print qq|<p><ul>|;
	if ($table eq "post") {
		print qq|<li><a href="$Site->{st_url}post/$record->{$fields->{thread}}">Back to the discussion thread</a></li>
			<li><a href="$Site->{st_url}threads.htm">View all discussion threads</a></li>
			<li><a href="$Site->{st_cgi}page.cgi?$table=$id_number&action=edit&code=$vars->{code}">Continue Editing Your $item_name</a></li>|;
	} elsif ($table eq "thread") {
		print qq|<li><a href="$Site->{st_cgi}cchat.cgi?chat_thread=$id_number">Enter your new backchannel</a></li>
			<li><a href="$Site->{st_cgi}cchat.cgi">List backchannels</a></li>|;
	}
	print qq|<li><a href="$Site->{st_url}">Back to the Home Page</a></li></ul>|;

						# Preview

	if ($table eq "post") {		# Temporary - posts for now



		# Define Display Format
		my $pformat;
		if ($record->{$fields->{type}}) { $pformat = "post_".$record->{$fields->{type}}."_summary"; }
		else { $pformat = $table ."_summary"; }

		# Format Record
		my $view_text = &format_record($dbh,$query,$table,$pformat,$record,"1"); 
		print qq|
		 	<br><i>&nbsp;&nbsp;Preview:</i><br/>
			<table border=1 cellpadding=10 cellspacing=0 width="600">
			<tr><td>
			$view_text
			</td></tr></table></form><br>|;
	}

						# Footer

	print $Site->{st_footer};
	exit;

}






#
#
# -------   Print Status -------------------------------------------------------
#
#           Print output in a 'status' span
#	      Edited: 27 March 2010
#

sub pr_status {

	my ($msg) = @_;
	return qq|<span class="status">$msg</span>|;
}


# -------   Process Event Dates ------------------------------------------------

sub process_event_dates {

	my ($dbh,$query,$table,$id_number) = @_;
	my $start="";my $finish="";
	&error($dbh,$query,"","Database not ready") unless ($dbh);
	my $vars = $query->Vars;

	my $start_time = &hmin($vars->{event_start_time},$vars->{event_start_ampm},
		$vars->{event_start_offset},$vars->{event_start_summer},$vars->{event_start_day},
		$vars->{event_start_month},$vars->{event_start_year});

	$vars->{event_finish_day} ||= $vars->{event_start_day};
	$vars->{event_finish_month} ||= $vars->{event_start_month};
	$vars->{event_finish_year} ||= $vars->{event_start_year};

	my $finish_time = &hmin($vars->{event_finish_time},$vars->{event_finish_ampm},
		$vars->{event_finish_offset},$vars->{event_finish_summer},$vars->{event_finish_day},
		$vars->{event_finish_month},$vars->{event_finish_year});


	return ($start_time,$finish_time);

}


sub hmin {

	my ($time,$ampm,$offset,$summer,$day,$month,$year) = @_;

	# Determine Hour
	my $hour; my $min;
	if ($time =~ /h/) { ($hour,$min) = split /h/,$time; }
	else { ($hour,$min) = split ":",$time; }
	if ($hour < 12 && $ampm) { $hour += 12; }
	if ($min) { $min = ( $min  / 60 ); }  else { $min = 0; }
 	$hour += $min;
	# Add Offset and Summer time
	$hour += $offset;
	if ($summer) { $hour += 1; }

	# Create Minutes
	$min = $hour - int($hour); 
	$min = $min * 60;  
	if ($min > 59) { $min = $min - 60; $hour=$hour+1; }

	# Determine Day
	if ($hour > 24) { $hour -= 24; $day += 1; }
	
	# Determine Month
	if ($year < 10) { $year = "0".$year; }
	if ($year < 2000) { $year = "20".$year; }					# standardize two-digit years
	my $d;my $f; $year +=0; if ($year % 4 == 0) { $f = 29; } else { $f = 28; }
	if (($month==1)||($month==3)||($month==5)||($month==7)||($month==8)||($month==10)||($month==12)) { $d = 31; }
	elsif (($month==4)||($month==6)||($month==9)||($month==11)) { $d = 30; }
	else { $d = $f; }
	if ($day > $d) { $day = 1; $month += 1; }
	if ($day < 10) { $day = "0".$day; }

	# Determine Year
	if ($month > 12) { $month = 1; $year += 1; }
	if ($month < 10) { $month = "0".$month; }



	if ($min < 10) { $min = "0".$min; }
	$hour = int($hour);  if ($hour < 10) { $hour = "0".$hour; }


	return $year."-".$month."-".$day."T".$hour.":".$min.":00Z";
	
}

# -------   Comment Unsubscribe ------------------------------------------------

sub comment_unsubscribe {

	my ($dbh,$query,$table,$format) = @_;
	&del_from_notify_list($dbh,$vars->{email},$vars->{thread});
	print "Content-type: text/html\n\n";
	print "Email $vars->{email} has unsubscribed from $vars->{thread}";
	exit;

}



# -------   Add to Email Notify List -------------------------------------------

sub add_to_notify_list {
	my ($dbh,$email,$thread) = @_;

	my $emails = &db_get_single_value($dbh,"post","post_emails",$thread);

	return if $emails =~ /$email/i;		# Already in list
	if ($emails) { $emails .= ","; }
	$emails .= $email;
	&db_update($dbh,"post",{post_emails=>$emails},$thread);
	
}


# -------   Delete From Email Notify List --------------------------------------

sub del_from_notify_list {
	my ($dbh,$email,$thread) = @_;
	
	my $emails = &db_get_single_value($dbh,"post","post_emails",$thread);
	return unless $emails =~ /$email/i;		# Not in list
	$emails =~ s/\Q$email\E//i;
	$emails =~ s/,,/,/g;
	$emails = "none" unless ($emails);
	&db_update($dbh,"post",{post_emails=>$emails},$thread);
}






sub in_anti_spam {		# Checks input for spam content and kills on contact

	my ($dbh,$query) = @_;
	my $vars = $query->Vars;
	
								# Define test text
	my $table = $vars->{table};
	my $d = $table."_description";
	my $t = $table."_title";
	my $c = $table."_content";
	my $test_text = $vars->{$d}.$vars->{$t}.$vars->{$c};
	my $sem_text = $vars->{$d}.$vars->{$c};

								# Require Users to Have Remote Addr
								# if they fail access permissions
	unless (&is_viewable("spam","remote_addr")) {
		unless ($ENV{'REMOTE_ADDR'}) {
			&error($dbh,$query,"","Who are you?");
		}
	}

								# Require Comment Code Match
#	unless (&is_viewable("spam","code_match")) {
#
		unless (&check_code($vars->{post_thread},$vars->{code}) || $table ne "post") {
			&error($dbh,$query,"","Spam code mismatch (used to prevent robots from submitting comments). Try this: use #the back arrow to get to the previous page, copy your comment (highlight and ctl/c), reload the web page ( do a shift-reload #for force a full reload), page the comment into the form, and submit again.","CONTENT: $test_text");
		}
#	}
	
								# Ban multiple links
	unless (&is_viewable("spam","many_links")) {
		my $c; while ($test_text =~ /http/ig) { $c++ }
		my $d; while ($test_text =~ /url/ig) { $d++ }
		if (($c > 5)||($d > 15)) {
			&error($dbh,$query,"","This post is link spam. Go away. (Too many links)","CONTENT: $test_text");
		}
	}
	
								# Ban scripts
	unless (&is_viewable("spam","scripts")) {
		if ($test_text =~ /<(.*?)(script|embed|object)(.*?)>/i) {
			&error($dbh,$query,"","No scripts in the comments please.","CONTENT: $test_text");
		}	
	}

								# Ban links
	unless (&is_viewable("spam","links")) {
		if ($test_text =~ /<a(.*?)>/i) {
			&error($dbh,$query,"","No links in the comments please.","CONTENT: $test_text");
		}	
	}
	
	
								# Ban words
	unless (&is_viewable("spam","links")) {
		if ($test_text =~ /(You are invited|viagra|areaseo|carisoprodol|betting|pharmacy|poker|holdem|casino|roulette|phentermine|ringtone|insurance|diet|ultram| pills| loans|tramadol|cialis|penis|handbag| shit | cock | fuck | fucker | cunt | motherfucker | ass )/i) {
			&error($dbh,$query,"","Spam in the text.","CONTENT: $test_text");
		}	
	}


								# Ban short comments
	unless (&is_viewable("spam","length")) {
		my $test_text_length = length ($test_text); 
		if ($test_text_length < 150) {
			&error($dbh,$query,"","Comments must be long enough to mean something.","CONTENT: $test_text");
		}	
	}


								# Semantic Test
								# applied to post only
								
	unless (&is_viewable("spam","semantic")) {

		unless ($sem_text =~ / and | or | but | the | is | If | you | my | me | he | she | was | will | all | some | I /i) {
			if ($table eq "post") {
				&error($dbh,$query,"","This content makes no sense and has thus been classified as spam","CONTENT: $test_text");
			}
		}
	}

					

	# Filter by IP
	unless (&is_viewable("spam","ip")) {
		if (&db_locate($dbh,"banned_sites",{banned_sites_ip => $ENV{'REMOTE_ADDR'}})) {
			&error($dbh,$query,"","Your IP address has been classified as a spammer.");
		}
	}

	return 1;
}



# -------   Viewer aka the PLE --------------------------------------------

sub viewer {

	my ($dbh,$query,$table,$format) = @_;
	my $vars = $query->Vars;


						# Generate Search Parameters
	my $where="";
	if ($Site->{st_tag}) { 
		$Site->{st_tag} =~ s/'//g;
		$where .= "link_type LIKE '%html%' AND (link_title LIKE '%$Site->{st_tag}%' OR link_description LIKE '%$Site->{st_tag}%') ";
	}

						# Get List of Links
	if ($where) { $where = "WHERE $where"; }
	my $sql_stmnt = "SELECT link_id FROM link $where ORDER BY link_id";
	my $links_list = $dbh->selectcol_arrayref($sql_stmnt);
	&error($dbh,"","","Links list not found for the following serach:<br>$sql_stmnt") unless ($links_list);
	my $links_count = scalar(@$links_list);
	if ($links_count == 0) { &error($dbh,"","","No links harvested using the $Site->{st_tag} tag yet."); }
	

						# Set Pointer
	my $mylastread;
	while (my($vx,$vy) = each %$vars) {  					# Last read indicated by pointer button
		if ($vx =~ /move - (.*?)/) { $mylastread = $1; $vars->{move} = $vy; }
	}
	unless ($mylastread) { $mylastread = $Person->{person_lastread}; }	# Or in person data
	my $pointer = &index_of($mylastread,\@$links_list);
	
	unless ($pointer) { $pointer = 0; }			# Default to first link
	if ($pointer < 0) { $pointer = 0; }			# Repair broken pointers		

						# Move Pointer
	
	if ($vars->{move}) {						# Perform Action, or
		for ($vars->{move}) {
			/up/ && do { $pointer++ if ($pointer<$links_count-1); last; };
			/down/ && do { $pointer-- if ($pointer>0); last;  };
			/first/ && do { $pointer = 0;  last; };
			/last/ && do { $pointer = $links_count-1;  last;  };
		}
	}

						# Set Link ID to Display and save as last read
	my $link_id = $links_list->[$pointer];
	&error($dbh,"","","Display link undefined") unless ($link_id);
	
	&db_update($dbh,"person",{person_lastread=>$link_id},$Person->{person_id});


						# Redirect to comment
	if ($vars->{comment} && $vars->{show}) {
		if ( &db_locate($dbh,"link",{link_id => $vars->{show}})) {
			print "Content-type:text/html\n";
			print "Location: $Site->{st_cgi}page.cgi?db=post&action=edit&autoblog=$vars->{show}\n\n";
			exit;
		} else {
			&error($dbh,"","","Redirect link number $vars->{show} does not exist.");

		}
	}

						# Header

	print "Content-type:text/html\n\n";
	print &header($dbh,$query,"","viewer","");

	
						# Get the Link Record and Format
	my $record = &db_get_record($dbh,"link",{link_id=>$link_id});
	&error($dbh,"","","Link number $link_id Not found") unless ($record);
	my $record_text = &format_record($dbh,$query,"link","link_viewer",$record);
	&error($dbh,"","","Formatting error for link number $link_id") unless ($record_text);
	&make_keywords($dbh,$query,\$record_text);
#	&make_admin_links(\$record_text);

	$record_text =~ s/&amp;nbsp;/&nbsp;/gi;
	
#while (my ($vx,$vy) = each %$vars) { print "$vx = $vy <br>"; }

						# Prepare Comment Button
	my $comment_button = "";
	if (&check_status("create","post")) {
		$name_field = qq|<a href="$Site->{st_url}options.htm">$Person->{person_title}</a> reading |;
		$comment_button = qq|<input type="submit" name="comment" value=" COMMENT ">|;
	} else {
		$comment_button = qq|<a href="$Site->{st_cgi}login.cgi?refer=http://cck12.mooc.ca/cgi-bin/page.cgi?action=viewer">LOGIN</a> to comment|;
		$name_field = qq|Reading |;
	}
						# print Link
	my $pointerplusone = $pointer + 1;
	print qq|
		
		<div style="padding-top:10px;height:50px;background-color:#b0c4de;">
		<form method="post" action="page.cgi">
		<input type="hidden" name="action" value="viewer">
		<input type="hidden" name="show" value="$link_id">
		<span style="float:left">
			<input type="submit" name="move - $link_id" value="first << ">
			<input type="submit" name="move - $link_id" value=" down <  ">
		</span>
		<span style="float:right">
			<input type="submit" name="move - $link_id" value="up  >  ">
			<input type="submit" name="move - $link_id" value="last >> ">
		</span>
		<center>$vars->{msg}
		$name_field
		$pointerplusone of $links_count  
		$comment_button
		</center>
		</form>
		</div><div>$record_text</div>|;

#	&viewer_autoblog(\$record_text,$record);	

#	print $record_text;
#	print $Site->{footer};

		&db_increment($dbh,"link",$link_id,"hits");
		&db_increment($dbh,"link",$link_id,"total");

	exit;


	
	
}

# -------   Viewer Autoblog --------------------------------------------
#
# Creates the autoblog link in the viewer
#

sub viewer_autoblog {

	my ($text_ptr,$record) = @_;
	while ($$text_ptr =~ /<BLOG>/sg) {
		my $replace = qq|<a href="?db=post&action=edit&autoblog=$record->{link_id}">
			Comment</a>|;
		$$text_ptr =~ s/<BLOG>/$replace/sig;
	}

}

# -------   APIs --------------------------------------------

sub api_graph {

	my ($dbh,$query,$table,$format) = @_;
	
	my $vars = $query->Vars;
	die "Incorrect API key" unless ($vars->{apikey} eq "tony");
	print "Content-type: text/xml\n\n";
	print qq|<?xml version="1.0" encoding="UTF-8"?>
<opml version="1.0">
    <head>
        <title>$Site->{st_name} Graph</title>
    </head>
    <body>
|;
    
	
	my $crdate = $vars->{cutoff};
	unless ($crdate) { 
		# $crdate = time - ( $3600 * 72 ); 
		$crdate = 0;
	}
	
	my $sql = qq|SELECT * FROM graph WHERE graph_crdate > ? ORDER BY graph_crdate|;
	
	my $sth = $dbh -> prepare($sql);
	$sth -> execute($crdate) or die $dbh->errstr;
	while (my $ref = $sth -> fetchrow_hashref()) {
		while (my ($gx,$gy) = each %$ref) {		# XMLify
			$ref->{$gx} =~ s/\&/&amp;/g;
		}
		
		print qq|	<outline title="Graph $ref->{graph_type} $ref->{graph_id}" text="$ref->{graph_crdate}">
		<outline text="$ref->{graph_tableone} $ref->{graph_idone}" title="$ref->{graph_tableone}" type="$ref->{graph_tableone}"
                  htmlUrl="$ref->{graph_urlone}"/>
		<outline text="$ref->{graph_tabletwo} $ref->{graph_idtwo}" title="$ref->{graph_tabletwo}" type="$ref->{graph_tableone}"
                  htmlUrl="$ref->{graph_urltwo}"/>
	</outline>
            |;		
	}
	
	print qq|   </body>
</opml>|;
	exit;
}


1;

