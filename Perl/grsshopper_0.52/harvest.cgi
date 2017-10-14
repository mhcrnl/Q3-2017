#!/usr/bin/env perl
use strict;

print "Content-type: text/html; charset=utf-8\n\n";



## use padre_syntax_check

# Forbid agents

if ($ENV{'HTTP_USER_AGENT'} =~ /bot|slurp|spider/) { 
  	print "Content-type: text/html; charset=utf-8\n";
	print "HTTP/1.1 403 Forbidden\n\n";
	print "403 Forbidden\n"; 
	exit; 
}




# Initialize gRSShopper Library

# FindBin doesn't work on ModCGI
#use FindBin qw($Bin);
#require "$Bin/grsshopper.pl";

use File::Basename;
my $basepath = dirname(__FILE__);
require $basepath . "/grsshopper.pl";

our ($query,$vars) = &load_modules("admin");			# Request Variables
our ($Site,$dbh) = &get_site("admin");				# Site
#$Site->{feed_cache_dir} = "/var/www/feeds/";
$Site->{diag_level} = 5;					# Diagnostics level 0-10
								# 1 - save item
								# 2 - save media, author
								# 3 - save link
								# 6 - scraper
								# 7 - graph
								# 8 - new gRSShopper record

our $Person = {}; bless $Person;				# Person  (still need to make this an object)
&get_person($dbh,$query,$Person);		
my $person_id = $Person->{person_id};

$vars->{msg} = "Messages<p>";



							
							# Only Admin Harvest

my $msg = "Permission Denied<br/><a href='$Site->{st_cgi}login.cgi?refer=$Site->{script}'?Login</a>";
&error($dbh,$query,"",$msg) unless (($Person->{person_status} eq "admin") || ($vars->{person_status} eq "cron"));

# Analyze Request --------------------------------------------------------------------

my $format; my $action;
# while (my($vx,$vy) = each %$vars) { print "$vx = $vy <br>"; }

$action = $vars->{action} || "none";		# Determine Action
if ($vars->{feed}) { $action = "harvest"; }
if ($vars->{source} eq "queue") { $action = "queue"; }
$vars->{format} ||= "html";			# Determine Output Format

&diag(1,"<hr><center>gRSShopper HARVESTER</center><hr><br/>Action: $action <p>\n\n");

for ($action) {					# There is always an action

	/queue/ && do { &harvest_queue(); last; 		};
	/harvest/ && do { &harvest_feed($vars->{feed}); last; 		};
	/export/ && do { &export_opml($dbh,$query); last;	};
	/import/ && do { &import_opml($dbh,$query); last;	};
	/opmlopts/ && do { &opmlopts($dbh,$query); last;	};

						# Go to Home Page



&diag(1,"Harvester OK. For action use parameter ?action=<i>action</i><br>\n");

	exit;

}

if ($dbh) { $dbh->disconnect; }		# Close Database and Exit


exit;




# -------   Harvest Queue ------------------------------------------------------

# Harvests the next feed in the queue. Used by Cron

sub harvest_queue {  

#	my () = @_;

	&diag(1,"Harvesting next in Queue<br/>\n");
	my $qtime = time;
	

					# Find next in queue
	my $stmt = "SELECT feed_id FROM feed WHERE feed_status = 'A' OR feed_status = 'Published' ORDER BY feed_lastharvest LIMIT 0,1";
	my $next = $dbh->selectrow_hashref($stmt);
	my $now = time;


	if ($next->{feed_id}) {			# If found, Harvest Feed

		&diag(1,"Next in queue is feed number $next->{feed_id} <br/>\n");
		&db_update($dbh,"feed",{feed_lastharvest=>$now},$next->{feed_id});
		&harvest_feed($next->{feed_id});

	} else {

		&diag(1,"Cannot find next in queue<br/>\n");
		return;

	}

		
	return $next->{feed_id};

}





# -------   Harvest Feed ------------------------------------------------------

# Harvests feed specified on input

sub harvest_feed {
	
	my ($feedid) = @_;

	my $feedrecord = gRSShopper::Feed->new({dbh=>$dbh,id=>$feedid});

	unless ($feedrecord) {
		&diag(1,"Could not find a record for feed number $feedid<br>\n");
		return;
	}	
	
	
	if ($feedrecord->{feed_type} =~ /twitter/i) {
		&twitter_harvest($feedrecord);
	} else {
		&get_url($feedrecord);
	}
	
	&harvest_process_data($feedrecord);	
	
}


# -------   Harvest URL ------------------------------------------------------

sub harvest_url {
	
	my ($url) = @_;
	
	my $feedrecord = gRSShopper::Feed->new({dbh=>$dbh});
	$feedrecord->{feed_link} = $url;
	&get_url($feedrecord);
	&harvest_process_data($feedrecord);
	
}

# -------   Harvest Twitter ------------------------------------------------------

