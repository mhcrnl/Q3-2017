# MODINFO module Guido::Plugin::Toolbox Guido plugin for providing a visual method of choosing new widgets for forms
package Guido::Plugin::Toolbox;

# MODINFO dependency module strict
use strict;
# MODINFO depedency module vars
use vars qw/@ISA $Bin/;
# MODINFO dependency module Guido::Plugin
require Guido::Plugin;
# MODINFO dependency module Tk::Frame
require Tk::Frame;
# MODINFO dependency module Tk::Balloon
use Tk::Balloon;
# MODINFO dependency module Guido::PropertyPageDialog
use Guido::PropertyPageDialog;
# MODINFO dependency module XML::Simple
use XML::Simple;
# MODINFO dependency module File::Slurp
use File::Slurp;
# MODINFO dependency module Data::Dumper
use Data::Dumper;
# MODINFO dependency module Tk::DragDrop
use Tk::DragDrop;
# MODINFO dependency module Tk::DropSite
use Tk::DropSite;
# MODINFO dependency module Guido::SourceFile::TkComposite
#use Guido::SourceFile::TkComposite;
# MODINFO dependency module Guido::SourceFile::TkForm
#use Guido::SourceFile::TkForm;
# MODINFO dependency module FindBin
use FindBin qw/$Bin/;

# MODINFO dependency Guido::SourceFile::TkWidget::Basic
use Guido::SourceFile::TkWidget::Basic;

# MODINFO parent_class Tk::Frame
@ISA = qw(Guido::Plugin Tk::Frame);
my $app;
my $toolbox_frame;
my $tools;
my $menubar;
my $clicked;
my $dragged;
my $inc_dir;
my @tools;
my $tools_cache = 'tools_cache.xml';

Construct Tk::Widget 'Toolbox';

sub current_dnd_token {
    return $dragged;
}

# MODINFO method refresh Refresh the plugin's display
# MODINFO retval
sub refresh {
    my ($self) = @_;
    # Called when application state changes like when someone adds a new file
    #Remove all current buttons
    foreach my $button ($toolbox_frame->children()) {
	$button->destroy;
    }
    $self->init_plugin($app);
}

# MODINFO method Populate Standard Tk intialization method
# MODINFO paramhashref args
# MODINFO retval
sub Populate {
    my ($cw, $args) = @_;
    $cw->SUPER::Populate($args);

    my $own_menuitems = 
      [
	  [Button => "~Choose Tools", -command => \&display_tools],
	  [Button => "~Clear Tools Cache", -command => \&clear_cache],
      ];
	
    my $menuitems = 
      [
	  [Button => "~Defaults", -command => \&defaults],
      ];

    $menubar = $cw->Menu(-menuitems => $menuitems,
			    -tearoff => 0);
    my $own_menubar = $cw->Menu(-menuitems => $own_menuitems,
				-tearoff => 0);
    my $label_frame = $cw->Frame(
	-borderwidth => 3,
	-relief => 'raised',
    )->pack(
	-fill => 'both',
    );
	
    my $header = $label_frame->Label(
	-text => 'Widget Box',
#	-font => '{Arial} 8 {bold}',
#	-background => 'dark blue',
#	-foreground => 'white',
	-borderwidth => 2,
	-relief => 'raised',
    )->pack(
	-side => 'top',
	-fill => 'x',
    );
	
    my $bounding_frame = $cw->Frame(
	-borderwidth => 3,
	-relief => 'ridge',
    )->pack(
	-fill => 'both',
	-expand => 1,
    );

    $toolbox_frame = $bounding_frame->Frame()->pack(
	anchor=>'nw',
    );

    $toolbox_frame->bind("<Button-3>" =>
        sub {
	    $own_menubar->Popup(	-popover => "cursor",
					-popanchor => 'nw') }
    );

    $bounding_frame->bind("<Button-3>" =>
	sub {
	    $own_menubar->Popup(	-popover => "cursor",
					-popanchor => 'nw') }
    );

    $cw->ConfigSpecs(
	-font => [$header, 'font', 'Font', '{Arial} 8 {bold}'],
	-background => [$header, 'background', 'Background', 'dark blue'],
	-foreground => [$header, 'foreground', 'Foreground', 'white'],
    );
}

