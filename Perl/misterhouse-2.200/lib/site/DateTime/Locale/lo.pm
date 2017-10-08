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
# This file was generated from the source file lo.xml.
# The source file version number was 1.45, generated on
# 2006/06/27 23:30:54.
#
# Do not edit this file directly.
#
###########################################################################

package DateTime::Locale::lo;

use strict;

BEGIN
{
    if ( $] >= 5.006 )
    {
        require utf8; utf8->import;
    }
}

use DateTime::Locale::root;

@DateTime::Locale::lo::ISA = qw(DateTime::Locale::root);

my @day_names = (
"ວັນຈັນ",
"ວັນອັງຄານ",
"ວັນພຸດ",
"ວັນພະຫັດ",
"ວັນສຸກ",
"ວັນເສົາ",
"ວັນອາທິດ",
);

my @day_abbreviations = (
"ຈ\.",
"ອ\.",
"ພ\.",
"ພຫ\.",
"ສກ\.",
"ສ\.",
"ອາ\.",
);

my @month_names = (
"ມັງກອນ",
"ກຸມພາ",
"ມີນາ",
"ເມສາ",
"ພຶດສະພາ",
"ມິຖຸນາ",
"ກໍລະກົດ",
"ສິງຫາ",
"ກັນຍາ",
"ຕຸລາ",
"ພະຈິກ",
"ທັນວາ",
);

my @month_abbreviations = (
"ມ\.ກ\.",
"ກ\.ພ\.",
"ມີ\.ນ\.",
"ມ\.ສ\.\.",
"ພ\.ພ\.",
"ມິ\.ຖ\.",
"ກ\.ລ\.",
"ສ\.ຫ\.",
"ກ\.ຍ\.",
"ຕ\.ລ\.",
"ພ\.ຈ\.",
"ທ\.ວ\.",
);

my @am_pms = (
"ກ່ອນທ່ຽງ",
"ຫລັງທ່ຽງ",
);

my @era_names = (
"ປີກ່ອນຄິດສະການທີ່",
"ຄິດສະການທີ່",
);

my @era_abbreviations = (
"ປີກ່ອນຄິດສະການທີ່",
"ຄ\.ສ\.",
);

my $date_parts_order = "dmy";


sub day_names                      { \@day_names }
sub day_abbreviations              { \@day_abbreviations }
sub month_names                    { \@month_names }
sub month_abbreviations            { \@month_abbreviations }
sub am_pms                         { \@am_pms }
sub era_names                      { \@era_names }
sub era_abbreviations              { \@era_abbreviations }
sub full_date_format               { "\%Aທີ\ \ \%\{day\}\ \%B\ \%\{era\}\ \%\{ce_year\}" }
sub long_date_format               { "\%\{day\}\ \%B\ \%\{ce_year\}" }
sub medium_date_format             { "\%\{day\}\ \%b\ \%\{ce_year\}" }
sub short_date_format              { "\%\{day\}\/\%\{month\}\/\%\{ce_year\}" }
sub full_time_format               { "\%\{hour\}ໂມງ\ \%\{minute\}ນາທີ\ \%S\'\ ວິນາທີ" }
sub long_time_format               { "\%\{hour\}\ ໂມງ\ \%\{minute\}ນາທີ" }
sub medium_time_format             { "\%\{hour\}\:\%M\:\%S" }
sub short_time_format              { "\%\{hour\}\:\%M" }
sub date_parts_order               { $date_parts_order }



1;

