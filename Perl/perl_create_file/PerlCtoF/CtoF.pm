#! /usr/bin/perl
# declaratia de pachet pt a crea o clasa
package CtoF;

use strict;
use warnings;
use Scalar::Util qw(looks_like_number); #almost always useful
=pod
	 Filename: CtoF.pl 
	 Autor: 'Mihai Cornel mhcrnl@gmail.com'
	 Create time: Tue Oct  3 14:25:12 2017
	 TODO:
=cut
=pod
    Constructor
=cut
sub new{
    my $class = shift;
    my $self = { _celsius => shift, };
    
    bless $self, $class;
    return $self;
}
=pod
    functia care calculeaza conversia
=cut
sub convertCtoF{
    my($self) =@_;
    return ($self->{_celsius}*9/5 + 32);
}
# ===== ENTRY POINT 
print "Salut din perl\n";