sub twitter_harvest {
	
	my ($feedrecord) = @_;			# data is stored in $feedrecord->{processed};
						# and processed in &save_records()
	
	print "Content-type: text/html\n\n";
	
 # print "Harvesting Twitter<p>"; 										# Access Account
	
	&error($dbh,"","","Twitter posting requires values for consumer key, consumer secret, token and token secret")
		unless ($Site->{tw_cckey} && $Site->{tw_csecret} && $Site->{tw_token} && $Site->{tw_tsecret});
		
	my $nt = Net::Twitter::Lite::WithAPIv1_1->new(
		consumer_key        => $Site->{tw_cckey},
		consumer_secret     => $Site->{tw_csecret},
		access_token        => $Site->{tw_token},
		access_token_secret => $Site->{tw_tsecret},
	);
	
		
	my $r = $nt->search($feedrecord->{feed_link});
			
	while (my($rx,$ry) = each %$r) { 
		if ($rx eq "search_metadata") {
#			while (my($mrx,$mry) = each %$ry) { print "$mrx = $mry <br>"; }
		}
		
		elsif ($rx eq "statuses") {
			foreach my $status (@$ry) { 
				next if ($status->{text} =~ /^RT/);		# Skip retweets (the bane of twitter)
				my $item;my $userstr = "";
	#			print "<hr>";
				while (my($srx,$sry) = each %$status) { 

#					print "$srx = $sry <br>"; 
					if ($srx eq "user") {

						
#						print "User info:-------------<br>";
						while (my($ssrx,$ssry) = each %$sry) { 
#							print "$ssrx = $ssry <br>"; 
						}
#						print "-----------------<br>";
#						print "Name: $sry->{name} <br>";
#						print "Screen Name: $sry->{screen_name} <br>";
						$item->{screen_name} = $sry->{screen_name};
						$item->{name} = $sry->{name};
						$item->{profile_image_url_https} = $sry->{profile_image_url_https};
#						print qq|<br>|; 
					}
					
				}
				my ($created,$garbage) = split / \+/,$status->{created_at};
				$status->{text} =~ s/\x{201c}/ /g;	# "
				$status->{text} =~ s/\x{201d}/ /g;	# "
				$item->{link_link} = "https://twitter.com/".$item->{screen_name}."/status/".$status->{id};
				$item->{link_title} = $status->{text};
				$status->{text} =~ s/#(.*?)( |:)/<a href="https:\/\/twitter.com\/search?q=%23$1&src=hash">#$1<\/a> /g;
				$status->{text} =~ s/http:(.*?)("|”|$| )/<a href="http:$1">http:$1<\/a> /g;		
				$status->{text} =~ s/\@(.*?)( |:)/<a href="https:\/\/twitter.com\/$1">\@$1<\/a> /g;				
				$item->{link_description} = qq|<div class="tweet" style="clear:both;"> 
					<img src="$item->{profile_image_url_https}" align="left" hspace="10">
					<a href="$item->{link_link}">\@|.$item->{screen_name}.qq|</a>: |.
					$status->{text} . " ($created)</div>";
					
#				print $item->{link_description} . "<p>";
				push @{$feedrecord->{processed}->{items}},$item;
				

			}
	#		&save_item($feed,$item);
		}
	}	
	foreach my $its (@{$feedrecord->{processed}->{items}}) {
		
		print $its->{link_description} . "<p>";
	}
	&save_records($feedrecord);
  print "Allz done<p>";  
	exit;
}


# -------   Harvest: Process Data ------------------------------------------------------

sub harvest_process_data {
	
	my ($feedrecord) = @_;

	if ($feedrecord->{feedstring} =~ /^BEGIN:VCALENDAR/) {
		&diag(1,"Feed is vcalendar, ick<br>\n");
		return;	
	} elsif ($feedrecord->{feedstring} =~ /<rss|<feed/i) {
		&diag(1,"Harvesting RSS/Atom feed.<br>\n"); 		
		&parse_feed($feedrecord);
	} else {
		&diag(1,"Harvest failed for some reason.<br>\n"); 
		&diag(1,"<form><textarea cols=80 rows=20>$feedrecord->{feedstring}</textarea></form> <br>\n");
		return;
	}
	
	&replace_cdata($feedrecord);						# Replace CDATA

	&scrape_items($feedrecord);
	
	&clean_feed_input($feedrecord);

	&save_records($feedrecord);
	

	#&post_processing($feed);
	#&diag(9,"<form><textarea cols=140 rows=80>".$feed->{feedstring}."</textarea><form>");
#my $file = "/var/www/feeds/feeds.feedburner.com_wordpress_ACyV_format_xml";

#my $last = (stat($file))[9];


#$feed->{feedstring} = &get_file($file);	
	
	return;	
}



# -------   Harvest: Process Data ------------------------------------------------------

# URL is stored in gRSShopper feed record, $feed->{feed_link}

sub get_url {

	my ($feedrecord) = @_;
	$feedrecord->{feedstring} = "";
	my $cache = &feed_cache_filename($feedrecord->{feed_link},$Site->{feed_cache_dir});
	

#	if ((time - (stat($cache))[9]) < (60*60)) {			# If the file is less than 1 hour old

#		&diag(1,"Getting file from common cache<br>");
#		$feedrecord->{feedstring} = &get_file($cache);

#	} else {	

		&diag(1,"Harvesting $feedrecord->{feed_link}<br>\n");


		my $ua = LWP::UserAgent->new();
		$ua->agent("Mozilla/8.0");				# I'd rateher say $ua->agent("gRSShopper") but too many sites reject it
		my $response = $ua->get($feedrecord->{feed_link},{
			'Accept' => 'text/html,application/xhtml+xml,application/xml;q=0.9,*/*;q=0.8',
			'Accept-Charset' => 'iso-8859-1,*,utf-8',
			'timeout' => '30'
		});
#'Accept' => 'text/html,application/xhtml+xml,application/xml;q=0.9,*/*;q=0.8',
# 			'Accept' => '*/*','application/atom+xml',
 	
		if (! $response->is_success) { 
			my $err = $response->status_line;
			my $as_string = $response->as_string;
			my ($r_header,$r_body) = split "<",$as_string;
			$r_header =~ s/\n/<br>\n/g;
			#$err .= $response->head;
			&diag(1,"ERROR:  $err ".$r_header." <br>$r_body<br>\n\n");
			return;
		}
	
		$feedrecord->{feedstring} =~ s/^\s+//;			
		$feedrecord->{feedstring} = $response->content;		
		unless ($feedrecord->{feedstring}) {
			&diag(1,"ERROR: Couldn't get $feedrecord->{feed_link} <br>\n\n");
			return;
		}

									# Save common cache
		open FOUT,">$cache" or die qq|Error opening to write to $cache: $! \nCheck your Feed Cache Location at this location: \n$Site->{st_cgi}admin.cgi?action=harvester\n\n|;
		print FOUT $feedrecord->{feedstring}  or die "Error writing to $cache: $!";
		close FOUT;
		chmod 0666, $cache or &diag(1,"Couldn't chmod $cache: $! <br>\n");
#	}
	

		
	return;

}

sub feed_cache_filename  {
	

	my ($feedurl,$feed_cache_dir) = @_;
	
	my $feed_file = $feedurl;
	unless ($feed_cache_dir =~ /\/$/) {  $feed_cache_dir .= "/"; }
	$feed_file =~ s/http:\/\///g;
	$feed_file =~ s/https:\/\///g;	
	$feed_file =~ s/\%|\$|\@//g;	
	$feed_file =~ s/(\/|=|\?)/_/g;
	
	return $feed_cache_dir.$feed_file;
	
}



sub parse_feed {

	my ($feedrecord) = @_;
#	&diag(8,"<form><textarea cols=140 rows=80>".$feedrecord->{feedstring}."</textarea><form><p>\n\n");	
	&diag(4,"Parsing Feed $feedrecord->{feed_id}: ".$feedrecord->{feed_title}."<p>\n\n");

	&process_cdata($feedrecord);						# Remove CDATA
	my $linecount = 0;						# Initialize line counter
	$vars->{content} = "off";					# Initialize content flag
	
	my @lines = split "<",$feedrecord->{feedstring}; 			# Split into lines

	foreach my $l (@lines) {					# For each line...
		# For each line...
		last if ($linecount > 5000);


 		if ($linecount == 1) {					# First line, make sure we don't have a feed error
			return "feed error" unless			# which would be indicated if the first line isn't xml
				 ($l =~ /\?xml/i || $l =~ /rss/i);	#     (note Google alert starts with <rss...> )
		}
		$linecount++; $vars->{linecount}="$linecount";		# Special for link = http://www.cbc.ca/podcasting
		
		my ($tag,$attributes,$content) = &process_line($l);	# Process line to get tag, attributes, content
		$feedrecord->{content_buffer} .= $content;	
		$feedrecord->{attributes_buffer} .= $attributes;
		

		#&diag(7,"<br>Tag: $tag <br>Attributes: $attributes <br>Content: $content <br>");
		
	
		if ($vars->{content} eq "on") {				# If we're processing content
		
		
			unless ($tag =~ /^\// && &detect_content($tag)) {	#   then unless we're closing the content tag
			
				$feedrecord->{content_buffer} .= "<".$l;	#      Restore < and add line to the content string
				#&diag(7,"Content: $con <br>");
				next;					#      and move on
			}
		}


		
		if ($tag =~ s/^\///) {					# If it's a close element tag
					
			&element_close($feedrecord,$tag);			#     Close Element

		} else {						# Otherwise
	
			&element_open($feedrecord,$tag);			#     Open Element	
	
			if ($attributes =~ /(.*?)(\/|\?)$/) {		# Single-line element, close here
				&element_close($feedrecord,$tag);		#     Close Element
			}
		}		
		

	}
	


}








#------------------------  Process CDATA

sub process_cdata {
	
	
	my ($feed) = @_;
	
	my $cdatacounter = 0;
	while ($feed->{feedstring} =~ s/<!\[CDATA\[(.*?)\]\]>/CDATA($cdatacounter)/ms) {
		$feed->{cdata}->[$cdatacounter] = "$1";
		$cdatacounter++;
	}	


}


#------------------------- Replace CData


sub replace_cdata {
	
	my ($feedrecord) = @_;
	my $feed = $feedrecord->{processed};
	my @items = @{$feed->{items}};
	&diag(0,"Replacing CDATA<br>\n");	
	
	
	# Feed Items
		
	while (my ($fx,$fy) = each %$feed) {
		if ($fx eq "items") {
			foreach my $item (@$fy) {
				while (my ($ix,$iy) = each %$item) {
					if ($iy && $ix =~ /link_/) { 
						$item->{$ix} =~ s/CDATA\((.*?)\)/$feedrecord->{cdata}->[$1]/msg; 
					}
				}
			}	
		} elsif ($fx eq "media") {
			foreach my $media (@$fy) {
				while (my ($mx,$my) = each %$media) {
					if ($my && $mx =~ /media_/) { 
						$media->{$mx} =~ s/CDATA\((.*?)\)/$feedrecord->{cdata}->[$1]/msg; 
					}
				}
			}	
		} elsif ($fy && $fx =~ /feed_/) { 
			$feed->{$fx} =~ s/CDATA\((.*?)\)/$feedrecord->{cdata}->[$1]/msg; 
		}
	}
}




#------------------------  Process line  --------------------

sub process_line {
	
	my ($l) = @_;
	$l =~ s/\n|\r//g;
	my ($element,$content) = split ">",$l;		# Split line at end of element
	$content =~ s/(^\s*|\s*$)//g;
	
	my @elementitems = split " ",$element;		# Carve off attributes to find tag in element
	my $tag = shift @elementitems;			
	my $attributes = join " ",@elementitems;	# Rebuild attribute string
	return ($tag,$attributes,$content);
	
}



#------------------------  Process URL  --------------------

sub process_url {
	
	my ($url) = @_;

	$url =~ s/utm=(.*?)$//;				# Wipe out utm parameters

	if ($url eq "http://www.cbc.ca/podcasting") { $url = $url . "#".$vars->{linecount}; }
	return $url;
	
	
}

#------------------------  Append to List  --------------------

# Some elements (eg. link_category) may consist of multiple items
# these are sorted as a string with ; as a delimiter for list items
# Does not add duplicate items

sub append_to_list {
	
	my ($list,$item) = @_;
	$item =~ s/\s*$//g;		# Nuke training white space
	my @listitems = split /;/,$list;
	foreach my $li (@listitems) { return if ($li eq $item); } # No duplicates
	if ($list) { $list .= ";"; }
	$list .= $item;
	return $list;
	
	
}


#------------------------  Process attributes  --------------------

#
#   Receive attribute string
#   Return hash with attribute name as key and value as value

sub process_attributes {
	
	my ($attributes) = @_;
	
	$attributes =~ s/\/$//;	my $del; my $att;					# Carve closing /
	if ($attributes =~ /=("|')/) { $del = $1; }					# Find delimeter ' or "
	my @attitems = split /$del /,$attributes;					# Split at the delimeter

	foreach my $ai (@attitems) {							# For each attribute				
		my ($attkey,$attval) = split/=$del/,$ai;				# Split at the delimiter
		$attval =~ s/$del$//;							# Carve trailing delimeter
		if ($attkey =~ /url|uri|href|src/) { &process_url($attval);}		# process URLs
		$att->{$attkey} = $attval;						# Store values
	}
	$att->{href} =~ s/utm=(.*?)$//;							# Wipe out utm parameters 
	$att->{src} =~ s/utm=(.*?)$//;							# Wipe out utm parameters 	
	return $att;
}

#------------------------  Element Open  --------------------

sub element_open {
	
	my ($feed,$tag) = @_;
	


	# If the element is a feed, link, author, publisher or media, create an object and add to object stack
	# If it's a content element (and might contain HTML) turn content flag on
	# Add the element to the tag stack

	if (my $type = &detect_object($tag)) {
	
		my $record = gRSShopper::Record->new;
		$record->{tag} = $tag; 
		$record->{type} = $type;
		$record->{attributes} = $feed->{attributes_buffer};
		unshift @{$feed->{objectstack}},$record;
	} 
	
	if (&detect_content($tag)) {  
		$vars->{content} = "on";
	}
	
	
	unshift @{$feed->{stack}},$tag;			# Add tag to stack
	
}

#------------------------  Element Close --------------------

sub element_close {
	
	my ($feed,$tag) = @_;
		
	my $child = ${$feed->{objectstack}}[0];	
	my $parent = ${$feed->{objectstack}}[1];
	

	
	my $type = &detect_object($tag);
	
	my $parenttype = $parent->{type};
	
#	my $type = @{$feed->{objectstack}}[0]->{type};
#	my $parenttype = @{$feed->{objectstack}}[1]->{type};
	
#	&diag(1," $tag - $type - $feed->{content_buffer} <br>\n");

	if ($type eq "link") {
		push @{$parent->{items}},$child;
		my $att = process_attributes($child->{attributes});      		# Sometimes 'entry' has attributes
		if ($att->{'gd:etag'}) { $child->{link_gdetag} = $att->{'gd:etag'}; }	# gd:etag
		
		&diag(9," - - Saving $child->{type}, to $parent->{type}<p>\n\n");
		
	}
	
	elsif ($type eq "author") {							# ^itunes:owner$|^author$|^dc:creator$
		push @{$parent->{authors}},$child;		
		
		$child->{author_name} = $feed->{content_buffer};
		&diag(9," - - <b>AUTHOR</b> Saving $child->{type}, to $parent->{type}<p>\n\n");
	}	
	
	elsif ($type eq "media") {							# ^image$|^media$|^media:content$
		push @{$parent->{media}},$child;
		
		my $att = process_attributes($child->{attributes});      		# 'Media:content' tag attributes
		if ($att->{url}) { $child->{media_url} = $att->{url}; }
		if ($att->{medium}) { $child->{media_type} = $att->{medium}; }
			
		&diag(9," - - Saving $child->{type}, to $parent->{type}<p>\n\n");
	}

	elsif (&detect_content($tag)) {  						# Content Tags
		$vars->{content} = "off";
		
		#	summary$|^media:text$|^content$|^content:encoded$|^description$
		for ($tag) {
			
			# content
			/^content$/i && do { _content($child,$feed->{content_buffer}); last; };
			
			# content:encoded
			/^content:encoded$/i && do { _content_encoded($child,$feed->{content_buffer}); last; };			
			
			# description
			/^itunes:summary$/i && do { _description($child,$feed->{content_buffer}); last; };
			
			# itunes
			/^itunes:summary$/i && do { _itunes_summary($child,$feed->{content_buffer}); last; };

			# media: text
			/^media:text$/i && do { _media_text($child,$feed->{content_buffer}); last; };
			
			# summary
			/^summary$/i && do { _summary($child,$feed->{content_buffer}); last; };			
			
		}
		

		
		$child->{$child->{type}."_".$tag} = $feed->{content_buffer};
		
		&diag(9,$tag.": ".$feed->{content_buffer}."<br>\n");
		

	}
	
	else {										# Other Tags
		
		&diag(9,$tag." ".$feed->{attributes_buffer}.": ".$feed->{content_buffer}."<br>\n");
			
		
		for ($tag) {
			
			# app
			/^app:edited$/i && do  { _app_edited($child,$feed->{content_buffer}); last; };
				
			# atom
			/^atom:updated$/i && do  { _atom_updated($child,$feed->{content_buffer}); last; };	
			/^atom:id$/i && do  { _atom_id($child,$feed->{content_buffer}); last; };			

			# blogChannel
			/blogChannel:blogRoll$/i && do { _blogChannel_blogRoll($child,$feed->{content_buffer}); last; };
		
			# category, itunes:category, media:category
			/category$/i && do { _category($child,$feed->{content_buffer},$feed->{attributes_buffer}); last; };

			# cloud
			/^cloud$/i && do { _cloud($child,$feed->{content_buffer}); last; };

			# comments
			/^comments$/i && do  { _comments($child,$feed->{content_buffer}); last; };

			# copyright
			/^copyrights$/i && do  { _copyright($child,$feed->{content_buffer}); last; };	
	
			# creativeCommons
			/^creativeCommons:license$/i && do  { _creativeCommons_license($child,$feed->{content_buffer}); last; };		
	
			# dc
			/^dc:date$/i && do  { _dc_date($child,$feed->{content_buffer}); last; };
			/^dc:subject$/i && do  { _dc_subject($child,$feed->{content_buffer}); last; };
			/^dc:publisher$/i && do  { _dc_publisher($child,$feed->{content_buffer}); last; };			
			/^dc:title$/i && do  { _dc_title($child,$feed->{content_buffer}); last; };		
	
			# docs
			/^docs$/i && do  { _copyright($child,$feed->{content_buffer}); last; };
			
			# enclosure
			/^enclosure$/i && do { _enclosure($child,$feed->{content_buffer},$feed->{attributes_buffer}); last; };	
			
			# feedburner
			/^feedburner:browserFriendly$/i && do { _feedburner_browserFriendly($child,$feed->{content_buffer}); last; };					
			/^feedburner:emailServiceId$/i && do { _feedburner_emailServiceId($child,$feed->{content_buffer}); last; };
			/^feedburner:feedburnerHostname$/i && do { _feedburner_feedburnerHostname($child,$feed->{content_buffer}); last; };					
			/^feedburner:info$/i && do { _feedburner_info($child,$feed->{content_buffer}); last; };	
			/^feedburner:origLink$/i && do { _feedburner_origLink($child,$feed->{content_buffer}); last; };
					
			# gd
			/^gd:extendedProperty$/ && do { _gd_extendedProperty($child,$feed->{content_buffer},$feed->{attributes_buffer}); last; };
			
			# geo
			/^geo:lat$/i && do { _geo_lat($child,$feed->{content_buffer}); last; };			
			/^geo:long$/i && do { _geo_long($child,$feed->{content_buffer}); last; };	
			/^georss:point$/i && do { _georss_point($child,$feed->{content_buffer}); last; };				
								
			# generator
			/^generator$/i && do { _generator($child,$feed->{content_buffer},$feed->{attributes_buffer}); last; };

			# guid
			/^guid$/i && do  { _guid($child,$feed->{content_buffer}); last; };
			
			# height
			/^height$/i && do  { _height($child,$feed->{content_buffer}); last; };

			# icon
			/^icon$/i && do  { _icon($child,$feed->{content_buffer}); last; };	
			
			# id
			/^id$/i && do  { _id($child,$feed->{content_buffer}); last; };					

			# issued
			/^issued$/i && do  { _issued($child,$feed->{content_buffer}); last; };	
			
			# itunes
			/^itunes:author$/i && do { _itunes_image($child,$feed->{content_buffer}); last; };	
			/^itunes:block$/i && do { _itunes_block($child,$feed->{content_buffer}); last; };				
			/^itunes:category$/i && do { _itunes_category($child,$feed->{content_buffer},$feed->{attributes_buffer}); last; };							
			/^itunes:copyright$/i && do { _itunes_copyright($child,$feed->{content_buffer},$feed->{attributes_buffer}); last; };	
			/^itunes:duration$/i && do { _itunes_duration($child,$feed->{content_buffer}); last; };									
			/^itunes:email$/i && do { _itunes_email($child,$feed->{content_buffer}); last; };	
			/^itunes:explicit$/i && do { _itunes_explicit($child,$feed->{content_buffer}); last; };
			/^itunes:keywords$/i && do { _itunes_keywords($child,$feed->{content_buffer}); last; };	
			/^itunes:image$/i && do { _itunes_image($child,$feed->{content_buffer},$feed->{attributes_buffer}); last; };	
			/^itunes:name$/i && do { _itunes_name($child,$feed->{content_buffer}); last; };						
			/^itunes:subtitle$/i && do { _itunes_subtitle($child,$feed->{content_buffer}); last; };	
						
			# language
			/^language$/i && do  { _language($child,$feed->{content_buffer}); last; };
			
			# lastBuildDate
			/^lastBuildDate$/i && do  { _lastBuildDate($child,$feed->{content_buffer}); last; };			
			
			# link, atom:link
			/link$/i && do { _link($child,$feed->{content_buffer},$feed->{attributes_buffer}); last; };	
		
			# logo
			/^logo$/i && do  { _logo($child,$feed->{content_buffer}); last; };	

			# managingEditor
			/^managingEditor$/i && do  { _managingEditor($child,$feed->{content_buffer}); last; };	
						
			# media - used for media objects, but will work for any object in this parser
			# TODO still need to add: media 5.13 ff http://www.rssboard.org/media-rss#media-restriction
			/^media:category$/i && do { _media_category($child,$feed->{content_buffer},$feed->{attributes_buffer}); last; };							
			/^media:credit$/i && do { _media_credit($child,$feed->{content_buffer},$feed->{attributes_buffer}); last; };
			/^media:description$/i && do { _media_description($child,$feed->{content_buffer},$feed->{attributes_buffer}); last; };
			/^media:hash$/i && do { _media_hash($child,$feed->{content_buffer},$feed->{attributes_buffer}); last; };							
			/^media:keywords$/i && do { _media_keywords($child,$feed->{content_buffer}); last; };
			/^media:player$/i && do { _media_player($child,$feed->{content_buffer},$feed->{attributes_buffer}); last; };							
			/^media:rating$/i && do { _media_rating($child,$feed->{content_buffer},$feed->{attributes_buffer}); last; };
			/^media:thumbnail$/i && do { _media_thumbnail($child,$feed->{content_buffer},$feed->{attributes_buffer}); last; };
			/^media:title$/i && do { _media_title($child,$feed->{content_buffer},$feed->{attributes_buffer}); last; };

			# modified
			/^moified$/i && do  { _modified($child,$feed->{content_buffer}); last; };

			# name
			/^name$/i && do  { _name($child,$feed->{content_buffer}); last; };
						
			# openSearch
			/^openSearch:totalResults$/i && do { _openSearch_totalResults($child,$feed->{content_buffer},$feed->{attributes_buffer}); last; };			
			/^openSearch:startIndex$/i && do { _openSearch_startIndex($child,$feed->{content_buffer},$feed->{attributes_buffer}); last; };			
			/^openSearch:itemsPerPage$/i && do { _openSearch_itemsPerPage($child,$feed->{content_buffer},$feed->{attributes_buffer}); last; };			

			# pingback
			/^pingback:server$/i && do  { _pingback_erver($child,$feed->{content_buffer}); last; };
			/^pingback:target$/i && do  { _pingback_target($child,$feed->{content_buffer}); last; };			

			# pubDate
			/^pubDate$/i && do  { _pubDate($child,$feed->{content_buffer}); last; };	

			# published
			/^published$/i && do  { _published($child,$feed->{content_buffer}); last; };
						
			# rights
			/^rights$/i && do  { _rights($child,$feed->{content_buffer}); last; };	
   	
			# slash
			/^slash:comments$/i && do  { _slash_comments($child,$feed->{content_buffer}); last; };
			/^slash:department$/i && do  { _slash_department($child,$feed->{content_buffer}); last; };
			/^slash:hit_parade$/i && do  { _slash_hit_parade($child,$feed->{content_buffer}); last; };
			/^slash:section$/i && do  { _slash_section($child,$feed->{content_buffer}); last; };
											
			# subtitle
			/^subtitle$/i && do  { _subtitle($child,$feed->{content_buffer}); last; };
			
			# syndication
			/^sy:updatePeriod$/i && do  { _sy_updatePeriod($child,$feed->{content_buffer}); last; };
			/^sy:updateFrequency$/i && do  { _sy_updateFrequency($child,$feed->{content_buffer}); last; };
			/^sy:updateBase$/i && do  { _sy_updateBase($child,$feed->{content_buffer}); last; };
						
			# tagline
			/^tagline$/i && do  { _tagline($child,$feed->{content_buffer}); last; };

			# thr
			/^thr:comments$/i && do  { _tagline($child,$feed->{content_buffer}); last; };
			/^thr:total$/i && do  { _tagline($child,$feed->{content_buffer}); last; };			
			
			# title
			/^title$/i && do  { _title($child,$feed->{content_buffer}); last; };

			# ttl
			/^trackback:ping$/i && do  { _trackback_ping($child,$feed->{content_buffer}); last; };

			# ttl
			/^ttl$/i && do  { _ttl($child,$feed->{content_buffer}); last; };					
											
			# updated
			/^updated$/i && do  { _updated($child,$feed->{content_buffer}); last; };

			# uri
			/^uri$/i && do  { _uri($child,$feed->{content_buffer}); last; };
						
			# url
			/^url$/i && do  { _url($child,$feed->{content_buffer}); last; };	
						
			# webMaster
			/^webMaster$/i && do  { _webMaster($child,$feed->{content_buffer}); last; };				

			# wfw
			/^wfw:comment$/i && do  { _wfw_comment($child,$feed->{content_buffer}); last; };
			/^wfw:comments$/i && do  { _wfw_comments($child,$feed->{content_buffer}); last; };
			/^wfw:commentRss$/i && do  { _wfw_commentRSS($child,$feed->{content_buffer}); last; };	
			
			# width
			/^width$/i && do  { _width($child,$feed->{content_buffer}); last; };	
			
			# xml - don't do anything
			/^channel$/i && do { last; };
			/^rss$/i && do { last; };
			/^\?xml$/i && do { last; };
			/^\?xml-stylesheet$/  && do { last; };
			
			&diag(0,qq|<p class="red"><b>Unknown element $tag</b><br>\n </p>\n\n|);							
	
						
		}

		
	}


	
	${$feed->{objectstack}}[0] = $child;	
	${$feed->{objectstack}}[1] = $parent;
	
	
	if ($child->{type} eq "feed") { $feed->{processed} = $child; }
	
	
	if (&detect_content($tag)) {  $vars->{content} = "off";  }
	
	

	
	#$feed->{processed} = ${$feed->{objectstack}}[0];	# Save object
	
	
	
	shift @{$feed->{stack}};					# Remove tag from stack
	if ($type) { 
		shift @{$feed->{objectstack}}; 
		
		
		}	# If object, remove object
	$feed->{content_buffer} = "";					# Clear content buffer
	$feed->{attributes_buffer} = "";
}


#------------------------  Detect Object --------------------
#
#	Defines which tags are objects, returns the object type
#

sub detect_object {
	
	my ($tag) = @_;
	
	my $type = "";
	if ($tag =~ /(^feed$|^channel$)/i) { $type = "feed"; }
	elsif ($tag =~ /(^item$|^entry$)/i) {  $type = "link"; }
	elsif ($tag =~ /(^itunes:owner$|^author$|^dc:creator$)/i) {  $type = "author"; }	
	elsif ($tag =~ /(^dc:publisher$)/i) {  $type = "publisher"; }	
	elsif ($tag =~ /(^itunes:image$|^image$|^media$|^media:content$)/i) {  $type = "media"; }	
	
	return $type;
}


#------------------------  Detect Content --------------------
#
#	Defines which tags are content types, and might contain html
#

sub detect_content {
	
	my ($tag) = @_;
	$tag =~ s/^\///;    # strip leading slash, to detect closes as well
	my $type = "";
	if ($tag =~ /(summary$|^media:text$|^content$|^content:encoded$|^description$)/i) {  
		$type = "content";
	}
	return $type;
}





#------------------------  Merge Media  --------------------

# Loop through scraped media items and merge duplicates


sub merge_media {
	
	my ($feed,$item) = @_;

			
	&diag(9,"MERGING<br>\n");
	&diag(9,"Item: ".$item->{link_title}." merge <br>\n");
	
	my @new_list = ();
	foreach my $xmedia (@{$item->{media}}) {
		my $duplicate = 0;
		foreach my $ymedia (@new_list) {
			if ($xmedia->{media_url} eq $ymedia->{media_url}) {
				while (my ($mx,$my) = each %$xmedia) {
					if ($my) {
						$ymedia->{$mx} ||= $my; 
						&diag(" -- -- $mx = $my <br>\n"); 
					}
				}
				&diag(9,"Rejecting duplicate $ymedia->{media_url} <br>\n");
				$duplicate = 1;
			}
		}
		unless ($duplicate) { &diag(9,"Pushing $xmedia->{media_url} <br>\n"); }
		unless ($duplicate) { push @new_list,$xmedia; }
	}
	@{$item->{media}} = @new_list;	
	
	
}


#------------------------  Save Records  --------------------

# Fill out missing data by flowing values down from higher level elements,
# eg. feed->{feed-author} flows into $item->{link_author} if link_author is empty
# We also find author information and flow it up
# Save all recordes in feed harvest


sub save_records {
	

			
	my ($feedrecord) = @_;
	my $feed = $feedrecord->{processed};
	my @items = @{$feed->{items}};
	&diag(1,"<hr> Saving Records <hr>\n\n");
	
	$feed->{feed_creator} = $Person->{person_id};			# Change to Person later
	$feed->{feed_crdate} = time;

	
	# Fill out feed elements from feed record in DB	
	while (my ($fx,$fy) = each %$feedrecord) {	
		$feed->{$fx} ||= $fy;
	}	
	
	# Flow feed values to feed media
	foreach my $media (@{$feed->{media}}) {
		
		&flow_values($feed,"feed",$media,"media");				# Flow feed values to feed items
	
		$media->{media_feedname} = $feed->{feed_title};
		$media->{media_feedurl} = $feed->{feed_html};
		$media->{media_feedid} = $feed->{feed_id};	
	}
	
	
	foreach my $item (@{$feed->{items}}) {
		&diag(1,"<hr>Item $item->{link_title} \n$item->{link_link}\n");
						
		if (&is_existing_link($item)) { &diag(1,"  -- Already Exists<br>\n"); next; }
		&diag(1," -- New item <br>\n");

		
		&flow_values($feed,"feed",$item,"link");			# Flow feed values to feed items	
		
		$item->{link_feedname} = $feed->{feed_title};
		$item->{link_feedurl} = $feed->{feed_html};
		$item->{link_feedid} = $feed->{feed_id};
			
		&find_author_information($feed,$item);				# Find authors and save as appropriate
		
		&find_media_information($feed,$item);				# Find media and save as appropriate	
		
		&find_link_information($feed,$item);				# Find media and save as appropriate	
		
		&save_item($feed,$item);						# Save Item 
&diag(2,"Item saved: $item->{link_id} <p>\n\n");		
		
		&diag(5,"Saving graph for item $item->{link_id} <p>\n\n");
		foreach my $aut (@{$item->{authors}}) { &save_graph("by",$item,$aut); }		# Save graphs
		foreach my $med (@{$item->{media}}) { &save_graph("contains",$item,$med); }		
		foreach my $lin (@{$item->{links}}) { &save_graph("links",$item,$lin); }
		
		&save_graph("contains",$feed,$item);	
		
		&rules($feed,$item);						# Rules
			
	
	}			
	
	&save_feed($feed);							# Save feed
	
}

#----------------------------- Flow Values ------------------------------
#
#  Flow values from one type of record to another
#  Eg., fill empty valies in a link with values from the feed


sub flow_values {
	
	my ($from,$from_prefix,$to,$to_prefix) = @_;
	
	while (my ($fx,$fy) = each %$from) {	
		my $fprefix = $from_prefix."_";
		my $tprefix = $to_prefix."_";
		next unless ($fx =~ /$fprefix/i);
		next if ($fx =~ /_id$/i);
		my $tx = $fx;
		$tx =~ s/$fprefix/$tprefix/ig;
		$to->{$tx} ||= $from->{$fx};			
	}
	
	
}



#----------------------------- Save Author ------------------------------


sub save_author {
	
	my ($feed,$author) = @_;
	
	if ($author->{author_name}) {
		$author->{author_creator} ||= $Person->{person_id};
		$author->{author_crdate} ||= time;	
		$author->{author_link} ||= $feed->{feed_html};
		$author->{author_id} = &db_insert($dbh,$query,"author",$author);
			&diag(2,qq|&nbsp;&nbsp;&nbsp;Creating new author record for 
			<a href="$Site->{st_url}author/$author->{author_id}">$author->{author_name}</a><br/>\n|);	
	} 
}

#----------------------------- Save Item ------------------------------
#
#  Saves main feed item or entry
#  Can replace 'link' created earlier via scraping with original data
#  created through a feed harvest
#


sub save_item {
	
	my ($feed,$item) = @_;
	
	$item->{link_creator} ||= $Person->{person_id};
	$item->{link_crdate} ||= time;	
	$item->{link_orig} = "yes";		
	$item->{link_content} ||= $item->{link_description} || $item->{link_summary};
	$item->{link_status} = "Fresh"; 		# freshly minted content :) 
	
	unless ($item->{link_link} =~ /http(s|):/) {			# Catch relative links eg. Global maritivmes
		$item->{link_link} = $feed->{feed_html} . $item->{link_link};
		$item->{link_link} =~ s/\/\//\//g;			# Fix // in RL
	}
	
	if ($item->{link_id}) {
		my $ti = &db_get_record($dbh,"link",{link_id=>$item->{link_id}});
		unless ($ti->{link_orig} eq "yes") {
	
			if ($item->{link_link}) {
				&db_update($dbh,"link",$item,$item->{link_id});
				&diag(1,qq|Converting existing item  
					<a href="$Site->{st_url}link/$item->{link_id}">$item->{link_title}</a><br/>\n|);	
			}
		}
	} else {
		if ($item->{link_link}) {			
			$item->{link_id} = &db_insert($dbh,$query,"link",$item);
			&diag(1,qq|Save Item  
				<a href="$Site->{st_url}link/$item->{link_id}">$item->{link_title}</a><br/>\n|);	
		}
	}
}	

#----------------------------- Save Feed ------------------------------

sub save_feed {

	my ($feed) = @_;
	
							# Roll up author information
	foreach my $author (@{$feed->{authors}}) {
		unless ($author->{author_id}) {	&find_author_record($feed,$author); }
		&append_to_list($feed->{feed_author},$author->{author_id});
		&append_to_list($feed->{feed_authorname},$author->{author_name});
		&append_to_list($feed->{feed_authorlink},$author->{author_link});
	}
	
	
	# Special for Plusfeed
	if ($feed->{feed_link} =~ /plusfeeds/) { $feed->{feed_link} =~ s/plusfeeds/plusfeed/i; }
	
	if ($feed->{feed_id}) {
		my $fl = $feed->{feed_link}; $feed->{feed_link} = "";	# Don't change feed link
		&db_update($dbh,"feed",$feed,$feed->{feed_id}); 
		$feed->{feed_link} = $fl;
		&diag(2,"Updating feed $feed->{feed_id} - $feed->{feed_title} <br>\n");
	} else {
		$feed->{feed_crdate} = time;
		$feed->{feed_creator} = $Person->{person_id};
		$feed->{feed_title} ||= $feed->{feed_link};
		$feed->{feed_id} = &db_insert($dbh,$query,"feed",$feed);
		&diag(2,"Created new feed $feed->{feed_id} - $feed->{feed_title} <br>\n");
	}
		
	
								# Verify and save feed media
	foreach my $media (@{$feed->{media}}) {
		&find_media_information($media);
	}
	
	foreach my $author (@{$feed->{authors}}) {		# Author graph
		&save_graph("by",$feed,$author);
	}
	
}



#----------------------------- Save Link ------------------------------
#
#  Saves links contained inside items or entries, usually found by scraper
#

sub save_link {
	
	
	my ($link) = @_;
	
	if ($link->{link_link}) {
		$link->{link_creator} ||= $Person->{person_id};
		$link->{link_status} |= "Link";		
		$link->{link_crdate} ||= time;	
		$link->{link_id} = &db_insert($dbh,$query,"link",$link);
		&diag(3,qq|---- Save link  
			<a href="$Site->{st_url}link/$link->{link_id}">$link->{link_title}</a><br/>\n|);	
	}
	
}	



#----------------------------- Save Link ------------------------------

sub save_media {
	
	my ($media) = @_;
	
	if($media->{media_url}) {
print "Saving media:<br>"; while (my($mx,$my) = each %$media) { print "$mx = $my<br>"; }
		
		$media->{media_creator} = $Person->{person_id};
		$media->{media_crdate} = time;
		$media->{media_id} = &db_insert($dbh,$query,"media",$media);
		&diag(2,qq|---- Save Media  
			<a href="$media->{media_url}">$media->{media_title}</a><br/>\n|);	
	}
	
}

#----------------------------- Rules ------------------------------

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

sub rules {
	
	my ($feed,$item) = @_;
	&diag(4,"Rules<p>\n\n");
	my @rules = split ";",$feed->{feed_rules};			
	my $triggered = 0;
	foreach my $rule (@rules) {
		if ($rule =~ /^else/i) { next if $triggered; } 			# else
		else { $triggered = 0; }
		$rule =~ s/else//i; $rule =~ s/^\s*//;
		my ($if,$then) = split /\s*=>\s*/i,$rule;			# if - then
		if (&rule_conditions($if,$item)) { 
			$triggered = 1;
			&rule_actions($then,$item); 
		}
	}
}

sub rule_conditions {
	
	my ($if,$item) = @_;
	my $true = 1;								# Always true if there are no conditions
										
	my @conditions = split /\s*&\s*/,$if;
	foreach my $cond (@conditions) {	
		$true = 0;
		if ($cond =~ m/(.*?)=(.*?)/) {							# field = value
			my ($fieldlist,$match) = split /\s*=\s*/,$cond;
	 		foreach my $field (split /\s*\|\s*/,$fieldlist) {
	 			if ($item->{$field} eq $match) { $true = 1; }
				if ($item->{"link_".$field} eq $match) { $true = 1; }
	 		}
	 	} elsif ($cond =~ m/(.*?)\s*~\s*(.*?)/) {						# field ~ value
			my ($fieldlist,$match) = split /\s*~\s*/,$cond;
	 		foreach my $field (split /\s*\|\s*/,$fieldlist) { 			
	 			if ($item->{$field} =~ /$match/i) { $true = 1; }
				if ($item->{"link_".$field} =~ /$match/i) { $true = 1; }				
	 		}
	 	} elsif ($cond =~ m/(.*?)>(.*?)/) {						# field > value
			my ($fieldlist,$match) = split /\s*>\s*/,$cond;
	 		foreach my $field (split /\s*\|\s*/,$fieldlist) {
	 			if (defined($item->{$field}) && ($item->{$field} > $match)) { $true = 1; }
				if (defined($item->{"link_".$field}) && ($item->{"link_".$field} > /$match/i)) { $true = 1; }
	 		}
	 	} elsif ($cond =~ m/(.*?)<(.*?)/) {						# field < value
			my ($fieldlist,$match) = split /\s*<\s*/,$cond;
	 		foreach my $field (split /\s*\|\s*/,$fieldlist) {
	 			if (defined($item->{$field}) && ($item->{$field} < $match)) { $true = 1; }
				if (defined($item->{"link_".$field}) && ($item->{"link_".$field} < $match)) { $true = 1; }
	 		}
	 	}		
	 		
	 	last unless ($true);
	}
				
	return $true;
}			

	 


sub rule_actions {
	
	my ($then,$item) = @_;

#			do {} while ($then =~ s/\((.*?),(.*?)\)/COMMA/g);   # screen commas in brackets

	my @actions = split /(?![^(]+\)),/, $then;

#			my @actions = split ",",$then;			
	
	my $dbupdate = ();
	foreach my $a (@actions) {
		&diag(4,"$a<br>\n");
		if ($a =~ /autopost/i) { &rule_autopost($item); }		# autopost 
	
		elsif ($a =~ /=/) { &rule_assign($item,$a); }			# change value

		elsif ($a =~ /extract/i) { &rule_extract($item,$a); }		# extract
			
		elsif ($a =~ /remove/i) { &rule_remove($item,$a); }		# remove
			
	}
}


#----------------------------- Rule:  Autopost ------------------------------


sub rule_autopost {
	
	my ($item) = @_;

	my $post_id = &auto_post($dbh,$query,$item->{link_id});
	
}



#----------------------------- Rule:  Assign ------------------------------


sub rule_assign {
	
	my ($item,$a) = @_;

	my ($fieldlist,$match) = split /\s*=\s*/,$a;
	unless ($fieldlist =~ /_link/) { $fieldlist = "link_".$fieldlist; }				
	$item->{$fieldlist}=$match;		
	&db_update($dbh,"link",{$fieldlist=>$match},$item->{link_id}); 			
	
}


#----------------------------- Rule:  Extract ------------------------------


sub rule_extract {
	
	my ($item,$a) = @_;

	$a =~ s/extract\(//; $a =~ s /\)//;			
	my ($f,$s,$e) = split /,/,$a;
	next unless ($f && $e);
	unless ($f =~ /_link/) { $f = "link_".$f; }		# Standardize field names

	my $extracted = "";
	if ($s eq '^') { if ($item->{$f} =~ /^(.*?)$e/i) { $extracted = $1; } }	
	elsif ($e eq '$') { if ($item->{$f} =~ /$s(.*?)$/i) { $extracted = $1; }	}
	else { if ($item->{$f} =~ /$s(.*?)$e/i) { $extracted = $1; } }
				
	if ($extracted) { 
		$item->{$f} = $extracted;
		&db_update($dbh,"link",{$f=>$extracted},$item->{link_id}); 
	}		
	
}

#----------------------------- Rule:  Remove ------------------------------


sub rule_remove {
	
	my ($item,$a) = @_;

	$a =~ s/remove\(//; $a =~ s /\)//;			
	my ($f,$s,$e) = split /,/,$a;
	next unless ($f && $e);
	unless ($f =~ /_link/) { $f = "link_".$f; }		# Standardize field names

	my $removed = "";
	if ($s eq '^') { if ($item->{$f} =~ /^(.*?)$e/i) { $removed = $1; } }	
	elsif ($e eq '$') { if ($item->{$f} =~ /$s(.*?)$/i) { $removed = $1; }	}
	else { if ($item->{$f} =~ /$s(.*?)$e/i) { $removed = $1; } }
				
	if ($removed) { 
		$item->{$f} =~ s/$removed//ig;
		&db_update($dbh,"link",{$f=>$item->{$f}},$item->{link_id}); 
	}
}



#----------------------------- Find Author ------------------------------

sub find_author_information {
	
	my ($feed,$item) = @_;
	
	# Find author information
	if (not defined(@{$item->{authors}}) || @{$item->{authors}} == 0) {						# If no author inormation in item
		if (@{$feed->{authors}} > 0) {					# then use feed author information
			foreach my $aut (@{$feed->{authors}}) { push @{$item->{authors}}, $aut; }
		} else {							# or use values from the feed record
			my $aut = {author_name=>$feed->{feed_authorname},author_email=>$feed->{feed_authoremail},
				author_id=>$feed->{feed_author},author_link=>$feed->{feed_authorlink}};
			if ($aut) { push @{$item->{authors}}, $aut; }
		}
	}
		
										# Find author information from database
	foreach my $author (@{$item->{authors}}) {
		&find_author_record($feed,$author);
		if ($author->{author_id}) {					# And flow it back up
			&append_to_list($item->{link_author},$author->{author_id});
			&append_to_list($item->{link_authorname},$author->{author_name});
			&append_to_list($item->{link_authorlink},$author->{author_link});	
		}
	} 
} 

sub find_author_record {
	
	my ($feed,$author) = @_;
	
		
	return unless (&is_author($author)); 
	&diag(2,"---- Author: $author->{author_name}... \n");
	
	my $author_record = find_buffered_author($feed,$author);  
	if ($author_record) { 		# nice if it's already there			 
		while (my($ax,$ay) = each %$author_record) { $author->{$ax} ||= $ay; }
		&diag(2," in buffer...<br/>\n ");
		return;
	}	
	
								# Life is easier if we have an author ID
	if (!$author_record && $author->{author_id}) {
		$author_record = &db_get_record($dbh,"author",{author_id => $author->{author_id}}); 
	}  					
								
								# If there's an author URL, it's easy
								# Unless it's a blog that uses multiple authors
								
	if (!$author_record && $author->{author_link}) {				
		$author_record = &db_get_record($dbh,"author",{author_link => $author->{author_link}}); 
	} 			
	
	return if ($feed->{feed_link} =~ /twitter/);		# Bail here if it's a Twitter author
								# (& any multi-author feed)		
								
								# Next, try by author email address

	if (!$author_record && $author->{author_email}) {				
		unless ($author->{author_email} =~ /noreply/) {		# Skip place-holder emails
			$author_record = &db_get_record($dbh,"author",{author_email => $author->{author_email}}); 
		}
	} 
	
	
		
	if (!$author_record && $author->{author_name}) {	# Next, search by Name
		if ($author->{author_name} =~ /@/) {			# Name is an email address?
			$author_record = &db_get_record($dbh,"author",{author_email => $author->{author_name}}); 
		} 
		if (!$author_record) {
			$author_record = &db_get_record($dbh,"author",{author_name => $author->{author_name}}); 
		}
	}
	
								# Try using the author's nickname as a desperate last measure	
	if (!$author_record) {
		$author_record = &db_get_record($dbh,"author",{author_nickname => $author->{author_name}}); 
	} 


	if ($author_record) { 					 
		push @{$feed->{author_buffer}},$author_record;	# save to skip future db lookups
		while (my($ax,$ay) = each %$author_record) { $author->{$ax} ||= $ay; }
		&diag(2,"Found author $author->{author_id}<br/> \n");
				
	} else {		
		&save_author($feed,$author);				# Save Author
		push @{$feed->{author_buffer}},$author;
	
	}
	
	
}	

sub find_buffered_author {
	
	my ($feed,$author) = @_;
	
	foreach my $buffered (@{$feed->{author_buffer}}) {
		return $buffered if (
			($author->{author_name} && ($buffered->{author_name} eq $author->{author_name})) ||
			($author->{author_email} && ($buffered->{author_email} eq $author->{author_email})) ||
			($author->{author_link} && ($buffered->{author_link} eq $author->{author_link}))
			);
	}
	return 0;
	
}

#------------------------  Find Link --------------------

sub find_link {
	
	my ($feed,$item) = @_;
	
	return if ($item->{item_id});								# Find by url
	
	$item->{item_id} = &db_get_record($dbh,"link",{link_link => $item->{link_link}});

	
}



#------------------------  Find Link Information --------------------
#
# Checks for previously saved links, and saves new ones (generally from scrapers)

sub find_link_information {
	
	my ($feed,$item) = @_;
	
	foreach my $link (@{$item->{links}}) {				# Check for existing links
		$link->{link_id} = &db_locate($dbh,"link",{link_link=>$link->{link_link}});
		next if ($link->{link_id});				# Skip existing links
		&save_link($link);					# Save new link
	}
	
}

#------------------------  Find Media --------------------

sub find_media_information {
	
	my ($feed,$item) = @_;
	
	foreach my $imedia (@{$item->{media}}) {			# Flow item values to item media
		&diag(2,"Media: ");
		$imedia->{media_id} = &db_locate($dbh,"media",{media_url=>$imedia->{media_url}});
		if ($imedia->{media_id}) { 
			&diag(2,"$imedia->{media_title} already stored, id $imedia->{media_id} <br>\n"); 
			next; }						# Skip existing media
		&flow_values($item,"link",$imedia,"media");		
		&save_media($imedia);					# Save new media
	}
	
}

#------------------------  Scrape Items --------------------

sub scrape_items {
	
	my ($feedrecord) = @_;
	my $feed = $feedrecord->{processed};
	my @items = @{$feed->{items}};
	&diag(6,"<hr> SCRAPE ITEMS <hr>\n\n");	
	
	
	# Feed Items
		
	while (my ($fx,$fy) = each %$feed) {
		if ($fx eq "items") {
			
			foreach my $item (@$fy) {
				&diag(6,"<hr>Scraping Item: $item->{link_title}: <br>\n");
				my $scrapetext = &scrape_prepare($feed,$item);
				&scrape_links($feed,$item,$scrapetext);
				&scrape_images($feed,$item,$scrapetext);	
				&scrape_iframes($feed,$item,$scrapetext);
				&scrape_embeds($feed,$item,$scrapetext);			
				#&diag("<form><textarea cols=80 rows=10>$scrapedata</textarea></form>") ;
				#&diag($scrapedata);
				
				&merge_media($feed,$item);
				
			}	
		}
	}
	
}


#------------------------  Scrape Prepare --------------------

sub scrape_prepare {
	
	my ($feed,$item) = @_;
	my $type = $item->{type};
	&diag(6,"Scrape Prepapre: $type<br>\n");

#	my $description = &replace_cdata($item->{$type."_description"});
#	my $content = &replace_cdata($item->{$type."_content"});	
#	my $summary = &replace_cdata($item->{$type."_summary"});	

	my $scrapedata = $item->{$type."_description"};
	if ($item->{$type."_description"} ne $item->{$type."_content"}) { $scrapedata .= $item->{$type."_content"}; }
	if ($item->{$type."_description"} ne $item->{$type."_summary"}) { $scrapedata .= $item->{$type."_summary"}; }
	
	$scrapedata = decode_entities($scrapedata);   	# uses HTML::Entities	
	
	return $scrapedata;
}

#------------------------  Clean Feed Input --------------------

sub clean_feed_input {
	my ($feedrecord) = @_;
	
	my $feed = $feedrecord->{processed};
	my @items = @{$feed->{items}};
	
	foreach my $item (@items) {
	
		my $type = "link";



#	my $description = &replace_cdata($item->{$type."_description"});
#	my $content = &replace_cdata($item->{$type."_content"});	
#	my $summary = &replace_cdata($item->{$type."_summary"});

	# Remove HTML, preserving some formatting
	
	
		&strip_html(\$item->{$type."_description"});
		&strip_html(\$item->{$type."_description"});
		&strip_html(\$item->{$type."_description"});	
	}

}
	
	

#-------------------------- Scrape Links --------------------------------

sub scrape_links {

	my ($feed,$item,$scrapetext) = @_;
	

	&diag(5,"Scraping Links for $item->{link_title}<br>\n");

# Can't use string (" href="http://fnoschese.wordpres") as a HASH ref while "strict refs" in use at /var/www/cgi-bin/harvestx.cgi line 715.

	while($scrapetext =~ m/<a(.*?)>(.*?)</ig) {
		
		my $attributes = $1;
		my $att = &process_attributes($attributes);
		my $title = $2;
	
		next unless &is_url($feed,$att->{href});			# URL			
				
		unless ($title) { $title = &is_title($att); }			# title
		
		my $mimetype = &mime_type($att->{href});			# mimetype
		if (!$mimetype || $mimetype eq "unknown") { $mimetype = "text/html"; }		

		my $type = &is_type($att->{href},$mimetype);			# type
		
							
				
		if ($type =~ /link|archive|document/) { 
									# save as link
			my $link = gRSShopper::Record->new(tag=>'scraped',type=>'link',
				link_link=>$att->{href},link_title=>$title);   	
			push @{$item->{links}},$link;	

			&diag(6,qq|-- Found link: <a href="$att->{href}">$link->{link_title}</a> ) <br>\n|);
			
		} else {						# save as media
			

			my $media = gRSShopper::Record->new(tag=>'scraped',type=>'media',
				media_url=>$att->{href},media_title=>$title,media_mimetype=>$mimetype,
				media_height=>$att->{height},media_width=>$att->{width}); 			
			push @{$item->{media}},$media;		
				
			&diag(6,qq|-- Found media: <a href="$att->{href}">$media->{media_title}</a> ) <br>\n|);				
		
		}
	}
}

#-------------------------- Scrape Images --------------------------------

sub scrape_images {

	my ($feed,$item,$scrapetext) = @_;
	
	
	&diag(6,"Scraping Images for $item->{link_title}<br>\n");

	my $type;
		
	while ($scrapetext =~ m/<img(.*?)>/ig) {
		
		my $attributes = $1;
		my $att = &process_attributes($attributes);
		
					
		next unless &is_url($feed,$att->{src});			# URL
		$att->{src} =~ s/\?(.*?)$//i;				# Strip parameters from image URLs
		
		my $title = &is_title($att);				# Title
		
		my $description = $att->{alt}; 				# description
		unless ($description) { $description = $title; }				
		
		my $mimetype = &mime_type($att->{src});			# mimetype
		if (!$mimetype || $mimetype eq "unknown") { $mimetype = "image"; }

						
									# save as media
		my $media = gRSShopper::Record->new(tag=>'scraped',type=>'media',media_type=>"image",
			media_url=>$att->{src},media_title=>$title,media_description=>$description,
			media_mimetype=>$mimetype,media_height=>$att->{height},media_width=>$att->{width}); 
			
					
		push @{$item->{media}},$media;		
				
		&diag(6,qq|-- Found image: <a href="$att->{src}">$media->{media_title}</a> ) <br>\n|);
		
		
	}
}




#-------------------------- Scrape Embeds --------------------------------

sub scrape_embeds {
	
	
	my ($feed,$item,$scrapetext) = @_;

	&diag(6,"Scraping embeds for $item->{link_title}<br>\n");
	
	while($scrapetext =~ m/<embed(.*?)>/ig) {
		
		my $attributes = $1;
		my $att = &process_attributes($attributes);		
		
		next unless &is_url($feed,$att->{src});			# URL

		my $title = &is_title($att);				# Title
		
		my $description = $att->{alt}; 				# description
		unless ($description) { $description = $title; }			
	
		my $mimetype = $att->{type};				# mimetype
		$mimetype ||= &mime_type($att->{src});			
		if (!$mimetype || $mimetype eq "unknown") { $mimetype = "embed"; }
		
		my $type = &is_type($att->{src},$mimetype);		# type
		
				
		if ($type =~ /link|archive|document/) { 
									# save as link
			my $link = gRSShopper::Record->new(tag=>'scraped',type=>'link',
				link_link=>$att->{src},link_title=>$title,link_description=>$description);     		 
			push @{$item->{links}},$link;	

			&diag(6,qq|-- Found link: <a href="$att->{src}">$link->{link_title}</a> ) <br>\n|);

			
		} else {						# save as media
			
			my $media = gRSShopper::Record->new(tag=>'scraped',type=>'media',
				media_url=>$att->{src},media_title=>$title,media_mimetype=>$mimetype,
				media_height=>$att->{height},media_width=>$att->{width}); 	
			push @{$item->{media}},$media;		
				
			&diag(6,qq|-- Found media: <a href="$att->{src}">$media->{media_title}</a> ) <br>\n|);				

		}
		

	}
	
}



