#! /usr/bin/perl

use strict;
use warnings;

use Person;
#### Variabile globale
my @pers_array;

print "Salut din TestPerson.pl";

my $pers = new Person("Radu", "Vasile", 3232234);
my $str = $pers->afisare();
print "$str";
run_program();

=pod
    Functia care are ca parametri de intrare un string fisier,
    creaza o fila si salveaza in ea lista de persoane

=cut
sub createFile{
    my($file) = @_;
    my $fr;
    open($fr, '>', $file) or die "Could not open '$file' $!"; 
    print $fr "@pers_array" ;   
    
}
#######################################
sub run_program{
    my $choice;
    while(1){
        $choice = meniu();
        if( $choice == 1){
            createPerson();
        } elsif($choice == 2){
            print "@pers_array\n";
        } elsif($choice == 3){
            print "Insert name of the file(text.txt): ";
            my $file = <STDIN>;
            createFile($file);
        } elsif($choice == 9){
            exit();
        } else {
            print "Your choice is not valid.\n";
        }
    }
}
############################################
sub meniu{
    print "\n1. Create person;\n";
    print "2. Afisare array;\n";
    print "3. Create file to save persons.\n";
    
    print "9. Exit;\n";
    print "Insert your choice: ";
    my $selection = <STDIN>;
    return $selection;
}
#########################################
sub createPerson{
    print "Insert first name: ";
    my $nume = <STDIN>;
    chomp $nume;
    
    print "Insert last name: ";
    my $prenume = <STDIN>;
    chomp $prenume;
    
    print "Insert cnp: ";
    my $cnp = <STDIN>;
    chomp $cnp;
    
    my $opers = new Person($nume, $prenume, $cnp);
    my $perstr = $opers->afisare();
    print "$perstr";
    
    push(@pers_array, $perstr);
}
