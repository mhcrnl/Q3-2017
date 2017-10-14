# MODINFO module Guido::SourceFile::TkWidget::Basic Class for management of a single basic Tk widget within the context of a SourceFile such as TkForm or TkComposite
package Guido::SourceFile::TkWidget::Basic;

# MODINFO dependency module strict
use strict;

# MODINFO dependency module vars
use vars qw($VERSION @ISA @EXPORT @EXPORT_OK);

# MODINFO dependency module vars
use vars qw( @ISA );
# MODINFO dependency module Guido::PropertySource
use Guido::PropertySource;
# MODINFO dependency module Guido::Property
use Guido::Property;
# MODINFO parent_class Guido::PropertySource
@ISA = qw( Guido::PropertySource );

#use base 'Guido::PropertySource';

# MODINFO dependency module Class::MethodMaker
use Class::MethodMaker get_set => [ qw / name ref geo_mgr children top parent type params / ];
# MODINFO dependency module Data::Dumper
use Data::Dumper;
# MODINFO dependency module Cwd;
use Cwd;
# MODINFO dependency module XML::DOM
use XML::DOM;
# MODINFO dependency module Tk
use Tk;
# MODINFO dependency module Template
use Template;
# MODINFO dependency module WidgetDrag
use WidgetDrag;
# MODINFO dependency module Tk::DropSite
use Tk::DropSite;

# MODINFO dependency module constant
use constant DEFAULT_TEMPLATE_DIR => 'Guido/SourceFile/TkWidget/Basic/templates';
# MODINFO dependency module constant
use constant DEFAULT_PROPERTY_FILE => 'Guido/properties.xml';

# MODINFO version 0.01
$VERSION = '0.01';
my $app;
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
# MODINFO key app Guido::Application Ref to the main Guido IDE
# MODINFO key name STRING Name of the widget
# MODINFO key ref Tk::Widget Ref to an existing Tk::Widget object that should be managed by this instance of the class
# MODINFO key children ARRAYREF Array of children for this widget (mainly for container widgets such as Tk::Frame)
# MODINFO key parent Guido::SourceFile The sourcefile instance that is managing this widget
# MODINFO key type STRING Type of widget being managed
# MODINFO key geo_mgr HASHREF Hash of values defining the geometry of the widget (pack, place, x/y, etc) in standard Tk format
sub new {
        my($class, %attribs) = @_;
        my $geo_mgr_objects = {};
        #my $param_objects = {};


        #Defaults
        $attribs{params} ||= {};

        my $app = $attribs{app};

        my $self = {
          app => $attribs{app},
          name => $attribs{name},
          'ref' => $attribs{'ref'},
          children => ($attribs{children} or []),
          parent => $attribs{parent},
          top => ($attribs{top} or $attribs{parent}),
          type => $attribs{type},
        };

        bless $self => $class;

        #Build and set the geo_mgr properties
        if($attribs{geo_mgr}) {
            TRACE("Using provided geo mgr props: " . Dumper($attribs{geo_mgr}), 1);
          while(my($key, $value) = each %{$attribs{geo_mgr}}) {
             $geo_mgr_objects->{$key} = new Guido::Property(
              name=>$key,
              value=>$value,
	      default_value=>$value,
              type=>'geo',
              listeners=>[$self],
            );
          }
        }
        else {
            TRACE("Using default geo mgr props.", 1);
          $geo_mgr_objects = {
                type=> new Guido::Property(name=>'type',value=>'place',default_value=>'place',type=>'geo',listeners=>[$self]),
                x=>new Guido::Property(name=>'x',value=>'1',default_value=>'1',type=>'geo',listeners=>[$self]),
                y=>new Guido::Property(name=>'y',value=>'1',default_value=>'1',type=>'geo',listeners=>[$self]),
          };
        }

        $self->{geo_mgr} = $geo_mgr_objects;

        $self->_populate_widget_props(%attribs);

        if (!$attribs{name}) {
            TRACE("Widget is generating name for itself", 99);
                my $temp_widget = $self->to_widget(parent=>$self->parent->ref);
                $self->{name} = $temp_widget->name();
                $temp_widget->destroy();
        }

        TRACE("New $attribs{type} widget being added", 1) if $app;
        return $self;
}

