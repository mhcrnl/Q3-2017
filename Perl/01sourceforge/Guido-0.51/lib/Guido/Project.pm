# MODINFO module Guido::Project  Base project management object for Guido
package Guido::Project;

# MODINFO dependency module strict
use strict;
# MODINFO dependency module vars
use vars qw($VERSION @ISA @EXPORT @EXPORT_OK);

# MODINFO dependency module Class::DirtyMethodMaker
use Class::DirtyMethodMaker get_set => [ qw / working_dir name type primary_source_file file_path plugin_data startup_file / ];
# MODINFO dependency module Class::DirtyMethodMaker
use Class::DirtyMethodMaker hash => [qw / source_files used_modules required_files support_files /];

# MODINFO dependency module Exporter
require Exporter;
# MODINFO dependency module AutoLoader
require AutoLoader;

# MODINFO dependency module XML::DOM
use XML::DOM;
# MODINFO dependency module XML::Simple
use XML::Simple;
# MODINFO dependency module Template
use Template;
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
# MODINFO dependency module Guido::RequiredFile
use Guido::RequiredFile;
# MODINFO dependency module Guido::SupportFile
use Guido::SupportFile;
# MODINFO dependency module Guido::UsedModule
use Guido::UsedModule;
# MODINFO dependency module Guido::PropertySource
use Guido::PropertySource;
# MODINFO dependency module Guido::Property
use Guido::Property;
my $app;

# MODINFO parent_class Guido::PropertySource
@ISA = qw(Exporter AutoLoader Guido::PropertySource);
# Items to export into callers namespace by default. Note: do not export
# names by default without a very good reason. Use EXPORT_OK instead.
# Do not simply export all your public functions/methods/constants.
@EXPORT = qw();

# MODINFO version 0.05
$VERSION = '0.05';


# Preloaded methods go here.
##
#Independent debug/error code
##
my $DEBUG;
# MODINFO function TRACE
sub TRACE {
	if($app) {
		$app->TRACE(@_);
	}
	else {
		print $_[0] . "\n" if $DEBUG;
	}
}

# MODINFO function ERROR
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
# MODINFO key app      Guido::Application Ref to the IDE
# MODINFO key type                STRING  Type of project
# MODINFO key file_path           STRING  Path to the project definition file
# MODINFO key working_dir         STRING  Working directory for this project
# MODINFO key plugin_data         HASHREF Hash ref of plugin data specific to this project
# MODINFO key primary_source_file STRING  Name of the primary source file for this project
sub new {
	my($class, %attribs) = @_;	

	#The constructor attempts to create an object of the
	# appropriate subclass, but returns its own version of
	# the class if that fails
	my $subclass_obj;
	$app = $attribs{app};
	if ($attribs{type}) {
		#print "Loading $attribs{type} class\n";
		eval {
			require "Guido/Project/$attribs{type}.pm";
			$subclass_obj = "Guido::Project::$attribs{type}"->new(%attribs);
		};	
	}	

	if ($@) {
		$app->TRACE("Error loading project class $attribs{type}: $@", 1);
	}

	if ($@ and !$subclass_obj) {
		$app->ERROR(text=>"Error loading $attribs{name} ($attribs{file_path}): \n$@");
		return undef;
	}

	if ($@ or !$attribs{type}) {
		#print "$@\n";
		my $self = {
			name => $attribs{name},
			working_dir => $attribs{working_dir},
			app => $attribs{app},
			plugin_data => ($attribs{plugin_data} or {}),
			type => ($attribs{type} or "TK_APP"),
			primary_source_file => $attribs{primary_source_file},
		};
			
		return bless $self, $class;
	}
	else {
		return $subclass_obj;
	}
}

