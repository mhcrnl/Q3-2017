# MODINFO module Guido::PropertySource Interface class for providing property change events
package Guido::PropertySource;

my @ps_watcher;

##
#These are the important methods to override
##
# MODINFO method property_source_properties
sub property_source_properties {undef}
# MODINFO method property_source_tk_ref
sub property_source_tk_ref {undef}
#sub property_source_callback {\&property_change}
# MODINFO method property_source_change
sub property_source_change {1}
# MODINFO method property_source_name
sub property_source_name {undef}
# MODINFO method property_source_type
sub property_source_type {return ref($_[0])}

##
#These are methods for providing metadata about the properties
#
#They should return hash structures for use by the PropertyManager
##
# MODINFO method property_source_categories
sub property_source_categories {undef}
# MODINFO method property_source_options
sub property_source_options {undef}
# MODINFO method property_source_read_only
sub property_source_read_only {undef}

##
#These methods allow the definition of an heirarchy,
# but are not necessary to use a PropertySource
##
# MODINFO method property_source_parent
sub property_source_parent {return;}
# MODINFO method property_source_children
sub property_source_children {return;}
# MODINFO method property_source_siblings
sub property_source_siblings {return;}

##
#These methods allow a listener to register its interest in
# the PropertySource's properties and receive updates in 
# realtime
##
# MODINFO method notify_property_watchers Called when a property changes so the property watcher callbacks can be executed
# MODINFO param property_name Name of the property being updated
# MODINFO param property_value New value of the property
# MODINFO retval
sub notify_property_watchers {
	my($self, $property_name, $property_value) = @_;
	foreach my $callback (@ps_watchers) {
		&$callback($property_name, $property_value);
	}
}

# MODINFO method register_property_watcher Allows the registration of a method to call when the property changes (1=success/0=failure)
# MODINFO param callback Code ref that should be executed when the property changes
# MODINFO retval INTEGER
sub register_property_watcher {
	my ($self, $callback) = @_;
	return 0 if ref($callback) ne "CODE";
	push(@ps_watchers, $callback);
	return 1;
}

1;

=head1 NAME

Guido::PropertySource - Defines an interface for providing property change notifications

=head1 SYNOPSIS

  use Guido::PropertySource;
  @ISA = qw/ Guido::PropertySource /;

  # Then override each of the methods in the class

=head1 DESCRIPTION

This class defines the interface that Guido uses for property change event notification.  When one class wants to know if a property in another class has changed, it can use this interface to register a callback that will be executed when the property changes.

The class also allows for creation of object heirarchies through the parent and children methods, and providing extended information about properties such as categories and read/write capabilities.

=head1 INTERFACE

=head1 KNOWN ISSUES

None at this time

=head1 AUTHOR

James Tillman <jtillman@bigfoot.com>

=head1 SEE ALSO

perl(1).

=cut