# MODINFO function load An alternate constructor that allows for loading the object's data from an XML::DOM::Node object
# MODINFO paramhash attribs
# MODINFO key app Guido::Application Ref to the main Guido IDE
# MODINFO key node XML::DOM::Node Node from which to load the object's data
sub load {
        my($class, %attribs) = @_;
        my $node = $attribs{node};
        $app = $attribs{app};
        
        TRACE("Guido::SourceFile::TkWidget::Basic->load()");
        
        my $widget_name = $node->getAttribute("name");
        my $widget_type = $node->getAttribute("type");

        my $self = {
                app=>$attribs{app},
                name=>$widget_name,
                parent => $attribs{parent},
                type=> $widget_type,
                geo_mgr => {},
                params => {},
                children => [],
        };

        if ($attribs{top}) {$self->{top} = $attribs{top}}
        else               {$self->{top} = $attribs{parent}}
        
        bless $self => $class;

        #Get geo_mgr information
        my($geo_node) = $node->getElementsByTagName("geo_info");
        my @geo_params = $geo_node->getElementsByTagName("param");
        $self->geo_mgr->{type} = new Guido::Property(
            name=> 'type',
            value=>$geo_node->getAttribute("mgr"),
            type=> 'geo',
            display_name => 'Geo Mgr',
            listeners => [$self],
        );

        foreach my $geo_param (@geo_params) {
                my $name = $geo_param->getAttribute("name");
                #next if $name eq 'geo_mgr';
                my $value = $geo_param->getAttribute("value");
                my $prop = new Guido::Property(
                    name => $name,
                    value => $value,
                    type => 'geo',
                    display_name => _get_display_name($name),
                    listeners => [$self],
                );
                $self->geo_mgr->{$name} = $prop;
        }

        #Get reference to a widget of this type so we can
        # determine all the properties we should have
        $self->_populate_widget_props();
        
        #Get widget param info (0 means don't recurse the XML tree)
        my @params = $node->getElementsByTagName("param", 0);
        foreach my $param (@params) {
          my $name = $param->getAttribute("name");
          my $value = $param->getAttribute("value");
          my(@enum, $enum_style);

          #If the property is a code ref, then create a list of possible
          # code handlers to use
          if ($param->getAttribute("data_type") eq 'CODE_REF') {
              @enum = $self->top->event_handlers();
              $enum_style = 'FREE';
          }
          my $prop = new Guido::Property(
              name => $name,
              value => $value,
              is_stock => $param->getAttribute("is_stock"),
              data_type => $param->getAttribute("data_type"),
              type => 'basic',
              display_name => $param->getAttribute('display_name'),
              listeners => [$self],
              enum => \@enum,
              enum_style => $enum_style,
          );
          $self->{params}->{$name} = $prop;
        }


        # Populate children if this widget has any
        my @children;
        my ($children_node) = $node->getElementsByTagName("children");
        if ($children_node) {
            foreach my $child_node (
                $children_node->getElementsByTagName("TkWidget")) {
                TRACE("Processing child " . $children_node->getElementsByTagName("name"), 1);
                my $child = load Guido::SourceFile::TkWidget::Basic(
                    parent => $self,
                    app => $app,
                    node => $child_node,
                    top => $self->top,
                );
                push(@children, $child);
                #$child->to_widget(parent_widget=>$self->ref);
            }
            $self->{children} = \@children;
        }
        return $self;
}

# MODINFO method DESTROY
sub DESTROY {}

sub set_param {
    my($self, %params) = @_;
    foreach my $param ($self->params) {
	$param->value($params{value}) if ($param->name eq $params{name});
    }
}

#Converts the object to perl code using a template
# MODINFO method to_code Converts the object to perl code for inclusion in the project's main code
# MODINFO retval STRING
sub to_code {
        my($self) = @_;
        my $code;
        my $tt = Template->new({
                PRE_CHOMP=>1,
                INCLUDE_PATH=>[Tk::findINC(DEFAULT_TEMPLATE_DIR)],

        });
        my $tpl_file = 'to_code.tt';
        $tt->process($tpl_file, $self, \$code) or die $tt->error();
        return $code;
}

#This is a debugging routine
# MODINFO method to_string Converts the object's data to a string using the Data::Dumper module
# MODINFO retval STRING
sub to_string {
        my($self) = @_;
        return Dumper($self);
}

