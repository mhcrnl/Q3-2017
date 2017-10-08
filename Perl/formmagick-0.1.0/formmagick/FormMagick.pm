#!/usr/bin/perl -w

#
# FormMagick (c) 2000 Kirrily Robert <skud@infotrope.net>
# This software is distributed under the GNU General Public License; see
# the file COPYING for details.
#
# $Id: FormMagick.pm,v 1.9 2000/11/11 15:33:40 skud Exp $
#
# $Log: FormMagick.pm,v $
# Revision 1.9  2000/11/11 15:33:40  skud
# Renamed a whole bunch of things so they're consistently testfm*
# Modified header/footer templates to be more realistic/prettier
#
# Revision 1.8  2000/11/11 15:23:57  skud
# Updated documentation prior to release of 0.1.0
# Moved contents of FormMagick.pod into FormMagick.pm
#
# Revision 1.7  2000/11/11 15:05:29  skud
# Renamed finish() to form_post_event()
#
# Revision 1.6  2000/11/11 14:36:46  skud
# It now does "Finish" on the last page.
#
# Revision 1.5  2000/11/11 14:24:23  skud
# It now maintains values from one page to the next.
# Added stubs for validation.
#
# Revision 1.4  2000/11/11 13:46:39  skud
# Persistence and moving backwards and forwards is working! Woohoo!
#
# Revision 1.3  2000/11/11 12:45:28  skud
# Fixed FormMagick.pm to match the DTD, as it specifies that the XML tags
# are ALL UPPER CASE.
# A few smallish code cleanups.
#
# Revision 1.2  2000/11/11 05:53:08  srl
# Took Skud's suggestion and added XML::Parser usage instead of XML::Simple.
# This gives us a data structure with an order, which means we know what pages
# and elements come first. Very important for displaying things properly.
#
# Revision 1.1  2000/11/09 15:20:31  skud
# Used srl's starting point...
# 	- FormMagick.pm display() and related routines
# 	- testfm.pl script to test the thing
# Wrote parse_template() and localise() routines
# HTMLised the output of display() etc
# Added stub templates for header/footer
# Moved docco for l10n and validation out to sub-modules.
#
#

package    FormMagick;
require    Exporter;
@ISA     = qw(Exporter);
@EXPORT  = qw(new display);

my $VERSION = $VERSION = "0.1.0";
my $debug = 1;

use strict;
use FormMagick::L10N;
use XML::Parser;
use Data::Dumper;
use Text::Template;
use CGI::Persistent;
use Carp;

my $language = FormMagick::L10N->get_handle()
        || die "Can't find an acceptable language module.";

sub new {
  shift;
  my $self = {};
  my $type = shift;
  my $source = shift;

  my $p = new XML::Parser (Style => 'Tree');
  $self->{xml} = $p->parsefile($source);

  # okay, this XML::Parser data structure is a little strange. 
  # perldoc XML::Parser gives some help, but here's a crib sheet: 
  
  # $self->{xml}[0] is "form", the name of the root element,
  # $self->{xml}[1] is the actual contents of the "form" element.
  # $self->{xml}[1][0] is the attributes of the "form" element.
  # $self->{xml}[1][4] is the first page. 
  # $self->{xml}[1][8] is the second page.
  # $self->{xml}[1][8][4] is the first field of the second page.  


  # debugging statements, use these to figure out for yourself 
  #   how the parse tree works. 
  # print Dumper( $self->{xml}) ;
  # print Dumper( $self->{xml}[1][0]) ;
  # print Dumper( $self->{current_page} );
  
  bless $self;
  return $self;

}

