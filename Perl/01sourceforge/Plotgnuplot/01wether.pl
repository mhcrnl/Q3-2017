#!/usr/bin/env perl
use strict;
use warnings;
use WWW::Wunderground::API;

my $home_location = 'New York City, NY';

# capture location
print "Enter city or zip code ($home_location): ";
my $location = <>;
chomp $location;

binmode STDOUT, ':utf8'; # for degrees symbol
my $w = new WWW::Wunderground::API(
    location => $location || $home_location,
    api_key  => '123456789012345',
    auto_api => 1,
);

# print header
printf "%-10s%-4s%-4s%-8s%-20s\n",
       'Time',
       "\x{2109}",
       "\x{2103}",
       'Rain %',
       'Conditions';

# print hourly
for (@{ $w->hourly })
{
    printf "%8s%4i%4i%8i  %-30s\n",
           $_->{FCTTIME}{civil},
           $_->{temp}{english},
           $_->{temp}{metric},
           $_->{pop},
           $_->{condition};
}