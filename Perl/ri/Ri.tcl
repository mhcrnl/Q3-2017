#!/bin/sh
# the next line restarts using wish \
exec wish "$0" "$@"
##########################################################################
# Developer : Binny V A                                                  #
# Website   : http://www.geocities.com/binnyva                           #
# E-Mail    : binnyva@hotmail.com                                        #
# Get more Tcl/Tk scripts from http://www.geocities.com/binnyva/code/tcl #
##########################################################################
# Name         : RI (RunInterpreter)                                     #
# Version      : 2.00.A                                                  #
# Started Date : October 16,17 2004                                      #
# Description  :                                                         #
# 	Load the file given at command line and using its extention to       #
#		recognize the language, runs its interpreter and displays the    #
# 		output in the text window.                                       #
#                                                                        #
# Get more Tcl/Tk scripts from http://www.geocities.com/binnyva/code/tcl #
##########################################################################

############################ Global Variables ############################
#Program Information
array set program {
	name			"RI"
	name_base		"RI"
	author			"Binny V Abraham"
	version			"2.00.A"
	email			"binnyva@hotmail.com"
	website			"http://www.geocites.com/binnyva"
}
#Details needed for the script
array set script {
	path 			""
	name			""
	home			""
	lang			""
	index			-1
	letter			""
	lang_modified	0
}
set script(home) "[file dirname $argv0]"

#Colour Options
array set colours {
	error_back		"red"
	error_fore		"yellow"
	headline_fore	"blue"
	headline_back	"white"
	err_head_fore	"red"
	err_head_back	"white"
}

#Options
array set opt {
	use_big_font	0
	start_folder	"~"
	option_file		"lang.config"
}

#Other Gobal variables
set tag_count 	0
set debugger	""

#Various interpretor for various languages - We will Source the file with the lang variable.
set lang {}


############################## Functions ##########################################
#Run the interpreter
proc run { interpreter } {
	global script colours ints lang opt
	
	#If the file must be executed by the shell
	if { ($interpreter == "shell") } {
		if { $tcl_platform(platform) == "windows" } {
			set interpreter "start"
		} elseif { $tcl_platform(platform) == "unix" } {
			set interpreter ""
			set script(path) "./$script(path)"
		}
	}
	
	if { $opt(use_big_font) } {
		set font_size "ansi 14 bold"
	} else {
		set font_size "ansi 12 bold"
	}
	#Run the interpreter and get the output	
	if { ([file exist $script(path)]) } {
		.txt delete 1.0 end
		if { [catch { set result [exec "$interpreter" $script(path)] } err] } {
			.txt insert end "Error...\n\n"
			.txt tag add "error" "1.0" "1.end"
			.txt tag configure "error" -font "$font_size" \
				-foreground $colours(err_head_fore) -background $colours(err_head_back)
			.txt insert end $err
			findErrors
		} else {
			.txt insert end "Executed \"$interpreter $script(path)\"\n\n"
			.txt tag add "head" "1.0" "1.end"
			.txt tag configure "head" -font "$font_size" \
				-foreground $colours(headline_fore) -background $colours(headline_back)
			.txt insert end "$result"
		}
	} else {
		tk_messageBox -icon error -message "The specified interpreter \"$scipt(path)\" is not a valid file."
	}
}