# MODINFO method init_plugin Initialize the plugin in the Guido IDE
# MODINFO param app_param Guido::Application Ref to the main Guido IDE
# MODINFO retval
sub init_plugin {
    my ($self, $app_param) = @_;

    $app = $app_param;
    $app->TRACE("Plugin initializing",1);
    #create 12 rows, each with two widgets
    my @widgets = (1..20);
    my $row = 0;
    my $col = 0;
    #my $framewidth = $self->width();
    my $framewidth = 2;
    my $buttonwidth = 0;
    $tools = $app->{plugin_data}->{Toolbox}->{tool};	

    my @tools = keys %$tools;

    $app->TRACE(scalar(@tools) . " tools have been registered", 1);
    my $bin = $app->{bin};
    my $search_path = $app->{plugin_data}->{Toolbox}->{icon_search_path};
    eval qq|\$search_path = "$search_path";|;
    $search_path ||= "./bin";
    $app->TRACE("Searching in $search_path for icons", 1);
    for my $tool (@tools) {
	my $short_tool = $tool;
	$short_tool =~ s/^Tk:://;
	my $icon_path;
	my @path = split(/:/, $search_path);
	push(@path, "$Bin/images");
	if ($icon_path = Guido::Application::find_in_path($short_tool . ".jpg", @path)) {
	    $app->TRACE("Found jpeg icon for $short_tool at $icon_path", 1);
	}
	elsif ($icon_path = Guido::Application::find_in_path($short_tool . ".gif", @path)) {
	    $app->TRACE("Found gif icon for $short_tool at $icon_path", 1);
	}
	else {
	    $app->TRACE("Couldn't locate default icon for $short_tool", 1);
	}

#	my $icon_path = $tools->{$tool}->{icon_path};
#	$icon_path =~ s/^\./$bin/e;
	my $btn;
	my $icon;
	if ($icon_path && -e $icon_path) {
	    $icon = $toolbox_frame->Photo(-file=>$icon_path);
	    $btn = $toolbox_frame->Button(
		-command => sub {Create_Widget($tool);},
		-relief => 'flat',
		-image => $icon,
		-text => $tool,
		-padx => 0,
		-pady => 0,
	    )->grid(
		-row => $row,
		-column => $col,
		-sticky => "w",
		-padx => 10,
		-pady => 5,				
	       );
	}
	else {
	    $btn = $toolbox_frame->Button(
		-command => sub {Create_Widget($tool);},
		-relief => 'flat',
		-text => $tool,
		-padx => 0,
		-pady => 0,
	    )->grid(
		-row => $row,
		-column => $col,
		-sticky => "w",
		-padx => 10,
		-pady => 5,
	    );
	}
			
	$btn->bind("<Button-3>" =>
		     sub { $clicked = $btn;
			   $menubar->Popup(	-popover => "cursor",
						-popanchor => 'nw') }
	);

	#Enable drag and drop
#	$btn->bind("<B1-Motion>" =>
#		     sub { print "Clicked!\n"; $clicked = $btn; }
#        );
	#$btn->bind("<ButtonPress-1>", sub {$clicked = $btn});
	my $token;
	$token = $btn->DragDrop(
	    -image => $icon,
	    -text => $tool,
	    -event => '<B1-Motion>',
	    -sitetypes => [qw/Local/],
	    #-startcommand => sub{$dragged = $token},
	);	
	$btn->bind("<ButtonPress-1>" => sub {
		       $clicked = $btn;
		       $dragged = $token;
		       my $f;
		       if ($app->plugins("FormBuilder")->active_form) {
			   $f = $app->plugins("FormBuilder")->active_form->ref;
			   $f->raise();
		       }
		   }
	);
	#Display Tool Tips
	my $balloon = $app->{mw}->Balloon();
	$balloon->attach($btn, -msg=> $tool);
		
	#$buttonwidth = $btn->width();
	my $buttonwidth = 1;
	#$max_cols = int($framewidth / $buttonwidth + .5);
	my $max_cols = 1;
	#		print "$max_cols:$col:$row\n";
	
	if ($col == $max_cols)  {
	    $col = 0;
	    ++$row;
	}	
	else {
	    ++$col;
	}
    }
}

# MODINFO method place_menus Causes the plugin to place its menus (if any) in the Guido IDE
# MODINFO retval
sub place_menus {
	
}

