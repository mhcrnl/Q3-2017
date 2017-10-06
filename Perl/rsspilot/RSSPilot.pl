#!/usr/local/bin/perl
##############################################################################
# Author: Binny V Abraham                                                    #
# Website: http://www.geocities.com/binnyva                                  #
# E-Mail : binnyva@hotmail.com                                               #
# Get more Perl scripts from http://www.geocities.com/binnyva/code/perl      #
##############################################################################
# Name    : RSSPilot                                                         #
# Version : 1.00.A Beta                                                      #
# Date    : January 20, 2005 - February 12, 2005                             #
# 	RSSPilot is a software that can be used to create RSS feeds for your     # 
# website. Can also be used to read RSS feeds.                               #
#                                                                            #
# Get more Perl scripts from http://www.geocities.com/binnyva/code/perl      #
##############################################################################

#Modules
# use warnings; #DEBUG - Remove this.
use strict;
use Tk;
use Tk::Balloon;
use XML::Simple;

############################ 'Global' Variables ############################
#Program Information
my %program = (
	name	=>	"RSSPilot",
	author	=>	"Binny V Abraham",
	version	=>	"1.00.A Beta",
	email	=>	"binnyva\@hotmail.com",
	website	=>	'http://www.geocites.com/binnyva',
	web_page=>	'http://www.geocites.com/binnyva/code/perl/tk/rsspilot/'
);

#Program Configuration.
my %script = (
	file		=>	"",	#RSS File
	item_index	=> 	-1, #Starts at 0
	item_count	=>	0,	#Total number of items
	modified	=>	0	#Becomes non-zero if any modifications are made. To make sure that file is save
);

#Options
my %opt = (
	opt_file		=> ".rsspilot",
	save_changes 	=> 1,	#What to do if a value is changed: 0 - Don't save | 1 - Ask | 2 = Save
	site_folder		=> '',
	site_url		=> '',
	fixed_font		=> 'courier',
	save_html		=> '',
	xml_url			=> '',
	editor			=> 'notepad',
	max_help_length	=> 45
);

#Get Position of options file
my $slash_pos = rindex($0,"\\"); # Find the postion of the last '/' in the Script path
my $len = length($0); # Get length of URL
my $script_folder = substr($0,0,$slash_pos); # Get the folder of script path
$opt{'opt_file'} = $script_folder . '\\' . $opt{'opt_file'};

#This will be in the form of '[file],[title],[file],[title]' - in Key/Value format. I can't used Hashs 
#	because space may come inside files or titles.
#Recent Feeds
my $recent_limit = 5;
my @recent_feeds;
#Favorite Feeds
my $favorite_limit = 10;
my @favorite_feeds;

my $xml = "";
my $xs = new XML::Simple(forcearray => 1, keeproot => 1);
my $last_file = "";
#Some global widgets
my $top_saa_txt;
my $top_saa;

############################### GUI Building #################################
# Main Window
my $mw = new MainWindow;

my $lbl_heading = $mw -> Label(-text=>"$program{'name'} v$program{'version'}", -font=>"ansi 12 bold") -> pack();
my $frm_top_buttons = $mw -> Frame();
my $but_previous = $frm_top_buttons -> Button(-text=>"<< Previous Item",-command=> sub { &viewItem('p'); })
		-> pack(-side=>"left",-anchor=>"w");
my $but_all      = $frm_top_buttons -> Button(-text=>"Show All Items",-command=>\&showAll)
		-> pack(-side=>"left",-padx=>5);
my $but_next     = $frm_top_buttons -> Button(-text=>"Next Item >>",-command=> sub { &viewItem('n'); }) 
		-> pack(-side=>"right",-anchor=>"e");
$frm_top_buttons -> pack;

#Item Details Area
my $frm_DA = $mw -> Frame(-bd=>1,-relief=>"raised");
my $lbl_title= $frm_DA -> Label(-text=>"Title") -> grid(-column=>0,-row=>0,-sticky=>"w");
my $ent_title= $frm_DA -> Entry() -> grid(-column=>1,-row=>0,-sticky=>"w");
my $lbl_url  = $frm_DA -> Label(-text=>"URL") -> grid(-column=>0,-row=>1,-sticky=>"w");
my $ent_url  = $frm_DA -> Entry(-width=>50) -> grid(-column=>1,-row=>1,-sticky=>"w");
my $lbl_desc = $frm_DA -> Label(-text=>"Description") -> grid(-column=>0,-row=>2,-sticky=>"nw");
my $stxt_desc= $frm_DA -> Scrolled('Text',-scrollbars=>'e',-width=>41,-height=>6) 
		-> grid(-column=>1,-row=>2,-sticky=>"nsew",-pady=>5);
my $lbl_date = $frm_DA -> Label(-text=>"Date") -> grid(-column=>0, -row=>3,-sticky=>"w");
my $ent_date = $frm_DA -> Entry(-width=>50) -> grid(-column=>1, -row=>3);
# my $but_date = $frm_DA -> Button(-text=>"Get Date",-command=>\&getDate) -> grid(-column=>0, -row=>4);
my $but_cur_date = $frm_DA -> Button(-text=>"Current Time",-command=>\&insertCurrentDate)
	-> grid(-column=>1, -row=>4,-sticky=>"w");

my $is_perm_link = 'false';
my $lbl_guid = $frm_DA -> Label(-text=>"GUID") -> grid(-column=>0, -row=>5, -sticky=>"w");
my $ent_guid = $frm_DA -> Entry(-width=>50) -> grid(-column=>1, -row=>5, -sticky=>"w");
my $lbl_ispermlink = $frm_DA -> Label(-text=>"isPermLink") -> grid(-column=>0, -row=>6, -sticky=>"w");
my $chk_ispermlink = $frm_DA -> Checkbutton(-variable=>\$is_perm_link,-offvalue=>'false',-onvalue=>'true')
		-> grid(-column=>1, -row=>6, -sticky=>"w");

my $if_blank = 'blank';
my $frm_blank = $frm_DA -> Frame();
my $lbl_blank = $frm_blank -> Label(-text=>"If GUID is blank") -> pack(side=>'left');
my $rdb_blank_create = $frm_blank -> Radiobutton(-text=>"Create",-variable=>\$if_blank,-value=>'create')
		-> pack(side=>'left');
my $rdb_blank_blank = $frm_blank -> Radiobutton(-text=>"Leave Blank",-variable=>\$if_blank,-value=>'blank')
		-> pack(side=>'left');
my $rdb_blank_url = $frm_blank -> Radiobutton(-text=>"Set to Link",-variable=>\$if_blank,-value=>'link')
		-> pack(side=>'left');
$frm_blank -> grid(-column=>0, -row=>7,-columnspan=>2,-sticky=>"w");

my $but_add = $frm_DA -> Button(-text=>"Set Item",-command=>\&setItem)->grid(-column=>0,-row=>8,-sticky=>"w",-pady=>10);
my $but_clear=$frm_DA -> Button(-text=>"Remove Item",-command=>\&removeItem) -> grid(-column=>1, -row=>8,-sticky=>"e");

my $but_insert = $frm_DA -> Button(-text=>"New Item",-command=>\&newItem) -> grid(-column=>0, -row=>9,-sticky=>"w");

$frm_DA -> pack(qw/-anchor w -padx 5 -pady 5 -ipadx 5 -ipady 5 -fill both -expand 1/);

my $frm_buttons = $mw -> Frame();
my $but_html = $frm_buttons -> Button(-text=>"Read HTML File",-command=>\&readHtml) -> pack(-side=>"left");
my $but_options = $frm_buttons -> Button(-text=>"Preferences",-command=>\&options) -> pack(-side=>"left",-padx=>15);
my $but_about = $frm_buttons -> Button(-text=>"About", -command=>\&about) -> pack(-side=>"right");
$frm_buttons -> pack(qw/-fill x/);

my $but_publish = $mw -> Button(-text=>" Publish RSS ",-command=>\&publish) -> pack(qw/-pady 15/);

my $frm_rss_file = $mw -> Frame();
my $lbl_rss_file = $frm_rss_file -> Label(-text=>"RSS File") -> pack(-side=>"left");
my $ent_rss_file = $frm_rss_file -> Entry() -> pack(-side=>"left",-expand=>1,-fill=>'x');
my $but_rss_file = $frm_rss_file -> Button(-text=>'Browse...',-command=>\&getFile) -> pack(-side=>"right");
$frm_rss_file -> pack(-side=>"left",-expand=>1,-fill=>'x');