# display returns the current form page. 
sub display {
  my $self = shift;

  my $cgi = new CGI::Persistent "session-tokens";
  print $cgi->header;

  # pick up page number from CGI, else default to 1
  my $pagenum = $cgi->param("page") || 1;

  # only go next/previous if there are no validation errors... if there
  # are validation errors, we want to redisplay the same page

  my %errors = validate_input($self, $cgi);
  unless (%errors) {
    # increment/decrement pagenum if the user clicked "Next" or "Previous
    $pagenum++ if $cgi->param("wherenext") eq "Next";
    $pagenum-- if $cgi->param("wherenext") eq "Previous";
  }

  # multiply page number by 4 to get the array index of where the page
  # description is... yes, it's ugly, but that's just how the parse tree
  # is

  $self->{current_page} = $self->{xml}[1][ $pagenum*4 ];

  print localise(parse_template($self->{xml}[1][0]->{HEADER}));
  print "<h1>", localise($self->{xml}[1][0]->{TITLE}), "</h1>\n";

  form_post_event($self, $cgi) if $cgi->param("wherenext") eq "Finish";

  print "<h2>", localise($self->{current_page}[0]->{TITLE}), "</h2>\n";

  list_error_messages(%errors) if %errors;

  my $url = $cgi->url();
  print qq(<form method="POST" action="$url">\n);

  print qq(<input type="hidden" name="page" value="$pagenum">\n);
  print $cgi->state_field(), "\n";	# hidden field with state ID

  print "<table>\n";
  
  display_fields($self, $cgi);

  print qq(
    <tr>
    <td></td>
    <td>
  );

  print qq(<input type="submit" name="wherenext" value="Previous">) 
  	unless $pagenum == 1;

  # check whether it's the last page yet
  if (scalar(@{$self->{xml}[1]} + 1)/4 == $pagenum+1) {
    print qq(<input type="submit" name="wherenext" value="Finish">\n);
  } else {
    print qq(<input type="submit" name="wherenext" value="Next">\n);
  }

  print qq(
    <input type="reset" value="Clear this form">
    </tr>
  ); 	
  print "</table>\n</form>\n";

  # here's how we clear our state IDs
  print qq(<p><a href="$url">Start over again</a></p>);

  print localise(parse_template($self->{xml}[1][0]->{FOOTER}));

}

sub display_fields {
  my ($self, $cgi) = @_;

  # $self->{current_page} is a big array. To find info about field N,
  # access element 4*N . 
  
  my @fields;
  for (my $i=4; $i <= length($self->{current_page}); $i=$i+4) {
    push (@fields, $self->{current_page}[$i][0] );
  }

  #print Dumper (@fields);
  
  while (my $fieldinfo = shift @fields  ) {

    #print Dumper ($fieldinfo);

    my $validation = $fieldinfo->{VALIDATION};
    my $label = $fieldinfo->{LABEL};
    my $type = $fieldinfo->{TYPE};
    my $fieldname = $fieldinfo->{ID};

    print "<tr>\n";
    print "<td>", localise($label), "</td)\n";

    my $field_output = qq(<td><INPUT TYPE="$type" NAME="$fieldname");

    # look for a value from CGI or from the XML-specified default
    if (my $value = ($cgi->param($fieldname) || $fieldinfo->{DEFAULT})) {
	    $field_output .= qq( VALUE="$value"></td>);
    } else {
	    $field_output .= qq(></td>);
    }

    print "<td>$field_output</td>\n";
    print "</tr>\n";

    # XXX 
    # handle options. this might be by making another tag like
    # this one, with a different value (if this is a RADIOBUTTON or CHECKBOX
    # field), or by outputting tags inside this one (for a SELECT, we'll need
    # multiple OPTIONs). 
    # give a closing tag, if needed (for SELECT and TEXTAREA, I think.)
    #if (($type eq "select") || ($type eq "textarea") ) {
    #  print "<\/$type>\n";
    #}
  }

}

sub parse_template {
	my $filename = shift;
	carp("Template file $filename does not exist") unless -e $filename;
	my $template = new Text::Template (
		TYPE => 'FILE', 
		SOURCE => $filename
	);
	my $output = $template->fill_in();
	return $output;
}

sub localise {
	my $string = shift;
	if (my $localised_string = $language->maketext($string)) {
		return $localised_string;
	} else {
		return $string;
	}
}


sub validate_input {
  my ($self, $cgi) = @_;

  use FormMagick::Validator;

  my @fields;
  for (my $i=4; $i <= length($self->{current_page}); $i=$i+4) {
    push (@fields, $self->{current_page}[$i][0] );
  }

  my %errors;
  while (my $fieldinfo = shift @fields  ) {
    my $validation = $fieldinfo->{VALIDATION};
    my $fieldname = $fieldinfo->{ID};
  }

  return %errors;
}

sub list_error_messages {
	my %errors = @_;
	print "<h2>Errors</h2>\n";
	print "<ul>";

	foreach my $field (keys %errors) {
		print "<li>$field: $errors{$field}\n";
	}
	print "</ul>\n";
}

