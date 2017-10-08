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
# This file was generated from the source file hu.xml.
# The source file version number was 1.70, generated on
# 2006/10/26 22:46:08.
#
# Do not edit this file directly.
#
###########################################################################

package DateTime::Locale::hu;

use strict;

BEGIN
{
    if ( $] >= 5.006 )
    {
        require utf8; utf8->import;
    }
}

use DateTime::Locale::root;

@DateTime::Locale::hu::ISA = qw(DateTime::Locale::root);

my @day_names = (
"hétfő",
"kedd",
"szerda",
"csütörtök",
"péntek",
"szombat",
"vasárnap",
);

my @day_abbreviations = (
"H",
"K",
"Sze",
"Cs",
"P",
"Szo",
"V",
);

my @day_narrows = (
"H",
"K",
"S",
"C",
"P",
"S",
"V",
);

my @month_names = (
"január",
"február",
"március",
"április",
"május",
"június",
"július",
"augusztus",
"szeptember",
"október",
"november",
"december",
);

my @month_abbreviations = (
"jan\.",
"febr\.",
"márc\.",
"ápr\.",
"máj\.",
"jún\.",
"júl\.",
"aug\.",
"szept\.",
"okt\.",
"nov\.",
"dec\.",
);

my @month_narrows = (
"J",
"F",
"M",
"Á",
"M",
"J",
"J",
"A",
"S",
"O",
"N",
"D",
);

my @quarter_names = (
"I\.\ negyedév",
"II\.\ negyedév",
"III\.\ negyedév",
"IV\.\ negyedév",
);

my @quarter_abbreviations = (
"N1",
"N2",
"N3",
"N4",
);

my @am_pms = (
"DE",
"DU",
);

my @era_names = (
"időszámításunk\ előtt",
"időszámításunk\ szerint",
);

my @era_abbreviations = (
"i\.\ e\.",
"i\.\ sz\.",
);

my $date_parts_order = "ymd";


sub day_names                      { \@day_names }
sub day_abbreviations              { \@day_abbreviations }
sub day_narrows                    { \@day_narrows }
sub month_names                    { \@month_names }
sub month_abbreviations            { \@month_abbreviations }
sub month_narrows                  { \@month_narrows }
sub quarter_names                  { \@quarter_names }
sub quarter_abbreviations          { \@quarter_abbreviations }
sub am_pms                         { \@am_pms }
sub era_names                      { \@era_names }
sub era_abbreviations              { \@era_abbreviations }
sub full_date_format               { "\%\{ce_year\}\.\ \%B\ \%\{day\}\." }
sub long_date_format               { "\%\{ce_year\}\.\ \%B\ \%\{day\}\." }
sub medium_date_format             { "\%\{ce_year\}\.\%m\.\%d\." }
sub short_date_format              { "\%\{ce_year\}\.\%m\.\%d\." }
sub full_time_format               { "\%\{hour\}\:\%M\:\%S\ \%\{time_zone_long_name\}" }
sub long_time_format               { "\%\{hour\}\:\%M\:\%S\ \%\{time_zone_long_name\}" }
sub medium_time_format             { "\%\{hour\}\:\%M\:\%S" }
sub short_time_format              { "\%\{hour\}\:\%M" }
sub date_parts_order               { $date_parts_order }



1;