### Help Messages
my $b = $mw->Balloon(-initwait=>1000,-state=>'balloon',-balloonposition=>'mouse');
$b->attach($ent_title,	-msg=>"The title of the item."); #Title Entry
$b->attach($ent_url,	-msg=>&wrapper("The URL of the item. Provide this only if there is a location on the web where the user can know more about this item.")); #Link Entry
$b->attach($stxt_desc,	-msg=>&wrapper("The text of the item, or a summary. One can use HTML code in the description.")); #Description
$b->attach($ent_date,	-msg=>&wrapper("The date/time when the item was published. You can insert the current time by pressing the 'Current Time' button. The format must be: \"Day, monthday Month year hour:min:sec GMT\",(e.g., Sat, 01 Jan 20053 01:01:00 GMT) ")); #Date Entry
$b->attach($but_cur_date,-msg=>&wrapper("Insert the current time in the correct format into the date field.")); #Get Time Button
$b->attach($ent_guid,	-msg=>&wrapper("A string that uniquely identifies the item. If \"isPermLink\" is checked, then readers can assume that the GUID value is a URL that is a permanent link to the item. If the GUID text box is left blank you can have a GUID automatically assigned based upon the current date/time or have the current value of the Link field copied using the radio buttons. (Optional)")); #GUID Entry
$b->attach($but_add,	-msg=>&wrapper("Save the changes made to the current item.")); #Set Item Button
$b->attach($but_clear,	-msg=>&wrapper("Delete currently selected item.")); #Remove Item Button
$b->attach($but_insert,	-msg=>&wrapper("Create a new Item at the beginning of the channel.")); # New Item Button
$b->attach($but_html,	-msg=>&wrapper("Creates a new item with the description of a HTML file of your choice.")); # Read HTML file Button
$b->attach($but_publish,-msg=>&wrapper("Saves the RSS file if any changes were made.")); # Publish Button
$b->attach($but_previous,-msg=>&wrapper("Show the previous item of this feed.")); # Next Button
$b->attach($but_next,	-msg=>&wrapper("Show the next item of the current channel.")); # Previous Button
$b->attach($but_all,	-msg=>&wrapper("Show all the items in a single view - for easy re-organization. You can move the items up or down, delete items etc.")); # Show All Button
$b->attach($ent_rss_file,-msg=>&wrapper("The current RSS feed's file is shown here.")); #RSS File Entry
$b->attach($but_rss_file,-msg=>&wrapper("Choose a new RSS feed.")); # Button

# $b->attach($but_,-msg=>&wrapper("")); # Button

### Accelarators
$mw -> bind('<Key-Escape>', sub { &exiter; });
$mw -> bind('<Control-Key-n>', sub { &newFeed; });
$mw -> bind('<Control-Key-o>', sub { &getFile; });
$mw -> bind('<Control-Key-s>', sub { &publish; });
$mw -> bind('<Control-Key-S>', sub { &saveAs; });
$mw -> bind('<Control-Key-i>', sub { &feedInfo; });
$mw -> bind('<Control-Key-A>', sub { &showAll; });
$mw -> bind('<Control-Key-N>', sub { &newItem; });
$mw -> bind('<Control-Key-p>', sub { &options; });
$mw -> bind('<Control-Key-e>', sub { &editor; });
$mw -> bind('<Key-F6>', sub { &viewItem('p');; });
$mw -> bind('<Key-F7>', sub { &viewItem('n');; });
$mw -> bind('<Key-F1>', sub { &about; });

$mw -> resizable(0,0);
$mw -> wm('protocol','WM_DELETE_WINDOW', sub { &exiter; });
$mw -> wm('title',"$program{'name'} v$program{'version'}");

#Initialize the program
init();

### Menu
my $mbar = $mw -> Menu();
my $menu_font = "ansi";

#The Main Buttons
my $mnu_file = $mbar -> cascade(-label =>"File", -underline=>0, -tearoff => 0);
my $mnu_edit = $mbar -> cascade(-label =>"Edit", -underline=>0, -tearoff => 0);
my $mnu_help = $mbar -> cascade(-label =>"Help", -underline=>0, -tearoff => 0);

#File Menu
$mnu_file -> command(-label => "~New Feed", -font=>$menu_font, -command=>\&newFeed, -accelerator=>"Ctrl+N");
$mnu_file -> command(-label => "~Open Feed", -font=>$menu_font, -command=>\&getFile, -accelerator=>"Ctrl+O");
$mnu_file -> command(-label => "~Save/Publish", -font=>$menu_font, -command=>\&publish, -accelerator=>"Ctrl+S");
$mnu_file -> command(-label => "Save ~As", -font=>$menu_font, -command=>\&saveAs, -accelerator=>"Ctrl+Shift+S");
$mnu_file -> separator;
my $mnu_export = $mnu_file -> cascade(-label => "~Export", -tearoff => 0, -font=>$menu_font);
	$mnu_export -> command(-label => "~RSS Feed", -font=>$menu_font, -command=>\&saveAs);
	$mnu_export -> command(-label => "~HTML File", -font=>$menu_font, -command=> sub { &publishHTML; });
my $mnu_import = $mnu_file -> cascade(-label => "~Import", -tearoff => 0, -font=>$menu_font);
	$mnu_import -> command(-label => "~HTML File", -font=>$menu_font, -command=>\&readHtml);
$mnu_file -> separator;

#Recent Feeds
my $mnu_recent = $mnu_file -> cascade(-label => "~Recent Feeds", -tearoff => 0, -font=>$menu_font);
my @unchanging_recents = @recent_feeds; #I used another list varaible because, everytime the readXml function is called, the @recent_feeds will change.
#Can't put this in a for loop - only the last one will be acessable.
$mnu_recent -> command(-label => "$unchanging_recents[1]", -font=>$menu_font, -command=> sub {
		$script{'file'} = "$unchanging_recents[0]"; &readXml;
	}) if ($unchanging_recents[0]);
$mnu_recent -> command(-label => "$unchanging_recents[3]", -font=>$menu_font, -command=> sub {
		$script{'file'} = $unchanging_recents[2]; &readXml;
	}) if ($unchanging_recents[2]);
$mnu_recent -> command(-label => "$unchanging_recents[5]", -font=>$menu_font, -command=> sub {
		$script{'file'} = $unchanging_recents[4]; &readXml;
	}) if ($unchanging_recents[4]);
$mnu_recent -> command(-label => "$unchanging_recents[7]", -font=>$menu_font, -command=> sub {
		$script{'file'} = $unchanging_recents[6]; &readXml;
	}) if ($unchanging_recents[6]);
$mnu_recent -> command(-label => "$unchanging_recents[9]", -font=>$menu_font, -command=> sub {
		$script{'file'} = $unchanging_recents[8]; &readXml;
	}) if ($unchanging_recents[8]);

#Favorates Feeds
my $mnu_fav = $mnu_file -> cascade(-label => "~Favorate Feeds", -tearoff => 0, -font=>$menu_font);
my @unchanging_favorites = @favorite_feeds; #I used another list varaible because, everytime a new Favorite is added, @favorite_feed will be modified
#Can't put this in a for loop - only the last one will be acessable.
$mnu_fav -> command(-label => "Add Current Feed", -font=>$menu_font, -command=>\&addFav);
$mnu_fav -> separator;
$mnu_fav -> command(-label => "$unchanging_favorites[1]", -font=>$menu_font, -command=> sub {
		$script{'file'} = $unchanging_favorites[0]; &readXml;
	}) if ($unchanging_favorites[0]);
$mnu_fav -> command(-label => "$unchanging_favorites[3]", -font=>$menu_font, -command=> sub {
		$script{'file'} = $unchanging_favorites[2];	&readXml;
	}) if ($unchanging_favorites[2]);
$mnu_fav -> command(-label => "$unchanging_favorites[5]", -font=>$menu_font, -command=> sub {
		$script{'file'} = $unchanging_favorites[4];	&readXml;
	}) if ($unchanging_favorites[4]);
$mnu_fav -> command(-label => "$unchanging_favorites[7]", -font=>$menu_font, -command=> sub {
		$script{'file'} = $unchanging_favorites[6];	&readXml;
	}) if ($unchanging_favorites[6]);
$mnu_fav -> command(-label => "$unchanging_favorites[9]", -font=>$menu_font, -command=> sub {
		$script{'file'} = $unchanging_favorites[8];	&readXml;
	}) if ($unchanging_favorites[8]);
$mnu_fav -> command(-label => "$unchanging_favorites[11]", -font=>$menu_font, -command=> sub {
		$script{'file'} = $unchanging_favorites[10]; &readXml;
	}) if ($unchanging_favorites[10]);
$mnu_fav -> command(-label => "$unchanging_favorites[13]", -font=>$menu_font, -command=> sub {
		$script{'file'} = $unchanging_favorites[12]; &readXml;
	}) if ($unchanging_favorites[12]);
$mnu_fav -> command(-label => "$unchanging_favorites[15]", -font=>$menu_font, -command=> sub {
		$script{'file'} = $unchanging_favorites[14]; &readXml;
	}) if ($unchanging_favorites[14]);
$mnu_fav -> command(-label => "$unchanging_favorites[17]", -font=>$menu_font, -command=> sub {
		$script{'file'} = $unchanging_favorites[16]; &readXml;
	}) if ($unchanging_favorites[16]);
