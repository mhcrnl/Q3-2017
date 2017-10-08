###########################################################################
#
#  variables.pl
#
#  Helpful variables to be used throughout the script to make modifications
#    and site changes easy.
#
#  Author:  Jason R. Govig  <govig@uiuc.edu>
#    Date:  5/22/98
#
###########################################################################

# NOTE:  edit dbhelp.pl to set the full path to this file

# full path to site on server
$docroot = '/public_html/gantt/';

# URL of site
$wwwroot = 'http://associate.com/gantt/';

# name of stored cookie
$cookieID = 'sessionID_gantt';

# Name of site administrator
$admin = 'Webmaster';

# Email of site administrator
$adminEmail = 'errors@associate.com';

# How many Tasks we will allow the user to enter (this could be abused otherwise)
$lastQuestion = 50;


1;