#Convert our private data to an XML node for saving to a project file
# MODINFO method to_node Converts the object's data to an XML::DOM::Node object
# MODINFO paramhash params
# MODINFO key xml_doc XML::DOM::Document The document to use when creating the node object
# MODINFO retval XML::DOM::Node
sub to_node {
        my($self, %params) = @_;
        TRACE("I am $self",1);
        if (!$self->type) {
                $app->ERROR(text=>"Missing widget type when converting to XML node");
                next;
        }

        #xml_doc contains ref to the parent XML::DOM document
        my $xml_doc = $params{xml_doc};
        my $node = $xml_doc->createElement("TkWidget");
        $node->setAttribute("type", $self->type);
        $node->setAttribute("name", $self->name);
        $node->setAttribute("subtype", ref($self));

        #Get the geometry manager and its parameters
        my $geo_node = $xml_doc->createElement("geo_info");
        $geo_node->setAttribute("mgr", $self->geo_mgr->{type}->value);
        $node->appendChild($geo_node);
        foreach my $param (values %{$self->geo_mgr}) {
         # print $param->name . "\n"; next;
                my $param_node = $xml_doc->createElement("param");
                next if $param->name eq 'type';
                $param_node->setAttribute("name", $param->name);
                $param_node->setAttribute("value", $param->value);
                $geo_node->appendChild($param_node);
        }
        #Handle the parameters as individual attributes
        foreach my $param (values %{$self->params}) {
                my $param_node = $xml_doc->createElement("param");
                $param_node->setAttribute("name", $param->name);
                $param_node->setAttribute("value", $param->value);
                $param_node->setAttribute("data_type", $param->data_type);
                $node->appendChild($param_node);
        }
        
        if ($self->children) {
            my $children_node = $xml_doc->createElement("children");
            $node->appendChild($children_node);
            foreach my $child (@{$self->children}) {
                $children_node->appendChild(
                    $child->to_node(xml_doc=>$xml_doc)
                );
            }
        }

        return $node;
}

# MODINFO method to_widget Use the object's data to create a real Tk widget for placement in a form or other widget
# MODINFO paramhash params
# MODINFO key parent Tk::Widget The parent widget with which to create the new widget
# MODINFO retval Tk::Widget
sub to_widget {
        my ($self, %params) = @_;
        my $parent_widget = delete $params{parent};
        
# These need to be modified to use the property objects
# that are now stored in the params and geo_mgr hashes
# Also, should the tk name include the "-"?

        my $type = $self->type;
        my %widget_params = %{$self->{params}} if $self->{params};
        my %geo_params = %{$self->{geo_mgr}};
        my $xgeo_mgr = delete $geo_params{type};
        my $geo_mgr = $xgeo_mgr->value;

        foreach my $key (keys %geo_params) {
          $geo_params{'-' . $key} = $geo_params{$key}->value;
          delete $geo_params{$key};
        }
        foreach my $key (keys %widget_params) {
          my $fixed_param = $widget_params{$key}->value;
          delete $widget_params{$key};
          next if !defined $fixed_param || $fixed_param eq '';

          if($key =~ /^-/) {
            $widget_params{$key} = $fixed_param;
          }
          else {
            $widget_params{'-' . $key} = $fixed_param;
          }
        }

        if (!$type) {
                $app->ERROR(text=>"Missing widget type for widget named " . $self->name);
                return undef;
        }

        if (!$parent_widget) {
                $app->ERROR(text=>"Missing parent widget for widget named " . $self->name);
                return undef;
        }

        #Do a dynamic import of the Tk class we're instantiating
        my $type_path = $type;
        $type_path =~ s|::|/|g;
        my($sub_type) = $type =~ /::([^:]+)$/;
        if (!$sub_type) {
                $sub_type = $type;
                $type = "Tk::$type";
        }
        eval{
                require "$type_path.pm";
        };
        if ($@) {
                eval {
                        $@ = undef;
                        require "Tk/$type_path.pm";
                };
        }

        if($@) {
                $app->ERROR(text=>"Couldn't import widget of type $type: $@");
                return 0;
        }
        else {
                TRACE("Widget $type imported successfully\n", 1);
        }
        TRACE("Widget geo params are: " . Dumper(\%geo_params), 1);
	if ($geo_mgr eq 'place') {
	    $geo_params{'-x'} = 1 if !$geo_params{'-x'};
	    $geo_params{'-y'} = 1 if !$geo_params{'-y'};
	}
        my $new_widget = ($parent_widget->$sub_type(%widget_params)->$geo_mgr(%geo_params));
        
        ##
        #Set up bindings
        ##
        
        if ($geo_mgr eq 'place') {
            TRACE("Enabling drag on widget", 50);
            WidgetDrag::enable_drag($new_widget,$self);
        }
        else {
	    $new_widget->bind("<ButtonPress-1>", sub {$new_widget->focus()});
	}

        #Need to add method to PropertyManager that allows passing of a ProperySource
        # object and setting the focus to it
        $new_widget->bind("<FocusIn>", sub {$self->{app}->plugins("PropertyManager")->display_properties(property_source=>$self)});
        #This next line doesn't work, and I don't know why.
        #$new_widget->bind("<Unmap>", sub {$app->plugins("PropertyManager")->clear(property_source=>$self)});

        #Add support for dropping widgets on this one as children
        $new_widget->DropSite(
            -droptypes   => [qw/Local/],
            -dropcommand => [\&request_widget, $self],
       );

        $self->{ref} = $new_widget;

        if ($self->children) {
            foreach my $child (@{$self->children}) {
                $child->to_widget(parent=>$self->{ref});
            }
        }

        $self->_attach_menu();
#       print "$new_widget\n";
        return $self->{ref};
}