$mnu_fav -> command(-label => "$unchanging_favorites[19]", -font=>$menu_font, -command=> sub {
		$script{'file'} = $unchanging_favorites[18]; &readXml;
	}) if ($unchanging_favorites[18]);

$mnu_file -> separator;
$mnu_file -> command(-label => "E~xit",-command=> sub { &exiter; }, -font=>$menu_font, -accelerator=>"Escape");

#Edit Menu
$mnu_edit -> command(-label => "~Feed Information", -font=>$menu_font, -command=>\&feedInfo, -accelerator=>"Ctrl+I");
$mnu_edit -> command(-label => "~New Item", -font=>$menu_font, -command=>\&newItem, -accelerator=>"Ctrl+Shift+N");
$mnu_edit -> command(-label => "~Delete Current Item", -font=>$menu_font, -command=>\&removeItem);
my $mnu_view = $mnu_edit -> cascade(-label => "~View", -font=>$menu_font, -tearoff=>0);
	$mnu_view -> command(-label => "Show ~Next", -font=>$menu_font, -command=>sub { &viewItem('n'); }, -accelerator=>"F6");
	$mnu_view -> command(-label => "Show ~Previous", -font=>$menu_font, -command=> sub { &viewItem('p'); }, -accelerator=>"F7");
	$mnu_view -> command(-label => "Show ~All", -font=>$menu_font, -command=>\&showAll, -accelerator=>"Ctrl+Shift+A");
$mnu_edit -> separator;
$mnu_edit -> command(-label => "Launch External ~Editor", -font=>$menu_font, -command=>\&editor, -accelerator=>"Ctrl+E");
$mnu_edit -> command(-label => "~Preferences", -font=>$menu_font, -command=>\&options, -accelerator=>"Ctrl+P");

#Help
$mnu_help -> command(-label => "~About", -font=>$menu_font, -command=>\&about, -accelerator=>"F1");

$mw ->configure(-menu => $mbar);#Set this as menu

MainLoop;

################################# Functions ####################################
#Shows a warning message box that no XML feed is set.
sub noFile {
	$mw->messageBox(-message=>"XML feed is not defined. Please create a new feed by choosing File->New or open an existing feed.");
}

#Get the XML file
sub getFile {
	my ($widget) = $ent_rss_file;
	my $types = [
    	['Feed Files', ['.xml', '.rss']],
    	['All Files',  '*']
	];
	
	my $folder = $opt{'site_folder'};
	my $last_file = $script{'file'};
	$folder =~ s/\//\\/g; #Convert all '/' to '\\'. Otherwise the getOpenFile function won't take it.
	$last_file =~ s/\//\\/g;
	
	my $file = $mw -> getOpenFile(-title => "Choose a Feed...",-filetypes=>$types,-initialfile=>$last_file);
	if ($file ne "") {
		$widget -> delete(0,'end');
		$widget -> insert(0,$file);
		$last_file = $script{'file'};
		$script{'file'} = $file;
		&readXml;
	}
}

#Makes the help(balloon) text to managable lengts.
sub wrapper {
	my ($txt) = @_;
	my @parts = split(" ",$txt); 
	my ($line,$l,$data) = "";
	foreach my $bit (@parts) {
		$line = "$line$bit ";
		$l = length $line;
		
		#Every line bigger than '$max_help_length' Chars will be turnicated.
		if($l < $opt{'max_help_length'}) {
			no warnings;
			$data = "$data$bit ";
		}
		else {
			$line = "$bit ";
			$data = "$data\n$bit ";
		}
	}
	return $data;
}

#Add an item to favorites and to its menu
sub addFav {
	#File not available
	unless ($script{'file'}) {
		&noFile;
		return 0;
	}
	
	my $file = $script{'file'};
	my $found = -1;
	
	#The limit is not exceed
	if ($#favorite_feeds < $favorite_limit*2) {
		#Check if file is already in the favorite list
		for(my $i=0; $i<$#favorite_feeds; $i+=2) {
			if($file eq $favorite_feeds[$i]) {
				$found = $i;
				last;
			}
		}
		#Add the file as a favorite if no such file exists in favorites.
		if ($found == -1) {
			#Put the favorites at the end of the list
			push(@favorite_feeds,$script{'file'});
			my $index = push(@favorite_feeds,$xml->{rss}[0]->{channel}[0]->{title}[0]);

			$mnu_fav -> command(-label => "$favorite_feeds[$index-1]", -font=>$menu_font, -command=> sub {
				$script{'file'} = $favorite_feeds[$index-2];
				&readXml;
			}) if ($favorite_feeds[$index-2]);
		}
	}
	else {
		$mw->messageBox(-message=>"Sorry, the maximum number of favorites have reached.");
	}
}

#Open the RSS file in an external Editor
sub editor {
	#File not available
	unless ($script{'file'}) {
		&noFile;
		return 0;
	}

	if ($opt{'editor'}) {
		if ( &checkChange != -1) {
			my $editor = $opt{'editor'};
			$editor =~ s/\//\\/g;
	
	 		unless(system($editor,$script{'file'})) {
				$mw->messageBox(-message=>"Error: Cannot run command '$opt{'editor'} $script{'file'}'.\n$?",
						-title=>"Error...",-icon=>'error');
			}
		}
	}
	else {
		$mw->messageBox(-message=>"No external editor defined. Set an Editor using 'Edit->Options->Editor'.");
	}
}

#The Save As function
sub saveAs {
	$ent_rss_file -> delete(0,'end');
	&publish;
}

############################## ShowAll Area(SAA) ##########################################
#Show all the items in a single view - for easy re-organization

#Deletes an item in the ShowAll Area
sub deleteItem {
	my ($index) = @_;
	my $title	= $xml->{rss}[0]->{channel}[0]->{item}[$index]->{title}[0];
	
	&removeItem($title);
	&display; #Refresh Display
}

#Interchange the items whose indexs are given as argument. For ex. moveFromTo(3,5) will interchange item[3] and item[5]
sub moveFromTo {
	my ($index,$to) = @_;
	my $title	= $xml->{rss}[0]->{channel}[0]->{item}[$index]->{title}[0];
	my $link 	= $xml->{rss}[0]->{channel}[0]->{item}[$index]->{link}[0];
	my $desc	= $xml->{rss}[0]->{channel}[0]->{item}[$index]->{description}[0];
	my $pubDate = $xml->{rss}[0]->{channel}[0]->{item}[$index]->{pubDate}[0];
	my $guid 	= $xml->{rss}[0]->{channel}[0]->{item}[$index]->{guid}[0]->{content};
	my $perm	= $xml->{rss}[0]->{channel}[0]->{item}[$index]->{guid}[0]->{isPermaLink};
	unless ($guid) {
		$guid 	= $xml->{rss}[0]->{channel}[0]->{item}[$index]->{guid}[0];
	}
	
	$xml->{rss}[0]->{channel}[0]->{item}[$index]->{title}[0] 		= $xml->{rss}[0]->{channel}[0]->{item}[$to]->{title}[0];
	$xml->{rss}[0]->{channel}[0]->{item}[$index]->{link}[0] 		= $xml->{rss}[0]->{channel}[0]->{item}[$to]->{link}[0];
	$xml->{rss}[0]->{channel}[0]->{item}[$index]->{description}[0]	= $xml->{rss}[0]->{channel}[0]->{item}[$to]->{description}[0];
	$xml->{rss}[0]->{channel}[0]->{item}[$index]->{pubDate}[0] 		= $xml->{rss}[0]->{channel}[0]->{item}[$to]->{pubDate}[0];
	$xml->{rss}[0]->{channel}[0]->{item}[$index]->{guid}[0]->{content}	= $xml->{rss}[0]->{channel}[0]->{item}[$to]->{guid}[0]->{content};
	unless ($xml->{rss}[0]->{channel}[0]->{item}[$to]->{guid}[0]->{content}) {
		$xml->{rss}[0]->{channel}[0]->{item}[$index]->{guid}[0]->{content} = $xml->{rss}[0]->{channel}[0]->{item}[$to]->{guid}[0];
	} else {
		$xml->{rss}[0]->{channel}[0]->{item}[$index]->{guid}[0]->{isPermaLink} = $xml->{rss}[0]->{channel}[0]->{item}[$to]->{guid}[0]->{isPermaLink};
	}

	$xml->{rss}[0]->{channel}[0]->{item}[$to]->{title}[0]		= $title;
	$xml->{rss}[0]->{channel}[0]->{item}[$to]->{link}[0]		= $link;
	$xml->{rss}[0]->{channel}[0]->{item}[$to]->{description}[0]	= $desc;
	$xml->{rss}[0]->{channel}[0]->{item}[$to]->{pubDate}[0]		= $pubDate;
	$xml->{rss}[0]->{channel}[0]->{item}[$to]->{guid}[0]->{content}		= $guid;
	$xml->{rss}[0]->{channel}[0]->{item}[$to]->{guid}[0]->{isPermaLink}	= $perm;
}

