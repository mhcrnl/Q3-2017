# MODINFO module Guido::SupportFile Class for managing files that support a project, such as graphics, binary files, etc.
package Guido::SupportFile;

# MODINFO dependency module strict
use strict;
# MODINFO dependency module vars
use vars qw($VERSION @ISA @EXPORT @EXPORT_OK);

# MODINFO dependency module Class::MethodMaker
use Class::MethodMaker get_set => [ qw / name type file_path working_dir project_name/ ];

# MODINFO dependency module XML::DOM
use XML::DOM;

# MODINFO dependency module Exporter
require Exporter;
# MODINFO dependency module AutoLoader
require AutoLoader;

# MODINFO parent_class AutoLoader
@ISA = qw(Exporter AutoLoader Guido::PropertySource);
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

# MODINFO dependency module File::Slurp
use File::Slurp;
# MODINFO dependency module Data::Dumper
use Data::Dumper;
# MODINFO dependency module Guido::Property
use Guido::Property;

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
# MODINFO key app Guido::Application Ref to the main IDE object
# MODINFO key project_name STRING name of the project with which this file is associated
# MODINFO key file_path STRING Path to the file
# MODINFO key working_dir STRING Directory where the file is located
# MODINFO key name STRING name of the file
sub new {
	my($class, %attribs) = @_;

	$app = $attribs{app};

	my $self = {
		app => $app,
		project_name => $attribs{project_name},
		working_dir => $attribs{working_dir},
		name => $attribs{name},
		file_path => $attribs{file_path},
		type => 'Basic',
		};
			
	return bless $self, $class;
}

# MODINFO constructor load
# MODINFO paramhash attribs
# MODINFO key app Guido::Application Ref to the main IDE object
# MODINFO key project_name STRING name of the project with which this file is associated
# MODINFO key file_path STRING Path to the file
# MODINFO key working_dir STRING Directory where the file is located
# MODINFO key name STRING Name of the file
# MODINFO key type STRING Type of support file this is
sub load {
	my($class, %attribs) = @_;

	$app = $attribs{app};

	my $self = {
		app => $app,
		project_name => $attribs{project_name},
		name => $attribs{name},
		file_path => $attribs{file_path},
		working_dir=> $attribs{working_dir},
		type => $attribs{type},
		};
			
	return bless $self, $class;
}

# MODINFO function to_node Convert the object's data to an XML node
# MODINFO paramhash params
# MODINFO key xml_doc XML::DOM::Document Ref to the XML document to be used when creating the XML node
# MODINFO retval XML::DOM::Node
sub to_node {
	my($self, %params) = @_;

	#xml_doc contains ref to the parent XML::DOM document
	my $xml_doc = $params{xml_doc};
	my $node = $xml_doc->createElement("SupportFile");
	$node->setAttribute("name", $self->name);
	$node->setAttribute("file_path", $self->file_path);
	return $node;
}

# MODINFO method menu Returns an array for converting into a TK menu that should appear as a popup when the visual representation of this object is right-clicked on
# MODINFO retval ARRAYREF
sub menu {
    my($self) = @_;
    return [
	[Button => "Launch editor", -command => [\&_e_edit, $self]],
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


#
# PropertySource override functions
#

sub property_source_name {$_[0]->name}

sub property_source_properties {
    my($self) = @_;
    return [
	$self->_get_prop('File Path', undef, $self->file_path),
	$self->_get_prop('Working Dir', undef, $self->working_dir),
    ];
}


#
# Some property helper subs
#
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


#
# EVENT HANDLERS
#

sub _e_debug_dump {
    Tk::Menu::Unpost();
    my($self) = @_;
    TRACE($self->to_string, 1);
}

sub _e_remove_from_project {
    Tk::Menu::Unpost();
    my($self) = @_;
    delete $app->projects($self->project_name)->{support_files}->{$self->name};
    $app->refresh();
    return $self;
}

sub _e_edit {
    Tk::Menu::Unpost();
    my($self) = @_;
    my $file_path = $self->file_path;
    my $working_dir = $self->working_dir;
    $file_path = File::Spec->canonpath($file_path);
    my $exec = $app->plugins("Executor");
    if ($exec) {
	my $process = $exec->auto_launch(
	    file        => $file_path,
	    working_dir => $working_dir,
	);
	$app->TRACE("Executor plugin returned: $process",1);
    }
    else {
	$app->TRACE("Executor plugin not loaded! Failed to execute $file_path",1);
    }
}

# Autoload methods go after =cut, and are processed by the autosplit program.

1;
__END__
# Below is the stub of documentation for your module. You better edit it!

=head1 NAME

Guido::SupportFile - Class for managing non-code files that support a project, such as graphics, binary files, etc.

=head1 SYNOPSIS

  use Guido::SupportFile;
  my $supp_file = new Guido::SupportFile(
      name => "LogoGraphic",
      file_path => '/home/jtillman/myproject/LogoGraphic.jpg',
      project => 'MyProject',
      app => $app,
  )

=head1 DESCRIPTION

The SupportFile class is for managing files that are not code, but which provide support to a project.  Image files, other binary files, just about anything that the developer wishes to keep associated with a particular project.

=head1 INTERFACE

=head1 KNOWN ISSUES

None known at this time.

=head1 AUTHOR

jtillman@bigfoot.com

=head1 SEE ALSO

perl(1).

=cut
