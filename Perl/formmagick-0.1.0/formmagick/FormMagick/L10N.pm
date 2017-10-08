#!/usr/bin/perl -w

use Locale::Maketext;

package FormMagick::L10N;
@ISA = qw(Locale::Maketext);

1;

=pod
=head1 NAME

FormMagick::L10N - localization routines for FormMagick

=head1 SYNOPSIS

  use FormMagick::L10N;

=head1 DESCRIPTION

FormMagick uses the C<Locale::Maketext> module for L10N.  L10N lexicons 
are kept in an L10N subdirectory and given names like L10N/fr.pm. 
The lexicons take the form of a Perl hash:

  %Lexicon = (
	"Hello"		=> "Bonjour",
	"Click here"	=> "Appuyez ici"
  );

Localisation preferences are picked up from the HTTP_ACCEPT_LANGUAGE 
environment variable passed by the user's browser.

Localisation is performed on:

=over 4

=item *

Form titles

=item *

Page titles and descriptions

=item *

Field labels

=item *

Validation error messages

=back

If you wish to localise other textual information such as your HTML 
Templates, you will have to explicitly call the l10n routines.

=head1 AUTHOR

Kirrily "Skud" Robert <skud@infotrope.net>

More information about FormMagick may be found at 
http://sourceforge.net/projects/formmagick/



=cut
