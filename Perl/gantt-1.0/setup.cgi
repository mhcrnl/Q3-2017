#!/usr/bin/perl

###########################################################################
#
#  setup.cgi
#
#  Initializes user and stores initial informatino and key on the server.
#  If the user is already on the server, then he is sent to the main page
#    and uses his old information
#
#  Author:  Jason R. Govig  <govig@uiuc.edu>
#    Date:  4/17/98
#    Modified:  10/13/98 (additional characters for username)
#
###########################################################################


use CGI;


require 'dbhelp.pl';

$query = new CGI;

# one word...all lower case
$userid = $query->param('userid');
$userid =~ tr/A-Z/a-z/;		# case insensitive
$userid =~ /\s*(\S*)/;		# first non-white space block
$userid = $1;
$userid =~ s/^\.*//;		# no . files
$query->param('userid', $userid);
$query->param('remotehost', $query->remote_host());

if ($userid eq '') {
  print $query->redirect("${wwwroot}index.html");
  exit 0;
}

$key = &FindUser($query->param('userid'));

if ($key) {
  &ReturningUser($query, $key);
}
else {
  &NewUser($query);
}


# ReturningUser
#    - paramters : CGI query object
#                : session id
#    - returns   : none
#    - setup for a returning user.
sub ReturningUser {
  local($query) = $_[0];
  local($key) = $_[1];
  local($cookie);

  $query = &AppendData(&GetData($key), $query);
  &WriteData($query, $key);

  $cookie = $query->cookie(-name=>$cookieID,
                           -value=>$key,
                           -path=>'/',
                           );
 print $query->redirect(-cookie=>$cookie,
                         -uri=>"${wwwroot}ganttPeople.cgi");

}


# NewUser
#    - parameters : CGI query object
#    - returns    : none
#    - creates a new user
sub NewUser {
  local($query) = $_[0];
  local($key);
  local($cookie);

  $key = $query->param('userid');

  &AddUser($query, $key);

  $cookie = $query->cookie(-name=>$cookieID,
                           -value=>$key,
                           -path=>'/',
                           );
  print $query->redirect(-uri=>"${wwwroot}login2.cgi",
  			 -cookie=>$cookie);
}


