# MODINFO module Guido::Plugin Interface definition class for Guido plugins
package Guido::Plugin;

# MODINFO method init_plugin Plugins implement this method to allow the IDE to initialize them
sub init_plugin {
	my($self, $app) = @_;
	warn ref($self) . " did not override the init_plugin method";
}

# MODINFO method place_menus This method is called when a plugin should place its menus (if any) into the IDE
sub place_menus {
	my($self, $app) = @_;
	warn ref($self) . " did not override the place_menus method";
}


# MODINFO method refresh This method is called when the plugin should refresh itself (perhaps look at the IDE's state and update its display)
sub refresh {
	my($self, $app) = @_;
	warn ref($self) . " did not override the refresh method";
}

# MODINFO method display This method is called when the plugin is being added into the GUI, and returns 1 if it can display a GUI or 0 if it can't.  It defaults to 1 unless overridden by the plugin.
# MODINFO retval BOOLEAN
sub display {
    return 1;
}

1;

=head1 NAME

Guido::Plugin - A virtual class defining the Guido interface for plugins

=head1 SYNOPSIS

	package Guido::Plugin::MyPlugin;

	use vars qw( @ISA );
	use Guido::Plugin;
	@ISA = qw( Guido::Plugin );
	
	sub init_plugin { #Do initialization here }
	sub refresh { #Do refresh here }
	sub place_menus { #Do menu placement here }



=head1 DESCRIPTION

Guido::Plugin is a virtual class that all Guido plugins should inherit
from.  It defines a simple interface made up of three methods.  These
methods allow Guido to interact with the plugins in a predictable way.

For more information on creating Guido plugins, see the Guido Plugin
Authors Guide, provided with the Guido distribution.

=head1 INTERFACE

=head1 AUTHOR

James Tillman <jtillman@bigfoot.com>

=head1 SEE ALSO

perl(1).

=cut
