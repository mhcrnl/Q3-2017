#!/usr/bin/perl

# this program generates the final (pretty) HTML timeline

use CGI;
use Date::Manip;

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
<SCRIPT language="JavaScript">
<!--
   the_view = window.open("", "preview","toolbar=0,location=0,directories=0,status=0,menubar=0,scrollbars=1,resizable=1,copyhistory=0,width=430,height=200,top=150,left=450");
   the_view.document.open();
   the_view.document.write("<HTML><HEAD>");
   the_view.document.write("<TITLE>Printing Guidelines</TITLE>");
   the_view.document.write("</HEAD><BODY BGCOLOR=FFFFFF TEXT=000000>");
   the_view.document.write("<P><HR><P>");
   the_view.document.write("<U><B><FONT COLOR=red>Printing Guidelines</FONT></B></U>:<P>");
   the_view.document.write("Timelines under 11 weeks will print in portrait on 8.5x11.<BR>");
   the_view.document.write("Timelines from 11-16 weeks will fit landscape on 8.5x11<BR>");
   the_view.document.write("Larger timelines will take multiple pages if larger paper is not used.");
   the_view.document.write("<P><HR><CENTER><FORM><INPUT TYPE='button' VALUE='Close' " + "onClick='self.close();'></FORM>");
   the_view.document.write("</CENTER>");
   the_view.document.write("</BODY></HTML>");
   the_view.document.close();

//-->
</SCRIPT>
<TITLE>Gantt</TITLE></HEAD>
<BODY BGCOLOR=#FFFFFF TEXT=#000000>

<FORM ACTION="store_check.cgi" METHOD="POST">
<INPUT TYPE="Hidden" NAME="part" VALUE="ganttGanttchart">

<FONT FACE="Verdana, Arial, Helvetica, sans-serif" SIZE=4 COLOR=#000000>
<U>
Project Assignment Key
</U>
</FONT>

<BR><BR>

END_HTML


$lastCell = $query->param("endTime1");

#find the last week that the project will go to
for($h = 2; $h <= $lastQuestion; $h++)
	{
	if($query->param("endTime$h") > $lastCell)
		{
		$lastCell = $query->param("endTime$h");
		}
	}

for($i = 1; $i <= $lastQuestion; $i++)
	{
	$startLength[$i] = $query->param("startTime$i");
	$startCells[$i] = $startLength[$i] - 1;
	
	$taskLength[$i] = $query->param("endTime$i") - $query->param("startTime$i");
	$taskCells[$i] = $taskLength[$i] + 1;
	
	$taskPic[$i] = $query->param("person$i");
	
	$endCells[$i] = $lastCell - $query->param("endTime$i");
	}

$startPic = "FFFFFF";
$endPic = "FFFFFF";


@format = ("%a", "%m", "%d", "%Y");

	#argument = %a
	#explanation = day of the week
	#return = Sun - Sat

	#argument = %m
	#explanation = month of the year
	#return = 01 - 12

	#argument = %d
	#explanation = day of the month
	#return = 01 - 31

	#argument = %Y
	#explanation = year
	#return = 0000 - 9999

$tempEndDate = $lastCell + 1;
$endDate = &DateCalc("$month/$day/$year", "+ $tempEndDate weeks");
#calculate the date of the week of the last project action + 1 from the start of the project

@tempWeeks = &ParseRecur("0:0:1:0:0:0:0", "$month/$day/$year", "$month/$day/$year", "$endDate");
#calculate an array of dates, 1 week after another

$n = 1;
for($k = 0; $k <= $lastCell; $k++)
	{
	@tempFormattedWeeks = &UnixDate($tempWeeks[$k], @format);
	$weeks[$n] = [ @tempFormattedWeeks ];	

		#set up a 2 dimensional array
			#1st dimension = the week from 1 to $lastCell + 1
			#2nd dimension = day of the week, month, day of the month, year
	$n++;
	}