sub request_widget {
    my($self, $source, $x, $y) = @_;
    my $widget_geo = {
	type => 'place',
	x => $x,
	y => $y,
    };

    $app->plugins("Toolbox")->create_active_widget(
	parent=>$self, 
	widget_geo => $widget_geo,
    );
    return 1;
}

sub add_widget {
    my($self, $child) = @_;
    push(@{$self->{children}}, $child);
    $child->to_widget(parent=>$self->{ref});
    return 1;
}

sub remove_widget {
    my($self, %params) = @_;
    my @kept_children;
    print "Looking for $params{widget}\n";
    foreach my $child (@{$self->children}) {
        print "Checking $child\n";
        if ($child eq $params{widget}) {
            $child->ref->packForget();
            $child->ref->destroy();
        }
        else {
            push(@kept_children, $child);
        }
    }
    $self->{children} = \@kept_children;
    return 1;
}

# MODINFO method update_position Update the coordinate information of the widget's geo manager data (only useful right now when using "place" geo mgr)
# MODINFO param newx INTEGER New X coordinate
# MODINFO param newy INTEGER New Y coordinate
# MODINFO retval
sub update_position {
        my($self, $newx, $newy) = @_;
#       print "Self is $self\n";
        if ($self->{geo_mgr}->{type}->value eq 'pack') {
        }
        elsif ($self->{geo_mgr}->{type}->value eq 'grid') {
        }
        elsif ($self->{geo_mgr}->{type}->value eq 'form') {
        }
        
        else {
                $self->{geo_mgr}->{x}->value($newx);
                $self->{geo_mgr}->{y}->value($newy);
        }
        TRACE("Widget updating position to $newx:$newy",1);
        #$app->plugins("PropertyManager")->update_property(name=>'x', value=>$newx);
        #$app->plugins("PropertyManager")->update_property(name=>'y', value=>$newy);
        $self->top->dirty(1);
}


##
#Overrides for Guido::PropertySource
##

# MODINFO method property_source_parent Returns the object's parent
# MODINFO retval Guido::SourceFile
sub property_source_parent {
        my($self) = @_;
        return $self->parent;
}

# MODINFO method property_source_children Returns the object's children array
# MODINFO retval ARRAY
sub property_source_children {
    return @{$_[0]->children};
}

# MODINFO method property_source_tk_ref Returns the true Tk widget currently being managed by the object
# MODINFO retval Tk::Widget
sub property_source_tk_ref {
        return shift->{ref};
}

# MODINFO method property_source_name Return name of the widget
# MODINFO retval STRING
sub property_source_name {
        my($self) = @_;
        return $self->name;
}

# MODINFO method property_source_type Return the type of widget defined in our data
# MODINFO retval STRING
sub property_source_type {
        my($self) = @_;
        return $self->type;
}

