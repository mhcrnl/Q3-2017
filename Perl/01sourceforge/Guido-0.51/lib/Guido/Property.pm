# MODINFO module Guido::Property Manager for various properties of objects in Guido IDE
package Guido::Property;

# MODINFO dependency module strict
use strict;
# MODINFO dependency module vars
use vars qw($VERSION @ISA @EXPORT @EXPORT_OK);

# MODINFO dependency module Class::DirtyMethodMaker
use Class::DirtyMethodMaker get_set => [ qw / name data_type display_name type enum_style default_value  / ];
# MODINFO dependency module XML::DOM
use XML::DOM;
# MODINFO dependency module Data::Dumper
use Data::Dumper;

# MODINFO dependency module Exporter
require Exporter;
# MODINFO dependency module AutoLoader
require AutoLoader;

# MODINFO dependency module constant
use constant STOCK_PROPERTY_FILE => 'Guido/properties.xml';

# MODINFO parent_class AutoLoader
# MODINFO parent_class Exporter
@ISA = qw(Exporter AutoLoader);
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

#
#Global property defaults
#
my $parser = new XML::DOM::Parser();
my $doc = $parser->parsefile(_findINC(STOCK_PROPERTY_FILE));

##
#Constructors
##


# MODINFO constructor new
# MODINFO key name STRING          Name of the property
# MODINFO key value STRING         Value of the property
# MODINFO key type STRING          Type of property (basic, geometry, etc.)
# MODINFO key data_type STRING     Data type of property (STRING, FONT, INTEGER, etc)
# MODINFO key listeners ARRAYREF   Other objects that want to know when this property's value changes
# MODINFO key is_stock STRING      Whether this property is a stock Tk property (as defined via the Tk documentation)
# MODINFO key enum ARRAYREF        A list of possible options for this property
# MODINFO key enum_style STRING    Should be FREE or STRICT.  When STRICT, only values from the "enum" property will be allowed.  When FREE, the values in "enum" are available, but other values can also be used.
# MODINFO key default_value ANY The default value to use for this property
sub new {
	my($class, %attribs) = @_;
	$attribs{default_value} ||= '';
	my $self = {
	    name => $attribs{name},
	    value => ($attribs{value} || $attribs{default_value}),
	    type => $attribs{type},
	    data_type => $attribs{data_type},
	    listeners => $attribs{listeners},
	    is_stock => $attribs{is_stock},
	    enum => $attribs{enum},
	    enum_style => $attribs{enum_style},
	    default_value => $attribs{default_value},
	    using_default => 0,
	};

	bless $self => $class;

	$self->using_default();

	if ($self->{is_stock} or $attribs{check_stock}) {
	  foreach my $prop_node ($doc->getElementsByTagName('property')) {
	    if ($prop_node->getAttribute('name') eq $attribs{name}) {
	      $self->{is_stock} = 1;
	      $self->{data_type} = $prop_node->getAttribute('datatype');
	      $self->{display_name} = $prop_node->getAttribute('display_name');
	      $self->{validation_style} = $prop_node->getAttribute('validation_style');

	      my @enum_values;
	      foreach my $enum_node ($prop_node->getElementsByTagName('enum_value')) {
		push(@enum_values, $enum_node->getAttribute('value'));
	      }
	      my @regexps;
	      foreach my $val_node ($prop_node->getElementsByTagName('validation_rule')) {
		push(@regexps, $val_node->getAttribute('value'));
	      }
	      if(@enum_values) {
		$self->{enum} = \@enum_values;
		if (@regexps and $self->{validation_style} eq 'OR') {
		  $self->{enum_style} = 'FREE';
		}
		else {
		  $self->{enum_style} = 'STRICT';
		}
	      }
	      if(@regexps) {
		$self->{rules} = \@regexps;
	      }
	      #Need to accomodate AND/OR situations in validation rules!
	    }
	  }
	}

	$self->{display_name} ||= ($attribs{display_name} || $self->{name});

#	print $self->{name} . ":" . Dumper($self->{enum}) . "\n";
	return $self;
}

# MODINFO method value Retrieves or sets the value of the property
# MODINFO param value        STRING  New value for the property
# MODINFO param force_update BOOLEAN Set the value of the property using the "value" parameter even if that value is undefined or empty
sub value{
  my($self, $value, $force_update) = @_;
  if($value || $force_update) {
      return $self->{value} if $value eq $self->{value};
      my $old_value = $self->{value};
      $self->{value} = $value;
      foreach my $listener (@{$self->{listeners}}) {
	  $listener->property_change($self, $old_value);
      }
      #Sync up using_default flag
      $self->using_default;
  }
  return $self->{value};
}

# MODINFO property using_default Indicates whether the Property is currently using its default value, or whether a specific value has been set
# MODINFO read using_default
# MODINFO retval BOOLEAN
sub using_default {
  my($self) = @_;
  if ($self->value eq $self->default_value) {
    $self->{using_default} = 1;
    return 1;
  }
  else {
    $self->{using_default} = 0;
    return 0;
  }
}

# MODINFO method use_default Reverts the property's value to its default value
# MODINFO retval ANY
sub use_default {
  my($self) = @_;
  $self->{using_default} = 1;
  $self->value($self->default_value);
}

# MODINFO method to_code Convert the value into Perl code
sub to_code{
  my($self) = @_;
  #print $self->data_type . "\n";
  if ($self->data_type =~ /REF/) {
    return $self->value;
  }
  else {
    return "'" . $self->value . "'";
  }
}

# MODINFO method get_editor Get a Tk window for editing the value of this property
# MODINFO retval Tk::Widget
sub get_editor {
}

# MODINFO method listeners Returns the array reference of listeners for this property
# MODINFO retval ARRAYREF
sub listeners {$_[0]->{listeners}}

# MODINFO method register_listener Add a new listener for this property
# MODINFO param listener Guido::PropertyChangeListener Ref to the object wishing to listen
# MODINFO retval BOOLEAN
sub register_listener {
  my($self, $listener) = @_;
  unless($listener->can('property_change')) {
    warn ref($listener) . " does not support the property_change method.\n";
    return 0;
  }
  push(@{$self->{listeners}}, $listener);
  return 1;
}

# MODINFO method deregister_listener Remove a listener from the array of listeners
# MODINFO param listener Guido::PropertyChangeListener Ref to the object that should be removed
# MODINFO retval BOOLEAN
sub deregister_listener {
  my($self, $listener) = @_;
  my @kept_listeners = ();
  foreach my $curr_listener (@{$self->{listeners}}) {
    if ($curr_listener != $listener) {
      push(@kept_listeners, $listener);
    }
  }
  $self->{listeners} = \@kept_listeners;
  return 1;
}

# MODINFO method to_string Convert property to a string
sub to_string {}

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

=cut

# Autoload methods go after =cut, and are processed by the autosplit program.

1;
__END__

=head1 NAME

Guido::Property - Manager for the values of Tk properties

=head1 SYNOPSIS

  use Guido::Property;
  my $prop = new Guido::Property(
      name => "background",
      value => "#FFFFFF",
      type => "basic",
      data_type => "COLOR",
      listeners => [$obj_ref, $obj2_ref],
  );
  #detailed code usage goes here

=head1 DESCRIPTION

Guido::Property helps to manage the internal representations of Tk properties such as those returned by the ->configure method of Tk widgets, as well as the geometry properties for widgets.

It also provides change-event notification through a simple array reference of objects that are to be notified when the event is changed.

=head1 KNOWN ISSUES

None known at this time

=head1 AUTHOR

jtillman@bigfoot.com

=head1 SEE ALSO

perl(1).

=cut