sub form_post_event {
	print "<p>FINISHED</p>";
	exit;
}


=pod 

=head1 NAME

FormMagick - easily create CGI form-based applications

=head1 SYNOPSIS

  use FormMagick;

  my $f = new FormMagick(TYPE => FILE,  SOURCE => 'myform.xml')
  my $f = new FormMagick(TYPE => STRING,  SOURCE => $myform)

  $f->display();

=head1 DESCRIPTION

=head2 WARNING: ALPHA SOFTWARE

This software is in ALPHA.  This means that it only works enough to give
you a rough idea of what it's capable of.  If it breaks you get to keep
both the pieces.

This documentation is mostly intended as a guide to FormMagick's
(intended) features.  Many of them are not yet implemented.

For more information about localisation and validation, see the perldoc
for FormMagick::L10N and FormMagick::Validator respectively.

=head2 How it works:

You (the developer) provide at least:

=over 4

=item *

Form descriptions (XML)

=item *

HTML templates (Text::Template?)

=back

And may optionally provide:

=over 4

=item *

Existing data (in a database of some kind)

=item *

L10N lexicons (Locale::Maketext)

=item *

Validation routines (Perl)

=back

FM brings them together to create a web-based CGI forms interface.

=head2 Form descriptions

=head3 Sample form description

The following is an example of how a form is described in XML.  It is
also available as testfm.xml in the FormMagick distribution.  

  <FORM TITLE="My form application" HEADER="myform_header.tmpl" 
    FOOTER="myform_footer.tmpl" POST-EVENT="submit_order">
    <PAGE TITLE="Personal details" TEMPLATE="myform_page.tmpl">
      <FIELD ID="firstname" LABEL="Your first name" TYPE="TEXT" 
        VALIDATION="nonblank"/>
      <FIELD ID="lastname" LABEL="Your surname" TYPE="TEXT" 
        VALIDATION="nonblank"/>
      <FIELD ID="username" LABEL="Choose a username" TYPE="TEXT" 
        VALIDATION="username, length(4)"/>
    </PAGE>
    <PAGE TITLE="Payment details">
      <FIELD ID="cardtype" LABEL="Credit card type" TYPE="SELECT" 
        OPTIONS="list_credit_card_types" VALIDATION="credit_card_type"/>
      <FIELD ID="cardnumber" LABEL="Credit card number" TYPE="TEXT" 
        VALIDATION="credit_card_number"/>
      <FIELD ID="cardexpiry" LABEL="Expiry date (MM/YY)" TYPE="TEXT" 
        VALIDATION="credit_card_expiry"/>
    </PAGE>
  </FORM>

The XML must comply with the FormMagick DTD (included in the
distribution as FormMagick.dtd).  A command-line tool to test compliance
is planned for a future release.

=head3 Notes on form descriptions

* = compulsory

Form

=over 4

=item 
	[*] TITLE (text)

=item 
	HEADER (name of template)

=item 
	FOOTER (name of template)

=item 
	PRE-EVENT (subroutine name)

=item 
	POST-EVENT  (subroutine name)

=back

Page

=over 4

=item 
	[*] TITLE 

=item 
	DESCRIPTION (text)

=item 
	TEMPLATE (name of template)

=item 
	PRE-EVENT (subroutine name)

=item 
	POST-EVENT  (subroutine name)

=back

Field

=over 4

=item 
	[*] ID

=item 
	LABEL (text)

=item 
	VALUE (text or subroutine name)

=item 
	TYPE (text)

=over 4

=item 
		optional add-ons for various types

=item 
		options (list or subroutine)

=item 
		size (number (or subroutine?))

=item 
		etc

=back

=item 
	VALIDATION (subroutine name)

=back

=head1 SEE ALSO

FormMagick::L10N

FormMagick::Validator

=head1 BUGS

Probably some in the sample code in this docco, but there's no real code
yet.

=head1 AUTHOR

Kirrily "Skud" Robert <skud@infotrope.net>

Contributors:

Shane R. Landrum <slandrum@turing.csc.smith.edu>

James Ramirez <jamesr@cogs.susx.ac.uk>

More information about FormMagick may be found at 
http://formmagick.sourceforge.net/

=cut
