#!/usr/bin/perl

# this program generates a HTML form that lets the user enter values to create the Gantt chart

use CGI;


require 'dbhelp.pl';

$query = new CGI;

$cookie = $query->cookie($cookieID);

if (! $cookie) {
  print $query->redirect(-uri=>"${wwwroot}index.html");
  exit 0;
}

$query = &GetData($cookie);

###
#Get stored variables

$redPerson = $query->param('redPerson');
$bluePerson = $query->param('bluePerson');
$greenPerson = $query->param('greenPerson');
$yellowPerson = $query->param('yellowPerson');
$purplePerson = $query->param('purplePerson');

$blackPerson = $query->param('blackPerson');
$maroonPerson = $query->param('maroonPerson');
$navyPerson = $query->param('navyPerson');
$olivePerson = $query->param('olivePerson');
$tealPerson = $query->param('tealPerson');

$greyPerson = $query->param('greyPerson');
# alternative is silver
$lavenderPerson = $query->param('lavenderPerson');
$limePerson = $query->param('limePerson');
$aquaPerson = $query->param('aquaPerson');
$khakiPerson = $query->param('khakiPerson');

$brownPerson = $query->param('brownPerson');
$orangePerson = $query->param('orangePerson');
$tanPerson = $query->param('tanPerson');
$pinkPerson = $query->param('pinkPerson');
$violetPerson = $query->param('violetPerson');

$month = $query->param('month');
$day = $query->param('day');
$year = $query->param('year');

$projName = $query->param('projName');

# load task descriptions
$count = 0;
do {
  $count++;
  $task[$count] = $query->param("task$count");
} while ($count != $lastQuestion);

#Done getting stored variables
###


print $query->header;

print << "END_HTML";

<HTML>
<HEAD>
<TITLE>Gantt</TITLE>

END_HTML

print << "END_JSCRIPT";

<SCRIPT LANGUAGE="JavaScript">

<!--

function validate()
	{
	var startTime = 5;
	var endTime = 6;
	var currentQuestion = 1;
	
	while(currentQuestion < 3)
		{

		if(window.document.gantt.elements[startTime].selectedIndex > window.document.gantt.elements[endTime].selectedIndex)
			{
			alert("There was a problem with your set of answers # " + currentQuestion + ".  Please make sure the the Week Starting is before the Week Ending.");
			currentQuestion = currentQuestion + 1;
			return false;		
			}

		else
			{
			startTime = startTime + 3;
			endTime = endTime + 3;
			currentQuestion = currentQuestion + 1;
			}
			
		}

	if((window.document.gantt.month.value >= 13) || (window.document.gantt.month.value <= 0))
		{
		alert("The month of the Start Date must be from 1 to 12.");
		return false;
		}

	if((window.document.gantt.day.value >= 32) || (window.document.gantt.day.value <= 0))
		{
		alert("The day of the Start Date must be from 1 to 31.");
		return false;
		}
		
	if(window.document.gantt.year.value <= 1998)
		{
		alert("The year of the Start Date must be after 1998.");
		return false;
		}
		
	return true;

	}	

// -->

</SCRIPT>

END_JSCRIPT

print << "END_HTML";

</HEAD>
<BODY BGCOLOR=#FFFFFF TEXT=#000000>

<FORM NAME="gantt" ACTION="store_check.cgi" METHOD="POST" onSubmit="return validate()">
<INPUT TYPE="Hidden" NAME="next" VALUE="ganttChart.cgi">
<INPUT TYPE="Hidden" NAME="part" VALUE="ganttTimechart">

<FONT FACE="Verdana, Arial, Helvetica, sans-serif" SIZE=4 COLOR=#000000>
<U>Create the Time Chart</U>
</FONT>

<BR><BR>

<TABLE CELLPADDING=2 CELLSPACING=2 BORDER=0>

<TR>
<TD BGCOLOR=#996666><FONT FACE="Verdana, Arial, Helvetica, sans-serif" SIZE=2 COLOR=#FFFFFF>
<B>What is the start date for your project?</B>
</TD>
</TR>

<TR>
<TD BGCOLOR=#CCCCCC><FONT FACE="Verdana, Arial, Helvetica, sans-serif" SIZE=2 COLOR=#000000>
<INPUT TYPE=text SIZE=2 NAME="month" VALUE="$month" MAXLENGTH=2> / 
<INPUT TYPE=text SIZE=2 NAME="day" VALUE="$day" MAXLENGTH=2> /
<INPUT TYPE=text SIZE=4 NAME="year" VALUE="$year" MAXLENGTH=4>
MM/DD/YEAR
</TD>
</TR>
</TABLE>

<BR><BR>

END_HTML


print "<TABLE CELLPADDING=2 CELLSPACING=2 BORDER=0>";

print "<TR>";

print "<TD BGCOLOR=#996666><FONT FACE=\"Verdana, Arial, Helvetica, sans-serif\" SIZE=2 COLOR=#FFFFFF><B>Activity Description</B></FONT></TD>";
print "<TD BGCOLOR=#996666><FONT FACE=\"Verdana, Arial, Helvetica, sans-serif\" SIZE=2 COLOR=#FFFFFF><B>Week Starting</B></FONT></TD>";
print "<TD BGCOLOR=#996666><FONT FACE=\"Verdana, Arial, Helvetica, sans-serif\" SIZE=2 COLOR=#FFFFFF><B>Week Ending</B></FONT></TD>";
print "<TD BGCOLOR=#996666><FONT FACE=\"Verdana, Arial, Helvetica, sans-serif\" SIZE=2 COLOR=#FFFFFF><B>Person Responsible</B></FONT></TD>";

