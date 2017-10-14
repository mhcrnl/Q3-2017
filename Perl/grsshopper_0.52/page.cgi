#!/usr/bin/env perl

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

# print "Content-type: text/html\n\n";
# print "Down for repairs<br>";
# exit;				

# Initialize gRSShopper Library

# FindBin doesn't work on ModCGI
#use FindBin qw($Bin);
#require "$Bin/grsshopper.pl";

use File::Basename;
my $basepath = dirname(__FILE__);
require $basepath . "/grsshopper.pl";

our ($query,$vars) = &load_modules("admin");			# Request Variables

our ($Site,$dbh) = &get_site("admin");				# Site
if ($vars->{context} eq "cron") { $Site->{context} = "cron"; }


our $Person = {}; bless $Person;				# Person  (still need to make this an object)
&get_person($dbh,$query,$Person);		
my $person_id = $Person->{person_id};



my $options = {}; bless $options;		# Initialize system variables
our $cache = {}; bless $cache;	



						# Search 

if ($vars->{q}) {
	&post_search(); exit;
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
		"file",
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
		/api submit/ && do { &api_submit($dbh,$query,$table,$id); last; 	};
		/rd/ && do { &redirect($dbh,$query,$table,$id); last; 	};
		/search/ && do { &search($dbh,$query); last; 	};
		/list/ && do { &list_records($dbh,$query,$table); last;		};
		/edit/ && do { &edit_record($dbh,$query,$table,$id); last; 		};
		/comment/ && do { &comment($dbh,$query); last; 		};
		/update/ && do { $id = &update_record($dbh,$query,$table,$id);
			&received($dbh,$query,$table,$id); last; 			};
		/viewer/ && do { &viewer($dbh,$query,$table,$format); last; 	};
		/meetings/ && do { &meetings($dbh,$query); last; 	};		
		/join_meeting/ && do { &join_meeting($dbh,$query); last; 	};	
		/moderate_meeting/ && do { &moderate_meeting($dbh,$query); last;	};		
		/unsub/ && do { &comment_unsubscribe($dbh,$query,$table,$format); last; 	};

		/hits/ && do { &api_hits($dbh,$query,$table,$id);last;};
		/votes/ && do { &api_votes($dbh,$query,$table,$id);last;};
		/vote/ && do { &input_vote($dbh,$query); last; 	};
		/apiv/ && do { &api_vote($dbh,$query); last; };

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


&db_cache_write($dbh);				# Write cache records to database after page is printed
if ($dbh) { $dbh->disconnect; }			# Close Database and Exit
exit;




#-------------------------------------------------------------------------------
#
#           Functions 
#
#-------------------------------------------------------------------------------
	
sub redirect {

	my ($dbh,$query,$table,$id) = @_;

	&db_increment($dbh,$table,$id,"hits");		# old school
	&db_increment($dbh,$table,$id,"total");		#  Increment Hit Counter	

	my $linkfield = $table."_link";
	
	my $target = db_get_single_value($dbh,$table,$linkfield,$id);
	$target =~ s/&amp;/&/g;	
	unless ($target) { $target = $Site->{st_url}.$table."/".$id; }

 #    $target = qq|https://edfutureqa.desire2learn.com/d2l/home/6611|;
				 	
	# Implement D2L REST API
	
	if ($Person->{person_id} && $Person->{person_id} ne "2") {

		if ($Site->{st_url} =~ /edfuture/) {		# Site-specific Need a better thing here
		
			if ($target =~ /d2l/) {			# URL-specific - Need a better thing here
	
				my $sitekey = qq|A48506F1-7AE3-4C90-9891-C4E6F662F0BC|;
				my $apiurl = "https://edfuture.desire2learn.com";
				my $apipath = "/d2l/api/custom/1.1/ssowithcreateandenroll/authUser/".$sitekey;
				
		
				my ($first,$last) = &first_last_name();
				&error($dbh,"","","fatal error, first and last name not found on D2L redirect: $first, $last") 
					unless ($first && $last);
				&error($dbh,"","","fatal error, email address not found on D2L redirect") 
					unless ($Person->{person_email});	
				my $data = {
					UserName => $Person->{person_title},
					FirstName => $first,
					LastName => $last,
					Email => $Person->{person_email}
				};
		

				my $redirect = &api_send_rest($dbh,$query,$apiurl,$apipath,$data,$target);
	
				print "Content-type: text/html\n";
				print "Location: $redirect\n\n";
			}
		}

	}
	
	
	print "Content-type:text/html\n";
	print "Location: $target\n\n";
	exit;
}

# First-Last Name 
# 
# Generates first and last name

sub first_last_name {
	
	
	if ($Person->{person_name} && !$Person->{person_lastname}) {
		($Person->{person_firstname},$Person->{person_lastname}) = split " ",$Person->{person_name};
	}
	
	if ($Person->{person_firstname} && $Person->{person_lastname}) {
		return ($Person->{person_firstname},$Person->{person_lastname}); 
	}
	
	if ($Person->{person_firstname} || $Person->{person_lastname} ||  $Person->{person_title}) {
		$Person->{person_firstname} = $Person->{person_firstname} || $Person->{person_lastname} ||  $Person->{person_title};
		$Person->{person_lastname} = $Person->{person_lastname} || $Person->{person_firstname} ||  $Person->{person_title};
		return ($Person->{person_firstname},$Person->{person_lastname});
	}
	
	
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

sub comment {



	my ($dbh,$query) = @_;
	my $vars = (); my $now = time;
	if (ref $query eq "CGI") { $vars = $query->Vars; }
	$vars->{force} = "yes";		# Never use cache on edit
	$vars->{cr_msg} = "";
	my $udcolour = "green";


	unless ($vars->{post_thread}) {
								# Autoblog Link
		if ($vars->{link_id}) { 
			$vars->{post_thread} = &auto_post($sbh,$query,$vars->{link_id}); 
			$vars->{cr_msg} .= qq|<p style="color:red">$vars->{post_thread}</p>| if ($vars->{post_thread} =~ /error/); 	
		}
		
	}
	
	
	$vars->{post_id} = &db_locate($dbh,"post",{post_createcode=>$vars->{post_createcode}});
	$vars->{msg} .= "Found post id $vars->{post_id} for comment key $vars->{post_createcode} ";
	
	$vars->{post_id} ||= "new";				# New Comment	
	if ($vars->{post_id} eq "new") {
		
		$vars->{post_title} = "Re: $vars->{rec_title}";
		$vars->{post_creator} = $Person->{person_id};
		$vars->{post_creatorname} = $Person->{person_name} || $Person->{person_title} ;
		$vars->{post_crdate} = $now;
		$vars->{post_type} = "comment";
		$vars->{post_id}  = &form_update_submit_data($dbh,$query,"post",$vars->{post_id});
		$vars->{cr_msg} .= qq|<p style="color:$udcolour;">Post submitted at |.localtime(time)."</p>";

	} else {
		$vars->{post_id}  = &form_update_submit_data($dbh,$query,"post",$vars->{post_id});
		$vars->{cr_msg} .= qq|<p>Thread: $vars->{post_thread} </p><p style="color:$udcolour;">Post updated at |.localtime(time)."</p>";
	}


	&output_record($dbh,$query,"post",$vars->{post_id},"comment");
	
	exit;
} 


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

sub post_search {
	

	$Site->{header} =~ s/\Q[*page_title*]\E/Search/g;

	print "Content-type: text/html; charset=utf-8\n\n";
	print $Site->{header};	
	
	my $newq = $vars->{q};
	$newq =~ s/ /%20/g;

	$vars->{number}=20;
	my ($sort,$start,$number,$limit) = &sort_start_number($query,"post");
	my $searchtable = $vars->{db} || "post"; exit "No search permitted" if ($searchtable =~ /person/);
	
	print "<h1>Search</h1>";
	if ($searchtable eq "post") {
		print qq|<p>This page: <a href="$Site->{st_url}search/$newq">$Site->{st_url}search/$newq</a></p>|;
	} else {
		print qq|<p>This page: <a href="$Site->{st_url}search/$newq">$Site->{st_url}search/$searchtable/$newq</a></p>|;
	}
	
	my $keyword = qq|<keyword start=$start;db=$searchtable;sort=crdate DESC;number=$number;title,description~$vars->{q};truncate=500;format=search>|;
	my $results_count = &make_keywords($dbh,$query,\$keyword);
	
	
	
	print $keyword;
	my $newstart = $vars->{start} + $vars->{number};
	
	unless ($results_count < $vars->{number}) {
		print qq|<p>[<a href="$Site->{st_cgi}page.cgi?start=$newstart&q=$newq">Next $vars->{number} results</a>]|;
	}
	
	print $Site->{footer};
	exit;
	
}

# -------   Output Record ------------------------------------------------------

sub output_record {

	my ($dbh,$query,$table,$id_number,$format) = @_;




	$table ||= $vars->{table};
	$id_number ||= $vars->{id_number};
	$format ||= $vars->{format};
	

	&error($dbh,"","","Output Table is not defined.") unless (defined $table && $table);
	
 if ($table eq "topic") {
	print "Content-type: text/html; charset=utf-8\n\n";
	print "Access to topics is disabled for the moment while I fix the code.";
	exit;
}

	my $record = &db_get_record($dbh,$table,{$table."_id"=>$id_number});
	if ($table eq "post") { &db_increment($dbh,$table,$id,"hits");	}	# old school
	if ($table eq "post") { &db_increment($dbh,$table,$id,"total");	}	#  Increment Hit Counter	
						
	
	if ($format eq "viewer") {						# Viewer
		

		my $record_text = &format_record($dbh,$query,$table,$table."_viewer",$record);
		my $admin_option = &output_admin($dbh,$query,$table,$record);
			
		print "Content-type:text/html\n\n";
		print qq|<html><head><title>$record->{$table."_title"}</title>|.
			&output_header.
			qq|<body>$admin_option $record_text|.
			&output_comment_form($record).
			qq|</body><html>|;
			
		return;	
			
	} elsif ($format eq "comment") {
	
		my $record_text = &format_record($dbh,$query,$table,$table."_comment",$record);
			
		print "Content-type:text/html\n\n";
		print qq|<html><head><title>$record->{$table."_title"}</title>|.
			qq|<body>$vars->{cr_msg}$record_text</body><html>|;
			
		return;		
		
	}

	my $vars = $query->Vars;
	$vars->{comment} = "yes";

											# If ID is specified as text
	unless ($id_number =~ /^[+-]?\d+$/) {					# Try to find by title
		$id_number = &find_by_title($dbh,$table,$id_number);
		if ($vars->{table} eq "feed") { $table = "feed"; }
	}
	

	my $fields = &set_fields($table);
	my $cformat = $table."_".$vars->{format};					# Set cache format



						# Get and Print Record Cache

										
#	if (my $cached = &db_cache_check($dbh,$table,$id_number,$cformat)) {	
									
#		&make_admin_links(\$cached);						# Fill special Admin links	
#		&make_login_info($dbh,$query,\$cached,$table,$id_number);
#		if ($cached) { print "Content-type: text/html\n\n";print $cached; return; }	# print cached version			
		
#	}	

	
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
	$Site->{header} =~ s/\Q[*page_title*]\E/$wp->{page_title}/g;


						# Set Formats

	my ($page_format,$record_format,$mime_type) =
		&set_formats($dbh,$query,$wp,$table);


						# Put Record Data Into Template 
	$wp->{page_content} = &format_record($dbh,$query,$table,$record_format,$wp);


						# For non-Page Records, Add Header and Footer

	if ($page_format =~ /thread/i) { $page_format = "html"; }
	$page_format ||= "HTML";

	unless ($table eq "page" || $format eq "viewer") {

		my $header_template = "page_header";
		my $footer_template = "page_footer";
		
		unless ($page_format =~ /html/i) { 
		
			$header_template = $Site->{lc($page_format) . "_header"} || lc($page_format) . "_header";
			$footer_template = $Site->{lc($page_format) . "_footer"} || lc($page_format) . "_footer";
		}


		if (defined $wp->{page_content}) {
			$wp->{page_content} =
				&db_get_template($dbh,$header_template) .
				$wp->{page_content} . &db_get_template($dbh,$footer_template);	
		} else {
			$wp->{page_content} =
				&db_get_template($dbh,$header_template) .
				"This page has no content." . &db_get_template($dbh,$footer_template);	
		}


	}




						# Format Record Content

	$wp->{table} = $table;
	&format_content($dbh,$query,$options,$wp);
	$wp->{page_content} =~ s/\Q[*page_title*]\E/$wp->{page_title}/g;
	
	
						# Fill timezone dates
	&autotimezones($query,\$wp->{page_content});	
		
						# Save To Cache
				 
				
	# &db_cache_save($dbh,$table,$id_number,$cformat,$wp->{page_content});			# Save To Cache

	
	&make_pagedata($query,\$wp->{page_content});						# Fill special Admin links and post-cache content
	&make_admin_links(\$wp->{page_content});
	&make_login_info($dbh,$query,\$wp->{page_content},$table,$id_number);
	

	
						# Print Record

	$wp->{page_content} =~ s/\Q]]]\E/] ]]/g;   # Fixes a Firefox XML CDATA bug

	#print "Content-type: text/html\n\n";
	print "Content-type: ".$mime_type."\n\n";

	print $wp->{page_content};


}

