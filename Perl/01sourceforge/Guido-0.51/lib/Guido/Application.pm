# MODINFO module Guido::Application The primary module for the Guido application
package Guido::Application;
#pragmas
# MODINFO dependency module strict
use strict;
# MODINFO dependency module vars
use vars qw/$VERSION @ISA @EXPORT @EXPORT_OK/;
use vars qw/$splash_screen $splash_status @CONF_PATH/;

#This BEGIN block is mainly for the splash screen
sub BEGIN {
  #This allows hiding of the splash screen (must be set in a BEGIN block)
  if ($main::NO_GUIDO_SPLASH) {return}

	#If the ENV vars are set, we need to add them to
	# the @INC array
	push(@INC, $ENV{GUIDOLIB})  if $ENV{GUIDOLIB};
	push(@INC, $ENV{GUIDOHOME}) if $ENV{GUIDOHOME};
# MODINFO dependency module Tk
	use Tk;
# MODINFO dependency module Tk::JPEG
	use Tk::JPEG;
	my $image_file = Tk::findINC('Guido/guido_splash.jpg');
	my $title = "Guido: GUI Development Objects";
	my $image_width = 500;
	my $image_height = 500;
	$splash_screen = new MainWindow;
	$splash_screen->overrideredirect(1);
    $splash_screen->title($title);
    my $splashphoto = $splash_screen->Photo(-file => $image_file);
    my $sw = $splash_screen->screenwidth;
    my $sh = $splash_screen->screenheight;
    $splash_screen->geometry("+" . int($sw/2 - $image_width/2) .
			     "+" . int($sh/2 - $image_height/2));
    my $l = $splash_screen->Label(-image => $splashphoto)->pack
      (-fill => 'both', -expand => 1);
    $splash_status = $splash_screen->Label(-text=>'Loading Guido...')->pack(-fill=>'x', -expand=>1);
    $splash_screen->update;
}

# MODINFO function splash_status
sub splash_status {
 	if ($splash_screen) {
		$splash_status->configure(-text=>$_[0]);
		$splash_screen->update;
	}
}

#Core modules
# MODINFO dependency module Tk
use Tk;
# MODINFO dependency module Tk::JPEG
use Tk::JPEG;
# MODINFO dependency module Tk::Dialog
use Tk::Dialog;
# MODINFO dependency module FindBin
use FindBin;

#use XML::DOM; #DOM no longer needed, using Simple instead
# MODINFO dependency module XML::Simple
use XML::Simple;
# MODINFO dependency module Data::Dumper
use Data::Dumper;

#Project modules
# MODINFO dependency module Guido::ConfigDialog
use Guido::ConfigDialog;
# MODINFO dependency module Guido::Project
use Guido::Project;
# MODINFO dependency module Guido::RTData
use Guido::RTData;
# MODINFO dependency module Guido::Tracer
use Guido::Tracer;
# MODINFO dependency module Guido::Plugin::Executor
use Guido::Plugin::Executor;
# MODINFO dependency module Guido::PluginLoader
use Guido::PluginLoader;
# MODINFO dependency module Guido::MacroLoader
use Guido::MacroLoader;
# MODINFO dependency module Tk::XMLMenu
use Tk::XMLMenu;
# MODINFO dependency module Tk::Toolbar
use Tk::Toolbar;

# MODINFO dependency module Exporter
require Exporter;
# MODINFO dependency module AutoLoader
require AutoLoader;

# MODINFO parent_class AutoLoader
@ISA = qw(Exporter AutoLoader);
# Items to export into callers namespace by default. Note: do not export
# names by default without a very good reason. Use EXPORT_OK instead.
# Do not simply export all your public functions/methods/constants.
@EXPORT = qw(run);

# MODINFO version 0.03
$VERSION = '0.03';

#Constants
# MODINFO dependency module constant
use constant DEFAULT_CONFIG_FILE => 'guido_config.cfg';
use constant DEFAULT_MENU_FILE => 'Guido/guido_menu.mxl';
use constant DEFAULT_RT_FILE => 'guido_rt.cfg';

#Conf path is where Guido looks for configuration information and
# icons and things.  It will look in @INC if nowhere else is specified
@CONF_PATH = ($ENV{'HOME'} . "/.guido", $FindBin::Bin, @INC);

