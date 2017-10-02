#! /usr/bin/perl
use warnings;
use strict;
use Scalar::Util qw(looks_like_number);  #almost always useful

=pod
        my multi-line documentation 
        what does this solution do?
        what parameters are needed?
        TODO
        clean and easy to maintain; suck it, Python and Java
=cut

my %appstrs = ( #maintain strings in one place; you will thank me

 appdesc => "This solution does something useful.",
 appauthdesc => "I coded this in 2017.",
 apphelp => "This solution takes some parmeters.",
 appmsgTODO => "This feature is not implemented yet."
);

#======= SUBROUTINES
sub main {     # use a main sub to control scope
 doInfoMsg($appstrs{appdesc});
 doInfoMsg($appstrs{appauthdesc});
 doInfoMsg($appstrs{apphelp}); 
 doDbgMsg(__LINE__.": ". $appstrs{appmsgTODO});  
}
sub doMsg { my $m=shift; print "$m\n"; }    
sub doDbgMsg { my $m=shift; doMsg("DBG: (".__LINE__.") ". $m);}
sub doInfoMsg { my $m=shift; doMsg("INFO: ". $m);}

#======= ENTRY POINT
doInfoMsg($0 . " start " . localtime($^T));
main(); 
doInfoMsg($0 . " end " . localtime(time) . " (" . (time-$^T) ." seconds)");