#Move Item up or down.
# $index - index of the item
# $direction - Up or down - 'u' for Up and 'd' for Down
sub move {
	my ($index,$direction) = @_;
	my $flag = 1;

	#Don't move conditions
 	$flag = 0 if ($index == 0 && $direction eq 'u');
 	$flag = 0 if ($index == $script{'item_count'} && $direction eq 'd');
 	$flag = 0 if ($index < 0 && $index < $script{'item_count'}); #Can't happen

	if ( $flag ) {
		#Determine the direction - 'u' - Up | 'd' - Down.
		my $to;
		if ($direction eq 'u') {
			$to = $index - 1;
		}
		else {
			$to = $index + 1;
		}
		
		&moveFromTo($index,$to);

		$script{'modified'}++; #Make sure that file is save
		&display; #Refresh Display
	}
}

#Close the SAA window and show the given item.
sub editItem {
	my $index = @_;
	my $top = $top_saa;

	$top -> destroy;
	$script{'item_index'} = $index;
	&viewItem($index,1);
}

#Fill the SAA with the needed data.
sub display {
	my $max_width = 30;
	my $txt = $top_saa_txt;#Get the widget ID from global variable.
	
	$txt -> delete('1.0','end');

	foreach (0..$script{'item_count'}) {
		my $i = $_;
		my $title	= $xml->{rss}[0]->{channel}[0]->{item}[$i]->{title}[0];
		my $link 	= $xml->{rss}[0]->{channel}[0]->{item}[$i]->{link}[0];
		my $desc	= $xml->{rss}[0]->{channel}[0]->{item}[$i]->{description}[0];
		
		#Make the buttons at the same line(vertically)
		my $spaceing = " ";
		if (length($title) < $max_width) {
			my $diff = $max_width - length($title);
			$spaceing x= $diff;
		}
		
		$txt -> insert('end',"$title",'bold');
		$txt -> insert('end',"$spaceing");
		$txt -> windowCreate('end', -padx => 2, -create => 
				sub { $txt -> Button(-text=>"View/Edit",-command=> sub { &editItem($i); }) });
		$txt -> windowCreate('end', -padx => 2, -create => 
				sub { $txt -> Button(-text=>"Delete",-command=> sub { &deleteItem($i) }) });
		$txt -> windowCreate('end', -padx => 2, -create => 
				sub { $txt -> Button(-text=>"Move Up   ^",-command=> sub { &move($i,'u') }) });
		$txt -> windowCreate('end', -padx => 2, -create => 
				sub { $txt -> Button(-text=>"Move Down v",-command=> sub { &move($i,'d') }) });
		$txt -> insert('end',"\n$link\n$desc\n\n");
		
		$txt -> tagConfigure('bold',-font=>"$opt{'fixed_font'} 8 bold");
	}
}

#Close the ShowAll Area(SAA)
sub saaCloser {
	my ($top) = $top_saa;
	$top -> destroy;
	&viewItem(0,1);
	$script{'item_index'} = 0;
}

#Make the ShowAll Area
sub showAll {
	#File not available
	unless ($script{'file'}) {
		&noFile;
		return 0;
	}
	
	my $top = $mw -> Toplevel();
	$top -> title("Re-Organisation Area");
# 	$top -> resizable(0,0);
	$top -> wm('protocol','WM_DELETE_WINDOW', sub { &saaCloser($top); });
	
	my $txt = $top->Scrolled('Text',-scrollbars=>"e",-font=>"$opt{'fixed_font'} 10")
			-> pack(-fill=>"both",-expand=>1);
	
	my $but_close = $top -> Button(-text=>" Close ",-command => sub { $top->destroy; } ) -> pack(-fill=>"x",-expand=>1);
	
	$top_saa_txt = $txt;#'$top_saa_txt' is a global variable - so other functions can access this widget
	$top_saa = $top; 	#	"	-	Same	-	Ditto
 	&display;
}

############################## More Dialog Functions ##########################################
#Setting Options
sub options {
	my $top_opt = $mw -> Toplevel();
	$top_opt -> title("Preferences");
	$top_opt -> resizable(0,0);

	my $site_folder = $opt{'site_folder'};
	my $site_url = $opt{'site_url'};
	my $save_html = $opt{'save_html'};
	my $xml_url = $opt{'xml_url'};
	my $editor = $opt{'editor'};
	
	my $types = [
    	['HTML Files', ['.htm', '.html']],
    	['Web Files',  ['.shtml','.php']],
    	['All Files',  '*']
	];
	my $programs = [
    	['Programs', ['.exe', '.com', '.bat']],
    	['All Files',  '*']
	];
	
	#GUI
	my $lbl_local_folder = $top_opt -> Label(-text=>"Local Website Folder") -> grid(-column=>0,-row=>1,-sticky=>'w');
	my $ent_local_folder = $top_opt -> Entry(-textvariable=>\$site_folder,-width=>40)
		-> grid(-column=>1,-sticky=>'ew',-row=>1,-columnspan=>2);
#ADD A DIRECTORY GETTING GUI COMPONENT
# 	my $but_local_folder = $top_opt -> Button(-text=>"Browse...",-command=>sub {
# 			my $ds  = $mw->DirSelect();
# 			my $dir = $ds->Show(".");
# 			$ent_local_folder -> delete(0,'end');
# 			$ent_local_folder -> insert(0,$dir);
# 		}) -> grid(-column=>3,-row=>1);

	my $lbl_url = $top_opt -> Label(-text=>"Website URL") -> grid(-column=>0,-row=>2,-sticky=>'w');
	my $ent_url = $top_opt -> Entry(-textvariable=>\$site_url) -> grid(-column=>1,-sticky=>'ew',-columnspan=>2,-row=>2);

	my $lbl_html_file = $top_opt -> Label(-text=>"HTML File Name") -> grid(-column=>0,-row=>3,-sticky=>'w');
	my $ent_html_file = $top_opt -> Entry(-textvariable=>\$save_html) -> grid(-column=>1,-row=>3,-sticky=>'ew');
	my $but_html_file = $top_opt -> Button(-text=>"Browse...",-command=>sub {
			my $file = $mw -> getOpenFile(-title => "Choose a file...",-filetypes=>$types,-initialfile=>$save_html);
			if ($file ne "") {
				$ent_html_file -> delete(0,'end');
				$ent_html_file -> insert(0,$file);
			}
		}) -> grid(-column=>3,-row=>3);

	my $lbl_rss_url = $top_opt -> Label(-text=>"RSS Feed's URL") -> grid(-column=>0,-row=>4,-sticky=>'w');
	my $ent_rss_url = $top_opt -> Entry(-textvariable=>\$xml_url) -> grid(-column=>1,-sticky=>'ew',-columnspan=>2,-row=>4);
	
	my $lbl_editor = $top_opt -> Label(-text=>"External Editor") -> grid(-column=>0,-row=>5,-sticky=>'w');
	my $ent_editor = $top_opt -> Entry(-textvariable=>\$editor) -> grid(-column=>1,-sticky=>'ew',-row=>5);
	my $but_editor = $top_opt -> Button(-text=>"Browse...",-command=>sub {
			my $file = $mw -> getOpenFile(-title => "Choose a Program...",-filetypes=>$programs);
			if ($file ne "") {
				$ent_editor -> delete(0,'end');
				$ent_editor -> insert(0,$file);
			}
		}) -> grid(-column=>3,-row=>5);

	my $but_ok = $top_opt -> Button(-text=>"   OK   ",-command=>sub {
			$opt{'site_folder'} = $site_folder;
			$opt{'site_url'} = $site_url;
			$opt{'save_html'} = $save_html;
			$opt{'xml_url'} = $xml_url;
			$opt{'editor'} = $editor;
			$top_opt->destroy;
		}) -> grid(-column=>0,-sticky=>'w',-row=>6);
	my $but_cancel = $top_opt -> Button(-text=>"Cancel",-command=>sub { $top_opt->destroy; }) 
		-> grid(-column=>3,-sticky=>'e',-row=>6);
}