# MODINFO method editor Returns a widget that provides a GUI for editing the plugin's configuration data
# MODINFO param parent_frame Tk::Frame Parent frame of the editor widget (used for creating, not placing)
# MODINFO param config HASHREF Configuration data structure the editor is supposed to modify
# MODINFO retval Guido::Plugin::Toolbox::Editor
sub editor {
    my($self, $parent_frame, $config) = @_;
# MODINFO dependency module Guido::Plugin::Toolbox::Editor
    use Guido::Plugin::Toolbox::Editor;
    my $editor = Guido::Plugin::Toolbox::Editor->new(
	$parent_frame->DelegateFor('Construct'),
	-config => $config,
    );
    return $editor;
}

# MODINFO method defaults Allows editing of the defaults for a particular widget in the toolbox
# MODINFO retval
sub defaults {
    $app->TRACE ("Editing Defaults", 1);
    return if !$clicked;
    my $tool = $clicked->cget(-text);
    $app->TRACE ("Creating a widget of type $tool", 2);

    my $defaults = $tools->{$tool}->{defaults};
    my $name_tpl = $tools->{$tool}->{name_tpl}->{template};
    
    my $temp_widget = new Guido::SourceFile::TkWidget::Basic(
	app => $app,
	name => 'temp_widget',
	parent => $app->{mw},
	type => $tool,
	params => $defaults,
    );
    my $properties = $temp_widget->property_source_properties;
    my @basic_properties = ();
    foreach my $property (@$properties) {
	if ($property->type eq 'basic') {
	    #This disconnects the properties from their TkWidget object
	    # (disables validation, unfortunately, but prevents errors)
	    $property->{listeners} = [];
	    push(@basic_properties, $property);
	}
    }
    my $ppd = $clicked->PropertyPageDialog(
	#-widget=>$temp_widget,
	-widget_name => "Defaults for $tool",
	-append_props => \@basic_properties,
    );
    my $retval = $ppd->Show();
    if (!$retval) {
	$app->TRACE("Default editing cancelled", 2);
	return;
    }
    my $widget_defaults = {};
    foreach my $prop (@$retval) {
	if ($prop->type eq 'basic' && !$prop->using_default) {
	    $widget_defaults->{$prop->name} = $prop->value if defined($prop->value);
	}
    }

    $tools->{$tool}->{defaults} = $widget_defaults;
    $app->TRACE ("Defaults have been edited", 1);
    return;	
}

sub create_active_widget {
    my($self, %params) = @_;
    return if !$clicked;
    my $tool = $clicked->cget(-text);
    Create_Widget($tool, $params{parent}, $params{widget_geo});
}

# MODINFO function Create_Widget Causes a widget to placed in the FormBuilder plugin's currently active form
# MODINFO param tool STRING Name of the widget (tool) to be created
# MODINFO retval
sub Create_Widget {
    my($tool, $parent, $widget_geo) = @_;
    my $defaults = $tools->{$tool}->{defaults};
    my %defaults = ();
    my $widget_name;
    
    my $name_tpl = $tools->{$tool}->{name_tpl}->{template};
    
    #Strip off the package path to get the widget class name
    my $short_tool = $tool;
    $short_tool =~ s/^Tk:://;
    
    foreach my $attrib (keys %$defaults) {
	$defaults{'-' . $attrib} = $defaults->{$attrib};
    }

    $app->TRACE("Toolbox::CreateWidget - Adding $short_tool widget", 1);

    $app->plugins('FormBuilder')->add_widget(
	widget_type => $short_tool,
	widget_params => \%defaults,
	parent => $parent,
	widget_geo => $widget_geo,
    );

    $app->TRACE("Finished with creating widget $tool",1);
}


