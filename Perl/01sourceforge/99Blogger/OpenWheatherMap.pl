#! /usr/bin/perl

# bf7be29e1775efb51f2311a0c952d151    APIKEY
#api.openweathermap.org/data/2.5/weather?q=London
# GET bf7be29e1775efb51f2311a0c952d151.openweathermap.org/data/2.5/weather?q=Bucharest
=pod
http://api.openweathermap.org/data/2.5/weather?q=London&appid=bf7be29e1775efb51f2311a0c952d151
http://api.openweathermap.org/data/2.5/forecast?id=524901&APPID={APIKEY} 
=cut

use strict;
use 5.018;
use LWP::Simple;
use JSON::PP;

my $api_url = 'http://bf7be29e1775efb51f2311a0c952d151.openweathermap.org/data/2.5/weather?q=';
my $qurey = 'San Diego, CA';

my $json = JSON::PP->new();
my $data = $json->decode(get($api_url . $qurey));

# coord
my $lon = $data->{coord}->{lon};
my $lat = $data->{coord}->{lat};
# sys
my $contry = $data->{sys}->{conunty};
my $sunrise = $data->{sys}->{sunrise};
my $sunset = $data->{sys}->{sunset};
# weather 0
my $id = $data->{weather}[0]->{id};
my $main = $data->{weather}[0]->{main};
my $description = $data->{weather}[0]->{description};
my $icon = $data->{weather}[0]->{icon};
# main
my $temp_k = $data->{main}->{temp}; # Kelvin
my $temp_c = $temp_k -271.15; # Celsius
my $temp_f = (($temp_c * 9)/5)+32; # Fahrenheit
my $humidity = $data->{main}->{humidity};
my $pressure = $data->{main}->{pressure};
my $temp_min_k = $data->{main}->{temp_min}; # Kelvin
my $temp_min_c = $temp_min_k -271.15; # Celsius
my $temp_min_f = (($temp_min_c * 9)/5)+32; # Fahrenheit
my $temp_max_k = $data->{main}->{temp_max}; # Kelvin
my $temp_max_c = $temp_max_k -271.15; # Celsius
my $temp_max_f = (($temp_max_c * 9)/5)+32; # Fahrenheit
# wind
my $wind_speed = $data->{wind}->{speed};
my $wind_deg = $data->{wind}->{deg};
# clouds
my $clouds = $data->{clouds}->{all};
# other
my $base = $data->{base};
my $time = $data->{dt};
my $_id = $data->{id};
my $name = $data->{name};
my $cod = $data->{cod};

##############################################################
say "It's $temp_f in $name."