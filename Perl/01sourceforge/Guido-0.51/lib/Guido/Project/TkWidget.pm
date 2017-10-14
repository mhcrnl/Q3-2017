# MODINFO module Guido::Project::TkWidget Class for managing Guido projects intended to become Tk Widgets (Perl/Tk modules, not scripts)
package Guido::Project::TkWidget;

# MODINFO dependency module strict
use strict;

# MODINFO dependency module vars
use vars qw( @ISA );
# MODINFO dependency module Guido::Project
use Guido::Project;
# MODINFO parent_class Guido::Project
@ISA = qw( Guido::Project );
#use base 'Guido::Project';

# MODINFO dependency module vars
use vars qw($VERSION);

#use Class::DirtyMethodMaker get_set => [ qw /  / ];
#use Class::DirtyMethodMaker hash => [qw / source_files used_modules required_files /];

# MODINFO dependency module Exporter
require Exporter;
# MODINFO dependency module AutoLoader
require AutoLoader;

# MODINFO dependency module XML::DOM
use XML::DOM;
# MODINFO dependency module XML::Simple
use XML::Simple;
#use Text::Template;
# MODINFO dependency module File::Slurp
use File::Slurp;
# MODINFO dependency module File::Spec
use File::Spec;
# MODINFO dependency module File::Spec::Functions
use File::Spec::Functions;
# MODINFO dependency module File::Basename
use File::Basename;
# MODINFO dependency module Data::Dumper
use Data::Dumper;

# MODINFO dependency module Guido::SourceFile
use Guido::SourceFile;

my $app;

# MODINFO version 0.05
$VERSION = '0.05';

sub TRACE {
	if($app) {
		$app->TRACE(@_);
	}
	else {
		print $_[0] . "\n";
	}
}

sub ERROR {
	if($app) {
		#print "Sending error to app: $_[0]\n";
		$app->ERROR(@_);
	}
	else {
		print "Error: " . $_[0] . "\n";
	}
}

##
#Constructors
##

# MODINFO constructor new
# MODINFO paramhash attribs
# MODINFO key name STRING Name of the project
# MODINFO key working_dir STRING Path to the working directory for the project
# MODINFO key plugin_data HASHREF Plugin data to store for the project (optional)
# MODINFO key primary_source_file STRING Name of the source file that should become the primary (the form displayed when the script is first run)
# MODINFO key app Guido::Application Ref to the main Guido IDE
sub new {
	my($class, %attribs) = @_;

	my $self = {
		name => $attribs{name},
		working_dir => $attribs{working_dir},
		app => $attribs{app},
		plugin_data => ($attribs{plugin_data} or {}),
		type => 'TkWidget',
		primary_source_file => $attribs{primary_source_file},
	};

	#Generate main project file name
	$self->{working_dir} = catfile($attribs{working_dir}, $attribs{name});
	$self->{file_path} = catfile($self->{working_dir}, $self->{name} . ".gpj");

	$app = $attribs{app};
	TRACE("TkWidget project class taking control.",1);
	TRACE("TkWidget project file path is " . $self->{file_path},1);

	bless $self, $class;
	$self->_process_templates();
	$self->_load_project_xml(%attribs);

	$app->TRACE("Project created successfully",1);
	return $self;
}

# MODINFO constructor load An alternate constructor for loading pre-existing projects
# MODINFO paramhash attribs
# MODINFO key doc XML::DOM::Document XML document with which to populate the object's data
# MODINFO key name STRING Name of the project
# MODINFO key working_dir STRING Path to the working directory for the project
# MODINFO key plugin_data HASHREF Plugin data to store for the project (optional)
# MODINFO key primary_source_file STRING Name of the source file that should become the primary (the form displayed when the script is first run)
# MODINFO key startup_file STRING Name of the file to be used as the "startup file" when debugging or running in test mode
# MODINFO key app Guido::Application Ref to the main Guido IDE
sub load {
	#This is an alternate constructor!
	# It's for loading pre-existing projects
	# from a file
	#Open a project file (xml) and create the project mngmt
	# objects
	my($class, %attribs) = @_;
	$app = $attribs{app};
	my $doc = $attribs{doc};

	$app->TRACE("TkWidget load routine taking control", 1);

	#Create the base project object
	my $self = {
		working_dir => $attribs{working_dir},
		file_path => $attribs{file_path},
		app => $attribs{app},
		startup_file => $attribs{startup_file},
		primary_source_file => $attribs{primary_source_file},
		type => 'TkWidget',
		name => $attribs{name},
	};

	#Bless early so we can get access to object methods
	bless $self, $class;

	$self->_populate(%attribs);
	$doc->dispose;
	
	$self->dirty(0);
	return $self;
}

##
#Accessors
##


##
#Methods
##

# MODINFO method collate_project Convert the project's data into a perl script (1=success/0=failure)
# MODINFO paramhash params
# MODINFO key save_as STRING Path to save the file to
# MODINFO retval BOOLEAN
sub collate_project {
	my($self, %params) = @_;

	#Create code for each source file
	my $source_files;
	$app->TRACE("Primary source is " . $self->primary_source_file, 1);
	$source_files .= $self->source_files($self->primary_source_file)->to_code(is_primary=>1);	
	foreach my $source_file ($self->source_files_values()) {
		next if $source_file->name eq $self->primary_source_file;
		$app->TRACE("Source file name is " . $source_file->name, 1);
		$source_files .= $source_file->to_code(is_primary=>0);
	}
	
	my $final_source .= qq|
# MODINFO dependency module Tk
use Tk;
$source_files
	|;
	$app->TRACE($final_source, 1);
	if ($params{save_as}) {
		$app->TRACE("Saving file as $params{save_as}", 1);
		write_file($params{save_as}, $final_source);
	}
	return 1;
}


1;
__END__


=head1 NAME

Guido::Project::TkWidget - Encapsulates Guido project information management and project creation functionality for projects meant to become Perl/Tk Widgets (perl modules, not scripts)

=head1 SYNOPSIS

  use Guido::Project::TkWidget;


=head1 DESCRIPTION

Guido::Project::TkWidget provides the functionality necessary to manage meta-data for a Guido project.  It also provides functions to import and save a project to a file.

=head1 INTERFACE

=head1 KNOWN ISSUES

None known at this time

=head1 AUTHOR

jtillman@bigfoot.com

=head1 SEE ALSO

perl(1).

=cut
