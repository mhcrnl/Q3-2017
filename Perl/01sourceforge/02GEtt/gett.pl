#!/usr/bin/perl
use 5.010;
use Gett;
 
# Get API Key from http://ge.tt/developers
 
my $gett = Gett->new( 
    api_key      => 'GettAPIKey',
    email        => 'me@example.com',
    password     => 'mysecret',
);
 
my $file_obj = $gett->upload_file( 
    filename => "ossm.txt",
    contents => "/some/path/example.txt",
       title => "My Awesome File", 
    encoding => ":encoding(UTF-8)"
);
 
say "File has been shared at " . $file_obj->getturl;
 
# Download contents
my $file_contents = $file_obj->contents();
 
open my $fh, ">:encoding(UTF-8)", "/some/path/example-copy.txt"
    or die $!;
print $fh $file_contents;
close $fh;
 
# clean up share and file(s)
my $share = $gett->get_share($file->sharename);
$share->destroy();
