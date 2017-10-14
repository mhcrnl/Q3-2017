#!/usr/bin/perl

#    gRSShopper 0.3  Login  0.5  -- gRSShopper administration module
#    29 January 2012 - Stephen Downes

#    Copyright (C) <2012>  <Stephen Downes, National Research Council Canada>
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




# Forbid agents

if ($ENV{'HTTP_USER_AGENT'} =~ /bot|slurp|spider/) { 
  	print "Content-type: text/html; charset=utf-8\n";
	print "HTTP/1.1 403 Forbidden\n\n";
	print "403 Forbidden\n"; 
	exit; 
}


# Initialize gRSShopper Library

# FindBin doesn't work on ModCGI
#use FindBin qw($Bin);
#require "$Bin/grsshopper.pl";

use File::Basename;
my $basepath = dirname(__FILE__);
require $basepath . "/grsshopper.pl";


our ($query,$vars) = &load_modules("login");
our $target; if ($vars->{target}) { $target = $vars->{target}; }
# Initialize OpenID

if (&new_module_load($query,"Net::OpenID::Consumer")) { $vars->{openid_enabled} = 1; }






# Initialize Session --------------------------------------------------------------


	

my $options = {}; bless $options;		# Initialize system variables
our $cache = {}; bless $cache;	
						
our ($Site,$dbh) = &get_site("page");		# Get Site Information

unless (defined $Site) { die "Site not defined."; }
unless (defined $dbh) { die "Database Handler not defined."; }




our $Person = {}; bless $Person;		# Get User Information
&get_person($dbh,$query,$Person);		
my $person_id = $Person->{person_id};

	

# TEMPORARY
#
# Logging requests for diagnostics
#
my $sq = "";
#while (my ($lx,$ly) = each %$vars) { $sq .= "\t$lx = $ly\n"; }
#open POUT,">>/var/www/cgi-bin/logs/login_access_log.txt" || print "Error opening log: $! <p>";
#print POUT "\n$ENV{'REMOTE_ADDR'}\t$vars->{action}\n$sq" 
#	 || print "Error printing to log: $! <p>";
#close POUT;



$vars->{openid_enabled} = 0;

for ($vars->{action}) {

	/Login/ && do { &login_form_input($dbh,$query); last; 					};
	/Logout/ && do { &user_logout($dbh,$query); last;						};
	/openidloginform/ && do { &openid_login_form($dbh,$query); last; 			};
	/OpenID/ && do { &openidq($dbh,$query); exit;						};

	/Register/ && do { &registration_form_text($dbh,$query); last;	 				};
	/New/ && do { &new_user($dbh,$query); last;	 					};
	/Remove/ && do { &remove_user($dbh,$query); last; 			};
	/Email/ && do { &email_password($dbh,$query); last;	 					};
	/Send/ && do { &send_password($dbh,$query); last;	 					};
	/reset/ && do { &reset_password($dbh,$query); last;	 					};
	/changepwdscr/ && do { &change_password_screen($dbh,$query); last;	 					};
	/changepwdinp/ && do { &change_password_input($dbh,$query); last;	 					};
	/Subscribe/ && do { &subscribe($dbh,$query); last;						};
	/Unsub/ && do { &unsubscribe($dbh,$query); last; 					};
	/Options/ && do { &options($dbh,$query); last;						};
	/form_socialnet/ && do { &form_socialnet($dbh,$query); last;						};
	/update_socialnet/ && do { &update_socialnet($dbh,$query); last;						};	
	/EditInfo/ && do { &edit_info($dbh,$query); last;						};
	/edit_info_in/ && do { &edit_info_in($dbh,$query); 
		&edit_info($dbh,$query); last;		};
	/add/ && do { &add_subscription($dbh,$query);
		&subscribe($dbh,$query); last;	};

	&login_form_text($dbh,$vars); last;
}



if ($dbh) { $dbh->disconnect; }			# Close Database and Exit
exit;

#-------------------------------------------------------------------------------
#
#           Functions 
#
#-------------------------------------------------------------------------------


# -------   Header ------------------------------------------------------------

sub header {

	my ($dbh,$query,$table,$format,$title) = @_;
	my $template = "page_header";

	return &template($dbh,$query,$template,$title);


}

# -------   Footer -----------------------------------------------------------

sub footer {

	my ($dbh,$query,$table,$format,$title) = @_;
	my $template = "page_footer";
	return &template($dbh,$query,$template,$title);

}


# -------  Make Admin Links -------------------------------------------------------
#


sub make_admin_links {

	my ($input) = @_;



}




# --------  Login Form Text ----------------------------------------------------

sub login_form_text {

	my ($dbh,$vars) = @_;


	$Site->{header} =~ s/\Q[*page_title*]\E/Login/g;

	print "Content-type: text/html; charset=utf-8\n\n";
	print $Site->{header};

	if ($vars->{openid_enabled}) {	print qq|<h3>Login</h3><p>$vars->{msg}</p>
			<p><a href='$Site->{script}?refer=$vars->{refer}&action=openidloginform'> 
			Login using OpenID</a>
			(<i><a href="$Site->{st_url}openid.htm">About OpenID on $Site->{st_name}</a></i>)
			</p>|;
	}
	
	my $target; my $targa;
	if ($vars->{target}) { 
		$target = qq|<input type="hidden" name="target" value="$vars->{target}">|; 
		$targa = qq|&target=$vars->{target}|;
	}
	
	my $refer; my $refa;
	if ($vars->{refer}) {
		$refer = qq|<input type="hidden" name="refer" value="$vars->{refer}">|; 
		$refa = qq|&refer=$vars->{refer}|;	
	}
		
		
	print qq|	
		<p>By logging in you agree to allow this site to set three cookies on your browser: 
		the login name you enter below, an ID number corresponding to that name, and a
		session variable, used to prevent fake logins, that changes each time you login.</p>
		<form method='post' action='$Site->{script}'>
	      	<p>Please enter your user name or email address:<br>
		<input name='person_title' type='text' size=40></p>
		<p>Please enter your password:<br>
		<input name='person_password' type='password' size=40></p>
		<p><input type='checkbox' name='remember' value='yes' checked> 
		Remember me next time</p>
      		<p>
		<input type='hidden' name='action' value='Login'>
		$refer
		$target
      		<input type='submit' value='Click here to continue'></p>
      		</form>
		<p>Not a registered user?
		<a href='$Site->{script}?action=Register$refa$targa'> 
     		Click Here</a></p>
		<p>Forget your password?
		<a href='$Site->{script}?action=Email$refa$targa'>
      		Click Here</a></p>|;
      	
	print $Site->{footer};
	return;
}

# --------  OpenID Login Form ----------------------------------------------------

sub openid_login_form {

	my ($dbh,$query) = @_;
	my $vars = $query->Vars;

	$Site->{header} =~ s/\Q[*page_title*]\E/Login Using OpenID/g;

	print "Content-type: text/html; charset=utf-8\n\n";
	print $Site->{header};

	if ($vars->{openid_enabled}) {
		print qq|<h3>Login Using OpenID</h3>

		<form method="post" action="$Site->{script}">
		<input type="hidden" name="action" value="OpenID">
		<input type="hidden" name="refer" value="$vars->{refer}">
		<nobr><b>Your OpenID URL:</b> <input class="sexy" id="openid_url" name="openid_url" size="30" />
<input style="background: #ff6200; color: #fff;" type="submit" value="Login" /></nobr><br />For example: <tt>melody.someblog.com</tt> (if your host supports OpenID)</form>

	      	<p><a href="$Site->{st_url}openid.htm">About OpenID on $Site->{st_name}</a></p>
		|;
	} else {
		print qq|<h3>Login Using OpenID</h3>
		<p>OpenID is not enabled on this website. 
		Ask the site administrator to load 
		Net::OpenID::Consumer if you would like to use it.</p>|;
	}
	

	print $Site->{footer};
	return;
}

# --------  Registration Form Text -------------------------------------------------