#-------------------------- Scrape Iframes --------------------------------

sub scrape_iframes {

	my ($feed,$item,$scrapetext) = @_;
	
	&diag(6,"Scraping iframes for $item->{link_title}<br>\n");
		
	while($scrapetext =~ m/<iframe(.*?)>/ig) {
		
							
		my $attributes = $1;
		my $att = &process_attributes($attributes);		
		
		next unless &is_url($feed,$att->{src});			# URL

		my $title = &is_title($att);				# Title
		
		my $mimetype = &mime_type($att->{src});			# mimetype
		
		my $type = &is_type($att->{src},$mimetype);		# type
		
		if ($type =~ /link|archive|document/) { 
			
			my $link = gRSShopper::Record->new({tag=>'scraped',type=>'link',
				link_link=>$att->{src},link_title=>$title});   		
			push @{$item->{links}},$link;	

			&diag(6,qq|-- Found link: <a href="$att->{src}">$link->{link_title}</a> ) <br>\n|);
			
		} else {						# save as media
			

			my $media = gRSShopper::Record->new(tag=>'scraped',type=>'media',
				media_url=>$att->{src},media_title=>$title,media_mimetype=>$mimetype,
				media_height=>$att->{height},media_width=>$att->{width}); 			
			push @{$item->{media}},$media;		
				
			&diag(6,qq|-- Found media: <a href="$att->{src}">$media->{media_title}</a> ) <br>\n|);
		}
	}
		

}