#Open a Dialog showing the detials about the current feed
sub feedInfo {
	#File not available
	unless ($script{'file'}) {
		&noFile;
		return 0;
	}
	
	my $title = $xml->{rss}[0]->{channel}[0]->{title}[0];
	my $url = $xml->{rss}[0]->{channel}[0]->{link}[0];
	my $desc = $xml->{rss}[0]->{channel}[0]->{description}[0];

	my $t_feed = $mw -> Toplevel();
	$t_feed -> resizable(0,0);
	$t_feed -> wm('title',"Feed Information");

	my $lab_title = $t_feed -> Label(-text=>"Feed Information",-font=>12) -> grid(-column=>0,-row=>0,-columnspan=>2);
	my $lab_channel = $t_feed -> Label(-text=>"Channel Title") -> grid(-column=>0,-row=>1,-sticky=>'w');
	my $ent_channel = $t_feed -> Entry(-textvariable=>\$title) -> grid(-column=>1,-row=>1,-sticky=>'we');
	my $lab_channel_url = $t_feed -> Label(-text=>"Link") -> grid(-column=>0,-row=>2,-sticky=>'w');
	my $ent_channel_url = $t_feed -> Entry(-textvariable=>\$url) -> grid(-column=>1,-row=>2,-sticky=>'we');
	my $lab_channel_desc = $t_feed -> Label(-text=>"Description") -> grid(-column=>0,-row=>3,-sticky=>'w');
	my $stxt_channel_desc = $t_feed -> Scrolled('Text',-scrollbars=>'e',-font=>"$opt{'fixed_font'} 8",-width=>41,-height=>6)
			-> grid(-column=>1,-row=>3,-sticky=>'ew');
	$stxt_channel_desc -> insert('end', $desc);

	my $but_canel = $t_feed -> Button(-text=>" Cancel ",-command=> sub { $t_feed -> destroy; })
		-> grid(-column=>1,-row=>4,-sticky=>'e');
	my $but_ok = $t_feed -> Button(-text=>"   OK   ",-command=> sub {
			$xml->{rss}[0]->{channel}[0]->{title}[0] = $title;
			$xml->{rss}[0]->{channel}[0]->{link}[0] = $url;
			my $desc = $stxt_channel_desc -> get('1.0','end');
			$xml->{rss}[0]->{channel}[0]->{description}[0] = $desc;
			$script{'modified'}++;
			$t_feed -> destroy;
		}) -> grid(-column=>0,-row=>4,-sticky=>'w');
}