sub registration_form_text {
	my ($dbh,$query) = @_;

								# Print Header
	print "Content-type: text/html; charset=utf-8\n\n";

	my $target; my $targa;
	if ($vars->{target}) { 
		$target = qq|<input type="hidden" name="target" value="$vars->{target}">|; 
		$targa = qq|&target=$vars->{target}|;
	}
	
	my $refer; my $refa;
	if ($vars->{refer}) {
		$refer = qq|<input type="hidden" name="refer" value="$vars->{refer}">|; 
		$refa = qq|&refer=$vars->{refer}|;	
	}

	$Site->{header} =~ s/\Q[*page_title*]\E/Register - Newsletter Subscription/g;
	print $Site->{header};
	my $script = $Site->{script};
	print	qq|<br/><h2>Registration and Newsletter Subscription</h2><br/>
			<form method='post' action='$script'>
			<input type='hidden' name='action' value='New'>
			$refer
			$target|;
      
      
      	if ($Site->{st_reg_on} eq "yes") {			# Accepting Registrations? (st_reg_on = yes)


									
		$Person->{person_id} = 0;				# Set up statements
		my $login_text = qq|<box Privacy Statement>
				    <box Cookies Statement>
				    <box Research Statement>|;
	
									# Set up captcha
		my $captchas;
		my $capt_text = "";
		if ($captchas = &get_captcha_table()) {
			my @capkeys = keys %$captchas;
			my $caplen = scalar @capkeys;
			my $cap_sel = rand($caplen);
		
			$capt_text = qq|<p><img src="http://www.downes.ca/images/captchas/|.
				@capkeys[$cap_sel].qq|.jpg" alt="|.@capkeys[$cap_sel].
				qq|"><input type='hidden' name='captcha_index' value='|.
				@capkeys[$cap_sel].qq|'><br/>
				<input type='text' size="10" name='captcha_submit'><br/>
				Please type the image text into the form.<br/></p>|;
			} else {
				$vars->{msg} .= "Captcha table not found.". $Site->{st_cgif}.
					"/data/captcha_table.txt";
			}


		if ($vars->{msg}) { $login_text .= qq|<p class="notice">$vars->{msg}</p>|; }
		$login_text .= qq|
			<p>Select a  username: <input name='person_title' type='text' size=20><br/>
			Select a password: <input name='person_password' type='password' size=20></p>
			<p>Enter your email address:<br>\n<input name='person_email' type='text' size='40'></p>|;
		

		$login_text .=  &subscription_form_text($dbh,$query);

		$login_text .= qq|
			<p>(Optional) Where did you hear about this website?<br/>
			<textarea name=\"source\" cols=60 rows=7></textarea></p>
			$capt_text
			<p><input type='submit' value='Click here to register'></p><p>&nbsp;</p>|;
      		
      		
      	 	&make_boxes($dbh,\$login_text,"silent");
      	 	&make_site_info(\$login_text);
      	 	
      	 	print $login_text;	

      	} else {						# Not Accepting Registrations (st_reg_on = no)
      		
      		print qq|<p>This site is not open to new registrations at this time.
			Visit <a href="http://mooc.ca">MOOC.ca</a> for a list of
			open sites.</p>|;
			
	} 

	print "</form>";
	print $Site->{footer};
	return;
}


# 


# --------  Login --------------------------------------------------------------


sub login_form_input {
	my ($dbh,$query) = @_;
	my $vars = $query->Vars;

						# Check Input Variables

	unless (($vars->{person_title}) && ($vars->{person_password})) {			# Unless fields filled
		&error($dbh,$query,"","Login info not provided"); exit; }			# User Login Error

	my $stmt;
	if ($vars->{person_title} =~ /@/) { 						# Select by email or title
		$vars->{person_email} = $vars->{person_title}; 
		$stmt = qq|SELECT * FROM person WHERE person_email = ? ORDER BY person_id LIMIT 1|;
	} else { 
		$vars->{person_title} = $vars->{person_title}; 
		$stmt = qq|SELECT * FROM person WHERE person_title = ? ORDER BY person_id LIMIT 1|;
	}

											# Get Person Data

	my $sth = $dbh -> prepare($stmt);
	$sth -> execute($vars->{person_title});
	my $ref = $sth -> fetchrow_hashref();

											# Eerror if Data not found
	unless ($ref) { 
		&anonymous($Person);
		&error($dbh,$query,"","<b>Login Error</b><br/>User name not found.<br><a href='".$Site->{st_cgi}.
			"login.cgi?refer=$vars->{refer}&action=Email'>Click here</a> to recover your login inormation."); 
		exit;
	}

											# Password Check
	exit unless (&password_check($vars->{person_password},$ref->{person_password}));

	

	while (my($x,$y) = each %$ref) { $Person->{$x} = $y; }
	$sth->finish(  );
	unless ($Person->{person_id}) { 	
		&error("","","","Unknown error (seriously, this shouldn't happen");
		exit;# No Person Data - Send Error
	}

	&user_are_go($dbh,$query);

}


# --------  Logout -------------------------------------------------------------

sub user_logout {
	my ($dbh,$options) = @_;
	print "Content-type: text/html; charset=utf-8\n";	# Print HTTP header


						# Define Cookie Names
	my $site_base = &get_cookie_base();		
	my $id_cookie_name = $site_base."_person_id";
	my $title_cookie_name = $site_base."_person_title";
	my $session_cookie_name = $site_base."_session";
	
	my $salt = "logout";
	my $sessionid = crypt("anymouse",$salt); 

	my $cookie1 = $query->cookie(-name=>$id_cookie_name,
		-value=>'2',
		-expires=>'-1y',
		-path=>'/',
		-domain=>$Site->{co_host},
		-secure=>0);
        my $cookie2 = $query->cookie(-name=>$title_cookie_name,
		-value=>'Anymouse',
		-expires=>'-1y',
		-path=>'/',
		-domain=>$Site->{co_host},
		-secure=>0);
	  my $cookie3 = $query->cookie(-name=>$session_cookie_name,
		-value=>$sessionid,
		-expires=>'-1y',
		-path=>'/',
	-domain=>$Site->{co_host},
		-secure=>0);	
		
        print $query->header(-cookie=>[$cookie1,$cookie2,$cookie3]);
	#print "Content-type: text/html; charset=utf-8\n";	# Print HTTP header
	print "\n\n";					

	&anonymous($Person);			# Make anonymous

						# Print Jumpoff Page
	$Site->{header} =~ s/\Q[*page_title*]\E/Logout/g;
	print $Site->{header};
	print "<h3>Logout successful</h3>";
	&print_nav_options($dbh,$options);
	print $Site->{footer};
	if ($dbh) { $dbh->disconnect; }			# Close Database and Exit
	exit;
}

# --------  Open ID ----------------------------------------------------------

