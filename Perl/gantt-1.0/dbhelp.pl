###########################################################################
#
#  dbhelp.pl
#
#  Routines to easily interface with the flat-file databases.
#
#  user and key values are stored in users/users.txt and user information
#    is stored in users/$key where $key is usually the $time that the
#    person first logged in.
#
#  Author:  Jason R. Govig  <govig@uiuc.edu>
#    Date:  4/17/98
#
###########################################################################


use CGI;

# Edit this to point to the location of your variables.pl file
require '/public_html/gantt/variables.pl';


#########################################################################
###  Do not edit below this point unless you know what you are doing! ###
#########################################################################


# FindUser
#    - parameters : user id name
#    - returns    : users session id or false if not found.
sub FindUser {
  local($user)  = shift;

  if (-e "${docroot}users/$user") {
    return $user;
  }

  return undef; 
}


# AddUser
#    - parameters : CGI query object
#                 : session id
#    - returns    : none
#    - adds a new user to the system, adding the user=key pair to userfile
#      and writing the initial query to a file named by the session id
sub AddUser {
  local($query) = shift;
  local($key) = shift;

  &WriteData($query, $key);
}


# AppendData
#    - parameters : CGI query object 1
#                 : CGI query object 2
#    - returns    : CGI query object containing both object 1 and 2
sub AppendData {
  local($q1) = $_[0];
  local($q2) = $_[1];
  local($temp);

  foreach $name ($q2->param) {
    $q1->param($name, $q2->param($name));
  }

  return $q1;
}


# GetData
#    - parameters : session id
#    - returns    : CGI query object from the users stored info
sub GetData {
  local($key) = $_[0];
  local($userdata);

  open(FILE, "${docroot}users/$key") || &CGIError("Couldn't get user data!");
  $userdata = new CGI(FILE);
  close(FILE);

  return $userdata;
}


# WriteData
#    - parameters : CGI query object
#                 : session id
#    - returns    : none
#    - writes the user's query info to his file ($key)
sub WriteData {
  local($query) = $_[0];
  local($key) = $_[1];

  $query->param('accessed', time);
  $query->delete('submit');

  open(KEYFILE, ">${docroot}users/$key") || &CGIError("Couldn't write user data!"); 
  $query->save(KEYFILE);
  close(KEYFILE);

  chmod(0664, "${docroot}users/$key");
}


# CGIError
#    - parameters : reason
#    - returns    : none
#    - sends an error message to the browser and quits
sub CGIError {
  local($reason) = $_[0];
  local($query);

  $query = new CGI('');
  print $query->header;
  print $query->start_html("Error: ${reason}");
  print "<h1>Error: ${reason}</h1>\n";
  print "Please contact $admin ",
        "(<a href=\"mailto:${adminEmail}\">${adminEmail}</a>) ",
        "stating the error and the events leading up to this error.<p>\n";
  print "Thank you!  Please click your back button to return.\n";
  print $query->end_html;

  die $reason;
}


1;  # return true