# MODINFO method property_source_properties Return an array of Guido::Property objects that represent all the properties of the widget
# MODINFO retval ARRAYREF
sub property_source_properties {
        my($self) = @_; 
        return [
                values %{$self->params},
                values %{$self->geo_mgr},
                new Guido::Property(
                  name => 'name',
                  value => $self->name,
                  type => 'custom',
                  display_name => 'Name',
                ),
        ];
}

# MODINFO method property_source_siblings Return an array containing all the widget manager objects currently being managed by the same Guido::SourceFile object as this one
# MODINFO retval ARRAYREF
sub property_source_siblings {
        my($self) = @_;
        #my $sibling_hash = $self->parent->children;
        #my @widgets = values %$sibling_hash;
        my @siblings;
        foreach my $widget (@{$self->parent->children}) {
                push(@siblings, $widget) unless $widget == $self;
        } 
        return @siblings;
}
 
# MODINFO method property_change Callback event notification
# MODINFO param property_obj Guido::Property Ref to the property object that has changed
# MODINFO param old_property_value ANY Old value of the property (the new value can be retrieved from the object itself)
# MODINFO retval BOOLEAN
sub property_change {
        my($self, $property_obj, $old_property_value) = @_;
        return 0 if !$property_obj and $old_property_value;
        TRACE("Received a property change callback", 1);

        my $property_name = '-' . $property_obj->name;
        my $property_value = $property_obj->value;
        my $property_type = $property_obj->type;
        TRACE("Property name is $property_name", 1);
        TRACE("Property type is $property_type", 1);
        if ($property_type eq 'geo') {
          $@ = undef;
          eval {
            my $geo_type = $self->geo_mgr->{type}->value;
            $self->{ref}->$geo_type($property_name => $property_value);
	    $property_obj->value($property_value) unless $!;
            #$self->{geo_mgr}->{$property_name}->value($property_value) unless $!;
          };
        }
        elsif($property_type eq 'basic' && $self->{ref}) {
            eval {
              unless ($property_obj->data_type =~ /_REF/) {
                $self->{ref}->configure($property_name => $property_value);
            }
              TRACE("Basic property name " . $property_name . " being set to " . $property_value, 1);
              TRACE("Error setting property: $!", 1) if $!;
              $self->top->dirty(1);
            };
        }
        elsif ($property_type eq 'custom') {
                TRACE("Setting class attribute $property_name to $property_value", 1);
                $property_name = lc($property_name);
                
                if ($self->$property_name() ne $property_value) {
                        $self->$property_name($property_value);
                        $self->top->dirty(1);
                }
        }
        else {
                TRACE("Unhandled property $property_name could not be set to $property_value", 1);
        }
        if ($@) {
                TRACE("Error setting property $property_name to $property_value: $@", 1);
                return 0;
        }

        return 1;
}


##
#Private methods
##

sub _attach_menu {
        my($self, %params) = @_;
        my $widget = $self->ref;
        
        my $menuitems = 
          [
           [Button      =>  'Widget Name',              
            -background =>  'white',
            -foreground =>  'white',
            -font       =>  '{MS Sans Serif} 8 {bold}',
            -state      =>  'disabled',
           ],
#          [Button => "Properties",    -command => [\&_properties, $self]],
           [Button => "Edit Event(s)", -command => [\&_edit_events, $self]],
           [Button => "Delete",        -command => [\&_delete, $self]],
           [Button => "Resize",        -command => [\&_resize, $self]],
           [Cascade => "Clipboard", 
            -tearoff => 0,
            -menuitems => 
            [
             [Button => "Copy", -command => \&_copy],
             [Button => "Cut",  -command => \&_cut],
            ],
           ],
           [Cascade => "Arrange", 
            -tearoff => 0,
            -menuitems => 
            [
             [Button => "Bring to Top",   -command => [\&_arrange, $self, 'Bring to Top']],
             [Button => "Move Up",        -command => [\&_arrange, $self, 'Move Up']],
             [Button => "Move Down",      -command => [\&_arrange, $self, 'Move Down']],
             [Button => "Send to Bottom", -command => [\&_arrange, $self, 'Send to Bottom']],
            ],
           ],
           [Button => "View final code", -command => [\&_view_code, $self]],
           [Button => "Trace dump", -command => [\&_trace_dump, $self]],
          ];
        
        my $menubar = $widget->Menu(
                                    -menuitems => $menuitems,
                                    -tearoff => 0
                                   );

        $widget->bindtags([$widget, $widget->toplevel,'all']);

        $self->_kill_bindings($widget);

        $widget->bind(
                      "<Button-3>" =>
                      sub {
                        $menubar->entryconfigure(0, -label=>$self->name);
                        $menubar->Popup(        
                                        -popover        => "cursor",
                                        -popanchor      => 'nw'
                                       );
                      }
                     );

}