# MODINFO method load Alternate constructor for pre-existing projects
# MODINFO paramhash attribs
# MODINFO key app        Reference to the IDE
# MODINFO key file_path  Path to the project file
# MODINFO key type       Type of project
sub load {
	#This is an alternate constructor!
	# It's for loading pre-existing projects
	# from a file
	my($class, %attribs) = @_;
	$app = $attribs{app};

	#Open a project file (xml) and create the project mngmt
	# objects
	if (!-e $attribs{file_path}) {
		ERROR(text=>"File not found: " . $attribs{file_path});
		return undef;
	}

	#The parse may fail if XML is not well-formed
	# There is currently no DTD or Schema validation
	my $parser = new XML::DOM::Parser;
	my $doc;
	eval {
		$doc = $parser->parsefile($attribs{file_path});
	};
	if ($@ or !$doc) {
		ERROR(text=>"Invalid project file format: Basic XML parse error: $@",1);
		return undef;
	}

	#Get the project node
	my $project_nodes = $doc->getElementsByTagName("Project");
	if (!$project_nodes or $project_nodes->getLength == 0) {
		ERROR(text=>"Invalid project file format: No <project> section",1);
		return undef;
	}

	#Pick up basic attributes
	my $project_node = $project_nodes->item(0);
	my $project_version = $project_node->getAttribute("version");
	if (!$project_version or $project_version < $VERSION) {
		ERROR(text=>"This project format ($project_version) is not compatible with this version of Guido's Project subsystem ($VERSION).");
		return undef;
	}
	my $project_name = $project_node->getAttribute("name");
	my $project_type = $project_node->getAttribute("type");
	my $working_dir = dirname($attribs{file_path});
	my $startup_file = $project_node->getAttribute("startup_file");
	my $primary_source_file = $project_node->getAttribute("primary_source_file");

	#Create the data structure
	my $self = {
		working_dir => $working_dir,
		file_path => $attribs{file_path},
		app => $attribs{app},
		startup_file => $startup_file,
		primary_source_file => $primary_source_file,
		type => $project_type,
		name => $project_name,
		doc => $doc,
	};

	#The constructor attempts to create an object of the
	# appropriate subclass, but returns its own version of
	# the class if that fails
	my $subclass_obj;
	
	#Take what we got from the XML file, and pretend it's parameters
	# given to the constructor
	%attribs = %$self;
	
	#Now attempt to get the subclass object
	if ($attribs{type}) {
		$app->TRACE("Loading $attribs{type} class\n", 1);
		eval {
			require "Guido/Project/$attribs{type}.pm";
			$subclass_obj = "Guido::Project::$attribs{type}"->load(%attribs);
		};	
	}	

	if ($@ and !$subclass_obj) {
		$app->ERROR(text=>"Error loading $attribs{name} ($attribs{file_path}): \n$@");
		return undef;
	}

	if (!$@ and $attribs{type}) {
		return $subclass_obj;
	}

	
	#If we reach this point, no project type was found or an error occurred
	# We use the default load routine as a last resort


	#Bless so we can get access to object methods
	bless $self => $class;
	$self->_populate(%attribs);
	$doc->dispose();
	return $self;
}

sub _process_templates {
  my($self) = @_;
  my $output;
  my $module_path = ref($self);
  $module_path =~ s|::|/|g;
  my $tpl_path = $self->_findINC($module_path . "/templates/");

  my $tt = Template->new({
    PRE_CHOMP    => 1,
    INCLUDE_PATH => [$tpl_path],
    OUTPUT_PATH  => $self->{working_dir},
  });

  TRACE("Template path is: " . $tpl_path, 1);
  if (!-d$tpl_path) {
    ERROR(
      title => 'Missing template',
      text  => 'Can\'t find template for projects of type ' . $self->{type}
    );
    return 0;
  }
  else {
    #Make sure working directory is created
    if (!-d $self->{working_dir}) {
      $! = undef;
      mkdir($self->{working_dir}, 0755);
      if ($!) {
	ERROR(
          title => 'Project initialization error',
	  text  => "Couldn't create directory " . $self->{working_dir} . 
	    ":\n$!"
	);
	return 0;
      }
    }

    my $tpl_file = 'new.tt';
    $tt->process($tpl_file, $self, \$output) or die $tt->error();
    write_file($self->{working_dir} . $self->{name} . '.gpj',  $output);
#	$self->_load_project_xml(%attribs);
    return 1;
  }
}