#Show a About box
sub about {
	$mw -> messageBox(-message =>"$program{'name'} V $program{'version'}
by Binny V Abraham

$program{'email'}
$program{'website'}",-title=>"About $program{'name'} V$program{'version'}");
}

############################## Functions called by Functions #######################################
#Checks for modifications by user - ask whether it should be changed or not
sub checkModification {
	if ( $script{'modified'} || &checkChange ) {
		my $answer = $mw->messageBox(-message=>"The feed was modified. Do you want to save it?",-icon=>'question',
				-type=>'yesnocancel');
		if($answer eq 'yes') {
			&setItem if &checkChange; #Current Item was changed.
			&publish;
			return 1;
		}
		elsif($answer eq 'no') {
			return 0;
		}
		else {
			return -1;
		}
	}	
}

#Compares a widget's contents with a given value and returns 0 if it is different and 1 if it is same.
sub checkField {
	my ($widget,$value) = @_;
	my $curr_value = $widget -> get();

	return 1 if ($value =~ /^(HASH|SCALAR|ARRAY).*/ && $curr_value eq ""); #You DID NOT see this.
	return 0 if $curr_value ne $value;
	return 1;
}

#Delete the contens of a specified widget and then insert the given value in it.
sub field {
	my ($widget,$value) = @_;
	$widget -> delete(0,'end');
	$widget -> insert(0,$value);
}

#See whether the wanted fields are filled out - Title and Description
sub validateItem {
	my $problems = "";
	$problems .= "Title\n" if &checkField($ent_title,"");
 	my $desc = $stxt_desc -> get(0.1,'end');
 	chomp $desc;
 	$problems .= "Description\n" if $desc eq "";
	
 	if($problems ne "") {
	 	$mw->messageBox(-message=>"Please fill the following fields...\n$problems",-icon=>'error');
	 	return 0;
 	}
 	return 1;
}

#Check if any field value was changed
sub checkChange {
	my $ask = @_;
	$ask = 0 unless $ask;

	#Read the values from structure
 	my $title	= $xml->{rss}[0]->{channel}[0]->{item}[$script{'item_index'}]->{title}[0];
	my $link 	= $xml->{rss}[0]->{channel}[0]->{item}[$script{'item_index'}]->{link}[0];
	my $desc	= $xml->{rss}[0]->{channel}[0]->{item}[$script{'item_index'}]->{description}[0];
	my $pubDate = $xml->{rss}[0]->{channel}[0]->{item}[$script{'item_index'}]->{pubDate}[0];
	#The following is done so to prevent 'use strict;' from reporting any errors - used two times.
	my ($guid,$perm);
	unless ( $xml->{rss}[0]->{channel}[0]->{item}[$script{'item_index'}]->{guid}[0] =~ /^(HASH|SCALAR|ARRAY).*/i ) {
		$guid = $xml->{rss}[0]->{channel}[0]->{item}[$script{'item_index'}]->{guid}[0];
	} else {
		$guid = $xml->{rss}[0]->{channel}[0]->{item}[$script{'item_index'}]->{guid}[0]->{content};
 		$perm	= $xml->{rss}[0]->{channel}[0]->{item}[$script{'item_index'}]->{guid}[0]->{isPermaLink};
	}

	$perm = 'false' unless $perm;
	my $description = $stxt_desc -> get(0.1,'end');
 	chomp $description;
 
	my $changed = 0;
	$changed++ unless &checkField($ent_title,$title);
 	$changed++ unless &checkField($ent_url,$link);
 	$changed++ unless &checkField($ent_date,$pubDate);
	$changed++ unless &checkField($ent_guid,$guid);
 	$changed++ if $is_perm_link ne $perm;
 	$changed++ if $desc ne $description;

 	#If there are changes, ask to save - depending on Options.
	if($changed && $opt{'save_changes'} && $ask) {
		my $response = 'yes';
		$response = $mw -> messageBox(-message=>"Values have been modified. Save current values?",
							-type=>'yesnocancel',-icon=>'question') if $opt{'save_changes'} == 1;
		&setItem if $response eq "yes";
		&newItemRollBack if(($response eq "no") && ($title eq "__Enter_Title_Here __[Internal Error]"));
		return -1 if $response eq 'cancel';
		
	}
	return $changed;
}

#This happens when user Clicks the new item button and then don't save the changes.
sub newItemRollBack {
	for (my $i = 0; $i<=$script{'item_count'}; $i++) {
		&moveFromTo($i+1,$i);
	}
	$script{'item_count'}--;
}
############################## Functions Called from GUI ##########################################
#Create a new feed.
sub newFeed {
	my $answer = 0;
	$answer = &checkModification if $script{'file'};
	my $file = "";
	
	if($answer != -1) {
		my $t_new = $mw -> Toplevel(-takefocus=>1);

		my $created = 0;
		my ($title,$url);
		my $lab_title = $t_new -> Label(-text=>"New Feed",-font=>12) -> grid(-column=>0,-row=>0,-columnspan=>3);
		my $lab_channel = $t_new -> Label(-text=>"Channel Title",-takefocus=>1)
				-> grid(-column=>0,-row=>1,-sticky=>'w');
		my $ent_channel = $t_new -> Entry(-textvariable=>\$title) -> grid(-column=>1,-row=>1,-sticky=>'we',-columnspan=>2);
		my $lab_channel_url = $t_new -> Label(-text=>"Link") -> grid(-column=>0,-row=>2,-sticky=>'w');
		my $ent_channel_url = $t_new -> Entry(-textvariable=>\$url) -> grid(-column=>1,-row=>2,-sticky=>'we',-columnspan=>2);
		my $lab_channel_desc = $t_new -> Label(-text=>"Description") -> grid(-column=>0,-row=>3,-sticky=>'w');
		my $stxt_channel_desc = $t_new -> Scrolled('Text',-scrollbars=>'e',-font=>"$opt{'fixed_font'} 8",-width=>40,-height=>6)
				-> grid(-column=>1,-row=>3,-sticky=>'ew',-columnspan=>2);
		my $lbl_rss_file_in = $t_new -> Label(-text=>"RSS File") -> grid(-column=>0,-row=>4,-sticky=>'w');
		my $ent_rss_file_in = $t_new -> Entry() -> grid(-column=>1,-row=>4,-sticky=>'we');
		my $but_rss_file_in = $t_new -> Button(-text=>'Browse...',-command=> sub {
			my $types = [
		    	['Feed Files', ['.xml', '.rss']],
		    	['All Files',  '*']
			];
			$file = $mw -> getSaveFile(-title => "Choose a new Feed...",-filetypes=>$types,-defaultextension=>'.xml');
			if ($file ne "") {
				$ent_rss_file_in -> delete(0,'end');
				$ent_rss_file_in -> insert(0,$file);
			}

		}) -> grid(-column=>2,-row=>4,-sticky=>'e');

		my $but_ok = $t_new -> Button(-text=>"   OK   ",-command=> sub {
			if( $title && $file ) {
				#Reinitialize - Open the default template file.
				#Get Position of template file
				my $slash_pos = rindex($0,"\\"); # Find the postion of the last '/' in the Script path
				my $len = length($0); # Get length of URL
				my $folder = substr($0,0,$slash_pos); # Get the folder of script path
				$xml = $xs->XMLin("$folder\\Template.xml");

				$xml->{rss}[0]->{channel}[0]->{title}[0] = $title;
				$xml->{rss}[0]->{channel}[0]->{link}[0] = $url;
				my $desc = $stxt_channel_desc -> get('1.0','end');
				$xml->{rss}[0]->{channel}[0]->{description}[0] = $desc;
				
				my ($sec, $min, $hour, $mday, $mon, $year, $wday, $yday, $isdst) = gmtime;
				my $day = qw(Sun Mon Tue Wed Thu Fri Sat)[$wday];
				my $month = qw(Jan Feb Mar Apr May Jun Jul Aug Sep Oct Nov Dec)[$mon];
				my $date_string = sprintf("%s, %02d %s %04d %02d:%02d:%02d GMT", $day,$mday,$month,$year+1900,$hour,$min,$sec);
				$xml->{rss}[0]->{channel}[0]->{lastBuildDate}[0] = $date_string;

				$xml->{rss}[0]->{channel}[0]->{item}[0]->{title}[0] = "__Enter_Title_Here __[Internal Error]"; #Make sure that the user will be asked to Save the value
				$script{'item_index'} = 0;
				$script{'item_count'} = -1;
				$script{'file'} = $file;

				#Display the new vales
				field($ent_title,"");
				field($ent_url,"");
				field($ent_date,"");
				field($ent_guid,"");
				$is_perm_link = 'false';
				$stxt_desc -> delete(0.1,'end');
				field($ent_rss_file,$file);

				$t_new -> destroy;
				$mw -> wm('title',"$program{'name'} V$program{'version'} - $title");
			}
			else {
				$mw->messageBox(-message=>"Please enter the title, descrition and the feed path.");
			}
		}) -> grid(-column=>0,-row=>5,-sticky=>'w');
		my $but_canel = $t_new -> Button(-text=>" Cancel ",-command=> sub { $t_new -> destroy; })
			-> grid(-column=>2,-row=>5,-sticky=>'e');

		$t_new -> wm('title',"New Feed");
		$t_new -> resizable(0,0);
		$t_new -> focus;
		$t_new -> raise;
	}
}

#Insert Current date into the date field.
sub insertCurrentDate {
	#File not available
	unless ($script{'file'}) {
		&noFile;
		return 0;
	}

	my ($sec, $min, $hour, $mday, $mon, $year, $wday, $yday, $isdst) = gmtime;
	my $day = qw(Sun Mon Tue Wed Thu Fri Sat)[$wday];
	my $month = qw(Jan Feb Mar Apr May Jun Jul Aug Sep Oct Nov Dec)[$mon];
	my $date_string = sprintf("%s, %02d %s %04d %02d:%02d:%02d GMT", $day,$mday,$month,$year+1900,$hour,$min,$sec);
	$ent_date -> delete(0,'end');
	$ent_date -> insert('end',$date_string);
}

#Remove the current item
sub removeItem {
	#File not available
	unless ($script{'file'}) {
		&noFile;
		return 0;
	}

	my ($index,$item_title) = @_;
	
	$item_title = $ent_title -> get() unless $item_title;
	$index = $script{'item_index'} unless $index;

	my $response = $mw -> messageBox(-message=>"Are you sure you want delete item '$item_title'?",
										-default=>'no',-type=>'yesno',-icon=>'question');
	if ($response eq "yes") {
		for(my $i=$index; $i<=$script{'item_count'}; $i++) {
			$xml->{rss}[0]->{channel}[0]->{item}[$i] = $xml->{rss}[0]->{channel}[0]->{item}[$i+1];
		}
		
		$script{'item_count'}--;
		&viewItem($script{'item_index'},1);
		$script{'modified'}++; #Make sure that file will be save
	}
}

#Add new Item
sub newItem {
	#File not available
	unless ($script{'file'}) {
		&noFile;
		return 0;
	}

	if ( $script{'item_count'} != -1 ) {
		#Create a new array element
		$script{'item_count'}++;
		#Push all items down to make a space at top.
		for (my $i = $script{'item_count'}-1; $i>=0; $i--) {
			&moveFromTo($i+1,$i);
		}
	}

	$xml->{rss}[0]->{channel}[0]->{item}[0]->{title}[0] = "__Enter_Title_Here __[Internal Error]"; #Make sure that the user will be asked to Save the value
	$script{'item_index'} = 0;

	#Display the new vales
	field($ent_title,"");
	field($ent_url,"");
	field($ent_date,"");
	field($ent_guid,"");
	$is_perm_link = 'false';
	$if_blank = 'blank';
	$stxt_desc -> delete(0.1,'end');
}

#Change the Item to current state.
sub setItem {
	#File not available
	unless ($script{'file'}) {
		&noFile;
		return 0;
	}

	return 0 unless &validateItem; #Exit if wanted fields are not validated.

	#Happens if a new Item is created.
	if($script{'item_index'} > $script{'item_count'}) {
		$script{'item_count'} = $script{'item_index'};
	}

	my $guid = $ent_guid -> get();
	unless ($guid) {
		if ($if_blank eq "create") {
			my ($sec, $min, $hour, $mday, $mon, $year, $wday, $yday, $isdst) = (gmtime)[0,1,2,3,4,5];
			$guid = sprintf("%s-%04d-%02d-%02d-%02d-%02d-%02d",
			$xml->{rss}[0]->{channel}[0]->{title}, $year+1900, $mon, $mday, $hour, $min, $sec);
		} elsif ($if_blank eq "link") {
			$guid = $ent_url -> get();
		}
		$ent_guid -> delete(0,'end');
		$ent_guid -> insert(0,$guid);
	}

	my $desc = $stxt_desc -> get(0.1,'end');
	chomp $desc;

	$xml->{rss}[0]->{channel}[0]->{item}[$script{'item_index'}]->{title}[0] = $ent_title -> get();
	$xml->{rss}[0]->{channel}[0]->{item}[$script{'item_index'}]->{link}[0] = $ent_url -> get();
	$xml->{rss}[0]->{channel}[0]->{item}[$script{'item_index'}]->{description}[0] = $desc;
	$xml->{rss}[0]->{channel}[0]->{item}[$script{'item_index'}]->{pubDate}[0] = $ent_date -> get();
	$xml->{rss}[0]->{channel}[0]->{item}[$script{'item_index'}]->{guid}[0]->{content} = $guid;
	$xml->{rss}[0]->{channel}[0]->{item}[$script{'item_index'}]->{guid}[0]->{isPermaLink}= $is_perm_link;

	$script{'modified'}++;
}

#Display an item - the last one or the next - by taking the values from the hash array
sub viewItem {
	#File not available
	unless ($script{'file'}) {
		&noFile;
		return 0;
	}

	my ($direction,$check) = @_;
	my $check_result = &checkChange unless $check;#Some magic involved.
	return 0 if $check_result == -1; #Get out if user clicked cancel.

	if($direction =~ /^\d+$/) {
		$script{'item_index'} = $direction;
	}
	elsif($direction eq 'p') { #Previous item
		$script{'item_index'}--;
		$script{'item_index'} = $script{'item_count'} if ($script{'item_index'} < 0);
	}
	else { #Next item
		$script{'item_index'}++;
		$script{'item_index'} = 0 if ( $script{'item_index'} > $script{'item_count'} );
	}

	#Read the values from file
	my $title	= $xml->{rss}[0]->{channel}[0]->{item}[$script{'item_index'}]->{title}[0];
	my $link 	= $xml->{rss}[0]->{channel}[0]->{item}[$script{'item_index'}]->{link}[0];
	my $desc	= $xml->{rss}[0]->{channel}[0]->{item}[$script{'item_index'}]->{description}[0];
	my $pubDate = $xml->{rss}[0]->{channel}[0]->{item}[$script{'item_index'}]->{pubDate}[0];
	#The following is done so to prevent 'use strict;' from reporting any errors - used two times.
	my ($guid,$perm);
	unless ( $xml->{rss}[0]->{channel}[0]->{item}[$script{'item_index'}]->{guid}[0] =~ /^(HASH|SCALAR|ARRAY).*/ ) {
		$guid = $xml->{rss}[0]->{channel}[0]->{item}[$script{'item_index'}]->{guid}[0];
	} else {
		$guid = $xml->{rss}[0]->{channel}[0]->{item}[$script{'item_index'}]->{guid}[0]->{content};
 		$perm = $xml->{rss}[0]->{channel}[0]->{item}[$script{'item_index'}]->{guid}[0]->{isPermaLink};
	}
	$perm = 'false' unless $perm;

	#Display the new vales
	field($ent_title,$title);
	field($ent_url,$link);
	field($ent_date,$pubDate);
	$is_perm_link = $perm;
	$if_blank = 'blank';

	if ( $guid =~ /^(HASH|SCALAR|ARRAY).*/i ) {
 		field($ent_guid,"");
	}
	else {
		field($ent_guid,$guid);
	}

	$stxt_desc -> delete(0.1,'end');
	$stxt_desc -> insert(0.1,$desc);
}

############################## Input/Output File Functions #######################################
#Make the user chose a HTML file and put its title, description and modified date into a new Item.
sub readHtml {
	#File not available
	unless ($script{'file'}) {
		&noFile;
		return 0;
	}

	my $types = [
    	['HTML Files', ['.htm', '.html']],
    	['Web Files',  ['.shtml','.php']],
    	['All Files',  '*']
	];

	my $file = $mw -> getOpenFile(-title => "Choose a file...",-filetypes=>$types,-initialdir=>$opt{'site_folder'});
	my ($desc,$title,$url);
	if ($file ne "") {
		if(!open(HTML,$file)) {
			$mw->messageBox(-message=>"Cannot open $file : $!",-title=>"Error",-icon=>'error');
		} else {
			while (<HTML>) {
				$title = $1 if(/<title>([^<]*)<\/title>/i && $title eq "");
				$desc  = $1 if(/<meta name\=\"description\"\s+content\=\"([^>]*)\">/i && $desc eq "");
				last if($desc ne "" && $title ne "");
			}
			close HTML;
			
			#Find last modified time of the file
			my $date_string = "";
			if ($file) {
				use Time::Local 'timelocal_nocheck';
				#Find modified time.
			    my $time = (stat($file))[9];
				my ($sec,$min,$hour,$mday,$mon,$year,$wday)=(localtime(timelocal_nocheck($time,0,0,1,0,70)))[0,1,2,3,4,5,6];
				my $day = qw(Sun Mon Tue Wed Thu Fri Sat)[$wday];
				my $month = qw(Jan Feb Mar Apr May Jun Jul Aug Sep Oct Nov Dec)[$mon];
				$date_string = sprintf("%s, %02d %s %04d %02d:%02d:%02d GMT", $day,$mday,$month,$year+1900,$hour,$min,$sec);
			}
	
			#Find Url
			my $url = "";
			if ( $opt{'site_folder'} ) {
				my $folder = $opt{'site_folder'};
				$folder =~ s/\\/\//g;
				$url = $opt{'site_url'} . $1 if($file =~ /$folder(.*)/);
			}

			&newItem;
			$ent_title -> insert('end',$title) if $title;
			$stxt_desc -> insert('end',$desc) if $desc;
			$ent_date  -> insert('end',$date_string) if $date_string;
			$ent_url   -> insert('end',$url) if $url;
		}
	}
}

#Reads and anaylises the XML file
sub readXml {
	field($ent_rss_file,$script{'file'});
	
 	$xml = $xs->XMLin($script{'file'});
	$script{'item_index'} = -1;
	
	#Count items in the <item> array
	my $i = 0;
	$i++ while ($xml->{rss}[0]->{channel}[0]->{item}[$i]->{title}[0]);
	$script{'item_count'} = $i - 1;

	my $title = $xml->{rss}[0]->{channel}[0]->{title}[0];
	$mw -> wm('title',"$program{'name'} V$program{'version'} - $title");

	#Send the current file to the top of the list.
	my $found_at = -1;
	for(my $i=0; $i<$#recent_feeds+1; $i+=2) {
		if ($recent_feeds[$i] eq $script{'file'}) {
			$found_at = $i;
			last;
		}
	}
	
	if($found_at == 0) {} #Already first Item - Nothing to do.
	elsif($found_at == -1) {
		#Not found - so put at first place
		unshift(@recent_feeds,$title);
		unshift(@recent_feeds,$script{'file'});
 	}
 	else {
	 	#Found - now move every element one step down and put it at top - most recent.
	 	for(my $i=$found_at; $i>1; $i-=2) {
			$recent_feeds[$i] = $recent_feeds[$i-2];
			$recent_feeds[$i+1] = $recent_feeds[$i-1];			
	 	}
	 	$recent_feeds[1] = $title;
		$recent_feeds[0] = $script{'file'};
 	}
 	
 	&viewItem(-1,1);
}

#Publish the HTML file
# $save_type : 0 - Lets the user choose the HTML file | 1 - Takes the file name specified in the Options.
sub publishHTML {
	#File not available
	unless ($script{'file'}) {
		&noFile;
		return 0;
	}

	my $save_type = @_;
	my $html_file = "";

	#Get directory of XML file
	my $slash_pos = rindex($script{'file'},"/"); # Find the postion of the last '/' in the URL
	my $len = length($script{'file'}); # Get length of URL
	my $folder = substr($script{'file'},0,$slash_pos); # Get the address of the site.
	
	if (index($opt{'save_html'},'/') > 0 || index($opt{'save_html'},"\\") > 0) {
		#There is a slash inside the filename - means that a full path is provided and not just the name
		$html_file = $opt{'save_html'};
	}
	elsif ($save_type) {
		#If only the name is provided
		$html_file = "$folder/$opt{'save_html'}";
	} else {
		my $types = [
	    	['HTML Files', ['.htm', '.html']],
	    	['Web Files',  ['.shtml','.php']],
	    	['All Files',  '*']
		];
		$folder =~ s/\//\\/g;
		my $def_file = $folder . "\\rss.html";

		$html_file = $mw -> getSaveFile(-title=>"Choose a file...",-filetypes=>$types,
				-initialdir=>$folder,-defaultextension=>'.html',-initialfile=>$def_file);
	}
	return 0 unless $html_file; #Exit the function if a valid Html file is not chosen

	#Make HTML Data
	#Get Date
	my ($sec, $min, $hour, $mday, $mon, $year, $wday, $yday, $isdst) = gmtime;
	my $day = qw(Sun Mon Tue Wed Thu Fri Sat)[$wday];
	my $month = qw(Jan Feb Mar Apr May Jun Jul Aug Sep Oct Nov Dec)[$mon];
	my $date_string = sprintf("%s, %02d %s %04d %02d:%02d:%02d GMT", $day,$mday,$month,$year+1900,$hour,$min,$sec);
	
	my $channel = $xml->{rss}[0]->{channel}[0]->{title}[0];
	my $channel_url = $xml->{rss}[0]->{channel}[0]->{link}[0];
	my $channel_desc = $xml->{rss}[0]->{channel}[0]->{description}[0];
	my $generator = "$program{'name'} V$program{'version'}";
	
	$channel_desc =~ s/\n/<br>\n/g;
	
	my $html_data = "";
	
	$html_data .= <<HTML_TOP;
<HTML><HEAD>
<TITLE>$channel</TITLE>
<style>
.channel { border:gray 1px dashed; width:100%; }
.item_1 { background:#aaaaaa; width:100%; }
.item_2 { background:#cccccc; width:100%; }
</style>
</HEAD>
<BODY>
<H1 align="center">$channel</h1>
<table class='channel'><tr><td>
<b>Channel Information:</b><br>
<a href="$channel_url">$channel</a> - $channel_desc
</td></tr></table>
<br><br>
HTML_TOP

	foreach (0..$script{'item_count'}) {
		my $i = $_;
		my $item_class = 'item_1';
		$item_class = 'item_2' if ($i % 2);
 		#Read the values from array
  		my $title	= $xml->{rss}[0]->{channel}[0]->{item}[$i]->{title}[0];
		my $link 	= $xml->{rss}[0]->{channel}[0]->{item}[$i]->{link}[0];
		my $desc	= $xml->{rss}[0]->{channel}[0]->{item}[$i]->{description}[0];
		my $pubdate = $xml->{rss}[0]->{channel}[0]->{item}[$i]->{pubDate}[0];
		
		$html_data .= "<table class='$item_class'>\n";
		$html_data .= "<tr><td class='title'><a class='link' href=\"$link\">$title</a></td></tr>\n";
		$html_data .= "<tr><td>$desc</td></tr>\n";
		$html_data .= "<tr><td><i>Published : $pubdate</i></td></tr>\n</table>\n\n";
	}
	
	$html_data .= <<HTML_END;
<br><br>
<hr>
<i>Last Updated on : $date_string</i><br>
Created by <b><a href="$program{'web_page'}">$generator</a></b>.<br>
HTML_END

$html_data .= "The URL to provide to an RSS aggregator when subscribing to this feed:
<a href=\"$opt{'xml_url'}\">$opt{'xml_url'}</a>" if $opt{'xml_url'};

$html_data .= "\n\n</body></html>";

	my $html_ok = open HTML, ">$html_file";
	if ($html_ok) {
		print HTML $html_data;
		close HTML;
	} else {
		#Error
		$mw->messageBox(-message=>"Cannot open '$html_file' for writing : $!",-title=>"Error",-icon=>'error');
	}
}

#Publish the XML file
sub publish {
	#File not available
	unless ($script{'file'}) {
		&noFile;
		return 0;
	}

	my $rss_file = $ent_rss_file -> get();
	if ($rss_file eq $script{'file'}) {
		$rss_file = $script{'file'};
	}
	elsif($rss_file eq "") {
		my $types = [
	    	['Feed Files', ['.xml', '.rss']],
	    	['All Files',  '*']
		];
		
		my $file = $mw -> getSaveFile(-title => "Choose a Feed...",-filetypes=>$types);
		if ($file ne "") {
			$ent_rss_file -> delete(0,'end');
			$ent_rss_file -> insert(0,$file);
			$script{'file'} = $file;
			$rss_file = $script{'file'};
		} else {
			return 0;
		}
	}
	
	#Make XML Data
	my ($sec, $min, $hour, $mday, $mon, $year, $wday, $yday, $isdst) = gmtime;
	my $day = qw(Sun Mon Tue Wed Thu Fri Sat)[$wday];
	my $month = qw(Jan Feb Mar Apr May Jun Jul Aug Sep Oct Nov Dec)[$mon];
	my $date_string = sprintf("%s, %02d %s %04d %02d:%02d:%02d GMT", $day,$mday,$month,$year+1900,$hour,$min,$sec);

	my $xml_data = "";
	$xml_data .= "<?xml version=\"1.0\" encoding=\"UTF-8\" ?>\n";
	$xml_data .= "<rss version=\"2.0\">\n";
	$xml_data .= " <channel>\n";
	$xml_data .= "  <title>$xml->{rss}[0]->{channel}[0]->{title}[0]</title>\n";
	$xml_data .= "  <link>$xml->{rss}[0]->{channel}[0]->{link}[0]</link>\n";
	$xml_data .= "  <description>$xml->{rss}[0]->{channel}[0]->{description}[0]</description>\n";
	$xml_data .= "  <lastBuildDate>$date_string</lastBuildDate>\n";
	$xml_data .= "  <generator>$program{'name'} V$program{'version'}</generator>\n";
	$xml_data .= "  <docs>http://blogs.law.harvard.edu/tech/rss</docs>\n\n";

	for(my $i=0; $i<=$script{'item_count'}; $i++) {
 		#Read the values from array
 		my ($title,$link,$desc,$pubdate,$guid,$perm) = "";
  		$title	= $xml->{rss}[0]->{channel}[0]->{item}[$i]->{title}[0];
		$link 	= $xml->{rss}[0]->{channel}[0]->{item}[$i]->{link}[0];
		$desc	= $xml->{rss}[0]->{channel}[0]->{item}[$i]->{description}[0];
		$pubdate = $xml->{rss}[0]->{channel}[0]->{item}[$i]->{pubDate}[0];
		#The following is done so to prevent 'use strict;' from reporting any errors - used two times.
		unless ( $xml->{rss}[0]->{channel}[0]->{item}[$i]->{guid}[0] =~ /^(HASH|SCALAR|ARRAY).*/ ) {
			$guid = $xml->{rss}[0]->{channel}[0]->{item}[$i]->{guid}[0];
		} else {
			$guid = $xml->{rss}[0]->{channel}[0]->{item}[$i]->{guid}[0]->{content};
	 		$perm = $xml->{rss}[0]->{channel}[0]->{item}[$i]->{guid}[0]->{isPermaLink};
		}
		$perm = 'false' unless $perm;
		
		if ( $xml->{rss}[0]->{channel}[0]->{item}[$i]->{title}[0] eq "__Enter_Title_Here __[Internal Error]") {
	  		$title = "";
  		}

  		unless ($title =~ /^(HASH|SCALAR|ARRAY).*/ && !$title) { #The unless are here to take care of a rather nasty bug.
			$xml_data .= "  <item>\n";
	        $xml_data .= "   <title>$title</title>\n" unless ($title =~ /^(HASH|SCALAR|ARRAY).*/ && !$title);
	        $xml_data .= "   <link>$link</link>\n" unless ($link =~ /^(HASH|SCALAR|ARRAY).*/ && !$link);
	        $xml_data .= "   <description>$desc</description>\n" unless ($desc =~ /^(HASH|SCALAR|ARRAY).*/ && !$desc);
	        $xml_data .= "   <pubDate>$pubdate</pubDate>\n" unless ($pubdate =~ /^(HASH|SCALAR|ARRAY).*/ && !$pubdate);
	        $xml_data .= "   <guid isPermaLink=\"$perm\">$guid</guid>\n" if $guid;
	        $xml_data .= "  </item>\n\n";
		}
	}
	
	$xml_data .= " </channel>\n";
	$xml_data .= "</rss>\n";
	
	if ($script{'modified'}) { 
		my $status_ok = open XML,">$rss_file";
		if ($status_ok) {
			print XML $xml_data;
			close XML;
			$script{'modified'} = 0; #The file is no longer 'modified'
		}
		else {
			$mw->messageBox(-message=>"Cannot open file '$rss_file' : $!",-icon=>'error');
		}
	}
	
	&publishHTML(1) if $opt{'save_html'};
}

############################## First And Last ##########################################
#Happens when the applications is closed
sub exiter {
	my $answer = 0;
 	$answer = &checkModification if $script{'file'}; #Don't have to check if file is not there.

	if ($answer != -1) { #Exit if user did'nt click cancel.
		#Saveing Options
		my $options_ok = open(OPT,">$opt{'opt_file'}");
		if($options_ok) {
			#Save Options
			print OPT "Site_Folder=$opt{'site_folder'}\n" if $opt{'site_folder'};
			print OPT "Site_Url=$opt{'site_url'}\n" if $opt{'site_url'};
			print OPT "Save_Html=$opt{'save_html'}\n" if $opt{'save_html'};
			print OPT "Xml_Url=$opt{'xml_url'}\n" if $opt{'xml_url'};
			print OPT "Editor=$opt{'editor'}\n" if $opt{'editor'};
			print OPT "Last_File=$script{'file'}\n" if $script{'file'};

			#Save Recent feeds
			my $total = $#recent_feeds;
			my $count = 0;
			$total = $recent_limit*2 if $#recent_feeds > $recent_limit*2; #*2 is nessary as 5 items means 10 elements - 1 file path and 1 title
			for(my $i=0; $i<$total; $i+=2) {
				if ($recent_feeds[$i]) {
					$count++;
					print OPT "RecentItem$count=$recent_feeds[$i+1]\n";
					print OPT "RecentFile$count=$recent_feeds[$i]\n";
				}
			}
			#Save Favorites
			$total = $#favorite_feeds;
			$count = 0;
			$total = $favorite_limit*2 if $#favorite_feeds > $favorite_limit*2; #*2 is nessary as 5 items means 10 elements - 1 file path and 1 title
			for(my $i=0; $i<$total; $i+=2) {
				if ($favorite_feeds[$i]) {
					$count++;
					print OPT "FavoriteItem$count=$favorite_feeds[$i+1]\n";
					print OPT "FavoriteFile$count=$favorite_feeds[$i]\n";
				}
			}
			close(OPT);
		}
		else {
			$mw->messageBox(-message=>"Cannot save options to '$opt{'opt_file'}' : $!",
					-title=>"Error",-icon=>'error');
		}
		exit 0;
	}
}

#Initialize the script
sub init {
	#Get Options 
	my $options_ok = open(OPT,$opt{'opt_file'});
	if($options_ok) {
		my @lines = <OPT>;
		my $line_count = @lines;

		for(my $i=0; $i<$line_count; $i++) {
			$_ = $lines[$i];

			$opt{'site_folder'}	= $1 if /Site_Folder=(.+)\n/;
			$opt{'site_url'}	= $1 if /Site_Url=(.+)\n/;
			$opt{'save_html'}	= $1 if /Save_Html=(.+)\n/;
			$opt{'xml_url'}		= $1 if /Xml_Url=(.+)\n/;
			$opt{'editor'}		= $1 if /Editor=(.+)\n/;
			$script{'file'}		= $1 if /Last_File=(.+)\n/;
			#Recent Files...
			if (/RecentItem[0-9]\=(.+)$/) {
				unshift(@recent_feeds,$1);
				$_ = $lines[++$i];

				if (/RecentFile[0-9]\=(.+)$/) {
					unshift(@recent_feeds,$1);
				}
			}
			#Favorites...
			if (/FavoriteItem[0-9]+\=(.+)$/) {
				unshift(@favorite_feeds,$1);
				$_ = $lines[++$i];

				if (/FavoriteFile[0-9]+\=(.+)$/) {
					unshift(@favorite_feeds,$1);
				}
			}
		}
		close(OPT);
	}

	#Get Command Line Arguments
	if (@ARGV) {
		$script{'file'} = $ARGV[0];
		&readXml;
	}
	elsif( $script{'file'} ) {
		&readXml;
	}

# 	#DEBUG
#	else {
#  		$script{'file'} = "D:/Scripts/Perl/Under Construction/RSSPilot/feed.xml"; #DEBUG
#  		$last_file = $script{'file'};
#  		readXml();
# 	}
# 	#DEBUG
}

############################## To Do ##########################################
# Ability to Edit Favorites
# More balloon help is needed.
# Remove all #DEBUG and #CHANGE
# Perhabs Drad and drop ability - For XML and HTML files?
# Give all Dialogs Grab - But how?
# Maybe a function that gets the needed data from the $xml variable and returns it...

# BUGS
# Tends to misbehave if given file is not XML