print "</TR>\n";


$count = 0;
do {
  $count++;
  print "<TR>";

  print "<TD BGCOLOR=#CCCCCC><FONT FACE=\"Verdana, Arial, Helvetica, sans-serif\" SIZE=2 COLOR=#000000><INPUT TYPE=text SIZE=85 NAME=\"task$count\" VALUE=\"$task[$count]\" MAXLENGTH=255></FONT></TD>";
  print "<TD BGCOLOR=#CCCCCC><FONT FACE=\"Verdana, Arial, Helvetica, sans-serif\" SIZE=2 COLOR=#000000>";
  print $query->popup_menu(-name=>("startTime$count"),
				         -values=>['1', '2', '3', '4', '5', '6', '7', '8', '9', '10', '11', '12', '13', '14', '15', '16', '17', '18', '19', '20', '21', '22', '23', '24'],
				         -labels=>{'1'=>'Week 1',
					               '2'=>'Week 2',
					               '3'=>'Week 3',
					               '4'=>'Week 4',
					               '5'=>'Week 5',
								   '6'=>'Week 6',
					               '7'=>'Week 7',
					               '8'=>'Week 8',
					               '9'=>'Week 9',
					               '10'=>'Week 10',
								   '11'=>'Week 11',
					               '12'=>'Week 12',
					               '13'=>'Week 13',
					               '14'=>'Week 14',
					               '15'=>'Week 15',
								   '16'=>'Week 16',
					               '17'=>'Week 17',
					               '18'=>'Week 18',
					               '19'=>'Week 19',
					               '20'=>'Week 20',
								   '21'=>'Week 21',
					               '22'=>'Week 22',
					               '23'=>'Week 23',
					               '24'=>'Week 24'},
				         -default=>'1'
				        );
  print "</FONT></TD>";
  print "<TD BGCOLOR=#CCCCCC><FONT FACE=\"Verdana, Arial, Helvetica, sans-serif\" SIZE=2 COLOR=#000000>";
  print $query->popup_menu(-name=>("endTime$count"),
				         -values=>['1', '2', '3', '4', '5', '6', '7', '8', '9', '10', '11', '12', '13', '14', '15', '16', '17', '18', '19', '20', '21', '22', '23', '24'],
				         -labels=>{'1'=>'Week 1',
					               '2'=>'Week 2',
					               '3'=>'Week 3',
					               '4'=>'Week 4',
					               '5'=>'Week 5',
								   '6'=>'Week 6',
					               '7'=>'Week 7',
					               '8'=>'Week 8',
					               '9'=>'Week 9',
					               '10'=>'Week 10',
								   '11'=>'Week 11',
					               '12'=>'Week 12',
					               '13'=>'Week 13',
					               '14'=>'Week 14',
					               '15'=>'Week 15',
								   '16'=>'Week 16',
					               '17'=>'Week 17',
					               '18'=>'Week 18',
					               '19'=>'Week 19',
					               '20'=>'Week 20',
								   '21'=>'Week 21',
					               '22'=>'Week 22',
					               '23'=>'Week 23',
					               '24'=>'Week 24'},
				         -default=>'1'
				        );
  print "</FONT></TD>";
  print "<TD BGCOLOR=#CCCCCC><FONT FACE=\"Verdana, Arial, Helvetica, sans-serif\" SIZE=2 COLOR=#000000>";
  print $query->popup_menu(-name=>("person$count"),
					     -values=>['FF0000', '0000FF', '008000', 'FFFF00', '800080', '000000', '800000', '000080', '808000', '008080', '808080', 'e6e6fa', '00ff00', '00ffff', 'f0e68c', 'a52a2a', 'ffa500', 'd2b48c', 'ffc0cb', 'ee82ee'],
						 -labels=>{'FF0000'=>$redPerson,
						 		   '0000FF'=>$bluePerson,
								   '008000'=>$greenPerson,
								   'FFFF00'=>$yellowPerson,
								   '800080'=>$purplePerson,
						 		   '000000'=>$blackPerson,
						 		   '800000'=>$maroonPerson,
						 		   '000080'=>$navyPerson,
						 		   '808000'=>$olivePerson,
						 		   '008080'=>$tealPerson,
						 		   '808080'=>$greyPerson,
						 		   'e6e6fa'=>$lavenderPerson,
						 		   '00ff00'=>$limePerson,
						 		   '00ffff'=>$aquaPerson,
						 		   'f0e68c'=>$khakiPerson,
						 		   'a52a2a'=>$brownPerson,
						 		   'ffa500'=>$orangePerson,
						 		   'd2b48c'=>$tanPerson,
						 		   'ffc0cb'=>$pinkPerson,
						 		   'ee82ee'=>$violetPerson},
						 -default=>'FF0000'
						);
  print "</FONT></TD>";

  print "</TR>\n";
} while ($count != $lastQuestion);



print "</TABLE>";

print << "END_HTML";

<BR><BR>

<INPUT TYPE=submit VALUE="Submit">

</FORM>

</BODY>

</HTML>

END_HTML

