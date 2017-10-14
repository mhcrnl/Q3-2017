# MODINFO module Guido::RequiredFile
package Guido::RequiredFile;

# MODINFO dependency module File::Spec
use File::Spec;
# MODINFO dependency module strict
use strict;
# MODINFO dependency module vars
use vars qw($VERSION);

# MODINFO version 0.01
$VERSION = '0.01';

# MODINFO dependency module Class::DirtyMethodMaker
use Class::DirtyMethodMaker get_set => [ qw / working_dir name file_path project_name / ];

# Preloaded methods go here.

my $app;

# MODINFO constructor new
# MODINFO paramhash attribs
# MODINFO key name  STRING Name of the required file
# MODINFO key file_path STRING File path to the required file
# MODINFO key working_dir STRING Directory in which the required file can be found
# MODINFO key project_name STRING Name with which the required file is associated
sub new {
	my($class, %attribs) = @_;
	my $self = {
		name => $attribs{name},
		file_path => $attribs{file_path},
		working_dir => $attribs{working_dir},
		project_name => $attribs{project_name},
	};
	$app = $attribs{app};
	return bless $self, $class;
}


# MODINFO constructor load
# MODINFO paramhash attribs
# MODINFO key name  STRING Name of the required file
# MODINFO key file_path STRING File path to the required file
# MODINFO key working_dir STRING Directory in which the required file can be found
# MODINFO key project_name STRING Name with which the required file is associated
sub load {
	my($class, %attribs) = @_;
	my $node = $attribs{node};
	my $self = {
		name => $node->getAttribute('name'),
		file_path => $node->getAttribute('file_path'),
		working_dir => $attribs{working_dir},
		project_name => $attribs{project_name},
	};
	$app = $attribs{app};	
	return bless $self, $class;
}

# MODINFO method to_code Convert the object to a snippet of perl code that will load the required file at runtime.
# MODINFO retval STRING
sub to_code {
	my($self) = @_;
	return 'require "' . $self->file_path . "\";\n";
}

# MODINFO method to_node Convert the object to an XML node (for inclusion in an xml document
# MODINFO paramhash params
# MODINFO key xml_doc XML::DOM::Document Ref to the document that should be used to create the node
# MODINFO retval XML::DOM::Node
sub to_node {
	my($self, %params) = @_;

	#xml_doc contains ref to the parent XML::DOM document
	my $xml_doc = $params{xml_doc};
	my $node = $xml_doc->createElement("RequiredFile");
	$node->setAttribute("name", $self->name);
	$node->setAttribute("file_path", $self->file_path);
	return $node;
}

# MODINFO method edit Use the Guido Executor functionality to launch an editor for the required file
# MODINFO retval
sub edit {
	my($self) = @_;
	my $file_path = $self->file_path;
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

1;
__END__

=head1 NAME

Guido::RequiredFile - Manages files that should be included in the final collated code, using "require" statements

=head1 SYNOPSIS

  use Guido::RequiredFile;

=head1 DESCRIPTION

RequiredFile is for tracking files that the Guido project needs to be included into the source code through the perl "require" statement.  It is useful for including commonly used, non-packaged perl script code into the project.  Because you can't specify the location where the required file will be inserted, it is not useful for including code that you expect to run at certain points in your code.  For that, you'll have to "require" the file manually.

=head1 INTERFACE

=head1 KNOWN ISSUES

None currently.

=head1 AUTHOR

jtillman@bigfoot.com

=head1 SEE ALSO

perl(1).

=cut 