#------------------------  Is Audio --------------------

# Return 1 if URL is on the 'rejected' list

sub is_audio { 		# Would like to make this a loadable list at some point
	
	my ($url) = @_;
		
		
	my @audio = ('soundcloud.com','www.freesound.org');	
	foreach my $a (@audio) { if ($url =~ /$a/i) { return 1; } }
	return 0;
}



#----------------------------- Is Author ------------------------------

sub is_author {
	
	# Weed out authors with no names, authors named 'admin', etc
	
	my ($author) = @_;
		
	unless ($author->{author_name} || $author->{author_email} || $author->{author_link} || $author->{author_id}) { 
		&diag(9,"<p>Author from $author->{source} rejected; it has no name, email, url or id</p>\n\n"); return 0; }
	if ($author->{author_name} =~ /^admin$/i) { 
		&diag(9,"<p>Author from $author->{source} rejected; 'admin' is not an author name</p>\n\n"); return 0; }	
	if ($author->{author_name} =~ /^guest$/i) { 
		&diag(9,"<p>Author from $author->{source} rejected; 'guest' is not an author name</p>\n\n"); return 0; }		
	return 1;
	
}

#------------------------  Is Existing Link --------------------
#
# Makes sure not only whether or not the link exists, but also whether it's one harvested
# here (link_orig = "yes") or just something linked incidentally and recorded here
#

