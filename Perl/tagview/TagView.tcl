#!/bin/sh
# the next line restarts using wish \
exec wish "$0" "$@"
##########################################################################
# Developer : Binny V A                                                  #
# Website   : http://www.geocities.com/binnyva                           #
# E-Mail    : binnyva@rediffmail.com                                     #
# Get more Tcl/Tk scripts from http://www.geocities.com/binnyva/code/tcl #
##########################################################################
# Name         : TagView                                                 #
# Version      : 2.01.A                                                  #
# Started Date : September 29, 2004                                      #
# Description  :                                                         #
# Give a Tcl/Tk file as the command line argument and this script will   #
#	find all the functions in it and display the function and the line no#
#	If any function is double-clicked, it will be opened in an external  #
#	editor - In this case Crimson Editor/Vi(by default)                  #
#                                                                        #
# Get more Tcl/Tk scripts from http://www.geocities.com/binnyva/code/tcl #
##########################################################################

########################## Global Variables ##############################
#Program Information
array set program {
	name		"TagView"
	version		"2.01.A"
	author		"Binny V Abraham"
	email		"binnyva@hotmail.com"
	website		"http://www.geocites.com/binnyva"
}
#Options
array set opt {
	func_width		17
	line_width		4
	show_comments	0
}

## Editor Specification
if { $tcl_platform(platform) == "windows" } {
	#The Program to be executed. Change this to whatever you wish.
	array set exe {
		program "\"C:/Program Files/Office/Text Editors/Crimson Editor/cedt.exe\""
		argument1 "/L:%LINE%"
		argument2 "%FILE%"
	}
} elseif { $tcl_platform(platform) == "unix" } {
	#For Vi
	array set exe {
		program "vi"
		argument1 "%FILE%"
		argument2 "\+%LINE%"
	}
} else {
	tk_messageBox -message "$tcl_platform(platform) not yet supported. You won't be able to open the files from within the program"
}

set file_path ""

#Open the file in the specified editor at the correct line number
proc showSub {} {
	global file_path exe

	#Get the index number of the double-clicked function and get that line
	set sel [.functions curselection]
	set line [.functions get $sel]
	#Get the line number
	regexp { ?[\w\.]+\s*(\d+)} $line full line_no
	
	regsub -all {/} $file_path {\\\\\\} file_path
	
	regsub {%LINE%} $exe(argument1) "$line_no" exe(argument1)
	regsub {%FILE%} $exe(argument1) "$file_path" exe(argument1)
	regsub {%LINE%} $exe(argument2) "$line_no" exe(argument2)
	regsub {%FILE%} $exe(argument2) "$file_path" exe(argument2)
	
	eval exec $exe(program) "$exe(argument1)" $exe(argument2) "&"
	.file_path delete 0 end
	.file_path insert end "$exe(program) $exe(argument1) $exe(argument2)"
	exit
}

