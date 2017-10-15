#! usr/bin/perl

use LWP::UserAgent;
use HTTP::Request;
=pod 
profile : +MihaiCmhcrnl
https://www.blogger.com/feeds/+MihaiCmhcrnl/blogs
GET https://www.googleapis.com/blogger/v3/blogs/5436213043189726123
GET https://www.googleapis.com/blogger/v3/users/+MihaiCmhcrnl/blogs

=cut 
my $blogger_url = "https://www.googleapis.com/blogger/v3/blogs/5436213043189726123?key=AIzaSyCAI9jtTusiWaIzzYkOXoSpyFN19lGiP70";
my $blog_id = "5436213043189726123";
my $api_key ="AIzaSyB8zg2espFrZ0DtccUs0qQV11aXtxZKJi0";

my $header = HTTP::Request->new(GET => $blogger_url);
print "$header";
my $request = HTTP::Request->new('GET', $blogger_url, $header);
# my $response = $ua->request($request);

# # if($response->is_success) {
	# print "URL: $URL\nHeaders:\n";
	# print $response->headers_as_string;
# } elsif ( $response->is_error) {
	# print "Error: $URL\n";
	# print $response->error_as_HTML;
# }
	