#!/usr/bin/perl
use LWP::UserAgent;
 
my $ua = LWP::UserAgent->new;
 
my $server_endpoint = "https://centruldeistorieaplicata.blogspot.ro/";
 
# set custom HTTP request header fields
my $req = HTTP::Request->new(POST => $server_endpoint);
$req->header('content-type' => 'application/json');
$req->header('x-auth-token' => 'kfksj48sdfj4jd9d');
 
# add POST data to HTTP request body
my $post_data = '{ "name": "Dan", "address": "NY" }';
$req->content($post_data);
 
my $resp = $ua->request($req);
if ($resp->is_success) {
    my $message = $resp->decoded_content;
    print "Received reply: $message\n";
}
else {
    print "HTTP POST error code: ", $resp->code, "\n";
    print "HTTP POST error message: ", $resp->message, "\n";
}
