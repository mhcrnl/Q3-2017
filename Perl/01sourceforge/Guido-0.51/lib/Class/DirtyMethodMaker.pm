# MODINFO module Class::DirtyMethodMaker
package Class::DirtyMethodMaker;

# MODINFO dependency module strict
use strict;

use vars qw( @ISA );
# MODINFO dependency module Class::MethodMaker
use Class::MethodMaker;
@ISA = qw( Class::MethodMaker );
#use base qw ( Class::MethodMaker );

# MODINFO dependency Carp
use Carp qw( carp cluck croak );

sub get_set {
	my $class = shift;
	my %results;

	foreach my $name (@_) {
		#print "Creating method named $name\n";
	
		$results{$name} = sub {
			my ($self, $new) = @_;
			my $diff;
			if (defined $new && $new ne $self->{$name}) {$diff = 1;}
			if (defined $new) {
				$self->{$name} = $new;
				$self->{dirty} = 1 if $diff;
			}
			$self->{$name};
		};
	}

	$results{dirty} = sub {
			my ($self, $new) = @_;
			$self->{dirty} = 0 if !defined($self->{dirty});

			if (defined $new) {
				$self->{dirty} = $new;
			}
			$self->{dirty};
	};
	$class->install_methods(%results);
}

sub hash {
  my ($class, @args) = @_;
  my %methods;

  foreach (@args) {
    my $field = $_;

    $methods{$field} =
      sub {
        my ($self, @list) = @_;
        defined $self->{$field} or $self->{$field} = {};
        if (scalar @list == 1) {
          my ($key) = @list;

          if ( my $type = ref $key ) {
            if ( $type eq 'ARRAY' ) {
              return @{$self->{$field}}{@$key};
            } elsif ( $type eq 'HASH' ) {
              while (my ($subkey, $value) = each %$key ) {
                if ( $^W ) {
                  defined $value
                    or carp "No value for key $subkey of hash $field.";
                }
                $self->{$field}->{$subkey} = $value;
                $self->{dirty} = 1;
              }
              return wantarray ? %{$self->{$field}} : $self->{$field};
            } else {
              cluck "Not a recognized ref type for hash method: $type.";
            }
          } else { # $key is simple scalar
              return $self->{$field}->{$key};
          }
        } else {
          while (1) {
            my $key = shift @list;
            defined $key or last;
            my $value = shift @list;
            defined $value or carp "No value for key $key.";
            $self->{$field}->{$key} = $value;
            $self->{dirty} = 1;
          }
          return wantarray ? %{$self->{$field}} : $self->{$field};
        }
      };

    $methods{$field . "_keys"} =
      sub {
        my ($self) = @_;
        keys %{$self->{$field}};
      };

    $methods{$field . "_values"} =
      sub {
        my ($self) = @_;
        values %{$self->{$field}};
      };

    $methods{$field . "_exists"} =
      sub {
        my ($self) = shift;
        my ($key) = @_;
        return
          exists $self->{$field} && exists $self->{$field}->{$key};
      };

    $methods{$field . "_tally"} =
      sub {
        my ($self, @list) = @_;
        defined $self->{$field} or $self->{$field} = {};
        map { ++$self->{$field}->{$_} } @list;
      };

    $methods{$field . "_delete"} =
      sub {
        my ($self, @keys) = @_;
        delete @{$self->{$field}}{@keys};
      };

    $methods{$field . "_clear"} =
      sub {
	my $self = shift;
	$self->{$field} = {};
      }
  }
  $class->install_methods(%methods);
}

1;

__END__

=head1 NAME

Class::DirtyMethodMaker - MethodMaker that supplies a dirty method automatically

=head1 SYNOPSIS

use Class::DirtyMethodMaker get_set => [ qw / working_dir name type primary_source_file file_path plugin_data startup_file / ];
use Class::DirtyMethodMaker hash => [qw / source_files used_modules required_files support_files /];

=head1 DESCRIPTION

Class::DirtyMethodMaker is just like Class::MethodMaker with the addition of a special automatically added method called "dirty" which is automatically set to 1 if any other get/set method in the object is used to modify data.  It is meant to allow easy monitoring of an object's data set.

No methods in the class are meant to be called as methods.  They are meant to called in the same format as Class::MethodMaker during the import of the class.

=head1 KNOWN ISSUES

None known at this time

=head1 AUTHOR

jtillman@bigfoot.com

=head1 SEE ALSO

perl(1).

=cut
