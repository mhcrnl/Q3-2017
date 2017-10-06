package Frog;

sub new {
		my($class, %args) = @_;
		bless \%args, $class;
	}
	
sub get {
		my($self, $attr) = @_;
		$self ->{$attr};
	}
	
package main;

my $frog = Frog->new(qw/ -color blue -poisonous 1/);
print "$frog: color=", $frog->get(-color), "\n";