#Object attributes
# MODINFO dependency module Class::MethodMaker
use Class::MethodMaker get_set => [ qw / config mw menu bin/ ];
use Class::MethodMaker hash => [ qw / projects plugins plugin_data toolbars / ];

# Preloaded methods go here.

##
#TRACING routines
##
my $TRACE;
my $TRACE_WINDOW;
my $MENU;
my $APP;

# MODINFO method TRACE Tracing function for logging diagnostic messages
# MODINFO param msg       STRING Message to send to trace
# MODINFO param trace_lvl STRING Level of tracing required to log msg
sub TRACE {
	my ($self, $msg, $trace_lvl) = @_;
	if ($TRACE) {
		my @caller = caller;
		my $caller = $caller[0] . '[' . $caller[2] .']';
		$TRACE->trace($msg, $trace_lvl, $caller);
	}
}

# MODINFO function trace_window  Displays a message to the trace window
# MODINFO param msg Message to write to trace window
sub trace_window {
	my ($msg) = @_;
	$TRACE_WINDOW->insert('end', "$msg\n");
	$TRACE_WINDOW->yviewMoveto(1);
}


# MODINFO method enable_trace_window Creates a TK window and starts logging TRACE messages to it.
sub enable_trace_window {
	my ($self) = @_;
	$TRACE = new Guido::Tracer(trace_level=>1);
	$TRACE->{target} = \&trace_window;
	my $trace_app = $APP->{mw}->Toplevel(-title=>'Trace Window');
	my $tracew = $trace_app->screenwidth() - 20;
	my $traceh = 100;
	my $tracex = 1;
	my $tracey = $trace_app->screenheight() - (100 + 100);
	$trace_app->geometry($tracew . 'x' . $traceh . "+$tracex+$tracey");
	$TRACE_WINDOW = $trace_app->Scrolled('Text');
	$TRACE_WINDOW->pack(-side=>'top', -fill=>'both', -expand=>1);
	#This causes direct window closing to disable the trace window
	# functionality (such as when you click the "X" on the window)
	$trace_app->protocol('WM_DELETE_WINDOW' => [\&disable_trace_window, $self]);
	$trace_app->raise();
	$MENU->entrycget(
		'Utilities',
		'-menu'
	)->entryconfigure(
		'Enable Trace Window', 
		-label=>'Disable Trace Window', 
		-command=>\&disable_trace_window
	);
	
	return 1;
}

# MODINFO method disable_trace_window Removes trace window from the display.  Future TRACE messages go to STDOUT
sub disable_trace_window {
	my($self) = @_;
	$TRACE_WINDOW->parent->destroy();
	$TRACE = undef;
	$MENU->entrycget(
		'Utilities',
		'-menu'
	)->entryconfigure(
		'Disable Trace Window', 
		-label=>'Enable Trace Window', 
		-command=>\&enable_trace_window,
	);
	return 1;
}

##
#END OF TRACING ROUTINES
##

# MODINFO function run Used to start up Guido without having to call the new method.
sub run {
	#run is used to instantiate the application and create a Tk event loop
	my($class, %attribs) = @_;
	#We might get called in non-object-oriented fashion, so let's just
	# do the obvious here...
	$class ||= 'Guido::Application';

	my $own_self = $class->new(%attribs);
	MainLoop;
	return 0;
}

