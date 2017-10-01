#!/usr/bin/perl
# ================================================================
#   Create a new perl file insert by user in form of 'my_perl.pl' 
#
# ================================================================
use strict;
use warnings;

print "USE: \n";
print "Insert input in form of my_perl_file.pl \n";

print "Enter your file name: ";
my $filename = <STDIN>;
chomp $filename;

my $author = 'Mihai Cornel mhcrnl@gmail.com';
my $fh;

open($fh, '>', $filename) or die "Could not open '$filename' $!";

print $fh "#!/usr/bin/perl\n\n";
print $fh "# Aceasta este o fila de cod perl $filename.\n";
print $fh "# Autor: '$author'\n";
print $fh "print \"Salut din perl\";";
close $fh;

print "Salut din PERL, operatie reusita.\n";
