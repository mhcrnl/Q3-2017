# MODINFO module Guido::SourceFile Class for managing perl source files
package Guido::SourceFile;

# MODINFO dependency module strict
use strict;
# MODINFO dependency module vars
use vars qw($VERSION @ISA @EXPORT @EXPORT_OK);

# MODINFO dependency module Class::MethodMaker
use Class::MethodMaker get_set => [ qw / name type file_path / ];

# MODINFO dependency module XML::DOM
use XML::DOM;
# MODINFO dependency module File::Slurp
use File::Slurp;


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
# MODINFO key name STRING Name of the source file
# MODINFO key app Guido::Application Ref to the main IDE object
# MODINFO key type STRING Type of source file being managed
# MODINFO key file_path STRING File path to the source file
# MODINFO key working_dir STRING Directory in which the source file resides
# MODINFO key project_name STRING Name of project with which this source file is associated
sub new {
	my($class, %attribs) = @_;

	$app = $attribs{app};

	#The constructor attempts to create an object of the
	# appropriate subclass, but returns its own version of
	# the class if that fails
	my $subclass_obj;
	if ($attribs{type}) {
		#print "Loading $attribs{type} class\n";
		eval {
			require "Guido/SourceFile/$attribs{type}.pm";
			$subclass_obj = "Guido::SourceFile::$attribs{type}"->new(%attribs);
		};	
	}	

	if ($@) {
		TRACE("Error loading sourcefile class $attribs{type}: $@", 1);
	}

	if ($@ and !$subclass_obj) {
		ERROR(text=>"Error loading $attribs{name} ($attribs{file_path}): \n$@");
		return undef;
	}

	if ($@ or !$attribs{type}) {
		#print "$@\n";
		my $self = {
			app => $app,
			project_name => $attribs{project_name},
			working_dir => $attribs{working_dir},
			name => $attribs{name},
			file_path => $attribs{file_path},
			type => $attribs{type},
		};
			
		return bless $self, $class;
	}
	else {
		TRACE("Successful load of sourcefile sub-class $attribs{type}", 1);
		return $subclass_obj;
	}
}

# MODINFO constructor load
# MODINFO paramhash attribs
# MODINFO key name           STRING Name of the source file
# MODINFO key node           XML::DOM::Node Ref to the XML node to be used to populate the object
# MODINFO key app            Guido::Application Ref to the main IDE object
# MODINFO key type           STRING Type of source file being managed
# MODINFO key file_path      STRING File path to the source file
# MODINFO key working_dir    STRING Directory in which the source file resides
# MODINFO key project_name   STRING Name of project with which this source file is associated
sub load {
	my($class, %attribs) = @_;

	$app = $attribs{app};
	my $node = $attribs{node};

	#The constructor attempts to create an object of the
	# appropriate subclass, but returns its own version of
	# the class if that fails
	my $subclass_obj;
	if ($attribs{type}) {
		TRACE("Loading $attribs{type} class\n", 1);
		eval {
			require "Guido/SourceFile/$attribs{type}.pm";
			$subclass_obj = "Guido::SourceFile::$attribs{type}"->load(node=>$node,%attribs);
		};	
	}	

	if ($@ and !$subclass_obj) {
		ERROR(text=>"Error loading $attribs{name} ($attribs{file_path}): \n$@");
		return undef;
	}

	if ($@ or !$attribs{type}) {
		TRACE("Error loading $attribs{type}: $@",1) if $@;
		TRACE("No sourcefile type provided, using default",1) if !$attribs{type};

		my $self = {
		        project_name => $attribs{project_name},
                        name         => $node->getAttribute("node_name"),
			file_path    => $node->getAttribute("file_path"),
			working_dir  => $node->getAttribute("working_dir"),
			type         => $node->getAttribute("type"),
		};

#		my $self = {
#			project_name => $attribs{project_name},
#			name => $attribs{name},
#			file_path => $attribs{file_path},
#			working_dir=> $attribs{working_dir},
#			type => $attribs{type},
#			geo_mgr_type => $attribs{geo_mgr_type},
#		};
			
#		return bless $self, $class;
		bless $self => $class;
		TRACE("Types of files I can create are: " . join(", ", $self->types),1);
		return $self;
	}
	else {
		TRACE("Types of files I can create are: " . join(", ", $class->types),1);
		return $subclass_obj;
	}
}

# MODINFO method types Return the types of source files that can be managed by this class
# MODINFO retval ARRAY
sub types {
	my $template_path = Tk::findINC("Guido/SourceFile");
	my @file_types = ();
#	$app->TRACE("Templates path is $template_path",1);
#	foreach my $candidate (read_dir($template_path)) {
#		my $full_path = "$template_path/$candidate/template.xml";
#		$app->TRACE("Full path for $candidate is $full_path",1);
#		push(@file_types, $candidate) if -e $full_path;
#	}
#	return @file_types;	
#	return grep {-d "$template_path/$_"} read_dir($template_path);
	return qw/ TkComposite TkForm /;
}

# MODINFO function get_sub_line Figures out the line # of a subroutine in the file (or at least it should.  Right now, it's unimplemented)
sub get_sub_line {
	#Figure out the line # of a subroutine in the file
}

#A debugging routine
# MODINFO method to_string Convert the object to a string representation using Data::Dumper
# MODINFO retval STRING
sub to_string {
    my($self) = @_;
    return Dumper($self);
}

