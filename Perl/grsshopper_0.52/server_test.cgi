#!/usr/bin/perl

#    gRSShopper 0.1  Server Test  0.1  -- gRSShopper server test module
#    Copyright (C) <2008>  <Stephen Downes, National Research Council Canada>

#    This program is free software: you can redistribute it and/or modify
#    it under the terms of the GNU General Public License as published by
#    the Free Software Foundation, either version 3 of the License, or
#    (at your option) any later version.

#    This program is distributed in the hope that it will be useful,
#    but WITHOUT ANY WARRANTY; without even the implied warranty of
#    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
#    GNU General Public License for more details.

#    You should have received a copy of the GNU General Public License
#    along with this program.  If not, see <http://www.gnu.org/licenses/>.


##########################################################################
# Servertest.pl
##########################################################################

# -----------------------------------------------------
# Check that all of the required modules can be located

$|++;
my $missing = 0;

# ---------------------------------
# Let's see what our environment is
  if (!$ENV{'SERVER_SOFTWARE'}) {
    $newline = "\n";
  }
  else {
    print "Content-type: text/html\n\n";
    $newline = "<br>";
   }

print "gRSShopper web server environment test.".$newline.$newline;



# --------------------------------------
# Check for the required version of PERL
  eval "require 5.004";
  print "Checking PERL version...";
  if ($@) {
    print "$newline"."This program requires at least PERL version 5.004 or greater.$newline";
    $missing=1;
  } else { 
	print " OK$newline"; 
  }
# -------------
# Check for CGI
  print "Checking for CGI. This module handles form input functions.";
  eval "use CGI";
  if ($@) {
    print "$newline"."The CGI module could not be located.$newline";
    $missing=1;
  } else { 
	print " OK$newline"; 
  }

# -------------
# Check for CGI::Carp
  print "Checking for CGI::Carp. This module displays error messages.";
  eval "use CGI::Carp";
  if ($@) {
    print "$newline"."The CGI::Carp module could not be located.$newline";
    $missing=1;
  } else { 
	print " OK$newline"; 
  }

# -------------
# Check for DBI
  print "Checking for DBI. This module handles database functions.";
  eval "use DBI";
  if ($@) {
    print "$newline"."The DBI module could not be located.$newline";
    $missing=1;
  } else { 
	print " OK$newline"; 
  }


# -------------
# Check for LWP
  print "Checking for LWP. This module connects to other web servers.";
  eval "use LWP";
  if ($@) {
    print "$newline"."The LWP module could not be located.$newline";
    $missing=1;
  } else { 
	print " OK$newline"; 
  }


# -------------
# Check for LWP::UserAgent
  print "Checking for LWP::UserAgent. This module emulates a web browser.";
  eval "use LWP::UserAgent";
  if ($@) {
    print "$newline"."The LWP::UserAgent module could not be located.$newline";
    $missing=1;
  } else { 
	print " OK$newline"; 
  }

# -------------
# Check for LWP::Simple
  print "Checking for LWP::Simple. This module emulates a web browser.";
  eval "use LWP::Simple";
  if ($@) {
    print "$newline"."The LWP::Simple module could not be located.$newline";
    $missing=1;
  } else { 
	print " OK$newline"; 
  }
  
# -------------
# Check for File::Basename
  print "Checking for File::Basename. This analyzes file names and is used for file uploads.";
  eval "use File::Basename";
  if ($@) {
    print "$newline"."The File::Basename module could not be located. Some admin functions may not work.$newline";
    $missing=1;
  } else { 
	print " OK$newline"; 
  }
	
# -------------
# Check for File::stat
  print "Checking for File::stat. This examines files and is used for file uploads.";
  eval "use File::stat";
  if ($@) {
    print "$newline"."The File::stat module could not be located. Some admin functions may not work.$newline";
    $missing=1;
  } else { 
	print " OK$newline"; 
  }	
  
  
    # -------------
   
# Check for MIME::Types
  print "Checking for MIME::Types. This determines the file type of uploaded files)";
  eval "use MIME::Types";
  if ($@) {
    print "$newline"."The MIME::Types module could not be located. Admin will not work properly.$newline";
    $missing=1;
  } else { 
	print " OK$newline"; 
  }
  	 
  
 # -------------