($currentSeconds, $currentMinutes, $currentHour, $currentDayofthemonth, $currentMonth, $currentYear, $currentWeekday, $currentDayoftheyear, $currentIsdst) = localtime(time);

$currentYear = $currentYear + 1900;
#$currentYear is initially returned as years since 1900

$currentMonth++;
#$currentMonth is initially returned as 00 through 11


print "<TABLE BORDER=0>";	
if($redPerson) {print "<TR><TD BGCOLOR=FF0000><IMG SRC=\"images/FF0000.gif\" BORDER=0 HEIGHT=10 WIDTH=10></TD><TD>= $redPerson </TD></TR>";}
if($bluePerson) {print "<TR><TD BGCOLOR=0000FF><IMG SRC=\"images/0000FF.gif\" BORDER=0 HEIGHT=10 WIDTH=10></TD><TD>= $bluePerson </TD></TR>";}
if($greenPerson) {print "<TR><TD BGCOLOR=008000><IMG SRC=\"images/008000.gif\" BORDER=0 HEIGHT=10 WIDTH=10></TD><TD>= $greenPerson </TD></TR>";}
if($yellowPerson) {print "<TR><TD BGCOLOR=FFFF00><IMG SRC=\"images/FFFF00.gif\" BORDER=0 HEIGHT=10 WIDTH=10></TD><TD>= $yellowPerson </TD></TR>";}
if($purplePerson) {print "<TR><TD BGCOLOR=800080><IMG SRC=\"images/800080.gif\" BORDER=0 HEIGHT=10 WIDTH=10></TD><TD>= $purplePerson </TD></TR>";}

if($blackPerson) {print "<TR><TD BGCOLOR=000000><IMG SRC=\"images/000000.gif\" BORDER=0 HEIGHT=10 WIDTH=10></TD><TD>= $blackPerson </TD></TR>";}
if($maroonPerson) {print "<TR><TD BGCOLOR=800000><IMG SRC=\"images/800000.gif\" BORDER=0 HEIGHT=10 WIDTH=10></TD><TD>= $maroonPerson </TD></TR>";}
if($navyPerson) {print "<TR><TD BGCOLOR=000080><IMG SRC=\"images/000080.gif\" BORDER=0 HEIGHT=10 WIDTH=10></TD><TD>= $navyPerson </TD></TR>";}
if($olivePerson) {print "<TR><TD BGCOLOR=808000><IMG SRC=\"images/808000.gif\" BORDER=0 HEIGHT=10 WIDTH=10></TD><TD>= $olivePerson </TD></TR>";}
if($tealPerson) {print "<TR><TD BGCOLOR=008080><IMG SRC=\"images/008080.gif\" BORDER=0 HEIGHT=10 WIDTH=10></TD><TD>= $tealPerson </TD></TR>";}

if($greyPerson) {print "<TR><TD BGCOLOR=808080><IMG SRC=\"images/808080.gif\" BORDER=0 HEIGHT=10 WIDTH=10></TD><TD>= $greyPerson </TD></TR>";}
if($lavenderPerson) {print "<TR><TD BGCOLOR=e6e6fa><IMG SRC=\"images/e6e6fa.gif\" BORDER=0 HEIGHT=10 WIDTH=10></TD><TD>= $lavenderPerson </TD></TR>";}
if($limePerson) {print "<TR><TD BGCOLOR=00ff00><IMG SRC=\"images/00ff00.gif\" BORDER=0 HEIGHT=10 WIDTH=10></TD><TD>= $limePerson </TD></TR>";}
if($aquaPerson) {print "<TR><TD BGCOLOR=00ffff><IMG SRC=\"images/00ffff.gif\" BORDER=0 HEIGHT=10 WIDTH=10></TD><TD>= $aquaPerson </TD></TR>";}
if($khakiPerson) {print "<TR><TD BGCOLOR=f0e68c><IMG SRC=\"images/f0e68c.gif\" BORDER=0 HEIGHT=10 WIDTH=10></TD><TD>= $khakiPerson </TD></TR>";}

