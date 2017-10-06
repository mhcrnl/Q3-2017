#!/bin/sh
# the next line restarts using wish \
exec wish "$0" "$@"
##########################################################################
# Developer : Binny V A                                                  #
# Website   : http://www.geocities.com/binnyva                           #
# E-Mail    : binnyva@rediffmail.com                                     #
# Get more Tcl/Tk scripts from http://www.geocities.com/binnyva/code/tcl #
##########################################################################
# Name         : SimplePlanner                                           #
# Version      : 2.00.A                                                  #
# Started Date : September 20, 2004                                      #
# Description  :                                                         #
# A planner that will write the plans and the date they were made in to  #
#	user specified Text file. Can read the plans, add new ones, finish   #
#	existing ones etc.                                                   #
#                                                                        #
# Get more Tcl/Tk scripts from http://www.geocities.com/binnyva/code/tcl #
##########################################################################

########################### Global Variables #############################
# Program Info
array set program {
	name		"SimplePlanner"
	version		"2.00.A"
	author		"Binny V Abraham"
	email		"binnyva@hotmail.com"
	website		"http://www.geocites.com/binnyva"
}
# Plan Storage Files
array set files {
	old			"History.txt"
	plans		"Plans.txt"
}
# Options
array set opt {
	editor		"notepad"
}
set editing "-Adobe-Courier-*-R-Normal--*-130-*-*-*-*-*-*"
set id 1

#Change the editor to somthing this platform support
if { $::tcl_platform(platform) == "unix" } {
	set opt(editor)	"vi"
}

# When a plan is over, delete its reference and write it to history
proc finished { no } {
	global files

	#Get file contents
	set in_file [open "$files(plans)" r]
	seek $in_file 0 start
	set buffer [read $in_file]
	close $in_file
	set lines [split $buffer "\n"]

	#Init
	set finished_plan [.frm.plan_$no get 1.0 end]
	set finished_plan [string trimright $finished_plan]
	set plans ""
	set finished ""
	set hit 0

	for { set i 0 } { $i < [llength $lines] } { incr i } {
		set line [lindex $lines $i]
		if { !$hit } {
			set found [regexp "(.*) -> (.*)" $line full plan start_month]
			if { [string trimright $plan] == $finished_plan } {
				#We got the Line we wanted
				set finished "$line"
				set hit 1
			} else {
				#Put all other plans in the collection - to write back.
				append plans "$line\n"
			}
		} else {
			#Put all other plans in the collection - to write back.
			append plans "$line\n"
		}
  	}
	
	set seconds [clock seconds]
	set times [clock format $seconds -format "%I:%m %p"]
	set date [clock format $seconds -format "%B %e, %Y"]
	
	if { $hit } {
		#Show a conformation
		set just_plan ""
		regexp "(.*) -> (.*)" $finished full just_plan
		set plans [string trimright $plans]
		set answer [tk_messageBox -message "Finish plan\n\"$just_plan\"\nAt $date, $times?" -type yesno -icon question]
	
		if { $answer } {
			#Write the other things back to the file.
			set out_file [open "$files(plans)" w]
			puts $out_file "$plans"
			close $out_file
		
			#Write the finished plan back to the history file.
			set history_file [open "$files(old)" a]
			puts $history_file "$finished -> $date, $times"
			close $history_file
	
			#Delete the item from the GUI
			if {[winfo exists .frm.plan_$no]} {
				destroy .frm.plan_$no
				destroy .frm.slb_$no
				destroy .frm.start_date_$no
				destroy .frm.but_update_$no
				destroy .frm.but_finish_$no
			}
		}
	} else {
		tk_messageBox -message "No plan called \"$finished_plan\" was found."
	}
}

