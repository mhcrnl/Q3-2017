# MODINFO module Guido::PropertyPage
package Guido::PropertyPage;

# MODINFO dependency module Tk::Frame
require Tk::Frame;
# MODINFO dependency module Carp
use Carp;
# MODINFO dependency module Tk
use Tk;
# MODINFO dependency module Tk::BrowseEntry
use Tk::BrowseEntry;
# MODINFO dependency module Tk::FontDialog
use Tk::FontDialog;
#use Tk::font;
# MODINFO dependency module Data::Dumper
use Data::Dumper;

# MODINFO dependency module vars
use vars qw( @ISA );
# MODINFO dependency module Tk::Derived
use Tk::Derived;
# MODINFO dependency module Tk::Frame
use Tk::Frame;
# MODINFO dependency module Tie::Watch
use Tie::Watch;

# MODINFO parent_class Tk::Frame
@ISA = qw( Tk::Derived Tk::Frame );

#use base qw/Tk::Derived Tk::Frame/;

Construct Tk::Widget 'PropertyPage';

my $enable_autoupdate = 1;

my @system_colors = qw/
	SystemButtonFace
	SystemWindowFrame
	SystemButtonText
	SystemDisabledText
/;

# MODINFO method Populate Standard Tk initialization routine
# MODINFO paramhashref attribs
# MODINFO key -append_props    HASHREF This should contain a hash reference that  contains simple key/value pairs of custom properties and their default values.  It is not required, but you must provide something here or in the widget parameter for anything useful to happen.
# MODINFO key -prop_options    HASHREF  This should contain a hash reference with pointers to array references.  The arrays should contain single string values to be placed in a BrowseEntry widget.  If a certain property does not have a matching prop_option key, a simple Entry is used instead.
# MODINFO key -widget          Tk::Widget This should be a reference to the widget whose properties are going to be edited.  It is not a required parameter; you could simply provide a bunch of custom properties in the append_props parameter.
# MODINFO key -prop_categories HASHREF A hashref whose keys are property names and values are the categories the property names should be placed in
# MODINFO key -mask_props      ARRAYREF This should be an array reference pointing to an array of simple string values that match the names of properties you wish to be hidden from the user in the editor.  Useful for preventing editing of widget properties you don't want to the user to mess with.

# MODINFO retval
sub Populate {
	my($cw, $attribs) = @_;
	my(@props);
	$cw->{props} = delete $attribs->{-append_props};
	my $props = $cw->{props};
	my $mask_props = delete $attribs->{-mask_props};
	my $prop_options = delete $attribs->{-prop_options};
	my $widget = delete $attribs->{-widget};
	my $prop_cats = delete $attribs->{-prop_categories};

	$cw->SUPER::Populate();
	$cw->ConfigSpecs(
	     -background => ['DESCENDANTS', 'background', 'Background'],
        );

	$text = $cw->Scrolled(
	    'Text',
	    -wrap=>'none',
	    -scrollbars=>'osoe',
	)->pack(
	    -expand=>1,
	    -fill=>'both',
	);
	#$text->configure(-background => $text->parent->cget(-background));

	#Figure out minimum width of our labels and entries
	my $min_lbl_width = 10;
	my $min_entry_width = 10;
	
	foreach my $item (@$props) {
	    $min_lbl_width = length($item->name) if $min_lbl_width < length($item->name);
	    next if !$item->value;
	    $min_entry_width = length($item->value) if $min_entry_width < length($item->value);
	}
	
 	$text->configure(-width=>$min_lbl_width + $min_entry_width + 15);

	#Loop over @$props to create the labels/entries
	my @sorted_props = sort {lc $a->display_name cmp lc $b->display_name} @$props;
	foreach my $item (@sorted_props) {
	    my $value = $item->value;
#	    print $item->display_name() . "\n";

	    my %frame_props = (
		label=>$item->display_name, 
		value=>$value, 
		ref=>$item,
		min_label_width=>$min_lbl_width,
		min_entry_width=>$min_entry_width,
	    );

	    #Get first prop frame and place it in the sorted page
	    my $prop_frame = $cw->_get_property_widget($text, %frame_props);

	    $text->windowCreate('end', -window=>$prop_frame, -stretch=>1);
	    $text->insert('end', "\n");

	    #Get second prop frame and place in the categories page
	    if ($prop_cats) {
		my $prop_frame2 = $cw->_get_property_widget($tree, %frame_props);
		my $category;
		my $pretty_name = $cw->_get_pretty_name($item);
		if ($prop_cats_lookup{$pretty_name}) {
		    $category = $prop_cats_lookup{$pretty_name};
		}
		else {
		    $category = 'Other';
		}
		
		if (!$tree->info('exists', $category)) {
		    $tree->add(
			"$category", 
			-itemtype=>'text',
			-text=>$category,
		    );
		}
			
		$tree->add("${category}.${item}", -itemtype=>'window', -widget=>$prop_frame2);
	    }
	}

	#Prevents accidental editing in the Text widget
	$text->configure(-state=>'disabled');
	$tree->autosetmode() if $tree;
	$enable_autoupdate = 1;
}

