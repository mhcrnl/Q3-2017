#!/usr/bin/perl
use strict;
use warnings;

use Person;
use Employee;

print "Salut din OOPPerl.\n";

my $object = new Person("Mihai", "cornel", 12345667);
# Get the first name which is set using constructor
my $firstName = $object->getFirstName();
print "First name is : $firstName\n";



$object->run_main();

my $ang_class = new Employee();
$ang_class->run_main();

#add elements object
my @tablou ;
push(@tablou, $object);
print "@tablou\n";
