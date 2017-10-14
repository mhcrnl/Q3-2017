# MODINFO module Guido::SourceFile::TkComposite Class for managing data related to a Tk "composite", a.k.a. a Tk::Widget
package Guido::SourceFile::TkComposite;

# MODINFO dependency module strict
use strict;

# MODINFO dependency module vars
use vars qw( $VERSION @ISA @EXPORT @EXPORT_OK );
# MODINFO dependency module Guido::SourceFile
use Guido::SourceFile;
# MODINFO dependency module Guido::PropertySource
use Guido::PropertySource;
# MODINFO dependency module Guido::SourceFile::TkComposite::Mapper
use Guido::SourceFile::TkComposite::Mapper;
# MODINFO parent_class Guido::PropertySource
@ISA = qw( Guido::SourceFile Guido::PropertySource );

#use base qw/Guido::SourceFile Guido::PropertySource/;


use Class::MethodMaker get_set => [ qw /
	name 
	ref 
	geometry 
	children 
	project_name 
	working_dir 
	type 
	file_path 
	events_file_path
	geo_mgr_type
	delegate_properties
        delegate_methods
	super_class
/];

#This will not be needed after conversion of children property to array from hash
# MODINFO dependency module Tie::IxHash
use Tie::IxHash;

# MODINFO dependency module Data::Dumper
use Data::Dumper;
# MODINFO dependency module File::Spec::Functions
use File::Spec::Functions;
# MODINFO dependency module File::Slurp
use File::Slurp;
# MODINFO dependency module Cwd
use Cwd;
# MODINFO dependency module XML::DOM
use XML::DOM;
#use Text::Template;
# MODINFO dependency module Guido::SourceFile::TkWidget::Basic
use Guido::SourceFile::TkWidget::Basic;
# MODINFO dependency module Tk::Text
use Tk::Text;
# MODINFO dependency module Tk::DialogBox
use Tk::DialogBox;
# MODINFO dependency module Template
use Template;

# MODINFO dependency module constant
use constant DEFAULT_TEMPLATE_DIR => 'Guido/SourceFile/TkComposite/templates';

# MODINFO dependency module Exporter
require Exporter;
# MODINFO dependency module AutoLoader
require AutoLoader;

#@ISA = qw(Exporter AutoLoader);
# Items to export into callers namespace by default. Note: do not export
# names by default without a very good reason. Use EXPORT_OK instead.
# Do not simply export all your public functions/methods/constants.
@EXPORT = qw();

# MODINFO version 0.01
$VERSION = '0.01';
my $app;

# Preloaded methods go here.

##
#Independent debug/error code
##
my $DEBUG;

sub TRACE {
	if($app) {
		$app->TRACE(@_);
	}
	else {
		print $_[0] . "\n" if $DEBUG;
	}
}

sub ERROR {
	if($app) {
		#print "Sending error to app: $_[0]\n";
		$app->ERROR(@_);
	}
	else {
		my %attribs = @_;
		print "Error: " . $attribs{text} . "\n";
	}
}


# MODINFO constructor new
# MODINFO paramhash attribs
# MODINFO key geometry         STRING Size and position (in standard Tk geometry format) of the widget
# MODINFO key project_name     STRING Name of the project with which the widget is associated
# MODINFO key name             STRING Name of the widget
# MODINFO key working_dir      STRING Working directory that should be used for this widget
# MODINFO key file_path        STRING Path to the Guido .gui file that should be created
# MODINFO key events_file_path STRING Path to the perl script that contains the event handlers for this widget
# MODINFO key geo_mgr_type     STRING Type of geometry manager that will be managing this widget's subwidgets
# MODINFO key app Guido::Application Ref to the main Guido IDE
sub new {
	my($class, %attribs) = @_;
	my $self = {
		geometry => $attribs{geometry},
		project_name => $attribs{project_name},
		name => $attribs{name},
		working_dir=> $attribs{working_dir},
		file_path => $attribs{file_path},
		events_file_path => $attribs{events_file_path},
		geo_mgr_type => $attribs{geo_mgr_type},
		type => 'TkComposite',
		children => [],
		delegate_properties => [],
		delegate_methods => [],
		super_class => $attribs{super_class}
	};

	$app = $attribs{app} if $attribs{app};
	$self->{super_class} ||= 'Tk::Frame';
	$self->{file_path} ||= $self->{name} . ".gui";	
	$self->{geo_mgr_type} ||= 'place';
	$self->{dirty} = 1;
		
	#Start of new TkForm creation from template
	TRACE("Source file type is " . $self->{type} . "\n",1);
	TRACE("File path is " . $self->{file_path} . "\n",1);

	#Bless early for access to methods
	bless $self => $class;

	return $self;
}

