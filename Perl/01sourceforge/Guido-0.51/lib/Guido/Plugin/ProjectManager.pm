# MODINFO module Guido::Plugin::ProjectManager Guido plugin for managing projects and displaying their structure and status
package Guido::Plugin::ProjectManager;
# MODINFO dependency module strict
use strict;

# MODINFO dependency module vars
use vars qw/ $inc_dir /;
# MODINFO dependency module constant
use constant DELIM => '&';
# MODINFO dependency module Tk::Tree
use Tk::Tree;
# MODINFO dependency module Tk::DirSelect
use Tk::DirSelect;
# MODINFO dependency module Tk
use Tk;
# MODINFO dependency module Tk::JPEG
use Tk::JPEG;
# MODINFO dependency module Tk::DialogBox
use Tk::DialogBox;
# MODINFO dependency module Tk::Dialog
use Tk::Dialog;
# MODINFO dependency module Data::Dumper
use Data::Dumper;
# MODINFO dependency module Tie::IxHash
use Tie::IxHash;

# MODINFO dependency module Cwd
use Cwd;
# MODINFO dependency module File::Slurp
use File::Slurp;
# MODINFO dependency module File::Spec
use File::Spec;
# MODINFO dependency module File::Spec::Functions
use File::Spec::Functions;
# MODINFO dependency module File::Basename
use File::Basename;
# MODINFO dependency module XML::Simple
use XML::Simple;

# MODINFO dependency module Guido::SourceFile
use Guido::SourceFile;
# MODINFO dependency module Guido::UsedModule
use Guido::UsedModule;

# MODINFO dependency module vars
use vars qw( @ISA );
# MODINFO dependency module Guido::Plugin
use Guido::Plugin;
# MODINFO dependency module Tk::Derived
use Tk::Derived;
# MODINFO dependency module Tk::Frame
use Tk::Frame;
# MODINFO parent_class Tk::Frame
@ISA = qw( Guido::Plugin Tk::Derived Tk::Frame );

#use base qw/Guido::Plugin Tk::Derived Tk::Frame/;

Construct Tk::Widget 'ProjectManager';

my $tree_projs;
my $default_project;
my $config;
my $app;
my $menus;
my $menu;
my $clicked; #Keeps ref to most recently right-clicked object
my $popup_menu;
my $source_file_popup;
my $required_file_popup;
my $used_module_popup;
my $support_file_popup;
my @modules;
$inc_dir = '';

#################
#TK GUI METHODS
#################

# MODINFO method Populate Standard Tk initialization method
# MODINFO paramhashref args
sub Populate {
	my ($cw, $args) = @_;
	my $label_frame = $cw->Frame(
		-borderwidth => 3,
		-relief => 'raised',

	)->pack(
		-fill => 'both',
		-expand => 1,
	);
	my $header = $label_frame->Label(
		-text=>'Project Manager',
		-font => '{Arial} 8 {bold}',
		-background => 'dark blue',
		-foreground => 'white',
		-borderwidth => 2,
		-relief => 'raised',
	)->pack(
		-side => 'top',
		-fill => 'x',
	);

	#Now create the tree widget that will show the projects and files
	$tree_projs = $label_frame->ScrlTree(
		-separator=>DELIM,
		-command=>\&_e_file_click,
		-browsecmd => \&_e_file_select,
	);

#	$tree->bind("<Button-3>", [\&clicked, Ev('x'), Ev('y')]);
	$tree_projs->bind("<Button-3>", [\&_e_popup_menu, Ev('x'), Ev('y')]);
	$tree_projs->pack(
		-side=>"top",
		-anchor=>'sw',
		-fill=>'both',
		-expand=>1
	);

	#Set up our popup menu
	my $menu_items = [];

	$popup_menu = $cw->Menu(
		-menuitems => $menu_items,
		-tearoff => 0
	);

	#Finish by calling the SUPER class's Populate function
	$cw->SUPER::Populate($args);
}

# MODINFO function init_plugin Initialize the plugin within the IDE
# MODINFO param param_app Guido::Application Ref to the main IDE object
sub init_plugin {
# MODINFO dependency module File::Basename
    use File::Basename;
# MODINFO dependency module Data::Dumper
    use Data::Dumper;

    my($self, $param_app) = @_;
    $self->{app} = $param_app;
    $app = $param_app;
    $self->_init_display;
    $config = $param_app->{plugin_data}->{ProjectManager};
}

