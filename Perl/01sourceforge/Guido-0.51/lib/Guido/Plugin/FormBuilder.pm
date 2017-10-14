# MODINFO module Guido::Plugin::FormBuilder  Guido plugin for visually building forms
package Guido::Plugin::FormBuilder;

# MODINFO dependency module Guido::Plugin
require Guido::Plugin;
# MODINFO dependency module Tk
use Tk;
# MODINFO dependency module Tk::Frame
require Tk::Frame;
# MODINFO dependency module Tk::Toplevel
use Tk::Toplevel;
# MODINFO dependency module Tk::NoteBook
use Tk::NoteBook;
# MODINFO dependency module WidgetDrag
use WidgetDrag;
#use Tk::Balloon;

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

#use base qw(Guido::Plugin Tk::Derived Tk::Frame);

# MODINFO version 0.050
$VERSION = '0.050';

Construct Tk::Widget 'FormBuilder';

my $forms = {};
my $app;
my $clicked;
my $clicked_name;
my $active_form;
my $guido_obj;
my $form_name;
my %name2id = ();
my $drop_x;
my $drop_y;

# MODINFO method active_form Returns a ref to the active form, if any
# MODINFO retval Guido::SourceFile
sub active_form {
    return $forms->{$active_form};
}

# MODINFO method init_plugin Initialize the plugin
# MODINFO param_app Guido::Application Ref to the main Guido IDE
# MODINFO retval
sub init_plugin {
	# Can give a reference to self
	# Can give a reference to GUIDO app (look at the GUIDO app module Guido::Application)
	my($self, $param_app) = @_;

	# $app is global to this module
	$app = $param_app;
}

# MODINFO method place_menus Causes plugin to place its menus in the IDE
# MODINFO retval
sub place_menus {
	# For instance, the File Menu creates a sub menu popup
	# For example, look at plugin ProjectManager.pm
}

# MODINFO method refresh Refresh the display
# MODINFO retval
sub refresh {
	# Called when application state changes like when someone adds a new file
}

# MODINFO method display Tells whether to display the plugin or not.  FormBuilder has no GUI
# MODINFO retval BOOLEAN
sub display {return 0}

# MODINFO method Populate Standard Tk initializatio method
# MODINFO paramhashref args
# MODINFO retval
sub Populate {
	my ($cw, $args) = @_;
	$cw->SUPER::Populate($args);
	
	#Create GUI
	my $tabs = $cw->NoteBook()->pack(-expand=>1, fill=>'x');
	my $form_page = $tabs->add('form', -label=>"Open Forms");
	my $form_select = $form_page->BrowseEntry(
		-variable => \$form_name,
		-browsecmd => [\&_e_select_form, $cw],
		-listcmd => \&_e_populate_form_select,
	)->pack();
	my $form_props = $form_page->PropertyPage(
	)->pack(-expand=>1, fill=>'x');
	

}

# MODINFO method load_form Load a form into the editor (1=success/0=failure)
# MODINFO paramhash params
# MODINFO key source_file Guido::SourceFile
# MODINFO retval BOOLEAN
sub load_form {
    my ($self,%params) = @_;
    my $tkform_ref = $params{source_file};
    my $form_name = "$tkform_ref";
    
    #TkForm needs to do these things on its own, but we do it for now
    if ($forms->{$form_name} and $forms->{$form_name}->ref) {
	$app->TRACE ($form_name . ' already exists', 1);
	$active_form = $form_name;
	$forms->{$form_name}->ref->deiconify();
	$forms->{$form_name}->ref->raise();
	$forms->{$form_name}->ref->focusForce();
	return 1;
    }
    
    my $work_form = $tkform_ref->to_widget(parent=>$self);
    
    $app->TRACE("The new form's name is $form_name",1);
    
    #This should be done by TkForm later on
    $work_form->protocol('WM_DELETE_WINDOW' => sub {$self->destroy_form()});
    $work_form->bind("<FocusIn>",  sub {$self->set_active_form(form_name => $form_name)});
    $work_form->bind("<Configure>",  sub {	
			 if ($work_form->geometry ne $tkform_ref->geometry) {
			     $app->TRACE("Setting dirty flag",1);
			     $tkform_ref->geometry($work_form->geometry);
			     $tkform_ref->dirty(1);
			 }
        }
    );
    $work_form->DropSite(
	-droptypes   => [qw/Local/],
	-dropcommand => [\&request_widget],
       );	
    $work_form->raise();
    $work_form->focusForce();


    #If the form data is still around, but the form window isn't
    # then we reuse the form data that we already have and ignore the

    # Restore the Top Level with the same height and width as originally corrected
    $app->TRACE ('Geometry of the form is: ' . $tkform_ref->geometry, 1);
    
    # Save the reference to this new form to %forms
    $forms->{$form_name} = $tkform_ref;
    
    # $active_form is global to this module
    $active_form = $form_name;
    return 1;
}

