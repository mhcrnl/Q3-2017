#!/usr/bin/perl
# ================================================================
#   Create a new perl file insert by user in form of 'my_perl.pl' 
#
# ================================================================
use strict;
use warnings;

my $filename;

runProgram();

# ================================================================
#   Functia createFile()
# =================================================================
sub createFile {
    print "Enter your file name: ";
    $filename = <STDIN>;
    chomp $filename;

    my $author = 'Mihai Cornel mhcrnl@gmail.com';
    my $fh;

    open($fh, '>', $filename) or die "Could not open '$filename' $!";

    print $fh "#!/usr/bin/perl\n\n";
    print $fh "# Aceasta este o fila de cod perl $filename.\n";
    print $fh "# Autor: '$author'\n\n";
    print $fh "use strict;\n";
    print $fh "use warnings;\n\n";
    print $fh "print \"Salut din perl\";";
    close $fh;

    print "Salut din PERL, operatie reusita.\n";
}
# ===================================================================
#   Functia Help()
# ===================================================================
sub Help {
    print "Aceasta este functia Help(). ";
    print "USE: \n";
    print "Insert input in form of my_perl_file.pl \n";
}
# ===================================================================
#   Functia Meniu()
# ===================================================================
sub Meniu {
    print "1. Help meniu.\n";
    print "2. Create file.\n";
    print "3. Read file.\n";
    print "4. Close program.\n";
    
    print "Insert your choice(1-5): ";
    my $prompt = <STDIN>;
    return $prompt;
}
# ==================================================================
#   Functia runProgram()
# ==================================================================
sub runProgram {
    my $choice;
    while (1) {
        $choice = Meniu();
        if($choice == 1) {
            # === Functia Help() apelare 
            Help();
        } elsif ($choice == 2) {
            createFile();
        } elsif ($choice == 3) {
            # === Apelarea functiei readFile() 
            readFile();
        } elsif ($choice == 4) {
            exit();
        } else {
            print "Invalid entry try again.";
        }
    }

}
# ===================================================================
#   Functia readFile()
# ===================================================================
sub readFile {
    open(DATA, '<', $filename) or die "Could not open '$filename' $!";
    my @lines = <DATA>;
    print "@lines\n";
    #close(DATA):
}