sub openidq {

	my ($dbh,$query) = @_;

	my $vars;

	unless ($vars->{openid_enabled}) {	
		print qq|<h3>OpenIDLogin</h3><p>$vars->{msg}</p>
		<p>This site does not support OpenID. Ask the site administrator to load 
		Net::OpenID::Consumer if you would like to use it.</p>|;
		
		exit;
	}

									# Set up OpenID object
#	  use Net::OpenID::Consumer;


#    my $ua = LWP::UserAgent->new(timeout => 7);
 #   my $csr = Net::OpenID::Consumer->new(
#					 ua   => $ua,
#					 args  => $vars,
#					 consumer_secret => "hello",
#					 );

	my $trust_root = $Site->{st_url};

								    # Part 1: user enters their URL.

   	if (my $url = $vars->{openid_url}) {

		my $claimed_id = $csr->claimed_identity($url)
	    		or 	&error($dbh,$query,"","Can't determine claimed ID"); 
	
		my $returntourl = $Site->{st_url}.
			"cgi-bin/login.cgi?action=OpenID&refer=$vars->{refer}";
		my $check_url = $claimed_id->check_url(
						   return_to => $returntourl,
						   trust_root => $trust_root,
						   delayed_return => 1,
						   );

		# print "Content-type: text/html; charset=utf-8\n";    # I don't need this? Why?
		 print "Location: $check_url\n\n";
		 exit;
	}

									# Login Cancelled
									
	if ($vars->{'openid.mode'} eq "cancel") {
		&error($dbh,$query,"","You cancelled");
	}

    
    								# Part 2: we get the assertion or setup url
    
									# Setup URL

    if (my $setup = $csr->user_setup_url) {

		# I don't know...
		print "Content-type: text/html; charset=utf-8\n\n";
		print "Setup URL $setup <br>";
		exit;
    }

								    # Assertion - get verified identity object
								    
    my $vident = eval { $csr->verified_identity; };
    if (! $vident) {
		if ($@) { $csr->_fail("runtime_error", $@); }
		&error($dbh,$query,"","OpenID runtime error"); 
    }
	$Person->{person_openid} = $vident->url;
		



								    # Not Already Logged In with regular ID?
	if (($Person->{person_id} eq 2) ||
	    ($Person->{person_id} eq "")) {


	    
	    							# Try to find an account for this OpenID
	    
		my $stmt = qq|SELECT * FROM person WHERE person_openid = ? LIMIT 1|;
		my $sth = $dbh -> prepare($stmt);
		$sth -> execute($Person->{person_openid});
		my $ref = $sth -> fetchrow_hashref();
		if ($ref) { 

									# Write Login Account Cookies
									
				$Person->{person_id} = $vars->{person_id} = $ref->{person_id};
				$Person->{person_title} = $vars->{person_title} = $ref->{person_title};
				&user_are_go($dbh,$query);
				exit;
				
		} else {
		
									# Brand New User, Yippee

				$Person->{person_title} = $vars->{person_title} = $Person->{person_openid};
				$vars->{person_openid} = $Person->{person_openid};
				
									# Require Unique Name
									# Prevents stacking OpenID accounts
				if (&db_locate($dbh,"person",{person_title => $vars->{person_title}}) ) {				
					&error($dbh,$query,"","Someone else named '$vars->{person_title}' has already registered."); 
				};

									# Create the User Record

				my $idval = 'new';
				$vars->{person_crdate} = time;
				$vars->{key} = &db_insert($dbh,$query,"person",$vars,$idval);		
				unless ($vars->{key}) {
					&error($dbh,$query,"","Error, no new account was created."); 
				}
				$Person->{person_id} = $vars->{person_id} = $vars->{key};
				
									# Send Email to Admin
				
				my $subj = "New OpenID User Registration";
				my $pagetext = qq|

					New OpenID User Registration:

					Userid: $vars->{person_title}
					Email: $vars->{person_email}

					Remove this user?
					$Site->{script}?action=Remove&person_id=$vars->{key}
				|;
				&send_email($Site->{em_copy},$Site->{em_from},$subj,$pagetext);

									# Create Login Message
									
				$vars->{msg} .= qq|
				
					OpenID login successful.<br/><br/>
					To personalize your account, click on [Options]<br/><br/>
					To associate your OpenID account with a previously existing
					$Site->{st_name} account, login to that account using
					your userid and password, then login using OpenID again.|;

									# Write Login Account Cookies
									
				&user_are_go($dbh,$query);
				exit;
				
		}

	    
	    
									# Already Logged In 
	} else {
	
									# Remove old stand-alone OpenID

		my $stmt = "DELETE FROM person WHERE person_openid=?";
		my $sth = $dbh->prepare($stmt);
		$sth->execute($Person->{person_openid});
		$sth->finish(  );

									# Associate ID with OpenID    

		&db_update($dbh,"person",{person_openid => $Person->{person_openid}}, $Person->{person_id});
	
									# Print Jumpoff Page
		print "Content-type: text/html; charset=utf-8\n\n";
		$Site->{header} =~ s/\Q[*page_title*]\E/OpenID Login Successful/g;
		print $Site->{header};
		print "<h3>Login Successful</h3>";
		print qq|<p>Identity verified. You are $Person->{person_openid}</p>
			You are currently logged in as $Person->{person_title}. 
			Associating $Person->{person_openid} with this account.</p>
			When you return to this site in the future,
			you may now log in with <i>either</i> your OpenID 
			account or your old $Site->{st_name} account. Either
			way, it will be the same account.</p>|;		
	
	}
	
	&print_nav_options($dbh,$query);
	print $Site->{footer};
	exit;
}


# --------  Register ----------------------------------------------------------

sub new_user {


	my ($dbh,$query) = @_; my $table = 'person';
	my $vars = $query->Vars;


		
	unless ( ($vars->{person_title}) &&	# Verify Input
		  ($vars->{person_email}) &&
		  ($vars->{person_password})) {	
		&error("nil",$query,"", "You must provide your name, email address and a password."); }	

							# Captcha Test
	my $captchas;
	if ($captchas = &get_captcha_table()) {
		unless ( $vars->{captcha_submit} eq $captchas->{$vars->{captcha_index}}) {
			&error("nil",$query,"", "Incorrect Captcha.");
		}
	} else {
		$vars->{msg} .= "Captcha table not found.";
	}


	my ($to) = $vars->{person_email};	# Check email address
	if ($to =~ m/[^0-9a-zA-Z.\-_@]/) { 
		&error("nil",$query,"","Bad Email"); 
	}

						# Unique Email

	if (&db_locate($dbh,"person",{person_email => $vars->{person_email}}) ) {				
		&error($dbh,$query,"","Someone else is using this email address."); };

						# Unique Name
	if (&db_locate($dbh,"person",{person_title => $vars->{person_title}}) ) {				
		&error($dbh,$query,"","Someone else named '$vars->{person_title}' has already registered."); };

						# Spam Checking
	if ($vars->{person_email} =~ /\.ru$/i) {
		&error($dbh,$query,"","Due to spam, Russian registrations must contact me personally by email."); };				
	if ($vars->{source} =~ /test,|just a|for all|for every/i) {
		&error($dbh,$query,"","Leave my website alone and go away."); };	
	if ($vars->{person_title} =~ /youtube|blog /i) {
		&error($dbh,$query,"","Obviously a spam. Go away."); };	


						# Create a Salted Password
	my $saved_password = $vars->{person_password}; 					
       	my $encryptedPsw = &encryptingPsw($vars->{person_password}, 4);
	my $sendpwd = $vars->{person_password};
	$vars->{person_password} = $encryptedPsw;


		
						# Create the User Record
	my $idname = $table."_id";
	my $idval = 'new';		
	$vars->{person_crdate} = time;	
	$vars->{person_status} = "reg";	
	$vars->{person_status} = "reg";		
	$vars->{person_source}=	$vars->{source};			
	$vars->{key} = &db_insert($dbh,$query,$table,$vars,$idval);
	unless ($vars->{key}) {
		&error($dbh,$query,"","Error, no new account was created."); 
	}
	$Person->{person_id} = $vars->{key};
	$vars->{person_password} = $saved_password; 	





						# Newsletter Subscriptions
	&add_subscription($dbh,$query,$vars->{key});


	# Send email to user
	my $subj = "Welcome to ".$Site->{st_name};
	my $pagetext = qq|

Welcome to $Site->{st_name}. It is nice to have you aboard.

This email confirms your new user registration. Please save it in a safe place. In order to post comments on the website, you will need to login with your userid and password.

   Site address: $Site->{st_url}
   Your userid is: $vars->{person_title}

Should you forget your userid and password, you can always have them sent to you at this email address.
To recover missing login infromation, go here: $Site->{st_cgi}login.cgi?refer=&action=Email

   -- $Site->{st_crea}
	|;


	
	# Log Data
#	my $new_user_file = $Site->{st_cgif}."logs/".$Site->{st_tag}."_new_users.txt";
#	if (-e $new_user_file) {
#		open NUOUT,">>$new_user_file" or &error($dbh,"","","Can't Create Log $new_user_file : $!");
#	} else {
#		open NUOUT,">$new_user_file" or &error($dbh,"","","Can't Open Log $new_user_file : $!");
#	}
#	print NUOUT "$vars->{person_title}\t$vars->{person_email}\t$vars->{source}\n" or &error($dbh,"","","Can't Print to Log $new_user_file : $!");;
#	close NUOUT;
	
	&send_email($vars->{person_email},$Site->{em_from},$subj,$pagetext);


	# Send Email to Admin
	$subj = "New User Registration";
	$pagetext = qq|

	New User Registration:

	Userid: $vars->{person_title}
	Email: $vars->{person_email}

	$vars->{msg}
	Remove this user?
	$Site->{script}?action=Remove&person_id=$vars->{key}

	Source:
	$vars->{source}

	|;


	&send_email($Site->{em_copy},$Site->{em_from},$subj,$pagetext);

	
	&login_form_input($dbh,$query);		

}


# -------   Captchas ------------------------------------------------------------


sub get_captcha_table {

	my $captchas; 
	my $found = 0;
	my $cfilename = $Site->{data_dir}."captcha_table.txt";
	open IN,"$cfilename";
	while (<IN>) {
		chomp;
		my ($x,$y) = split "\t",$_;
		$captchas->{$x} = $y;
	}
	close IN;
	return  $captchas;

}


# -------   Options ------------------------------------------------------------