# MODINFO method destroy_all_forms Destroys all forms currently being managed by the FormBuilder (1=success/0=failure)
# MODINFO retval BOOLEAN
sub destroy_all_forms {
    my($self) = @_;
    foreach my $form_name (keys %$forms) {
	$app->TRACE("Destroying form named: $form_name",1);
	$self->destroy_form(form_name=>$form_name) or return 0;
    }
    $active_form = undef;
    return 1;
}

# MODINFO method raise_all_forms Brings all forms to the top above any other windows (1=success/0=failure)
# MODINFO retval BOOLEAN
sub raise_all_forms {
    my($self) = @_;
    foreach my $form (values %$forms) {
	$app->TRACE("Raising form named: " . $form->name,1);
	$form->ref->raise();
    }
    return 1;
}

# MODINFO method destroy_form Destroy the currently active form (1=success/0=failure)
# MODINFO paramhash params
# MODINFO retval BOOLEAN
sub destroy_form {
    my($self, %params) = @_;
    if ($app->plugins("PropertyManager")) {
	$app->plugins("PropertyManager")->clear(override=>1);
    }
    unless($forms->{$active_form}) { 
	return 1;
    }
    
    $app->TRACE("Dirty flag set to: " . $forms->{$active_form}->dirty, 1);
    
    if ($forms->{$active_form}->dirty) {
	my $dialog = $self->Dialog(
	    -text => 'Changes were made to this form, do you wish to save them?', 
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
	    $app->TRACE("Saving form",1);
	    $forms->{$active_form}->save() or $app->ERROR("Error saving form!: $!");
	}
	else {
	    #This causes the TkForm object to revert to its saved
	    # version (necessary in case changes weren't saved)
	    $forms->{$active_form}->revert();
	}
    }

    $app->TRACE ("Destroying the form now", 1);

    #Destroy tk ref and remove all references to it
    $forms->{$active_form}->close_form();
    delete $forms->{$active_form};
    $active_form = '';

    return 1;
}

# MODINFO function set_active_form Sets the active form
# MODINFO paramhash params
# MODINFO key form_name STRING Name of the form to set as active form
# MODINFO retval
sub set_active_form {
    my($self, %params) = @_;
    $app->TRACE("Setting active form to $params{form_name}",1);
    $active_form = $params{form_name};
}

# MODINFO function hide_form Hide the currently active form
# MODINFO paramhash params
# MODINFO retval
sub hide_form {
    my($self, %params) = @_;
    unless($forms->{$active_form}) { 
	$app->TRACE ("I'm returning undef from hide_form and not doing anything", 1);
	return undef; 
    }
    my $work_form = $forms->{$active_form}->ref;
    $work_form->withdraw;
    $active_form = '';
}

sub request_widget {
    my($source, $x, $y) = @_;
    $drop_x = $x;
    $drop_y = $y;
    $app->TRACE("New widget to be placed at $drop_x, $drop_y", 1);
    $app->plugins("Toolbox")->create_active_widget();
}

