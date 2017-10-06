#! /usr/bin/perl
use strict;
use warnings;
use Scalar::Util qw(looks_like_number);  #almost always useful
use Cwd qw(cwd); # LINUX pwd
use CreateClass;
=pod
    Create a new DIRECTORY from input of the user and inside create
        a new perl FILE insert by user in form of 'my_perl.pl',
        and a new file README.md, gitpush.sh and executed after
        permissions.
    This code search to include best practice in perl.
    CREATE: README.md, gitpush.sh, .pl and .pm file
    For pm module see folder Modul.
    1. Create Class file NameClass =. NameClass.pm 
    TODO:
    1. Create module file .pm and .pl with file to test func: createModule
    
=cut
# ============= ENTRY POINT
my $filename;
my $dir = cwd; # Directorul curent in care se afla aplicatia
#my %module_txt;

runProgram();
# ==============================================================
#   createModule() - creates two file ---.pm and Test---.pl
# ==================================================================
sub createModule{
    print "Enter your module name(ex: modul): ";
    my $fmodule = <STDIN>;
    chomp $fmodule;
    # Create the files .pm and .pl
    my $f_name_module = $fmodule.".pm";
    print "$f_name_module";
    my $f_name_test = "Test_".$fmodule.".pl";
    print "$f_name_test";
    # Strings to include in file .pm
    my %module_txt = ( #maintain strings in one place; you will thank me

        'appack'   => "package ".$fmodule.";",
        'use1'     => "use strict;",
        'use2'     => "use warnings;",
        'use3'     => "use Exporter qw(import);",
        'use4'     => "our \@EXPORT_OK = qw(add multiply);",
        
        'usef'    => "1;"
    );
    # Create file .pm
    my $fh;
    open($fh, '>', $f_name_module) or die "Could not open '$f_name_module' $!";
    
    print $fh "package ".$fmodule.";\n\n";
    print $fh "use strict;\n";
    print $fh "use warnings;\n";
    print $fh "use Exporter qw(import);\n";
    print $fh "our \@EXPORT_OK = qw(add multiply);\n";
    
    print $fh "1;\n";
    # Create file .pl
    my $fh1;
    open($fh1, '>', $f_name_test) or die "Could not open '$f_name_test' $!";
    
    my @pl_txt = ( "#!/usr/bin/perl\n", "use strict;\n","use warnings;\n",
        "use File::Basename qw(dirname);\n", "use Cwd qw(abs_path);\n",
        "use lib dirname(dirname abs_path $0) . '/Modul';\n",
        "use Math qw(add);\n", "print \"Salut din perl.\"".";\n");
    print $fh1 @pl_txt;
}
# ================================================================
#   Functia createFile()
# =================================================================
sub createFile {
    print "Enter your file name: ";
    $filename = <STDIN>;
    chomp $filename;
    
    # This changes perl directory  and moves you inside directory.
    chdir( $dir ) or die "Couldn't go inside $dir directory, $!";
    
    my $author = 'Mihai Cornel mhcrnl@gmail.com';
    my $fh;

    open($fh, '>', $filename) or die "Could not open '$filename' $!";

    print $fh "#! /usr/bin/perl\n";
    print $fh "use strict;\n";
    print $fh "use warnings;\n";
    print $fh "use Scalar::Util qw(looks_like_number); #almost always useful\n";
    print $fh "=pod\n";
    print $fh "\t Filename: $filename \n";
    print $fh "\t Autor: '$author'\n";
    print $fh "\t Create time: " . localtime($^T) . "\n";
    print $fh "\t TODO:\n";
    print $fh "=cut\n";
    print $fh "# ===== ENTRY POINT \n"; 
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
    print "4. Create directory.\n";
    print "5. Create README.md.\n";
    print "6. Create gitpush.sh file. \n";
    print "7. Execute command gitpush.sh \n";
    print "8. Create module.\n";
    print "9. Creare class.\n";
    print "10. Close program.\n";
    
    print "Insert your choice(1-9): ";
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
            # === Apelarea functiei createDirectory()
            createDirectory();
        } elsif ($choice == 5){
            # === Apelarea functiei createReadme()
            createReadme();
        } elsif ($choice == 6){
            createGitpush();
        } elsif ($choice == 7) {
            system("./gitpush.sh");
        } elsif ($choice == 8) {
            createModule();
        } elsif ($choice == 9){
            createClass(); 
        } elsif ($choice == 10) {
            exit();
        } else {
            print "Invalid entry try again.";
        }
    }
    print "Executarea programului s-a terminat.End.";
}
#===================================================================
#       Functia createClass()
# ===================================================================
sub createClass{
        print "Insert name of the class (NumeleClasei): ";
        my $numeleClasei = <STDIN>;
        chomp $numeleClasei;
        
        my $obj = new CreateClass($numeleClasei);
        $obj->createClass();
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
# =====================================================================
#    Functia createDirectory() - create a new Directory
# =====================================================================
sub createDirectory {
    print "Enter the name of Directory: ";
    $dir = <STDIN>;
    chomp $dir;
    
    mkdir($dir) or die "Couldn't create $dir directory, $!"; 
    print "Directory created with success!";
}
# =====================================================================
#       Functia createReadme() - create file README.md
# ======================================================================
sub createReadme
{
    my $readme = "README.md";
    my $fr;
    print "$dir\n";
    $dir = cwd; # Intra in directorul curent  
    # This changes perl directory  and moves you inside directory.
    chdir($dir) or die "Couldn't go inside $dir directory, $!"; 
    # This create the file README.md  
    open($fr, '>', $readme) or die "Could not open '$readme' $!"; 
    print $fr "#This is the README file." ;   
    
}
# =========================================================================
#       Functia createGitpush() - create file gitpush.sh
# =========================================================================
sub createGitpush
{
    my $gitpush = "gitpush.sh";
    my $fg;
    $dir = cwd;
    # This changes perl directory  and moves you inside directory.
    chdir($dir) or die "Couldn't go inside $dir directory, $!"; 
    # This create the file README.md  
    open($fg, '>', $gitpush) or die "Could not open '$gitpush' $!"; 
    
    print $fg "#!/bin/bash \n";
    print $fg "DATE=`date` \n";
    print $fg "git add . \n";
    print $fg 'git commit -m "$DATE"';
    print $fg "\n git push origin master \n";
    
    print "$gitpush create with success!!";
}