# MODINFO method load An alternate constructor for loading pre-existing widgets
# MODINFO paramhash attribs
# MODINFO key geometry         STRING Size and position (in standard Tk geometry format) of the widget
# MODINFO key project_name     STRING Name of the project with which the widget is associated
# MODINFO key name             STRING Name of the widget
# MODINFO key working_dir      STRING Working directory that should be used for this widget
# MODINFO key file_path        STRING Path to the Guido .gui file that should be created
# MODINFO key events_file_path STRING Path to the perl script that contains the event handlers for this widget
# MODINFO key geo_mgr_type     STRING Type of geometry manager that will be managing this widget's subwidgets
# MODINFO key app Guido::Application Ref to the main Guido IDE
sub load {
	#This constructor is for pre-existing files
	# It doesn't really load anything, but
	# follows the general naming convention used
	# elsewhere, such as the Project class...
	my($class, %attribs) = @_;
	my $self = {
		project_name => $attribs{project_name},
		name => $attribs{name},
		working_dir=> $attribs{working_dir},
		file_path => $attribs{file_path},
		events_file_path => $attribs{events_file_path},
		type => 'TkComposite',
		geo_mgr_type => $attribs{geo_mgr_type},
		children => [],
		delegate_properties => [],
                delegate_methods => [],
	};
	
	$app = $attribs{app} if $attribs{app};
	bless $self => $class;
	
	#Get form data
	my $gui = $self->_xml_to_gui();

	#Extract info from data structure
	$self->geometry(delete $gui->{geometry});
	$self->super_class(delete $gui->{super_class});
	#Delegates are determined and configured in the
	# xml_to_gui phase
	

	#$self->title(delete $gui->{title});
	$self->geo_mgr_type(delete $gui->{geo_mgr_type});
	$self->{geo_mgr_type} ||= 'place';
	$self->children($gui->{children});

	return $self;
}


###########
#Accessors
###########

# MODINFO property dirty BOOLEAN Whether the form has been modified since it was loaded
sub dirty {
	my ($self, $new) = @_;
	if(defined $new) {
		$self->{dirty} = $new;
		$app->TRACE("Setting dirty flag to value: $new",1);
	}
	$self->{dirty};
}

# MODINFO method clear_dirty Clears the dirty flag
# MODINFO retval
sub clear_dirty {
	my ($self) = @_;
	$self->{dirty} = undef;
}

#########
#Methods
#########
# MODINFO method close_form Closes the widget by destroying the Widget being displayed (1=success/0=failure)
# MODINFO paramhash params
# MODINFO retval BOOLEAN
sub close_form {
	my($self, %params) = @_;
	$self->ref->destroy();
	delete $self->{'ref'};
	return 1;
}


# MODINFO method add_widget Adds a widget to the widget data and the Widget currently being displayed (if any) (1=success/0=failure)
# MODINFO paramhash params
# MODINFO key widget Guido::SourceFile::Widget Widget to be added
# MODINFO retval BOOLEAN
sub add_widget {
	my($self, %params) = @_;
	my $new_widget = $params{widget};
	if(!$new_widget) {
		TRACE("No widget parameter value provided",1);
		return 1;
	}
	if (!$self->is_valid_name(widget_name=>$new_widget->name)) {
		TRACE("Invalid name " . $new_widget->name, 1);
		return 0;
	}
	#Add it to our children list
	push(@{$self->children}, $new_widget);
	
	#If we have a ref, add it to the form using the provided parameters
	# (or the default)
	if($self->ref) {
		$new_widget->to_widget(parent=>$self->ref);
	}
	
	TRACE("Widget $new_widget added to children list",1);
	$self->dirty(1);
	return 1;
}

