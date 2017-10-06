#! /usr/bin/perl

package Employee;

use Person;
use strict;

our @ISA = qw(Person); # inherits from Person

####################################################################
sub run_main{
    my $angajat = new Employee("Vasile", "Radu", 9876);
    my $ang_name = $angajat->getFirstName();
    print "Numele angajatului : $ang_name\n";
}