#All the operation that happen when a file is opened - all file operations
proc fileOps { script_file } {
	global program script lang editor debugger
	
	#This is needed as the Batch file gives the 8.3 filename.
	set arg "[file normalize $script_file]"
	
	if { ($arg != "") && ([file exist $arg]) } {
		set script(path) $arg
		set ext [file extension $arg]
		set script(name) [file rootname [file tail $arg]]
		
		set flag 0

		#Find which languages have the extension of the current file.
		for { set i 0 } { $i < [llength $lang] } { incr i } {
			set all_exts [lindex [lindex [lindex $lang $i] 1] 1]
			set exts [split $all_exts ";"]

			foreach extension $exts {
				if { ".$extension" == $ext } {
					set script(lang) 	[lindex [lindex [lindex $lang $i] 0] 1]
					set script(letter)	[lindex [lindex [lindex $lang $i] 2] 1]
					
					set interpreters	[lindex [lindex [lindex $lang $i] 3] 1]
	 				set debugger 		[lindex [lindex [lindex $lang $i] 4] 1]
	 				set editors  		[lindex [lindex [lindex $lang $i] 5] 1]
	 				set flag 1
					break
				}
			}
		}
		
		#If there no support for this file extension.
		if { !$flag } {
			.frm_com.int_choice configure -state disabled
			tk_messageBox -message "Unknown langauge encountered with extension '$ext'.\n\
Please configure support for this language using the 'Language Configuration' option" -title "Unkown Langugage" -icon error

			langConfig "new"
			return
		}

		#Get the editor arguments for this language
		if { $editors != "" } {
			set editor(program)		[lindex $editors 0]
			set editor(argument1)	[lindex $editors 1]
			#if { [lindex $editors 2] != "" } {
				set editor(argument2)	[lindex $editors 2]
			#}
			.frm_com.edit configure -state normal
		} else {
			.frm_com.edit configure -state disable
		}
		#The debugger for this langauge
		if { [lindex $debugger 0] != "" } {
			.frm_com.debug configure -state normal
		} else {
			.frm_com.debug configure -state disabled
		}
		
		#Get the interpreters for the language
		.frm_com.run configure -command "run [lindex [lindex $interpreters 0] 1]" -state normal
		
		#Multiple interpreters
		set m ".frm_com.int_choice_mnu"
		$m delete 0 end ;# Clear the formar interpreter list
		for { set i 0 } { $i < [llength $interpreters] } { incr i } {
			set in [lindex [lindex $interpreters $i] 1]
			set name [lindex [lindex $interpreters $i] 0]
			if { $name != "" } {
				$m add command -label "$name" -command "run $in"
			}
		}
		if { $i > 1 } {
			#if there is more than one interpreter for this language...
			.frm_com.int_choice configure -state normal
		} else {
			.frm_com.int_choice configure -state disabled
		}

		#Other GUI elements
		.lang configure -text "$script(lang)"
		.file_info configure -text "$script(name)"
		
		#Change name
		set program(name) "$program(name_base)$script(letter)"
		wm title . "$program(name) V$program(version) - $script(path)"
		
	} else {
		tk_messageBox -message "\"$arg\" not a valid file." -icon error
	}
}

#Open an external debugger for that language
proc debug { } {
	global script debugger
	
	if { $debugger != "" } {
		set arg1 [lindex $debugger 0]
		set arg2 [lindex $debugger 1]
		set arg3 [lindex $debugger 2]
		
		#Get file path in proper format
		set file_path ""
		regsub -all {/} $script(path) {\\} file_path
		regsub {%FILE%} $arg1 "$file_path" arg1
		regsub {%FILE%} $arg2 "$file_path" arg2
		regsub {%FILE%} $arg3 "$file_path" arg3
	
		#Get the debugger for this language
		set error_flag 0
		set command ""

		#Run the command		
		eval "set error_flag [catch { exec $arg1 $arg2 $arg3 & } err]"
		set command "$arg1 $arg2 $arg3"

		#Print error reports	
		if { $error_flag }  {
			tk_messageBox -icon error -message "Error '$err' with '$command'"
		}
	} else {
		tk_messageBox -message "No debuggers available for $script(lang)."
	}
	
}

