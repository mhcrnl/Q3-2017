#!/usr/bin/perl

# this program lets the user define people involved with the project

use CGI;


require 'dbhelp.pl';

$query = new CGI;

$cookie = $query->cookie($cookieID);

if (! $cookie) {
  print $query->redirect(-uri=>"${wwwroot}index.html");
  exit 0;
}

$query = &GetData($cookie);

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

$projName = $query->param('projName');

print $query->header;

print << "END_HTML";

<HTML>
<HEAD><TITLE>Gantt</TITLE></HEAD>
<BODY BGCOLOR=#FFFFFF TEXT=#000000>

<FORM ACTION="store_check.cgi" METHOD="POST">
<INPUT TYPE="Hidden" NAME="next" VALUE="ganttTimechart.cgi">
<INPUT TYPE="Hidden" NAME="part" VALUE="ganttPeople">

<FONT FACE="Verdana, Arial, Helvetica, sans-serif" SIZE=4 COLOR=#000000>
<U>Create a Timetable For Your Project</U>
</FONT>

<BR><BR>

<TABLE CELLPADDING=2 CELLSPACING=2 BORDER=0>

<TR>
<TD BGCOLOR=#996666><FONT FACE="Verdana, Arial, Helvetica, sans-serif" SIZE=2 COLOR=#FFFFFF>
<B>What is the Name of your project?</B>
</TD>
</TR>

<TR>
<TD BGCOLOR=#CCCCCC><FONT FACE="Verdana, Arial, Helvetica, sans-serif" SIZE=2 COLOR=#000000>
Project: <INPUT TYPE=text SIZE=32 NAME="projName" VALUE="$projName">
</TD>
</TR>
</TABLE>

<BR><BR>

<TABLE CELLPADDING=2 CELLSPACING=2 BORDER=0>

<TR>
<TD BGCOLOR=#996666 WIDTH=600><FONT FACE="Verdana, Arial, Helvetica, sans-serif" SIZE=2 COLOR=#FFFFFF>
<B>The following activity helps create a <U>Gantt Chart</U> or timetable for your particular activity.  
For each field below, enter the name of a person who is accountable for a certain project task.  
Use as many fields as you need, leaving the others blank.
</B>
</TD>
</TR>

