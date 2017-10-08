#!/usr/bin/perl

###########################################################################
#
#  store_check.cgi
#
#  Saves the current information, deleting old that pertains
#  to the part givin.
#
#  Author:  Jason R. Govig  <govig@uiuc.edu>
#    Date:  11/20/98
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

$next = $query->param('next');
$query->delete('next');
$basepart = $query->param('part');
$query->delete('part');

$savedQuery = &GetData($cookie);

$query = &AppendData($savedQuery, $query);
&WriteData($query, $cookie);

print $query->redirect(-uri=>"${wwwroot}${next}");