# MODINFO method remove_widget Remove named widget from the widget data and from the display Widget (if any) (1=success/0=failure)
# MODINFO paramash params
# MODINFO key widget_name STRING Name of the widget to remove
# MODINFO retval BOOLEAN
sub remove_widget {
	my($self, %params) = @_;
	my @kept_widgets;
	my $deleted_widget;
	foreach my $widget (@{$self->children}) {
		if($widget eq $params{widget}) {
			$deleted_widget = $widget;
		}
		else {
			push(@kept_widgets, $widget);
		}
	}
	$self->children(\@kept_widgets);
	$deleted_widget->ref->destroy() if $deleted_widget;
	$self->dirty(1);
	return 1;
}

# MODINFO method to_widget Use the object's current data to create a widget of the appropriate type (usually a Tk::Frame)
# MODINFO paramhash params
# MODINFO key parent Parent widget (should be a MainWindow) to use when creating the widget
# MODINFO retval Tk::Widget
sub to_widget{
	my($self, %params) = @_;
	my $parent_widget = $params{parent};
	
	my $form_widget = $parent_widget->Toplevel(-title=>'Composite Widget: ' . $self->name);
	$form_widget->geometry($self->geometry);
	
	foreach my $widget (@{$self->children}) {
		$widget->to_widget(parent=>$form_widget);
	}
	
	$self->ref($form_widget);
	
	return $form_widget;
}

# MODINFO method widget_names Returns an array of names of the widgets managed by the object
# MODINFO retval ARRAY
sub widget_names {
	my($self, %params) = @_;
	return map {$_->name} @{$self->children};
}

# MODINFO method is_valid_name Returns 1 if the name is an acceptable widget name, 0 if not (useful when creating a widget to be placed in the widget)
# MODINFO paramhash params
# MODINFO key widget_name STRING Name to check for acceptability
# MODINFO retval BOOLEAN
sub is_valid_name {
	my($self, %params) = @_;
	TRACE("Checking name " . $params{widget_name} . " for validity", 1);
	return 0 if $params{widget_name} eq '';
	foreach my $widget_name ($self->widget_names()) {
		return 0 if $widget_name eq $params{widget_name};
	}
	return 1;
}

# MODINFO function revert
# MODINFO method revert Undo all changes since the last save (really just reloads the object from file) Returns ref to itself
# MODINFO retval Guido::SourceFile::TkComposite
sub revert {
	#This pseudo-constructor is for returning the file object
	# to it's persisted state without having to send
	# in the initializing data
	# It doesn't really load anything, but
	# follows the general naming convention used
	# elsewhere, such as the Project class...
			
	my($self, %params) = @_;

	if(!-e $self->working_dir . "/" . $self->file_path) {
		$self->children([]);
	}
	else {
		$app->TRACE("Reverting to saved version", 1);		
		my $gui = $self->_xml_to_gui();
		$self->geometry(delete $gui->{geometry});
		#$self->title(delete $gui->{title});
		#$self->title('Composite Widget: ' . $self->name);
		$self->children($gui->{children});
	}

	$self->dirty(0);
	return $self;
}


sub event_handlers {
    my($self) = @_;
    my $orig_dir = cwd;
    unless(chdir($self->working_dir)) {
	ERROR(text=>"Couldn't chdir to $self->working_dir: $!");
	return ();
    }
    my $event_file = $self->events_file_path;
    unless(open(EV, $self->events_file_path)) {
	ERROR(text=>"Couldn't open events file at " . 
		$self->events_file_path . ": $!");
	return ();
    }
    my @lines = <EV>;
    close(EV);
    chdir($orig_dir);
    my @handlers;
    foreach my $line (@lines) {
	next unless $line =~ /^\s*sub\s+([a-zA-Z0-9_]+)/;
	push(@handlers, "\\&$1");
    }
    return @handlers;
}