sub _kill_bindings {
        my($self, $widget) = @_;
        #foreach my $child ($widget->children) {
        #       $app->TRACE("Killing bindings for " . $child, 1);
        #       $child->bindtags([$child->parent, 'all']);
        #       $self->_kill_bindings($child);
        #}
}

sub _insert_handler {
    # Needs to check for the presence of the handler in the file already
    #  or we'll have an invalid file
    my($self, $handler_name) = @_;
    my $top = $self->top;
    my $parent = $self->parent;
    my $orig_dir = cwd;
    my $curr_line_nbr = 0;
    my $handler_line_nbr = undef;
    unless(chdir($top->working_dir)) {
        ERROR(text=>"Couldn't chdir to $parent->working_dir: $!");
        return 0;
    }
    if (open(EV, $top->events_file_path)) {
        unless(open(EVT, ">" . $top->events_file_path . ".tmp")) {
            ERROR(text=>"Couldn't create temp file " . 
                    $top->events_file_path . 
                      ".tmp for writing: $!");
            return undef;
        }
        #
        # Loop over the entire file until we find the end and then
        #  insert our new event handler
        #
        while(my $line = <EV>) {
            if ($line =~ /^1;$/) {
                $handler_line_nbr = $curr_line_nbr;
                $line = <<EOL;
#+GUIDO $handler_name + If you're editing this file by hand, please do not remove this line or what is below it!
sub $handler_name\{

  #Todo:  ADD YOUR EVENT HANDLER CODE HERE

\}
#-GUIDO $handler_name - If you're editing this file by hand, please do not remove this line or what is above it!

$line
EOL
                # Append number of lines in $line onto the line count
                $curr_line_nbr += $line =~ /\n/;
                print EVT $line;
            }
            else {
                ++$curr_line_nbr;
                print EVT $line;
            }
        }
        close(EVT);
        close(EV);
        rename($top->events_file_path, $top->events_file_path . ".old");
        rename($top->events_file_path . ".tmp", $top->events_file_path);
        #print "Changing back to $orig_dir\n";
        chdir($orig_dir);
        return $handler_line_nbr;
    }
    else {
        ERROR(text=>"Couldn't open " . $top->events_file_path . " for reading: $!");
        chdir($orig_dir);
        return 0;
    }
}

sub _properties {
        Tk::Menu::Unpost();
        my($self) = @_;
        my $ppd = $self->ref->PropertyPageDialog(
                -widget => $self->property_source_tk_ref, 
                -widget_name => $self->name,
                -append_props => $self->property_source_properties,
                -prop_options => $self->property_source_options,
                -prop_categories => $self->property_source_categories,
        );
        my $widget_properties = $ppd->Show();
        return if !$widget_properties;
        
        #TRACE (Dumper($widget_properties), 99);
        $self->ref->configure(%$widget_properties);
        $self->params($widget_properties);
        TRACE("Setting dirty flag",1);
        $self->top->dirty(1);
        return 1;
}


sub _edit_events {
        Tk::Menu::Unpost();
        my($self,%params) = @_;
        my @code_props;
        foreach my $prop (values %{$self->params}) {
          if($prop->data_type eq 'CODE_REF') {
              push(@code_props, $prop);
          }
        }
        if (scalar(@code_props) == 1) {
            # Open the event file, find the event handler defined
            # or create a new one
            my $prop = $code_props[0];
            if ($prop->value) {
                TRACE("Event handler for '" . 
                        $prop->name . "' event is: " . $prop->value, 1);
            }
            else {
                my $handler_name = $self->name . "_" . $prop->name;
                if (grep(/$handler_name/, @{$self->top->event_handlers})) {
                    TRACE("Using existing event handler named $handler_name", 1);
                    $prop->value("\\&$handler_name");
                }
                else {
                    TRACE("Creating new event handler for '" . $prop->name . 
                            "' named " . $handler_name, 1);
                    $self->_insert_handler($handler_name);
                    $prop->value("\\&$handler_name");
                }
            }
        }
        elsif (@code_props) {$app->ERROR("Multiple (" . scalar(@code_props) . ") event handlers detected: " . @code_props);}
        else {$app->ERROR("This widget has no valid event handlers");}
        return 1;
}

