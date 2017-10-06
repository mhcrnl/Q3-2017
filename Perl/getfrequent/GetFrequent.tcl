#!/bin/sh
# the next line restarts using wish \
exec wish "$0" "$@"
##########################################################################
# Developer : Binny V A                                                  #
# Website   : http://www.geocities.com/binnyva                           #
# E-Mail    : binnyva@rediffmail.com                                     #
# Get more Tcl/Tk scripts from http://www.geocities.com/binnyva/code/tcl #
##########################################################################
# Name         : GetFrequent                                             #
# Version      : 1.04.C                                                  #
# Started Date : October 18, 2004 to November 13, 2004                   #
# Description  :                                                         #
#		Download a given list of URLs from the net and store it in a     #
# given folder.                                                          #
#                                                                        #
#                                                                        #
# Get more Tcl/Tk scripts from http://www.geocities.com/binnyva/code/tcl #
##########################################################################

############################ Global Variables ############################
#Program Information
array set program {
	name			"GetFrequent"
	author			"Binny V Abraham"
	version			"1.04.C"
	email			"binnyva@hotmail.com"
	website			"http://www.geocites.com/binnyva"
}

array set opt {
	auto_start		0
	auto_exit		1
	save_folder 	"Downloaded"
	opt_file		"gf.opt"
}
set home_folder "[file dirname $argv0]"

package require http

#Download all the urls from the net
proc download { } {
	global opt home_folder program

	set folder [file join $home_folder $opt(save_folder)]
	set files [.files get 0 end]
	set names [.names get 0 end]
	for { set i 0 } { $i < [llength $files] } { incr i } {
		set url [lindex $files $i]
		set name [lindex $names $i]

 		set result [fetchUrl "$url" "[file join $home_folder $opt(save_folder) $name]" $i] ;# Have to remove $home_folder
 		if { $result == "NoNet" } { 
	 		#If there is no internet connection, continue no further. Else app will crash.
	 		tk_messageBox -message "Internet Connection not found." -icon error
	 		set i [llength $files]
	 		break
	 	}
	}
	#See if all files are downloaded
	if { $result == "Good" } {
		if { $opt(auto_exit) } {
			exiter
		} else {
			wm title . "$program(name) $program(version) - Finished"
		}
	}
}

#Get the given url from the net and return contents
proc fetchUrl { url file_path index } {
    set html ""
    set err ""
    set result "Good"
    
    #Feedback
    .per delete $index
	.per insert $index "Downloading..."
	.per itemconfigure $index -foreground blue

    set OUT [open "$file_path" w]
    seek $OUT 0

    if { ![catch { set token [http::geturl $url -timeout 30000 -channel $OUT] } res] } {
	    #"OK" will be there only if url is valid
	    if { [string equal [http::status $token] "ok"] } {
	        if {[http::ncode $token] >= 500} {
	            set err "Server Error: [http::code $token]"
	        } elseif { [http::ncode $token] >= 400 } {
	            set err "Authentication Error: [http::code $token]"
	        } elseif { [http::ncode $token] >= 300 } {
	            upvar \#0 $token state
	            array set meta $state(meta)
	            if {[info exists meta(Location)]} {
	                return [fetchUrl $meta(Location) $file_path $index]
	            } else {
	                set err [http::code $token]
	            }
	        }
	    } else {
		    set err [http::error $token]
	    }
	    http::cleanup $token
    } else {
		set err "$res"
    }
    close $OUT

    if { [string length $err] > 0 } {
	    #Show Error - If any
 	    if { [string match $err "couldn't open socket: invalid argument"] } {
	 	    set result "NoNet"
 		}
        .msg insert 1.0 "$err - In $url\n"
        .msg tag add "error" 1.0 1.end
        .msg tag configure "error" -foreground red
    } else {
	    .per delete $index
		.per insert $index "Finished"
		.per itemconfigure $index -foreground darkgreen 
	    #Give the message that the download is finished
	    .msg insert 1.0 "Downloaded $url and saved to $file_path\n"
        .msg tag add "over" 1.0 1.end
        .msg tag configure "over" -foreground darkgreen
    }
    return $result
}

#Shows the progress of the download - Unwanted - very small files are downloaded. 
#	For this to work, add  "-progress progress" in url fetching code.
proc progress { token total current } {
	regsub "::http::" $token full no
	set no [expr {$n - 1}]

	set percent 0
	if { $total != 0 } {
		set percent [expr {($current/$total)*100}]
	}
}

#Add a new url to the to-be-downloaded list
proc add { } {
	set url [.new get]

	#See if there is a copy of the same url in the list - if not, insert it
	if {[lsearch -exact [.files get 0 end] $url] == -1} {
		.files insert end $url
		set name [getName $url]
		.names insert end "$name"
		.per insert end "To Download"
		.new delete 0 end
	}
}