#Open the specified file in the given editor.
proc editFile {  } {
	global script editor
	
	set file_path ""
	regsub -all {/} $script(path) {\\\\\\} file_path

	if { [catch { eval exec $editor(program) \"$file_path\" & } err ] } {
		#Show error if there is one
		tk_messageBox -message "[string totitle $err]." -icon error -title "Error..."
	}
}

# Function : openFile
# Shows a file opening dialog and set the contents of the selected files in the
#		text area.
proc openFile { } {
	global opt

	set types {
	{{All Files}        *         }
	{{Perl Files} 		{.pl}	  }
	{{Tcl/Tk Files} 	{.tcl}	  }
	{{Tcl/Tk Files} 	{.tk}	  }
	{{Python Files} 	{.py}	  }
	{{Java Files} 		{.java}	  }
	}
	set result [tk_getOpenFile -filetypes $types -initialdir $opt(start_folder)]
	if { $result != "" } {
		fileOps "$result"
	}
}

#Copied form TagView V 1.02.A
#Open the editor at a specified line no. Happens when the user double clicks the error line.
proc openAtLine { line } {
	global script editor
	
	#Init
	set file_path ""
	set arg1 ""
	set arg2 ""
	set quotes ""
	regsub -all {/} $script(path) {\\\\\\} file_path
	
	regsub {%LINE%} $editor(argument1) "$line" arg1
	regsub {%FILE%} $arg1 "$file_path" arg1
	regsub {%LINE%} $editor(argument2) "$line" arg2
	regsub {%FILE%} $arg2 "$file_path" arg2
	if { $arg2 != "" } {
		set quotes "\""
	}

	if { [catch { eval exec $editor(program) $arg1 $quotes$arg2$quotes & } err ] } {
		#Show error if present
		tk_messageBox -message "[string totitle $err]." -icon error -title "Error..."
	}
}

#Happens when the user exits the program
proc exiter { } {
	global lang program opt script
	
	if { $script(lang_modified) } {
		set data "#This file is generated by $program(name) V$program(version).\n#Do not edit unless you know what you are doing.\n"
		append data "set lang \{\n$lang\n\}\n"
		
		set err ""
		#Write the file
		#The catchs are there so that no error will come even if it is 
		#	run from a CD-ROM(non writeable medium)
		if { ![catch { set opt_file [open "$opt(option_file)" w]} err] } {
			catch { puts $opt_file $data } err
		close $opt_file
		}
		if { $err != "" } {
			tk_messageBox -message "Error: $err" -icon error -title "Error..."
		}
	
	}
	exit
}
################### Text Tagers - For error display ########################
#Copied from GAF Replacer (Pre-Release version)

# Function : lineLength
# Return the list of all the line lengths in the given text. This is called from 
#		'replace' function. Needed to find the position of text in the text widget.
# Argument : content - The inputed text.
# Return   : lengths - The list of all line lengths
proc lineLength { content } {
	set lines [split $content "\n"]
	set total 0
	lappend lengths 0
	foreach line $lines {
		set total [expr $total + [string length $line] + 1]
		lappend lengths $total
	}
	return $lengths
}

# Function : findLine
# Find in which line is $i. The list containing all line length made by lineLength
#		functions.
# Argument : line_no - The position of the wanted char in the text
#			 line_lengths - The list containing the lengths of all lines made by lineLength
# Return   : cur_line - The line in which the char will be found
proc findLine { line_no line_lengths } {
	set cur_line -1
	for { set i 0 } { $i < [llength $line_lengths] } { incr i } {
		if {($line_no >= [lindex $line_lengths $i]) &&\
			($line_no < [lindex $line_lengths [expr $i + 1]])} {
			set cur_line $i
			break
		}
	}
	return $cur_line
}

# Procedure : findErrors - Original Name : find
# Finds all instances of the specifed expression in the text and mark them all
proc findErrors {} {
	global colours tag_count
	
	#Clear current tags
	for { set i 1 } { $i < $tag_count } { incr i } {
		.txt tag delete "errors$i"
	}
	set tag_count 0

	#Initializaitons
	set re {line ([0-9]+)}
	set tags {}
	set i 0

	#Get the text and its info
	set content [.txt get 1.0 end]
	set line_lengths [lineLength $content]
	set length [string length $content]

	while { $i < $length } {
		set flag [regexp -line -lineanchor -linestop -start $i -indices "$re" $content index]
		if { $flag != 0 } {
			#Mark the replace
 			set from_to [split $index " "]
			set from [lindex $from_to 0]
			set to [lindex $from_to 1]
			#Find in which line '$from' and '$to' are located. This will be the line of the replace.
			set from_line [expr [findLine $from $line_lengths] + 1]
			set to_line [expr [findLine $to $line_lengths] + 1]
 			set from_last_length [lindex $line_lengths [expr $from_line - 1]]
 			set to_last_length [lindex $line_lengths [expr $to_line - 1]]
 			#Get thc char # with respect to the line.
			if { $from_last_length != 0 } {
				set from [expr $from - $from_last_length]
				set to [expr $to - $to_last_length + 1]
			} else {
				set to [expr [lindex $from_to 1] + 1]
			}

			#Get the line number
			set hit_text [.txt get "$from_line.$from" "$to_line.$to"]
			regexp $re $hit_text full line_no
			
			incr tag_count
			#Mark the text
			.txt tag add "errors$tag_count" "$from_line.$from" "$to_line.$to"
			.txt tag configure "errors$tag_count" -foreground $colours(error_fore) -background $colours(error_back)
			.txt tag bind "errors$tag_count" <Double-ButtonPress-1> "openAtLine $line_no"

			#Start the searching from the NEXT char
			set i [expr [lindex $from_to 1] + 1]
		} else {
			incr i
		}
	}
}

############################### Lanugage Defenition ##################################

#Get the path of an executable program to run as the interpreter
proc getProgram { field } {
	set types {
	{{All Files}        *         }
	{{Executable Files} {.exe}	  }
	}
	set result [tk_getOpenFile -filetypes $types]
	if { $result != "" } {
		$field delete 0 end
		$field insert 0 "$result"
	}
}

# Help on language Defenition
proc langHelp { } {
	set h [toplevel .helper]
		
    text $h.txt_help -font {Helvetica 12} -wrap word -width 60 -yscrollcommand "$h.slb_help set"
    scrollbar $h.slb_help -orient vertical -command "$h.txt_help yview"
    $h.txt_help  insert 0.0 \
"New Language Definition Help\n" h1 \
"Before using RI, all the details of the langauges it has to support must be entered.\n" p \
"Please DO NOT enter multipe argument\(like 'perl -d'\) in one field. I will try to solve this problem in later \
versions.\n\n" bold \
"First you must enter the name of the language\(Tcl/Tk, Perl etc.\) The next entry field should be given all the \
extensions this language is likely to have. This is very important if you are working in a windows system. Each \
extension should be seperated by a semi-colon(;). For example for Tcl/Tk, you should enter \"tcl;tk\" sans quote. \
In the case of perl, \"pl\"(again without quotes) sould be entered.\n\n" p \
"The interpreters of the languages must be specified. Enter the name of the interpreter in the first field and \
the path of the interpreter in the second field. For example enter 'ActivePerl 5' in the first field and \
'C:/Perl/bin/perl.exe' in the second field. One can specify upto three different interpreters. Of these, \
the first will be consided as the primary interpreter and the next two will be alternate interpreters. Alternate \
interpreters can be run using the 'More' button. If you enter 'shell' in the interpreter name field, the script \
will be executed using the './<script>' command(Unix) or 'start <script>' command(Windows).\n\n" p \
"If there is a debugger for this language, the user can specify it here. Some command line options can be specified \
here. If you want to debug a shell script, you must enter 'sh' in the Debugger field, '+x' in the Debugger Argument 1 \
field and '%FILE%' in the Debugger Argument 2 field. This will run the command 'sh +x %FILE%' if the debug \
button is pressed. The text '%FILE%' will be replaced by the script's path.\n\n" p \
"An external editor for the language can be specified here. In editor's arguments, the text '%LINE%' will be replaced by line number. This is useful \
if there is any error in the script. The editor will shtart at the line with the error. Make sure that the editor \
you specified supports this feature. If you are using vi as your editor, you should enter 'vi' in the Editor field, \
'+%LINE%' in Editor Argument 1 and %FILE% in Editor Argument 2" p

	button $h.but_ok -text "       OK       " -command "destroy $h"

	$h.txt_help tag configure h1 -font {Helvetica 14 bold} -foreground red -justify center 
    $h.txt_help tag configure h2 -font {Helvetica 12 bold}
    $h.txt_help tag configure p
    $h.txt_help tag configure bold -font {Helvetica 12 bold}
    $h.txt_help tag configure center -justify center

    $h.txt_help configure -state disabled

	grid $h.txt_help -in $h -row 0 -column 0 -sticky nsew
	grid $h.slb_help -in $h -row 0 -column 1 -sticky ns
	grid $h.but_ok	 -in $h -row 1 -column 0 -sticky w
}

#Get the data in the language defenition toplevel. If such a language exists, replace it 
#		with the new one. If one don't exist, make a new one.
proc langGet { } {
	global lang script
	
	set name 		 [.l.ent_name get]
	set ext	 		 [.l.ent_ext get]
	set in_name1	 [.l.ent_in_name1 get]
	set interp_1	 [.l.ent_inter1 get]
	set in_name2	 [.l.ent_in_name2 get]
	set interp_2	 [.l.ent_inter2 get]
	set in_name3	 [.l.ent_in_name3 get]
	set interp_3	 [.l.ent_inter3 get]
	set debugger	 [.l.ent_debugger get]
	set debug_arg_1	 [.l.ent_debug_arg1 get]
	set debug_arg_2	 [.l.ent_debug_arg2 get]
	set editor	 	 [.l.ent_editor get]
	set editor_arg_1 [.l.ent_edit_arg1 get]
	set editor_arg_2 [.l.ent_edit_arg2 get]
	
	#If a needed item is not set, show an error
	set err ""
	if { $name == "" } {
		set err "Name"
		.l.lab_name configure -fg red
	}
	if { $ext == "" } {
		set err "$err, Associated Extensions"
		.l.lab_ext configure -fg red
	}
	if { $in_name1 == "" } {
		set err "$err, Interpreter"
		.l.lab_in_name1 configure -fg red
	}
	if { $interp_1 == "" } {
		set err "$err, Interpreter Path"
		.l.lab_inter1 configure -fg red
	}
	
	if {$err != "" } {
		tk_messageBox -message "You should enter $err to continue."
	} else {
		set this_lang {}
		
		set item {}
		lappend item "Name"
		lappend item "$name"
		lappend this_lang $item
		
		set item {}
		lappend item "Extension"
		lappend item "$ext"
		lappend this_lang $item
		
		set item {}
		lappend item "Letter"
		lappend item "[string toupper [string index $name 0]]"
		lappend this_lang $item
		
		set item {}
		lappend item "Interpreter"
		set mid_item {}
		set sub_item {}
		lappend sub_item "$in_name1" "$interp_1"
		lappend mid_item $sub_item
		set sub_item {}
		lappend sub_item "$in_name2" "$interp_2"
		lappend mid_item $sub_item
		set sub_item {}
		lappend sub_item "$in_name3" "$interp_3"
		lappend mid_item $sub_item
		lappend item $mid_item
		lappend this_lang $item
		
		set item {}
		lappend item "Debugger"
		set sub_item {}
		lappend sub_item "$debugger" "$debug_arg_1" "$debug_arg_2"
		lappend item $sub_item
		lappend this_lang $item
		
		set item {}
		lappend item "Editor"
		set sub_item {}
		lappend sub_item "$editor" "$editor_arg_1" "$editor_arg_2"
		lappend item $sub_item
		lappend this_lang $item
		
#		#The resulting array will be in this format - without \n's of course
# 		set this_lang {
# 			{ Name "$name" }
# 			{ Ext	"$ext" }
# 			{ Letter "L" }
# 			{ Interpreter
# 				{ { "[file rootname [file tail $interp_1]]"	"$interp_1" } }
# 			}
# 			{ Debugger
# 				{ "$debugger" "$debug_arg_1" "$debug_arg_2" }
# 			}
# 			{ Editor
# 				{ "$editor" "$editor_arg_1" "$editor_arg_2" }
# 			}
# 		}
	}
	
	set found 0
	for { set i 0 } { $i < [llength $lang] } { incr i } {
		if { $name == "[lindex [lindex [lindex $lang $i] 0] 1]" } {
			set lang [lreplace $lang $i $i $this_lang]
			set found 1
			break
		}
	}
	
	if { !$found } {
		lappend lang $this_lang
	}
	
	#Tag the 'lang' variable as modified - make sure it is written to a file
	set script(lang_modified) 1
	catch { destroy .l }
}

#This function clears the entry widgets in Language configuration and give it new values.
proc langEditNew { widget value } {
	.l.ent_$widget delete 0 end
	.l.ent_$widget insert 0 $value
}
proc langEdit { } {
	global lang
	#Get the index number of the double-clicked language
	set sel [.l.lst_lang curselection]
	set lang_name [.l.lst_lang get $sel]
	
	for { set i 0 } { $i < [llength $lang] } { incr i } {
		if { $lang_name == "[lindex [lindex [lindex $lang $i] 0] 1]" } {
			langEditNew "name" 		$lang_name
			langEditNew "ext" 		"[lindex [lindex [lindex $lang $i] 1] 1]"
			langEditNew "in_name1"	"[lindex [lindex [lindex [lindex [lindex $lang $i] 3] 1] 0] 0]"
			langEditNew "inter1" 	"[lindex [lindex [lindex [lindex [lindex $lang $i] 3] 1] 0] 1]"
			langEditNew "in_name2" 	"[lindex [lindex [lindex [lindex [lindex $lang $i] 3] 1] 1] 0]"
			langEditNew "inter2" 	"[lindex [lindex [lindex [lindex [lindex $lang $i] 3] 1] 1] 1]"
			langEditNew "in_name3" 	"[lindex [lindex [lindex [lindex [lindex $lang $i] 3] 1] 2] 0]"
			langEditNew "inter3" 	"[lindex [lindex [lindex [lindex [lindex $lang $i] 3] 1] 2] 1]"
			langEditNew "debugger" 	"[lindex [lindex [lindex [lindex $lang $i] 4] 1] 0]"
			langEditNew "debug_arg1" "[lindex [lindex [lindex [lindex $lang $i] 4] 1] 1]"
			langEditNew "debug_arg2" "[lindex [lindex [lindex [lindex $lang $i] 4] 1] 2]"
			langEditNew "editor" 	"[lindex [lindex [lindex [lindex $lang $i] 5] 1] 0]"
			langEditNew "edit_arg1" "[lindex [lindex [lindex [lindex $lang $i] 5] 1] 1]"
			langEditNew "edit_arg2" "[lindex [lindex [lindex [lindex $lang $i] 5] 1] 2]"
		}
	}
}

#Configuration for new languages. This is a little tricky. If the variable 'type' dont have the
#		value 'new' then a listbox with all existing languages appear at the side. One can use
#		this to edit current languages.
proc langConfig { type } {
	global lang
	
	set l [toplevel .l]
	
	if { $type == "new" } {
		wm title .l "New Language Definition"
		label $l.lab_head -text "New Language Definition" -font "ansi 12 bold"
	} else {
		wm title .l "Language Configuration"
		label $l.lab_head -text "Language Definition" -font "ansi 12 bold"
	}
	
	label $l.lab_name -text "Name *"
	entry $l.ent_name
	help $l.ent_name "Name of this language."
	label $l.lab_ext -text "Associated Extensions *"
	entry $l.ent_ext
	help $l.ent_ext "All the extensions for this language. Must be seperated by a semicolon(;). For example - tcl;tk"

	label $l.lab_in_name1 -text "Interpreter 1 *"
	entry $l.ent_in_name1
	help $l.ent_in_name1 "This is the name of the first interpreter. For example - ActivePerl or Tcl8.4"
	label $l.lab_inter1 -text "Interpreter 1(Path) *"
	entry $l.ent_inter1
	help $l.ent_inter1 {Enter the location of the interpreter of this langauge. This can be given as a command name (for example, wish) or as an absolute path(/usr/bin/wish84).}
	button $l.but_inter1 -text "Browse..." -command "getProgram $l.ent_inter1"
	label $l.lab_in_name2 -text "Interpreter 2"
	entry $l.ent_in_name2
	help $l.ent_in_name2 "The name of the second interpreter."
	label $l.lab_inter2 -text "Interpreter 2(Path)"
	entry $l.ent_inter2
	help $l.ent_inter2 "Enter the path of the alternate interpreter for this langauge."
	button $l.but_inter2 -text "Browse..." -command "getProgram $l.ent_inter2"
	label $l.lab_in_name3 -text "Interpreter 3"
	entry $l.ent_in_name3
	help $l.ent_in_name3 "This is then name of the third interpreter."
	label $l.lab_inter3 -text "Interpreter 3(Path)"
	entry $l.ent_inter3
	help $l.ent_inter2 "Enter the path of another alternate interpreter for this langauge."
	button $l.but_inter3 -text "Browse..." -command "getProgram $l.ent_inter3"

	label $l.lab_debugger -text "Debugger"
	entry $l.ent_debugger
	help $l.ent_debugger "Location of the debugger for this language."
	button $l.but_debugger -text "Browse..." -command "getProgram $l.ent_debugger"
	label $l.lab_debug_arg1 -text "Debugger Argument 1"
	entry $l.ent_debug_arg1
	help $l.ent_debug_arg1 "Debugger arguments. The text '%FILE%' will be replaced by the script's path."
	$l.ent_debug_arg1 insert end "%FILE%"
	label $l.lab_debug_arg2 -text "Debugger Argument 2"
	entry $l.ent_debug_arg2

	label $l.lab_editor -text "Editor Path"
	entry $l.ent_editor
	help $l.ent_editor "The editor of this language. For example, vi(in Linux) or C:\\Windows\\Notepad.exe(in Windows)"
	button $l.but_editor -text "Browse..." -command "getProgram $l.ent_editor"
	label $l.lab_edit_arg1 -text "Editor Argument 1"
	entry $l.ent_edit_arg1
	$l.ent_edit_arg1 insert end "%FILE%"
	help $l.ent_debug_arg1 "Editor's arguments. The text '%FILE%' will be replaced by the script's path."
	label $l.lab_edit_arg2 -text "Editor Argument 2"
	entry $l.ent_edit_arg2
	help $l.ent_debug_arg2 "Editor's arguments. The text '%LINE%' will be replaced by line number. This is useful \
if there is any error in the script. The editor will shtart at the line with the error. Make sure that the editor \
you specified supports this feature."

	button $l.but_ok -text "   OK   " -command { langGet }
	button $l.but_help -text " Help " -command { langHelp }
	button $l.but_cancel -text " Cancel " -command { destroy .l }

	set col0 0
	set col1 1
	set col2 2

	#Existing Language Configuration.
	if { $type != "new" } {
		listbox $l.lst_lang
		bind $l.lst_lang <Double-ButtonPress-1> { langEdit }
		foreach lan $lang {
			set langs [lindex [lindex $lan 0] 1]
			$l.lst_lang insert end $langs
		}
		grid $l.lst_lang -in $l -row 1 -column 0 -rowspan 14 -sticky nsew

		#Push all columns one step back.
		set col0 1
		set col1 2
		set col2 3
	}
	
	grid $l.lab_head -in $l -row 0 -column 0 -columnspan 4
	grid $l.lab_name     -in $l -column $col0 -row 1 -sticky w
	grid $l.ent_name	 -in $l -column $col1 -row 1 -sticky w
	grid $l.lab_ext 	 -in $l -column $col0 -row 2 -sticky w
	grid $l.ent_ext 	 -in $l -column $col1 -row 2 -sticky w
	grid $l.lab_in_name1 -in $l -column $col0 -row 3 -sticky w
	grid $l.ent_in_name1 -in $l -column $col1 -row 3 -sticky w
	grid $l.lab_inter1	 -in $l -column $col0 -row 4 -sticky w
	grid $l.ent_inter1 	 -in $l -column $col1 -row 4 -sticky w
	grid $l.but_inter1   -in $l -column $col2 -row 4 -sticky w
	grid $l.lab_in_name2 -in $l -column $col0 -row 5 -sticky w
	grid $l.ent_in_name2 -in $l -column $col1 -row 5 -sticky w
	grid $l.lab_inter2	 -in $l -column $col0 -row 6 -sticky w
	grid $l.ent_inter2 	 -in $l -column $col1 -row 6 -sticky w
	grid $l.but_inter2   -in $l -column $col2 -row 6 -sticky w
	grid $l.lab_in_name3 -in $l -column $col0 -row 7 -sticky w
	grid $l.ent_in_name3 -in $l -column $col1 -row 7 -sticky w
	grid $l.lab_inter3	 -in $l -column $col0 -row 8 -sticky w
	grid $l.ent_inter3   -in $l -column $col1 -row 8 -sticky w 
	grid $l.but_inter3   -in $l -column $col2 -row 8 -sticky w
	grid $l.lab_debugger -in $l -column $col0 -row 9 -sticky w
	grid $l.ent_debugger -in $l -column $col1 -row 9 -sticky w
	grid $l.but_debugger -in $l -column $col2 -row 9 -sticky w
	grid $l.lab_debug_arg1 -in $l -column $col0 -row 10 -sticky w
	grid $l.ent_debug_arg1 -in $l -column $col1 -row 10 -sticky w
	grid $l.lab_debug_arg2 -in $l -column $col0 -row 11 -sticky w
	grid $l.ent_debug_arg2 -in $l -column $col1 -row 11 -sticky w
	grid $l.lab_editor	-in $l -column $col0 -row 12 -sticky w
	grid $l.ent_editor	-in $l -column $col1 -row 12 -sticky w
	grid $l.but_editor	-in $l -column $col2 -row 12 -sticky w
	grid $l.lab_edit_arg1 -in $l -column $col0 -row 13 -sticky w
	grid $l.ent_edit_arg1 -in $l -column $col1 -row 13 -sticky w
	grid $l.lab_edit_arg2 -in $l -column $col0 -row 14 -sticky w 
	grid $l.ent_edit_arg2 -in $l -column $col1 -row 14 -sticky w
	grid $l.but_ok $l.but_help $l.but_cancel -in $l -row 15 -sticky w -pady 15

	raise .l
 	wm deiconify .l
 	focus .l.ent_name
}

######################################## Common Functions ########################################
# Function : Help
proc help {w h} {
#Show the hint 1 second after the pointer rests on the same spot
bind $w <Any-Enter> "after 1000 [list help:show %W [list $h]]"
bind $w <Any-Leave> "destroy %W.balloon"
}
proc help:show {w arg} {
if {[eval winfo containing  [winfo pointerxy .]]!=$w} {return}
set top $w.balloon
catch {destroy $top}
toplevel $top -bd 0 -bg gray
wm overrideredirect $top 1
pack [message $top.txt -bg lemonchiffon1 -font ansi -width 170 \
	-text $arg -relief solid -aspect 10000 -bd 1 -padx 2 -pady 1]
set wmx [winfo rootx $w]
set wmy [expr [winfo rooty $w]+[winfo height $w]]
wm geometry $top [winfo reqwidth $top.txt]x[winfo reqheight $top.txt]+$wmx+$wmy
raise $top
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
			exec rundll32 url.dll,FileProtocolHandler $url &
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

#Show the specified text as the status for a second and then clear it
proc stat { msg } {
	.status configure -text "$msg"
	after 2000 { .status configure -text "Ready" }
}
#Show status for specifed time and clear it.
proc statu { msg delay } {
	.status configure -text "$msg"
	#If it is given in seconds rather than milliseconds.
	if { $delay < 20 } {
		set delay [expr $delay * 1000]
	}
	after $delay { .status configure -text "Ready" }
}
#Update the status bar
proc status { msg } {
	if { $msg != "" } {
		.status configure -text "$msg"
	} else {
		.status configure -text "Ready"
	}
}

# This function will make the menu bar at the top of the window. I thought
# 	that I will seperate it from the main GUI programming.
# Arguments : m - m is the id of the menu.
proc makeMenu { m } {
global opt program

menu $m
#The Main Buttons
$m add cascade -label "File" -underline 0 -menu [menu $m.file -tearoff 0]
$m add cascade -label "Operation" -underline 0 -menu [menu $m.ops -tearoff 0]
$m add cascade -label "Preferences" -underline 0 -menu [menu $m.pref -tearoff 0]
$m add cascade -label "Help" -menu [menu $m.help -tearoff 0]

## File Menu ##
set c $m.file
$c add command -label "Open Script" -underline 0 -command { openFile }
$c add separator
$c add command -label "Exit" -underline 1 -command { exit }

## Date Menu ##
set c $m.ops
$c add command -label "Run Script" -command { run 0 }
$c add command -label "Edit" -command { editFile }
$c add command -label "Debug" -command { debug }

## Preferences Menu ##
set c $m.pref
$c add checkbutton -label "Use Bigger Font" -underline 4 -variable opt(use_big_font)
$c add command -label "Configue Languages" -underline 0 -command { langConfig "config" }
$c add command -label "Add New Languages"  -underline 0 -command { langConfig "new" }


## Help Menu ##
set c $m.help
$c add command -label "Author's Website" -underline 0 -command { launchBrowser "http://www.geocities.com/binnyva" }
$c add command -label "$program(name) Page" -underline 0 -command { launchBrowser "http://www.geocities.com/binnyva/code/tcl/scripts/usenet/" }
$c add separator
$c add command -label "About" -underline 0 -command { 
	tk_messageBox -type ok -title "About $program(name)" -message \
"$program(name) V $program(version)

by Binny V Abraham

$program(email)
$program(website)"
}
}

############################# GUI Building ##############################
#Makes the menu
makeMenu ".menubar"
. configure -menu .menubar

## The Result Area
frame .frm
text .txt -wrap none -yscrollcommand ".srl_txt_y set" -xscrollcommand ".srl_txt_x set"
scrollbar .srl_txt_y -command ".txt yview" -orient v
scrollbar .srl_txt_x -command ".txt xview" -orient h
label .lab_spacer -text "   "

if { $opt(use_big_font) } {
	.txt configure -font "ansi 12"
}

pack .txt -in .frm -side left -fill both -expand 1
pack .srl_txt_y -in .frm -fill y -expand 1
pack .frm -fill both -expand 1
pack .lab_spacer -side right
pack .srl_txt_x -fill x -side top

## Command Buttons
frame .frm_com -bd 1 -relief raised
button .frm_com.run   -text "Run Script" -command { run }      -font "ansi 10 bold" -state disable
button .frm_com.edit  -text "   Edit   " -command { editFile } -font "ansi 10 bold" -state disable
button .frm_com.debug -text "   Debug  " -command { debug }    -font "ansi 10 bold" -state disable

set mnu [menu .frm_com.int_choice_mnu -tearoff 0]
menubutton .frm_com.int_choice -text "More" -font "ansi 8 bold" -bd 2 -relief raised -menu $mnu
pack .frm_com.run .frm_com.int_choice .frm_com.edit .frm_com.debug -side left -padx 15
pack .frm_com -ipady 2 -pady 2

## Status Bar
frame .frm_stat
label .status -text "Ready" -anchor w
label .file_info -bd 1 -relief sunken -width 20 -text "Empty"
label .lang -bd 1 -relief sunken -width 20
pack .status    -in .frm_stat -side left -padx 1 -expand 0
pack .file_info -in .frm_stat -side right -padx 1
pack .lang      -in .frm_stat -side right -padx 1
pack .frm_stat -side left -fill x -expand 1

bind . <Key-Escape> { exiter }
wm protocol . WM_DELETE_WINDOW { exiter }
wm geometry . =640x480+25+25

#The Inititialization Function
proc init {} {
	global argv program script lang opt
	
	#Load saved options
	catch { source "[file join $script(home) $opt(option_file)]" }

	if { $argv != "" } { 
		fileOps [lindex $argv 0]
	} else {
		openFile
	}
}
init

###################################  To Do  ########################################
# What happens if there is input?
# What if it is a long time program
# Make a Installer Script - One that configures stuff according to the OS.

################################## History #########################################
# 1.00.A - First Version - October 17 2004
#
# 2.00.A - January 19, 2005 
#  - First Public Release
#  - More Configurable.
#  - Can add more languages
#  - Solved 800x600 Resolution bug