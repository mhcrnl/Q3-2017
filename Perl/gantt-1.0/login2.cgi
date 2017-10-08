#!/usr/bin/perl

###########################################################################
#
#  login-c.cgi
#
#  Stores the information and goes to the next page provided the cookie
#    is set, otherwise go to the intro page.
#
#  Author:  Jason R. Govig  <govig@uiuc.edu>
#  Co-Author:  Seth Goldstein  <sgoldstn@uiuc.edu>
#    Date:  4/17/98
#
###########################################################################


use CGI;

require 'dbhelp.pl';


$query = new CGI;

$cookie = $query->cookie($cookieID);

if (! $cookie) {
  print $query->redirect(-uri=>"${wwwroot}intro.html");
  exit 0;
}

$query = &GetData($cookie);
print $query->header;


print <<'ENDPRINT';
<html>

<head>
<title>Community Development Learning Laboratory</title>

ENDPRINT

print << 'END_JSCRIPT';

<SCRIPT LANGUAGE="JavaScript">

<!--

function validate()
	{

	if(window.document.login.location[0].checked == 1)

		{
		if((window.document.login.state.value == "") || (window.document.login.county.value == ""))
			{
			alert("You cannot leave the County or State fields empty \nif you live in the United States.");
			return false;
			}

		else
			{
			return true;
			}
		}

	if(window.document.login.location[1].checked == 1)
		
		{
		if(window.document.login.province.value == "")
			{
			alert("You cannot leave the Province field empty \nif you live in Canada.");
			return false;
			}
			
		else
			{
			return true;
			}
		}
		
	if(window.document.login.location[2].checked == 1)

		{
		if(window.document.login.country.value == "")
			{
			alert("You cannot leave the Country field empty \nif you live outside the United States and Canada.");
			return false;
			}
			
		else
			{
			return true;
			}
		}
				
	}

// --> 

</SCRIPT>

END_JSCRIPT

print <<'ENDPRINT';


</head>
    
<body bgcolor="#ffffff" text="#000000" link="#996666"
 alink="#006699" vlink="#006699">
      
<!-- <img src="images/project.gif" border=0 alt="Conduct a Project for your Organization"> -->

<p>

<form name="login" action="store.cgi" method="get" onSubmit="return validate()">

<input type=hidden name="next" value="ganttPeople.cgi">

<table border=0 cellpadding=2 cellspacing=2>
<tr><th colspan=5 bgcolor="#996666" align="left"><font color="#ffffff">Please tell us a little more about yourself</font></th></tr>


ENDPRINT


print "<tr>\n<td bgcolor=\"#cccccc\"> Contact Name: </td>";
print "<td colspan=4 align=left bgcolor=\"#cccccc\">",
      $query->textfield(-name=>'name', -size=>60);
print "</td></tr>\n<tr><td bgcolor=\"#cccccc\">Phone: </td>";
print "<td bgcolor=\"#cccccc\" colspan=4>",
      $query->textfield(-name=>'phone', -size=>60);
print "</td></tr>\n<tr><td bgcolor=\"#cccccc\"> Email: </td>";
print "<td align=left bgcolor=\"#cccccc\" colspan=4>",
      $query->textfield(-name=>'email', -size=>60);
print "</td></tr>\n<tr><td bgcolor=\"#cccccc\">Community: </td>";
print "<td colspan=4 align=left bgcolor=\"#cccccc\">",
      $query->textfield(-name=>'community', -size=>60);


	 
print "</TD>\n</TR>\n\n\n<TR><TD BGCOLOR=#CCCCCC>Country: </TD>\n";
print "<TD BGCOLOR=#CCCCCC>",
	 $query->radio_group(-name=>'location', -values=>['United States'], -default=>'United States');
print "</TD>\n<TD BGCOLOR=#CCCCCC COLSPAN=2>",
	 $query->radio_group(-name=>'location', -values=>['Canada'], -default=>'United States');
print "<IMG SRC=\"images/grey.gif\" BORDER=0 HEIGHT=1 WIDTH=30>";
print "</TD>\n<TD BGCOLOR=#CCCCCC>",
	 $query->radio_group(-name=>'location', -values=>['Outside the United States and Canada'], -default=>'United States');


print "</TD>\n</TR>\n";
print "<TR><TD BGCOLOR=#CCCCCC COLSPAN=5>&nbsp</TD></TR>\n";


print "<TR>\n<TD BGCOLOR=#CCCCCC>If United States: </TD>\n";
print "<TD BGCOLOR=#CCCCCC COLSPAN=2>County: ";
print "<IMG SRC=\"images/grey.gif\" BORDER=0 HEIGHT=1 WIDTH=9>",
	 $query->textfield(-name=>'county', -size=>20);
print "<IMG SRC=\"images/grey.gif\" BORDER=0 HEIGHT=1 WIDTH=20>";
print "</TD>\n<TD BGCOLOR=#CCCCCC COLSPAN=2>State: ",
	 $query->textfield(-name=>'state', -size=>20);
print "</TD></TR>\n";


print "<TR>\n<TD BGCOLOR=#CCCCCC>If Canada: </TD>\n";
print "<TD BGCOLOR=#CCCCCC COLSPAN=4>Province: ",
	 $query->textfield(-name=>'province', -size=>20);
print "</TD></TR>\n";


print "<TR>\n<TD BGCOLOR=#CCCCCC>If Outside: </TD>\n";
print "<TD BGCOLOR=#CCCCCC COLSPAN=4>Country: ";
print "<IMG SRC=\"images/grey.gif\" BORDER=0 HEIGHT=1 WIDTH=4>",
	 $query->textfield(-name=>'country', -size=>20);
print "</TD></TR>\n";

print "</TABLE>";


print <<'ENDPRINT';


<br>

<input type="submit" value="Finish Login">

</form>

</body>

</html>

ENDPRINT

