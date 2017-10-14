# MODINFO module Guido::PluginLoader Loads Guido plugins into the IDE
package Guido::PluginLoader;

# MODINFO dependency module XML::DOM
use XML::DOM;
# MODINFO dependency module Data::Dumper
use Data::Dumper;
# MODINFO dependency module strict
use strict;

# MODINFO constructor new
# MODINFO paramhash attribs
# MODINFO key app         Guido::Application Ref to IDE object
# MODINFO key config_file STRING             Path to configuration file to use
sub new {
	my($class, %attribs) = @_;
	my $self = {
		app => $attribs{app},
		config_file => $attribs{config_file},
	};
	return bless $self => $class;
}

# MODINFO method import_plugins
# MODINFO paramhash params
# MODINFO key plugin Guido::Plugin Name of plugin to import, if not all of them
# MODINFO retval INTEGER
sub import_plugins {
    my($self, %params) = @_;
	
    my $plugin_name = $params{plugin} if $params{plugin};

    my $app = $self->{app};
    my $file_name = $self->{config_file};
	
    #Get MainWindow ref from Application object
    my $mw = $app->{mw};

    #Use the application's parsed config data    
    my $plugins = $app->{config}->{plugins}->{plugin};

    if (!scalar(@$plugins)) {
	$app->TRACE("No plugins to process", 1);
	return 0;
    }

    $app->TRACE(scalar(@$plugins) . " plugins to process", 1);

    #Create adjuster object for resizable plugins
    foreach my $plugin (@$plugins) {
	#my $plugin = $plugins->item($i);
	#my $att = $plugin->getAttribute("plugin_name");
	my $att = $plugin->{plugin_name};
	Guido::Application::splash_status("Loading plugins..." . $att. " plugin");
	my $no_display = $plugin->{no_display};
	$no_display = 0 if ref($no_display);
	my $no_adjust = $plugin->{no_adjust};
	$app->TRACE("Plugin: " . $att, 3);
	
	if ($plugin_name and $att ne $plugin_name) {
	    $app->TRACE("Skipping $att",1);
	    next;
	}
	
	#Add plugin and pack it
	my %atts = %$plugin;
	my $atts = \%atts;
	delete $atts->{plugin_name};
	delete $atts->{no_display};
	delete $atts->{no_adjust};
	
	$app->TRACE("Attributes:\n" . Dumper($atts), 5);

	my $pack_info = getPackInfo(delete($atts->{'pack'}));
	my $class = delete($atts->{class_name});
	$app->TRACE("Pack info:\n" . Dumper($pack_info), 5);
	
	#Import the source file and instantiate the widget
	eval {
	    require "Guido/Plugin/" . $class . ".pm";

	    #Some plugins don't provide UI
	    if ("Guido::Plugin::$class"->isa("Tk::Widget")) {
		#If there is a UI then load as widget
		my $wdg_plugin = $mw->$class(%$atts);
		unless ($no_display or !$wdg_plugin->display()) {
		    $app->TRACE("Packing plugin", 2);
		    if ($no_adjust) {
			$wdg_plugin->pack(%$pack_info) if $pack_info;
		    }
		    else {
			$wdg_plugin->packAdjust(%$pack_info) if $pack_info;
		    }
		}
		$wdg_plugin->init_plugin($app);
		$wdg_plugin->place_menus($app);
		$app->plugins($class, $wdg_plugin);
	    }
	    else {
		#Else load as plain ol' module
		my $plugin = "Guido::Plugin::$class"->new(%$atts);
		$plugin->init_plugin($app);
		$plugin->place_menus($app);
		$app->plugins($class, $plugin);
	    }
	};
	
	#If any errors occurred, report them
	if ($@) {
	    $app->ERROR(
		title	=>"Plugin Init Error",
		text	=>"Initialization of plugin $class failed: $@\n",
	       );
	    return 0;
	}
    }	

    return 1;
}

sub getPluginAtts {
	my($node) = @_;
	my $atts = {};
    my $node_map = $node->getAttributes;
	for (my $i = 0; $i < $node_map->getLength; $i++) {
	    my $att = $node_map->item($i);
	    my $name = $att->getName;
	    next if $name eq 'plugin_name' or $name eq 'no_display' or $name eq 'no_adjust';
	    my $value = $att->getValue();
#	    $value =~ s|^\&|\&main\:\:| if $value !~ /::/;
#	    $value = eval "\\$value" if $value =~ /^(\&|sub\s*\{)/;
		$atts->{$name} = $value; 
	}
    return $atts;
}

sub getPackInfo {
  my($string) = @_;
  my %atts;
  map {
    my($key,$value) = split(/=/);
    $atts{$key} = $value;
  } split(/;/,$string);
  return \%atts;
}

1;

__END__

=head1 NAME

Guido::PluginLoader - A class for loading Guido plugins from configuration files

=head1 SYNOPSIS

	$plugin_loader = new Guido::PluginLoader(
		app=>$self,
		config_file=>'/home/jtillman/.guido/myconfig.cfg',
	);
	$plugin_loader->import_plugins();


=head1 DESCRIPTION

Guido::PluginLoader is a class for initializing Guido's plugins from 
configuration files.  It is really only meant for use by the Application 
object, although it might be useful elsewhere.

The configuration file should be an XML file that follows the structure 
documented in the Guido Configuration Structure documentation (DESIGN.pod), 
found in this same directory.

For more information on creating Guido plugins, see the Guido Plugin 
Authors Guide, provided with the Guido distribution.

=head1 INTERFACE

=head1 AUTHOR

James Tillman <jtillman@bigfoot.com>

=head1 SEE ALSO

perl(1).

=cut