# MODINFO method save_gui Persist the object to a file
# MODINFO paramhash params
# MODINFO key save_as STRING Path to save the file to (optional)
# MODINFO key gui HASHREF Structure representing the GUI to be saved
sub save_gui {
	my($self, %params) = @_;

	#save_as allows us to save to a different path
	$self->{file_path} = $params{save_as} if $params{save_as};

	#Generate an XML document based on the sourcefile object's
	# contents
	TRACE("Self is $self",1);
	my $xml = $self->_gui_to_xml(gui=>$params{gui});
	return 0 if !$xml;
#	TRACE("File path is " . $self->{file_path} . "\n");
#	TRACE($xml,1);
	
	#Persist the XML stream to the save_as or file_path
	open (OUT, ">" . $self->{file_path}) or die "Couldn't open " . $self->{file_path} . " for saving\n";
	print OUT $xml;
	close(OUT);	
	return 1; 
}

sub _gui_to_xml {
	my ($self, %params) = @_;
#	if ($params{document_node}) {print "Document is: \n" . $params{document_node}->toString() . "\n"}
	my $gui = $params{gui} or return 0;
	my $top_node;
	my $doc;
	
	if ($params{document_node}) {
		my $parent_node = $params{document_node};
#		print "Creating element " . $gui->{type} . "\n";
		$top_node = $parent_node->getOwnerDocument->createElement($gui->{type});
		$parent_node->appendChild($top_node);

		my $w = $gui;
#		print "$params{name}\'s widget hash is $w\n";
		#Set the name of widget
		$top_node->setAttribute('name', $params{name});
		
		#Get the geometry manager and its parameters
		my $geo_type = delete $w->{geo_mgr}->{type};
		my @geo_params;
		while( my($param, $value) = each %{$w->{geo_mgr}}) {
			push(@geo_params, "$param=$value");
		}
		my $geo_params = join(";", @geo_params);
#		print "Geo mgr: $geo_type->$geo_params\n";
		$top_node->setAttribute($geo_type, $geo_params);
		
		#Fill in the usual Tk attributes as tag attributes
		foreach my $attrib (keys %$w) {
			next if $attrib =~ /^(children|params|ref|type|geo_mgr)$/i;
#			print "Setting attrib: $attrib\n";
			$top_node->setAttribute($attrib, $w->{$attrib});
		}

		foreach my $attrib (keys %{$w->{params}}) {
#			print "Setting attrib: $attrib\n";
			$top_node->setAttribute($attrib, $w->{params}->{$attrib});
		}
	
		foreach my $child (keys %{$w->{children}}) {
			$self->_gui_to_xml(
				gui=>$w->{children}->{$child}, 
				document_node=>$top_node,
				name=>$child,
			);
		}
	}
	else {
		#Create Base XML document
		$doc = XML::DOM::Document->new();
	
		#Create the base object structure
		my $decl = $doc->createXMLDecl("1.0");
		$doc->setXMLDecl($decl);
		#my $doctype = $doc->createDocumentType("guidoProject");
		#$doctype->setSysId("guidoProject.dtd");
		#$doc->setDoctype($doctype);

		#Create the starting container nodes
		#print "Creating top element " . $self->{type} . "\n";
		my $main_node = $doc->createElement($self->{type});		
		$doc->appendChild($main_node);
		
		#Loop over each widget in the collection
		foreach my $widget (keys %$gui) {
			my $top_node = $main_node->getOwnerDocument->createElement($gui->{$widget}->{type});
			$main_node->appendChild($top_node);
			
			my $w = $gui->{$widget};
			#print "$widget\'s widget hash is $w\n";
			#Get the geometry manager and its parameters
			my $geo_type = delete $w->{geo_mgr}->{type};
			my @geo_params;
			while( my($param, $value) = each %{$w->{geo_mgr}}) {
				push(@geo_params, "$param=$value");
			}
			my $geo_params = join(";", @geo_params);
			#print "Geo mgr: $geo_type->$geo_params\n";
			$top_node->setAttribute($geo_type, $geo_params);
			
			#Fill in the usual Tk attributes as tag attributes
			foreach my $attrib (keys %$w) {
				next if $attrib =~ /^(children|params|ref|type|geo_mgr)$/i;
				#print "Setting attrib: $attrib\n";
				$top_node->setAttribute($attrib, $w->{$attrib});
			}
		
			foreach my $child (keys %{$w->{children}}) {
				$self->_gui_to_xml(
					gui=>$w->{children}->{$child}, 
					document_node=>$top_node,
					name=>$child,
				);
			}
		}
	}


	if (!$params{document_node}) {
		my $doc_text = $doc->toString();
		$doc_text =~ s/(\>)/$1\n/g;
#		print "Returning $doc_text\n";
		return $doc_text;
	}
	else {
		return 1;
	}
}

#
# Event handlers (inherited by SourceFile modules)
#

sub _e_debug_dump {
    Tk::Menu::Unpost();
    my($self) = @_;
    TRACE($self->to_string, 1);
}

# Autoload methods go after =cut, and are processed by the autosplit program.

1;
__END__
# Below is the stub of documentation for your module. You better edit it!

=head1 NAME

Guido::SourceFile - Class for management of source files

=head1 SYNOPSIS

  use Guido::SourceFile;
  my $sf = new Guido::SourceFile(
      type         => 'TkComposite',
      name         => 'test',
      working_dir  => '/home/jtillman/MyProject/',
      app          => $app,
  )

=head1 DESCRIPTION

The SourceFile class is a class that delegates the management of source files to other classes.  If it files to find a suitable class for managing the source file in question, it attempts to provide a minimal management functionality itself.

=head1 INTERFACE

=head1 KNOWN ISSUES

None known at this time.

=head1 AUTHOR

jtillman@bigfoot.com

=head1 SEE ALSO

perl(1).

=cut