sub options {
	my ($dbh,$query) = @_;
	my $vars = $query->Vars;

	print "Content-type: text/html; charset=utf-8\n\n";
	$Site->{header} =~ s/\Q[*page_title*]\E/Options/g;
	print $Site->{header};

						# Find User Data
	my $pid = &find_person($dbh,$query);
	my $pdata = &db_get_record($dbh,"person",{person_id =>$pid});


						# Anonymous User Options
	if (($Person->{person_id} eq 2) ||
	    ($Person->{person_id} eq "")) { &anon_options($dbh,$query); return; }


	my $name;				# Define Name
	if ($pdata->{person_name}) { $name = $pdata->{person_name}. "(". $pdata->{person_title}.")";	} 
	else { $name = $Person->{person_title};	}


						# Print Page
	print qq|<h2>Welcome, $name</h2>|;					
	print $vars->{msg};
	print qq|<p>This is <i>your</i> private page. If you want to see how the public sees you,
			<a href="$Site->{st_cgi}page.cgi?person=$pid">Click here</a>.</p>|;
	
	
	print qq|<h3>Personal Information</h3>
			<p>
			<table width="400" cellpadding="3" cellspacing="0" border="0">
			<tr><td width="150" align="right">UserID:</a></td>
			<td>$pdata->{person_title}</td></tr>
			<tr><td width="150" align="right">Name:</a></td>
			<td>$pdata->{person_name}</td></tr>			
			<tr><td width="150" align="right">Home Page:</a></td>
			<td>$pdata->{person_url}</td></tr>
			<tr><td width="150" align="right">Email:</a></td>
			<td>$pdata->{person_email}</td></tr>
			<tr><td width="150" align="right">Organization:</a></td>
			<td>$pdata->{person_organization}</td></tr>		
			<tr><td width="150" align="right">Location:</a></td>
			<td>$pdata->{person_city}|;
	if ($pdata->{person_city}) { print ", "; }		
	print qq|		$pdata->{person_country}</td></tr>
			<tr><td colspan="2" align="right"><a href="$Site->{script}?action=EditInfo$refera">
			Change Email Address and personal Info</a></td></tr>
			</table></p>|;

	print qq|<h3>Password</h3>
		<p>
		<a href="$Site->{cgi}login.cgi?action=changepwdscr">Change your password</a></p>|;


	print qq|<h3>Social Network</h3>
		<p>
		<table width="400" cellpadding="3" cellspacing="0" border="0">|;
		
	my $sni = $pdata->{person_socialnet};	# Existing social networks
	my @snil = split ";",$sni;
	my $count = 0;
	foreach my $sn (@snil) {
		$count++;
		my ($netname,$netid,$netok) = split ",",$sn;
		$netok =~ s/checked/public/;
		print qq|
			<tr>
			<td width="150" align="right">$netname:</td>
			<td>$netid</td>
			<td>$netok</td>
			</tr>
		|;	
	}	
	print qq|<tr><td colspan="2" align="right"><a href="$Site->{script}?action=form_socialnet$refera">
			Edit Social Network Info</a></td></tr><table></p>|;



	print qq|<h3>Blogs and RSS Feeds</h3>
		<p>
		<table width="500" cellpadding="3" cellspacing="0" border="0">|;
		
	my $stmt = qq|SELECT * FROM feed WHERE feed_creator=?|;
	my $sth = $dbh->prepare($stmt);
	$sth->execute($pid);
	while (my $ref = $sth -> fetchrow_hashref()) {
		print qq|<tr><td width="150" align="right">$ref->{feed_title}:</td>\n<td>$ref->{feed_html}</td>
			<td width="100"><img src="$Site->{st_url}images/$ref->{feed_status}tiny.jpg"> <a href="$Site->{st_cgi}page.cgi?feed=$ref->{feed_id}">Look</a></td></tr>|;
	}	
	$sth->finish();
	print qq|<tr><td colspan="2" align="right"><img src="$Site->{st_url}images/Otiny.jpg"> Pending Approval 
			<img src="$Site->{st_url}images/Atiny.jpg"> Approved 
			<img src="$Site->{st_url}images/Rtiny.jpg"> Retired<br/> <a href="$Site->{st_url}new_feed.htm">
			Add a New Feed</a></td></tr></table></p>|;
	
	
	
	
	
	print qq|<h3>Newsletter Subscriptions</h3>
		<p>
		<table width="400" cellpadding="3" cellspacing="0" border="0">|;
		
		
			 
	my $stmt = "SELECT subscription_box FROM subscription WHERE subscription_person = '$pid'";
	my $sub_ary_ref = $dbh->selectcol_arrayref($stmt);

	my $sql = qq|SELECT page_id,page_title,page_autosub FROM page WHERE page_sub = 'yes' ORDER BY page_title|;
	my $sth = $dbh->prepare($sql);
	$sth->execute();
	while (my $p = $sth -> fetchrow_hashref()) {
		if (&index_of($p->{page_id},$sub_ary_ref) > -1) { 
			print qq|<tr><td width="150" align="right">$p->{page_title}:</td>
			<td><a href="$Site->{st_url}$p->{page_location}">Read</a></td></tr>|;
		}		
	}
	
	print qq|<tr><td colspan="2" align="right"><a href="$Site->{script}?action=Subscribe$refera">
			Edit Newsletter Subscriptions</a></td></tr><table></p>|;
			
	
	
	
	print qq|<h3>OpenID</h3>
		<p>
		<table width="500" cellpadding="3" cellspacing="0" border="0">|;
			 
	if ($Person->{person_openid}) {
		print qq|<tr><td align="right" width="150">OpenID:</td><td>$Person->{person_openid}</td></tr>|;
	} else {			 
		if ($vars->{openid_enabled}) {
			print qq|<tr><td colspan="2" align="right"><a href="$script?referq&action=openidloginform">
			Associate OpenID account with your $Site->{st_name} account</a></td></tr>|; 
		}
	}		
			
	print "</table></p>";




	print qq|<p>[<a href="$Site->{script}?action=Logout$refera">Logout</a>]|;

	if ($vars->{refer}) {
		my $rf = $vars->{refer}; 
		$rf =~ s/AND/&/g;
		$rf =~ s/COMM/#/g;
		print qq|
			[<a href="$rf">
			Go back to where you were</a>]|;
	}


	print qq|</p>|;

	print $Site->{footer};

}

# -------   Anon Options ------------------------------------------------------------

sub anon_options {
	
		my ($dbh,$query) = @_;
	my $vars = $query->Vars;

		print qq|<p>Welcome to $Site->{st_name}.
			You are using this site anonymously
			and will be identified as 'Anymouse'
			if you choose to post comments.</p>
			<p>If you wish to sign your name to
                        comments or to receive a newsletter
			by email, you will need to login or register.</p>
			<p><ul>
			<li><a href="$Site->{script}$referq">Login</a> if you already have a UserID</li>
			<li><a href="$Site->{script}?action=Register$refera">
			Register</a> if you don't</li>|; #'

		if ($vars->{refer}) {
			my $rf = $vars->{refer}; 
			$rf =~ s/AND/&/g;
			$rf =~ s/COMM/#/g;
			print qq|<li><a href="$rf">
				Go back to where you were</a></li>|;
		}
		print qq|</ul></p>|;
		print "<p>&nbsp;</p>".$Site->{footer};
		return;	
	
	
}

# --------  User Are Go --------------------------------------------------------

# Writes login cookies after succcessful login or registration
# As in: Thunderbirds Are Go
#
# Used by: login_form_input()



