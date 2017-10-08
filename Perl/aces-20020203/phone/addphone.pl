#!/usr/bin/perl -w

###########
# Change! #
###########

my $phoneurl = '/home/acramon1/.phone.txt';

########
# Main #
########

print "\n Name:  ";
my $name = <STDIN>;
chomp $name;
print "\n Number:  ";
my $number = <STDIN>;
print "\n";
open(WRITE, ">>$phoneurl");
flock WRITE , 2;
print WRITE "! $name\t\t" . '|'. " $number";
flock WRITE , 8;
close(WRITE);
print " COOL!\n";
