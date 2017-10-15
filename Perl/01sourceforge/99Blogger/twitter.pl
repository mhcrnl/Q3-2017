#! /usr/bin/perl

use LWP::UserAgent;
use HTTP::Request;

my $URL = 'https://www.twitter.com/';

my $ua = LWP::UserAgent->new(ssl_opts => { verify_hostname => 1 });
my $header = HTTP::Request->new(GET => $URL);
my $request = HTTP::Request->new('GET', $URL, $header);
my $response = $ua->request($request);

if($response->is_success) {
	print "URL: $URL\nHeaders:\n";
	print $response->headers_as_string;
} elsif ( $response->is_error) {
	print "Error: $URL\n";
	print $response->error_as_HTML;
}
	
	