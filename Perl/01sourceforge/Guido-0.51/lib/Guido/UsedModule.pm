# MODINFO module Guido::UsedModule
package Guido::UsedModule;

# MODINFO dependency module strict
use strict;
# MODINFO dependency module vars
use vars qw($VERSION @ISA @EXPORT @EXPORT_OK);

# MODINFO dependency module Exporter
require Exporter;
# MODINFO dependency module AutoLoader
require AutoLoader;

# MODINFO parent_class AutoLoader
@ISA = qw(Exporter AutoLoader);
# Items to export into callers namespace by default. Note: do not export
# names by default without a very good reason. Use EXPORT_OK instead.
# Do not simply export all your public functions/methods/constants.
@EXPORT = qw();

# MODINFO version 0.01
$VERSION = '0.01';

use Class::MethodMaker get_set => [ qw /
	name 
	file_path 
	package
	imports
/];



# Preloaded methods go here.

# MODINFO constructor new
# MODINFO paramhash attribs
# MODINFO key name STRING Name of the used module
# MODINFO key file_path STRING Path to the module
# MODINFO key package STRING Package name of the module
# MODINFO key imports ARRAYREF Array of imports to make from the used module
sub new {
	my($class, %attribs) = @_;
	my $self = {
		name => $attribs{name},
		file_path => $attribs{file_path},
		package => $attribs{package},
		imports => $attribs{imports},
	};
	
	return bless $self, $class;
}

# MODINFO constructor load Alternative constructor that populates the object form an XML node
# MODINFO paramhash attribs
# MODINFO key node XML::DOM::Node Node from which to load the object's data
sub load {
	my($class, %attribs) = @_;
	my $node = $attribs{node};

	my $self = {
		name      => $node->getAttribute("name"),
		file_path => $node->getAttribute("file_path"),
		package   => $node->getAttribute("package"),
		imports   => $node->getAttribute("imports"),
	};
	
	return bless $self, $class;
}

# method save Saves the object's data to a file
#sub save {
#	my($self, %params);
#	return;
#}

# MODINFO method to_node Convert the object's data into an XML node
# MODINFO paramhash params
# MODINFO key xml_doc XML::DOM::Document XML document to use when creating the XML node
# MODINFO retval XML::DOM::Node
sub to_node {
	my($self, %params) = @_;

	#xml_doc contains ref to the parent XML::DOM document
	my $xml_doc = $params{xml_doc};
	my $node = $xml_doc->createElement("UsedModule");
	$node->setAttribute("name", $self->name);
	$node->setAttribute("file_path", $self->file_path);
	$node->setAttribute("package", $self->package);
	$node->setAttribute("imports", $self->imports);
	return $node;
}

# Autoload methods go after =cut, and are processed by the autosplit program.

1;
__END__


=head1 NAME

Guido::UsedModule - Class for managing references to modules used by a Guido project

=head1 SYNOPSIS

  use Guido::UsedModule;


=head1 DESCRIPTION

The used module class manages references to modules that are "use"-ed by the Guido project.  It also keeps track of functions and variables that are imported by the project.  The information is used when the project is converted to true perl code.

=head1 INTERFACE

=head1 KNOWN ISSUES

None known at this time.

=head1 AUTHOR

jtillman@bigfoot.com

=head1 SEE ALSO

perl(1).

=cut