sub get_sub_line {
	#Figure out the line # of a subroutine in the event file
	
}


sub menu {
	my($self) = @_;
	return [
		[Button => "Properties", -command => [\&_e_properties, $self]],
		[Button => "Edit widget", -command => [\&_e_design_form, $self]],
		[Button => "Save widget", -command => [\&_e_save_form, $self]],
		[Button => "Close Form", -command => [\&_e_close_form, $self]],
		[Button => "View final code", -command => [\&_e_view_code, $self]],
		[Button => "Edit event file", -command => [\&_e_edit_events, $self]],
		[Button => "Set as primary", -command => [\&_e_set_primary, $self]],
		[Button => "Remove from project", -command => [\&_e_remove_from_project, $self]],
		[Button => "Debug dump", -command => [\&_e_debug_dump, $self]],
	];
}

#A debugging routine
# MODINFO method to_string Convert the object to a string representation using Data::Dumper
# MODINFO retval STRING
sub to_string {
	my($self) = @_;
	return Dumper($self);
}

#Convert our private data to an XML node for saving to a project file
#Convert our private data to an XML node for saving to a project file
# MODINFO method to_node Convert the object's data to an XML::DOM::Node
# MODINFO paramhash params
# MODINFO key xml_doc XML::DOM::Document XML document to use when creating the node
# MODINFO key is_primary BOOLEAN When true, this object should consider itself the primary file of its parent project
# MODINFO retval XML::DOM::Node
sub to_node {
	my($self, %params) = @_;

	#xml_doc contains ref to the parent XML::DOM document
	my $xml_doc = $params{xml_doc};
	my $node = $xml_doc->createElement("SourceFile");
	$node->setAttribute("name", $self->name);
	$node->setAttribute("file_path", $self->file_path);
	$node->setAttribute("events_file_path", $self->events_file_path);
	$node->setAttribute("type", $self->type);
	return $node;
}

# MODINFO method to_code Convert the object's data into runnable Perl code intended to be merged into the project's main code
# MODINFO paramhash params
# MODINFO key is_primary BOOLEAN When true, the object should consider itself the primary file of its parent project
# MODINFO retval STRING
sub to_code {
	my($self) = @_;
	my $code;
	my $tt = Template->new({
		PRE_CHOMP=>1,
		INCLUDE_PATH=>[Tk::findINC(DEFAULT_TEMPLATE_DIR)],
	});
	my $tpl_file = 'to_code.tt';
	$tt->process($tpl_file, {app=>$app, form=>$self}, \$code) or die $tt->error();
	return $code;
}