<TR>
<TD BGCOLOR=#CCCCCC><FONT FACE="Verdana, Arial, Helvetica, sans-serif" SIZE=2 COLOR=#000000>
<INPUT TYPE=text NAME="redPerson" SIZE=20 VALUE="$redPerson">
(will be displayed in <FONT COLOR=#FF0000> RED </FONT>)
</TD>
</TR>

<TR>
<TD BGCOLOR=#CCCCCC><FONT FACE="Verdana, Arial, Helvetica, sans-serif" SIZE=2 COLOR=#000000>
<INPUT TYPE=text NAME="bluePerson" SIZE=20 VALUE="$bluePerson">
(will be displayed in <FONT COLOR=#0000FF> BLUE </FONT>)
</TD>
</TR>

<TR>
<TD BGCOLOR=#CCCCCC><FONT FACE="Verdana, Arial, Helvetica, sans-serif" SIZE=2 COLOR=#000000>
<INPUT TYPE=text NAME="greenPerson" SIZE=20 VALUE="$greenPerson">
(will be displayed in <FONT COLOR=#008000> GREEN </FONT>)
</TD>
</TR>

<TR>
<TD BGCOLOR=#CCCCCC><FONT FACE="Verdana, Arial, Helvetica, sans-serif" SIZE=2 COLOR=#000000>
<INPUT TYPE=text NAME="yellowPerson" SIZE=20 VALUE="$yellowPerson">
(will be displayed in <FONT COLOR=#FFFF00> YELLOW </FONT>)
</TD>
</TR>

<TR>
<TD BGCOLOR=#CCCCCC><FONT FACE="Verdana, Arial, Helvetica, sans-serif" SIZE=2 COLOR=#000000>
<INPUT TYPE=text NAME="purplePerson" SIZE=20 VALUE="$purplePerson">
(will be displayed in <FONT COLOR=#800080> PURPLE </FONT>)
</TD>
</TR>

<TR>
<TD BGCOLOR=#CCCCCC><FONT FACE="Verdana, Arial, Helvetica, sans-serif" SIZE=2 COLOR=#000000>
<INPUT TYPE=text NAME="blackPerson" SIZE=20 VALUE="$blackPerson">
(will be displayed in <FONT COLOR=#000000> BLACK </FONT>)
</TD>
</TR>

<TR>
<TD BGCOLOR=#CCCCCC><FONT FACE="Verdana, Arial, Helvetica, sans-serif" SIZE=2 COLOR=#000000>
<INPUT TYPE=text NAME="maroonPerson" SIZE=20 VALUE="$maroonPerson">
(will be displayed in <FONT COLOR=#800000> MAROON </FONT>)
</TD>
</TR>

<TR>
<TD BGCOLOR=#CCCCCC><FONT FACE="Verdana, Arial, Helvetica, sans-serif" SIZE=2 COLOR=#000000>
<INPUT TYPE=text NAME="navyPerson" SIZE=20 VALUE="$navyPerson">
(will be displayed in <FONT COLOR=#000080> NAVY </FONT>)
</TD>
</TR>

<TR>
<TD BGCOLOR=#CCCCCC><FONT FACE="Verdana, Arial, Helvetica, sans-serif" SIZE=2 COLOR=#000000>
<INPUT TYPE=text NAME="olivePerson" SIZE=20 VALUE="$olivePerson">
(will be displayed in <FONT COLOR=#808000> OLIVE </FONT>)
</TD>
</TR>

<TR>
<TD BGCOLOR=#CCCCCC><FONT FACE="Verdana, Arial, Helvetica, sans-serif" SIZE=2 COLOR=#000000>
<INPUT TYPE=text NAME="tealPerson" SIZE=20 VALUE="$tealPerson">
(will be displayed in <FONT COLOR=#008080> TEAL </FONT>)
</TD>
</TR>

<TR>
<TD BGCOLOR=#CCCCCC><FONT FACE="Verdana, Arial, Helvetica, sans-serif" SIZE=2 COLOR=#000000>
<INPUT TYPE=text NAME="greyPerson" SIZE=20 VALUE="$greyPerson">
(will be displayed in <FONT COLOR=#808080> GREY </FONT>)
</TD>
</TR>

<TR>
<TD BGCOLOR=#CCCCCC><FONT FACE="Verdana, Arial, Helvetica, sans-serif" SIZE=2 COLOR=#000000>
<INPUT TYPE=text NAME="lavenderPerson" SIZE=20 VALUE="$lavenderPerson">
(will be displayed in <FONT COLOR=#e6e6fa> LAVENDER </FONT>)
</TD>
</TR>

<TR>
<TD BGCOLOR=#CCCCCC><FONT FACE="Verdana, Arial, Helvetica, sans-serif" SIZE=2 COLOR=#000000>
<INPUT TYPE=text NAME="limePerson" SIZE=20 VALUE="$limePerson">
(will be displayed in <FONT COLOR=#00ff00> LIME </FONT>)
</TD>
</TR>

<TR>
<TD BGCOLOR=#CCCCCC><FONT FACE="Verdana, Arial, Helvetica, sans-serif" SIZE=2 COLOR=#000000>
<INPUT TYPE=text NAME="aquaPerson" SIZE=20 VALUE="$aquaPerson">
(will be displayed in <FONT COLOR=#00ffff> AQUA </FONT>)
</TD>
</TR>

<TR>
<TD BGCOLOR=#CCCCCC><FONT FACE="Verdana, Arial, Helvetica, sans-serif" SIZE=2 COLOR=#000000>
<INPUT TYPE=text NAME="khakiPerson" SIZE=20 VALUE="$khakiPerson">
(will be displayed in <FONT COLOR=#f0e68c> KHAKI </FONT>)
</TD>
</TR>

<TR>
<TD BGCOLOR=#CCCCCC><FONT FACE="Verdana, Arial, Helvetica, sans-serif" SIZE=2 COLOR=#000000>
<INPUT TYPE=text NAME="brownPerson" SIZE=20 VALUE="$brownPerson">
(will be displayed in <FONT COLOR=#a52a2a> BROWN </FONT>)
</TD>
</TR>

<TR>
<TD BGCOLOR=#CCCCCC><FONT FACE="Verdana, Arial, Helvetica, sans-serif" SIZE=2 COLOR=#000000>
<INPUT TYPE=text NAME="orangePerson" SIZE=20 VALUE="$orangePerson">
(will be displayed in <FONT COLOR=#ffa500> ORANGE </FONT>)
</TD>
</TR>

<TR>
<TD BGCOLOR=#CCCCCC><FONT FACE="Verdana, Arial, Helvetica, sans-serif" SIZE=2 COLOR=#000000>
<INPUT TYPE=text NAME="tanPerson" SIZE=20 VALUE="$tanPerson">
(will be displayed in <FONT COLOR=#d2b48c> TAN </FONT>)
</TD>
</TR>

<TR>
<TD BGCOLOR=#CCCCCC><FONT FACE="Verdana, Arial, Helvetica, sans-serif" SIZE=2 COLOR=#000000>
<INPUT TYPE=text NAME="pinkPerson" SIZE=20 VALUE="$pinkPerson">
(will be displayed in <FONT COLOR=#ffc0cb> PINK </FONT>)
</TD>
</TR>

<TR>
<TD BGCOLOR=#CCCCCC><FONT FACE="Verdana, Arial, Helvetica, sans-serif" SIZE=2 COLOR=#000000>
<INPUT TYPE=text NAME="violetPerson" SIZE=20 VALUE="$violetPerson">
(will be displayed in <FONT COLOR=#ee82ee> VIOLET </FONT>)
</TD>
</TR>

</TABLE>

<INPUT TYPE=submit VALUE="Submit">

</FORM>

<BR><BR>

<FONT FACE="Verdana, Arial, Helvetica, sans-serif" SIZE=2 COLOR=#000000>
<I>

*If you have already created your Gantt chart and would like to view it,
<BR>
you may do so <A HREF="ganttChart.cgi">here.</A>

<BR><BR>

*If you have already created your Gantt chart and would like to modify it,
<BR>
please follow the same steps used during the creation of the chart and modify it where necessary.

</I>

</FONT>

</BODY>

</HTML>

END_HTML