if($brownPerson) {print "<TR><TD BGCOLOR=a52a2a><IMG SRC=\"images/a52a2a.gif\" BORDER=0 HEIGHT=10 WIDTH=10></TD><TD>= $brownPerson </TD></TR>";}
if($orangePerson) {print "<TR><TD BGCOLOR=ffa500><IMG SRC=\"images/ffa500.gif\" BORDER=0 HEIGHT=10 WIDTH=10></TD><TD>= $orangePerson </TD></TR>";}
if($tanPerson) {print "<TR><TD BGCOLOR=d2b48c><IMG SRC=\"images/d2b48c.gif\" BORDER=0 HEIGHT=10 WIDTH=10></TD><TD>= $tanPerson </TD></TR>";}
if($pinkPerson) {print "<TR><TD BGCOLOR=ffc0cb><IMG SRC=\"images/ffc0cb.gif\" BORDER=0 HEIGHT=10 WIDTH=10></TD><TD>= $pinkPerson </TD></TR>";}
if($violetPerson) {print "<TR><TD BGCOLOR=ee82ee><IMG SRC=\"images/ee82ee.gif\" BORDER=0 HEIGHT=10 WIDTH=10></TD><TD>= $violetPerson </TD></TR>";}
print "</TABLE>";

print "<BR>";

print "<H4>Start date: $month / $day / $year</H4>";
print "<H2 ALIGN=center>Project: $projName</H2>";

print << "END_HTML";

<P>



<TABLE BORDER=1 CELLPADDING=3 CELLSPACING=0>

<TR>

<TD WIDTH=300 NOWRAP ALIGN=right>
<FONT FACE="Verdana, Arial, Helvetica, sans-serif" SIZE=2 COLOR=#000000>
Current Week
</TD>

END_HTML

for($t = 1; $t <= $lastCell; $t++)
	{
	$flag = 0;
	
	if($weeks[$t][3] == $currentYear)
		{
		$flag++;
		}
		
	if($weeks[$t][1] == $currentMonth)
		{
		$flag++;
		}
		
	if(($weeks[$t][2] <= $currentDayofthemonth) && ($weeks[$t+1][2] >= $currentDayofthemonth))
		{
		$flag++;
		}

	print"<TD>";
	
	if($flag == 3) 
			#flag == 3 when the date has the right year, month, and is between the right dates
		{
		print "<DIV ALIGN=center><IMG SRC=\"images/downArrow.gif\" HEIGHT=30 WIDTH=30 BORDER=0></DIV>";
		}
	
	else
		{
		print "&nbsp;";
		}
		
	print "</TD>\n";

	}
	
print << "END_HTML";
	
</TR>
<TR>

<TD WIDTH=300 NOWRAP ALIGN=right>
<FONT FACE="Verdana, Arial, Helvetica, sans-serif" SIZE=2 COLOR=#000000>
Weeks<P ALIGN=left><B>Tasks</B></P>
</TD>

END_HTML

for($r = 1; $r <= $lastCell; $r++)
	{
	print "<TD ALIGN=center>";
	print "<FONT FACE=\"Verdana, Arial, Helvetica, sans-serif\" SIZE=2 COLOR=#000000>";
	print "$weeks[$r][1]/$weeks[$r][2]";
	print "<BR>to<BR>";
	print "$weeks[$r+1][1]/$weeks[$r+1][2]";
	print "</TD>\n";
	}

