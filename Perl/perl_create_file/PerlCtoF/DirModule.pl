#! /usr/bin/perl
use strict;
use warnings;
use Scalar::Util qw(looks_like_number); #almost always useful
use Cwd qw(cwd); # LINUX pwd
use FileHandle;
use File::Glob;
=pod
	 Filename: DirModule.pl 
	 Autor: 'Mihai Cornel mhcrnl@gmail.com'
	 Create time: Wed Oct  4 09:05:15 2017
	 TODO:
=cut
# ===== ENTRY POINT 
print "Salut din perl";

my $dir = cwd;
chdir($dir) or die "no dir $dir =, $!"; 
print "$dir";
open (DIR, $dir) or die $!;

while(my $file = readdir DIR){
    print "$file\n";
}

closedir DIR;
exit 0;
=pod
my @files = glob($dir);
foreach (@files ){
    print $_ . "\n";
}
=cut