# MODINFO function refresh
sub refresh {
	
}

# MODINFO method properties This returns a reference to the combined properties from -widget and -append_props.  The widget's properties will correspond with the name that would be retrieved via the $widget->configure('property') method call, including the dash prefix (i.e., -activebackground). The properties that were passed in via -append_props will be named just as they were in the -append_props parameter.
sub properties {
	my($cw) = @_;
	return $cw->{props};
}

# MODINFO function is_color_value Returns 1 if value is a color value, 0 if not
# MODINFO param value STRING The value to check
# MODINFO retval BOOLEAN
sub is_color_value {
	my($value) = @_;
	return 0 if !$value;
	return 1 if ($value =~ /\#(\w|\d){6}/ or grep(/^$value$/, @system_colors));
	return 0;
}

sub _get_pretty_name {
	my($self, $item) = @_;
	my $item_label = $item;
	$item_label =~ s/^\-//;
	$item_label =~ s/^(.)/\u$1/;
	return $item_label;
}

sub _get_property_widget {
	my($self, $parent, %params) = @_;
	my $item = $params{label};
#	my $value = $params{value};
	my $var_ref = $params{ref};
	my $min_lbl_width = $params{min_label_width};
	my $min_entry_width = $params{min_entry_width};

	#Make the item label
	my $item_label = $var_ref->display_name;

	#Create holder frame
	my $frame = $parent->Frame();

	#Create the label
	my $w = $frame->Label(
		-anchor=>'w',
		-text=>$item_label,
		-width=>$min_lbl_width,
	)->pack(-side=>'left');

	##
	#Everything else gets the usual Entry or Select box
	##
	my $value = $var_ref->value || '';
	if ($var_ref->{enum} && @{$var_ref->{enum}} > 0) {
	    if ($var_ref->enum_style eq 'STRICT') {$state = 'readonly';}
	    else                                  {$state = 'normal';}
	    $w = $frame->BrowseEntry(
		-width=>20,
		-variable=>\$value,
		#-validatecommand=>[\&update_value, $var_ref],
		#-validate=>'focusout',
		-state=>$state,
	    )->pack(-side=>'left');
	    $w->insert(0,@{$var_ref->{enum}});
	}
	else {
	    $value = "$value";
	    $w = $frame->Entry(
		-width=>20, 
		-textvariable=>\$value,
		#-validatecommand=>[\&update_value, $var_ref],
		#-validate=>'focusout',
	    )->pack(-side=>'left');
	}

	$w->bind('<FocusOut>',[\&update_value, $var_ref, \$value]);
		
	my $using_default = $var_ref->using_default;
	$d = $frame->Checkbutton(
	     -variable=>\$using_default,
	     -text=>'Default',
	)->pack(-side=>'left');
	Tie::Watch->new(
	     -variable=>\$value,
	     -store=> sub {
		  my($watched, $new_value) = @_;
                  $watched->Store($new_value);
		  if ($new_value ne $var_ref->default_value && $using_default) {
		    $using_default = 0;		
		  }
		  elsif ($new_value eq $var_ref->default_value && !$using_default) {
		    $using_default = 1;
		  }
		},
	    );
        Tie::Watch->new(
	    -variable=>\$using_default,
            -store=> sub {
	       my ($watched, $new_value) = @_;
               $watched->Store($new_value);
	       if ($new_value) {$value = $var_ref->default_value}
            }
	);

	return $frame;
}

sub finalize {
  my($self) = @_;
  $self->focusForce();
  $self->update();
}

sub update_value{
  my($widget, $property_obj, $new_value_ref) = @_;
  # Passing a 1 as 2nd param forces an update if value is empty
  $property_obj->value($$new_value_ref, 1);
}

__END__

=head1 Guido::PropertyPage

Guido::PropertyPage - A generic property set editor, originally built
for allowing editing of Tk widget properties

=head1 SYNOPSIS

  use Tk;
  use Guido::PropertyPage;
  my $mw = new MainWindow();
  my $pp = $mw->PropertyPage(
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

Guido::PropertyPage allows you to display a property editor for
a Tk widget, a custom property set, or both.  You might wish to have 
both when you are displaying properties for a Tk widget but want
the widget appear to have properties that it really doesn't.  See the 
SYNOPSIS for an example of this.

Extra parameters allow for customizing the way the properties are 
displayed and edited.

=head1 INTERFACE


=head1 KNOWN ISSUES

Currently ignores prop_options for font and color properties

-validatecommand is currently broken

=head1 AUTHOR

jtillman@bigfoot.com

=head1 SEE ALSO

perl(1).
Tk(1).

=cut