sub FillCells()
	{
	
	$currentQuestion = $_[0];

	if($startCells[$currentQuestion] != 0)
		{
		for($a2 = 1; $a2 <= $startCells[$currentQuestion]; $a2++)
			{
			print "<TD BGCOLOR=#$startPic>";
			print "&nbsp;";
			print "</TD>\n";
			}
		}

	for($a3 = 1; $a3 <= $taskCells[$currentQuestion]; $a3++)
		{
		print "<TD ALIGN=center BGCOLOR=$taskPic[$currentQuestion]>";

		# this is pathetically crude...a better way would save some CPU time!
		if ("$taskPic[$currentQuestion]" eq "FF0000") {
		  print "<IMG SRC=\"images/$taskPic[$currentQuestion].gif\" HEIGHT=20 WIDTH=30 ALT=\"$redPerson\">";}
		elsif ("$taskPic[$currentQuestion]" eq "0000FF") {
		  print "<IMG SRC=\"images/$taskPic[$currentQuestion].gif\" HEIGHT=20 WIDTH=30 ALT=\"$bluePerson\">";}
		elsif ("$taskPic[$currentQuestion]" eq "008000") {
		  print "<IMG SRC=\"images/$taskPic[$currentQuestion].gif\" HEIGHT=20 WIDTH=30 ALT=\"$greenPerson\">";}
		elsif ("$taskPic[$currentQuestion]" eq "FFFF00") {
		  print "<IMG SRC=\"images/$taskPic[$currentQuestion].gif\" HEIGHT=20 WIDTH=30 ALT=\"$yellowPerson\">";}
		elsif ("$taskPic[$currentQuestion]" eq "800080") {
		  print "<IMG SRC=\"images/$taskPic[$currentQuestion].gif\" HEIGHT=20 WIDTH=30 ALT=\"$purplePerson\">";}
		elsif ("$taskPic[$currentQuestion]" eq "000000") {
		  print "<IMG SRC=\"images/$taskPic[$currentQuestion].gif\" HEIGHT=20 WIDTH=30 ALT=\"$blackPerson\">";}
		elsif ("$taskPic[$currentQuestion]" eq "800000") {
		  print "<IMG SRC=\"images/$taskPic[$currentQuestion].gif\" HEIGHT=20 WIDTH=30 ALT=\"$maroonPerson\">";}
		elsif ("$taskPic[$currentQuestion]" eq "000080") {
		  print "<IMG SRC=\"images/$taskPic[$currentQuestion].gif\" HEIGHT=20 WIDTH=30 ALT=\"$navyPerson\">";}
		elsif ("$taskPic[$currentQuestion]" eq "808000") {
		  print "<IMG SRC=\"images/$taskPic[$currentQuestion].gif\" HEIGHT=20 WIDTH=30 ALT=\"$olivePerson\">";}
		elsif ("$taskPic[$currentQuestion]" eq "008080") {
		  print "<IMG SRC=\"images/$taskPic[$currentQuestion].gif\" HEIGHT=20 WIDTH=30 ALT=\"$tealPerson\">";}
		elsif ("$taskPic[$currentQuestion]" eq "808080") {
		  print "<IMG SRC=\"images/$taskPic[$currentQuestion].gif\" HEIGHT=20 WIDTH=30 ALT=\"$greyPerson\">";}
		elsif ("$taskPic[$currentQuestion]" eq "e6e6fa") {
		  print "<IMG SRC=\"images/$taskPic[$currentQuestion].gif\" HEIGHT=20 WIDTH=30 ALT=\"$lavenderPerson\">";}
		elsif ("$taskPic[$currentQuestion]" eq "00ff00") {
		  print "<IMG SRC=\"images/$taskPic[$currentQuestion].gif\" HEIGHT=20 WIDTH=30 ALT=\"$limePerson\">";}
		elsif ("$taskPic[$currentQuestion]" eq "00ffff") {
		  print "<IMG SRC=\"images/$taskPic[$currentQuestion].gif\" HEIGHT=20 WIDTH=30 ALT=\"$aquaPerson\">";}
		elsif ("$taskPic[$currentQuestion]" eq "f0e68c") {
		  print "<IMG SRC=\"images/$taskPic[$currentQuestion].gif\" HEIGHT=20 WIDTH=30 ALT=\"$khakiPerson\">";}
		elsif ("$taskPic[$currentQuestion]" eq "a52a2a") {
		  print "<IMG SRC=\"images/$taskPic[$currentQuestion].gif\" HEIGHT=20 WIDTH=30 ALT=\"$brownPerson\">";}
		elsif ("$taskPic[$currentQuestion]" eq "ffa500") {
		  print "<IMG SRC=\"images/$taskPic[$currentQuestion].gif\" HEIGHT=20 WIDTH=30 ALT=\"$orangePerson\">";}
		elsif ("$taskPic[$currentQuestion]" eq "d2b48c") {
		  print "<IMG SRC=\"images/$taskPic[$currentQuestion].gif\" HEIGHT=20 WIDTH=30 ALT=\"$tanPerson\">";}
		elsif ("$taskPic[$currentQuestion]" eq "ffc0cb") {
		  print "<IMG SRC=\"images/$taskPic[$currentQuestion].gif\" HEIGHT=20 WIDTH=30 ALT=\"$pinkPerson\">";}
		elsif ("$taskPic[$currentQuestion]" eq "ee82ee") {
		  print "<IMG SRC=\"images/$taskPic[$currentQuestion].gif\" HEIGHT=20 WIDTH=30 ALT=\"$violetPerson\">";}
		  
		print "</TD>\n";
		}

	if($endCells[$currentQuestion] != 0)
		{
		for($a4 = 1; $a4 <= $endCells[$currentQuestion]; $a4++)
			{
			print "<TD BGCOLOR=#$endPic>";
			print "&nbsp;";
			print "</TD>\n";
			}
		}
	}


