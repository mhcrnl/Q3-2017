#! /usr/bin/perl
package Person;
# This is the CONSTRUCTOR
sub new{
    my $class = shift;
    my $self = {
        _firstName => shift,
        _lastName => shift,
        _ssn => shift,
    };
    
    print "First name is $self->{_firstName}\n";
    print "Last name is $self->{_lastName}\n";
    print "CNP is $self->{_ssn}\n";
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
#################################################################
sub setLastName{
    my($self, $lastName) = @_;
    $self->{_lastName} = $lastName if defined ($lastName);
    return $self->{_lastName};
}
##################################################################
sub getLastName{
    my($self)=@_;
    return $self->{_lastName};
}
##################################################################
sub getSSN{
    my($self)=@_;
    return $self->{_ssn};
}
#################################################################
sub setSSN{
    my($self, $ssn)=@_;
    $self->{_ssn} = $ssn if defined ($ssn);
    return $self->{_ssn};
}
#################################################################
sub afisare{
    my ($self) = @_;
    return $self->{_firstName}." ".$self->{_lastName}." ".
            $self->{_ssn};
}
1;