sub output_admin {
	
	my ($dbh,$query,$table,$record) = @_;
	return unless ($Person->{person_status} eq "admin"); 
	$record->{link_status} ||= "Fresh";
	
	return qq|
		<style>
		     #status { color:blue;float:left;text-align:center;height:2.5em;line-height:2.5em;width:10em;border: 1 px solid black; }
		     #control { color:red;float:left;text-align:center;height:2.5em;line-height:2.5em;width:5em;border: 1 px solid black; }
		     #adminmenu { width:100%;height:3em;margin-top:0.5em; }
		     .adminbutton { height:2em; width:5em; };
		</style>
		<div id="adminmenu">
		<div id="status">
		<span>Status: $record->{link_status}</span>
		</div>
		<div id="control">
		<form id="autopost" method="post" action="$Site->{st_cgi}admin.cgi">
		<input type="submit" class="adminbutton" value=" POST "/>
		<input type="hidden" name="action" value="autopost">
		<input type="hidden" name="id" value="$record->{link_id}">
		</form>
		</div>
		<div id="control">
		<form id="postedit" method="post" action="$Site->{st_cgi}admin.cgi">
		<input type="submit" class="adminbutton" value=" EDIT "/>
		<input type="hidden" name="action" value="postedit">
		<input type="hidden" name="id" value="$record->{link_id}">
		</form>
		</div>
		</div>
		<div id="adminedit"><div>
	|;
	
}