sub _populate {

        my($self, %params) = @_;
	my $doc = $params{doc};
	
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
#		TRACE("App ref is $app",1);
#		TRACE("Project working dir is " . $self->{working_dir}, 1);
		
		my $new_sourcefile = load Guido::SourceFile(
			doc => $source_node,
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
#	print "Loaded used modules\n";
	$self->_load_support_files(doc=>$doc);
#        print "Loaded support files\n";
	
	#foreach my $required_node ($doc->getElementsByTagName("RequiredFile")) {
	#	$self->required_files(
	#		$required_node->getAttribute("name"),
	#		$required_node->getAttribute("file_path"),
	#	);
	#}
	
	
	my @plugin_data_node = $doc->getElementsByTagName("PluginData");
	$self->{plugin_data} = XMLin($plugin_data_node[0]->toString());

	$self->dirty(0);
	return 1;
}

sub _load_required_files {
	my ($self, %params) = @_;
	my $doc = $params{doc};

	foreach my $req_node ($doc->getElementsByTagName("RequiredFile")) {
		#These are assumed values, others may exist and
		# are handled by looping over the XML attributes
		my $name = $req_node->getAttribute("name");
		my $file_path = $req_node->getAttribute("file_path");
		my $type = $req_node->getAttribute("type");
		
		my $xml_attribs = $req_node->getAttributes;
		my %file_atts;
		for(my $i=0;$i<$xml_attribs->getLength;++$i) {
			my $attrib = $xml_attribs->item($i)->getName;
			my $value = $xml_attribs->item($i)->getValue;
			$file_atts{$attrib} = $value;
		}

		TRACE(Dumper(\%file_atts),1);

		#Clean up filename dots
		$name =~ s/\./_/g;
		$file_atts{name} =~ s/\./_/g;
		
		my $new_reqfile = load Guido::RequiredFile(
                        node => $req_node,
			%file_atts, 
			app=>$app, 
			working_dir=>$self->{working_dir},
			project_name => $self->name,
		);

		if (!$new_reqfile) {
			ERROR(
				title=>'Error loading project',
				text=>"Couldn't create source file object for $name ($file_path): $!"
			);
			#return undef;
		}
		else {
			TRACE("Adding req file object for $name ($file_path)",1);
	
			$self->required_files(
				$name,
				$new_reqfile,
			);
		}
	}

}



sub _load_used_modules {
	my ($self, %params) = @_;
	my $doc = $params{doc};
	$app->TRACE("Loading used modules", 1);

	foreach my $mod_node ($doc->getElementsByTagName("UsedModule")) {
		#These are assumed values, others may exist and
		# are handled by looping over the XML attributes
		my $name = $mod_node->getAttribute("name");
		my $package = $mod_node->getAttribute("package");
		my $imports = $mod_node->getAttribute("imports");
		
		my $xml_attribs = $mod_node->getAttributes;
		my %file_atts;
		for(my $i=0;$i<$xml_attribs->getLength;++$i) {
			my $attrib = $xml_attribs->item($i)->getName;
			my $value = $xml_attribs->item($i)->getValue;
			$file_atts{$attrib} = $value;
		}

		TRACE("Used module attribs:\n" . Dumper(\%file_atts),1);

		my $new_usedmod = load Guido::UsedModule(
                        node => $mod_node,
			%file_atts, 
			app=>$app, 
			working_dir=>$self->{working_dir},
			project_name => $self->name,
		);

		if (!$new_usedmod) {
			ERROR(
				title=>'Error loading project',
				text=>"Couldn't create used mod object for $name ($package): $!"
			);
			#return undef;
		}
		else {
			TRACE("Adding used mod object for $name ($package)",1);
	
			$self->used_modules(
				$name,
				$new_usedmod,
			);
		}
	}

}

sub _load_support_files {
	my ($self, %params) = @_;
	my $doc = $params{doc};
	$app->TRACE("Loading support files", 1);

	foreach my $sf_node ($doc->getElementsByTagName("SupportFile")) {
		#These are assumed values, others may exist and
		# are handled by looping over the XML attributes
		my $name = $sf_node->getAttribute("name");
		
		my $xml_attribs = $sf_node->getAttributes;
		my %file_atts;
		for(my $i=0;$i<$xml_attribs->getLength;++$i) {
			my $attrib = $xml_attribs->item($i)->getName;
			my $value = $xml_attribs->item($i)->getValue;
			$file_atts{$attrib} = $value;
		}

		TRACE("Support file attribs:\n" . Dumper(\%file_atts),1);

		my $new_sf = load Guido::SupportFile(
                        node => $sf_node,
			%file_atts, 
			app=>$app, 
			working_dir=>$self->{working_dir},
			project_name => $self->name,
		);

		if (!$new_sf) {
			ERROR(
				title=>'Error loading project',
				text=>"Couldn't create support file object for $name: $!"
			);
			#return undef;
		}
		else {
			TRACE("Adding used support file $name",1);
	
			$self->support_files(
				$name,
				$new_sf,
			);
		}
	}

}



##
#Accessors
##

#
#I'm not sure the project object should be able to collate itself,
# because it requires displaying a GUI for entering the file name.
# Then again, shouldn't it have the intelligence for allowing the
# user to do so?
#
#
#sub menu {
#	my($self) = @_;
#	return [
#		[Button => "Properties", -command => [\&_e_properties, $self]],
#		[Button => "Save", -command => [\&save_project, $self]],
#		[Button => "Close", -command => [\&_e_close, $self]],
#		[Button => "Add", -command => [\&_e_close, $self]],
#	];
#}

##
#Overrides Guido::PropertySource
##
sub property_source_properties {
	my($self) = @_;
	return [
		new Guido::Property(
				    name => 'name', 
				    value => $self->name,
				    default_value => $self->name,
				    display_name => 'Name',
				    listeners => [$self],
				   ),
		new Guido::Property(
				    name => 'working_dir',
				    value => $self->working_dir,
				    default_value => $self->working_dir,
				    display_name => 'Working Dir',
				    listeners => [$self],
				    ),
		new Guido::Property(
				    name => 'type',
				    value => $self->type,
				    default_value => $self->type,
				    display_name => 'Type',
				    listeners => [$self],
				   ),
		new Guido::Property(
				    name => 'primary_source_file',
				    value => $self->primary_source_file,
				    default_value => $self->primary_source_file,
				    display_name => 'Primary Source File',
				    listeners => [$self],
				   ),
		new Guido::Property(
				    name => 'file_path',
				    value => $self->file_path,
				    default_value => $self->file_path,
				    display_name => 'File Path',
				    listeners => [$self],
				   ),
	];
}

sub property_source_children {
	my($self) = @_;
	return $self->source_files_values;
}

sub property_source_siblings {
	my($self) = @_;
	my @projects = $app->projects_values;
	my @siblings;
	foreach my $project (@projects) {
		push(@siblings, $project) unless $project == $self;
	}
	return @siblings;
}

sub property_change {
	my($self, $property_obj, $old_value) = @_;
	#print __PACKAGE__ . " property changed\n";
	my $property_name = $property_obj->name;
	$self->{$property_name} = $property_obj->value;
	return 1;
}

sub prop_options {
		
}

sub property_source_name {
	my($self) = @_;
	return $self->name;
}

##
#Methods
##

# MODINFO method save_project Saves the project to file
sub save_project {
	my($self, %params) = @_;

	#Have each sub-file save itself
	foreach my $source_file ($self->source_files_values()) {
		$source_file->save();
	}

	#Generate an XML document based on the project object's
	# contents
	TRACE("Self is $self",1);
	my $xml = ${$self->_to_xml()};
	TRACE("File path is " . $self->{file_path} . "\n");
	TRACE($xml,1);
	
	#Persist the XML stream to the save_as or file_path
	open (OUT, ">" . $self->{file_path}) or die "Couldn't open " . $self->{file_path} . " for saving\n";
	print OUT $xml;
	close(OUT);	
	return 1;
}

# MODINFO method collate_project Turns the project data into a runnable perl script
# MODINFO paramhash params
# MODINFO key save_as File path to which it should save the perl script
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

MainLoop;

	|;
	$app->TRACE($final_source, 1);
	if ($params{save_as}) {
		$app->TRACE("Saving file as $params{save_as}", 1);
		write_file($params{save_as}, $final_source);
	}
	return 1;
}

