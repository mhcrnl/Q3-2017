# MODINFO module Guido::Project::TkApp Class for managing Guido projects intended to become Tk applications (Perl/Tk scripts)
package Guido::Project::TkApp;

# MODINFO dependency module strict
use strict;

# MODINFO dependency module vars
use vars qw(@ISA $VERSION);

# MODINFO dependency module Guido::Project
use Guido::Project;
# MODINFO dependency module Guido::PropertySource
use Guido::PropertySource;
# MODINFO parent_class Guido::PropertySource
@ISA = qw( Guido::Project Guido::PropertySource );

#use base is broken on linux, or at least ->isa doesn't work with it!
#use base qw/Guido::Project Guido::PropertySource/;

# MODINFO dependency module Class::DirtyMethodMaker
use Class::DirtyMethodMaker get_set => [ qw / working_dir name type primary_source_file file_path plugin_data / ];
# MODINFO dependency module Class::DirtyMethodMaker
use Class::DirtyMethodMaker hash => [qw / source_files used_modules required_files /];

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
# MODINFO dependency module Guido::Property
use Guido::Property;

use constant DEFAULT_TEMPLATE_DIR => 'Guido/Project/TkApp/templates';

my $app;


# MODINFO version 0.05
$VERSION = '0.05';

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
	type => 'TkApp',
	primary_source_file => $attribs{primary_source_file},
    };

    my %unblessed = %$self;
	
    #Generate main project file name
    $self->{working_dir} = catfile($attribs{working_dir}, $attribs{name});
    $self->{file_path} = catfile($self->{working_dir}, $self->{name} . ".gpj");

    $app = $attribs{app};
    TRACE("TkApp project class taking control.",1);
    TRACE("TkApp project file path is " . $self->{file_path},1);
	
	
    #Bless early for access to methods
    bless $self, $class;

    $self->_process_templates();
	
#    #Auto-generate the project files using the templates
#    # if the files don't already exist
#    if (!-e $self->{file_path}) {
#	my($tpl_path) = $self->_findINC("Guido/Project/TkApp/templates/");
#	TRACE("Template path is: " . $tpl_path, 1);
#	if (!$tpl_path) {
#	    ERROR(
#		title=>'Missing template',
#		text=>"Can't find template for projects of type " . 
#		  $self->{type}
#	    );
#	    return undef;
#	}
#	else {
#	    #Make sure working directory is created
#	    if (!-d $self->{working_dir}) {
#		$! = undef;
#		mkdir($self->{working_dir}, "0755");
#		if ($!) {
#		    ERROR(
#			title=>'Project initialization error',
#			text=>"Couldn't create directory " . 
#			  $self->{working_dir} . ":\n$!"
#		    );
#		    return undef;
#		}
#	    }

#	    #new Template method
#	    TRACE("Processing file new.tt", 1);
#	    my $code;
#	    my $tt = Template->new({
#		PRE_CHOMP=>1,
#		INCLUDE_PATH=>[Tk::findINC(DEFAULT_TEMPLATE_DIR)],
#	    });
#	    my $tpl_file = 'new.tt';
#	    $tt->process($tpl_file, $self, \$code) or die $tt->error();
#	    write_file($self->{working_dir} . $self->{name} . '.gpj',  $code);

	    #process each template in the directory and
	    # put the results in the working directory
#	    foreach my $file (read_dir($tpl_path)) {
#		TRACE("Processing file $file",1);
#		my $proj_file_text = Text::Template::fill_in_file(
#		    "$tpl_path/$file", 
#		    HASH => \%unblessed, 
#		    DELIMITERS => ['<%', '%>'],
#		);
#		my $file_path = Text::Template::fill_in_string(
#		    $file, 
#		    HASH => \%unblessed, 
#		);
#		write_file($self->{working_dir} . "/" . 
#			     $file_path, $proj_file_text);
#	    }
#	}
#    }

    bless $self, $class;
    $self->_load_project_xml(%attribs);
    TRACE("Project created successfully",1);
    return $self;
}