# MODINFO method add_widget Add a widget to the currently active form
# MODINFO paramhash params
# MODINFO key form_name STRING Name of the form to add the widget to (if not provided, the active form is used)
# MODINFO key clean     BOOLEAN If provided, the dirty flag of the form is not set
# MODINFO key widget_data Tk::Widget If provided, should be the ref to the widget that should be placed.  If not provided, then the other "widget_" parameters should be provided to allow the creation of the widget
# MODINFO key widget_geo    STRING The type of geometry manager to use when adding the widget
# MODINFO key widget_name   STRING Name to give the widget (will be generated if not provided)
# MODINFO key widget_type   STRING Type of widget to create
# MODINFO key widget_params HASHREF Parameters for the widget
# MODINFO retval
sub add_widget {
# MODINFO dependency module Data::Dumper
    use Data::Dumper;
    my($self, %params) = @_;
    my $form_name = ($params{form_name} || $active_form);
    my $geo_mgr;
    my $parent = ($params{parent} or $forms->{$form_name});
    unless($forms->{$form_name}) { return undef; }
    my $work_form = $forms->{$form_name}->ref;
	
    if($params{clean}) {
	$app->TRACE("Not setting dirty flag",1);
    }
    else {
	$app->TRACE("Setting dirty flag",1);
	$forms->{$form_name}->dirty(1);
    }

    # the alternative name here is temporary and should be removed after Toolbox gives this

    $app->TRACE("Form's geo mgr type is " . $forms->{$form_name}->geo_mgr_type, 1);

    if (!$params{widget_geo}) {
	if ($forms->{$form_name}->geo_mgr_type eq 'pack') {
	    $params{widget_geo} = {
		type => 'pack',
	    };			
	}
	else {
	    #my $tgt_x = $parent->ref->x;
	    #my $tgt_y = $parent->ref->y;

	    $drop_x ||= 1;
	    $drop_y ||= 1;

	    $app->TRACE("New widget's geo_mgr will be 'place' ($drop_x, $drop_y)", 1);
	    $params{widget_geo} = {
		type => 'place',
		x => $drop_x,
		y => $drop_y,
	    };
	    $drop_x = 1;
	    $drop_y = 1;
	}
    }

    my $widget_obj = $params{widget_data};
    unless ($widget_obj) {
	$app->TRACE("Creating new TkWidget object",1);
	$widget_obj = new Guido::SourceFile::TkWidget::Basic(
	    name => $params{widget_name},
	    type => $params{widget_type},
	    params => $params{widget_params},
	    parent => $parent,
	    geo_mgr => $params{widget_geo},
	    app => $app,
	    top => $forms->{$form_name},
	);
    }
	
    my $name = $widget_obj->name;

    if (!$params{parent}) {
	$forms->{$form_name}->add_widget(widget=>$widget_obj);
    }
    else {
	$params{parent}->add_widget($widget_obj);
    }
    my $widget = $widget_obj->ref;
    $widget->{_guido_name} = $name;
    $widget->bind("<Double-Button-1>" =>
		    sub {$widget->focus();}
    );

    # For now, the only geometry manager that Guido supports for graphically moving is "place"
    # Need to come up with a method for "pack", "grid" and "form"
    $geo_mgr = $widget_obj->geo_mgr->{type}->value;
    if ($geo_mgr eq 'place' or $geo_mgr eq '') {
	WidgetDrag::enable_drag($widget,$widget_obj);
    }
    elsif ($geo_mgr eq 'pack') {
	$app->TRACE ('Some day we will support a graphical update of widget location for the geometry manager of pack',1);
    }
    elsif ($geo_mgr eq 'grid') {
	$app->TRACE ('Some day we will support a graphical update of widget location for the geometry manager of grid',1);
    }
    elsif ($geo_mgr eq 'form') {
	$app->TRACE ('Some day we will support a graphical update of widget location for the geometry manager of form',1);
    }
    $forms->{$form_name}->ref->focusForce();

}	# END OF add_widget

# MODINFO method forms Returns the internally managed hashref of forms being managed by the FormBuilder
# MODINFO retval HASHREF
sub forms {
    # now external modules have access to the forms hash
    return $forms;
}