sub _to_xml {
	my ($self) = @_;

	#Create Base XML document
	my $doc = XML::DOM::Document->new();

	#Create the base object structure
	my $decl = $doc->createXMLDecl("1.0");
	$doc->setXMLDecl($decl);
	#my $doctype = $doc->createDocumentType("guidoProject");
	#$doctype->setSysId("guidoProject.dtd");
	#$doc->setDoctype($doctype);
	
	#Create the starting container nodes
	my $proj_node = $doc->createElement("Project");
	$proj_node->setAttribute("name", $self->{name});
	$proj_node->setAttribute("type", $self->{type});
	$proj_node->setAttribute("version", $VERSION);
	$proj_node->setAttribute("startup_file", $self->{startup_file});
	$proj_node->setAttribute("primary_source_file", $self->{primary_source_file});
	$proj_node->setAttribute("working_dir", $self->{working_dir});

	my $files_node = $doc->createElement("Files");
	my $src_files_node = $doc->createElement("SourceFiles");
	while( my($name, $sf_ref) = each %{$self->source_files}) {
		$src_files_node->appendChild($sf_ref->to_node(xml_doc=>$doc));
	}

	my $used_mods_node = $doc->createElement("UsedModules");
	while( my($name, $um_ref) = each %{$self->used_modules}) {
		$used_mods_node->appendChild($um_ref->to_node(xml_doc=>$doc));
	}


	my $req_files_node = $doc->createElement("RequiredFiles");
	while( my($name, $rf_ref) = each %{$self->required_files}) {
		$req_files_node->appendChild($rf_ref->to_node(xml_doc=>$doc));
	}

	my $supp_files_node = $doc->createElement("SupportFiles");
	while( my($name, $sf_ref) = each %{$self->support_files}) {
		$supp_files_node->appendChild($sf_ref->to_node(xml_doc=>$doc));
	}	

	my $plugins_node = $doc->createElement("Plugins");
	
	my $parser = new XML::DOM::Parser;
	#We use XML::Simple to create the plugin data to remain compatible with
	# the App level plugin data hash.  It's easier, anyway.
	my $plugin_data_doc = $parser->parse(XMLout($self->{plugin_data}, rootname=>'PluginData'));
	my $plugin_data_node = $plugin_data_doc->getFirstChild();
	TRACE($plugin_data_node->toString(), 1);
	$plugin_data_node->setOwnerDocument($doc);
	
	#Append the two primary sub-nodes to the project
	$doc->appendChild($proj_node);
	$proj_node->appendChild($files_node);
	$proj_node->appendChild($plugins_node);
	$proj_node->appendChild($plugin_data_node);
	
	#Append the file sub-types to the files node
	$files_node->appendChild($src_files_node);
	$files_node->appendChild($used_mods_node);
	$files_node->appendChild($req_files_node);
	$files_node->appendChild($supp_files_node);

	my $doc_text = $doc->toString();
	$doc->dispose();
	$doc_text =~ s/(\>)/$1\n/g;

	return \$doc_text;
}