sub user_are_go {
	my ($dbh,$query) = @_;
	my $vars = $query->Vars;
	
	$vars->{remember} = 1; 						# Because people keep forgetting to check the little box

									# Define Cookie Names
	my $site_base = &get_cookie_base();		
	my $id_cookie_name = $site_base."_person_id";
	my $title_cookie_name = $site_base."_person_title";
	my $session_cookie_name = $site_base."_session";
	my $admin_cookie_name = $site_base."_admin";	
	
#	$Site->{co_host} = "www.downes.ca";

#	print "Content-type: text/html; charset=utf-8\n\n";	# Print HTTP header
#	print "User are go<p>";



	my $exp; 							# Expiry Date
	if ($vars->{remember}) { $exp = '+1y'; } 
	else { $exp = '+1h'; }
	

									# Session ID
	my $salt = $site_base . time;
	my $sessionid = crypt("anymouse",$salt); 			# Store session ID in DB
	&db_update($dbh,"person",{person_mode => $sessionid}, $Person->{person_id},"Setting session ID for Person $Person->{person_id}");
	
									# Cookies
	my $cookie1 = $query->cookie(-name=>$id_cookie_name,
		-value=>$Person->{person_id},
		-expires=>$exp,
		-domain=>$Site->{co_host},
		-secure=>0);
	my $cookie2 = $query->cookie(-name=>$title_cookie_name,
		-value=>$Person->{person_title},
		-expires=>$exp,
		-domain=>$Site->{co_host},
		-secure=>0);
	my $cookie3 = $query->cookie(-name=>$session_cookie_name,
		-value=>$sessionid,
		-expires=>$exp,
		-domain=>$Site->{co_host},
		-secure=>0);		
	
									# Admin Cookie
									# Not secure; can be spoofed, use only to create links								
	my $admin_cookie_value = "";				
	if ($Person->{person_status}  eq "admin") { $admin_cookie_value="admin"; }
	else { my $admin_cookie_value="registered"; }
	
	my $cookie4 = $query->cookie(-name=>$admin_cookie_name, 
			-value=>$admin_cookie_value,
			-expires=>$exp,
			-domain=>$Site->{co_host},
			-secure=>0);			
	
	print $query->header(-cookie=>[$cookie1,$cookie2,$cookie3,$cookie4]);
   
#	print "\n\n";     
#	print "Done cookies<p>";
	my $redirect;			
						# If D2L, do API and send back
					
	if ($Person->{person_id} && $Person->{person_id} ne "2") {

		if ($vars->{target}) {		# Site-specific Need a better thing here
			if ($target =~ /edfuture/) {			# URL-specific - Need a better thing here
			my $sitekey = qq|A48506F1-7AE3-4C90-9891-C4E6F662F0BC|;
	my $apiurl = "https://edfuture.desire2learn.com";
	my $apipath = "/d2l/api/custom/1.1/ssowithcreateandenroll/authUser/".$sitekey;
				
		
	my ($first,$last) = &first_last_name();
	&error($dbh,"","","fatal error, first and last name not found on D2L redirect: $first, $last") 
		unless ($first && $last);
	&error($dbh,"","","fatal error, email address not found on D2L redirect") 
		unless ($Person->{person_email});	
	my $data = {
		UserName => $Person->{person_title},
		FirstName => $first,
		LastName => $last,
		Email => $Person->{person_email}
	};
		
			
	$redirect = &api_send_rest($dbh,$query,$apiurl,$apipath,$data,$target);
	print qq|Return to the D2L website - <a href="$redirect">Click here</a><p>|;exit;
	print "Location: $redirect\n\n";
				

				
			}
		}

	}					
	

	print "\n";	
						# Print Jumpoff Page
	$Site->{header} =~ s/\Q[*page_title*]\E/Login Successful/g;
	print $Site->{header};
	#if ($options->{new} eq "yes") { &show_subscriptions($dbh,$vars,$person); }
	print "<h3>Login Successful</h3>";
	print "$redirect";
	if ($vars->{msg}) {
		print qq|<div id="notice">$vars->{msg}</div>|;
	}
	&print_nav_options($dbh,$query);
	print $Site->{footer};
	exit;
}


sub go_to_d2l {
	
	
	exit;
}

# First-Last Name 
# 
# Generates first and last name

sub first_last_name {
	
	
	if ($Person->{person_name} && !$Person->{person_lastname}) {
		($Person->{person_firstname},$Person->{person_lastname}) = split " ",$Person->{person_name};
	}
	
	if ($Person->{person_firstname} && $Person->{person_lastname}) {
		return ($Person->{person_firstname},$Person->{person_lastname}); 
	}
	
	if ($Person->{person_firstname} || $Person->{person_lastname} ||  $Person->{person_title}) {
		$Person->{person_firstname} = $Person->{person_firstname} || $Person->{person_lastname} ||  $Person->{person_title};
		$Person->{person_lastname} = $Person->{person_lastname} || $Person->{person_firstname} ||  $Person->{person_title};
		return ($Person->{person_firstname},$Person->{person_lastname});
	}
	
	
}
# --------  Print Nav Options ---------------------------------------------------
#
# Used by: login_form_input()  (via user_are_go() )
#          user_logout()


sub print_nav_options {
	my ($dbh,$query) = @_;
	my $vars = $query->Vars;
	my $script = $Site->{script};
	



	my $refer=""; 				# Define Refer Link
	my $referq; my $refera;
	if ($vars->{refer}) { 
		$referq = "?refer=".$vars->{refer}; 
		$refera = "&refer=".$vars->{refer}; 		
	}
	if ($vars->{target}) { 
		$targetq = "?refer=".$vars->{target}; 
		$targeta = "&refer=".$vars->{target}; 		
	}
	print "<p><ul>";


	# Sepecial for Ed Future
	if ($Site->{st_url} =~ /edfuture/) {
		$vars->{target} ||= "http%3a%2f%2fedfuture.desire2learn.com%3a80%2fd2l%2fhome%2f6609";
		
		
		my $sitekey = qq|A48506F1-7AE3-4C90-9891-C4E6F662F0BC|;
		my $apiurl = "https://edfuture.desire2learn.com";
		my $apipath = "/d2l/api/custom/1.1/ssowithcreateandenroll/authUser/".$sitekey;
				
		
		my ($first,$last) = &first_last_name();
		&error($dbh,"","","fatal error, first and last name not found on D2L redirect: $first, $last") 
			unless ($first && $last);
		&error($dbh,"","","fatal error, email address not found on D2L redirect") 
			unless ($Person->{person_email});	
		my $data = {
			UserName => $Person->{person_title},
			FirstName => $first,
			LastName => $last,
			Email => $Person->{person_email}
		};
		
		
		$redirect = &api_send_rest($dbh,$query,$apiurl,$apipath,$data,$target);
		print qq|<li>Return to D2L website - <a href="$redirect">Click here</a></li>|;

	}
	
	if ($Person->{person_status} eq "admin") {
		print qq|<li><a href="$Site->{st_cgi}admin.cgi">Site 
			Administration</a></li>|;
	}
	print qq|<li><a href="$script?action=Options$refera$targeta">
		Edit Your Personal Information and Options</a></li>|;
		
	unless ($Person->{person_openid}) {
		unless ($Person->{person_id} eq 2) {
			if ($vars->{openid_enabled}) {
				print qq|<li><a href="$script?$referq$targetq&action=openidloginform">
				Associate OpenID account with your $Site->{st_name} account</a></li>|; 
			}
		}
	}

	if ($vars->{refer}) {
		my $rf = $vars->{refer}; 
		$rf =~ s/AND/&/g;
		$rf =~ s/COMM/#/g;
		print qq|<li><a href="$rf">
			Go back to where you were</a></li>|;
	} elsif ($vars->{target}) {
		unless (&new_module_load($query,"URI::Escape")) { 
			print $vars->{error};
			exit;
		}
		my $tf = $vars->{target}; 
		$tf = uri_unescape($tf);
		print qq|<li><a href="$rf">
			Go back to where you were</a></li>|;		
		
	}
	print qq|
		<li><a href="$Site->{st_url}">
		Go to the site home page</a></li>

		<li><a href="$script$referq">
		Log on as another user</a></li>|;
 
	unless ($Person->{person_id} eq 2) {
		print qq|<li><a href="$script?action=changepwdscr">Change your Password</a></li>|;
		print qq|<li><a href="$script?action=Logout$refera$targeta">Logout</a></li>|;
	}
	print "</ul></p>";

}



# --------  Remove User ----------------------------------------------------------

sub remove_user {

	my ($dbh,$query) = @_;
	my $vars = $query->Vars;

						# Check Input
	&error($dbh,$query,"","Not allowed") 	# Admin only
		unless ($Person->{person_status} eq "admin");

	&error($dbh,$query,"","User not specified") 
		unless ($vars->{person_id} > 2);


	my $pid = $vars->{person_id};


	&drop_subscription($dbh,$pid);		# Remove Subscriptions

							# Remove Person

	my $stmta = "DELETE FROM person WHERE person_id=?";
	my $stha = $dbh->prepare($stmta);
	$stha->execute($pid);
	$stha->finish(  );
							# Print Page
	print "Content-type: text/html; charset=utf-8\n\n";
	$Site->{header} =~ s/\Q[*page_title*]\E/Deleted/g;
	print $Site->{header};
	print "<h2>Deleted</h2><p>User number $pid has been deleted.</p>";
	print $Site->{footer};
	
}

#   -------------------------------------------------------------------------------------
#
#   find_person
#
#   This function allows a person to identify themselves to edit their data,
#   or an administrator to find a person given name, email, etc.
#   Returns a single value, $pid   person->person_id
#
#   -------------------------------------------------------------------------------------



