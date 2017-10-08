#!/usr/bin/perl -w

####################
# Global Variables #
####################
my $phoneurl = '/home/acramon1/.phone.txt';

########
# Main #
########

open(PURL,$phoneurl); # opening the file
flock PURL , 1;
@purl = <PURL>; # loading the file
flock PURL , 8;
close(PURL); # closing the file


print "\nPHONE BOOK\n\n"; # just for show

my $query = pop; # get command line argument

if(!(defined $query)) { # if there was no command line argument
	print "input?  ";
	$query = <STDIN>;
}

print "\n--\n"; # just for show

chomp($query); # clear up any ugly lines
foreach (@purl) { # go through the entire file
   print "$_\n" if (/$query/i);
};

print "\n"; # just for show
