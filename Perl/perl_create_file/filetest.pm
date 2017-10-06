#! /usr/bin/perl
package filetest;
use 5.010;
use strict;
use warnings;
our $VERSION = '0.01';
=pod
CONSTRUCTOR
=cut
sub new {
my $class = shift;
my $self  ={
_fileName => shift,
};
bless $self, $class;
return $self;
}