#Happens when the software is closed
proc exiter { } {
	global home_folder opt

	set files [.files get 0 end]
	set names [.names get 0 end]
	set urls ""
	
	for { set i 0 } { $i < [llength $files] } { incr i } {
		set fil [lindex $files $i]
		set name [lindex $names $i]
		if { $fil != "" && $name != "" } {
			set urls [linsert $urls end "$fil x@x $name"]
		} elseif { $fil != "" } {
			set urls [linsert $urls end "$fil"]
		}
	}
	set urls [join $urls "\n"]
	set opt_file [file join $home_folder "$opt(opt_file)"]

	#Write it to file
	set OPT [open "$opt_file" w]
 	puts $OPT "$urls"
	close $OPT

	exit
}

#Happens at first - Loads all the urls to be downloaded
proc init { } {
	global home_folder opt

	set opt_file [file join $home_folder "$opt(opt_file)"]
	#Get the urls
	set OPT [open "$opt_file" r]
	set buffer [read $OPT]
	close $OPT
	
	set lines [split $buffer "\n"]
	foreach line $lines {
		if { $line != "" } {
			.per   insert end "To Download"
			if { [regexp "(.+) x@x (.+)" $line full url name] } {
				.files insert end "$url"
				.names insert end "$name"
			} else {
				.files insert end "$line"
				set name [getName $line]
				.names insert end "$name"
			}
		}
	}
	if { $opt(auto_start) } { 
		download
	}
}

#Edit the selected url
proc edit { path title } {
	set sel [$path  curselection]
	set url [$path get $sel]
	if { $url != "" } {
		toplevel .edt
		label .edt.lab -text "$title" -font "ansi 12 bold"
		entry .edt.url -width 100
		.edt.url insert end $url
		button .edt.cancel -text "Cancel" -command { destroy .edt }
		button .edt.ok     -text "  OK  " -command "getEdited $sel $path"
		pack .edt.lab .edt.url -pady 3
		pack .edt.ok -side right
		pack .edt.cancel -side right -padx 5 -pady 3
		wm title .edt "$title"
		
		bind .edt <Key-Return> "getEdited $sel $path"
		bind .edt <Key-Escape> { destroy .edt }
	}
}
#Get the edited url from the toplevel
proc getEdited { sel path } {
	$path delete $sel
	$path insert $sel [.edt.url get]
	destroy .edt
}

#Resolve a name from a given url
proc getName { line } {
	set all_names [split $line ";?/\\=+"]
	set name "[lindex $all_names [expr [llength $all_names] - 1]]"
	#Make sure there is a name		
	set temp 2
	while { $name == "" && $temp < 10 } {
		set name "[lindex $all_names [expr [llength $all_names] - $temp]]"
		set temp [expr $temp + 1]
	}
	if { [file extension $name] == "" } { set name "$name.htm" }
	return $name
}

#Open a browser with the given url
proc visit { } {
	set path ".files"
	set sel [$path  curselection]
	set url [$path get $sel]
	if { $url != "" } {
		launchBrowser $url
	}
}

#Launch the browser no matter what OS the user is having
proc launchBrowser { url } {
	global tcl_platform
	
	set flag 0
	# It *is* generally a mistake to switch on $tcl_platform(os), particularly
	# in comparison to $tcl_platform(platform).  For now, let's just regard it
	# as a stylistic variation subject to debate.
	switch $tcl_platform(os) {
		Darwin {
			set command [list open $url]
			}
		HP-UX -
		Linux  -
		SunOS {
			foreach executable {mozilla netscape iexplorer opera lynx
					w3m links galeon konquerer mosaic firefox amaya
					browsex elinks} {
				set executable [auto_execok $executable]
				if [string length $executable] {
					# Do you want to mess with -remote?  How about other browsers?
					set command [list $executable $url &]
					break
				}
			}
		}
		{Windows 95} -
		{Windows NT} {
			exec "rundll32" "url.dll,FileProtocolHandler" "$url" &
			set flag 1
			#set command "rundll32 url.dll,FileProtocolHandler $url &"
			#set command "[auto_execok start] {} [list $url]"
		}
	}

	if { !$flag } {
		if { [info exists command] } {
			if [catch {exec {expand}$command} err] {
				tk_messageBox -icon error -message "Error '$err' with '$command'"
			}
		} else {
			tk_messageBox -icon error -message \
				"($tcl_platform(os), $tcl_platform(platform)) is not yet ready for browsing."
		}
	}
}

#Scroll the three listboxes simultaniously
proc syncScroll { args } {
	eval .files yview $args
	eval .names yview $args
	eval .per yview $args
}