sub is_existing_link {
	
	my ($item) = @_;

	$item->{link_link} =~ s/\#(.*?)$//;				# Remove gunk
	$item->{link_link} =~ s/utm=(.*?)$//;
	
	$item->{link_id} = &db_locate($dbh,"link",{link_link=>$item->{link_link}});
	if ($item->{link_id}) { 
		my $tl = &db_get_record($dbh,"link",{link_id=>$item->{link_id}});
		if ($tl->{link_orig} eq "yes") { return  1; } 
	} 
	return 0;
}

#------------------------  Is Slideshow --------------------

# Return 1 if URL is on the 'slideshow' list

sub is_slides { 		# Would like to make this a loadable list at some point
	
	my ($url) = @_;
		

	my @slide = ('slideshare.net','slieshare.com');	
	foreach my $a (@slide) { if ($url =~ /$a/i) { return 1; } }
	return 0;
}

#------------------------  Is Title --------------------

# Return title based on attributes

sub is_title {
	
	my ($att) = @_;
	my $title = $att->{title};						# try 'title'
	unless ($title) { $title = $att->{name}; }				# try 'name'
	unless ($title) { $title = $att->{alt}; }				# try 'alt'
	unless ($title) {							# try url
		my $url = $att->{src} || $att->{url} || $att->{href};
		my @mtitlearr = split "/",$url; $title = pop @mtitlearr; 
	}		
	return $title;
}

