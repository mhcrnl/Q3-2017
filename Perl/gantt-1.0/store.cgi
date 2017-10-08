#!/usr/bin/perl

###########################################################################
#
#  store.cgi
#
#  Stores the information and goes to the next page provided the cookie
#    is set, otherwise go to the intro page.
#
#  Author:  Jason R. Govig  <govig@uiuc.edu>
#    Date:  4/17/98
#
###########################################################################


use CGI;

require 'dbhelp.pl';


$query = new CGI;

$cookie = $query->cookie($cookieID);

if (! $cookie) {
  print $query->redirect(-uri=>"${wwwroot}login.html");
  exit 0;
}

$next = $query->param('next');
$query->delete('next');

$savedQuery = &GetData($cookie);
$query = &AppendData($savedQuery, $query);
&WriteData($query, $cookie);

print $query->redirect(-uri=>"${wwwroot}${next}");