# Check for HTML::Entities
  print "Checking for HTML::Entities. This encodes and decodes strings with HTML entities.";
  eval "use HTML::Entities";
  if ($@) {
    print "$newline"."The HTML::Entities module could not be located. Some admin functions may not work.$newline";
    $missing=1;
  } else { 
	print " OK$newline"; 
  }	 
  
 # -------------
# Check for Scalar::Util 'blessed'
  print "Checking for Scalar::Util 'blessed'. This is a set of useful utilities.";
  eval "use Scalar::Util 'blessed'";
  if ($@) {
    print "$newline"."The Scalar::Util 'blessed' module could not be located. Some admin functions may not work.$newline";
    $missing=1;
  } else { 
	print " OK$newline"; 
  }	
  
   # -------------
# Check for Text::ParseWords
  print "Checking for Text::ParseWords. This is used to extract lists of words from strings (ignoring delimiters insider quotes)";
  eval "use Text::ParseWords";
  if ($@) {
    print "$newline"."The Text::ParseWords module could not be located. Some admin functions may not work.$newline";
    $missing=1;
  } else { 
	print " OK$newline"; 
  }	
  
   # -------------
   
# Check for Net::Twitter::Lite::WithAPIv1_1
  print "Checking for Net::Twitter::Lite::WithAPIv1_1. This connects to Twitter and executes the new Twitter API)";
  eval "use Net::Twitter::Lite::WithAPIv1_1";
  if ($@) {
    print "$newline"."The Net::Twitter::Lite::WithAPIv1_1 module could not be located. Twitter functions will not work.$newline";
    $missing=1;
  } else { 
	print " OK$newline"; 
  }
    
   # -------------
   
# Check for Image::Magick
  print "Checking for Image::Magick. This connects to Twitter and executes the new Twitter API)";
  eval "use Image::Magick";
  if ($@) {
    print "$newline"."The Image::Magick module could not be located. Icons will not be created.$newline";
    $missing=1;
  } else { 
	print " OK$newline"; 
  }	
  
   # -------------
   
# Check for DateTime
  print "Checking for DateTime. This converts dates and times)";
  eval "use DateTime";
  if ($@) {
    print "$newline"."The DateTime module could not be located. Many date functions will not work properly.$newline";
    $missing=1;
  } else { 
	print " OK$newline"; 
  }	
  
   # -------------
   
# Check for DateTime::TimeZone
  print "Checking for DateTime::TimeZone. This manages time zone conversions)";
  eval "use DateTime::TimeZone";
  if ($@) {
    print "$newline"."The DateTime::TimeZone module could not be located. Time zone conversions will not work properly.$newline";
    $missing=1;
  } else { 
	print " OK$newline"; 
  }	
      
  			
   # -------------
   
# Check for Time::Local
  print "Checking for Time::Local. This manages local time)";
  eval "use Time::Local";
  if ($@) {
    print "$newline"."The Time::Local module could not be located. Local time might not function properly.$newline";
    $missing=1;
  } else { 
	print " OK$newline"; 
  }	
      
    				
   # -------------
   
# Check for Time::Local
  print "Checking for Digest::SHA1 qw/sha1 sha1_hex sha1_base64/. This excrypts passwords and access tokens)";
  eval "use Digest::SHA1 qw/sha1 sha1_hex sha1_base64/";
  if ($@) {
    print "$newline"."The Digest::SHA1 qw/sha1 sha1_hex sha1_base64/ module could not be located. Passwords and access tokens will not work properly.$newline";
    $missing=1;
  } else { 
	print " OK$newline"; 
  }
  							





# -------------
# Provide CPAN help

if ($missing eq "1") {

	print qq|$newline You are missing at least one required Perl module.
		$newline$newline
		There are two ways to get your module. You can either use the 'cpan'
		command, or you can download the module and install it manually.
		We recommend you try the cpan command first. $newline $newline
		Note that either way you must have root (system administrator)
		access to install the module. If you do not have access, request
		that your administrator make the installation for you. $newline
		$newline To start CPAN, type: $newline $newline
		perl -MCPAN -e shell $newline $newline
		If this is the first time you've run CPAN, it's going to ask 
		you a series of questions - in most cases the default answer 
		is fine. Then, once you see the cpan> prompt, type 'install'
		and your module name. For example:$newline $newline
		cpan> install LWP::UserAgent$newline $newline
		For more information, please see:
		http://www.cpan.org/modules/INSTALL.html $newline
		http://www.rcbowen.com/imho/perl/modules.html $newline|;

} 



exit;