# MODINFO function place_menus Called when the plugin is supposed to place its menus (if any) within the IDE.  (1=success/0=success)
# MODINFO param app Guido::Application Ref to the main IDE object
# MODINFO retval INTEGER
sub place_menus {
    my($self, $app) = @_;

    my $menu_struct = 
		[
		    [Button => '~New Project', 
		     -command=>\&new_project,
	    	],
	    	[Button => '~Open Project',
	    		-command=>\&open_project,
	    	],
			[Button => '~Save Project', 
				-command=>\&save_project, -state=>'disabled',
			],
			[Button => '~Run Project', 
				-command=>\&run_project, -state=>'disabled',
			],
			[Button => '~Debug Project', 
				-command=>\&debug_project, -state=>'disabled',
			],
	    	[Button => '~Collate Project',
	    		-command=>\&collate_project, -state=>'disabled',
	    	],
	    	[Button => '~Close Project',
	    		-command=>[\&close_project, $self], 
	    		-state=>'disabled',
	    	],
	
			[Cascade => '~Add Existing',
	    		-tearoff => 0, 
	    		-state=>'disabled',
	    		-menuitems =>
					[
					    #This structure is built later in this method
					]
	    	],
	
			[Cascade => '~New',
				-tearoff => 0, 
				-state=>'disabled',
				-menuitems =>
					[
					    #This structure is built later in this method
					],
			],
	
			[Button => '~Save Selected File', 
				-command=>\&_e_save_selected,
	    		-state=>'disabled',
			],
			[Button => '~Edit Selected File', 
				-command=>\&_e_edit_selected,
	    		-state=>'disabled',
			],
			[Button => '~Remove Selected File', 
				-command=>\&_e_remove_selected,
	    		-state=>'disabled',
			],
		];

	
	#Build the "New" cascade menu item structure
	foreach my $sourcefile_type (Guido::SourceFile::types) {
		push(
			@{$menu_struct->[8]->[7]},
			[	
				Button   => '~' . $sourcefile_type,
				-command => sub {_e_file_new("$sourcefile_type")},
			]	
		);
		push(
			@{$menu_struct->[7]->[7]},
			[	
				Button   => '~' . $sourcefile_type, 
				-command => sub {_e_file_add("$sourcefile_type")},
			]	
		);
	}

    $menu = $app->{mw}->Menu(-menuitems=>$menu_struct);

    my $retval = $app->place_menu("File", "Project", $menu);

    if ($retval) {
    	$self->{menu} = $menu;
    }
    else {
    	$app->ERROR(text=>"Couldn't place ProjectManager menu!: $!");
    }

	#Set up the Source File popup menus
	my($add_existing_menu, $add_new_menu);
	foreach my $sourcefile_type (Guido::SourceFile::types) {
		push(
			@$add_existing_menu,
			[
				Button   => '~' . $sourcefile_type, 
				-command => sub {_e_file_new("$sourcefile_type")},
			]	
		);
		push(
			@$add_new_menu,
			[	
				Button   => '~' . $sourcefile_type, 
				-command => sub {_e_file_add("$sourcefile_type")},
			]	
		);
	}
		

	my $source_file_menu_struct = [
			[Cascade => '~Add Existing',
	    		-tearoff => 0, 
	    		-state=>'normal',
	    		-menuitems => $add_existing_menu,
	    	],
	
			[Cascade => '~New',
				-tearoff => 0, 
				-state=>'normal',
				-menuitems => $add_new_menu,
			],
	];

	$source_file_popup = $self->Menu(
		-menuitems => $source_file_menu_struct,
		-tearoff => 0,
	);


	my $required_file_menu_struct = [
			[Button => '~Add Existing',
				-command => [\&_e_req_file_add],
	    	],
	
#			[Button => '~New',
#				-command => sub{},
#			],		
	];

	$required_file_popup = $self->Menu(
		-menuitems => $required_file_menu_struct,
		-tearoff => 0,
	);

	my $used_module_menu_struct = [
			[Button => '~Add Existing',
				-command => [\&_e_used_mod_add],
	    	],
	
#			[Button => '~New',
#				-command =>sub{},
#			],		
	];

	$used_module_popup = $self->Menu(
		-menuitems => $used_module_menu_struct,
		-tearoff => 0,
	);


	my $support_file_menu_struct = [
			[Button => '~Add Existing',
				-command => [\&_e_sup_file_add],
	    	],
	
#			[Button => '~New',
#				-command =>sub{},
#			],		
	];

	$support_file_popup = $self->Menu(
		-menuitems => $support_file_menu_struct,
		-tearoff => 0,
	);
	
	return 1;
}

# MODINFO method refresh Tells object to update its display
sub refresh {
	my($self) = @_;
	$app->TRACE("Refreshing display",1);
	$self->_init_display();
}



###########################
#PROJECT MANAGEMENT METHODS
###########################

