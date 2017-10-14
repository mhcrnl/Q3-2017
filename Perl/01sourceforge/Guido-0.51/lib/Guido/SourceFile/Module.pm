package Guido::SourceFile::Module;

use strict;

#Use base is broken on linux! or at least ->isa doesn't work with it
#use base qw/Guido::SourceFile Guido::PropertySource/;
use vars qw($VERSION @ISA @EXPORT @EXPORT_OK);

@ISA = ('Guido::SourceFile', 'Guido::PropertySource');

use Class::MethodMaker get_set => [ qw /
	name
	project_name
	working_dir
	type
	file_path
/];
use Tie::IxHash;
use Data::Dumper;
use File::Spec::Functions;
use File::Slurp;
use Cwd;
use XML::DOM;
use Text::Template;
use Tk::Text;
use Tk::DialogBox;

require Exporter;
require AutoLoader;

#@ISA = qw(Exporter AutoLoader);
# Items to export into callers namespace by default. Note: do not export
# names by default without a very good reason. Use EXPORT_OK instead.
# Do not simply export all your public functions/methods/constants.
@EXPORT = qw();

$VERSION = '0.01';
my $app;

# Preloaded methods go here.

#The SourceFile module doesn't require Guido to function, but can
# use the TRACE hook if requested...

sub new {
        my($class, %attribs) = @_;
	my $self = {
		project_name => $attribs{project_name},
		name => $attribs{name},
		working_dir=> $attribs{working_dir},
		file_path => $attribs{file_path},
		type => 'Module',
	};

	$app = $attribs{app} if $attribs{app};
	$self->{file_path} ||= $self->{name} . ".pm";

	#Start of new Module creation from template
	$app->TRACE("Source file type is " . $self->{type} . "\n",1);
	$app->TRACE("File path is " . $self->{file_path} . "\n",1);

	#Auto-generate the files using the templates
	# if the file don't already exist
	if (!-e $self->{file_path}) {
		my($tpl_path) = _findINC("Guido/SourceFile/" . $self->{type} . "/templates");
		$app->TRACE("Template path is: " . $tpl_path, 1);
		if (!$tpl_path) {
			$app->ERROR(
				title=>'Missing template',
				text=>"Can't find template for source files of type " .
				$self->{type}
			);
			return undef;
		}
		else {
			#Make sure working directory exists
			if (!-d $self->{working_dir}) {
				$app->ERROR(
					title=>'Source File initialization error',
					text=>"Directory does not exist: " . $self->{working_dir},
				);
				return undef;
			}

			#process each template in the directory and
			# put the results in the working directory
			foreach my $file (read_dir($tpl_path)) {
				$app->TRACE("Processing file $file",1);
				my $file_text = Text::Template::fill_in_file(
					"$tpl_path/$file",
					HASH => $self,
					DELIMITERS => ['<%', '%>'],
				);
				my $file_path = Text::Template::fill_in_string(
					$file,
					HASH => $self,
			#		#DELIMITERS => ['{', '}'],
				);
				$app->TRACE("Writing file " . $file_path, 1);
				write_file($self->{working_dir} . '/' . $file_path, $file_text);
				$app->TRACE("File path is $file_path",1);
				if ($file_path =~ /\.gui$/) {
					$self->{file_path} = $file_path;
				}
			}
		}
	}
	#End of new Module creation from template

	#Bless early for access to methods
	bless $self => $class;

	return $self;
}

sub load {
	#This constructor is for pre-existing files
	# It doesn't really load anything, but
	# follows the general naming convention used
	# elsewhere, such as the Project class...
	my($class, %attribs) = @_;
	my $self = {
		project_name => $attribs{project_name},
		name => $attribs{name},
		working_dir=> $attribs{working_dir},
		events_file_path => $attribs{events_file_path},
		type => 'Module',
	};

	$app = $attribs{app} if $attribs{app};
	bless $self => $class;

	return $self;
}


###########
#Accessors
###########

sub dirty {
	my ($self, $new) = @_;
	if(defined $new) {
		$self->{dirty} = $new;
		$app->TRACE("Setting dirty flag to value: $new",1);
	}
	$self->{dirty};
}

sub clear_dirty {
	my ($self) = @_;
	$self->{dirty} = undef;
}

#########
#Methods
#########
sub revert {
	#This pseudo-constructor is for returning the file object
	# to its persisted state without having to send
	# in the initializing data
	# It doesn't really load anything, but
	# follows the general naming convention used
	# elsewhere, such as the Project class...

	my($self, %params) = @_;

	$app->TRACE("Reverting to saved version", 1);
	$self->dirty(0);
	return $self;
}

sub get_sub_line {
	#Figure out the line # of a subroutine in the event file

}