# MODINFO method editor Returns an "editor" widget for managing the FormBuilder's configuration data
# MODINFO param parent_frame Tk::Frame Frame in which the editor widget will be placed (used for creating, not placing)
# MODINFO param config HASHREF Configuration data structure which the editor should modify
# MODINFO retval Guido::Plugin::FormBuilder::Editor
sub editor {
    my($self, $parent_frame, $config) = @_;
# MODINFO dependency module Guido::Plugin::FormBuilder::Editor
    use Guido::Plugin::FormBuilder::Editor;
    my $editor = Guido::Plugin::FormBuilder::Editor->new(
	$parent_frame->DelegateFor('Construct'),
	-config => $config,
    );
    return $editor;
}

############################################
# Following subroutines are event handlers #
############################################

sub _view_code {
    #my $widget = $forms->{$active_form}->{children}->{$clicked_name};
    my $widget = $guido_obj;
    Tk::Menu::Unpost();
    my $dialog = $app->{mw}->DialogBox(
	-title=>'Code for ' . $widget->type . " " . $widget->name,
	-buttons=>['OK'],
    );
    my $text = $dialog->add(
	'Scrolled',
	'Text',
	-height=>20,
	-width=>60,
    )->pack();
    $text->insert('end', $widget->to_code());
    $dialog->Show();
}

sub _trace_dump {
    my $widget = $guido_obj;
    Tk::Menu::Unpost();
    $app->TRACE($widget->to_string,1);
}

sub _e_select_form {
    my($self, $be, $form_name) = @_;
    my $form_id = $name2id{$form_name};
    $self->load_form(source_file=>$forms->{$form_id});
}

sub _e_populate_form_select {
    my($be) = @_;
    %name2id = ();
#	for my $form_name (map {$_->name} values %$forms) {
    foreach my $form_name (keys %$forms) {
	$name2id{$forms->{$form_name}->name} = $form_name;
    }
	
    $be->choices([keys %name2id]);
}

sub _kill_bindings {
    my($self, $widget) = @_;
    foreach my $child ($widget->children) {
	$app->TRACE("Killing bindings for " . $child, 1);
	$child->bindtags([$child->parent, 'all']);
	$self->_kill_bindings($child);
    }
}

sub _properties {
    Tk::Menu::Unpost();
    my %to_append = ();
    my $params = $forms->{$active_form}->{children}->{$clicked_name}->{params};
    foreach my $prop (keys %$params) {
	$to_append{$prop} = $params->{$prop};
    }
    my $ppd = $clicked->PropertyPageDialog(
	-widget => $clicked, 
	-widget_name => $clicked_name,
	-append_props => \%to_append,
    );
    my $widget_properties = $ppd->Show();
    return if !$widget_properties;
	
    #If person clicks OK without actually changing anything
    # the {dirty} flag will still be set, and all the properties
    # will be updated.
    
    $app->TRACE (Dumper($widget_properties), 99);
    $clicked->configure(%$widget_properties);
    $forms->{$active_form}->{children}->{$clicked_name}->{params} = $widget_properties;
    $app->TRACE (Dumper($forms), 99);
    $app->TRACE("Setting dirty flag",1);
    $forms->{$active_form}->dirty(1);
    return 1;
}

sub _edit_events {
    Tk::Menu::Unpost();
    $app->TRACE ("This will eventually open an editor with a subroutine shell", 1);
    $app->TRACE ("\$clicked = $clicked", 1);
    return 1;
}

sub _delete {
    Tk::Menu::Unpost();
    $forms->{$active_form}->remove_widget(widget_name=>$clicked_name);
    $app->TRACE ("This widget has been deleted", 1);
    return 1;
}

sub _resize {
    Tk::Menu::Unpost();
    $app->TRACE ("This will eventually allow the user to resize the widget", 1);
    return 1;
}

sub _copy {
    Tk::Menu::Unpost();
    $app->TRACE ("This will eventually copy the widget", 1);
    return 1;
}

sub _cut {
    Tk::Menu::Unpost();
    $app->TRACE ("This will eventually cut the widget", 1);
    # UnmapWindow is useful for cutting and pasting, doesn't seem to work right though
    # gets refreshed when another widget is created.
    $clicked->UnmapWindow;
    $app->TRACE ("This widget has been cut", 1);
    return 1;
}

