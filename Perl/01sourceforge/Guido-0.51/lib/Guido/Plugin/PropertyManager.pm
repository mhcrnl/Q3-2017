package Guido::Plugin::PropertyManager;

require Guido::Plugin;
use Tk;
require Tk::Frame;
use Tk::NoteBook;
use Guido::PropertyPage;

use vars qw( @ISA );
use Guido::Plugin;
use Tk::Derived;
use Tk::Frame;
@ISA = qw( Guido::Plugin Tk::Derived Tk::Frame );

#use base qw(Guido::Plugin Tk::Derived Tk::Frame);

$VERSION = '0.010';

Construct Tk::Widget 'PropertyManager';

my $app;
my $ps;
my %name2id = ();

my %pack_params = (		
	-expand=>1, 
	-fill=>'both', 
	-side=>'top', 
	-anchor=>'n',
);

sub init_plugin {
	my($self, $param_app) = @_;

	# $app is global to this module
	$app = $param_app;
}

sub place_menus {
	# For instance, the File Menu creates a sub menu popup
	# For example, look at plugin ProjectManager.pm
}

sub refresh {
	# Called when application state changes like when someone adds a new file
}

sub Populate {
	my ($cw, $args) = @_;

	$cw->SUPER::Populate($args);
	
	#Create GUI
	
	#Header portion
	my $main_frame = $cw->Frame(
		-borderwidth => 3,
		-relief => 'raised',
	)->pack(
		-fill => 'both',
		-expand => 1,
	);
	my $header = $main_frame->Label(
		-text=>'Property Manager',
		-borderwidth => 2,
		-relief => 'raised',
	)->pack(
		-side => 'top',
		-fill => 'x',
	);

	$cw->ConfigSpecs(
	        -font => [$header, 'font', 'Font', '{Arial} 8 {bold}'],
		-background => [$header, 'background', 'Background', 'dark blue'],
		-foreground => ['DESCENDANTS', 'foreground', 'Foreground', 'white'],
	);

	#Functional portion
	my $menu_button = $main_frame->Menubutton()->pack();
	my $item_props = $main_frame->PropertyPage()->pack(%pack_params);

	$cw->Advertise('menu' => $menu_button);
	$cw->Advertise('property_page' => $item_props);
	$cw->Advertise('main_frame' => $main_frame);
}


##
#Methods
##
sub update_property {
	my($self, %params) = @_;
	foreach my $prop (values %{$self->{props}}) {
	  $prop->value($params{value}) if $prop->name eq $params{name};
	  #print "updated value $params{name} as $params{value}\n";
        }
}

sub property_source {$ps}

sub display_properties {
	my($self, %params) = @_;
	$ps = $params{property_source} || '';
	$app->ERROR(text=>"Invalid property source") unless $ps;

	if ($self->{_current_object} && $self->{_current_object} == $ps) {return 1;}

	$self->Subwidget("menu")->pack();
	$self->Subwidget("property_page")->pack();

	my @children_menu_items;
	my @children_objects = $ps->property_source_children;
	foreach my $child (@children_objects) {
		my $child_struct = [
			Button => $child->property_source_name,
			-command => sub {
				$app->TRACE("Switching view to child now", 1);
				$app->TRACE("The child is of type " . ref($child), 1);
				$self->display_properties(property_source=>$child);
			}
		];
		push(@children_menu_items, $child_struct);
	}


	my @sibling_menu_items;
	my @sibling_objects = $ps->property_source_siblings;
	foreach my $sibling (@sibling_objects) {
		my $sibling_struct = [
			Button => $sibling->property_source_name,
			-command => sub {
				$app->TRACE("Switching view to sibling now", 1);
				$app->TRACE("The sibling is of type " . ref($sibling), 1);
				$self->display_properties(property_source=>$sibling);
			}
		];
		push(@sibling_menu_items, $sibling_struct);
	}

	my $menu_struct = [];

	if (@children_menu_items) {
	    push(@$menu_struct, [
		Cascade => "Children",		
		-tearoff => 0,
		-menuitems => \@children_menu_items,
	       ]
	    );
	}
	if (@sibling_menu_items) {
	    push(@$menu_struct, [
		Cascade => "Siblings",
		-tearoff => 0,
		-menuitems => \@sibling_menu_items,
	       ]	
	    );
	}


	if ($ps->property_source_parent) {
		my $parent_struct = [
			Button => "Parent",
			-command => sub{
				$app->TRACE("Switching view to parent now", 1);
				$app->TRACE("The parent is of type " . ref($ps->property_source_parent), 1);
				$self->display_properties(property_source=>$ps->property_source_parent) if $ps->property_source_parent;
			}
		];
		unshift(@$menu_struct, $parent_struct);
	}

	my $temp_menu = $self->Subwidget('menu')->Menu(
		-tearoff => 0,
		-menuitems => $menu_struct,
	);

	my $ps_type = $ps->property_source_type;
	if ($ps_type =~ /::/) {
		($ps_type) = $ps_type =~ /::([^:]*)$/;
	}

	$app->TRACE("This property source is a $ps_type", 1);

	$self->Subwidget('menu')->configure(
		-relief => 'raised',
		#-indicatoron=>1,
		-text => $ps_type . " " . $ps->property_source_name,
		-menu => $temp_menu,
	);

	
	$app->TRACE(join("\n", keys %$props), 1);
	$app->TRACE("Setting focus to " . $ps->property_source_name . " of type $ps", 1);

        eval{  $self->Subwidget('property_page')->destroy; };

	$self->{_current_object} = $ps;
	my $form_props = $self->Subwidget('main_frame')->PropertyPage(
		-append_props => $ps->property_source_properties,
		-prop_options => $ps->property_source_options,
		-prop_categories => $ps->property_source_categories,
		#-validatecommand => $ps,
	)->pack(%pack_params);
	$self->Advertise('property_page' => $form_props);
	
	return 1;
}

sub clear {
        my($self, %params) = @_;
	$params{property_source} ||= '';
	if ($self->{_current_object} eq $params{property_source} || $params{override}) {
                $self->Subwidget('property_page')->packForget;
		$self->Subwidget('menu')->packForget;
        }
	$ps = undef;
}

############################################
# Following subroutines are event handlers #
############################################

sub _e_validate {
	$app->TRACE("Property change: " . join(":", @_), 1);
	return 1;
}

sub _e_select_property_page {
	my($self, $browse_entry, $form_name) = @_;
	my $form_id = $name2id{$form_name};
	$self->load_property_page();
}

sub _e_populate_property_page_select {
	my($browse_entry) = @_;
	%name2id = ();
	foreach my $form_name (keys %$forms) {
		$name2id{$forms->{$form_name}->name} = $form_name;
	}
	
	$browse_entry->choices([keys %name2id]);
}

sub _e_property_change {
	
}

1;

__END__

# Below is the stub of documentation for your module. You better edit it!

=head1 NAME

PropertyManager - A Guido plugin for managing properties of various objects in the IDE, such as forms, widgets, and projects

=head1 SYNOPSIS

  # Not intended to be instantiated outside the Guido environment

=head1 DESCRIPTION

The Property Manager is Guido's primary way of editing properties of widgets, forms, projects, etc.  It provides a unified interface for editing values.

=head1 KNOWN ISSUES

None known at this time.

=head1 AUTHOR

James Tillman <jtillman@bigfoot.com>

=head1 SEE ALSO

perl(1).

=head1 Things to do next

=cut
