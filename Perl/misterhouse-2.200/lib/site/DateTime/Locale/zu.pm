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
# This file was generated from the source file zu.xml.
# The source file version number was 1.12, generated on
# 2006/07/11 19:22:10.
#
# Do not edit this file directly.
#
###########################################################################

package DateTime::Locale::zu;

use strict;

BEGIN
{
    if ( $] >= 5.006 )
    {
        require utf8; utf8->import;
    }
}

use DateTime::Locale::root;

@DateTime::Locale::zu::ISA = qw(DateTime::Locale::root);

my @day_names = (
"Msombuluko",
"Lwesibili",
"Lwesithathu",
"Lwesine",
"Lwesihlanu",
"Mgqibelo",
"Sonto",
);

my @day_abbreviations = (
"Mso",
"Bil",
"Tha",
"Sin",
"Hla",
"Mgq",
"Son",
);

my @month_names = (
"Januwari",
"Februwari",
"Mashi",
"Apreli",
"Meyi",
"Juni",
"Julayi",
"Agasti",
"Septemba",
"Okthoba",
"Novemba",
"Disemba",
);

my @month_abbreviations = (
"Jan",
"Feb",
"Mas",
"Apr",
"Mey",
"Jun",
"Jul",
"Aga",
"Sep",
"Okt",
"Nov",
"Dis",
);

my @era_names = (
"BC",
"AD",
);

my @era_abbreviations = (
"BC",
"AD",
);



sub day_names                      { \@day_names }
sub day_abbreviations              { \@day_abbreviations }
sub month_names                    { \@month_names }
sub month_abbreviations            { \@month_abbreviations }
sub era_names                      { \@era_names }
sub era_abbreviations              { \@era_abbreviations }



1;

