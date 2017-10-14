# MODINFO module Guido::PropertyPageDialog
package Guido::PropertyPageDialog;
# MODINFO dependency module strict
use strict;

# MODINFO dependency module vars
use vars qw( @ISA );
# MODINFO dependency module Tk::Toplevel
use Tk::Toplevel;
# MODINFO parent_class Tk::Toplevel
@ISA = qw( Tk::Toplevel );

#use base qw(Tk::Toplevel);

# MODINFO dependency module Guido::PropertyPage
use Guido::PropertyPage;
# MODINFO dependency module Tk::widgets
use Tk::widgets qw(Toplevel);

Construct Tk::Widget 'PropertyPageDialog';

# MODINFO method Populate Standard Tk init method
# MODINFO paramhashref args
# MODINFO key -widget_name STRING Name to use for the widget
# MODINFO key -title       STRING Title to display in the dialog
sub Populate {
	my ($cw, $args) = @_;
	$cw->{properties} = {};
	my $pp_args = {};
	my $widget_name;
	eval {
		$widget_name = delete $args->{-widget_name};
	};

    $cw->transient($cw->Parent->toplevel);
    #Temporarily commented to allow window to be destroyed if error occurs
    #$cw->protocol('WM_DELETE_WINDOW' => sub {});
	
	if ($widget_name and !$args->{-title}) {
		$args->{-title} = 'Properties for "' . ($widget_name or $args->{-widget}->name) . '"';
	}

	foreach my $item (qw/-prop_options -widget -append_props -mask_props -prop_options -prop_categories/) {
		$pp_args->{$item} = delete $args->{$item};
	}

	$cw->SUPER::Populate($args);

	my $prop_page = $cw->PropertyPage(
		%$pp_args
	)->pack(
 #		-expand=>1
	);
	$cw->Advertise('property_page' => $prop_page);

	my $btn_cncl = $cw->Button(
		-width=>'7', 
		-text=>'Cancel', 
		-command=>sub{$cw->{'properties'} = undef;}
	)->pack(
		-anchor=>'e', 
		-side =>'right', 
		-pady=>'1m',
 #		-expand=>1,
	);
	
	my $btn_ok = $cw->Button(
		-width=>'7',
		-text=>'OK', 
		-default=>'active',
		-command=>sub{$prop_page->finalize(); $cw->{'properties'} = $prop_page->properties()},
		-justify=>'right',
	)->pack(
		-anchor=>'e', 
		-side =>'right', 
		-padx=>'1m', 
		-pady=>'1m',
 #		-expand=>1,
	);
	
	$cw->bind('<Return>' => [ $btn_ok, 'Invoke']);
	
}

sub Wait {
   my $cw = shift;
   $cw->waitVariable(\$cw->{'properties'});
   $cw->grabRelease;
   $cw->withdraw;
   $cw->Callback(-command => $cw->{'properties'});
}

# MODINFO method Show Standard Tk dialog function that causes the dialog to popup and grab focus
# MODINFO param grab Type of grab to use (global or local)
# MODINFO retval HASHREF
sub Show {
   my ($cw, $grab) = @_;
   my $old_focus = $cw->focusSave;
   my $old_grab = $cw->grabSave;
   Tk::catch {
      if (defined $grab && length $grab && ($grab =~ /global/)) {
	 $cw->grabGlobal;
      } 
      else {
	 $cw->grab;
      }
   };
   $cw->focus;
   $cw->Wait;
   &$old_focus;
   &$old_grab;
   $cw->withdraw;
   return $cw->{'properties'} or {};
}

1;

__END__

=head1 NAME

Guido::PropertyPageDialog - Displays a Guido::PropertyPage in a dialog box.

=head1 SYNOPSIS

	my $ppd = $mw->PropertyPageDialog(
		#Same types of params as for PropertyPage
	  	-widget => $widget, #ref to a TK widget (not required)
	  	-mask_props => ['-activebackground', '-font'],
	  	-append_props => {  #extra non-Tk properties (not required)
	  		LastName => 'Smith',
	  		FirstName => 'John',
	  	},
	  	-prop_options => {  #provide lists here for drop-down edits
	  		LastName => ['Smith', 'Johnson', 'Jones'],
	  		-activebackground => ['Black', 'Blue', 'White'],
	  	},
	);		

=head1 DESCRIPTION

Guido::PropertyPageDialog is a convenience class for developers to 
prevent them from having to create their own dialog boxes anytime they 
want to display a PropertyPage.  For more information on the parameters 
that PropertyPageDialog can accept, see the 
Guido::PropertyPage documentation.

Use the standard Tk construction syntax as shown in the SYNOPSIS.

=head1 INTERFACE

=head1 KNOWN ISSUES

None at this time

=head1 AUTHOR

James Tillman <jtillman@bigfoot.com>

=head1 SEE ALSO

perl(1).

=cut
