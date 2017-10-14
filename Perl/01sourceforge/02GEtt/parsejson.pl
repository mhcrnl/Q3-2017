#!/usr/bin/perl
use strict;
use warnings;
use JSON qw( decode_json );
 
my $json = '{
        "name": "Bob",
        "sex": "Male",
        "address": {
                "city": "San Jose",
                "state": "California"
        },
        "friends":
                [
                        {
                                "name": "Alice",
                                "age": "20"
                        },
                        {
                                "name": "Laura",
                                "age": "23"
                        },
                        {
                                "name": "Daniel",
                                "age": "30"
                        }
                ]
}';
 
my $decoded = decode_json($json);
 
# This is a Perl example of parsing a JSON object.
 
print "City = " . $decoded->{'address'}{'city'} . "\n";
 
# This is a Perl example of parsing a JSON array.
 
my @friends = @{ $decoded->{'friends'} };
foreach my $f ( @friends ) {
  print $f->{"name"} . "\n";
}
