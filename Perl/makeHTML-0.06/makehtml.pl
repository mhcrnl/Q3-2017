#!/usr/bin/perl

# ----------------------------------------------------------------------------
# program:	makehtml.pl
# version:	0.06 m5 build 2000-02-15
# task:		Creates HTML documents out of a simple script and some
#		dummy and content files
# author:	Jan Theofel, jan@theofel.de
# language:	Perl
# license:	GPL (GNU General Public License)
# ----------------------------------------------------------------------------
# THIS PROGRAM IS PUBLISHED UNDER THE TERMS OF THE GNU PUBLIC LICENSE (GPL).
# IT COMES WITH ABSOLUTLY NO WARRENTY! USE IT AT YOUR OWN RISK!
# ----------------------------------------------------------------------------

use GD;
use Tie::IxHash;

$identify = "makehtml v0.06 m5 build 2000-02-15 by Jan Theofel (jan\@theofel.de)";

&init;
&run;
&done;

sub init
# ----------------------------------------------------------------------------
# sub: 		init
# task: 	initalisation of the script, reading & parsing input files
# author:	Jan Theofel, jan@theofel.de
# last changed: 2000-02-14 
# ----------------------------------------------------------------------------
{
  &set_contances;
  &basic_init;
  &prepare_logfile;
  &parse_files; 
  &setgfxsize;
  &preparse;
}

