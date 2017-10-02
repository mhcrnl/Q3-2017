#! /usr/bin/perl
package Person;
# This is the CONSTRUCTOR
sub new{
    my $class = shift;
    my $self = {
        _firstName => shift,
        _lastName => shift,
        _cnp => shift,
    };
    
    print "First name is $self->{_firstName}\n";
    print "Last name is $self->{_lastName}\n";
    print "CNP is $self->{_cnp}\n";
    bless $self, $class;
    return $self;
}
################################################################
sub setFirstName{
    my($self, $firstName) = @_;
    $self->{_firstName} = $firstName if defined($firstName);
    return $self->{_firstName};
}
#################################################################
sub getFirstName {
    my ($self) = @_;
    return $self->{_firstName};
}
#################################################################
sub run_main{
    my $object = new Person("Vasile", "cornel", 12345667);
}

1;