#findINC stolen shamelessly from Tk.pm for independence
sub _findINC {
	my $self = shift(@_);
	my $file = join('/',@_);
	my $dir;
	$file  =~ s,::,/,g;
	foreach $dir (@INC) {
		my $path;
		return $path if (-e ($path = "$dir/$file"));
	}
	return undef;
}

sub _load_project_xml {
	my($self, %params) = @_;
	my $parser = new XML::DOM::Parser;
	my $doc = $parser->parsefile($self->{file_path});
	
	my $project_name = $doc->getFirstChild->getAttribute("name");
	my $project_type = $doc->getFirstChild->getAttribute("type");
	my $working_dir = dirname($self->{file_path});

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

		#print Dumper \%file_atts;
				
		my $new_sourcefile = load Guido::SourceFile(
			%file_atts,
			app=>$app, 
			working_dir=>$self->working_dir,
		);

		if (!$new_sourcefile) {
			ERROR(
				title=>'Error loading project',
				text=>"Couldn't create source file object for $name ($file_path): $!"
			);
			return undef;
		}

		TRACE("Adding source file object for $name ($file_path)",1);

		$self->source_files(
			$name,
			$new_sourcefile,
		);
	}
	
	#foreach my $required_node ($doc->getElementsByTagName("RequiredFile")) {
	#	$self->required_files(
	#		$required_node->getAttribute("name"),
	#		$required_node->getAttribute("file_path"),
	#	);
	#}
	
	#foreach my $used_node ($doc->getElementsByTagName("UsedModule")) {
	#	$self->used_modules(
	#		$used_node->getAttribute("name"),
	#		$used_node->getAttribute("name")
	#	) if $used_node->getAttribute("name") ne "";
	#}
	
	my @plugin_data_node = $doc->getElementsByTagName("PluginData");
	$self->{plugin_data} = XMLin($plugin_data_node[0]->toString());
	$doc->dispose();
}

##
#Event handlers
##
=for comment

sub file_mod_check {
	 "Callback was called...\n";
	my $comp_stat = stat($file_path);
	print $file_stat->size . ":" . $comp_stat->size . "\n";
	if (
		$comp_stat->mode  != $file_stat->mode or
		$comp_stat->size  != $file_stat->size or
		$comp_stat->atime != $file_stat->atime or
		$comp_stat->mtime != $file_stat->mtime
	) {
		print "File changed\n";
		$file_stat = $comp_stat;	
	}
}

=cut

1;
__END__

=head1 NAME

Guido::Project - Encapsulates Guido project information management and project creation functionality

=head1 SYNOPSIS

  use Guido::Project;
  my $proj = new Guido::Project(
    app => $app,
    type => 'TkWidget',
    file_path => '/home/jtillman/projects/MyProject/MyProject.gpj',
  );

  $proj->collate_project(save_as=>'MyProject.pl');
  $proj->save_project();

=head1 DESCRIPTION

Guido::Project provides the functionality necessary to manage meta-data for a Guido project.  It also
provides functions to import and save a project to a file.

=head1 INTERFACE

=head1 KNOWN ISSUES

Known issues should be listed here

=head1 AUTHOR

jtillman@bigfoot.com

=head1 SEE ALSO

perl(1).

=cut
