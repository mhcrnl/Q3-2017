
=pod

=head1 Class csv

	The class csv models the files of type CSV.
	It provides methods to create CSV files.

=head2 Syntax

=head3 Methods

	new         constructor
	destroy     destructor

	delimiter   property 
	quoted      property

	quoteValue  returns quoted column depending on property 'quoted'
	convert2Csv convert the given array to a CSV 
	emptyRow    returns a row of empty columns
	emptyCsv    returns a CSV file content of empty rows
	writeCsv    writes the given file content to FS

=head2 programming notes

=over

=item None

=back

=head2 Maintenance

	Author:	MARCO
	date:	09.05.2005
	History 
			09.05.2005 MO00001 mam First draft
			28.11.2006 MO00001 mam Upgrade

=cut

package csv;

$debug = 0;

use vars qw/$VERSION/;

$VERSION = 1.02;

sub new {
	my ($class) = shift;
	my (%args) = @_;
	$class = ref($class) || $class;
	my $self = {qw/delimiter ; hwnd 0 quoted 0/};
	$self = bless $self , $class;
	$self->{hwnd} = delete $args{hwnd} if (exists $args{hwnd});
	$self->{delimiter} = delete $args{delimiter} if (exists $args{delimiter});
	$self->{quoted} = delete $args{quoted} if (exists $args{quoted});
	$debug = $args{debug} if (exists $args{debug});
	return $self;
}

sub destroy {
	my $self = shift;
	$self ={};
}

sub _debug { shift; @_ ? $debug = shift : $debug }

sub delimiter { shift->{delimiter}}

sub quoted { shift->{quoted}}

sub quoteValue {
	my $self = shift;
	my ($rv) = @_;
	$rv = $self->quoted.$_.$self->quoted if $self->quoted;
	return $rv;
}

sub convert2Csv {
	my $self = shift;
	my ($s) = @_;
	my $rv = [];
	my $delimiter = $self->delimiter;
	map {
		my $row = $_;
		my $line = '';
		map {
			$line .=  $self->quoteValue($_).$delimiter 
		} @$row;
		$line =~ s/.$//;
		push @$rv , $line;
	} @$s;
	return $rv;
}
sub emptyRow {
	my $self = shift;
	my ($size,$value, $delimiter) = @_;
	my $rv = '';
	$delimiter = $self->delimiter unless defined $delimiter;
	map {$rv .= "$value $delimiter" }1..$size;
	$rv =~ s/.$//;
	return $rv
}

sub emptyCsv {
	my $self = shift;
	my ($size, $rowSize,$value, $delimiter) = @_;
	my $rv = [];
	$delimiter = $self->delimiter unless defined $delimiter;
	map {push @$rv, $self->emptyRow($rowSize,$value, $delimiter)} 1..$size;
	return $rv;
}

sub writeCsv {
	my $self = shift;
	my ($csv,$fName) = @_;
	local *CSV;
	return undef unless(@$csv);
	$fName .='.csv' unless $fName =~ /\.\w+$/;
	open CSV, ">$fName" || die "Could not open '$fName'";
	map {print CSV "$_\n"} @$csv;
	close CSV;
	return 1;
}

1; ## make perl happy ...!
