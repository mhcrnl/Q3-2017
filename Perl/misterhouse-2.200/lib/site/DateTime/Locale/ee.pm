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
# This file was generated from the source file ee.xml.
# The source file version number was 1.18, generated on
# 2006/06/28 01:23:32.
#
# Do not edit this file directly.
#
###########################################################################

package DateTime::Locale::ee;

use strict;

BEGIN
{
    if ( $] >= 5.006 )
    {
        require utf8; utf8->import;
    }
}

use DateTime::Locale::root;

@DateTime::Locale::ee::ISA = qw(DateTime::Locale::root);

my @day_names = (
"Dzoɖa",
"Braɖa",
"Kuɖa",
"Yawoɖa",
"Fiɖa",
"Memleɖa",
"Kɔsiɖa",
);

my @day_abbreviations = (
"Dzo",
"Bra",
"Kuɖ",
"Yaw",
"Fiɖ",
"Mem",
"Kɔs\ Kwe",
);

my @day_narrows = (
"D",
"B",
"K",
"Y",
"F",
"M",
"K",
);

my @month_names = (
"Dzove",
"Dzodze",
"Tedoxe",
"Afɔfiɛ",
"Dama",
"Masa",
"Siamlɔm",
"Deasiamime",
"Anyɔnyɔ",
"Kele",
"Adeɛmekpɔxe",
"Dzome",
);

my @month_abbreviations = (
"Dzv",
"Dzd",
"Ted",
"Afɔ",
"Dam",
"Mas",
"Sia",
"Dea",
"Any",
"Kel",
"Ade",
"Dzm",
);

my @month_narrows = (
"D",
"D",
"T",
"A",
"D",
"M",
"S",
"D",
"A",
"K",
"A",
"D",
);

my @am_pms = (
"AN",
"EW",
);

my @era_names = (
"Hafi\ Yesu\ Va\ Do\ ŋgɔ\ na\ Yesu",
"Yesu\ Ŋɔli",
);

my @era_abbreviations = (
"HY",
"YŊ",
);



sub day_names                      { \@day_names }
sub day_abbreviations              { \@day_abbreviations }
sub day_narrows                    { \@day_narrows }
sub month_names                    { \@month_names }
sub month_abbreviations            { \@month_abbreviations }
sub month_narrows                  { \@month_narrows }
sub am_pms                         { \@am_pms }
sub era_names                      { \@era_names }
sub era_abbreviations              { \@era_abbreviations }



1;

