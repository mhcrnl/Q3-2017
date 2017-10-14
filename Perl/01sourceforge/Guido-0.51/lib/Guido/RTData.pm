# MODINFO module Guido::RTData Manager for real time data such as recently access files, etc.
package Guido::RTData;
# MODINFO dependency module XML::Simple
use XML::Simple;

# MODINFO constructor new
# MODINFO paramhash attribs
# MODINFO key file_path STRING Path to the file in which to store/retrieve the data
sub new {
	my($class, %attribs) = @_;
	my $self = {
		file_path => $attribs{file_name},
	};
	$self->{data} = XMLin($self->{file_path});
	return bless $self => $class;
}
 
# MODINFO method data Store and retrieve data from the RTData set
# MODINFO param key STRING Name of the key value to retrieve
# MODINFO param value STRING Value to store in the key (optional)
# MODINFO retval STRING
sub data {
	my($self, $key, $value) = @_;
	return undef if !$key;
	if($key and $value) {
		$self->{data}->{$key} = $value;
		$self->save;
	}
	return $self->{data}->{$key};
}

# MODINFO method delete Remove a value from the RTData set.  Returns the deleted value
# MODINFO param key STRING Name of the key to delete
# MODINFO retval STRING
sub delete {
	my($self, $key) = @_;
	my $deleted = delete $self->{data}->{$key};
	$self->save;
	return $deleted;
}

# MODINFO method save Persists the RTData set to file.  (1=success/0=failure)
# MODINFO retval INTEGER
sub save {
	my($self) = @_;
	return XMLout($self->{data}, rootname=>'realtime_data', xmldecl=>1, outputfile=>$self->{file_path}) or return 0;
}

1;

__END__


=head1 NAME

Guido::RTData - Manages real time data such as recently accessed files, etc. in XML format

=head1 SYNOPSIS

  use Guido::RTData;
  my $rt = new Guido::RTData(file_path=>'rtdata.cfg');

=head1 DESCRIPTION

Real time data is really anything that needs to be kept up to date at any given moment during Guido's current session without requiring the user to explicitly save the data.  Things that don't need to be saved immediately should be placed in the main configuration data set.

=head1 INTERFACE

=head1 KNOWN ISSUES

None currently.

=head1 AUTHOR

jtillman@bigfoot.com

=head1 SEE ALSO

perl(1).

=cut
