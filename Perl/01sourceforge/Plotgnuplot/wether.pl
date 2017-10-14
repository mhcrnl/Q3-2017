#!/usr/bin/perl -w

use strict;
use LWP::Simple;

my $url = "https://www.wunderground.com/weather/us/ca/san-francisco/94102";
print "$url";
my $ca = get("${url}95472"); # Sebastopol, California
my $ma = get("${url}02140"); # Cambridge, Massachusetts

my $ca_temp = current_temp($ca);
my $ma_temp = current_temp($ma);
my $diff = $ca_temp - $ma_temp;

print $diff > 0 ? "California" : "Massachusetts";
print " is warmer by ", abs($diff), " degrees F.\n";

sub current_temp {
  local $_ = shift;
  m{<tr ><td>Temperature</td>\s+<td><b>(\d+)} || die "No temp data?";
  return $1;
}