# MODINFO constructor new Constuctor that returns a reference to the main Guido Application object
# MODINFO paramhash attribs
# MODINFO key trace_level  INTEGER Level of tracing to perform
# MODINFO key trace_window BOOLEAN Send trace output to a scrollable window, instead of STDOUT
sub new {
	#new is the object oriented constructor.  Use "run" to create
	# the Tk application with its own event loop

	my($class, %attribs) = @_;
	my $self = {};
	$self->{bin} = $FindBin::Bin;
	##
	#Init defaults, bless the object
	##
	push(@INC, $ENV{GUIDOLIB}) if $ENV{GUIDOLIB};
	
	$self->{menu_config_path} ||= find_in_path(DEFAULT_MENU_FILE, @CONF_PATH);
	$self->{app_config_path} ||= find_in_path(DEFAULT_CONFIG_FILE, @CONF_PATH);
	$self->{rt_config_path} ||= find_in_path(DEFAULT_RT_FILE, @CONF_PATH);
	$APP = $self;
	
	bless $self, $class;
	
	##
	#Build the MainWindow for the application
	##
	$self->mw(new MainWindow());
	$self->mw->client("guido");
		
	##
	#This causes FormBuilder to keep its forms on top of the mainwindow
	# at all times.  I don't like doing this here, because it assumes formbuilder
	# exists and is desired.  We need a way of making forms "stay on top" by themselves!
	##
	#$self->mw->bind("<Motion>",  sub {$self->plugins("FormBuilder")->raise_all_forms()});

	##
	#This handles tracing options
	##

	if ($attribs{trace_level}) {
		$TRACE = new Guido::Tracer(%attribs);
	}

	$self->TRACE(join("\n", (
	    "Config files:", 
	    "App: " . $self->{app_config_path}, 
	    "RT:  " . $self->{rt_config_path},
	    "Menu:" . $self->{menu_config_path}
	    )), 1
	);
	
	#This reads in the Unix-like .Xdefaults file if it exists
	# just for the convenience of those who know what it is
	eval {$self->mw->optionReadfile(".Xdefaults")};

	#Get the realtime data (data to be kept current)
	# throughout the program's execution
	$self->{rt_data} = new Guido::RTData(file_name=>$self->{rt_config_path});

	$self->TRACE("RealTime data:\n" . Dumper($self->{rt_data}),10);

	#Get the configuration file
	#Note that these configuration entries supersede .Xdefaults
	#
	#XMLin is part of XML::Simple
	$self->{config} = XMLin($self->{app_config_path}, forcearray=>['plugin','macro']);

	#Get the upper-left window icon
	my $guido_small_logo = Tk::findINC('Guido/guido_logo.jpg');
	$self->TRACE("Logo path is $guido_small_logo", 2);
	my $icon = $self->mw->Photo(
		-format=>"jpeg", 
		-file=>$guido_small_logo,
	);
	#This is necessary for the upper-left window icon to work
	$self->mw->withdraw;
	$self->mw->update;
	$self->mw->iconimage($icon);

	#Use the <startup> branch of the config file to configure the app
	my %config_specs = %{$self->{config}->{startup}};
	
	while( my($setting, $value) = each %config_specs) {
		next if $setting =~ /^(load_last_project|remember_last_geo)$/;
		if ($setting eq 'geometry') {
			$self->{mw}->geometry($value);
		}
		else {
			$self->{mw}->configure($setting, $value);
		}
	}

	$self->{plugin_data} = $self->config->{plugindata};
	$self->TRACE(Dumper($self->{plugin_data}), 10);

	#Configure status_bar
	$self->{status_bar} = $self->{mw}->Label(
		-justify=>'left',
		-anchor=>'w',
	)->pack(
		-side=>'bottom',
		-anchor=>'sw',
		-fill=>'x',
	);
	
	#Init the main menu, toolbar, registered macros & plugins
	$self->init_menu();

	#Have to wait until the menu is built to enable trace window
	if ($attribs{trace_window}) {
		$self->enable_trace_window();
	}

	$self->init_toolbar();
	$self->init_macros();
	$self->init_plugins();

	#Load previous project, if any
	if ($self->{config}->{startup}->{load_last_project}) {
		if (my $last_project = $self->{rt_data}->data('last_project')) {
			my $project_ref = $self->open_project(file_path=>$last_project);
			#If load fails, remove entry from rt_config
			if (!$project_ref) {
				$self->{rt_data}->delete('last_project');
				$self->{rt_data}->save();
			}
		}
	}

	#Reset status
	$self->status();

	#We might be able to drop this global ref kludge later, if we work out certain
	# ways of storing the ref to the app object while using Tk callbacks
	$main::GuidoApp = $self;

	#Now show ourselves and remove splash screen
	$self->mw->deiconify; 
	$self->mw->raise;
	$self->mw->update;
	$self->mw->focusForce;
	$splash_screen->destroy if $splash_screen;	

	return $self;
}

# MODINFO method init_menu Initializes Guido's menu
sub init_menu {
	my($self, %params) = @_;
	splash_status("Loading menus...");
	$self->{menu} = Tk::XMLMenu::import_menu($self, $self->{menu_config_path}, \&eval_handler);
	
	$self->_refresh_recent_files();
		
	$MENU = $self->{menu};
	return 1;
}