#Posts a menu at right-click
proc listboxRC { path menu_id } {
	#Get the position of the mouse
	set x [winfo pointerx .]
	set y [winfo pointery .]
	#Active the item which is right clicked
	set winy [expr [winfo pointery $path] - [winfo rooty $path]]
	set index [$path nearest $winy]
	$path selection clear 0 end
	$path selection set $index
	#Put the menu there.
	$menu_id post $x $y
}
proc listboxRC:delete { path } {
	set sels [$path curselection]
	for { set i 0 } { $i<[llength $sels] } { incr i } {
		set to_del [lindex $sels $i]
		#When an element is deleted, the index of all elements below it will decrease by 1
		#	So no of elements deleted must be subtacted from element index
		set to_del [expr $to_del - $i]
		$path delete $to_del
		
		#Delete the name and percentage also
		.names delete $to_del
		.per delete $to_del
	}
}
proc listboxRC:empty { path } {
	set sels [$path curselection]
	$path delete $sels
	$path insert $sels ""
}
proc listboxRC:selectAll { path } {
	$path selection set 0 end
}
proc listboxRC:moveUp { path } {
	set sel [$path curselection]
	#Get the content of the selection, Delete it, and move it to top 
	#	and then select it - one by one
	#Up and down need 2 diffrent for loops because else, when the down command is given,
	#	only the first element will be moved because its index will keep changing
	for {set i 0} {$i<[llength $sel]} {incr i} {
		set no [lindex $sel $i]
		set item [$path get $no]
		set item2 [.names get $no]
		set move [expr $no - 1]
		$path delete $no		
		$path insert $move $item
		$path selection set $move
		.names delete $no
		.names insert $move $item2
	}
}
proc listboxRC:moveDown { path } {
	set sel [$path curselection]
	for {set i [expr [llength $sel] - 1]} {$i>=0} {set i [expr $i - 1]} {
		set no [lindex $sel $i]
		set item [$path get $no]
		set item2 [.names get $no]
		set move [expr $no + 1]	
		$path delete $no
		$path insert $move $item
		$path selection set $move
		.names delete $no
		.names insert $move $item2
	}
}


############################# GUI Building ################################

label .head -text "$program(name) $program(version)" -font "ansi 12 bold"
pack .head

## Url List Area
frame .frm_files
listbox .files -font "ansi 10" -activestyle dotbox -yscrollcommand ".slb_y set"
listbox .names -font "ansi 10" -width 15
listbox .per   -font "ansi 10" -width 10
scrollbar .slb_y -orient v -command { syncScroll }
pack .files -in .frm_files -side left -fill both -expand 1
pack .names -in .frm_files -fill y -side left
pack .per   -in .frm_files -fill y -side left
pack .slb_y -in .frm_files -fill y -side right 
pack .frm_files -fill both -expand 1

## Url Right Click Menu
set mn [menu .urls_mnu -tearoff 0]
$mn add command -label "Edit Url" -underline 0 -command { edit ".files" "Edit URL" }
$mn add command -label "Delete Url" -underline 0 -command { listboxRC:delete .files }
$mn add separator
$mn add command -label "Visit Url" -underline 0 -command { visit }
$mn add separator
$mn add command -label "Move Up" -underline 5 -command { listboxRC:moveUp .files }
$mn add command -label "Move Down" -underline 5 -command { listboxRC:moveDown .files }
bind .files <ButtonPress-3> "listboxRC .files $mn"

## Names Right Click Menu
set mnu [menu .names_mnu -tearoff 0]
$mnu add command -label "Edit Name" -underline 0 -command { edit ".names" "Edit File name" }
$mnu add command -label "Delete Name" -underline 0 -command { listboxRC:empty .names }
bind .names <ButtonPress-3> "listboxRC .names $mnu"

## Commands
frame .frm_com -relief raised -bd 1
button .frm_com.but_about -text "About" -command { tk_messageBox -title "About $program(name)" -message \
"$program(name) V $program(version)

by Binny V Abraham

$program(email)
$program(website)" }
button .frm_com.but_down -text "Start Downloading" -command { download } -font "ansi 10 bold"
button .frm_com.but_visit -text "My Site" -command { launchBrowser "$program(website)" }
pack .frm_com.but_about .frm_com.but_down .frm_com.but_visit -pady 3 -padx 15 -side left 
pack .frm_com -ipadx 5 -pady 2


## Addition
frame .frm_adder
entry .new -font "ansi 10"
bind .new <Key-Return> { add }
button .but_add -text "Add new File" -command { add }
pack .new     -in .frm_adder -side left -expand 1 -fill x
pack .but_add -in .frm_adder -side right
pack .frm_adder -fill x

## Console
frame .frm_con
text .msg -wrap word -yscrollcommand ".srl_msg_y set" -height 5
scrollbar .srl_msg_y -command ".msg yview" -orient v
pack .msg       -in .frm_con -side left -fill both -expand 1
pack .srl_msg_y -in .frm_con -fill y -expand 1
pack .frm_con -fill both -expand 1

focus .new
bind . <Key-Escape> { exiter }
#bind . <Key-Space> { download }
wm protocol . WM_DELETE_WINDOW { exiter }
wm title . "$program(name) $program(version)"

init

############################### History ###############################
# 1.00.A
# First version
#
# 1.04.A - Will automatically exit after downloads
# 1.04.B - Shows what is currently downloaded - better feedback.
# 1.04.C - Added the 'About button' and 'Visit my Site' button
#		 - Program Published

############################### To Do ###############################
# Mutiple downloads at the same time



