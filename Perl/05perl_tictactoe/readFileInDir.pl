 #!/usr/bin/perl
 use strict;
 use warnings;
 use 5.010;
 use Cwd qw(cwd getcwd);
say cwd;
say getcwd;
my $directory = cwd;
print "$directory\n";

my $filename = 'README.md';
open(my $fh, '>>', $filename) or die "Could not open file '$filename' $!";
say $fh "My first report generated by perl";

say 'done';

opendir (DIR, $directory) or die $!;
print $fh "FILES:\n\n";
 while (my $file = readdir(DIR)) {
        print "$file\n";
        print $fh "\t$file\n";

 }
 print $fh "![img_file](img/img.jpg)\n";
say cwd;
close $fh;
closedir(DIR);
    exit 0;