# MODINFO constructor load An alternate constructor for loading pre-existing projects
# MODINFO paramhash attribs
# MODINFO key doc XML::DOM::Document XML document with which to populate the object's data
# MODINFO key name STRING Name of the project
# MODINFO key working_dir STRING Path to the working directory for the project
# MODINFO key plugin_data HASHREF Plugin data to store for the project (optional)
# MODINFO key primary_source_file STRING Name of the source file that should become the primary (the form displayed when the script is first run)
# MODINFO key app Guido::Application Ref to the main Guido IDE

sub load {
    #This is an alternate constructor!
    # It's for loading pre-existing projects
    # from a file
    #Open a project file (xml) and create the project mngmt
    # objects
    my($class, %attribs) = @_;
    my $doc = $attribs{doc};

    $app = $attribs{app};
    TRACE("TkApp load routine taking control", 1);


    #Create the base project object
    my $self = {
	working_dir => $attribs{working_dir},
	file_path => $attribs{file_path},
	app => $attribs{app},
	startup_file => $attribs{startup_file},
	primary_source_file => $attribs{primary_source_file},
	type => 'TkApp',
	name => $attribs{name},
    };

    #Bless early so we can get access to object methods
    bless $self, $class;

    #Now populate the file object arrays
    foreach my $source_node ($doc->getElementsByTagName("SourceFile")) {
	#These are assumed values, others may exist and
	# are handled by looping over the XML attributes
	my $name = $source_node->getAttribute("name");
	my $file_path = $source_node->getAttribute("file_path");
	my $type = $source_node->getAttribute("type");
	
	my $xml_attribs = $source_node->getAttributes;
	my %file_atts;
	for(my $i=0;$i<$xml_attribs->getLength;++$i) {
	    my $attrib = $xml_attribs->item($i)->getName;
	    my $value = $xml_attribs->item($i)->getValue;
	    $file_atts{$attrib} = $value;
	}

	TRACE(Dumper(\%file_atts),1);
	TRACE("App ref is $app",1);
	TRACE("Project working dir is " . $self->{working_dir}, 1);
	
	#Clean up filename dots
	$name =~ s/\./_/g;
	$file_atts{name} =~ s/\./_/g;
	
	my $new_sourcefile = load Guido::SourceFile(
	    %file_atts, 
	    app=>$app, 
	    working_dir=>$self->{working_dir},
	    project_name => $self->name,
	 );

	if (!$new_sourcefile) {
	    ERROR(
		title=>'Error loading project',
		text=>"Couldn't create source file object for $name ($file_path): $!"
	    );
	    #return undef;
	}
	else {
	    TRACE("Adding source file object for $name ($file_path)",1);
	    $self->source_files(
		$name,
		$new_sourcefile,
	    );
	}
    }
	
    $self->_load_required_files(doc=>$doc);
    $self->_load_used_modules(doc=>$doc);
    $self->_load_support_files(doc=>$doc);
	
    my @plugin_data_node = $doc->getElementsByTagName("PluginData");
    $self->{plugin_data} = XMLin($plugin_data_node[0]->toString());

    #Cleanup DOM objects
    $doc->dispose;

    $self->dirty(0);

    return $self;
}

##
#Accessors
##

##
#Overrides Guido::PropertySource
##