sub find_person {

	my ($dbh,$query) = @_;
	my $vars = $query->Vars;

							# Admin Only

	return $Person->{person_id} unless ($Person->{person_status} eq "admin");

							

	return $Person->{person_id} unless (		# On request only
		$vars->{pid} ||
		$vars->{ptitle} ||
		$vars->{pname} ||
		$vars->{pemail} );

	if ($vars->{pid} and 
		&db_locate($dbh,"person",{		# Check ID
		person_id => $vars->{pid}})) {
		return $vars->{pid};
	}

	my $pid;					# Check Title
	if ($vars->{ptitle} and 	
		$pid = &db_locate($dbh,"person",{	
		person_title => $vars->{ptitle}})) {
		return $pid;
	}

							# Check Name
	if ($vars->{pname} and 	
		$pid = &db_locate($dbh,"person",{	
		person_name => $vars->{pname}})) {
		return $pid;
	}
							# Check Email
	if ($vars->{pemail} and 	
		$pid = &db_locate($dbh,"person",{	
		person_email => $vars->{pemail}})) {
		return $pid;
	}

	&error($dbh,$query,"","User not found");	# Not found
	exit;
}


# -------   Edit Info Form ---------------------------------------------

sub edit_info {
	my ($dbh,$query) = @_;
	my $vars = $query->Vars;

	print "Content-type: text/html; charset=utf-8\n\n";	# Print Header
	my $script = $Site->{script};
	$Site->{header} =~ s/\Q[*page_title*]\E/Change Email and Personal Info/g;
	print $Site->{header};

						# Determine Person
	my $pid = &find_person($dbh,$query);
	&error($dbh,$query,"","Cannot edit anonymous account") 
		if ($pid eq "2");	

						# Get Person Info

	my $record = &db_get_record($dbh,'person',{person_id => $pid});

# while (my ($px,$py) = each %$record) { print "$px = $py <br>"; }


						# Print Form

	print	qq|<h3>Change Email and Personal Info</h3>|;
	print $vars->{msg};
	print qq|
		<form method='post' action='$script'>
		<input type='hidden' name='action' value='edit_info_in'>
		<input type='hidden' name='refer' value='$vars->{refer}'>
		<input type='hidden' name='pid' value='$pid'>

		<table border=0 cellpadding=2>

		<tr>
		<td align="right">user ID:</td>
		<td colspan="3">$record->{person_title} </td>
		</tr>

		<tr>
		<td align="right">Name:</td>
		<td colspan="3"><input size="30" type="text" name="person_name" value="$record->{person_name}"></td>
		</tr>

		<tr>
		<td align="right">Email:</td>
		<td colspan="3"><input size="30" type="text" name="person_email" value="$record->{person_email}"></td>
		</tr>

		<tr>
		<td align="right">City:</td>
		<td colspan="3"><input size="30" type="text" name="person_city" value="$record->{person_city}"></td>
		</tr>

		<tr>
		<td align="right">Country:</td>
		<td colspan="3"><input size="30" type="text" name="person_country" value="$record->{person_country}"></td>
		</tr>

		<tr>
		<td align="right">Organization:</td>
		<td colspan="3"><input size="30" type="text" name="person_organization" value="$record->{person_organization}"></td>
		</tr>

		<tr>
		<td align="right">Home Page:</td>
		<td colspan="3"><input size="30" type="text" name="person_html" value="$record->{person_html}"></td>
		</tr>

		<tr>
		<td align="right">RSS Feed:</td>
		<td colspan="3"><input size="30" type="text" name="person_xml" value="$record->{person_xml}"></td>
		</tr>

		</table>

      		<input type='submit' value='Update Information'></p>
      		</form>|;



	unless ($Person->{person_openid}) {
		unless ($Person->{person_id} eq 2) {
			if ($vars->{openid_enabled}) {
				print qq|<ul><li><a href="$script?referq&action=openidloginform">
				Associate a new OpenID account with your $Site->{st_name} account</a></li></ul>|; 
			}
		}
	}
	
	
	&print_nav_options($dbh,$query);
	print $Site->{footer};
	return;
}

# -------   Edit Info Input ---------------------------------------------


sub edit_info_in {

	my ($dbh,$query) = @_; my $table = 'person';
	my $vars = $query->Vars;

						# Validate input user
	my $pid = $vars->{pid};
	&error($dbh,$query,"","Cannot edit anonymous account") 
		if ($pid eq "2");
	unless ($Person->{person_status} eq "admin" ||
		$Person->{person_id} eq $pid) {
		&error($dbh,$query,"","You are not authorized to edit this account.");
	}

	my ($to) = $vars->{person_email};	# Check email address
	if ($to) {
		if ($to =~ m/[^0-9a-zA-Z.\-_@]/) { 
			&error($dbh,$query,"","Bad Email"); 
		}
						# Pre-delete email addr

		&db_update($dbh,"person",{person_email => "none"}, $pid);

	}

						# Unique Email
						# To prevent email addr spoofing
	my $e = &db_locate($dbh,"person",{person_email => $vars->{person_email}});
	if ($e) {
#		unless ($vars->{person_email} eq "none") {
#			&error($dbh,$query,"","Someone else is using this email address."); 
#		}
	}

						# Update the User Record
	&db_update($dbh,"person",$vars, $pid);
	$vars->{msg} .= qq|<p class="notice">Your personal data has been updated.</p>|;


}



# -------   Manage Subscriptions ---------------------------------------------

sub subscribe {
	my ($dbh,$query) = @_;

	$Site->{header} =~ s/\Q[*page_title*]\E/Manage Subscriptions/g;  # print form
	print qq|Content-type: text/html; charset=utf-8\n\n|.
		$Site->{header}.
		qq|<h3>Manage Subscriptions</h3>
		 <form method="post" action="$Site->{script}">
		 <input type="hidden" name="action" value="add">|;
	print &subscription_form_text($dbh,$query,"manage");
	print qq|<input type="submit" value="Update Subscriptions"></form><p>&nbsp;</p>|;
	&print_nav_options($dbh,$query);
	print $Site->{footer};
}


# -------   Subscription Form Text --------------------------------------------

# Dynamic generation of subscription options

# Used by: subscribe()
#          registration_form_text()

	# Get Array of Subscriptions


sub subscription_form_text {

	my ($dbh,$query,$man) = @_;
	my $vars = $query->Vars;




						# Get Person Data
	my $pid = &find_person($dbh,$query);
	my $pdata = &db_get_record($dbh,"person",{person_id =>$pid});
	my $pname = $pdata->{person_name} || $pdata->{person_email} || $pdata->{person_id};
	
						# Get Person's Existing Subscriptions
	my $sub_ary_ref;
	unless ($vars->{action} eq "Register") {
		if ($man eq "manage" && ($pid eq "0" || $pid eq "2" || $pid eq "")) {
			return "No subscriptions for anonymous users." }
		my $stmt = "SELECT subscription_box FROM subscription WHERE subscription_person = '$pid'";
		$sub_ary_ref = $dbh->selectcol_arrayref($stmt);
	}					

						# Initialize Form Text
	my $form_text = "";					
	if ($pname) { $form_text .= qq|<p>Displaying subscriptions for $pname</p>|; }
	$form_text .= qq|
		<p>Select newsletter subscriptions 
		(you may choose more than one; leave blank for none) 
		</p>
		<input type="hidden" name="pid" value="$pid">
	|;


						# Get List of Subscribable Pages
	my $pages = {};
	my $sql = qq|SELECT page_id,page_title,page_sub,page_autosub FROM page WHERE page_sub = 'yes' ORDER BY page_title|;
	my $sth = $dbh->prepare($sql) or die "Can't prepare SQL statement in subscription_form_text $sql : ", $sth->errstr(), "\n";
	$sth->execute()  or die "Can't execute SQL statement in subscription_form_text $sql : ", $sth->errstr(), "\n";

						# For Each Subscribable Page...
	$form_text .= qq|<p>\n|;
	while (my $p = $sth -> fetchrow_hashref()) {
		
						# Does the user already subscribe?
		my $selected = "";
		if (&index_of($p->{page_id},$sub_ary_ref) > -1) { 
			$selected = " checked";	
		}

						# Is it a default subscribe?
		if ($p->{page_autosub} eq "yes") {				
			$selected = " checked";
		}

						# Create the form text for that page
		$form_text .= qq|
			<input type="checkbox" name="newsletter" value="$p->{page_id}"|.
			qq| $selected > $p->{page_title}</input><br/>|;


	}
	$form_text .= qq|</p>\n|;
	return $form_text;













}