#Opens the Plans.txt File and get the info.
proc getPlans { base } {
	global files id editing all_plans

	#If Plans file is not found, make one
	if { ![file exist $files(plans)] } {
		set make_file [open "$files(plans)" w]
		close $make_file
	}
	
	set in_file [open "$files(plans)" r]
	seek $in_file 0 start

	#Init
	set i 1
	set flag 1

	while { $flag } {
		set line [gets $in_file]
		if { $line == -1 } {
			break ;# Get out at end of file
		}

		set found [regexp "(.*) -> (.*)" $line full plan start_month]
		if { ($line!="") && ($found) } {
			#Get just the date and not the time
			regexp {([^,]*, .*), .*} $start_month full start_month

			#Make the nessary GUI
			text $base.plan_$i -height 2 -wrap word -width 50 \
				-yscrollcommand "$base.slb_$i set" -font "$editing"
			scrollbar $base.slb_$i -command "$base.plan_$i yview" -orient v
			entry $base.start_date_$i -width 15
			# entry $base.end_date_$i -width 15
			button $base.but_update_$i -text "Update" -command "updatePlan $i"
			button $base.but_finish_$i -text "Finsished" -command "finished $i"
			grid $base.plan_$i $base.slb_$i $base.start_date_$i \
				$base.but_update_$i $base.but_finish_$i -in $base -row $i
					# Add $base.end_date_$i
			
			#Put it in GUI
			$base.plan_$i insert end "$plan"
			$base.start_date_$i insert end "$start_month"
			# $base.end_date_$i insert end "$end_month"

			incr i
		} else {
			set flag 0
		}
  	}
	close $in_file
	
	#If there plans are found...
	if { $i > 1 } {
		set id $i ;#Update the global variable
	}
	return $i
}

# Write the edited plan after removing the original
proc updatePlan { id } {
	global files

	#Get the edited plan from GUI
	set edited_plan [.frm.plan_$id get 1.0 end]
	regsub {\n} $edited_plan { } edited_plan
	
	set in_file [open "$files(plans)" r]
	set buffer [read $in_file]
	close $in_file
	set lines [split "$buffer" "\n"]
	set length [llength $lines]

	set i 1
	set plans ""
	set finished ""

	foreach line $lines {
		set found [regexp "(.*) -> (.*)" $line full plan start_month]
		if { ($line != "") && ($found) } {
			if { $i == $id } {
				#We got the Line we wanted, put the edited one in its place
				set seconds [clock seconds]
				set times [clock format $seconds -format "%I:%m %p"]
				set date [clock format $seconds -format "%B %e, %Y"]
	
				#Show a conformation
				set answer [tk_messageBox -message "Update plan\n\"$plan\"\n to \"$edited_plan\"\nAt $date, $times?" -type yesno -icon question]
				if { $answer } {
					append plans "$edited_plan -> $date, $times\n"
				}
			} else {
				#Put all other plans in the collection - to write back.
				append plans "$line\n"
			}
			incr i
		} else {
			#Put all other lines in the collection
			append plans "$line\n"
		}
  	}
	
	if { $answer } {
		string trimright $plans ;#Remove the unwanted '\n's
		#Write the other things back to the file.
		set out_file [open "$files(plans)" w]
		puts $out_file "$plans"
		close $out_file
		
		stat "Plan updated."
	}
}

# Refresh the Plans - Load all from file.
proc refresh { } {
	global id
	set base ".frm"
	set plan_count 0
	for { set i 1 } { $i < $id } { incr i } {
		if { [winfo exist "$base.plan_$i"] } {
			#Delete all GUI
			destroy $base.plan_$i $base.slb_$i $base.start_date_$i \
				$base.but_update_$i $base.but_finish_$i
		}
	}
	set plan_count [getPlans ".frm"]
	status "[expr $plan_count - 1] plan(s) available."
}