sub _delete {
        Tk::Menu::Unpost();
        my($self) = @_;
        #$self->parent->remove_widget(widget_name=>$self->name);
        $self->parent->remove_widget(widget=>$self);
        $app->plugins("PropertyManager")->clear(override=>1);
        TRACE ("This widget has been deleted", 1);
        return 1;
}

sub _resize {
        Tk::Menu::Unpost();
        TRACE ("This will eventually allow the user to resize the widget", 1);
        return 1;
}

sub _copy {
        Tk::Menu::Unpost();
        TRACE ("This will eventually copy the widget", 1);
        return 1;
}

sub _cut {
        Tk::Menu::Unpost();
        TRACE ("This will eventually cut the widget", 1);
        # UnmapWindow is useful for cutting and pasting, doesn't seem to work right though
        # gets refreshed when another widget is created.
        #$clicked->UnmapWindow;
        #$app->TRACE ("This widget has been cut", 1);
        return 1;
}

sub _paste {
        Tk::Menu::Unpost();
        TRACE ("This will eventually paste the widget", 1);
        return 1;
}

sub _arrange {
        Tk::Menu::Unpost();
        my ($self, $mode) = @_;

        if ($mode eq 'Bring to Top') {
                $self->ref->raise();

                # [dirty] This does not check to see if the widget was actually 
                # brought to top or was already there
                TRACE("Setting dirty flag",1);
                $self->top->dirty(1);
                return 1;
        }
        elsif ($mode eq 'Move Up') {
                my @children = $self->parent->ref->children();
                my $counter  = 0;
                my $pathname;
                foreach my $child (@children) {
                        if ($self->ref eq $child) {
                                return 1 if $counter == $#children;
                                $counter  = $counter + 1;
                                $pathname = $children[$counter]->PathName;
                                last;
                        }
                        $counter++;
                }
#               return 0 unless $pathname;
                $self->ref->raise($pathname);

                TRACE("Setting dirty flag",1);
                $self->top->dirty(1);
                return 1;
        }
        elsif ($mode eq 'Move Down') {
                my @children = $self->parent->ref->children;
                my $counter  = 0;
                my $pathname;
                foreach my $child (@children) {
                        if ($self->ref eq $child) {
                                return 1 if $counter == 0;
                                $counter  = $counter - 1;
                                $pathname = $children[$counter]->PathName;
                                last;
                        }
                        $counter++;
                }
                $self->ref->lower($pathname);

                TRACE("Setting dirty flag",1);
                $self->top->dirty(1);
                return 1;
        }
        elsif ($mode eq 'Send to Bottom') {
                $self->ref->lower();

                # [dirty] This does not check to see if the widget was actually
                # sent to bottom or was already there
                TRACE("Setting dirty flag",1);
                $self->top->dirty(1);
                return 1;
        }
        return 0;
}

sub _view_code {
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
        $text->insert('end', $self->to_code());
        $dialog->Show();
}

sub _trace_dump {
        Tk::Menu::Unpost();
        my($self) = @_;
        TRACE($self->to_string,1);
}

sub _get_display_name {
  my($name) = @_;
  $name = lc($name);
  $name =~ s/(\w+)/\u\L$1/g;
  return $name;
}

sub _populate_properties {
  my($self) = @_;
  my $widget = $self->to_widget();
  my @props = $widget->configure();
}

#Temporarily commented due to problems with tab-view feature
sub _property_source_categories {
        my($self) = @_;
        return {
                Color => [sort(qw/Activebackground Activeforeground Background Highlightbackground/)],
                Appearance => [sort(qw/Activeimage Activetile Bitmap Font/)],
                Size => [sort(qw/Height Width/)],
        };
}

sub _load_property_xml{
  my $parser = new XML::DOM::Parser();
  my $doc = $parser->parsefile(Tk::findINC(DEFAULT_PROPERTY_FILE));
  return $doc;
}