# MODINFO method init_toolbar  Initializes the toolbar for Guido
sub init_toolbar {
	my($self, %params) = @_;
	splash_status("Loading toolbar...");
	
	my $toolbar = $self->{mw}->Toolbar(
		-buttons=>[
			[
				'New Project',
				"$ENV{GUIDOLIB}/Tk/Toolbar/NEW.gif",
				sub {$self->plugins("ProjectManager")->new_project()},
				
			],			
			[
				'Open Project',
				"$ENV{GUIDOLIB}/Tk/Toolbar/OPEN.gif",
				sub {$self->plugins("ProjectManager")->open_project()},
				
			],
			[
				'Restart Guido',
				"$ENV{GUIDOLIB}/Tk/Toolbar/REFRESH.gif",
				sub {$self->reinit_app()},
				
			],
		],
	)->pack(
		-side=>'top',
		-anchor=>'nw',
	);

	$self->toolbars('main', $toolbar);
	
	return 1;
}

# MODINFO method init_macros Initializes the currently registered macros
sub init_macros {
	my($self, %params) = @_;
	splash_status("Loading registered macros...");
	$self->{macro_loader} = new Guido::MacroLoader(
		app=>$self,
		config_file=>$self->{app_config_path},
	);
	$self->{macro_loader}->import_macros();
	return 1;
}

# MODINFO method init_plugins Initializes the currently registered plugins
sub init_plugins {
	my($self, %params) = @_;
	$self->TRACE("Loading plugins", 1);
	splash_status("Loading plugins...");
	$self->{plugin_loader} = new Guido::PluginLoader(
		app=>$self,
		#config_file=>$self->{plugin_config_path},
		config_file=>$self->{app_config_path},
	);
	$self->{plugin_loader}->import_plugins();
	return 1;
}

# MODINFO method reinit_plugin Reinitializes a particular plugin, causing its display to refresh
# MODINFO paramhash params
# MODINFO key       name   STRING Name of plugin to reinitialize
sub reinit_plugin {
	my($self, %params) = @_;
	$self->TRACE("Reloading $params{name}",1);

	#Does this work?
	$self->plugins($params{name}, undef)->destroy();

	$self->{plugin_loader}->import_plugins(
		plugin => $params{name},
	);
	return 1;
}

# MODINFO method reinit_app  Restarts the Guido IDE using the original command line parameters
sub reinit_app {
	my ($self) = @_;
	$self->TRACE("Restarting Guido", 1);
	#These are just to keep things cleaned up for a select few
	# operating systems...
	if ($^O eq 'MSWin32') {system("cls")}
	elsif ($^O eq 'Linux') {system("clear")}
	my $ex = $self->plugins("Executor");
	my $proc = $ex->launch(
		path=>$^X, 
		parameters=>"$0 " . join(' ', @ARGV), working_dir=>'.',
	);
	exit;
}

# MODINFO method open_project Opens a new project
# MODINFO paramhash params
# MODINFO key       file_path  STRING Path to the project file to be opened
# MODINFO retval Guido::Project
sub open_project {
	my($self, %params) = @_;
	
	#Create the base project object
	my $project_ref = load Guido::Project(file_path=>$params{file_path}, app=>$self);
	$self->TRACE("Project ref is $project_ref",1);
	if ($project_ref) {
		$self->TRACE("Adding project " . $project_ref->{name} . " to the projects list", 1);
		$self->projects($project_ref->{name}, $project_ref);
		$self->{rt_data}->data('last_project', $params{file_path});
		my $recent = $self->{rt_data}->data('recent_files');
		$recent = [$recent] if ref($recent) ne 'ARRAY';
		my $found;
		foreach my $path (@$recent) {
			$found = 1 if $path eq $params{file_path};
		}
		unshift(@$recent, $params{file_path}) unless $found;
		$self->{rt_data}->data('recent_files', $recent);
		$self->{rt_data}->save();
		$self->refresh();
	}
	push(@INC, $project_ref->working_dir);
	$self->TRACE("Adding " . $project_ref->working_dir . " to \@INC", 1);
	return $project_ref;

}

# MODINFO method close_project  Closes a named project that is currently open in the IDE
# MODINFO paramhash params
# MODINFO key       project_name  STRING Name of project to close
# MODINFO retval Guido::Project
sub close_project {
	my($self, %params) = @_;
	
	#Close the project
	$self->TRACE("Closing project $params{project_name}", 1);
	#$self->projects($params{project_name});
	my $project_ref = delete $self->{projects}{$params{project_name}};
	#my $project_ref = $self->projects($params{project_name}, undef);
	$self->refresh();
	return $project_ref;
}