# MODINFO function new_project Create a new project based on user input
# MODINFO param project_dir STRING Directory to create the project in
# MODINFO param project_name STRING Name to give the new project
# MODINFO retval Guido::Project
sub new_project {
	my ($project_type, $project_dir, $project_name) = @_;

	#$project_type ||= "TkApp";

	my $tl = $app->{mw}->DialogBox(
		-title=>"New Project",
		-buttons=>["OK", "Cancel"],
	);
	
	#This was the old base path
	#my $tpl_base_path = Tk::findINC('Guido/templates');
	my $tpl_base_path = Tk::findINC("Guido/Project");
	if (!$tpl_base_path) {
		$app->ERROR(text=>"Couldn't locate Guido template directory! (Must be in \@INC path)");
		return undef;
	}
	$app->TRACE("Project templates path is $tpl_base_path",1);

	$app->TRACE(Dumper($config),1);
	my @listing = read_dir($tpl_base_path);
	$app->TRACE(Dumper(\@listing),1);
	my $project_types = {};
	foreach my $item (@listing) {
		if (!-f "$tpl_base_path/$item" || $item !~ s/.pm$//) {next}
		my $data_path = "$tpl_base_path/$item/templates/data";
		$app->TRACE($data_path,1);
		next if !-r "$data_path/label";
		$project_types->{$item}->{label} = read_file("$data_path/label");
		$project_types->{$item}->{icon} = "$data_path/icon.jpg" if -r "$data_path/icon.jpg";
	}

	my $i = 0;
	my @buttons;
	$app->TRACE(Dumper($project_types),1);
	foreach my $proj_type (keys %$project_types) {
			$app->TRACE("Looking for icon for $proj_type",1);
			my $icon;
			my $btn;
			my $icon_path = $project_types->{$proj_type}->{icon};

			my $fr = $tl->Frame(
				-label=>$project_types->{$proj_type}->{label},
			)->pack(side=>'left', anchor=>'n');
			
			if ($icon_path) {
				my $j = $i;
				$icon = $app->{mw}->Photo(
					-format=>"jpeg", 
					-file=>$icon_path
				);
				$btn = $fr->Button(
					-command => sub {set_proj_type($proj_type, $j, \$project_type, \@buttons);},
					-relief => 'flat',
					-image => $icon,
					-padx => 0,
					-pady => 0,
				)->pack(-side => 'top');

			}
			else {
				$app->TRACE("Icon file $icon_path not found",1);
				my $j = $i;
				$icon = 'questhead',
				$btn = $fr->Button(
					-command => sub {set_proj_type($proj_type, $j, \$project_type, \@buttons);},
					-relief => 'flat',
					-bitmap => $icon,
					-padx => 0,
					-pady => 0,
				)->pack();
			}
			
			push(@buttons, $btn);
			++$i;
	}

	$tl->Label(-text=>'Project Name')->pack();
	$tl->Entry(-textvariable=>\$project_name)->pack();
	my $fr = $tl->Frame()->pack();
	$fr->Label(-text=>'Project Directory')->pack(-side=>'top');
	$fr->Entry(-textvariable=>\$project_dir)->pack(-side=>'left');
	$fr->Button(-text=>'...', -state=>'disabled', -command=>[\&get_proj_dir, $tl, \$project_dir])->pack(-side=>'right');

	my $button_choice = $tl->Show();
	
	return undef if $button_choice eq 'Cancel';
	if ($project_name && $project_type && -d $project_dir) {
		$app->TRACE("New project named $project_name, type $project_type, in directory $project_dir", 1);
		$app->TRACE("App ref is $app", 1);
		#$project_file = catfile($project_dir, $project_name . ".xml");
		my $new_proj = $app->new_project(
			app=>$app, 
			name=>$project_name,
			working_dir=>$project_dir,
			type=>$project_type
		);
		return undef if !$new_proj;
		$app->TRACE("Successfully created new project object",1);
		
		#Enable file related menus
		_enable_project_menus();

		#Set this proj to our default for future operations
		$default_project = $new_proj;

		#Clear the status bar
		$app->status();	

		#Load the project into the application
		$app->open_project(
			file_path=>$new_proj->{file_path},
		);

		return $new_proj;
	}
	else {
		$app->ERROR(title=>"Invalid project values", text=>"You must provide a valid name and directory for your project and choose a project type");
		return new_project($project_type, $project_dir, $project_name);
	}
}

# MODINFO method get_proj_dir Get directory for the project
sub get_proj_dir {
	$app->TRACE("Showing directory dialog",1);
	my($dialog, $proj_dir_ref) = @_;
	my $fs = $dialog->DirSelect();
	my $temp_dir = $fs->Show();
	$$proj_dir_ref = $temp_dir if $temp_dir;
}

# MODINFO method set_proj_type
sub set_proj_type {
	my($proj_type, $btn_idx, $proj_type_ref, $buttons) = @_;
	my $curr_proj_type = $proj_type;
	$app->TRACE("Project type: $proj_type, button index: $btn_idx\n",1);
	foreach my $btn (@$buttons) {
		$btn->configure(-relief=>'flat');
	}
	$buttons->[$btn_idx]->configure(-relief=>'sunken');
	$$proj_type_ref = $curr_proj_type;
	return 1;
}


# MODINFO method open_project
sub open_project {
	$app->status("Please choose file");
	print cwd . "\n";
	my $file_path = $app->{mw}->getOpenFile(
	    -defaultextension=>"gpj",
	    -filetypes => [
		['Guido Project Files', ['.gpj']],
	    ],
	    -initialdir=>cwd,
	    -title=>"Choose project file",
	);
	$default_project = $app->open_project(file_path=>$file_path) 
	  if $file_path;

	#Enable file related menus
	_enable_project_menus();

	$app->status();	
}

# MODINFO method save_project
sub save_project {
	$app->TRACE($default_project,1);
	$default_project->save_project();
}

# MODINFO method debug_project
sub debug_project {
	$app->TRACE("Debugging $default_project",1);
	my $working_dir = $default_project->{working_dir};
	my $file_path = $default_project->{startup_file};
	$default_project->collate_project(save_as=>"$working_dir/$file_path");
	$app->TRACE("Trying to open $file_path (working dir $working_dir)...", 1);
	my $exec = $app->plugins("Executor");
	if ($exec) {
		my $process = $exec->launch(path=>"perl", working_dir=>$working_dir, parameters=>"-d:ptkdb $file_path");
		$app->TRACE("Executor plugin returned: $process",1);
	}
	else {
		$app->TRACE("Executor plugin not loaded! Failed to execute $file_path",1);
	}
}

# MODINFO method run_project
sub run_project {
    $app->TRACE("Running $default_project",1);
    my $working_dir = $default_project->{working_dir};
    my $file_path = $default_project->{startup_file};
    $default_project->collate_project(save_as=>"$working_dir/$file_path");
    $app->TRACE("Trying to open $file_path (working dir $working_dir)...", 1);
    my $exec = $app->plugins("Executor");
    if ($exec) {
	my $process = $exec->launch(path=>"perl", working_dir=>$working_dir, parameters=>$file_path);
	$app->TRACE(text=>"Executor plugin returned: $process",1);
    }
    else {
	$app->ERROR(text=>"Executor plugin not loaded! Failed to execute $file_path");
    }
}


# MODINFO method close_project
sub close_project {
	my($self) = @_;
	$app->TRACE("Closing project", 1);
	$app->plugins("FormBuilder")->destroy_all_forms() or return 0;
	if ($default_project->dirty) {
	
		my $dialog = $app->{mw}->Dialog(
			-text => 'Changes were made to this project, do you wish to save them?', 
			-bitmap => 'question', 
			-title => 'Save Changes?', 
			-default_button => 'Yes', 
			-buttons => [qw/Yes No Cancel/],
		);
		my $response = $dialog->Show();
		if ($response eq "Cancel") {
			return 0;
		}
		elsif ($response eq "Yes") {
			unless($default_project->save_project()) {
				$app->ERROR("Error saving project!: $!");
				return 0;
			}
		}
	}
	
	$app->close_project(project_name=>$default_project->name);
	if (!keys(%{$app->projects()})) {
		$self->_disable_project_menus();
	}
	else {
		$app->TRACE(keys(%{$app->projects()}) . " projects still open", 1);
	}
	return 1;
}

# MODINFO method collate_project
sub collate_project {
	my $save_as = $app->{mw}->getSaveFile(
		-initialdir => $default_project->working_dir,
		-defaultextension => 'pl',
		-filetypes => [
			['Perl Files', ['.pl', '.pm']],
		],
		-title => 'Save collated project to file',
	);
	$default_project->collate_project(save_as=>$save_as);
}


# MODINFO method set_selection
sub set_selection {
	my($self, $item) = @_;
	$self->{selection} = $item;
	return 1;
}

#################
#Private methods
#################

#This routine takes a menu ref and an array of menu items to 
# dig down into
sub _get_menu_ref {
 my $menu = shift;
 while(my $menu_name = shift) {
  $menu = $menu->entrycget($menu_name, -menu);
 }
 return $menu;
}

sub _init_display {
	my($self) = @_;
	my $app = $self->{app};
	
	#Remove all current items
	$tree_projs->delete('all');
	
	$app->TRACE('Total projects: ' . scalar($app->projects_keys()), 1);
	if (scalar($app->projects_keys())) {
		_enable_project_menus();
	}


	foreach my $proj ($app->projects_values()) {
		$app->TRACE("Adding project " . $proj->name() . " to the project manager.", 1);
		#_enable_project_menus();
		
		$tree_projs->add(
			$proj->name(), 
			-itemtype=>'text', 
			-text=>$proj->name(),
		);
		$tree_projs->add(
			$proj->name() . DELIM . "Source Files", 
			-itemtype=>'text',
			-text=>"Source Files",
		);
		$tree_projs->add(
			$proj->name() . DELIM . "Required Files", 
			-itemtype=>'text', 
			-text=>"Required Files",
		);
		$tree_projs->add(
			$proj->name() . DELIM . "Used Modules", 
			-itemtype=>'text', 
			-text=>"Used Modules",
		);
		$tree_projs->add(
			$proj->name() . DELIM . "Support Files", 
			-itemtype=>'text', 
			-text=>"Support Files",
		);


		#Loop over the source files in the project
		foreach my $file ($proj->source_files_values()) {
			$app->TRACE($file->name(), 1);
			my $list_item_path = $tree_projs->add(
				$proj->name() . DELIM . "Source Files" . DELIM . $file->name(),
				-itemtype=>'text',
				-text=>$file->name(),
			);
			#my $list_item = $tree_projs->itemCget($list_item_path);
			#$list_item->bind("<Button-3>" =>
			#	sub {
			#		$clicked = $list_item;
			#		$popup_menu->Popup(
			#			-popover => "cursor",
			#			-popanchor => 'nw',
			#		);
			#	}
			#);
		}

		#Loop over the required files in the project
		foreach my $file ($proj->required_files_keys()) {
			$tree_projs->add(
				$proj->name() . DELIM . "Required Files" . DELIM . $file,
				-itemtype=>'text',
				-text=>$file
			);
		}

		#Loop over the used modules in the project
		foreach my $file ($proj->used_modules_keys()) {
                        #$file =~ s/::/-/g;
			$tree_projs->add(
				$proj->name() . DELIM . "Used Modules" . DELIM . $file,
				-itemtype=>'text',
				-text=>$file,
			);
		}

		#Loop over the support modules in the project
		foreach my $file ($proj->support_files_keys()) {
                        #$file =~ s/::/-/g;
		    $app->TRACE("Adding support file $file", 1);
			$tree_projs->add(
				$proj->name() . DELIM . "Support Files" . DELIM . $file,
				-itemtype=>'text',
				-text=>$file,
			);
		}


	$default_project = $proj;
	}

	$tree_projs->autosetmode();
	#$tree_projs->setmode($proj->name(), "close");
}


sub _enable_project_menus {
	#Enable file related menus
	$app->TRACE("Enabling project related menus",1);
	$menu->entryconfigure('New Project',   -state=>'normal');
	$menu->entryconfigure('Add Existing',           -state=>'normal');
	$menu->entryconfigure('New',           -state=>'normal');
	$menu->entryconfigure('Save Project',  -state=>'normal');
	$menu->entryconfigure('Run Project', -state=>'normal');
	$menu->entryconfigure('Debug Project', -state=>'normal');
	$menu->entryconfigure('Collate Project', -state=>'normal');
	$menu->entryconfigure('Close Project', -state=>'normal');
}

sub _disable_project_menus {
	#Enable file related menus
	$app->TRACE("Disabling project related menus",1);
	$menu->entryconfigure('Add Existing',    -state=>'disabled');
	$menu->entryconfigure('New',             -state=>'disabled');
	$menu->entryconfigure('Save Project',    -state=>'disabled');
	$menu->entryconfigure('Run Project',     -state=>'disabled');
	$menu->entryconfigure('Debug Project',   -state=>'disabled');
	$menu->entryconfigure('Collate Project', -state=>'disabled');	
	$menu->entryconfigure('Close Project',   -state=>'disabled');
}

sub _path2object {
        my $delim = DELIM;
	my($project, $file_type, $file) = split(/$delim/, $_[0]);
	$app->TRACE("Clicked item is $project:$file_type:$file", 2);
	
	#Sometimes, a higher level path may be passed in
	#return undef if !$file;
	
	if(!$file) {
		if (!$file_type) {
			#They've clicked a project
			my $project_object = $app->projects($project);
			return $project_object;
		}
		else {
			#They've clicked a file type
		}
	}
	else {
		#They've clicked a file
		my $file_group = $file_type;
		$file_group =~ s/ /_/g;
		$file_group = lc($file_group);
		my $file_object = $app->projects($project)->$file_group($file);
		return $file_object;
	}
}

################
#Event handlers
################

sub _e_popup_menu {
	my($tree, $x, $y) = @_;
        my $delim = DELIM;
	my $path = $tree->nearest($y);
	$app->TRACE("Path to clicked item is " . $path, 1);
	if ($path =~ /{$delim}Source Files$/) {
		$source_file_popup->Popup(
			-popover => "cursor",
			-popanchor=> 'nw',
		);
		return 1;
	}
	if ($path =~ /${delim}Required Files$/) {
		$required_file_popup->Popup(
			-popover => "cursor",
			-popanchor=> 'nw',
		);
		return 1;
	}
	if ($path =~ /${delim}Used Modules$/) {
		$used_module_popup->Popup(
			-popover => "cursor",
			-popanchor=> 'nw',
		);
		return 1;
	}
	if ($path =~ /${delim}Support Files$/) {
		$support_file_popup->Popup(
			-popover => "cursor",
			-popanchor=> 'nw',
		);
		return 1;
	}

	my $object = _path2object($path) or return;

	#$app->TRACE("Source File name is " . $file_object->name, 1);

	$clicked = $object;

	if($object->can('menu') and my $menu_struct = $object->menu) {
		$app->TRACE('Using class builtin menu',1);
		my $temp_popup_menu = $app->{mw}->Menu(
			-menuitems => $menu_struct,
			-tearoff => 0
		);
		$temp_popup_menu->Popup(			
			-popover => "cursor",
			-popanchor => 'nw',
		);

	}
}

sub _e_file_new {
	my($type) = @_;
	return undef if !$type;

	my $name_dialog = $app->{mw}->DialogBox(
		-title=>"Enter name for file (no extension)",
		-buttons=>['Ok', 'Cancel'],
	);

	my $name;
	$name_dialog->add('Entry', -textvariable=>\$name)->pack();
	my $response = $name_dialog->Show();
	
	return if $response eq 'Cancel';
	
	#Strip extension if they added one
	$name =~ s/\..+//;

	my $new_file = new Guido::SourceFile(
			app => $app,
			project_name => $default_project->name,
			name => $name,
			file_path => undef,
			working_dir=> $default_project->working_dir,
			type => $type,
	);
	
	$default_project->source_files($name, $new_file);
	$app->refresh();
	return 1;
}

sub _e_file_add {
	my($type) = @_;
	return undef if !$type;

	my $file_path = $app->{mw}->getOpenFile(
		-initialdir=>$default_project->working_dir,
		-title=>"Choose file to add",
	);
	my($working_dir);
	
	return if !$file_path;
	
	#Split out the path and the file name
	($file_path, $working_dir) = fileparse($file_path);
	my $name = $file_path;
	$name =~ s/\..+//;

	$working_dir ||= $default_project->working_dir;

	my $new_file = load Guido::SourceFile(
			app => $app,
			name => $file_path,
			project_name => $default_project->name,
			file_path => $file_path,
			working_dir=> $working_dir,
			type => $type,
	);
	
	$default_project->source_files($new_file->name, $new_file);
	$app->refresh();
	return 1;
}


sub _e_req_file_add {

	my $file_path = $app->{mw}->getOpenFile(
		-initialdir=>$default_project->working_dir,
		-title=>"Choose required file to add",
	);
	my($working_dir);
	
	return if !$file_path;
	
	#Split out the path and the file name
	($file_path, $working_dir) = fileparse($file_path);
	my $name = $file_path;
	$name =~ s/\..+//;

	$working_dir ||= $default_project->working_dir;

	my $new_file = load Guido::RequiredFile(
			app => $app,
			name => $file_path,
			project_name => $default_project->name,
			file_path => $file_path,
			working_dir=> $working_dir,
	);
	
	$default_project->required_files($new_file->name, $new_file);
	$app->refresh();
	return 1;
}

sub _e_sup_file_add {

    $app->TRACE("Displaying getOpenFile at " . $default_project->working_dir, 1);

	my $file_path = $app->{mw}->getOpenFile(
		-initialdir=>$default_project->working_dir(),
		-filetypes => [['All Files', '*']],
		-title=>"Choose support file to add",
	);
	my($working_dir);
	
	return if !$file_path;
	
	#Split out the path and the file name
	($file_path, $working_dir) = fileparse($file_path);
	my $name = $file_path;
	$name =~ s/\..+//;

	$working_dir ||= $default_project->working_dir;

	my $new_file = load Guido::SupportFile(
			app => $app,
			name => $file_path,
			project_name => $default_project->name,
			file_path => $file_path,
			working_dir=> $working_dir,
	);
	
	$default_project->support_files($new_file->name, $new_file);
	$app->refresh();
	return 1;
}


##
#Toolbox user options dialog
##

sub _e_used_mod_add {
	Tk::Menu::Unpost();
# MODINFO dependency module File::Find
	use File::Find;
	my %selected_modules = ();
	my $previous_modules = {};
	@modules = ();
	my $dialog = $app->{mw}->DialogBox(
		-title => "Available Modules",
		-buttons => ["OK", "Cancel"],
	);

	my $text = $dialog->add(
			'Scrolled',
			'Text',
			-wrap=>'none',
			-scrollbars=>'osoe',
			-width=>25,
			-height=>20,
	);
	$text->pack(
		expand=>1,
		fill=>'x',
	);

	$text->configure(-background => $text->parent->cget(-background));

	my $modules_cache = 'modules_cache.xml';
	if (-e $modules_cache) {
		my $modules = XMLin($modules_cache, searchpath=>['.']);
		@modules = sort @$modules;
	}
	else {
		$app->status("Creating module listing cache...please wait");
		foreach $inc_dir (@INC) {
			$inc_dir =~ s|\\|/|g;
                        #print "Inc dir is $inc_dir\n";
			find(\&_found_mod, $inc_dir);
		}
		#Strip out dupes
		my %seen = ();
		my @unique_modules = grep { ! $seen{$_} ++ } @modules;
                @unique_modules = sort(@unique_modules);
		$app->TRACE(join("|\n|", @unique_modules), 1);

		#Save to xml file
                my $modules_cache_xml = XMLout(\@unique_modules);
                $app->TRACE("Cache xml is\n" . $modules_cache_xml, 1);
		write_file($modules_cache, $modules_cache_xml);
		$app->status();
                $app->TRACE('Finished building modules cache', 1);
                @modules = @unique_modules;
	}


	foreach my $module (@modules) {
		my $checked = 0;
		if ($previous_modules->{$module}) {
			$selected_modules{$module} = 1;
			$checked = 1;
		}
		my $ck_box = $text->Checkbutton(
			-variable => \$checked,
			-command=> sub {
				if (!$selected_modules{$module}) {
					$selected_modules{$module} = 1;
				}
				else {
					#print "Deleting $module!\n";
					delete $selected_modules{$module};
				}
			}
		);
		my $w = $text->Label(-text=>$module);
		$text->windowCreate('end', -window=>$ck_box);
		$text->windowCreate('end', -window=>$w);
		$text->insert('end', "\n");
	}

	$text->configure(-state=>'disabled');

	my $button = $dialog->Show;
	#print Dumper \%selected_modules;
	if ($button eq "OK") {
		foreach my $module (keys %{$previous_modules}) {
			#print "Checking $module\n";
			if(!$selected_modules{$module}) {
				#print "Deleting $module\n";
				delete $previous_modules->{$module};
			}
		}
		foreach my $module (keys %selected_modules) {
			next if $previous_modules->{$module};
			my $new_mod = new Guido::UsedModule(
				name=>$module,
				'package'=>$module,
				imports=>'',
			);
			$default_project->used_modules($module, $new_mod);
		}
	}
	$app->TRACE("Done with module selection",1);
	$app->refresh();
}


sub _found_mod {
	my $mod_dir = $File::Find::dir;

	return if $_ !~ /\.pm$/;
        #print "$mod_dir | $inc_dir\n";
	$mod_dir =~ s|$inc_dir||;
        #print "Mod dir is $mod_dir\n";
	$mod_dir =~ s|^/||;
	if ($mod_dir) {$mod_dir .= '/'}
	my $mod_path = $mod_dir . $_;
	my $full_path = $File::Find::dir . '/' . $_;

	unless (open(MOD,$full_path)) {
		warn "Couldn't open $full_path\n$!\n";
		return 0;
	}
	my $package = $mod_path;

	$package =~ s|/|::|g;
	$package =~ s|\.pm||;
        #print "Package is $package\n";
	while(my $line = <MOD>) {
		if ($line =~ /^[^#]*Construct/ && $line =~ /^[^#]*Tk::Widget/) {
			return;
		}
	}
	push(@modules, $package);
	close(MOD);
}



sub _e_remove_selected {
        my $delim = DELIM;
	my ($project, $file_type, $file) = split(/$delim/, $tree_projs->selectionGet);
	$app->TRACE("Removing $project:$file_type:$file from project", 1);
	
	$app->TRACE("Before: " . Dumper(\{$app->projects($project)->source_files}), 1);
	my $file_group = $file_type;
	$file_group =~ s/ /_/g;
	$file_group = lc($file_group);
	$app->TRACE("File group: $file_group", 1);
	delete $app->projects($project)->$file_group()->{$file};
	$app->TRACE("After: " . Dumper(\{$app->projects($project)->source_files}), 1);
	$app->refresh();
}

sub _e_edit_selected {
	#print $tree_projs->selectionGet->cget(-path) . "\n";
	$app->TRACE("Edit selected file",1);
	_e_file_click($tree_projs->selectionGet);
}

sub _e_save_selected {
        my $delim = DELIM;
	my($project, $file_type, $file) = split(/$delim/, $tree_projs->selectionGet);
	my $file_group = $file_type;
	$file_group =~ s/ /_/g;
	$file_group = lc($file_group);
	$app->TRACE("Saving selected file $file",1);
	my $gui = $app->plugins("FormBuilder")->forms->{form_name};
	$app->TRACE($gui,1);
	return 0;
	$app->projects($project)->$file_group($file)->save(gui=>$gui);
}

sub _e_file_select {
        my $delim = DELIM;
	#Incoming param is the path to the selected item, i.e.: Projects:MyProj:MyFile.pl
	my($project, $file_type, $file) = split(/$delim/, $_[0]);

        #print "$project : $file_type : $file\n";

	#Set focus to the parent project for the clicked file
	$default_project = $app->projects($project);
	$app->TRACE("New default project is " . $default_project->name, 1);

	$app->TRACE("Selected item is $_[0]", 2);
	my $file_group = $file_type;
	$file_group =~ s/ /_/g;
	$file_group = lc($file_group);
	if (!$file_group && $project) {
		if ($default_project->isa("Guido::PropertySource")) {
			if($app->plugins("PropertyManager")) {
				$app->TRACE("Sending PropertyManager the project",1);
				$app->plugins("PropertyManager")->display_properties(property_source=>$default_project);
			}
		}
		return(1);
	}
	
	$app->TRACE("File group: $file_group", 1);
	#if ($file_group =~ /(source_files|required_files|used_modules)/) {
	my $file_object = $app->projects($project)->$file_group($file);

	return if !$file_object;
	$app->TRACE("File object is of type " . ref($file_object), 1);
	if ($file_object->isa("Guido::PropertySource")) {
		$app->TRACE("It's a PropertySource", 1);
		if($app->plugins("PropertyManager")) {
			$app->TRACE("Sending PropertyManager the file",1);
			$app->plugins("PropertyManager")->display_properties(property_source=>$file_object);
		}
	}
        else {
                $app->TRACE("Not a property source",1);
        }


	if($file_object->can("save")) {
		$app->TRACE("Enabling save menu option",1);
		$menu->entryconfigure('Save Selected File', -state=>'normal');
	}
	else {
		$app->TRACE("Disabling save menu option",1);
		$menu->entryconfigure('Save Selected File', -state=>'disabled');
	}
	if ($file) {
		my $file_path = $app->projects($project)->$file_group($file);
		$menu->entryconfigure('Remove Selected File', -state=>'normal');
		$menu->entryconfigure('Edit Selected File',     -state=>'normal');
	}
	else {
		$menu->entryconfigure('Remove Selected File', -state=>'disabled');
		$menu->entryconfigure('Edit Selected File',   -state=>'disabled');
	}
	$app->plugins("ProjectManager")->set_selection($_[0]);
#	my $file_path = File::Spec->canonpath($file_path);
}
 
sub _e_file_click {
        my $delim = DELIM;
	#Incoming param is the path to the clicked item, i.e.: Projects:MyProj:MyFile.pl
	my($project, $file_type, $file) = split(/$delim/, $_[0]);
	return if !$file;
	$app->TRACE("Clicked file is $file", 2);
	my $file_group = $file_type;
	$file_group =~ s/ /_/g;
	$file_group = lc($file_group);
	my $file_object = $app->projects($project)->$file_group($file);
	my $file_path = $file_object->file_path;
	if($file_object->can("edit")) {
		$file_object->edit();
	}
	return 1;
}

#sub show_deps {
#	#Incoming param is the path to the selected item, i.e.: Projects:MyProj:MyFile.pl
#	my($project, $file_type, $file) = split(/:/, $self->{selection}->configure(-id));
#	$app->TRACE("Selected file is $file", 1);
#	my $file_path = $app->projects($project)->source_files($file);
#	my $file_path = File::Spec->canonpath($file_path);
#	$app->TRACE("Trying to get deps for $file_path...", 1);
#	my $exec = $app->plugins("Executor");
#	if ($exec) {
#		my $output = $exec->auto_launch(path=>"perl", file_handle=>1, parameters=>"-c -d:Modlist $file_path");
#		while($line = <$output>) {
#			$app->TRACE("Executor plugin returned: $line",1);
#		}
#	}
#	else {
#		$app->TRACE("Executor plugin not loaded! Failed to run deps on $file",1);
#	}
#}

1;

__END__

=head1 NAME

Guido::ProjectManager - Guido plugin for managing and graphically displaying the components that make up a Guido project

=head1 SYNOPSIS

  use Guido::ProjectManager;


=head1 DESCRIPTION

The ProjectManager plugin is responsible for graphically showing the user which projects are open and allowing operations to be performed on the project components through the IDE.  It uses a familiar "explorer" type interface that is common in most IDEs.

=head1 INTERFACE

=head1 KNOWN ISSUES

None known at this time.

=head1 AUTHOR

jtillman@bigfoot.com

=head1 SEE ALSO

perl(1).