#This gets called by both the new() and load() constructors
sub _populate_widget_props {
  my($self, %attribs) = @_;

  TRACE("Loading default property definitions", 5);

  #Load the property definitions from xml
  my $doc = $self->_load_property_xml();
  my $def_props = {};
  my @def_props = $doc->getElementsByTagName("property");
  foreach my $ind_def_prop (@def_props) {
    $def_props->{$ind_def_prop->getAttribute('name')} = $ind_def_prop;
  }
  @def_props = ();

  #Use the app mainwindow or create a temporary one
  $app = $self->{'app'};
  my $mw;
  if($app) {
    $mw = $app->{mw};
  }
  else {
    $mw = new Tk::MainWindow();
    #Load the property definitions from xml
#    my $doc = $self->_load_property_xml();
#    my $def_props = {};
#    my @def_props = $doc->getElementsByTagName("property");
#    foreach my $ind_def_prop (@def_props) {
#      $def_props->{$ind_def_prop->getAttribute('name')} = $ind_def_prop;
#    }
#    @def_props = ();    $mw->iconify();
  }

  ##
  #Get the properties and set them up as empty
  ##
  #Generate a widget of the same type and get the 'configure' array
  my $widget = $self->to_widget(parent=>$mw);
  my @start_properties = $widget->configure();
  my $param_objects;
  foreach my $start_property (@start_properties) {
      next if !$start_property->[2];
      my $key = $start_property->[0];
      $key =~ s/^-//;
      my $data_type;

      #Check to see if this matches a default property
      # in our property definition file
      my(@enum, $enum_style);
      if ($def_props->{$key}) {
          my $prop_node = $def_props->{$key};
          TRACE("Default property found: $key", 1);
          $data_type = $prop_node->getAttribute("datatype");
          my @enum_nodes = $prop_node->getElementsByTagName("enum_value");
          foreach my $enum_node (@enum_nodes) {
              push(@enum, $enum_node->getAttribute("value"));
          }
          
          $enum_style = 'STRICT';

          TRACE("Datatype set to $data_type", 1);
          TRACE("Valid values are: " . join(", ", @enum), 1);
      }
      else {
          $data_type = 'STRING';
      }
      my $display_name = $start_property->[2];
      $display_name =~ s/(.)/\u$1/;
      #print "Got key $key\n";

      $param_objects->{$key} = new Guido::Property(
          name=>$key,
          display_name=>$display_name,
          type=>'basic',
          check_stock => 1,
	  value => $start_property->[3],
          default_value => $start_property->[3],
          #data_type=>$data_type,
          listeners=>[$self],
          enum=>\@enum,
          enum_style=>$enum_style,
      );
  }

  $widget->destroy;
  $widget = undef;
  $self->{ref} = undef;
  
  #Build and set the property objects for parameters that
  # have been modified from the defaults (defined in the .gui file)
  #print "Params " . Dumper($attribs{params}) . "\n";
  while (my($key, $value) = each %{$attribs{params}}) {
      $key =~ s/^-//;
      my(@enum, $enum_style);
      my $data_type = "STRING";
      if($def_props->{$key}) {
          $data_type = $def_props->{$key}->getAttribute("datatype");
          #If the property is a code ref, then create a list of possible
          # code handlers to use
          if ($def_props->{$key}->getAttribute("data_type") eq 'CODE_REF') {
              @enum = $self->top->event_handlers();
              $enum_style = 'FREE';
          }
      }

      $param_objects->{$key} = new Guido::Property(
          name=>$key,
          value=>$value,
          type=>'basic',
          listeners=>[$self],
          data_type=> $data_type,
          enum => \@enum,
          enum_style => $enum_style,                                                 );
  }

  $self->{params} = $param_objects;
}

1;
__END__



=head1 NAME

Guido::SourceFile::TkWidget::Basic - Class for managing data related to a single Tk::Widget

=head1 SYNOPSIS

  use Guido::SourceFile::TkWidget::Basic;


=head1 DESCRIPTION

The Basic class is for managing normal data descibing Tk::Widget objects as part of a larger source file, such as a TkForm or TkComposite.

=head1 INTERFACE

=head1 KNOWN ISSUES

None known at this time

=head1 AUTHOR

jtillman@bigfoot.com

=head1 SEE ALSO

perl(1).

=cut