# MODINFO method new_project Creates a new project and returns it
# MODINFO paramhash params  This paramhash is passed directly to the Guido::Project new constructor
# MODINFO retval Guido::Project
sub new_project {
	my($self, %params) = @_;
	
	#Create the base project object
	my $project_ref = new Guido::Project(%params) or return undef;
	
	$self->TRACE("Adding project " . $project_ref->{name} . " to the projects list", 1);
	$self->projects($project_ref->{name}, $project_ref);
	$self->refresh();
	return $project_ref;
}

# MODINFO method refresh Reinits all plugins
# MODINFO retval
sub refresh {
	my($self) = @_;
	#Refresh all plugins	
	foreach my $plugin ($self->plugins_values()) {
		$self->TRACE("Refreshing $plugin",1);
		$plugin->refresh();
	}
	$self->_refresh_recent_files();
}

# MODINFO method status  Updates the status bar at the bottom of the IDE
# MODINFO param status_msg  STRING Message to be displayed (if empty, the status is reset to "Ready"
# MODINFO retval INTEGER
sub status {
	my($self, $status_msg) = @_;
	#CR and LF not allowed
	$status_msg ||= "Ready";
	$status_msg =~ s/(\n|\r)//g;
	$self->{status_bar}->configure(-text => $status_msg);
	$self->{mw}->update();
	return 1
}

# MODINFO method choose_project  Allows the choosing of a project using a file selection dialog box
# MODINFO retval
sub choose_project {
	my($self, %params) = @_;
	my $file_path = $self->{mw}->getOpenFile(
												-defaultextension=>"xml",
												-initialdir=>".",
												-title=>"Choose project file",
											);
	$self->open_project(file_path=>$file_path) if $file_path;
}

# MODINFO method save_config  Saves the current in-memory configuration settings to disk
# MODINFO retval INTEGER
sub save_config {
	my($self) = @_;
	if ($self->{config}->{startup}->{remember_last_geometry}) {
		$self->{config}->{startup}->{geometry} = $self->{mw}->geometry();
	}
	my $xml = XMLout(
		$self->{config}, 
		rootname=>'configuration'
	);
	$self->TRACE("Writing:\n" . $xml,1);
	
	#Persist the XML stream to the save_as or file_path
	open (OUT, ">" . $self->{app_config_path}) or die "Couldn't open " . $self->{app_config_path} . " for saving\n";
	print OUT $xml;
	close(OUT);	
	return 1;
}

# MODINFO method edit_config  Displays the configuration editor dialog box
# MODINFO retval INTEGER
sub edit_config {
	my($self) = @_;
	my $orig_config = $self->{config};
	my $conf = $self->{mw}->ConfigDialog(-app=>$self, -config=>$orig_config);
	my $new_config = $conf->Show();
	if ($new_config) {
		$self->{config} = $new_config;
		my $response = $self->{mw}->Dialog(
			-title=>'Save Configuration Changes?',
			-text=>'You made changes to Guido\'s current configuration.  Would you like to save the changes so they\'ll be available the next time you run Guido?',
			-default_button=>'Yes',
			-buttons=>['Yes','No'],
			-bitmap=>'question',
		)->Show();
		if ($response eq 'Yes') {$self->save_config()};
	}
	return 1;
}

# MODINFO method place_menu  Allows a plugin to place a menu in the IDE's menu structure
# MODINFO param menu_name    STRING Name of the menu in which to place the menu referenced by the menu_ref parameter
# MODINFO param submenu_name STRING Name to give the submenu
# MODINFO param menu_ref     Tk::Menu Reference to the menu that is to be placed
# MODINFO retval INTEGER
sub place_menu($$$) {
	my($self, $menu_name, $submenu_name, $menu_ref) = @_;
	my $menu_bar = $self->{menu};
	my $menu_item;
	$self->TRACE("Adding menu $submenu_name",2);
	eval {
		$menu_item = $menu_bar->entrycget($menu_name, '-menu');
	};
	if ($@) {
		 warn "Insertion of menu item '$submenu_name' for " . caller() . " failed: menu item '$menu_name' does not exist.";
		return 0;
	}
	else {
		my $submenu_item = $menu_item->insert(0, 'cascade', 
			-label=>$submenu_name, 
			-menu=>$menu_ref,
		);
		return 1;
	}
}

