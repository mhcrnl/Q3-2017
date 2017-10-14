# MODINFO module Guido::Tracer Class for providing tracing information for Guido modules
package Guido::Tracer;

# MODINFO dependency module strict
use strict;
# MODINFO dependency module vars
use vars qw($VERSION @ISA @EXPORT @EXPORT_OK);
# MODINFO dependency module Exporter
require Exporter;

# MODINFO parent_class AutoLoader
@ISA = qw(Exporter AutoLoader);
# Items to export into callers namespace by default. Note: do not export
# names by default without a very good reason. Use EXPORT_OK instead.
# Do not simply export all your public functions/methods/constants.
#@EXPORT = qw();
@EXPORT = qw();
@EXPORT_OK = qw();
# MODINFO version 0.01
$VERSION = '0.01';

# Preloaded methods go here.
# MODINFO constructor new
# MODINFO paramhash attribs
# MODINFO key trace_level STRING Level of tracing to perform
# MODINFO key trace_target CODEREF Callback to execute when a trace message is sent to the trace method
# MODINFO key subsys STRING If provided, indicates the subsystem for which trace messages should be honored
sub new {
	my ($class, %attribs) = @_;
	my $self = {
		level => $attribs{trace_level},
		target => $attribs{trace_target},
		subsys => $attribs{subsys},
	};
	return bless $self, $class;
}

# MODINFO method trace Method called to send a trace message to the system
# MODINFO param msg STRING Message to be sent
# MODINFO param trace_lvl STRING Level of tracing assigned to this message.  Must be equal to or greater than the trace_level assigned to the Tracer object for the message to be honored
# MODINFO param subsys STRING Subsystem from which this message has been sent. Used for filtering out messages from subsystems that are not currently of interest
sub trace {
    my ($self, $msg, $trace_lvl, $subsys) = @_;

    return if ($self->{subsys} and $self->{subsys} ne $subsys);
    return if !$trace_lvl;
	
    $msg = "TRACE (" . $subsys . "): " . $msg;
    # If trace_lvl is less than or equal to the
    #  current defined level, we display the message
    if (!$self->{level} or $trace_lvl <= $self->{level}) {
	# If target is a CODE ref, we call it like a function
	if (defined($self->{target}) && 
	      ref($self->{target}) eq "CODE") {
	    &{$self->{target}}($msg);
	}
	# If target is a SCALAR, we assume it's an output file
	#  and append to it
	elsif (defined($self->{target}) && ref($self->{target}) eq "SCALAR") {
	    open(TRACEFILE, ">>" . $self->{target});
	    print TRACEFILE $msg . "\n";
	    close(TRACEFILE);
	}
	# Finally, if target is defined, but isn't a SCALAR or CODE ref
	#  we assume it's a file handle and we print to it
	elsif (defined($self->{target})) {
	    print {$self->{target}} $msg . "\n";
	}
	# If target is not defined, we just default to STDERR output
	else {
	    print STDERR $msg . "\n";
	}
    }
}

1;
__END__
=head1 NAME

Guido::Tracer - Utility module used by Guido to provide tracing information

=head1 SYNOPSIS

used internally when debug=>1 is passed to the Application object

=head1 DESCRIPTION

The Guido::Tracer object provides a common logging facility for sending 
trace output either to the command line or to a Tk window.  Plugins 
can send trace messages to the trace facility by using the TRACE method 
in the Application object:

$app->TRACE("My trace message", 1);

Note that the second parameter is the minimum trace level that must be 
in effect for the message to actually be displayed.

=head1 INTERFACE

=head1 AUTHOR

James Tillman <jtillman@bigfoot.com>

=head1 SEE ALSO

perl(1).