##
#Toolbox user options dialog
##
# MODINFO function display_tools Display the dialog that allows the user to pick which tools are shown in the toolbox
# MODINFO retval
sub display_tools {
    Tk::Menu::Unpost();
# MODINFO dependency module File::Find
    use File::Find;
    my %selected_tools = ();
    my $previous_tools = $app->{plugin_data}->{Toolbox}->{tool};	
    @tools = ();
    my $dialog = $app->{mw}->DialogBox(
	-title => "Available Widgets", 
	-buttons => ["OK", "Cancel"]
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

    if (-e $tools_cache) {
	my $tools = XMLin($tools_cache, searchpath=>['.']); 
	@tools = sort @$tools;
    }
    else {
	$app->status("Creating widget listing cache...please wait");
	foreach my $tmp_dir (@INC) {
	    $inc_dir = $tmp_dir;
	    $app->TRACE("Searching $inc_dir for tools...", 1);
	    $inc_dir =~ s|\\|/|g;
	    #@tools = ();
	    find(\&found, $inc_dir);
	}
	#Strip out dupes
	my %seen = ();
	my @unique_tools = sort grep { ! $seen{$_} ++ } @tools;
	
	$app->TRACE(join("|\n|", @unique_tools), 1);

	#Save to xml file
	write_file($tools_cache, XMLout(\@unique_tools));
	
	$app->status();
    }

    foreach my $tool (@tools) {
	my $tk_tool = $tool;
	$tk_tool =~ s/^Tk:://;
	my $checked = 0;
	if ($previous_tools->{$tool} or $previous_tools->{$tk_tool}) {
	    $selected_tools{$tool} = 1;
	    $checked = 1;
	}
	my $ck_box = $text->Checkbutton(
	    -variable => \$checked,
	    -command=> sub {
		if (!$selected_tools{$tool}) {$selected_tools{$tool} = 1;}
		else {delete $selected_tools{$tool};}
	    }
	);
	my $w = $text->Label(-text=>$tool);
	$text->windowCreate('end', -window=>$ck_box);	
	$text->windowCreate('end', -window=>$w);
	$text->insert('end', "\n");
    }

    $text->configure(-state=>'disabled');

    my $button = $dialog->Show;
    if ($button eq "OK") {
	foreach my $tool (keys %{$previous_tools}) {
	    if(!$selected_tools{$tool}) {
		delete $previous_tools->{$tool};
	    }
	}
	foreach my $tool (keys %selected_tools) {
	    my $short_tool = $tool;
	    $short_tool =~ s/^Tk:://;

	    next if $previous_tools->{$tool};
#	    my $search_path = $app->{plugin_data}->{Toolbox}->{icon_search_path};
#	    my $icon_path;
#	    $app->TRACE("Searching in $search_path for default icons", 1);
#	    $app->TRACE("Looking for $search_path/${short_tool}.gif",1);
#	    if (-e "$search_path/${short_tool}.jpg") {
#		$icon_path = "$search_path/${short_tool}.jpg";
#	    }
#	    elsif (-e "$search_path/${short_tool}.gif") {
#		$icon_path = "$search_path/${short_tool}.gif";
#	    }
#	    else {
#		$app->TRACE("Couldn't locate default icon for $tool", 1);
#	    }
	    $previous_tools->{$tool}->{defaults} = {};
#	    $previous_tools->{$tool}->{icon_path} = $icon_path;
	}
    }
    $app->TRACE("Done with tool selection",1);
    $app->refresh();
}

sub found {
    my $mod_dir = $File::Find::dir;

    $app->TRACE("Mod dir: $mod_dir", 1);
    $app->TRACE("Inc dir: $inc_dir", 1);
    $app->TRACE("File is $_", 1);
    return if $_ !~ /\.pm$/;
    
    $mod_dir =~ s|$inc_dir||;
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
    while(my $line = <MOD>) {
	if ($line =~ /^[^#]*Construct/ && $line =~ /^[^#]*Tk::Widget/) {
	    push(@tools, $package);
	}
    }
    close(MOD);
}

sub clear_cache {
    my ($self) = @_;
    unlink($tools_cache) || $app->ERROR(-text=>"Couldn't clear tools cache ($tools_cache): $!");
}

1;

__END__

=head1 NAME

Guido::Toolbox - Guido plugin that allows the user to pick which widgets to place on the active FormBuilder form

=head1 SYNOPSIS

  use Guido::Toolbox;


=head1 DESCRIPTION

The Toolbox plugin allows the user to define a set of widgets to display as clickable buttons.  When a button for a particular widget is clicked, a widget of that type is placed in the currently active form of the FormBuilder plugin.

=head1 INTERFACE

=head1 KNOWN ISSUES

None known at this time.

=head1 AUTHOR

jtillman@bigfoot.com

=head1 SEE ALSO

perl(1).