# MODINFO method ERROR  Displays an error dialog box with the provided message
# MODINFO paramhash params
# MODINFO key       text           STRING Text to display in the dialog
# MODINFO key       title          STRING Title to give the dialog
# MODINFO key       bitmap         STRING Valid TK bitmap value to use when displaying the dialog
# MODINFO key       buttons        ARRAYREF Array reference to a list of strings to display as buttons
# MODINFO key       default_button STRING
# MODINFO retval    STRING
sub ERROR {
	my($self, %params) = @_;
#	my %params = @params;
	my ($text, $title, $bitmap);
	if(!$params{text}) {
		$text = @{keys(%params)}[0];
	}
	else {
	
		$text = $params{text};
		$title = $params{title};
		$bitmap = $params{bitmap};
	}

	my $buttons = $params{buttons} || [qw/ OK /];
	my $default_button = $params{default_button} || 'OK';

	if($title) {
		$title = "Guido Error: " . $title;
	}
	else {
		$title = "Guido Error";
	}
	my @caller = caller();
	
	$self->TRACE("Error from " . $caller[0] . "::" . $caller[2] . ": " . $params{text}, 1);
	
	my $dlg_err = $self->{mw}->Dialog(
		-text=>$params{text},
		-title=>$title,
		-buttons=>$buttons,
		-bitmap=>$bitmap,
		-default_button=>$default_button,
	);

	return $dlg_err->Show();
}

# MODINFO function eval_handler  Evaluates code passed into it
# MODINFO param eval_code  STRING The code to evaluate
sub eval_handler {
	my($eval_code) = @_;
	return eval "$eval_code";
}

# MODINFO function find_in_path  Finds the provided file in the provided path
# MODINFO param file       STRING File to find
# MODINFO paramarray path  Array of directories to search for the file
# MODINFO retval STRING
sub find_in_path {
    my($file, @path) = @_;
    my $dir;
    $file  =~ s,::,/,g;
    foreach $dir (@path) {
	my $path;
	return $path if (-e ($path = "$dir/$file"));
    }
    return undef;
}

sub _about {
    my ($self) = @_;
    my $image_file = Tk::findINC('Guido/guido_splash.jpg');
    my $title = "Guido: GUI Development Objects";
    my $image_width = 500;
    my $image_height = 500;
    my $about = new MainWindow;
    $about->overrideredirect(1);
    $about->title($title);
    my $aboutphoto = $about->Photo(-file => $image_file);
    my $sw = $about->screenwidth;
    my $sh = $about->screenheight;
    $about->geometry("+" . int($sw/2 - $image_width/2) .
			     "+" . int($sh/2 - $image_height/2));
    my $l = $about->Label(
	-image => $aboutphoto
    )->pack(
	-fill => 'both', 
	-expand => 1
    );
    my $about_label = $about->Label(
	-text=>'Copyright 2000 James Tillman and the Guido Project Team'
    )->pack(
	-fill=>'x', -expand=>1
    );
    $about->bind("<Button-1>", [\&_close_about, $about]);
    $about->update;
}

sub _close_about {$_[1]->destroy()}

sub _refresh_recent_files {
	my($self) = @_;
	#add recent files to the File menu
	my $file_menu = $self->{menu}->entrycget('File', '-menu');
	my @menu_struct;
	my $recent_files = $self->{rt_data}->data('recent_files');
	$recent_files = [] if ref($recent_files) eq 'HASH';
	$recent_files = [$recent_files] if ((ref($recent_files) ne 'ARRAY') and ($recent_files));
	
	foreach my $file_path (@$recent_files){
	  next if ref($file_path);
		push(@menu_struct,[
			'Button' => $file_path,
			-command=>sub {$self->open_project(file_path=>$file_path)},
		]);
	}
	if ($file_menu) {
		my $menu_ref = $file_menu->Menu(-menuitems=>\@menu_struct);
		my $recent_menu;
		$@ = undef;
		eval {
			$recent_menu = $file_menu->entrycget('Recent Files', '-menu');
		};
		if ($recent_menu && !$@) {
			$file_menu->entryconfigure('Recent Files', -menu=>$menu_ref);
		}
		else {
			my $submenu_item = $file_menu->insert(0, 'cascade', 
				-label=>'Recent Files', 
				-menu=>$menu_ref,
			);
		}
	}
}