#------------------------  Is Type --------------------

# Return type based on URL and mimetype

sub is_type { 		# Would like to make this a loadable list at some point
	
	my ($url,$mimetype) = @_;
	
	my $type;
	if (&is_video($url) || $mimetype =~ /video/i) {	 $type = "video"; }		# video
	elsif (&is_audio($url) || $mimetype =~ /audio/i) {  $type = "audio"; }		# audio
	elsif (&is_slides($url)) { $type = "slides"; }					# slideshare
	elsif ($mimetype =~ /image/i) {	$type = "image"; }				# image
	elsif ($mimetype =~ /pdf|msword|powerpoint/i) {	$type = "document"; }		# document
	elsif ($mimetype =~ /zip|tar|binhex/i) { $type = "archive"; }			# archive
	else {	$type = "link";	 }							# link
	return $type;
}


#------------------------  Is URL --------------------

# Return 0 if URL is on the 'rejected' list

sub is_url { 		# Would like to make this a loadable list at some point
	
	my ($feed,$url) = @_;

	my $href;
	
	return 0 unless ($url =~ /(http|https):\/\//);						 	# No relative URLs
	if ($feed->{feed_html}) { return 0 if ($url =~ /$feed->{feed_html}/); }				# - don't scrape internal links
	return 0 if ($url =~ /#!/);									# - Don't scrape hashbang links			
	my @rejected = ('api.tweetmeme.com/','feeds.wordpress.com','api.postrank.com','feeds.feedburner.com',
		'www.diigo.com/user/', 'http://academicacareers.ca/','stats.wordpress.com','gravatar.com');	
	foreach my $a (@rejected) { if ($url =~ /$a/i) { return 0; } }
	return 1;
}

#------------------------  Is Video --------------------

# Return 1 if URL is on the 'video' list

sub is_video { 		# Would like to make this a loadable list at some point
	
	my ($url) = @_;
		
	my @video = ('youtu.be','video.umwblogs.org','www.openshotvideo.com','blip.tv','www.youtube.com','www.theonion.com/video');	
	foreach my $a (@video) { if ($url =~ /$a/i) { return 1; } }
	return 0;
}





#------------------------  Post Processing --------------------

sub post_processing {
	
	my ($feedrecord) = @_;
	my $feed = $feedrecord->{processed};
	my @items = @{$feed->{items}};
	&diag(5,"<hr> POST PROCESS <hr>\n\n");
		
	# Feed elements
	while (my ($fx,$fy) = each %$feed) {	
		next if &detect_object($fx);
		if ($fy) { &diag(9," -- $fx = $fy <br>\n"); }
	}
	
	# Feed authors
	while (my ($fx,$fy) = each %$feed) {	
		if ($fx eq "authors") { 
			foreach my $author (@$fy) {
				&diag(5,"Author: $author->{author_name}<br>\n");  
				while (my ($ax,$ay) = each %$author) {
					if ($ay) { &diag(9," -- -- $ax = $ay <br>\n"); }
				}
			}
		}
	}
		
	# Feed media
	while (my ($fx,$fy) = each %$feed) {	
		if ($fx eq "media") { 
			foreach my $media (@$fy) {
				&diag(5,"Media: $media->{media_title}");  
				while (my ($mx,$my) = each %$media) {
					if ($my) { &diag(9," -- -- $mx = $my <br>\n"); }
				}
			}
		}
	}
			
	
	# Feed Items
		
	while (my ($fx,$fy) = each %$feed) {
		if ($fx eq "items") {
			
			foreach my $item (@$fy) {
				&diag(3,qq|Item: <a href="$item->{link_link}">$item->{link_title}</a><br>\n|);  
				
				# Item Elements
				while (my ($ix,$iy) = each %$item) {
					next unless ($ix =~ /link_/);

					next if ($ix =~ /description/ || $ix =~ /content/);
					&diag(9," -- $ix = $iy <br>\n");
				}
				
				# Feed Authors
				foreach my $author (@{$item->{authors}}) {
					&diag(5,"<br>-- AUTHOR: $author->{author_title} , $author->{author_name}<br>\n");
					while (my ($ax,$ay) = each %$author) {
						if ($ay) { &diag(9," -- -- $ax = $ay <br>\n"); }
					}
				}
					
				# Item Media
				foreach my $media (@{$item->{media}}) {
#					next unless (&is_url($feed,$media->{media_url}));			# punt gravatar
					&diag(5,"<br>-- MEDIA: $media->{media_title}<br>\n");  
					while (my ($mx,$my) = each %$media) {
						if ($my) { &diag(9," -- -- $mx = $my <br>\n"); }
					}
				}

				
				# Item Links
				foreach my $link (@{$item->{links}}) {
#					next unless (&is_url($feed,$link->{link_link}));			# punt gravatar
					&diag(5,"<br>-- LINK: $link->{link_title}<br>\n");  
					while (my ($lx,$ly) = each %$link) {
						if ($ly) { &diag(9," -- -- $lx = $ly <br>\n"); }
					}
				}
			}
		} 
	}
}




#----------  tags ---------------------


sub _app_edited {
	
	my ($element,$content) = @_;
	my $type = $element->{type};
		
	$element->{$type."_updated"} = $content;			
}


sub _atom_id {
	
	my ($element,$content) = @_;
	my $type = $element->{type};
		
	$element->{$type."_blogID"} = $content;		
}


sub _atom_updated {
	
	my ($element,$content) = @_;
	my $type = $element->{type};
		
	$element->{$type."_updated"} = $content;	
}


sub _blogChannel_blogRoll {
	
	my ($element,$content) = @_;
	my $type = $element->{type};
		
	$element->{$type."_blogroll"} = $content;	
}


sub _category {

	my ($element,$content,$attributes) = @_;
	my $type = $element->{type};
	


	if ($attributes) {
		my $att = process_attributes($attributes);      				
		$content .= $att->{term};
		if ($att->{scheme}) { $content = $att->{scheme} . ":" . $content; }
	}
	$element->{$type."_category"} = &append_to_list($element->{$type."_category"},$content);
	

}

sub _cloud {

	my ($element,$content,$attributes) = @_;
	my $att = process_attributes($attributes);      		# Cloud always has attributes
	my $type = $element->{type};
		
	
	$element->{$type."_cloudDomain"} = $att->{domain};
	$element->{$type."_cloudPort"} = $att->{port};
	$element->{$type."_cloudPath"} = $att->{path};			
	$element->{$type."_cloudRegister"} = $att->{registerProcedure};
	$element->{$type."_cloudProtocol"} = $att->{protocol};	
	
}


sub _comments {
	
	# Obviously a very partial represendation of the slash extension

	
	my ($element,$content) = @_;
	my $type = $element->{type};
		
	$element->{$type."_commentURL"} = $content;		
}


sub _content {
	
	my ($element,$content) = @_;
	my $type = $element->{type};
		
	$element->{$type."_content"} = $content;	
}


sub _content_encoded {
	
	my ($element,$content) = @_;
	my $type = $element->{type};
		
	$element->{$type."_content"} = $content;	
}


sub _copyright {
	
	my ($element,$content,$attributes) = @_;
	my $type = $element->{type};
		
	my $att = process_attributes($attributes);      		
	if ($att->{url}) { $content .= ";".$att->{url}; }		
	$element->{$type."_copyright"} = $content;		
	
}


sub _creativeCommons_license {
	
	my ($element,$content) = @_;
	my $type = $element->{type};
		
	$element->{$type."_copyright"} = $content;		
	
}



sub _dc_date {
	
	my ($element,$content) = @_;
	my $type = $element->{type};

	$element->{$type."_updated"} ||= $content;			
	$element->{$type."_issued"} ||= $content;		
	
}


sub _dc_publisher {	# I might make this an object later
	
	my ($element,$content) = @_;
	my $type = $element->{type};

	$element->{$type."_publisher"} ||= $content;			
	
}

sub _dc_subject {

	my ($element,$content) = @_;
	my $type = $element->{type};
	
	$content =~ s/,\s*/;/g;			# gRSShopper uses ; to delimit list items
	$element->{$type."_subject"} = &append_to_list($element->{$type."_topic"},$content);	
}


sub _dc_title {
	
	my ($element,$content) = @_;
	my $type = $element->{type};
		
	$element->{$type."_title"} = $content;		
	
}


sub _description {
	
	my ($element,$content) = @_;
	my $type = $element->{type};
		
	$element->{$type."_description"} = $content;	
}


sub _docs {
	
	my ($element,$content) = @_;
	my $type = $element->{type};
		
	$element->{$type."_docs"} = $content;		
	
}

sub _enclosure {

	my ($element,$content,$attributes) = @_;
	my $att = process_attributes($attributes);      		# Enclosure always has attributes
	my $type = $element->{type};
		
	my $media = gRSShopper::Record->new;     			# Set values                          
	$media->{media_url} = $att->{url};
	$media->{media_size} = $att->{length};
	$media->{media_mimetype} = $att->{type};
	my @mtitlearr = split "/",$att->{url};
	$media->{media_title} = pop @mtitlearr;
	$media->{type} = "media";

	push @{$element->{media}},$media;
	
}
	
	
sub _feedburner_browserFriendly {
	
	my ($element,$content,$attributes) = @_;
	my $att = &process_attributes($attributes);
	my $type = $element->{type};
	
	if ($att->{uri}) { $element->{$type."_browserFriendly"} =  $att->{uri}; }
	
}
	
	
sub _feedburner_emailServiceId {
	
	my ($element,$content,$attributes) = @_;
	my $att = &process_attributes($attributes);
	my $type = $element->{type};
	
	if ($att->{uri}) { $element->{$type."_feed_feedburnerid"} =  $att->{uri}; }
	
}

sub _feedburner_feedburnerHostname {
	
	my ($element,$content,$attributes) = @_;
	my $att = &process_attributes($attributes);
	my $type = $element->{type};
	
	if ($att->{uri}) { $element->{$type."_feedburnerhost"} =  $att->{uri}; }
	
}	
	
sub _feedburner_info {
	
	my ($element,$content,$attributes) = @_;
	my $att = &process_attributes($attributes);
	my $type = $element->{type};
	
	if ($att->{uri}) { $element->{$type."_feedburnerurl"} =  $att->{uri}; }
	
}
	

sub _feedburner_origLink {
	
	my ($element,$content) = @_;
	my $type = $element->{type};
		
	# Note tha 'link' tag is superseded by feedburner:origLink
	$content = &process_url($content);	
	$element->{$type."_link"} = $content;		
	
}

	
sub _gd_extendedProperty {
	
	my ($element,$content,$attributes) = @_;
	my $att = &process_attributes($attributes);
	my $type = $element->{type};
	
	if ($att->{name} eq "OpenSocialUserId") {
		$element->{$type."_opensocialuserid"} = $att->{value};
	}  else {
		&diag(0,qq|<p class="red">Google Docs Attribute $att->{name} unknown in $element->{tag}<br/>\n|);				
	}
	
}


sub _geo_lat {
	
	my ($element,$content) = @_;
	my $type = $element->{type};

	$element->{$type."_geo_lat"} = $content;		
	
}


sub _geo_long {
	
	my ($element,$content) = @_;
	my $type = $element->{type};
		
	$element->{$type."_geo_long"} = $content;			
}


sub _georss_point {
	
	my ($element,$content) = @_;
	my $type = $element->{type};
		
	$element->{$type."_geo"} = "point:".$content;			
}

	
sub _generator {
	
	my ($element,$content,$attributes) = @_;
	my $att = &process_attributes($attributes);
	my $type = $element->{type};
	
	if ($att->{version}) { $element->{$type."_genver"} = $att->{version}; }
	if ($att->{url}) { $element->{$type."_genurl"} = $att->{url}; }
	if ($content) { $element->{$type."_genname"} = $content; }
	
}


sub _guid {
	
	my ($element,$content) = @_;
	my $type = $element->{type};
		
	$element->{$type."_guid"} = $content;			
}

	
sub _height {				# Typically used with the 'image' media object
	
	my ($element,$content) = @_;
	my $type = $element->{type};
		
	$element->{$type."_height"} = $content;			
}


sub _icon {
	
	my ($element,$content) = @_;
	my $type = $element->{type};
		
	$element->{$type."_imgURL"} = $content;			
}


sub _id {
	
	my ($element,$content) = @_;
	my $type = $element->{type};
		
	$element->{$type."_blogID"} = $content;		# For feeds
	$element->{$type."_guid"} = $content;		# The rest
		
}


sub _issued {
	
	my ($element,$content) = @_;
	my $type = $element->{type};
		
	$element->{$type."_issued"} = $content;			
}


sub _itunes_author {
	
	my ($element,$content) = @_;

	my $type = $element->{type};
	
							# Initialize Author Object, as appropriate
	my $author = gRSShopper::Record->new;     	# Set values  
	$author->{type} = "author";                        
	$author->{author_name} = $content;
	push @{$element->{authors}},$author;
	
}


sub _itunes_block {
	
	my ($element,$content) = @_;
	my $type = $element->{type};
	
	$element->{$type."_itunesblock"} = $content;	
}


sub _itunes_category {

	my ($element,$content,$attributes) = @_;
	my $type = $element->{type};
	
	if ($attributes) {
		my $att = process_attributes($attributes);      				
		$content .= $att->{term};
		if ($att->{scheme}) { $content = $att->{scheme} . ":" . $content; }
	}
	$element->{$type."_category"} = &append_to_list($element->{$type."_category"},$content);	

}


sub _itunes_duration {
	
	my ($element,$content) = @_;
	my $type = $element->{type};
	
	$element->{$type."_duration"} = $content;	
}


sub _itunes_email {		# Typically applies to itunes:owner author object
	
	my ($element,$content) = @_;
	my $type = $element->{type};
	
	$element->{$type."_email"} = $content;	
}


sub _itunes_explicit {
	
	my ($element,$content) = @_;
	my $type = $element->{type};
	
	$element->{$type."_explicit"} = $content;	
}


sub _itunes_image {
	
	my ($element,$content,$attributes) = @_;
	my $att = &process_attributes($attributes);
	my $type = $element->{type};
	
	if ($att->{href}) { unless ($element->{$type."_imgURL"}) { $element->{$type."_imgURL"} =  $att->{href}; }  }
	if ($content) { unless ($element->{$type."_imgURL"}) { $element->{$type."_imgURL"} =  $content; }  }	
	
}


sub _itunes_keywords {

	my ($element,$content) = @_;
	my $type = $element->{type};
	
	$content =~ s/,\s*/;/g;			# gRSShopper uses ; to delimit list items
	$element->{$type."_topic"} = &append_to_list($element->{$type."_topic"},$content);	
}




sub _itunes_name {		# Typically applies to itunes:owner author object
	
	my ($element,$content) = @_;
	my $type = $element->{type};
	
	$element->{$type."_name"} = $content;	
}


sub _itunes_subtitle {
	
	my ($element,$content) = @_;
	my $type = $element->{type};
		
	$element->{$type."_subtitle"} = $content;		
}


sub _itunes_summary {
	
	my ($element,$content) = @_;
	my $type = $element->{type};
		
	$element->{$type."_description"} ||= $content;	
}

	
sub _language {
	
	my ($element,$content) = @_;
	my $type = $element->{type};
		
	$element->{$type."_language"} = $content;		
	
}


sub _lastBuildDate {
	
	my ($element,$content) = @_;
	my $type = $element->{type};
		
	$element->{$type."_updated"} = $content;		
	
}
		
sub _link {
	
	my ($element,$content,$attributes) = @_;
	
	&diag(5,"LINK: $element->{type},$content,$attributes <br>\n");
	
	my $type = $element->{type};
	$content = &process_url($content);
	
	if ($attributes) {
		my $att = process_attributes($attributes);

		
		if ($att->{rel} =~ /^self$/i) { 
			$element->{$type."_link"} ||= $att->{href}; 
		} 
		
		elsif ($att->{rel} =~ /^alternate$/i) {  
			$element->{$type."_link"} = $att->{href};      # Will supersede rel=self
			
		}

		elsif  ($att->{rel} =~ /^replies$/i) {
			$element->{$type."_comments"} = $att->{href};
			
		}
		
		elsif ($att->{rel} =~ /^hub$/i) { 
	
			$element->{$type."_hub"} = $att->{href};
			
				
		} 
		
		elsif ($att->{rel} =~ /^enclosure$/i) {		# enclosure in Atom
			
									# Initialize Media Object, as appropriate
			my $media = gRSShopper::Record->new;     	# Set values  
			$media->{type} = "media";                        
			$media->{media_url} = $att->{href};
			$media->{media_size} = $att->{length};
			$media->{media_mimetype} = $att->{type};
			my @mtitlearr = split "/",$att->{href};
			$media->{media_title} = pop @mtitlearr;
			$media->{type} = "media";
			
			push @{$element->{media}},$media;
			

			
		} elsif ($att->{type} =~ "image") {					# Twitter Images
			$element->{$type."_thumbnail"} = $att->{href};
			
		} elsif ($att->{href}) {						# PHPBB style links
		
			$element->{$type."_link"} ||= $att->{href};
		} else {
			
			&diag(0,qq|<p class="red">Exception, not sure what to do with atom10:link rel = $att->{rel} <br>\n </p>|);
	
		}
		
		
	} else {  # Note tha 'link' tag is superseded by feedburner:origLink
		  # Also, we don't want to replace original link in feed->{feed_link}
		unless ($type eq "feed") { $element->{$type."_link"} ||= $content; }		
		
	}
	
	
}


sub _logo {
	
	my ($element,$content) = @_;
	my $type = $element->{type};
		
	$element->{$type."_imgURL"} = $content;		
	
}


sub _managingEditor {					# Should eventually become a type of author
	
	my ($element,$content) = @_;
	my $type = $element->{type};
		
	$element->{$type."_managingEditor"} = $content;		
	
}




sub _media_category {

	my ($element,$content,$attributes) = @_;
	my $type = $element->{type};
	
	if ($attributes) {
		my $att = process_attributes($attributes);      				
		$content .= $att->{term};
		if ($att->{scheme}) { $content = $att->{scheme} . ":" . $content; }
	}
	$element->{$type."_category"} = &append_to_list($element->{$type."_category"},$content);	

	# gRSShopper does not support the optional 'lable' attributed defined
	# in the spec at http://www.rssboard.org/media-rss#media-category

}


sub _media_copyright {
	
	my ($element,$content,$attributes) = @_;
	my $type = $element->{type};
		
	my $att = process_attributes($attributes);      		
	if ($att->{url}) { $content .= ";".$att->{url}; }		
	$element->{$type."_copyright"} = $content;		
	
}


sub _media_credit {

	my ($element,$content,$attributes) = @_;
	my $type = $element->{type};			# Probably 'media' but we're stick to the format
	
	if ($attributes) {
		my $att = process_attributes($attributes);      				
		if ($att->{role}) { $content = $att->{role} . ":" . $content; }
	}
	$element->{$type."_credits"} = &append_to_list($element->{$type."_credits"},$content);
	
}


sub _media_description {

	my ($element,$content,$attributes) = @_;
	my $type = $element->{type};
	
	if ($attributes) {
		my $att = process_attributes($attributes);    
		if ($att->{type} eq "html") { $content = decode_entities($content); }  	# uses HTML::Entities			
	}
	
	$element->{$type."_description"} ||= $content;

}


sub _media_hash {

	my ($element,$content,$attributes) = @_;
	my $type = $element->{type};			# Probably 'media' but we're stick to the format
	
	if ($attributes) {
		my $att = process_attributes($attributes);      				
		if ($att->{algo}) { $content = $att->{algo} . ":" . $content; }
	}
	$element->{$type."_hash"} = $content;
	
}


sub _media_keywords {

	my ($element,$content) = @_;
	my $type = $element->{type};
	
	$content =~ s/,\s*/;/g;			# gRSShopper uses ; to delimit list items
	$element->{$type."_topic"} = &append_to_list($element->{$type."_topic"},$content);	
}


sub _media_player {

	my ($element,$content,$attributes) = @_;
	my $type = $element->{type};			# Probably 'media' but we're stick to the format
	
	
	if ($attributes) {
		my $att = process_attributes($attributes);      				
		
		$element->{$type."_plurl"} = $att->{url};
		$element->{$type."_plheight"} = $att->{height};
		$element->{$type."_plwidth"} = $att->{width};
		$element->{$type."_player"} = $att->{url} .";".$att->{width}.";".$att->{height};	
	}	
}


sub _media_rating {

	my ($element,$content,$attributes) = @_;
	my $type = $element->{type};
	
	if ($attributes) {
		my $att = process_attributes($attributes);      				
		$content .= $att->{term};
		if ($att->{scheme}) { $content = $att->{scheme} . ":" . $content; }
	}
	$element->{$type."_rating"} = &append_to_list($element->{$type."_rating"},$content);	

}


sub _media_text {

	my ($element,$content,$attributes) = @_;
	my $type = $element->{type};
	
	if ($attributes) {
		my $att = process_attributes($attributes);    
		if ($att->{type} eq "html") { $content = decode_entities($content); }  	# uses HTML::Entities	
		my $start = "start:".$att->{start};
		my $end = "end:".$att->{end};
		$content = "<p>($start;$end) $content</p>";		
	}
	
	$element->{$type."_content"} ||= $content;
	
	# gRSShopper does not support separate text entries, as per the specification at
	# http://www.rssboard.org/media-rss#media-text
	# but it does collect all relevant data and places it into the 'content' element
	# in an easy-to-parse format

}

sub _media_thumbnail {

	my ($element,$content,$attributes) = @_;
	my $type = $element->{type};			# Probably 'media' but we're stick to the format
	
	# gRSShopper supports only one thumbnail, not a whole series as defined in the
	# specification at http://www.rssboard.org/media-rss#media-thumbnails
	# As per that spec, the first thumbnail is taken to be the most important
	
	if ($attributes) {
		my $att = process_attributes($attributes);      				
		
		$element->{$type."_thurl"} ||= $att->{url};
		$element->{$type."_thheight"} ||= $att->{height};
		$element->{$type."_thwidth"} ||= $att->{width};
	}	
}			


sub _media_title {

	my ($element,$content,$attributes) = @_;
	my $type = $element->{type};
	
	if ($attributes) {
		my $att = process_attributes($attributes);    
		if ($att->{type} eq "html") { $content = decode_entities($content); }  	# uses HTML::Entities			
	}
	
	$element->{$type."_title"} ||= $content;

}


sub _modified {
	
	my ($element,$content) = @_;
	my $type = $element->{type};
		
	$element->{$type."_updated"} = $content;			
}


sub _name {		# Typically applies to  author object
	
	my ($element,$content) = @_;
	my $type = $element->{type};
	
	$element->{$type."_name"} = $content;	
}


sub _openSearch_totalResults {
	
	my ($element,$content) = @_;
	my $type = $element->{type};
		
	$element->{$type."_OStotalResults"} = $content;		
}

sub _openSearch_startIndex {
	
	my ($element,$content) = @_;
	my $type = $element->{type};
		
	$element->{$type."_OSstartIndex"} = $content;		
}

sub _openSearch_itemsPerPage {
	
	my ($element,$content) = @_;
	my $type = $element->{type};
		
	$element->{$type."_OSitemsPerPag"} = $content;		
}
	
	
sub _pingback_server {
	
	my ($element,$content) = @_;
	my $type = $element->{type};	
	
	$element->{$type."_pingserver"} = $content;		
}
	
	
sub _pingback_target {
	
	my ($element,$content) = @_;
	my $type = $element->{type};	
	
	$element->{$type."_pingtarget"} = $content;		
}
	
	
sub _pubDate {
	
	my ($element,$content) = @_;
	my $type = $element->{type};
		
	$element->{$type."_issued"} = $content;			
}


sub _published {
	
	my ($element,$content) = @_;
	my $type = $element->{type};
		
	$element->{$type."_issued"} = $content;			
}	
			

sub _rights {
	
	my ($element,$content,$attributes) = @_;
	my $type = $element->{type};
		
	my $att = process_attributes($attributes);      		
	if ($att->{url}) { $content .= ";".$att->{url}; }		
	$element->{$type."_copyright"} = $content;		
	
}


sub _subtitle {
	
	my ($element,$content) = @_;
	my $type = $element->{type};
		
	$element->{$type."_subtitle"} = $content;		
}


sub _summary {
	
	my ($element,$content) = @_;
	my $type = $element->{type};
		
	$element->{$type."_description"} ||= $content;	
}


sub _sy_updatePeriod {
	
	my ($element,$content) = @_;
	my $type = $element->{type};
		
	$element->{$type."_updatePeriod"} ||= $content;	
}


sub _sy_updateFrequency {
	
	my ($element,$content) = @_;
	my $type = $element->{type};
		
	$element->{$type."_updateFrequency"} ||= $content;	
}


sub _sy_updateBase {
	
	my ($element,$content) = @_;
	my $type = $element->{type};
		
	$element->{$type."_updateBase"} ||= $content;	
}
	

sub _tagline {
	
	my ($element,$content) = @_;
	my $type = $element->{type};
		
	$element->{$type."_subtitle"} = $content;		
}


sub _slash_comments {
	
	# Obviously a very partial represendation of the slash extension

	
	my ($element,$content) = @_;
	my $type = $element->{type};
		
	$element->{$type."_comments"} = $content;		
}


sub _slash_department {
	
	# Obviously a very partial represendation of the slash extension

	
	my ($element,$content) = @_;
	my $type = $element->{type};
		
	$element->{$type."_department"} = $content;		
}


sub _slash_hit_parade {
	
	# Obviously a very partial represendation of the slash extension

	
	my ($element,$content) = @_;
	my $type = $element->{type};
		
	$element->{$type."_hit_parade"} = $content;		
}


sub _slash_section {
	
	# Obviously a very partial represendation of the slash extension

	
	my ($element,$content) = @_;
	my $type = $element->{type};
		
	$element->{$type."_section"} = $content;		
}

sub _thr_commments {
	
	# Obviously a very partial represendation of the thr extension
	# TODO fix threading per http://www.niallkennedy.com/blog/2006/09/feed-threads-comments.html
	# and http://purl.org/syndication/thread/1.0
	
	my ($element,$content) = @_;
	my $type = $element->{type};
		
	$element->{$type."_commentURL"} = $content;		
}


sub _thr_totals {
	
	my ($element,$content) = @_;
	my $type = $element->{type};
		
	$element->{$type."_comments"} = $content;		
}


sub _title {
	
	my ($element,$content) = @_;
	my $type = $element->{type};
		
	$element->{$type."_title"} = $content;		
}


sub _trackback_ping {
	
	my ($element,$content) = @_;
	my $type = $element->{type};
		
	$element->{$type."_pingtrackback"} = $content;		
}


sub _ttl {
	
	my ($element,$content) = @_;
	my $type = $element->{type};
		
	$element->{$type."_ttl"} = $content;		
}


sub _updated {
	
	my ($element,$content) = @_;
	my $type = $element->{type};
		
	$element->{$type."_updated"} = $content;			
}


sub _uri {		# Typically applies to  author object
	
	my ($element,$content) = @_;
	my $type = $element->{type};
	
	if ($type eq "author" || $type eq "link") {
		$element->{$type."_link"} = $content;	
	} else {
		$element->{$type."_url"} = $content;
	}
}

	
sub _url {				# Typically used with the 'image' media object
	
	my ($element,$content) = @_;
	my $type = $element->{type};
		
	$content = &process_url($content);		
	$element->{$type."_url"} = $content;			
}


sub _wfw_comment {
	
	my ($element,$content) = @_;
	my $type = $element->{type};
		
	$element->{$type."_commentURL"} = $content;			
}


sub _wfw_comments {
	
	my ($element,$content) = @_;
	my $type = $element->{type};
		
	$element->{$type."_comments"} = $content;			
}


sub _wfw_commentRSS {
	
	my ($element,$content) = @_;
	my $type = $element->{type};
		
	$element->{$type."_commentRSS"} = $content;			
}


sub _webMaster {					# Should eventually become a type of author
	
	my ($element,$content) = @_;
	my $type = $element->{type};
		
	$element->{$type."_webMaster"} = $content;		
}

	
sub _width {				# Typically used with the 'image' media object
	
	my ($element,$content) = @_;
	my $type = $element->{type};
		
	$element->{$type."_width"} = $content;			
}