$count = 0;
do {
  $count++;
  
  print "</TR>\n";
  print "<TR>";

  print "<TD WIDTH=300>";
  print "<FONT FACE=\"Verdana, Arial, Helvetica, sans-serif\" SIZE=2 COLOR=#000000>";
  print "$task[$count]";
  print "</TD>\n";

  &FillCells($count);
  
} while (($count != $lastQuestion) && ($task[$count+1]));


print "</TR>\n";
print "<TR>";

print "<TD WIDTH=300 NOWRAP ALIGN=left>";
print "<FONT FACE=\"Verdana, Arial, Helvetica, sans-serif\" SIZE=2 COLOR=#000000>";
print "<B>Tasks</B><P ALIGN=right>Weeks</P>";
print "</TD>\n";

for($r = 1; $r <= $lastCell; $r++)
	{
	print "<TD>";
	print "<FONT FACE=\"Verdana, Arial, Helvetica, sans-serif\" SIZE=2 COLOR=#000000>";
	print "$weeks[$r][1]/$weeks[$r][2]";
	print "<BR><DIV ALIGN=center>to</DIV>";
	print "$weeks[$r+1][1]/$weeks[$r+1][2]";
	print "</TD>\n";
	}


print "</TR>\n";
print "<TR>";

print "<TD WIDTH=300 NOWRAP ALIGN=right>";
print "<FONT FACE=\"Verdana, Arial, Helvetica, sans-serif\" SIZE=2 COLOR=#000000>";
print "Current Week";
print "</TD>\n";

for($t = 1; $t <= $lastCell; $t++)
	{
	$flag = 0;
	
	if($weeks[$t][3] == $currentYear)
		{
		$flag++;
		}
		
	if($weeks[$t][1] == $currentMonth)
		{
		$flag++;
		}
		
	if(($weeks[$t][2] <= $currentDayofthemonth) && ($weeks[$t+1][2] >= $currentDayofthemonth))
		{
		$flag++;
		}

	print"<TD>";
	
	if($flag == 3)
		{
		print "<DIV ALIGN=center><IMG SRC=\"images/upArrow.gif\" HEIGHT=30 WIDTH=30 BORDER=0></DIV>";
		}
	
	else
		{
		print "&nbsp;";
		}
		
	print "</TD>\n";

	}


print << "END_HTML";


</TR>


</TABLE>

</BODY>
</HTML>

END_HTML