sub _paste {
    Tk::Menu::Unpost();
    $app->TRACE ("This will eventually paste the widget", 1);
    return 1;
}

sub _bring_top {
    Tk::Menu::Unpost();
    my($event_source, $event_tag) = @_;
    $app->TRACE("Visibility: $event_tag",1);
    $forms->{$active_form}->ref->raise();
	
}

sub _arrange {
    Tk::Menu::Unpost();
    my ($mode) = @_;
    
    if ($mode eq 'Bring to Top') {
	$clicked->raise();
	
	# [dirty] This does not check to see if the widget was actually 
	# brought to top or was already there
	$app->TRACE("Setting dirty flag",1);
	$forms->{$active_form}->dirty(1);
	return 1;
    }
    elsif ($mode eq 'Move Up') {
	my @children = $clicked->parent->children;
	my $counter  = 0;
	my $pathname;
	foreach my $child (@children) {
	    if ($clicked eq $child) {
		return 1 if $counter == $#children;
		$counter  = $counter + 1;
		$pathname = $children[$counter]->PathName;
		last;
	    }
	    $counter++;
	}
	#		return 0 unless $pathname;
	$clicked->raise($pathname);
	
	$app->TRACE("Setting dirty flag",1);
	$forms->{$active_form}->dirty(1);
	return 1;
    }
    elsif ($mode eq 'Move Down') {
	my @children = $clicked->parent->children;
	my $counter  = 0;
	my $pathname;
	foreach my $child (@children) {
	    if ($clicked eq $child) {
		return 1 if $counter == 0;
		$counter  = $counter - 1;
		$pathname = $children[$counter]->PathName;
		last;
	    }
	    $counter++;
	}
	$clicked->lower($pathname);
	
	$app->TRACE("Setting dirty flag",1);
	$forms->{$active_form}->dirty(1);
	return 1;
    }
    elsif ($mode eq 'Send to Bottom') {
	$clicked->lower();
	
	# [dirty] This does not check to see if the widget was actually
	# sent to bottom or was already there
	$app->TRACE("Setting dirty flag",1);
	$forms->{$active_form}->dirty(1);
	return 1;
    }
    return 0;
}

1;

__END__

=head1 NAME

Guido::FormBuilder - Guido plugin for graphically building forms

=head1 SYNOPSIS

  use Guido::FormBuilder;


=head1 DESCRIPTION

The FormBuilder plugin is used for visually presenting and editing the source file data of TkForms, TkWidgets, and potentially other source file data.  It handles the addition of new widgets to the form and the display and hiding of the form when appropriate.

=head1 INTERFACE

=head1 KNOWN ISSUES

None known at this time.

=head1 AUTHOR

jtillman@bigfoot.com

=head1 SEE ALSO

perl(1).

=head1 Things to do next

We have already decided that the $form_frame and $form_label are Guido's "holder" for a
project form.  A project form will be a "top level" in the actual application that is being
built.  So, a simulated "top level" is a frame that is packed on $form_frame.  This $work_form
is "glued" then to Guido's "holder", and follows it in drag and resize exactly.  When this form
is either destroyed or hidden, everything from $form_frame on down is destroyed or hidden.

So, we need to be able to resize $form_frame, as well as individual widgets.  If $form_frame is
resized, then so is $work_form, by the same amount since they are "glued" together.

To do list for Guido:

1. Redisplay $work_form when design form is chosen *** COMPLETE ***
2. Resize widgets
3. Resize $work_form *** COMPLETE ***
4. Drag $work_form *** COMPLETE ***
5. Z-Order (check with the experts first) *** COMPLETE ***
6. Multiple forms within a project *** COMPLETE ***
7. Multiple projects
8. Popup hints for widgets, like the Tool Box, tried this, slow performance
9. Figure out how to handle special widgets like scrollbar length.
   It probably needs to be bound to a specific kind of widget to work.
10. Need to add functionality to bind special widgets to those widgets
    they were designed to be bound to, such as scrollbar bound to list box?

=cut
