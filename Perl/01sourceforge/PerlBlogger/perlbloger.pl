use Mojo::UserAgent;
use Mojo::JSON qw(decode_json encode_json);
use v5.010;
# Fine grained response handling (dies on connection errors)
my $ua  = Mojo::UserAgent->new;
my $res = $ua->get('mojolicious.org/perldoc')->result;
if    ($res->is_success)  { say $res->body }
elsif ($res->is_error)    { say $res->message }
elsif ($res->code == 301) { say $res->headers->location }
else                      { say 'Whatever...' }

my $Key ='AIzaSyDn-tCHKa2auxKch1fNWeeyQnlpPTqAWD8';
#GET https://www.googleapis.com/blogger/v3/blogs/2399953?key=YOUR-API-KEY
my $value = $ua->get('https://www.googleapis.com/blogger/v3/blogs/2399953?key=$Key')->result->json;
 my $hash  = decode_json $value;
say "MY: ". $hash;