#This function will open a file, scan for procedures and will list them.
proc init {} {
	global file_path opt

	#Check file validity
	if { ![file exist $file_path] } {
		tk_messageBox -message "The specified file\($file_path\) does not exist.\nProgram will now terminate." -icon error
		exit 2
	}
	
	#Open the file
	set IN_FILE [open $file_path r]
	set contents [read $IN_FILE]
	close $IN_FILE
	#Get Contents
	set lines [split $contents "\n"]
	.lines configure -text "[llength $lines]"
	
	#Find the language
	set ext [file extension $file_path]
	if { $ext == ".tcl" || $ext == ".tk" } {
		set re_nuller	{^\s*[\#p].*}
		set re_label	{^[\s]*#{2,5} ([^\#]+)}
		set re_section	{\#{5,} ?([^\#]+) ?\#{5,}}
		set re_comment	{^[\s]+\#([^\#].*)}
		set re_new_com	{^\s+\#\s*(.*)}
		set re_function	{proc ([^\{]+) \{[^\}]*\}}
		set re_com_desc {^\s*#(.*)}
		set re_fun_desc {^[\s\#]*(.*)}
		
		.lang config -text "Tcl/Tk"
	} elseif { $ext == ".pl" || $ext == ".cgi" } {
		set re_nuller	{^\s*[\#s].*}
		set re_label	{^[\s]*#{2,5} ([^\#]+)}
		set re_section	{\#{5,} ?([^\#]+) ?\#{5,}}
		set re_comment	{^[\s]*\#([^\#].*)}
		set re_new_com	{^\s+\#\s*(.*)}
		set re_function	{sub ([^\{]+)}
		set re_com_desc {^\s*#(.*)}
		set re_fun_desc {^[\s\#]*(.*)}
		
		.lang config -text "Perl"
	} elseif { $ext == ".cpp" || $ext == ".c" || $ext == ".h" } {
		set re_nuller	{^\s*[\/vicf].*}
		set re_label	{^[\s]*//// (.+)}
		set re_section	{/\*{5,} ?([^/\*]+) ?\*{5,}/}
		set re_comment	{^[\s]+//([^/].*)}
		set re_new_com	{^\s+//\s*(.*)}
		set re_function	{^(?:void|int|char|float) ([^\{\( ]+)\(}
		set re_com_desc {^\s*/[/\*]*([^\*]*)}
		set re_fun_desc {^[\s/]*(.*)}
		
		if { $ext == ".c" } {
			.lang config -text "C"
		} else {
			.lang config -text "C++"
		}
	} else {
		tk_messageBox -message "Unidentified Language\($ext\). Program Terminated." -icon error
		exit 2
	}

	for { set i 0 } { $i < [llength $lines] } { incr i } {
		#Initializations
		set line [lindex $lines $i]
		set desc ""
		set desc_flag 1
		set name "-"

		#If any line dont match $re_nuller, it wont check other REs. This avoids check all lines - major optimizer.
		if { ![regexp $re_nuller $line full] } {
		} elseif { [regexp $re_label $line full label] } {
			#...We have a Label
			
			set new_label [spacer $label $opt(func_width)]
			set new_i [spacer [expr {$i + 1}] $opt(line_width)]

			.functions insert end " $new_label$new_i __$label\__"
			.functions itemconfigure end -foreground blue ;#Gives labels blue color

		} elseif { [regexp $re_section $line full section] } {
			#...We have a Section Divider

			set new_section [spacer $section $opt(func_width)]
			set new_i [spacer [expr {$i + 1}] $opt(line_width)]

			.functions insert end " $new_section$new_i ... $section ..."
			.functions itemconfigure end -foreground red ;#Gives section dividers red color

		} elseif { [regexp $re_comment $line full comment] && $opt(show_comments) }  {
			#...We Got a comment
			set comment_flag 1
			set j $i
			
			#Get all the comments immidately after current comment
			while { $comment_flag } {
				set j [expr {$j + 1}]
				set new_comment [lindex $lines $j]

				if { [regexp $re_new_com $new_comment full new_comment] } {
					set comment "$comment $new_comment"
					set i $j
				} else {
					set comment_flag 0
				}
			}
			set new_comment [spacer "Comment" $opt(func_width)]
			set new_i [spacer [expr {$i + 1}] $opt(line_width)]
			
			.functions insert end " $new_comment$new_i $comment"
			.functions itemconfigure end -foreground {#008000} ;#Gives comment green color

		} elseif { [regexp $re_function $line full name] } {
			#...We got a procedure

			#We will try to find the description of the procedure. It is usally found
			#	just before the 'proc' line.
			set j $i
			while { $desc_flag } {
				set j [expr {$j - 1}]
				set desc_line [lindex $lines $j]
				if { [regexp $re_com_desc $desc_line full new_desc] } {
					regexp $re_fun_desc $new_desc full new_desc
					#Some things that should be ignored.
					if { ![regexp {Function *: *} $new_desc] &&
						 ![regexp {Procedure *: *} $new_desc] &&
						 ![regexp {Argument *: *} $new_desc] &&
						 ![regexp {Arguments *: *} $new_desc] &&
						 ![regexp {Return *: *} $new_desc] &&
						 ![regexp {Returns *: *} $new_desc] &&
						 ![regexp {\w+ ?\#{10,}} $new_desc] &&
						 ![regexp {^:? ?\w+ +- +} $new_desc] } {
							 #The last two lines are Binny Specifiec. First Use...
							 #For preventing taking of Section dividers. Second Use...
							 #Argument : one - Use
							 #			 two - Another Use.
							 #The regexp will delete the second line.

						set desc "$new_desc $desc" ;#'append desc "$new_desc"' causes the result to be upside-down
					}
				} else {
					set desc_flag 0
				}
			}

			set new_name [spacer $name $opt(func_width)]
			set new_i [spacer [expr {$i + 1}] $opt(line_width)]

			#If there is no description
			if { $desc == "" } {
				set desc " - "
			}

			.functions insert end " $new_name$new_i $desc"
		}
	}
}

#Refresh the fields - Ussualy after enabling the "Show Comments" field.
proc refresh { } {
	global opt
	.functions delete 0 end
	init
}

#Fits the text with needed spaces at the end and return it.
proc spacer { txt width } {
	set txt_width [string length $txt]
	set new_txt "$txt"
	#If the width of function txt is more than wanted, turnicate it.
	if { $txt_width > $width } {
		regexp "(.{[expr $width - 3]}).*" $txt full new_txt
		set new_txt "$new_txt.. "
	#If it is less, full the rest space with spaces
	} else {
		set spaces [expr $width - $txt_width]
		set new_txt "$new_txt[string repeat { } $spaces]"
	}
	return $new_txt
}

################################### GUI Building #########################################
set editing "-Adobe-Courier-*-R-Normal--*-120-*-*-*-*-*-*"

frame .frm_labels
label .lab_func -text "Functions" -width [expr {$opt(func_width) + 2}]
label .lab_line -text "Line #" -width $opt(line_width)
label .lab_desc -text "Description"
checkbutton .chk_comment -text "Show Comments" -variable opt(show_comments) \
	-command { refresh }
pack .lab_func -in .frm_labels -side left -fill x
pack .lab_line -in .frm_labels -side left -fill x
pack .lab_desc -in .frm_labels -side left -fill x -expand 1
pack .chk_comment -in .frm_labels -side right
pack .frm_labels -fill x

#The Functions Area (SubRotuines)
frame .frm_subs -relief ridge -bd 2
listbox .functions -bd 0 -font $editing -bg white \
	-yscrollcommand ".srl_subs_y set" -xscrollcommand ".srl_subs_x set"
bind .functions <Double-ButtonPress-1> { showSub }

scrollbar .srl_subs_y -command ".functions yview" -orient v
scrollbar .srl_subs_x -command ".functions xview" -orient h
label .lab_spacer -text "   "

pack .functions  -in .frm_subs -side left -fill both -expand 1
pack .srl_subs_y -in .frm_subs -fill y -expand 1
pack .frm_subs -fill both -expand 1
pack .lab_spacer -side right
pack .srl_subs_x -fill x -side top

#File Information
frame .frm_file
label .lang  -bd 1 -relief sunken -text "" -width 15
label .lines -bd 1 -relief sunken -text "0" -width 5
entry .file_path -width 50
pack .file_path -in .frm_file -side left -padx 1
pack .lines -in .frm_file -side right -padx 1
pack .lang  -in .frm_file -side right -padx 1
pack .frm_file -fill x

# Getting the file name to open from the command line.
if { [lindex $argv 0] != "" } {
	set file_path [lindex $argv 0]
	set title [file rootname $file_path]
	set title [file tail $title]
	wm title . "$program(name) V$program(version) - $title"
	
	.file_path insert end $file_path
	init
} else {
	wm title . "$program(name) V$program(version)"

	tk_messageBox -message "Please provide a file as the argument.\nUsage $argv0 <FILE>\nTagView will now terminate."
# 	set file_path "D:/Scripts/Tcl/Under Constuction/GaF Replacer/gui.tcl"
# 	set file_path "D:/Scripts/Perl/RecAn.pl"
# 	set file_path "D:/Documents/Cprs/Programs/Batch ToolKit/Tnd.cpp"
# 	init
	exit
}

bind . <Key-Escape> {exit}
focus .

################################### Regognizes ########################################
#1. proc whatever { Arguments } { - Function
#2. #.... - Comment
#3. ## .... - Label
#4. ###################################  Section Divider  #############################

###################################  History  #########################################
# 1.00.A - September 29, 2004
# First Release
# 
# 2.00.A - December 17, 2004 
# Added support for more languages like Perl, C++, C
# Optimized the code to run a little faster.
# Added support for Unix platform
# Added support for Vi Editor
# Can see comments
#
# 2.00.B - February 02, 2005 
# Listbox background colour becomes white - not default
#
# 2.01.A - February 10, 2005 
# Exterminated the Resizing bug.

###################################  To Do  ###########################################
# Optimize Code. Make items in lists
# Arrange the functions in alphabetical order by option