sub menu {
	my($self) = @_;
	return [
		[Button => "Properties", -command => [\&_e_properties, $self]],
		[Button => "View final code", -command => [\&_e_view_code, $self]],
		[Button => "Edit code", -command => [\&_e_edit_source_file, $self]],
		[Button => "Set as primary", -command => [\&_e_set_primary, $self]],
		[Button => "Remove from project", -command => [\&_e_remove_from_project, $self]],
	];
}

#Convert our private data to an XML node for saving to a project file
sub to_node {
	my($self, %params) = @_;

	#xml_doc contains ref to the parent XML::DOM document
	my $xml_doc = $params{xml_doc};
	my $node = $xml_doc->createElement("SourceFile");
	$node->setAttribute("name", $self->name);
	$node->setAttribute("file_path", $self->file_path);
	$node->setAttribute("type", $self->type);
	return $node;
}

sub to_code {
	my($self, %params) = @_;
	return '';
}

sub save {
	my($self, %params) = @_;

        return 1;
}

sub edit {
	my($self, %params) = @_;

#	The original version of "edit" had just this one line
#		I don't think it was being used, but something might
#		break by my changing this...
#	return $self->_xml_to_gui(%params);

	$self->_e_open_source_file();

}

##
#Overloads Guido::PropertySource
##

sub property_source_name {
	my($self) = @_;
	return $self->name;
}

sub property_source_properties {
	my($self) = @_;
	return {
		Name => $self->name,
	};
}

sub property_source_change {
	my ($self, $item, $new_value) = @_;
	return 1;
}

sub property_source_parent {
	my($self) = @_;
	return $app->projects($self->project_name);
}

sub property_source_children {
	my($self) = @_;
	return ();
}


sub property_source_siblings {
	my($self) = @_;
	my @forms = $app->projects($self->project_name)->source_files_values;
	my @siblings;
	foreach my $form (@forms) {
		push(@siblings, $form) unless $form == $self;
	}
	return @siblings;
}

sub property_source_categories {
	my($self) = @_;
	return {
		Misc => [qw/Name/],
	};
}

#################
#Private methods
#################

#findINC stolen shamelessly from Tk.pm for independence
sub _findINC {
	my $file = join('/',@_);
	my $dir;
	$file  =~ s,::,/,g;
	foreach $dir (@INC) {
		my $path;
		return $path if (-e ($path = "$dir/$file"));
	}
	return undef;
}



################
#Event Handlers
################

sub _e_set_primary {
	Tk::Menu::Unpost();
	my($self) = @_;
	$app->projects($self->project_name)->primary_source_file($self->name);
	$app->refresh();
}


sub _e_properties {
	Tk::Menu::Unpost();
	my($self) = @_;
	my $ppd = $app->mw->PropertyPageDialog(
		-widget_name => $self->name,
#		-append_props => {
#			Title => $self->title,
#			Name => $self->name,
#		},
		-append_props => $self->property_source_properties(),
	);
	my $props = $ppd->Show();
	$ppd->destroy;
	return if !$props;

	$app->TRACE("Form properties: " . Dumper(\$props), 1);

	#If our name wasn't changed, things are easy
	if ($props->{Name} eq $self->name) {
		$app->plugins("FormBuilder")->forms->{$self->name}->{title} = $props->{Title};
		$self->title($props->{Title});
		$self->dirty(1);
		return;
	}


	$app->projects($self->project_name)->source_files(
		$props->{Name},
		$self
	);
	$app->TRACE("Current name is " . $app->projects($self->project_name)->source_files($props->{Name})->name, 1);

	#Remove ourselves from the old name "slot" and
	# simulataneously insert ourselves in the new name's
	# "slot"
	$app->projects($self->project_name)->source_files(
		$props->{Name},
		delete $app->projects($self->project_name)->source_files->{$self->name}
	);

	#Change our name
	$self->name($props->{Name});
	$self->dirty(1);
	$app->refresh();
}

sub _e_view_code {
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
	$text->insert('end',$self->to_code());
	$dialog->Show();
}

sub _e_remove_from_project {
	Tk::Menu::Unpost();
	my($self) = @_;
	delete $app->projects($self->project_name)->{source_files}->{$self->name};
	$app->refresh();
	return $self;
}

sub _e_edit_source_file {
	Tk::Menu::Unpost();
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




# Autoload methods go after =cut, and are processed by the autosplit program.

1;
__END__
# Below is the stub of documentation for your module. You better edit it!

=head1 NAME

PackageName - Summary goes here

=head1 SYNOPSIS

  use PackageName;
  #detailed code usage goes here

=head1 DESCRIPTION

Detailed description goes here

=head1 KNOWN ISSUES

Known issues should be listed here

=head1 AUTHOR

author@sourceforge.net

=head1 SEE ALSO

perl(1).

=cut
