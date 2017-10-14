# MODINFO module Guido::Plugin::Executor
package Guido::Plugin::Executor;
#require Guido::Plugin;

# MODINFO dependency module strict
use strict;

use Data::Dumper;

# MODINFO dependency module Config
use Config;
# MODINFO dependency module FileHandle
use FileHandle;
# MODINFO dependency module File::Spec::Functions
use File::Spec::Functions;
# MODINFO dependency module File::Basename
use File::Basename;
# MODINFO dependency module Data::Dumper
use Data::Dumper;

# MODINFO dependency module strict
use strict;
# MODINFO dependency module vars
use vars qw($VERSION @ISA @EXPORT @EXPORT_OK $priority);

my $app;
my $mime_maps;
my $mime_handlers;
my $plugin_data;

# MODINFO dependency module vars
use vars qw( @ISA );
# MODINFO dependency module Guido::Plugin
use Guido::Plugin;
# MODINFO parent_class Guido::Plugin
@ISA = qw( Guido::Plugin );

#use base qw/ Guido::Plugin/;

# Items to export into callers namespace by default. Note: do not export
# names by default without a very good reason. Use EXPORT_OK instead.
# Do not simply export all your public functions/methods/constants.
@EXPORT = qw();
@EXPORT_OK = qw();
# MODINFO version 0.01
$VERSION = '0.01';

BEGIN {  # Decide which module to use based on the operating system
  $| = 1;
  my $OS_win = ($^O eq "MSWin32") ? 1 : 0;
  if ($OS_win) { eval "use Win32::Process; use Win32; \$priority = Win32::Process::NORMAL_PRIORITY_CLASS;" }
  die "$@" if $@;
} 

##
#Constructor
##

# MODINFO constructor new
# MODINFO paramhash attribs
# MODINFO key working_dir STRING Directory in which set focus when launching processes
sub new {
	my($class, %attribs) = @_;	
	my $self = {
		working_dir => $attribs{working_dir},
		win32 => (($^O eq "MSWin32") ? 1 : 0),
	};

	return bless $self, $class;
}

##
#Executor-specific methods
##
# MODINFO method auto_launch Start up a file using the program associated with it through the mime-type mappings in Guido
# MODINFO paramhash params
# MODINFO key file STRING File to launch process for
# MODINFO retval 
sub auto_launch {
	my($self, %params) = @_;

	#Do a lookup in plugin data to get types and handlers
	my $mime_type = $self->get_mime_type(file=>$params{file});
	$app->TRACE("Mime type of file is $mime_type", 1);
	#Use the mime-type "default" if there isn't a handler for this
	# particular mime-type...
	my $app_path = $self->get_mime_handler(mime_type=>$mime_type) or
		$self->get_mime_handler(mime_type=>'default');
	if (!$app_path) {
		if (!$mime_type) {
			$app->ERROR(text=>"No mime-type defined for files of this type ($params{file}), and default handler is not defined.");
			return undef;
		}
		$app->ERROR(text=>"No handler defined for mime-type '$mime_type' and default handler is not defined.");
		return undef;
	}
	return $self->launch(path=>$app_path, parameters=>$params{file}, working_dir=>$params{working_dir});
}

# MODINFO method get_mime_type Lookup the mime-type of a particular file in the Guido configuration data
# MODINFO paramhash params
# MODINFO key file STRING Name of file to look up mime-type for
# MODINFO retval STRING
sub get_mime_type {
	my($self, %params) = @_;
	my $fullname = $params{file};
	my($name,$path,$suffix) = fileparse($fullname,qw/\..+$/);
	$app->TRACE("Name of file to execute is $name, suffix is $suffix",2);
	foreach my $type (@$mime_maps) {
		if ($type->{suffix} eq $suffix) {
			return $type->{mimetype};
		}
	}
	return undef;
}