# MODINFO method property_source_properties Returns an array of Guido::Property objects that represent the modifiable properties of the project
# MODINFO retval ARRAYREF
sub property_source_properties {
	my($self) = @_;
	return [
		new Guido::Property(
				    name => 'name', 
				    value => $self->name,
				    display_name => 'Name',
				    listeners => [$self],
				   ),
		new Guido::Property(
				    name => 'working_dir',
				    value => $self->working_dir,
				    display_name => 'Working Dir',
				    listeners => [$self],
				    ),
		new Guido::Property(
				    name => 'type',
				    value => $self->type,
				    display_name => 'Type',
				    listeners => [$self],
				   ),
		new Guido::Property(
				    name => 'primary_source_file',
				    value => $self->primary_source_file,
				    display_name => 'Primary Source File',
				    listeners => [$self],
				   ),
		new Guido::Property(
				    name => 'file_path',
				    value => $self->file_path,
				    display_name => 'File Path',
				    listeners => [$self],
				   ),
	];
}

# MODINFO method property_source_children Returns an array containing the source files that are managed by this particular project object
# MODINFO retval ARRAY
sub property_source_children {
	my($self) = @_;
	return $self->source_files_values;
}

# MODINFO method property_source_siblings Returns an array of other projects that are currently open in the IDE
# MODINFO retval ARRAY
sub property_source_siblings {
	my($self) = @_;
	my @projects = $app->projects_values;
	my @siblings;
	foreach my $project (@projects) {
		push(@siblings, $project) unless $project == $self;
	}
	return @siblings;
}

# MODINFO method property_change Callback used to notify the object that one of its property objects has been modified
# MODINFO param property_obj Guido::Property The object that has been modified
# MODINFO param old_value ANY The old value the property object had (the new one can be obtained from the property object itself)
# MODINFO retval BOOLEAN
sub property_change {
	my($self, $property_obj, $old_value) = @_;
	#print __PACKAGE__ . " property changed\n";
	my $property_name = $property_obj->name;
	$self->{$property_name} = $property_obj->value;
	return 1;
}

sub prop_options {
		
}

##
#Methods
##

# MODINFO method collate_project Convert the project's data into a perl script (1=success/0=failure)
# MODINFO paramhash params
# MODINFO key save_as STRING Path to save the file to
# MODINFO retval BOOLEAN
sub collate_project {
    my($self, %params) = @_;
    my $code;
    my $tt = Template->new({
	PRE_CHOMP=>1,
	INCLUDE_PATH=>[Tk::findINC(DEFAULT_TEMPLATE_DIR)],
    });
    my $tpl_file = 'collate.tt';
    $tt->process($tpl_file, {app=>$app, project=>$self}, \$code) or 
      die $tt->error();

    TRACE("Final code after collate is:\n" . $code, 1);
    if ($params{save_as}) {
	TRACE("Saving file as $params{save_as}", 1);
	write_file($params{save_as}, $code);
    }
    return 1;

}
sub collate_project_old {
    my($self, %params) = @_;

    #Create code for each source file
    my $source_files;
    TRACE("Primary source is " . $self->primary_source_file, 1);
    $source_files .= $self->source_files($self->primary_source_file)->to_code(is_primary=>1);	
    foreach my $source_file ($self->source_files_values()) {
	next if $source_file->name eq $self->primary_source_file;
	TRACE("Source file name is " . $source_file->name, 1);
	$source_files .= $source_file->to_code(is_primary=>0);
    }
	
    my $final_source .= qq|

# MODINFO dependency module Tk
use Tk;

$source_files

MainLoop;

	|;
    TRACE($final_source, 1);
    if ($params{save_as}) {
	TRACE("Saving file as $params{save_as}", 1);
	write_file($params{save_as}, $final_source);
    }
    return 1;
}


1;
__END__


=head1 NAME

Guido::Project::TkApp - Encapsulates Guido project information management and project creation functionality for projects meant to become Tk applications (perl scripts, not modules)

=head1 SYNOPSIS

  use Guido::Project::TkApp;


=head1 DESCRIPTION

Guido::Project provides the functionality necessary to manage meta-data for a Guido project.  It also provides functions to import and save a project to a file.

=head1 INTERFACE

=head1 KNOWN ISSUES

None known at this time.

=head1 AUTHOR

jtillman@bigfoot.com

=head1 SEE ALSO

perl(1).

=cut