sub output_header {
	
	return qq|
	<head>
		<link href="http://open.mooc.ca/assets/css/bootstrap.css" rel="stylesheet">
		<link href="http://open.mooc.ca/assets/css/bootstrap-responsive.css" rel="stylesheet">	
		<link rel="stylesheet" type="text/css" href="http://open.mooc.ca/assets/css/html.css" media="screen, projection, tv " />
		<link rel="stylesheet" type="text/css" href="http://open.mooc.ca/assets/css/layout.css" media="screen, projection, tv" />	
		<script src="http://open.mooc.ca/assets/js/jquery.js"></script>
		<script type="text/javascript" src="http://open.mooc.ca/assets/js/grsshopper.js"></script>		
		<script src="http://open.mooc.ca/assets/js/grsshopper_viewer.js"></script>
	</head>
	|;
}

sub output_comment_form {
	
	my ($record,$comment) = @_;
	
	$createcode = $Person->{person_id} . time;
	return qq|
	<div id="commented"></div>
	<h4>Comment</h4>
	<form  class="ajax_form" id="comment" method="POST" action="$Site->{script}">
		<input name="action" value="comment" type="hidden">
		<input name="post_createcode" value="$createcode" type="hidden">
		<input name="link_id" value="$record->{link_id}" type="hidden">
		<input name="rec_title" value="$record->{link_title}" type="hidden">		
		<input name="post_thread" value="$record->{link_post}" type="hidden">
		<input name="code" value="85QwMollLxZZc" type="hidden">
		<textarea name="post_description" cols="60" rows="10" style="width:auto;"></textarea><br/>
		<input class="ajax_button" type="submit" value="Post Comment" /> 
	</form>
	|;

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

print "Content-type: text/html\n\n";
						# Define Import Variables
# 	print &record_submit($dbh,$vars);
					
	my ($dbh,$query,$table,$id) = @_;
	my $vars = $query->Vars;	
	$id = &record_submit($dbh,$vars,"id");
print "Created record number $id <p>";	
	return $id;
}


