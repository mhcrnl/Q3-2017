###########################################################################
#
# This file is auto-generated by the Perl DateTime Suite time locale
# generator (0.03).  This code generator comes with the
# DateTime::Locale distribution in the tools/ directory, and is called
# generate_from_cldr.
#
# This file as generated from the CLDR XML locale data.  See the
# LICENSE.cldr file included in this distribution for license details.
#
# This file was generated from the source file so.xml.
# The source file version number was 1.42, generated on
# 2006/06/27 23:30:54.
#
# Do not edit this file directly.
#
###########################################################################

package DateTime::Locale::so;

use strict;

BEGIN
{
    if ( $] >= 5.006 )
    {
        require utf8; utf8->import;
    }
}

use DateTime::Locale::root;

@DateTime::Locale::so::ISA = qw(DateTime::Locale::root);

my @day_names = (
"Isniin",
"Salaaso",
"Arbaco",
"Khamiis",
"Jimco",
"Sabti",
"Axad",
);

my @day_abbreviations = (
"Isn",
"Sal",
"Arb",
"Kha",
"Jim",
"Sab",
"Axa",
);

my @day_narrows = (
"I",
"S",
"A",
"K",
"J",
"S",
"A",
);

my @month_names = (
"Bisha\ Koobaad",
"Bisha\ Labaad",
"Bisha\ Saddexaad",
"Bisha\ Afraad",
"Bisha\ Shanaad",
"Bisha\ Lixaad",
"Bisha\ Todobaad",
"Bisha\ Sideedaad",
"Bisha\ Sagaalaad",
"Bisha\ Tobnaad",
"Bisha\ Kow\ iyo\ Tobnaad",
"Bisha\ Laba\ iyo\ Tobnaad",
);

my @month_abbreviations = (
"Kob",
"Lab",
"Sad",
"Afr",
"Sha",
"Lix",
"Tod",
"Sid",
"Sag",
"Tob",
"KIT",
"LIT",
);

my @month_narrows = (
"K",
"L",
"S",
"A",
"S",
"L",
"T",
"S",
"S",
"T",
"K",
"L",
);

my @am_pms = (
"sn",
"gn",
);

my @era_abbreviations = (
"Ciise\ ka\ hor",
"Ciise\ ka\ dib",
);

my $date_parts_order = "dmy";


sub day_names                      { \@day_names }
sub day_abbreviations              { \@day_abbreviations }
sub day_narrows                    { \@day_narrows }
sub month_names                    { \@month_names }
sub month_abbreviations            { \@month_abbreviations }
sub month_narrows                  { \@month_narrows }
sub am_pms                         { \@am_pms }
sub era_abbreviations              { \@era_abbreviations }
sub full_date_format               { "\%A\,\ \%B\ \%d\,\ \%\{ce_year\}" }
sub long_date_format               { "\%d\ \%B\ \%\{ce_year\}" }
sub medium_date_format             { "\%d\-\%b\-\%\{ce_year\}" }
sub short_date_format              { "\%d\/\%m\/\%y" }
sub full_time_format               { "\%\{hour_12\}\:\%M\:\%S\ \%p" }
sub long_time_format               { "\%\{hour_12\}\:\%M\:\%S\ \%p" }
sub medium_time_format             { "\%\{hour_12\}\:\%M\:\%S\ \%p" }
sub short_time_format              { "\%\{hour_12\}\:\%M\ \%p" }
sub date_parts_order               { $date_parts_order }



1;