# Write the newly made plan
proc writeNewPlan {} {
	global id files editing
	set base ".frm"
	
	#Make sure that the toplevel window exist before doing anything
	if { [winfo exist .new] } {
		#Get details of the new plan and destroy the toplevel window
		set plan [.new.txt_plan get 1.0 end]
		set date [.new.ent_time get]
		destroy .new

		regsub {\n} $plan { } plan ;# Delete all the '\n' chars		
		#Write the other things back to the file.
		set in [open "$files(plans)" r]
		set buffer [read $in]
		close $in
		set lines [split $buffer "\n"]
		set new ""
		set flag 1
		#Insert the plan in the first empty place.
		for { set i 0 } { $i < [llength $lines] } { incr i } {
			set line [lindex $lines $i]
			if { $line == "" && $flag } {
				append new "$plan -> $date\n"
				set flag 0
			} else {
				append new "$line\n"
			}
		}
		set newer [string trimright $new] ;#Remove the unwanted '\n's
		#Write the file
		set out [open "$files(plans)" w]
		puts $out "$newer"
		close $out

		#Make nessary GUI
		text $base.plan_$id -height 2 -wrap word -width 50 \
			-yscrollcommand "$base.slb_$id set" -font "$editing"
		scrollbar $base.slb_$id -command "$base.plan_$id yview" -orient v
		entry $base.start_date_$id -width 15
		button $base.but_update_$id -text "Update" -command "updatePlan $id"
		button $base.but_finish_$id -text "Finsished" -command "finished $id"
		grid $base.plan_$id $base.slb_$id $base.start_date_$id \
			$base.but_update_$id $base.but_finish_$id -in $base -row $id

		#Put it in GUI
		regexp {([^,]*, .*), .*} $date full date ;#Get just the date and not the time
			
		$base.plan_$id insert end "$plan"
		$base.start_date_$id insert end "$date"
		
		stat "A new plan is made and written."
		incr id
	}
}

# A new plan must be made
proc newPlan {} {
	global editing

	#Make sure that there is no other window by that name.
	if { ![winfo exist .new] } {
		set i [toplevel .new]
		
		text $i.txt_plan -width 70 -height 5 -font "$editing"
		pack $i.txt_plan
		
		set seconds [clock seconds]
		set times [clock format $seconds -format "%I:%m %p"]
		set date [clock format $seconds -format "%B %e, %Y"]
		
		entry $i.ent_time -width 30
		$i.ent_time insert end "$date, $times"
		pack $i.ent_time
		
		button $i.but_ok -text "    OK     " -command {
			#Check if the user have entered anything.
			if { [string length [.new.txt_plan get 1.0 end]] > 2 } { 
				writeNewPlan
			}
		}
		button $i.but_cancel -text "  Cancel  " -command { catch { destroy .new } }
		pack $i.but_ok -side left
		pack $i.but_cancel -side right
		
		wm title $i "New Plan"
		bind $i <Key-Escape> { catch { destroy .new } }
		focus $i.txt_plan
	}
}

# Open the plans file in notepad
proc openForEdit {} {
	global files opt
	if { ![catch { exec "$opt(editor)" "$files(plans)" & } res] } {
		stat "Plans file opened in $opt(editor)."
	} else {
		stat "Error! $res."
	}
}

#Show the specified text as the status for a second and then clear it
proc stat { msg } {
	.status configure -text "$msg"
	after 2000 { .status configure -text "Ready" }
}
#Update the status bar
proc status { msg } {
	if { $msg != "" } {
		.status configure -text "$msg"
	} else {
		.status configure -text "Ready"
	}
}

################################ GUI Building ##########################################
set heading "-Adobe-Helvetica-Bold-R-Normal--*-150-*-*-*-*-*-*"

label .lbl_heading -text "Plans And To Dos" -font "$heading"
pack .lbl_heading 

frame .frm
set plan_count [getPlans ".frm"]
pack .frm

frame .buttons
button .buttons.but_new -text "New Plan" -command "newPlan" -font "ansi 10 bold"
button .buttons.but_refresh -text "Refresh" -command "refresh" -font "ansi 10 bold"
pack .buttons.but_new .buttons.but_refresh -padx 10 -side right
pack .buttons

#Status Bar
frame .frm_stat
label .status -text "Ready" -anchor w
button .but_edit -text "Edit File" -command { openForEdit }
pack .status   -in .frm_stat -side left -padx 1 -expand 0
pack .but_edit -in .frm_stat -side right -padx 1
pack .frm_stat -side left -fill x -expand 1

bind . <Key-Escape> { exit }
bind . <Key-F5> { refresh }
bind . <Key-F2> { newPlan }
bind . <Control-n> { newPlan }

if { $plan_count == 1 } {
	#If there are no plans
	tk_messageBox -message "No plans were found in file \"$files(plans)\"."
} else {
	status "[expr $plan_count - 1] plan(s) available."
}

################################ To Do ##########################################