# MODINFO method get_mime_handler Look up the registered handler for a particular mime-type in the Guido configuration
# MODINFO paramhash params
# MODINFO key mime_type Name of the mime_type to look up
# MODINFO retval STRING
sub get_mime_handler {
	my($self, %params) = @_;
	my $mime_type = $params{mime_type};
	foreach my $handler (@$mime_handlers) {
		if ($handler->{mimetype} eq $mime_type) {
			return $handler->{path};
		}
	}
	return undef;
}

# MODINFO method launch Startup the handler program for a particular file
# MODINFO paramhash params
# MODINFO key path STRING Path to the file
# MODINFO key working_dir STRING Working dir to start the process in
# MODINFO key parameters STRING Parameters to pass to the process
# MODINFO key handle BOOLEAN When true, the return value will be a Filehandle object opened either for output or input, depending on the value of the input parameter
# MODINFO key input BOOLEAN When true, the process is started up as a pipe for input, otherwise, it is started up for output
#MODINFO retval ANY
sub launch {
	my($self, %params) = @_;

	##
	#This call can return a typeglob (handle reference for piping),
	# a process object (for control of Win32 processes),
	# or a PID (for control of Unix processes
	##

	my $ret_val;
	my $path = canonpath($params{path});
	
	if ($path eq "perl") {$path = $Config{perlpath};}
	
	$params{working_dir} ||= $self->{working_dir};
	$params{working_dir} ||= ".";
	
	$app->TRACE("Working dir is $params{working_dir}",1);
	$app->TRACE("$path $params{parameters}",1);
	
	if ($params{handle}) {
		
		my $command  = "| " if !$params{input};
		$command .= $path . " " . $params{parameters};
		$command .= " |" if $params{input};
		
		my $ret_val = new FileHandle $command;
	}
	elsif ($params{exit_code}) {
		my $command  = "| " if !$params{input};
		$command .= $path . " " . $params{parameters};
		$command .= " |" if $params{input};
		
		my $ret_val = new FileHandle $command;
		
	}
	elsif ($self->{win32}) {
		#no strict subs;
		Win32::Process::Create(
			$ret_val,
			"$path",
			"Guido " . $params{parameters},
			0,
			$priority,
			$params{working_dir},
		);	
# MODINFO dependency module strict
		use strict;
	}
	else {
		my $orig_dir = chdir($params{working_dir});
		#I know this doesn't really return the PID, but
		# I'm going to figure it out sooner or later!
		$ret_val = system("$path $params{parameters} &");
		chdir($orig_dir);
	}
	return $ret_val;
}



##
#Required Plugin overrides
##

# MODINFO method init_plugin
# MODINFO param app_param Ref to the main Guido IDE
sub init_plugin {
	my($self, $app_param) = @_;
	$app = $app_param;
	$app->TRACE("Plugin initialized",1);
	$mime_maps = $app->{plugin_data}->{Executor}->{mimemaps}->{mimemap};
	$mime_handlers = $app->{plugin_data}->{Executor}->{mimehandlers}->{mimehandler};
	#print "\nRef is " . ref($mime_handlers) . "\n";
	#exit;
	$app->TRACE("Handlers: " . Dumper(\$mime_handlers), 10);
}

# MODINFO method place_menus
sub place_menus {}

# MODINFO method refresh
sub refresh {}

# MODINFO method editor
# MODINFO param parent_frame Tk::Frame Frame to create the editor in
# MODINFO param config HASHREF The Guido configuration data to use
# MODINFO retval Guido::Plugin::Executor::Editor
sub editor {
	my($self, $parent_frame, $config) = @_;
# MODINFO dependency module Guido::Plugin::Executor::Editor
	use Guido::Plugin::Executor::Editor;
	my $editor = Guido::Plugin::Executor::Editor->new(
		$parent_frame->DelegateFor('Construct'),
		-config => $config,
	);
	return $editor;
}

1;
__END__
=head1 NAME

Guido::Executor - Utility module used by Guido to launch external apps 
based on mime-type mappings

=head1 SYNOPSIS


=head1 DESCRIPTION

=head1 INTERFACE

=head1 AUTHOR

James Tillman <jtillman@bigfoot.com>

=head1 SEE ALSO

perl(1).

=cut