# Autoload methods go after =cut, and are processed by the autosplit program.

1;
__END__

=head1 NAME

Guido::Application - The primary Guido class that manages the primary functions of the IDE.

=head1 SYNOPSIS

  use Guido::Application;
  Guido::Application::run();

=head1 DESCRIPTION

Guido::Application provides the core management functions for the IDE, including tracing, plugin loading, and macro/toolbar initialization

=head1 INTERFACE

=head2 Parent Classes

=over 4


=item AutoLoader

=back





=head2 Constructors



=over 4



=item sub new returns [VOID]

=over 4

=item _hash as attribs

=back

Constuctor that returns a reference to the main Guido Application object



=back





=head2 Methods



=over 4



=item sub TRACE returns [VOID]

=over 4

=item msg as STRING
=item trace_lvl as STRING

=back

Tracing function for logging diagnostic messages


=item sub enable_trace_window returns [VOID]

Creates a TK window and starts logging TRACE messages to it.


=item sub disable_trace_window returns [VOID]

Removes trace window from the display.  Future TRACE messages go to STDOUT


=item sub init_menu returns [VOID]

Initializes Guido's menu


=item sub init_toolbar returns [VOID]

Initializes the toolbar for Guido


=item sub init_macros returns [VOID]

Initializes the currently registered macros


=item sub init_plugins returns [VOID]

Initializes the currently registered plugins


=item sub reinit_plugin returns [VOID]

=over 4

=item params as HASH

=over 4

=item name as STRING

=back

=back

Reinitializes a particular plugin, causing its display to refresh


=item sub reinit_app returns [VOID]

Restarts the Guido IDE using the original command line parameters


=item sub open_project returns [Guido::Project]

=over 4

=item params as HASH

=over 4

=item file_path as STRING

=back

=back

Opens a new project


=item sub close_project returns [Guido::Project]

=over 4

=item params as HASH

=over 4

=item project_name as STRING

=back

=back

Closes a named project that is currently open in the IDE


=item sub new_project returns [Guido::Project]

=over 4

=item params as HASH


=back

Creates a new project and returns it


=item sub refresh returns [VOID]

Reinits all plugins


=item sub status returns [INTEGER]

=over 4

=item status_msg as STRING

=back

Updates the status bar at the bottom of the IDE


=item sub choose_project returns [VOID]

Allows the choosing of a project using a file selection dialog box


=item sub save_config returns [INTEGER]

Saves the current in-memory configuration settings to disk


=item sub edit_config returns [INTEGER]

Displays the configuration editor dialog box


=item sub place_menu returns [INTEGER]

=over 4

=item menu_name as STRING
=item submenu_name as STRING
=item menu_ref as Tk::Menu

=back

Allows a plugin to place a menu in the IDE's menu structure


=item sub ERROR returns [STRING]

=over 4

=item params as HASH

=over 4

=item text as STRING

=item title as STRING

=item bitmap as STRING

=item buttons as ARRAYREF

=item default_button as STRING

=back

=back

Displays an error dialog box with the provided message



=back





=head2 Functions



=over 4



=item sub splash_status returns [VOID]




=item sub trace_window returns [VOID]

=over 4

=item msg as Message

=back

Displays a message to the trace window


=item sub run returns [VOID]

Used to start up Guido without having to call the new method.


=item sub eval_handler returns [VOID]

=over 4

=item eval_code as STRING

=back

Evaluates code passed into it


=item sub find_in_path returns [VOID]

=over 4

=item file as STRING
=item path as 

=back

Finds the provided file in the provided path



=back





=head2 Dependencies

=over 4

=item module strict

=item module vars

=item module Tk

=item module Tk::JPEG

=item module Tk

=item module Tk::JPEG

=item module Tk::Dialog

=item module FindBin

=item module XML::Simple

=item module Data::Dumper

=item module Guido::ConfigDialog

=item module Guido::Project

=item module Guido::RTData

=item module Guido::Tracer

=item module Guido::Plugin::Executor

=item module Guido::PluginLoader

=item module Guido::MacroLoader

=item module Tk::XMLMenu

=item module Tk::Toolbar

=item module Exporter

=item module AutoLoader

=item module constant

=item module Class::MethodMaker

=back



=head1 KNOWN ISSUES

Known issues should be listed here

=head1 AUTHOR

jtillman@bigfoot.com

=head1 SEE ALSO

perl(1).

=cut