#---------------------  Input Vote  ----------------------------------

sub input_vote {
	
	my ($dbh,$query) = @_;	
	my $sum = &update_vote($dbh,$query);
	$vars->{vote_table} ||= "post";
	
	&output_record($dbh,$query,$vars->{vote_table},$vars->{vote_post},"html");
	
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
		if ($vars->{post_type} eq "comment") {
		print qq|<li><a href="$Site->{st_url}post/$record->{$fields->{thread}}">Back to the discussion thread</a></li>
			<li><a href="$Site->{st_url}threads.htm">View all discussion threads</a></li>
			<li><a href="$Site->{st_cgi}page.cgi?$table=$id_number&action=edit&code=$vars->{code}">Continue Editing Your $item_name</a></li>|;
		} elsif ($vars->{post_type} eq "trend") {  # Special for ed future course
		
			print qq|<li><a href="http://edfuture.mooc.ca/cgi-bin/page.cgi?page=189&force=yes">View all the Drivers</a></li>
				<li><a href="$Site->{st_cgi}page.cgi?$table=$id_number&action=edit&code=$vars->{code}">Continue Editing Your $item_name</a></li>|;
	
		}
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

sub get_tag_options {
	
	my ($dbh,$opted,$blank,$size,$width) = @_;
	$opted ||= "none";
	my $title = "Tag";
	$size ||= 1;
	$width ||= 15;	
	my $output = "";
	
	my $nonselected; if ($opted eq "none") { $noneselected = qq| selected="selected"|; }
	my $tagselected; if ($opted eq "$Site->{st_tag}") { $tagselected = qq| selected="selected"|; }
		
	$output = qq|<h4>$title:</h4>
	<p class="options">
		<select name="tag" size="$size" width="$width">
		<option value="none"$nonselected>$blank</option>	
		<option value="$Site->{st_tag}"$tagselected>$Site->{st_tag}</option>			
		</select></p>
	|;

	return $output;
}

sub get_options {
	
	my ($dbh,$table,$opted,$blank,$size,$width) = @_;
	return "Table not specified in get_options" unless ($table);
	$opted ||= "none";	
	my $titfield = $table."_title";
	my $title = ucfirst($table);
	my $idfield = $table."_id";
	$size ||= 15;
	$width ||= 15;	
	my $output = "";
	if ($table eq "feed") { $where = qq|WHERE feed_status = 'A'|; } else { $where = ""; }
	my $sql = qq|SELECT $titfield,$idfield from $table $where ORDER BY $titfield|;
	
	my $sth = $dbh -> prepare($sql);
	$sth -> execute() or die $dbh->errstr;
	while (my $ref = $sth -> fetchrow_hashref()) {
		next unless ($ref->{$titfield});
		my $selected="";
		if ($opted eq $ref->{$idfield}) { $selected = " selected"; }
		$output .= qq|    <option value="$ref->{$idfield}"$selected>$ref->{$titfield}</option>\n|;
	}
	
	if ($output) {
		$output = qq|<h4>$title:</h4>
		<p class="options">
		<select name="$table" size="$size" width="$width">
		<option value="none" selected>$blank</option>
		$output
		</select></p>
		|;
	}
	return $output;
}

sub get_optlist {
	
	my ($dbh,$optlist,$opted,$blank,$size,$width) = @_;
	return "Optlist not specified in get_optlists" unless ($optlist);
	$opted ||= "none";
	my ($table,$field) = split "_",$optlist;
	my $title = ucfirst($field);	
	my $output = "";
	my $sql = qq|SELECT optlist_data FROM optlist WHERE optlist_title=? LIMIT 1|;
	my $sth = $dbh -> prepare($sql);
	$sth -> execute($optlist) or die $dbh->errstr;
	my $ref = $sth -> fetchrow_hashref();
	my @opts = split ";",$ref->{optlist_data};
	foreach my $opt (@opts) {
		my ($oname,$ovalue) = split ",",$opt;
		next unless ($oname && $ovalue);
		my $selected; if ($opted eq $ovalue) { $selected = " selected"; }  else { $selected=""; }
		$output .= qq|    <option value="$ovalue"$selected>$oname</option>\n|;				
	}
	
	if ($output) {
		$output = qq|<h4>$title:</h4>
		<p class="options">
		<select name="$field" size="$size" width="$width">
		<option value="none" selected>$blank</option>
		$output
		</select></p>
		|;
	}
		
	return $output;
}

sub viewer {

	my ($dbh,$query,$table,$format) = @_;
	my $vars = $query->Vars;
	$vars->{tag} ||= "none";
	print "Content-type: text/html\n\n";

	
									# Print Header
									

	print qq|<html>
		<head>
		<title>$Site->{st_name} Viewer</title>
		<link href="$Site->{st_url}assets/css/bootstrap.css" rel="stylesheet">
		<link href="$Site->{st_url}assets/css/bootstrap-responsive.css" rel="stylesheet">	
		<link rel="stylesheet" type="text/css" href="$Site->{st_url}assets/css/html.css" media="screen, projection, tv " />
		<link rel="stylesheet" type="text/css" href="$Site->{st_url}assets/css/layout.css" media="screen, projection, tv" />	
		<script src="$Site->{st_url}assets/js/jquery.js"></script>
		<script type="text/javascript" src="$Site->{st_url}assets/js/grsshopper.js"></script>		
		<script src="$Site->{st_url}assets/js/grsshopper_viewer.js"></script>
		</head>
		  <body data-twttr-rendered="true" data-spy="scroll" data-target=".subnav" data-offset="50">
	</head>|;								


									# Print Viewer Header
									
	my $viewer_header = qq|<div class="span12">
		<span style="float:right;"><script language="Javascript">login_box();</script></span></div>
		<div class="row-fluid">|;
	
	
     



									# Generate Search Parameters
	my @where_arr;
	my @search_string;
	
	
										# Tag
	if ($vars->{tag} && $vars->{tag} ne "none") { 
		$Site->{st_tag} =~ s/'//g;
		push @where_arr, "(link_type LIKE '%html%' AND (link_content LIKE '%$Site->{st_tag}%' OR link_category LIKE '%$Site->{st_tag}%' OR link_title LIKE '%$Site->{st_tag}%' OR link_description LIKE '%$Site->{st_tag}%'))";
		push @search_string,"Tag: $vars->{tag}";
	}

										# Feed
	if ($vars->{feed} && ($vars->{feed} ne "none")) {
		my @feedlist = split /\0/,$vars->{feed}; my @feed_arr;
		foreach my $f (@feedlist) { push @feed_arr,"link_feedid = '$f'"; }
		my $feedl = join " OR ",@feed_arr;
		push @where_arr, "($feedl)";
		push @search_string,"Feed: $vars->{feed}";		
	}
	
										# Section
	if ($vars->{section} && $vars->{section} ne "none") { 
		push @where_arr, "(link_section = '$vars->{section}')";
		push @search_string,"Section: $vars->{section}";
	}
	
										# Status
	if ($vars->{status} && $vars->{status} ne "none") { 
		push @where_arr, "(link_status = '$vars->{status}')";
		push @search_string,"Status: $vars->{status}";
	}
		
	
	my $where; my $wherestring;
	if (scalar(@where_arr) > 0) {
		$where = join " AND ",@where_arr; $where = " ".$where;
		$searchstring = join "; ",@search_string; $searchstring = "Listing: ".$searchstring."<br/>";
	}


									# Execute Search
 	

									# Get List of Links
	my $msg = "";					
	if ($where) { $where = "WHERE $where"; }
	my $sql_stmnt = "SELECT link_id FROM link $where ORDER BY link_id";
	

	my $links_list = $dbh->selectcol_arrayref($sql_stmnt);
	&error($dbh,"","","Links list not found for the following search:<br>$sql_stmnt <br> ".$dbh->errstr) unless ($links_list);
	my $links_count = scalar(@$links_list);
	if ($links_count == 0) { $msg .= "No links harvested with $sql_stmnt <br>".$dbh->errstr; }
	

										# Set Pointer
	my $lastreadindex = 0; 
	if ($Person->{person_lastread}) { 
		my $m = &index_of($Person->{person_lastread},$links_list);
		if ($m > 0) { $lastreadindex = $m; } else { $lastreadindex = 0; }
	}	
	
	my @larray; foreach my $l (@$links_list) { push @larray,qq|"$l"|; } 					
	my $ll = join ",",@larray;
	my $post_scr; if ($Person-{person_status} eq "admin") { $post_scr = "admin"; } else { $post_scr = "page"; }
		
									# Create Screen
									

	my $jscr = &viewer_taskbar($ll,$lastreadindex,$post_scr,$links_count);


# <input type="button" id="button5" style="height:2em; width:5em;" onclick="viewer_post(sitecgi,larr[index],'$post_scr')" value=" POST "/>


	if ($links_count == 0) {
		
		$jscr .= qq|
<div id="viewer-screen" class="span11">
  <p>It distresses me to say there was nothing found.</p>
</div>		
		|;
	} else {
		$jscr .= qq|
<div id="viewer-screen" class="span11">
  <p>Placeholding text</p>
</div>

<script>
document.getElementById('pointer').value=index;
document.getElementById('resource').value=larr[index];  
document.getElementById('rescounter').innerHTML=index+1; 
viewer_ajax_request(sitecgi+"page.cgi?link="+larr[index]+"&format=viewer");
</script> 

	|;
	
	}
	
									# Print Viewer

	print qq|<div class="span12">$viewer_header</div>
		<div class="row-fluid">
			<div class="span3">|.&viewer_controls($dbh,$query,$table,$format).qq|</div>
			<div class="span8">$searchstring$jscr</div>
		</div></body></html>|;
	
#	print $page->{content};


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

sub viewer_controls {
	
	my ($dbh,$query,$table,$format) = @_;
	
	my $controls = qq|
		<form method="post" action="page.cgi">
		<input type="hidden" name="action" value="viewer">
		<h2>Viewer</h2>|.

		&get_optlist($dbh,"feed_section",$vars->{section},"All Sections").
		&get_optlist($dbh,"link_status",$vars->{status},"Any Status").
		&get_options($dbh,"feed",$vars->{feed},"All Feeds").
		&get_options($dbh,"topic",$vars->{topic},"All Topics").
		&get_tag_options($dbh,$vars->{tag},"None").		
		&get_optlist($dbh,"feed_genre",$vars->{genre},"All Genres").
		qq|

		<input type="submit" value="S U B M I T">	
		
		</form>	
		[<a href="$Site->{st_cgi}admin.cgi">Admin</a>]
	|;
	
	return $controls;
}




sub viewer_taskbar {
	
	my ($ll,$lastreadindex,$post_scr,$links_count) = @_;

	return qq|<p>
	<script type="text/javascript">
		var larr = [$ll];
		var last = larr.length-1;
		var index=$lastreadindex;
		var sitecgi='$Site->{st_cgi}';
		var pscr = '$post_scr';
	</script>
	<div style="text-align: center;">
		<span style="float:left;">
			<input type="button" id="button4" style="height:2em; width:5em;" onclick="viewer_increment(sitecgi,4,last)" value=" << "/>
			<input type="button" id="button2" style="height:2em; width:5em;" onclick="viewer_increment(sitecgi,2,last)" value=" < "/>
		</span>
		<span style="float:right;">
			<input type="button" id="button1" style="height:2em; width:5em;" onclick="viewer_increment(sitecgi,1,last)" value=" > "/>
			<input type="button" id="button3" style="height:2em; width:5em;" onclick="viewer_increment(sitecgi,3,last)" value=" >> "/>
		</span>
		<input type="hidden" id="resource" value="increment me!"/>
		<input type="hidden" id="pointer" value=""/>
	</div>
	<div style="text-align: center;">
		<span>Displaying resource number <span id="rescounter">0</span>  of $links_count</span>
	</div>
	|;
	
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

# --------- API Submit -------------------
#
#  Submit record, return preview
#



sub api_submit {
	
	my ($dbh,$query) = @_;	
	my $vars = $query->Vars;
	
	print "Content-type: text/html\n\n";


	print &record_submit($dbh,$vars);
		
			
	exit;
	
}



# --------- API Vote -------------------
#
#  Submit vote, returns the number of votes for a resource
#


sub api_vote {
	
	my ($dbh,$query) = @_;	
	
	$vars->{vote_table} ||= "post";			# Input from grsshopper.js
	if ($vars->{vote_value} eq "up") { $vars->{vote_value} = 1; }
	if ($vars->{vote_value} eq "down") { $vars->{vote_value} = -1; }

	
	
	print "Content-type: text/html\n\n";
	my $sum = &update_vote($dbh,$query,$vars->{vote_table});
	
	print $sum || "No result";
	exit;
	
}


# --------- API Votes -------------------
#
#  Returns the number of votes for a resource
#
#  <st_url>/<table>/<id>/votes
#  eg. http://www.downes.ca/post/42/votes

sub api_votes {
	
	my ($dbh,$query,$table,$id) = @_;	
	$table ||= "post";
	my $votesfield=$table."_votescore";
	my $sum = &db_get_single_value($dbh,$table,$votesfield,$id);
	print "Content-type: text/html\n\n";
	print qq|<html><head><head><body style="margin:0;padding:0;line-height: 26px;
     text-align: center; width:45px; height: 26px;font-family:arial, helvetica; font-size:0.8em; font-weight:bold;">|;	
	if ($sum) { print $sum; } else { print "0"; }
	print "</body></html>";
	exit;
	
		
}


# --------- API Hits -------------------
#
#  Returns the number of votes for a resource
#
#  <st_url>/<table>/<id>/votes
#  eg. http://www.downes.ca/post/42/votes

sub api_hits {
	
	my ($dbh,$query,$table,$id) = @_;	
	$table ||= "post";
	my $hitsfield=$table."_total";
	my $sum = &db_get_single_value($dbh,$table,$hitsfield,$id);
	print "Content-type: text/html\n\n";
	print qq|<html><head><head><body style="margin:0;padding:0;      float:left;
		width: 45px;
		height: 40px;
		font-family:arial, helvetica; font-size:0.8em; font-weight:bold;
		margin:0; padding:0;
		padding-top:5px;
		padding-bottom:5px;
		margin-right:5px;
		margin-bottom:5px;
		text-align: center;">|;
	if ($sum) { print $sum; } else { print "0"; }
	print "<br/>HITS";
	print "</body></html>";
	exit;
	
	
		
}


1;