# -------   Add Subscription -------------------------------------------------

sub add_subscription {

	my ($dbh,$query,$pid) = @_;
	my $vars = $query->Vars;
						# Determine Person ID
	$pid ||= $vars->{pid};		
	&error($dbh,$query,"","No ID number provided for subscription")
		unless ($pid);
	&error($dbh,$query,"","Cannot edit anonymous account") 
		if ($pid eq "2");

						# Validate User
	unless ($Person->{person_status} eq "admin" ||
		$Person->{person_id} eq $pid) {
		&error($dbh,$query,"","$Person->{person_id} eq $pid You are not authorized to edit this account.");
	}
						
	unless ($vars->{action} eq "New") {	# Remove Previous Subscriptions
		&drop_subscription($dbh,$pid);
	}

	unless ($vars->{newsletter}) {
		$vars->{msg} .= qq|<p class="notice">No longer subscribed to anything.</p>|;
		return;
	}	

					# Insert Subscriptions
	my @nls = split /\0/,$vars->{newsletter};
	

	foreach my $newsl (@nls) {
		my $nl={};
		$nl->{subscription_box} = $newsl;
		$nl->{subscription_person} = $pid;
		$nl->{subscription_crdate} = time;
		my $sub = &db_insert($dbh,$query,"subscription",$nl);
		unless ($sub) { 
			&error($dbh,$query,"","For some unknown reason your subscription failed. Please try again later."); 
		}
	}

						# Notify
	$vars->{msg} .= qq|<p class="notice">Subscriptions have been updated.</p>|;
	#&notify_subscribe($person_id,"Subscribe",$sb);
	return;
}

# -------   Unsubscribe ------------------------------------------------------