# MODINFO method save Persist the object's data to a .gui file (1=success/0=failure)
# MODINFO paramhash params
# MODINFO key save_as Path to the save the file to (if not provided, then the currently value of file_path property is used)
# MODINFO retval BOOLEAN
sub save {
	my($self, %params) = @_;

	#Bail if we haven't been opened in FormBuilder
	# This may create problems with the form name and title
	# being modified without opening it up in FormBuilder
	if (!$self->{ref}) {
		#We need to get a ref to ourselves here, don't we??
	}

	#save_as allows us to save to a different path
	my $file_path = $self->{file_path};
	$file_path = $params{save_as} if $params{save_as};
	my $prev_working_dir = cwd;
	chdir($self->{working_dir});
	

	#Generate an XML document based on the sourcefile object's
	# contents
	$app->TRACE("Self is $self",1);
	
	#Create Base XML document
	$app->TRACE("Creating root document node",1);
	my $doc = XML::DOM::Document->new();
	#Create the base object structure
	my $decl = $doc->createXMLDecl("1.0");
	$doc->setXMLDecl($decl);
	#my $doctype = $doc->createDocumentType("guidoProject");
	#$doctype->setSysId("guidoProject.dtd");
	#$doc->setDoctype($doctype);

	#Create the starting container nodes
	my $main_node = $doc->createElement($self->{type});		
	$doc->appendChild($main_node);

	#Set geometry attribute
	if ($self->{ref}) {
		$app->TRACE("Setting geometry for form:" . $self->{ref}->geometry,1);
		$main_node->setAttribute('geometry', $self->{ref}->geometry);
		$self->geometry($self->{ref}->geometry);
	}
	else {
		$app->TRACE("No ref available to retrieve geometry",1);
		$main_node->setAttribute('geometry', $self->geometry);
	}

	#Set title&name attributes
	#$main_node->setAttribute('title', $self->title);
	$main_node->setAttribute('name', $self->name);
	$main_node->setAttribute('geo_mgr_type', $self->geo_mgr_type);
	$main_node->setAttribute('super_class', $self->super_class);

	my $widgets_node = $doc->createElement("TkWidgets");
	my $delegates_node = $doc->createElement("Delegates");
	$main_node->appendChild($widgets_node);
	$main_node->appendChild($delegates_node);
	
	$app->TRACE("Creating widget nodes",1);		

	#Loop over each widget in the collection
	#foreach my $widget (map {$_->{_guido_name}} $self->{ref}->children) {
	foreach my $widget (@{$self->children}) {
		$widgets_node->appendChild($widget->to_node(xml_doc=>$doc));
	}

	foreach my $del (@{$self->delegate_properties}) {
	  $delegates_node->appendChild($del->to_node(xml_doc=>$doc));
	}

	foreach my $del (@{$self->delegate_methods}) {
	  $delegates_node->appendChild($del->to_node(xml_doc=>$doc));
	}

	$app->TRACE("Finished creating document",1);
	my $xml = $doc->toString();
	$doc->dispose();
	$xml =~ s/(\>)/$1\n/g;
	$app->TRACE("Gui file contains:\n$xml", 1);

	if(!$xml) {
		$app->ERROR(text=>"No form content to save");
		chdir($prev_working_dir);
		return 0;
	}
	$app->TRACE("File path is " . $self->{file_path} . "\n");
	$app->TRACE($xml,1);
	
	#Persist the XML stream to the save_as or file_path
	$! = undef;
	open (OUT, ">" . $self->{file_path});
	chdir($prev_working_dir);

	if ($!) {
		$app->ERROR(text=>"Couldn't open " . $self->{file_path} . " for saving: $!");
		return 0;
	}
	print OUT $xml;
	close(OUT);	
	$self->dirty(0);
	return 1; 
}

# MODINFO method design Converts the object's data into a hashref that can be used to create a Toplevel widget that realizes the stored data
# MODINFO retval HASHREF
sub design {
	my($self, %params) = @_;
	return $self->_xml_to_gui(%params);
}

# MODINFO function edit Causes the object to create and display a Tk::Toplevel that realizes the stored data
# MODINFO retval
sub edit {
	my($self, %params) = @_;
	$self->_e_design_form();
}

##
#Overloads Guido::PropertySource
##

# MODINFO method property_source_name
sub property_source_name {
	my($self) = @_;
	return $self->name;
}

# MODINFO method property_source_properties
sub property_source_properties {
	my($self) = @_;
        return [
          $self->_get_prop('name', 'Name', $self->name),
          $self->_get_prop('events_file', 'Events File', $self->events_file_path),
          $self->_get_prop('geo_mgr', 'Geo Mgr', $self->geo_mgr_type),
	  $self->_get_prop('super_class', 'Super Class', $self->super_class),
        ];
}

# MODINFO method property_change
sub property_change {
	my ($self, $item, $old_value) = @_;
	TRACE($item->name . " is being set to " . $item->value . "\n", 1);
	if($item->name eq 'geo_mgr') {
	        $app->TRACE("Setting geo_mgr_type", 1);
		$self->geo_mgr_type($item->value);
	}
	elsif ($item->name eq 'events_file') {
	        $app->TRACE("Setting events_file_path", 1);
		$self->events_file_path($item->value);
	}
	elsif ($item->name eq 'Name') {
	  $self->name($item->value);
	}
	else {
	        my $method = lc($item->name);
		$self->$method($item->value);
	}
	return 1;
}

