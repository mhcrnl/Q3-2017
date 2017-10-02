#!/usr/bin/perl

use strict;
use warnings;

my %phonebook;
while (1) {
	my $choice = menu();
	if ($choice == 1) {
		addEntry();
	} elsif ($choice == 2) {
		deleteEntry();
	} elsif ($choice == 3) {
		searchEntry();
	} elsif ($choice == 4) {
		showEntry();
	} elsif ($choice == 5) {
		exit();
	} else {
		print "Invaild Entry Try again";
	}
}

###############################################

sub menu {
	print"1. Add an entry.\n";
	print"2. Delete an entry.\n";
	print"3. Look up an entry.\n";
	print"4. List all entries.\n";
	print"5. Quit.\n";
	print"Enter your choice (1-5): ";
	my $prompt = <STDIN>;
	return $prompt;
}

################################################

sub addEntry {
	print"Enter a name: \n";
	chomp (my $name = <STDIN>);
	$name = lc($name);
	if (exists $phonebook{$name}){
		print"Entry already exists\n";
	} else {
		print"Enter phone: \n";
		chomp (my $phone = <STDIN>);
		$phonebook{$name} = $phone;
	}
}

###############################################

sub deleteEntry {
	print"Enter name: \n";
	my $delname = <STDIN>;;
	$delname = lc($delname);
	if (exists $phonebook{$delname}){
		delete($phonebook{$delname});
		print"The name and phone have been deleted\n";
        } else {
                print"There is no such name in the phone book\n";
        }
}

##################################################

sub searchEntry {
	print"Enter name: \n";
	my $searchname = <STDIN>;
	$searchname = lc($searchname);
	if (exists $phonebook{$searchname}) {
		print($phonebook{$searchname});
	} else {
		print"Entry doesnt exist\n";
	}
}
###################################################
sub showEntry{
	while (( my $key, my $value) = each(%phonebook)){
		print"$key ,  $value\n";
	}

}

############################################


