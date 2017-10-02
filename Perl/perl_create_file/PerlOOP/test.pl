#!/usr/bin/perl
use strict;
use warnings;

use Person;


print "Salut din OOPPerl.\n";

my $object = new Person("Mihai", "cornel", 12345667);
# Get the first name which is set using constructor
my $firstName = $object->getFirstName();
print "First name is : $firstName\n";

$object->run_main();