# MODINFO method property_source_parent
sub property_source_parent {
	my($self) = @_;
	return $app->projects($self->project_name);
}

# MODINFO method property_source_children
sub property_source_children {
	my($self) = @_;
	return @{$self->children()};
}


# MODINFO method property_source_siblings
sub property_source_siblings {
	my($self) = @_;
	my @forms = $app->projects($self->project_name)->source_files_values;
	my @siblings;
	foreach my $form (@forms) {
		push(@siblings, $form) unless $form == $self;
	}
	return @siblings;
}

#sub property_source_categories {
#	my($self) = @_;
#	return {
#		Misc => [qw/Name Title/],
#		'Geo Mgmt' => [qw/Geo Mgr/],
#	};
#}

# MODINFO method property_source_options
sub property_source_options {
	my($self) = @_;
	#print "Returning options\n";
	return {
		'Geo Mgr' => [qw/pack place/],
	};
}

#################
#Private methods
#################

sub _get_prop {
  my($self, $name, $display_name, $value) = @_;
  return new Guido::Property(
    name => $name,
    value => $value,
    type => 'custom',
    display_type => _get_display_name($name),
    listeners => [$self],
  );
}

sub _get_display_name {
  my($name) = @_;
  $name = lc($name);
  $name =~ s/(\w+)/\u\L$1/g;
  return $name;
}

#findINC stolen shamelessly from Tk.pm for independence
sub _findINC {
	my $file = join('/',@_);
	my $dir;
	$file  =~ s,::,/,g;
	foreach $dir (@INC) {
		my $path;
		return $path if (-e ($path = "$dir/$file"));
	}
	return undef;
}


sub _xml_to_gui {
	my($self, %params) = @_;
	my $parser = new XML::DOM::Parser;
	$app->TRACE("Loading file " . $self->{working_dir} . "/" . $self->{file_path}, 1);
	my $doc = $parser->parsefile($self->{working_dir} . "/" . $self->{file_path});
	if (!$doc) {
		$app->ERROR(
			text=>"Couldn't parse file " . $self->{working_dir} . "/" . $self->{file_path},
		);
		return undef;
	}

	TRACE("Parsed file " . $self->{working_dir} . "/" . $self->{file_path}, 1);

	my ($app_node) = $doc->getElementsByTagName($self->type);
	if (!$app_node) {
		$app->ERROR(
			text=>"File at " . $self->{working_dir} . "/" . $self->{file_path} . " is not a " . $self->type . " definition file",
		);
		return undef;
	}

	#Parse delegates, if any
	foreach my $delegate ($app_node->getElementsByTagName('DelegateProperty')){
	  my $del_obj = new Guido::SourceFile::TkComposite::DelegateProperty(
	      name=>$delegate->getAttribute('name'),
              target=>$delegate->getAttribute('target'),
              dbname=>$delegate->getAttribute('dbname'),
              dbclass=>$delegate->getAttribute('dbclass'),
              default=>$delegate->getAttribute('default'),
	  );
          push(@{$self->delegate_properties}, $del_obj);
        }
	foreach my $delegate ($app_node->getElementsByTagName('DelegateMethod')){
	  my $del_obj = new Guido::SourceFile::TkComposite::DelegateMethod(
            name=>$delegate->getAttribute('name'),
            target=>$delegate->getAttribute('target'),
          );
          push(@{$self->delegate_methods}, $del_obj);
	
	}


#	my $form_data = $self->_recurse_gui(gui=>$app_node), form_data => {};

	my $form_data = $params{form_data};
	$form_data->{children} = [];
	my($widgets_node) = $app_node->getElementsByTagName("TkWidgets", 0);
	my @widget_nodes;
	if ($widgets_node) {
	    @widget_nodes = $widgets_node->getElementsByTagName("TkWidget", 0);
	}
	$form_data->{geometry} = $app_node->getAttribute('geometry');
	$form_data->{title} = $app_node->getAttribute('title');
	$form_data->{super_class} = $app_node->getAttribute('super_class');
	$form_data->{super_class} ||= "Tk::Frame";
	$form_data->{geo_mgr_type} = $app_node->getAttribute('geo_mgr_type');

	foreach my $widget_node (@widget_nodes) {
		next if $widget_node->getNodeType != ELEMENT_NODE;
		my $widget_obj = load Guido::SourceFile::TkWidget::Basic(
			node=>$widget_node, 
			app=>$app,
			parent=>$self,
		);
				
		#Put object in the children array
		push(@{$form_data->{children}}, $widget_obj);
	}
	
	$app->TRACE("Form for " . $self->name . " is:\n" . Dumper($form_data), 1);

	$doc->dispose();
	return $form_data;
}