sub run
# ----------------------------------------------------------------------------
# sub:		run
# task:		creates the html files
# author:	Jan Theofel, jan@theofel.de
# last changed: 2000-02-17
# ----------------------------------------------------------------------------
{
  logmsg("");
  msg("----- Creating the homepage:\n");
  msg("writing files from the menu...\n");
  foreach $key (keys %menu)
  {
    if($menu{$key}->{KIND} == $menu_kind_item)
    {
      logmsg("Creating file '$key' (menu item id $menu{$key}->{ID})\n");
      $filename = $key;
      $outfilename = $key;
      open(OUT,">$htmlpath$filename")||die("FATAL ERROR: Can't open outfile $filename");
      $contentfile = $menu{$filename}->{CONTENT};
      open(CONTENT,"<$contentfile")||die("FATAL ERROR: Can't open content file $contentfile");
    }

    $menu = "";
    $count_gfx = $set{START_COUNT_GFX};

    &create_menu($menu{$filename}->{ID});
#    print "DEBUG: Calling \&create_menu with $menu{$filename}->{ID}\n";

    &start_html;

    &include_dummy($contentfile);
  }
  msg("writing files which are not in the menu...\n");
  for($x=0;$x<=$#none_menu_files;$x++)
  {
    $filename = $none_menu_files[$x];
    open(OUT,">$htmlpath$filename")||die("FATAL ERROR: Can't open outfile $filename");
    $x++;
    $contentfile = $none_menu_files[$x];
    open(CONTENT,"<$contentfile")||die("FATAL ERROR: Can't open content file $contentfile");
    $menu = "";
    $count_gfx = $set{START_COUNT_GFX};

    &create_menu("");

    &start_html;

    &include_dummy($contentfile);
  }

}

sub done
# ----------------------------------------------------------------------------
# sub:		done
# task:		finishes the script and exits
# author:	Jan Theofel, jan@theofel.de
# last changed: 2000-02-14
# ----------------------------------------------------------------------------
{

  msg("----- Homepage finished!!!\n");

  # --- check for defined but not used elements
  logmsg("Checking all table for COUNT");
  foreach $key (keys %tables)
  {
    if($tables{$key}->{COUNT} == 0)
    {
      warning("Table '$key' was defined, but never used! Perhaps a typo?");
    }
    else
    {
      logmsg("table '$key' was used $table{$key}->{COUNT} time(s)");
    }
  }

  logmsg("Checking all fonts for COUNT");
  foreach $key (keys %fonts)
  {
    if($fonts{$key}->{COUNT} == 0)
    {
      warning("Font '$key' was defined, but never used! Perhaps a typo?");
    }
    else
    {
      logmsg("font '$key' was used $fonts{$key}->{COUNT} time(s)");
    }
  }

  msg("TOTAL WARNINGS: $warnings\n");
  close(LOG);
}

sub usage
# ----------------------------------------------------------------------------
# sub:		done
# task:	 	prints the usage to the screen and dies (not much really ;-)	
# author:	Jan Theofel, jan@theofel.de
# last changed:	2000-02-14
# ----------------------------------------------------------------------------
{
  
  die <<EOF;

$identify

THIS PROGRAM IS PUBLISHED UNDER THE TERMS OF THE GNU GENERAL PUBLIC LICNESE.
IT COMES WITH ABSOLUTLY NO WARRENTY. USE IT AT YOUR OWN RISK!

Usage:
  makeHTML makefile [makefile2] [makefile3] [...] [makefilex]

Visit the makeHTML homepage for new versions, bugfixes, exapmles, ...
  http://www.theofel.de/oss/makehtml/

Send me your comments, suggestions, buxreports, ... via email to:
  Jan Theofel <jan\@theofel.de>

EOF

}

sub basic_init
# ----------------------------------------------------------------------------
# sub:		basic_init
# task: 	runs the basic initialisations for the script
# author:	Jan Theofel, jan@theofel.de
# last changed: 2000-02-16
# ----------------------------------------------------------------------------
{

  $paramcount = $#ARGV;
  if($paramcount==-1) {&usage};

  $warnings = 0;

  $submenu = 0;
  $javascriptdefs = 0;
  $defimages = ();
  %imagemapdef = ();
  @addjavascript = ();
  @none_menu_files = ();

  tie %menu, "Tie::IxHash";		# keys should return the following
  tie %set, "Tie::IxHash";		# hashs in the order they were
  tie %meta, "Tie::IxHash";		# filled

  push(@makefiles,$ARGV[0]);
  foreach $filename (@makefiles)
  {
    if($filename eq "--help")
      { &usage; }
    if($filename eq "--version")
      { die "$identify\n"; }
  }

  $dummy_width = 0;
  $dummy_height = 0;

  $set{WIDTH} = 0;
  $set{HEIGHT} = 0;

  print <<WELCOME;

$identify

THIS PROGRAM IS PUBLISHED UNDER THE TERMS OF THE GNU GENERAL PUBLIC LICNESE.
IT COMES WITH ABSOLUTLY NO WARRENTY. USE IT AT YOUR OWN RISK!

WELCOME
}

sub set_contances
# ----------------------------------------------------------------------------
# sub:          set_contances
# task:         set the basic constances to run the script
# author:       Jan Theofel, jan@theofel.de
# last changed: 2000-02-14 by Jan Theofel
# ----------------------------------------------------------------------------
{
  $menu_kind_none	= 0;	# for unknown entries
  $menu_kind_item	= 1;	# for menu items
  $menu_kind_sub	= 2;	# for submenu entries
  $menu_kind_sep	= 3;	# for seperators
}

sub setgfxsize
# ----------------------------------------------------------------------------
# sub:          setgfxsize
# task:         sets the size for the images, autodetection if needed
# author:       Jan Theofel, jan@theofel.de
# last changed: 2000-02-15
# ----------------------------------------------------------------------------
{
  msg("----- Preparing the homepage creation:\n");
  if($set{DUMMYHEIGHT}==0||$set{DUMMYHEIGHT}==undef||$set{DUMMYWIDTH}==0||$set{DUMMYWIDTH}==undef)
  {
    msg("Autodetecting size for dummy gfx...\n");
    $localfilename = $htmlpath . $set{GFXDUMMY};
    if(!open(GIF,$localfilename))
    {
      warning("Can't open $localfilename, no autosize possible!");
    }
    else
    {
      if(($giffile = newFromGif GD::Image(GIF))=0)
      {
        warning("Dummy file is not a GIF file. Autodetection not possible!\n");
        $dummy_height = undef;
        $dummy_width = undef;
      }
      else
      {
        ($dummy_width,$dummy_height) = GD::Image::getBounds($giffile);
        msg("autosize (dummy gfx) returns width = $dummy_width, height = $dummy_height\n");
      }
    }
  }
  else
  {
    $dummy_height = $set{DUMMYHEIGHT}; $dummy_height =~ s/\s*//g;
    $dummy_width = $set{DUMMYWIDTH}; $dummy_width =~ s/\s*//g;
  }
}

sub parse_files
# -----------------------------------------------------------------------------
# sub:		parse_files
# task: 	parses the makefile
# author:	Jan Theofel, jan@theofel.de
# last changed: 2000-02-18
# -----------------------------------------------------------------------------
{

  $menu_id = 0;

  msg("----- Parsing files\n");
  while($#makefiles!=-1)
  {
    $actual_makefile = pop(@makefiles);

    logmsg("Parsing file $actual_makefile ...\n");

    open(MAKE,"$actual_makefile")||die("FATAL ERROR: Can't open file $actual_makefile!\n\n");    $linecount = 0;

    while(<MAKE>)
    {
      $linecount++;
      chomp;
      if(/^\s*$/) {next;}		# skip empty lines
      if(/^#.*$/){next;}		# skip comment lines
      $_=~s/^\s*//;

      ($command, $param, $value) =split(/\ /,$_,3);
      if(uc($command) eq "SET")
      {
        $set{uc($param)} = $value;
      }
      elsif(uc($command) eq "META")
      {
        $meta{$param} = $value;
      }
      elsif(uc($command) eq "FILE")
      {
        push(@none_menu_files,$param);
        push(@none_menu_files,$value);
      }
      elsif(uc($command) eq "MENUITEM")
      {
        $filename = $param;

        ($content, $button, $button_hl, $button_hl2, $alttext)
          = split(/\ /, $value, 5);
      
	$menu{$filename}->{KIND}	= $menu_kind_item;  
	$menu{$filename}->{ID}		= $menu_id;
        $menu{$filename}->{CONTENT}	= $content;
        $menu{$filename}->{BUTTON}	= $button;
        $menu{$filename}->{BUTTON_HL}	= $button_hl;
        $menu{$filename}->{BUTTON_HL2}	= $button_hl;
        $menu{$filename}->{ALTTEXT}	= $alttext;

	$menu_id++;
       
      }
      elsif(uc($command) eq "IMG")
      {
        push(@defimages, uc($param), $value);
      }
      elsif(uc($command) eq "DEFTABLE")
      {
        %localdef = ();
        $startdefline = $linecount;
        $enddef = 0;
        while(<MAKE>)
        {
          $linecount++;
          chomp;
          if(/^\s*$/) {next;}		# skip empty lines
          if(/^#.*$/){next;}		# skip comment lines
          $_=~s/^\s*//;
          if($_ eq "enddef") 
          { 
            $enddef = 1; 
            last; 
          }
          ($param, $value) =split(/\ /,$_,2);
          $param =~ s/^\s+//;			# the following lines can be
          $param =~ s/\s+$//;			# simplified, can they?
          $value =~ s/^\s+//;
          $value =~ s/\s+$//;
          $localdef{uc($param)} = $value;
        }
        if($enddef==0)
        {
          close(MAKE);
          die("FATAL ERROR: Missing enddef for table def in line $startdefline!");
        }
        elsif($localdef{NAME} eq "")
        {
          close(MAKE);
          die("FATAL ERROR: Missing name for table def from line $startdefline to $linecount!");
        }
        else
        {
          logmsg("reading table definition $localdef{NAME}\n");
        }
        foreach $key (keys %localdef)
        {
          if($key ne "NAME")
          {
            $tables{$localdef{NAME}}->{$key} = $localdef{$key};
          }
        }
        $tables{$localdef{NAME}}->{COUNTER} = 0;
      }
      elsif(uc($command) eq "DEFJAVASCRIPTGFX")
      {
        $javascriptdefs++;
        $startdefline = $linecount;
        $enddef = 0;
        while(<MAKE>)
        {
          $linecount++;
          chomp;
          if(/^\s*$/) {next;}           # skip empty lines
          if(/^#.*$/){next;}            # skip comment lines
          $_=~s/^\s*//;
          if($_ eq "enddef") { $enddef = 1; last; }
          ($param, $value) =split(/\ /,$_,2);
          $javascriptgfxdef{$javascriptdefs . $param} = $value;
        }
        if($enddef==0)
        {
          close(MAKE);
          die("FATAL ERROR: Missing enddef for javascript gfx addition in line $startdefline!");
        }
        else
        {
           msg("reading graphics for adding to java script (jsgfx #$javascriptdefs)\n");
        }
      }
      elsif(uc($command) eq "DEFFONT")
      {
        $startdefline = $linecount;
        $enddef = 0;
        while(<MAKE>)
        {
          $linecount++;
          chomp;
          if(/^\s*$/) {next;}           # skip empty lines
          if(/^#.*$/){next;}            # skip comment lines
          $_=~s/^\s*//;
          if($_ eq "enddef") 
          { 
            $enddef = 1; 
            last; 
          }
          ($param, $value) =split(/\ /,$_,2);
          $this_font_def{uc($param)} = $value;
        }
        if($enddef==0)
        {
          close(MAKE);
          die("FATAL ERROR: Missing enddef for font definition starting in line $startdefline!\n");
        }
        if($this_font_def{NAME} eq "")
        {
          close(MAKE);
          die("FATAL ERROR: Missing name for font definition starting in line $startdefline!\n");
        }
        foreach $key (keys %this_font_def)
        {
          if($key ne "NAME")
          {
            $fonts{$this_font_def{NAME}}->{$key} = $this_font_def{$key};
          }
        }
        logmsg("reading font definition " . $this_font_def{NAME} . "\n");
        $fonts{$this_font_def{NAME}}->{COUNTER} = 0;
      }
      elsif(uc($command) eq "INCLUDE")
      {
        logmsg("storing file $param in include stack\n");
        push(@makefiles,$param);
      }
      elsif(uc($command) eq "JAVASCRIPT")
      {
        msg("reading javascript code starting in line $linecount...\n");
        $startjavascript = $linecount;
        $javascriptended = 0;
        while(<MAKE>)
        {
          if(uc($_) =~ /\s*ENDJAVASCRIPT\s*/)
          {
            $javascriptended = 1;
            last;
          }
          else
          {
            push(@addjavascript,$_);
          }
        }
        if($javascriptended==0)
        {
          die("FATAL ERROR: Javascript code from line $startjavascript has no end!\n             Use command 'endjavascript' to end it correctly.\n");
        }
      }
      elsif(uc($command) =~ /\s*IMAGEMAP\s*/)
      {
        $imagemapname = "";
        $imagemapdata = "";
        $startdefline = $linecount;
        $enddef = 0;
        while(<MAKE>)
        {
          $linecount++;
          chomp;
          if(/^\s*$/) {next;}           # skip empty lines
          if(/^#.*$/){next;}            # skip comment lines
          $_=~s/^\s*//;
          if(uc($_) =~ /\s*ENDIMAGEMAP\s*/)
            { $enddef = 1; last; }
          ($kind, $link, $data, $alt) =split(/\ /,$_,4);
          if(uc($kind) eq "NAME") 
            { $imagemapname = $link; } 
          else
          {
            @coords = (); 
            @coords = split(/,/,$data);
            for($count_coords=0;$count_coords<=$#coords;$count_coords++)
            {
              if($coords[$count_coords] =~ /^\+(.*)$/)
                { $coords[$count_coords] = $coords[$count_coords-2] + $1; } 
              if($coords[$count_coords] =~ /^-(.*)$/)
                { $coords[$count_coords] = $coords[$count_coords-2] - $1; }
            }
            $coords = join(",",@coords);
            $imagemapdata = $imagemapdata . "<AREA SHAPE=\"" . uc($kind) . "\" COORDS=\"$coords\" HREF=\"$link\" ALT=\"$alt\">\n";
          }
        }
        if($imagemapname eq "")
          { die("FATAL ERROR: Missing name for imagemap definition in line $startdefline!"); }
        if($enddef==0)
        {
          close(MAKE);
          die("FATAL ERROR: Missing enddef for imagemap definition in line $startdefline!");
        }

        $imagemapdata = "<MAP NAME=\"$imagemapname\">\n" . $imagemapdata . "<\/MAP>\n";

        $imagemapdef{$imagemapname} = $imagemapdata;
      }
      else
      {
        close(MAKE);
        die "FATAL ERROR: Error reading line $linecount!\n\n";
      }
    }
    close(MAKE);
  }
 
  if($set{HTMLPATH} ne "")
  {
    if($set{HTMLPATH} !~ /\/$/)
      { $set{HTMLPATH} = $set{HTMLPATH} . "/"; }
    $htmlpath = $set{HTMLPATH};
  }
  else
  {
    $htmlpath = "./";
    warning("Output path is the local path. Don't mix your source with the results!");
  }
  logmsg("Parse htmlpath is '$htmlpath'");

  if($set{DEFAULT_FONT} ne "")
  {
    if($fonts{$set{DEFAULT_FONT}}->{START} ne "")
    {
      logmsg("Using default font '$set{DEFAULT_FONT}'");
    }
    else
    {
      warning("Default font '$set{DEFAULT_FONT}' not declared!\nUse 'deffont' in the makefile to declare it.");
    }
  }
  else
  {
    logmsg("HINT: No default font defined.\n      Use 'set default_font xxx' to set it in the makefile.");
  }

# ----- start of debugging code -----
#  foreach $key (keys %fonts)
#  {
#    foreach $param (keys %{$fonts{$key}})
#    {
#      print "DEBUG: font '$key' has param '$param' width value '$fonts{$key}->{$param}'\n";
#    } 
#  } 
#  die;
# ------ end of debugging code ------
}

sub create_menu_gfx_entries
# -----------------------------------------------------------------------------
# sub:		create_menu_gfx_entries
# task:		prints the entries in the javascript which are needed for the 
#		menu
# author:	Jan Theofel, jan@theofel.de
# last changed:	2000-02-14
# -----------------------------------------------------------------------------
{
  foreach $key (keys %menu)
  {
    print OUT "    menuitem$menu{$key}->{ID} = new Image();\n";
    print OUT "    menuitem$menu{$key}->{ID}.src = \"$menu{$key}->{BUTTON}\";\n";
  }

  foreach $key (keys %menu)
  {
    print OUT "    menuitem$menu{$key}->{ID}_hl = new Image();\n";
    print OUT "    menuitem$menu{$key}->{ID}_hl.src = \"$menu{$key}->{BUTTON_HL}\";\n";
  }

}

sub create_add_gfx_entries
# -----------------------------------------------------------------------------
# sub:		create_add_gfx_entries
# task:		insert additional items in the js list
# author:	Jan Theofel, jan@theofel.de
# last changed: 2000-02-14
# -----------------------------------------------------------------------------
{
  if($javascriptdefs!=0)
  {
    for($count=1;$count<=$javascriptdefs;$count++)
    {
      if($javascriptgfxdef{$count . "files"} =~ /$outfilename/)
      {
        msg("  Adding graphic entries to javascript for file $outfilename (jsgfx #$count)\n");
        print OUT "\n";
        $filenamemask = $javascriptgfxdef{$count . "filename"};
        foreach $key (keys(%javascriptgfxdef))
        {
          if(uc($key) ne $count."FILES" && uc($key) ne $count."FILENAME")
          {
            if($key !~ /^$count/)
            {
              next;
            }
            $key =~ s/^$count//;
            $gfxfilename = $filenamemask;
            $gfxfilename =~ s/\*/$javascriptgfxdef{$count.$key}/; 
            print OUT "    $key = new Image();\n";
            print OUT "    $key.src = \"$gfxfilename\";\n";
          } 
        }
      }
      else
      {
        logmsg("  No additional grapic entries to javascript for file $outfilename (jsgfx #$count)\n");
      }
    }
  }
}

sub create_add_javascriptcode
# -----------------------------------------------------------------------------
# sub:		create_add_javascriptcode
# task:		inserts additionaly javascript code from the makefile(s)
# author:	Jan Theofel, jan@theofel.de
# last changed: 2000-02-14
# -----------------------------------------------------------------------------
{
  if($#addjavascript!=-1)
  {
    logmsg("  Adding javascript code from makefile...\n");
    print OUT "\n";
    for($count=0;$count<=$#addjavascript;$count++)
    {
      print OUT $addjavascript[$count];
    }
  }
}

sub preparse
# -----------------------------------------------------------------------------
# sub:		preparse
# task:		setting some values from the makefiles for faster access to
# 		them, preparsing of the meta tags
# author:	Jan Theofel, jan@theofel.de
# last changed:	2000-02-18
# ----------------------------------------------------------------------------
{

  # ----- read in some vars for faster access to them -----
  $menuhorizontal = (uc($set{MENU}) =~ /HORIZONTAL/);
  if($menuhorizontal)
  {
    msg("Using horizontal menus!\n");
  }
  else
  {
    msg("Using vertical menus!\n");
  }

  # ----- preparse the meta tags (references on others) -----
  foreach $key (keys(%meta))
  {
    if($meta{$key} =~ /^=/)
    {
      $newkey = $meta{$key};
      $newkey =~ s/^=//;
      $meta{$key} = $meta{$newkey};
    }
  }

  # ----- print out the used meta tags ----- 
  logmsg("Using the following meta-tags:\n");
  foreach $key (keys %meta)
  {
    logmsg("  $key -> $meta{$key}\n");
  }

  # ----- preparsing of the menu items -----
  msg("preparing menuitems...\n");

  # ----- check for given gfx dummy filenames ---
  if($set{GFXFILENAME} eq "")
  {
    $set{GFXFILENAME} = "*";
    warning("GFXFILENAME was not given in make file. You use full gfx filenames!");
  }
  
  if($set{GFXHLFILENAME} eq "")
  {
    $set{GFXHLFILENAME} = "*";
    warning("GFXHLFILENAME was not given in make file. You use full gfx filenames!");
  }
  
  if($set{GFXHL2FILENAME} eq "")
  {
    $set{GFXHL2FILENAME} = "*";
    warning("GFXHL2FILENAME was not given in make file. You use full gfx filenames!");
  }
  
  # --- some analisis of the menuitems ---
  foreach $key (keys %menu)
  {
    $basefilename = $menu{$key}->{BUTTON};

    $menu{$key}->{BUTTON} = $set{GFXFILENAME};
    $menu{$key}->{BUTTON} =~ s/\*/$basefilename/g;

    if($menu{$key}->{BUTTON_HL} eq "*")
    {
      $menu{$key}->{BUTTON_HL} = $set{GFXHLFILENAME};
      $menu{$key}->{BUTTON_HL} =~ s/\*/$basefilename/g;
    }
    else
    {
      $thisbasefilename = $menu{$key}->{BUTTON_HL};
      $menu{$key}->{BUTTON_HL} = $set{GFXHLFILENAME};
      $menu{$key}->{BUTTON_HL} =~ s/\*/$thisbasefilename/g;
    }

    if($menu{$key}->{BUTTON_HL2} eq "*")
    {
      $menu{$key}->{BUTTON_HL2} = $set{GFXHL2FILENAME};
      $menu{$key}->{BUTTON_HL2} =~ s/\*/$basefilename/g;
    }
    else
    {
      $thisbasefilename = $menu{$key}->{BUTTON_HL2};
      $menu{$key}->{BUTTON_HL2} = $set{GFXHLFILENAME};
      $menu{$key}->{BUTTON_HL2} =~ s/\*/$thisbasefilename/g;
    }


    if($menu{$key}->{WIDTH} == 0 || $menu{$key}->{HEIGHT} == 0)
    {
      $localfilename = $htmlpath . $menu{$key}->{BUTTON};
      if(!open(GIF,$localfilename))
      {
        warning("Can't open $localfilename, no autosize possible!");

        if($menu{$key}->{WIDTH} == 0)
        {
          $menu{$key}->{WIDTH} = "";
        }

        if($menu{$key}->{HEIGHT} == 0)
        {
          $menu{$key}->{HEIGHT} = "";
        }
      }
      else
      {
        if($giffile = newFromGif GD::Image(GIF))
        {
          ($file_width, $file_height) = GD::Image::getBounds($giffile);
          logmsg("  autosize returns for file $localfilename: width = $file_width, height = $file_height\n");

          if($menu{$key}->{WIDTH} == 0)
          {
            $menu{$key}->{WIDTH} = $file_width;
          }

          if($menu{$key}->{HEIGHT} == 0)
          {
            $menu{$key}->{HEIGHT} = $file_height;
          }
   
          close(GIF);
        }
        else
        {
          warning("$localfilename is not a GIF file, autosize not possible");
          if($menu{$key}->{WIDTH} == 0)
          {
            $menu{$key}->{WIDTH} = "";
          }

          if($menu{$key}->{HEIGHT} == 0)
          {
            $menu{$key}->{HEIGHT} = "";
          }
        }
      }
    }
  }

  # ----- checking the dummy gfx file -----
  if(!-e $set{DUMMY}) 
    { die "FATAL ERROR: dummy file $set{DUMMY} not found!"; }

}

sub menu_direction
# -----------------------------------------------------------------------------
# sub:		menu_direction
# task:		inserts a "<br>" in $menu if the menu is vertical
# author:	Jan Theofel
# last changed: 2000-02-14
# -----------------------------------------------------------------------------
{
  if(!$menuhorizontal)
  {
    $menu = $menu . "<br>";
  }
}

sub start_html
# ----------------------------------------------------------------------------
# sub:		start_html
# task:		creates the HTML header with doctype, head, meta tags, java-
#		script
# author:	Jan Theofel, jan@theofel.de
# last changed: 2000-02-14	
# ----------------------------------------------------------------------------
{

  # ----- create the html head with meta tags -----
  print OUT "<!DOCTYPE HTML PUBLIC \"-\/\/W3C\/\/DTD HTML $set{HTML}\/\/EN\">\n";
  print OUT "\n<HTML>\n\n<HEAD>\n";
  print OUT "  <TITLE>$set{TITLE}<\/TITLE>\n";

  foreach $key (keys %meta)
  {
    print OUT "  <META TYPE=\"$key\" CONTENT=\"".$meta{$key}."\">\n";
  }

  # ----- create the java script for the menu -----
  print OUT "  <SCRIPT LANGUAGE=\"JavaScript\">\n  <!--\n\n";

  &create_menu_gfx_entries;

  &create_add_gfx_entries;

  &create_add_javascriptcode;

  # ----- now print out the rest for the java script -----
  print OUT <<JAVASCRIPT;

  function ChangeGFX(gfxid,gfx)
  {
   window.document.images[gfxid].src = gfx.src;
  }
 //-->
  //-->
 </script>
</head>

JAVASCRIPT

  # ----- increase the gfx counter -----
  $count_gfx = $count_gfx + $set{ADD_COUNT_GFX};

}

sub include_dummy
# ----------------------------------------------------------------------------
# sub:          include_dummy 
# task:         includes the dummy html files and replaces the needed parts
# author:       Jan Theofel, jan@theofel.de
# last changed: 2000-02-18
# parameter:	1: name of the content file to include (for error msg)
# ----------------------------------------------------------------------------
{
  open(DUMMY,"<$set{DUMMY}");
  while(<DUMMY>)
  {
    if(/\<\!--menu--\>/i)
    {
      ($before,$after) = split(/\<\!--menu--\>/i);
      print OUT "$before$menu$after";
    }
    elsif(/\<\!--content--\>/i)
    {
      ($before,$after) = split(/\<\!--content--\>/i);
      @table_in_use = ();
      @font_in_use = ();
      print OUT $before;
      if($set{DEFAULT_FONT})
      {
        print OUT "$fonts{$set{DEFAULT_FONT}}->{START}\n";
        $active_font_name = $set{DEFAULT_FONT};
      }
      $content_line_count = 0;
      while(<CONTENT>)
      {
        $line = $_;
        $content_line_count++;

        # --------- count the number of images in one line ---------
        while($line=~/\<img/ig)
        {
          $count_gfx++;
        }

        # ---------- where do we have to insert images? ---------
        if($line=~/\<\!--img\:(\w*)--\>/i)
        {
          $imgname = uc($1);
          $foundimg = -1;
          for($count=0;$count<=$#defimages;$count+=2)
            { if($defimages[$count] eq $imgname) { $foundimg = $count; } }
          if($foundimg == -1)
          {
            warning("($filename, $content_line_count)\nImage '$imgname' not found in makefile!\n");
          }
          else
          {
            $foundimg++;
            $line=~s/\<\!--img\:$imgname--\>/$defimages[$foundimg]/i;
            $count_gfx++;
            logmsg("Image '$imgname' used in file $outfilename.\n");
          }
        }

        # --------- starting of some tables in this line? ---------
        if($line=~/\<\!--starttable\:(\w*)--\>/i)
        {
          $callername = $1;
          logmsg("  Using table definition $1 in file $outfilename\n");
          push(@table_in_use, $1);
          $active_table_name = $1;
          $tables{$active_table_name}->{COUNT}++;
          $table_tag = "<TABLE";
          foreach $key (keys %{$tables{$active_table_name}})
          {
             if($key ne "NAME" && $key ne "TDSTART" && $key ne "TDEND" && $key ne "FONT" && $key ne "COUNT")
             {
               $table_tag = $table_tag . " " . uc($key) . "=\"" . $tables{$active_table_name}->{$key} . "\"";
             }
          }
          $table_tag = $table_tag . ">";
          $line=~s/\<\!--starttable\:$callername--\>/$table_tag/i;
        }

	# --------- or does any table end? ---------
        if($line=~/\<\!--endtable\:(\w*)--\>/i)
        {
          $callername = $1;
          $line=~s/\<\!--endtable\:$callername--\>/\<\/TABLE\>/i;
          $ret = pop(@table_in_use);
          if($ret ne $callername)
          {
            if($ret eq "")
            {
              warning("($filename, $content_line_count)\nTable end found which has no start ('$callername')!\n");
            }
            else 
            {
              warning("($filename, $content_line_count)\nTable '$ret' ended by '$callername'!\n");
            }
          }
          $warned_table_miss_surrounding_font = 0;
          
        }

        # --------- are we in a defined table? ---------
        if($#table_in_use!=-1)
        {
          if($line=~/\<[tT][dD]([^\>]*)\>/i)
          {
            $td_tag = "<TD$1";
            $td_tag = $td_tag . ">";
            $replace_tag = $td_tag . $tables{$active_table_name}->{TDSTART};
            if($tables{$active_table_name}->{FONT} ne "")
            {
              if(uc($tables{$active_table_name}->{FONT}) eq "AUTO")
              {
                if($active_font_name ne "")
                {
                  $replace_tag = $replace_tag . $fonts{$active_font_name}->{START};
                }
                else
                {
                  if(!$warned_table_miss_surrounding_font)
                  {
                    $warned_table_miss_surrounding_font = 1;
                    warning("($filename, $content_line_count)\nTable '$active_table_name' requests surrounding font which is not given.\nUse deffont to declare one!");
                  }
                }
              }
              else
              {
                $replace_tag = $replace_tag . $fonts{$tables{$active_table_name}->{FONT}}->{START};
              }
            }
            $line =~ s/\<td[^\>]*\>/$replace_tag/;
          }
          if($line=~/\<\/td\>/i)
          {
            $replace_tag = $tables{$active_table_name}->{TDEND};
            if($tables{$active_table_name}->{FONT} ne "")
            {
              if(uc($tables{$active_table_name}->{FONT}) eq "AUTO")
              {
                if($#font_in_use ne -1)
                {
                  $replace_tag = $replace_tag . $fonts{$active_font_name}->{END};
                }
              }
              else
              {
                $replace_tag = $replace_tag . $fonts{$tables{$active_table_name}->{FONT}}->{END};
              }
            }
            $line =~ s/\<\/td\>/$replace_tag<\/TD\>/;
          }
        }

	# --------- search and replace font starts ---------
        if($line=~/\<\!--startfont\:(\w*)--\>/i)
        {
          logmsg("Using font definition $1 in file $outfilename\n");
          push(@font_in_use, $1);
          $active_font_name = $1;
          $font_found = 0;
          foreach $key (keys %fonts)
          {
            if($key eq $active_font_name)
            {
              $replace_tag = $fonts{$key}->{START}; 
              $line=~s/\<\!--startfont\:$active_font_name--\>/$replace_tag/i;
              $font_found = 1;
              last;
            }
          }
          if($font_found == 0)
          {
            warning("($filename, $content_line_count)\nFont $active_font_name not found in makefiles!");
          }
          else
          {
            $fonts{$active_font_name}->{COUNT}++;
          }          
        }

        # ---------- find ending of fonts in the line ---------
        if($line=~/\<\!--endfont\:(\w*)--\>/i) 
        {
          $ret = pop(@font_in_use);
          $font_name = $1;
          if($ret ne $font_name)
          {
            if($ret eq "")
            {
              warning("($filename, $content_line_count)\nFont end found which has no start ('$font_name')!\n");
            }
            else
            {
              warning("($filename, $content_line_count)\nFont '$ret' ended by '$font_name'\"!\n");
            }
          }

          # can be extremly optimized!!!!
          foreach $key (keys %fonts)
          {
            if($key eq $active_font_name)
            {
              $replace_tag = $fonts{$key}->{END};
              $line=~s/\<\!--endfont\:$ret--\>/$replace_tag/i;
              last;
            }
          }

          # --- restore active_font_name for use in tables ---
          if($#font_in_use ne -1)
          {
            $active_font_name = pop(@font_in_use);
            push(@font_in_use, $active_font_name);
          }
          else
          {
            $active_font_name = $set{DEFAULT_FONT};
          }
        }

        # --------- replace highlighted elements in the lines ---------
        if($line=~/\<\!--highlight\:([\w,]*)--\>/i)
        {
          ($highlight_gfx,$normal_gfx) = split(/,/,$1);
          $highlightcommand = " onMouseOver=\"ChangeGFX($count_gfx,$normal_gfx);\" onMouseOut=\"ChangeGFX($count_gfx,$highlight_gfx);\"";
          $line=~s/\<\!--highlight\:([\w,]*)--\>/$highlightcommand/i;
        }

	# --------- find and create image maps in the file ---------
        if($line=~/\<\!--imagemap\:(\w*)--\>/i)
        {
          $imagemapname = $1;
          if($imagemapdef{$imagemapname} eq undef)
            { die "FATAL ERROR: Imagemap $imagemapname undefined!\n"; }
          $line=~s/\<\!--imagemap\:$imagemapname--\>/ ismap usemap=\"\#$imagemapname\" /i;
          $line = $line . $imagemapdef{$imagemapname};
        }
        print OUT $line;
      }
      print OUT $after;
      if($set{DEFAULT_FONT})
      {
        print OUT "$fonts{$set{DEFAULT_FONT}}->{END}\n";
      }
    }
    else
    {
      print OUT;
    }
  }
  close(CONTENT)||die("FATAL ERROR: Can't close content file $content");
  close(OUT)||die("FATAL ERROR: Can't close outfile $filename");

  # ----- check for unclosed fonts
  if ($#font_in_use ne -1)
  {
    warning("$contentfile (eof): Unclosed font(s) " . join(" ", @font_in_use));
  }

  # ----- check for unclosed tables 
  if ($#table_in_use ne -1)
  {
    warning("$contentfile (eof): Unclosed table(s) " . join(" ", @table_in_use));
  }
}

sub create_menu
# ----------------------------------------------------------------------------
# sub:		create_menu
# task:		creates the clickable menu depending on the file which is
#		actually created
# author:	Jan Theofel, jan@theofel.de
# last changed:	2000-02-15
# parameters:	1: actual menu item id
# ----------------------------------------------------------------------------
{

  foreach $key (keys %menu)
  {
#    print "DEBUG: $menu{$key}->{ID} eq $_[0]\n";

    if($menu{$key}->{ID} eq $_[0])
    {
      $menu = $menu . "<IMG SRC=\"$menu{$key}->{BUTTON_HL2}\" BORDER=\"0\" ALT=\"$menu{$key}->{ALTTEXT}\" WIDTH=\"$menu{$key}->{WIDTH}\" HEIGHT=\"$menu{$key}->{HEIGHT}\">";
      $count_gfx++;
      &menu_direction;
    }
    else
    {
      $menu = $menu . "<A HREF=\"$key\" onMouseOver=\"ChangeGFX($count_gfx,menuitem$menu{$key}->{ID}_hl);\" onMouseOut=\"ChangeGFX($count_gfx,menuitem$menu{$key}->{ID});\"><img src=\"$menu{$key}->{BUTTON}\" BORDER=\"0\" ALT=\"$menu{$key}->{ALTTEXT}\" WIDTH=\"$menu{$key}->{WIDTH}\" HEIGHT=\"$menu{$key}->{HEIGHT}\"><\/A>";
      $count_gfx++;
      &menu_direction;
    }
    $menu = $menu . "<IMG SRC=\"$set{GFXDUMMY}\" ALT=\"\"";
    if(!($dummy_width == 0))
      { $menu = $menu . "WIDTH=\"$dummy_width\""; }
    if(!($dummy_height == 0))
      {  $menu = $menu . " HEIGHT=\"$dummy_height\""; }
    $menu = $menu .  ">";
    &menu_direction;
    $count_gfx++;
  }
}

sub prepare_logfile
# ----------------------------------------------------------------------------
# sub:          prepare_logfile
# task:         opens the logfile and checks for success 
# author:       Jan Theofel, jan@theofel.de
# last changed: 1999-11-02
# ----------------------------------------------------------------------------
{
  if(open(LOG,">homepage.log")!=0)
  {
    $logging = 1; 
    print LOG "logfile created the ... by:\n\n";
    print LOG "  $identify\n\n";
    print LOG "THIS PROGRAM IS PUBLISHED UNDER THE TERMS OF THE GNU GENERAL PUBLIC LICNESE.\n";
    print LOG "IT COMES WITH ABSOLUTLY NO WARRENTY. USE IT AT YOUR OWN RISK!\n\n";
  }
  else
  {
    $logging = 0;
    $warnings++;
    print("WARNING: Can't open logfile - logging goes only to stdout.\n\n");
    # can't use 'warning' here as it wants to log
  }
}

sub msg 
# ----------------------------------------------------------------------------
# sub:          msg 
# task:         prints a string to the logfile and to STDOUT
# author:       Jan Theofel, jan@theofel.de
# last changed: 1999-11-02
# ----------------------------------------------------------------------------
{
  if($#_ == -1) { return; }
  if($logging) { print LOG $_[0]; }
  print $_[0];
}

sub logmsg
# ----------------------------------------------------------------------------
# sub:          logmsg
# task:         prints a string only to the logfile
# author:       Jan Theofel, jan@theofel.de
# last changed: 2000-02-17
# ----------------------------------------------------------------------------
{
  if($#_ == -1) { return; }
  @lines = @_;
  foreach $key (@lines)
  {
    if($lines[$key] !~ /^.*\n$/)
    {
      $lines[$key] = $lines[$key] . "\n";
    }  
  }
  $logmsg = join("",@lines);
  if($logging) { print LOG $logmsg; }
}


sub warning
# ----------------------------------------------------------------------------
# sub:          warning
# task:         prints a string as warning
# author:       Jan Theofel, jan@theofel.de
# last changed: 2000-02-17 
# ----------------------------------------------------------------------------
{
  $warnings++;
  $warn = $_[0];
  if($warn =~ /^(.*)\n$/)
  {
    $warn = $1;
  }  
  $warn =~ s/\n/\n         /g;
  msg("WARNING: $warn\n");
}

__END__