sub unsubscribe {

	my ($dbh,$query) = @_;
	my $vars = $query->Vars;
	$vars->{sid} =~ s/\s//g;			# Clean email address

	unless (&db_locate($dbh,"person",{		# If person exists...
		person_id => $vars->{pid},
		person_email => $vars->{sid}})) {

		&error($dbh,$query,"","Looking for $vars->{pid} $vars->{sid}<br/><br/>
			User not found, cannot unsubscribe.<br/><br/>
			If this is a partial email address, please
			cut and paste the entire unsubscribe URL from the
			email newsletter to the address bar.");
	}

	unless (&db_locate($dbh,"subscription",{	# If subscription exists...
		subscription_person => $vars->{pid}})) {

		&error($dbh,$query,"","Subscription not found<br/><br/>
			$vars->{sid} is not subscribed.<br/><br/>");
	}

	&drop_subscription($dbh,$vars->{pid});		# Drop subscription

	my $subj = "Subscription Cancelled";		# Print report

	$Site->{header} =~ s/\Q[*page_title*]\E/$subj/g;
	my $msg = qq|<h2>$subj</h2>
		   <p>Your email subscription has been cancelled.<br/>
		   Email: $vars->{sid} <br/> 
		   If you wish to restart it any time in the future,
                   return to your <a href="$Site->{st_url}options.htm">options page</a>
		   to resubscribe.</p>|;

	print qq|Content-type: text/html; charset=utf-8\n\n|.$Site->{header}.$msg.$Site->{footer};
	$msg =~ s/<(.*?)>/\n/sig;
						# Send Emails

	&send_email($vars->{sid},$Site->{em_from},$subj,$msg);
	&send_email($Site->{em_copy},$Site->{em_from},$subj,$msg);

	exit;	 
}



# -------   Drop Subscription ------------------------------------------------

# Called by add_subscription()


sub drop_subscription {

	my ($dbh,$person_id) = @_;
	return unless ($person_id);
						# Remove Subscriptions

	my $stmt = "DELETE FROM subscription WHERE subscription_person=?";
	my $sth = $dbh->prepare($stmt);
	$sth->execute($person_id);
	$sth->finish(  );

}

#   -------------------------------------------------------------------------------------
#
#   
#		PASSWORD MANAGEMENT
#   
#
#   -------------------------------------------------------------------------------------


# --------  Password Check ------------------------------------------------------

sub password_check {

	my ($inputpwn,$dbpwd,$msg) = @_;
	$msg ||= "Login Error";

#print "Content-type: text/html\n\n";
my $tmp_msg = qq|
<p>Please Note: We have made some changes to the login system recently. If 
your password is continually being rejected, it's probably our fault, not
yours. Please follow the link to recover your login information and you'll 
be back online in no time. Our apologies for any inconvenience.</p>|; 
#print $tmp_msg;
 #print "<p> -- $inputpwn $dbpwd </p> ";
	return 1 if ($dbpwd eq crypt($inputpwn, $dbpwd));	# Salted crypt match
	&anonymous($Person);
	&error($dbh,$query,"","<p><b>$msg</b><br/>Incorrect password.  <br><a href='".$Site->{st_cgi}."login.cgi?refer=$vars->{refer}&action=Email'>Click here</a> to recover your login inormation.</p>$tmp_msg"); 
	exit;


}

#   -------------------------------------------------------------------------------------
#
#   email_password
#
#   Form to request password sent to the user's email address
#
#   -------------------------------------------------------------------------------------

sub email_password {
	my ($dbh,$query) = @_;

	print "Content-type: text/html; charset=utf-8\n\n";
	$Site->{header} =~ s/\Q[*page_title*]\E/Email Password/g;
	print $Site->{header};
	print "<h3>Email Password</h3>";


	print "<p><form method=\"post\" action=\"$Site->{script}\">\n" .	# Form
		"<p>To reset your password, enter your email address, your User ID, or your name:\n" .
		"<input type=\"hidden\" name=\"refer\" value=\"$vars->{refer}\">" .
		"<input type='text' size='40' name='person_email'>\n" .
		"<input type='hidden' name='action' value='Send'></p>\n" .	# Send
		"<p><input type=\"submit\" value=\"Click Here\"></p>\n" .	# Submit
		"</form>\n</p><p>&nbsp;</p>";							# End form


	&print_nav_options($dbh,$query);
	
	print $Site->{footer};
}


#   -------------------------------------------------------------------------------------
#
#   send_password
#
#   Sends password to the user's email address
#
#   -------------------------------------------------------------------------------------

sub send_password {
	my ($dbh,$query) = @_;
	my $vars = $query->Vars;
#return unless ($Person->{person_status} eq "Admin");

	unless ($vars->{person_email}) { &error($dbh,$query,"","Please enter <i>something!</i>."); }

	my $person = &db_get_record($dbh,'person',{person_email => $vars->{person_email}});
	unless ($person) { $person = &db_get_record($dbh,'person',{person_title => $vars->{person_email}}); }
	unless ($person) { $person = &db_get_record($dbh,'person',{person_name => $vars->{person_email}}); }


	# We generate a random string, store it in $person->{person_midm}, then send it as a key
	# to reset the password

	my $reset_key = &generate_random_string(64);
	&db_update($dbh,"person",{person_midm=>$reset_key},$person->{person_id});
 

	if ($person) {			# If there's a person
					# With an email

		if ($person->{person_email}) {	

					# Send the password

			$Site->{st_name} =~ s/&#39;/'/g;
			&send_email($person->{person_email},$person->{person_email},
				"To reset your password from ".$Site->{st_name},
				"\nTo reset your password from $Site->{st_name} go to the following URL\n\n" .
				"$Site->{st_cgi}login.cgi?action=reset&key=$person->{person_id},$reset_key\n\n");	

			print "Content-type: text/html; charset=utf-8\n\n";
			$Site->{header} =~ s/\Q[*page_title*]\E/Password Retrieval/g;
			print $Site->{header} . qq|
				<h3>Password Retrieval</h3><p>&nbsp;</p>
				<p>We have sent you a reset URL. To reset your password, please check your email inbox.
				 </p>
				<p>&nbsp;</p>|;
			#&print_nav_options($dbh,$query);
			print $Site->{footer};

		} else {

			&error($dbh,$query,"","Could not find your email address.");

		}

	} else {

		&error($dbh,$query,"","Could not find $vars->{person_email} in my database.");

	}



}

#   -------------------------------------------------------------------------------------
#
#   reset_password
#
#   Resets password and sends to the user's email address
#   Requires key cerated by send_password
#
#   -------------------------------------------------------------------------------------

sub reset_password {

	my ($dbh,$query) = @_;
	my $vars = $query->Vars;


	my ($id,$key) = split ",",$vars->{key};
	my $person = &db_get_record($dbh,'person',{person_id => $id});
	&error($dbh,"","","Blank midm") unless ($person->{person_midm});
	&error($dbh,"","","Reset key expired") if ($person->{person_midm} eq "expired");
	&error($dbh,"","","Key mismatch") unless ($person->{person_midm} eq $key);

	my $new_password = generate_random_string(10);
	my $encryptedPsw = &encryptingPsw($new_password, 4);
	&db_update($dbh,"person",{person_password=>$encryptedPsw},$id);

	my $expired = "expired";
	&db_update($dbh,"person",{person_midm=>$expired},$id);

	if ($person->{person_email}) {	

				# Send the password
		$Site->{st_name} =~ s/&#39;/'/g;
		&send_email($person->{person_email},$person->{person_email},
			"Password reset for ".$Site->{st_name},
			"\nYour password has been reset:\n\n" .
			"Userid: $person->{person_title} \n Password: $new_password\n\n");	

		print "Content-type: text/html; charset=utf-8\n\n";
		$Site->{header} =~ s/\Q[*page_title*]\E/Password Retrieval/g;
		print $Site->{header} . qq|
			<h3>Password Reset</h3><p>&nbsp;</p>
			<p>Your password has been reset. Please check your email inbox.<br/><br/>
			<a href="$Site->{st_cgi}login.cgi">Click here to login</a> with your new password.
			 </p>|;
	#	&print_nav_options($dbh,$query);
		print $Site->{footer};

	} else {

		&error($dbh,$query,"","Could not find your email address.");

	}
	exit;

}


#   -------------------------------------------------------------------------------------
#
#   change_password_screen
#
#   Input screen to change password
#
#   -------------------------------------------------------------------------------------

sub change_password_screen {

	my ($dbh,$query) = @_;
	my $vars = $query->Vars;


	print "Content-type: text/html; charset=utf-8\n\n";
	$Site->{header} =~ s/\Q[*page_title*]\E/Password Retrieval/g;
	print $Site->{header} . qq|
			<form method="post" action="$Site->{st_cgi}login.cgi">
			<input type="hidden" name="action" value="changepwdinp">
			<h3>Change Your Password</h3><p>&nbsp;</p>
			<p>Enter your old password and your new password.<br/><br/>
			Old&nbsp; Password: <input type="password" name="op" size="20"><br/><br/>
			New Password: <input type="password" name="npa" size="20"><br/><br/>
			New Password: <input type="password" name="npb" size="20"><br/>
			(Again)<br/><br/>
			<input type="submit" value="Change Password">
			</form>
			 </p>|;
	#	&print_nav_options($dbh,$query);
		print $Site->{footer};

	
	exit;

}


#   -------------------------------------------------------------------------------------
#
#   change_password_input
#
#   Input screen to change password
#
#   -------------------------------------------------------------------------------------

sub change_password_input {

	my ($dbh,$query) = @_;
	my $vars = $query->Vars;

	print "Content-type: text/html; charset=utf-8\n\n";


	&error($dbh,"","","Attempting to change password: incorrect old password") 
		unless &password_check($vars->{op},$Person->{person_password},"Password Change Error");

	&error($dbh,"","","<b>Password Change Error</b><br/>New password is blank.")
		unless ($vars->{npa});

	&error($dbh,"","","<b>Password Change Error</b><br/>New passwords do not match.")
		unless ($vars->{npa} eq $vars->{npb});


	my $encryptedPsw = &encryptingPsw($vars->{npa}, 4);
	&db_update($dbh,"person",{person_password=>$encryptedPsw},$Person->{person_id});


	print $Site->{header} . qq|
			<h3>Password Change</h3><p>&nbsp;</p>
			<p>Your password has been changed.<br/><br/>
			<a href="$Site->{st_cgi}login.cgi">Click here to login</a> with your new password.
			 </p>|;
	&print_nav_options($dbh,$query);
	print $Site->{footer};


	
	exit;

}


#   -------------------------------------------------------------------------------------
#
#   form_socialnet
#
#   Input social network information
#
#   -------------------------------------------------------------------------------------


sub form_socialnet {
	
	
	my ($dbh,$query,$man) = @_;
	my $vars = $query->Vars;

#	my $alterstmt = "ALTER TABLE person MODIFY person_socialnet text";
#	my $asth = $dbh -> prepare($alterstmt);
#	$asth -> execute();

						# Get Person Data
	my $pid = &find_person($dbh,$query);
	my $pdata = &db_get_record($dbh,"person",{person_id =>$pid});
	my $pname = $pdata->{person_name} || $pdata->{person_email} || $pdata->{person_id};
	my $record = &db_get_record($dbh,'person',{person_id => $pid});
	
							# Print Form
	print "Content-type: text/html\n\n";
	$Site->{header} =~ s/\Q[*page_title*]\E/Edit Social Network Info/g;
	print $Site->{header};
	print	qq|<h3>Edit Social Network Info</h3>|;
	print $vars->{msg};
	
	print qq|<p>Use this form to edit your social network information. We will be able to use
		this information to help you post from the $Site->{st_name} site to your social
		network, and to associate posts we havest from these social networks with your
		$Site->{st_name} identity.<br/><br/>Please note that providing this information is
		<i>optional</i>. Also, your social network identity will not be displayed to
		the public unless you have checked the 'public' box for that social network name.</p>|;
	
	print qq|<p><form method="post" action="$Site->{st_cgi}login.cgi">
		<input type="hidden" name="action" value="update_socialnet">
		<input type='hidden' name='refer' value='$vars->{refer}'>
		<input type='hidden' name='pid' value='$pid'>
		<table cellpadding="2" cellspacing="0" border="1">
		<tr><td><i>Network</i></td><td><i>Your ID</i></td><td><i>Public?</i></td></tr>|;
		
	my $sni = $record->{person_socialnet};	# Existing social networks
	my @snil = split ";",$sni;
	my $count = 0;
	foreach my $sn (@snil) {
		$count++;
		my ($netname,$netid,$netok) = split ",",$sn;
		print qq|
			<tr>
			<td><input type="text" size="20" name="netname$count" value="$netname"></td>
			<td><input type="text" size="20" name="netid$count" value="$netid"></td>
			<td><input type="checkbox" name="netok$count" value=" checked"$netok></td>
			</tr>
		|;
		
	}	
	$count++;				# Add a new social network
	my @titleslist = qw(Facebook Twitter);
	print qq|
		<tr>
		<td><select name="netname$count">
		|;
	foreach my $snt (@titleslist) { print qq|
		<option value="$snt">$snt</option>|;
	}
	print qq|
		</select>
		</td>
		<td><input type="text" size="20" name="netid$count" value="$netid"></td>
		<td><input type="checkbox" name="netok$count" value=" checked"$netok></td></tr>
		<td colspan=3><input type="submit" value="Update Social Network Information"></td></tr>
		</table>
		</form></p>
	|;	
	
	print $Site->{footer};
}



#   -------------------------------------------------------------------------------------
#
#   submit_socialnet
#
#   Submit social network information
#
#   -------------------------------------------------------------------------------------

sub update_socialnet {
	
	
	my ($dbh,$query,$man) = @_;
	my $vars = $query->Vars;
#print "Content-type: text/html\n\n";
#while (my ($vx,$vy) = each %$vars) { print "$vx = $vy <br>"; }

						# Get Person Data
	my $pid = &find_person($dbh,$query);
	my $pdata = &db_get_record($dbh,"person",{person_id =>$pid});
	my $pname = $pdata->{person_name} || $pdata->{person_email} || $pdata->{person_id};
	my $record = &db_get_record($dbh,'person',{person_id => $pid});
	
	my $count = 0; my $snstring = "";
	while ($count < 1000) { 	# Huge upper limit on these
		$count++;
		my $netnamefield = "netname".$count;
		my $netidfield = "netid".$count;
		my $netokfield = "netok".$count;
		my $addstr = "";
		if ($vars->{$netnamefield} && $vars->{$netidfield}) {
			$addstr = $vars->{$netnamefield}.",".$vars->{$netidfield}.",".$vars->{$netokfield};
		}

		
		# Stop when we're done, but make sure we're definitely done
		unless ($vars->{$netnamefield}) { unless ($vars->{$netnameid}) { last }};
		if ($snstring) { $snstring .= ";"; }
		$snstring .= $addstr;
	
	}
#	print "Updating person $pid with $snstring <br>";
	if ($snstring) { &db_update($dbh,"person",{person_socialnet=>$snstring},$pid); }
	&form_socialnet($dbh,$query,$man);
	
}


1;