################
#Event Handlers
################

sub _e_debug_dump {
	Tk::Menu::Unpost();
	my($self) = @_;
	TRACE($self->to_string, 1);
}

sub _e_set_primary {
	Tk::Menu::Unpost();
	my($self) = @_;
	$app->projects($self->project_name)->primary_source_file($self->name);
	$app->refresh();
}

sub _e_view_code {
	Tk::Menu::Unpost();
	my($self) = @_;
	my $dialog = $app->{mw}->DialogBox(
		-title=>'Code for ' . $self->type . " " . $self->name,
		-buttons=>['OK'],
	);
	my $text = $dialog->add(
		'Scrolled',
		'Text',
		-height=>20,
		-width=>60,
	)->pack();
	$text->insert('end',$self->to_code());
	$dialog->Show();
}

sub _e_design_form {
	Tk::Menu::Unpost();
	my($self) = @_;
	$app->TRACE('Initiating load_form in FormBuilder', 1);
	$app->plugins('FormBuilder')->load_form(source_file=>$self);
}

sub _e_close_form {
	Tk::Menu::Unpost();
	my($self) = @_;
	$app->plugins("FormBuilder")->destroy_form(form_name=>$self->name);
}

sub _e_save_form {
	Tk::Menu::Unpost();
	my($self) = @_;
	return $self->save();
}

sub _e_remove_from_project {
	Tk::Menu::Unpost();
	my($self) = @_;
	delete $app->projects($self->project_name)->{source_files}->{$self->name};
	$app->refresh();
	return $self;
}

sub _e_edit_events {
	Tk::Menu::Unpost();
	my($self) = @_;
	my $file_path = $self->events_file_path;
	my $working_dir = $self->working_dir;
	$file_path = File::Spec->canonpath($file_path);
	$app->TRACE("Trying to open $file_path (working dir $working_dir)...", 1);
	my $exec = $app->plugins("Executor");
	if ($exec) {
		my $process = $exec->auto_launch(file=>$file_path, working_dir=>$working_dir);
		$app->TRACE("Executor plugin returned: $process",1);
	}
	else {
		$app->TRACE("Executor plugin not loaded! Failed to execute $file_path",1);
	}
}


sub _e_properties {
  Tk::Menu::Unpost();
  my($self, %params) = @_;

  my $dlg = $app->mw->Mapper(
    -object => $self,
  );
  $dlg->Show();
}


# Autoload methods go after =cut, and are processed by the autosplit program.

1;
__END__



=head1 NAME

Guido::SourceFile::TkComposite - Class for managing data related to a Tk "composite", a.k.a a Tk::Widget

=head1 SYNOPSIS

  use Guido::SourceFile::TkComposite;


=head1 DESCRIPTION

The TkComposite class is a SourceFile class for managing data intended to create a Tk::Widget by combining other existing Tk Widgets into a composite widget.  It can be the main source file of a TkWidget project, or a non-main source file for a TkApp project (when this happens, the widget is only usable from within the TkApp project, and is not available to other applications)

=head1 INTERFACE

=head1 KNOWN ISSUES

None known at this time

=head1 AUTHOR

jtillman@bigfoot.com

=head1 SEE ALSO

perl(1).

=cut
