#!/usr/bin/perl -w

#
# FormMagick (c) 2000 Kirrily Robert <skud@infotrope.net>
# This software is distributed under the GNU General Public License; see
# the file COPYING for details.
#
# $Id: Validator.pm,v 1.5 2000/11/11 15:05:29 skud Exp $
#
# $Log: Validator.pm,v $
# Revision 1.5  2000/11/11 15:05:29  skud
# Renamed finish() to form_post_event()
#
# Revision 1.4  2000/11/11 08:20:45  skud
# Time::ParseDate is DWIMmier than Date::Parse.
#
# Revision 1.3  2000/11/11 08:08:14  skud
# Added the "date" routine.
#
# Revision 1.2  2000/11/11 08:05:19  skud
# Made a start on validation routines.
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

package    FormMagick::Validator;

=pod
=head1 NAME

FormMagick::Validator - validate data from FormMagick forms

=head1 SYNOPSIS

use FormMagick::Validator;

=head1 DESCRIPTION

This module provides some common validation routines.  Validation
routines return the string "OK" if they succeed, or a descriptive
message if they fail.

=head2 Validation routines provided:

=over 4

=item nonblank

The data is not an empty string : C<$data ne "">

=cut 

sub nonblank {
	my $data = $_[0];
	if ($data ne "") {
		return "OK";
	} else {
		return "This field must not be left blank" if /^$/;
	}
}

=pod

=item number

The data is a number (strictly speaking, data is a positive number):
C<$data =~ /^[0-9.]+$/>

=cut

sub number {
	my $data = $_[0];
	if ($data =~ /^[0-9.]+$/) {
		return "OK";
	} else {
		return "This field must contain a positive number.";
	}
}

=pod

=item word

The data looks like a word: C<$data !~ /\W/>

=cut

sub word {
	my $data = $_[0];
}

=pod

=item length(n)

The data is at least C<n> characters long: C<length($data) E<gt>= $n>

=cut

=pod

=item url

The data looks like a (normalish) URL: C<$data =~ m!(http|ftp)://[\w/.-/)!>

=cut

sub url {
	my $data = $_[0];
	if ($data =~ m!(http|ftp)://[\w/.-/]!) {
		return "OK";
	} else {
		return "This field must contain a URL starting with http:// or ftp://";
	}
}

=pod

=item email 

The data looks more or less like an internet email address:
C<$data =~ /\@/>

=cut

sub email {
	my $data = $_[0];
	if ($data =~ /\@/) {
		return OK;
	} else {
		return "This field doesn't look like an email address.
		It should contain an at-sign (\@).";
	}
}

=pod

=item domain_name

The data looks like an internet domain name.

=cut

sub domain_name {
	my $data = $_[0];
	return "NOT YET IMPLEMENTED";
}

=pod

=item ip_number

The data looks like a valid IP number.

=cut

sub ip_number {
	my $data = $_[0];
	return "NOT YET IMPLEMENTED";
}

=pod

=item username

The data looks like a good, valid username

=cut

sub username {
	my $data = $_[0];
	return "NOT YET IMPLEMENTED";
}

=pod

=item password

The data looks like a good password

=cut

sub password {
	my $data = $_[0];
	return "NOT YET IMPLEMENTED";
}

=pod

=item date

The data looks like a date.

=cut

sub date {
	my $data = $_[0];
	use Time::ParseDate;
	if (my $time = parsedate($data)) {
		return "OK";
	} else {
		return "The data entered could not be parsed as a date."
	}
}

=pod

=item iso_country_code

The data is a standard 2-letter ISO country code.  Uses Net::Country to
check.

=cut

sub country {
	my $data = $_[0];
	return "NOT YET IMPLEMENTED";
}

=pod

=item US_state

The data is a standard 2-letter US state abbreviation.  Uses
Geography::State in non-strict mode.

=cut

sub US_state {
	my $data = $_[0];
	use Geography::States;

	my $us = Geography::States->new('USA');

	if ($us->state(uc($data))) {
		return "OK";
	} else {
		return "This doesn't appear to be a valid 2-letter US state abbreviation."
	}			
}

=pod

=item US_zipcode

The data looks like a valid US zipcode

=cut

sub US_zipcode {
	my $data = $_[0];
	if ($data =~ /^\d{5}$/) {
		return "OK";
	} else {
		return "US zip codes must contain 5 numbers.";
	}
}

=pod

=item credit_card_type

The data looks like a valid type of credit card (eg Visa, Mastercard).
Uses Business::CreditCard.

=cut

sub credit_card_type {
	my $data = $_[0];
	return "NOT YET IMPLEMENTED";
}

=pod

=item credit_card_number

The data looks like a valid credit card number
Uses Business::CreditCard.

=cut

sub credit_card_number {
	my $data = $_[0];
	return "NOT YET IMPLEMENTED";
}

=pod

=item credit_card_expiry

The data looks like a valid credit card expiry date
Uses Business::CreditCard.

=cut

sub credit_card_expiry {
	my $data = $_[0];
	return "NOT YET IMPLEMENTED";
}



=pod

=back

These validation routines may be overridden, and others may be added on 
a per-application basis.

=head1 AUTHOR

Kirrily "Skud" Robert <skud@infotrope.net>

More information about FormMagick may be found at 
http://sourceforge.net/projects/formmagick/

=cut

return 1;
