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
# This file was generated from the source file gv.xml.
# The source file version number was 1.38, generated on
# 2006/06/27 23:30:54.
#
# Do not edit this file directly.
#
###########################################################################

package DateTime::Locale::gv;

use strict;

BEGIN
{
    if ( $] >= 5.006 )
    {
        require utf8; utf8->import;
    }
}

use DateTime::Locale::root;

@DateTime::Locale::gv::ISA = qw(DateTime::Locale::root);

my @day_names = (
"Jelhein",
"Jemayrt",
"Jercean",
"Jerdein",
"Jeheiney",
"Jesarn",
"Jedoonee",
);

my @day_abbreviations = (
"Jel",
"Jem",
"Jerc",
"Jerd",
"Jeh",
"Jes",
"Jed",
);

my @month_names = (
"Jerrey\-geuree",
"Toshiaght\-arree",
"Mayrnt",
"Averil",
"Boaldyn",
"Mean\-souree",
"Jerrey\-souree",
"Luanistyn",
"Mean\-fouyir",
"Jerrey\-fouyir",
"Mee\ Houney",
"Mee\ ny\ Nollick",
);

my @month_abbreviations = (
"J\-guer",
"T\-arree",
"Mayrnt",
"Avrril",
"Boaldyn",
"M\-souree",
"J\-souree",
"Luanistyn",
"M\-fouyir",
"J\-fouyir",
"M\.Houney",
"M\.Nollick",
);

my @am_pms = (
"a\.m\.",
"p\.m\.",
);

my @era_abbreviations = (
"RC",
"AD",
);



sub day_names                      { \@day_names }
sub day_abbreviations              { \@day_abbreviations }
sub month_names                    { \@month_names }
sub month_abbreviations            { \@month_abbreviations }
sub am_pms                         { \@am_pms }
sub era_abbreviations              { \@era_abbreviations }



1;

