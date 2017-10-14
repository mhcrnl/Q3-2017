=pod

=head1 spreadsheet

	This class models an easy spreadsheet mainly to build
	simple tables to be imported into EXCEL using the
	CSV file model.

	Unlike EXCEL cells are addressed using standard perl indices (row,column).

	Each cell have two parts

		- the value part which contains the computed value of the cell and
		- the cell part which contains the entered value, which may be an
		  expression (formula) which yields the value part.

	Formula may apply two syntax modes
		- PERL formulas are perl code snipped which may be evaluated
		       inside this class. Whithin formulas cells are identified by
			   $self->value(<row>,<col>) whereby <row>,<col> may be integers or the variable $row resp. $col
			   for the current row resp. column .

		- EXCEL formulas apply the syntax of EXCEL.

	The syntax mode is declared at construction time and it is valid
	for all cells.

	Formula of type PERL may be converted to EXCEL a) replacing the messages value or cell 
	with message xcell, b) executing the converted formula and c) saving the resulted string
	into the cell part by means of a cell message.

=head2 Methods

	autoCalc    property, update all values after each cell update.
	syntax      property, cell syntax mode

	new         constructor
	destroy     destructor

	cell        return the cell part of the given cell
	evalCell    evaluate the given cell part and return its value
	fill        fill the given value into the given cell range
	load        load the instance from FS
	save        save the instance to FS
	sum         return the summ of the given cell range
	update      update all cells
	value       return the current value of the given cell
	writeCsv    write all cell values as a CD^SV file into FS.
	xcell       build xcel compatible cell addres using ARRAY indices (row,col)
	xcellRange  build a cell range using EXCEL syntax i.e. A1:B2 

=head2 Maintenance

	Author:	MARCO
	date:	10.05.2005
	History 
			10.05.2005 MO00001 mam First draft
			27.11.2006 Upgrade, version 1.03

=cut

package spreadsheet;

$debug = 0;

use base (qw/csv/);

use vars qw/$VERSION/;

$VERSION = 1.03;

sub _debug { shift; @_ ? $debug = shift : $debug }

sub autoCalc {shift->{_autoCalc}}
sub syntax {shift->{_syntax}}
sub cells {shift->{_s}}
sub values {shift->{_v}}

sub new {
	my ($class) = shift;
	my (%args) = @_;
	$class = ref($class) || $class;
	$debug = $args{debug} if (exists $args{debug});
	my $self = $class->SUPER::new(%args);
	$self->{_autoCalc} = 0;
	$self->{_autoCalc} = delete $args{autocalc} if exists $args{autocalc};
	$self->{_syntax} = 'PERL';
	$self->{_syntax} = uc(delete $args{syntax}) if exists $args{syntax};
	die "Unallowed syntax argument value" unless $self->syntax =~ /^(perl|excel)$/i;
	$self->{_s} = [];
	$self->{_v} = [];
	$self->load(delete $args{load}) if exists $args{load};
	return $self;
}

sub destroy {
	my $self = shift;
	$self->SUPER::destroy(@_);
	$self ={};
}

sub evalCell {
	my $self = shift;
	my ($row,$col) = @_;
	my $w = $self->cells->[$row][$col];
	my $rv =  $self->cells->[$row][$col];
		if ($w =~ /^\s*=(.+)\s*$/) {
			if ($self->syntax eq 'PERL') {
				$rv = eval $1;
				if ($@) {
					warn " cell $row,$col : $@" ;
					undef $rv
				} ## else {}
			} elsif ($self->syntax eq 'EXCEL') {
				## TODO: parse and execute formula
				warn"syntax EXCEL not yet supported, formula not evaluated."
			} else {}
		} ## else {}
	return $rv ;
}

sub xcell {
	my $self = shift;
	my ($row,$col) = @_;
	my $xcol='ABCDEFGHIGKLMNOPQRSTUVWXYZ';
	my $rv;
	$row++;
	$rv = substr($xcol,$col,1).$row;
	return $rv
}

sub xcellRange {
	my $self = shift;
	my ($fromRow,$fromCol,$toRow,$toCol) = @_;
	my $rv;
	$rv = $self->xcell($fromRow,$fromCol).':'.$self->xcell($toRow,$toCol);
	return $rv
}

sub value {
	my $self = shift;
	my ($row,$col) = @_;
	return $self->values->[$row][$col] if defined ($self->values->[$row][$col]);
	$self->values->[$row][$col] = $self->evalCell($row,$col) if defined ($self->cells->[$row][$col]);
	return $self->values->[$row][$col] if defined ($self->values->[$row][$col]);
	return '';
}

sub cell {
	my $self = shift;
	my ($row,$col) = @_;
	return $self->cells->[$row][$col] if(@_ == 2);
	$self->cells->[$row][$col] = $_[2];
	$self->update() if $self->autoCalc;
	return $self->cells->[$row][$col]
}

sub fill {
	my $self = shift;
	my ($row0,$col0,$row1,$col1,$value) = @_;
	for (my $i = $row0; $i <= $row1 ;$i++) {
		for (my $j = $col0; $j <= $col1 ;$j++) {
			$self->cell($i,$j,$value);
		}
	}
	$self->update() if $self->autoCalc;
	return 1
}

sub sum {
	my $self = shift;
	my ($row0,$col0,$row1,$col1) = @_;
	my $rv = 0;
	for (my $i = $row0; $i <= $row1 ;$i++) {
		for (my $j = $col0; $j <= $col1 ;$j++) {
			my $w = $self->evalCell($i,$j,$value);
			$rv += $w if ($w =~ /^\s*\d*\.*\d+\s*$/);
		}
	}
	return $rv;
}

sub update {
	my $self = shift;
	my $rv = 1;
	my $w = $self->cells;
	my ($row,$col);
	for ($row=0;$row < scalar(@$w) ;$row++) {
		for ($col = 0;$col < scalar(@{$w->[$row]}) ;$col++) {
			$self->values->[$row][$col] = $self->evalCell($row,$col);
			$rv = undef unless defined $self->values->[$row][$col];	## temp 28.11.2006
		}
	}
	return $rv;
}

sub save {
	my $self = shift;
	my ($fName) = @_;
	local *FILE;
	open FILE,"> $fName";
	my $w = $self->cells;
	for (my $i=0;$i < scalar(@$w) ;$i++) {
		for (my $j = 0;$j < scalar(@{$w->[$i]}) ;$j++) {
			print FILE "$i , $j |",$self->cell($i,$j),"\n";
		}
	}
	close FILE;
	return 1
}

sub load {
	my $self = shift;
	my ($fName) = @_;
	my $rv;
	local *FILE;
	my ($i,$j,$content);
	return $rv unless open FILE,"< $fName";
	$self->{_s}=[];
	while(<FILE>) {
		chomp;
		if (($i,$j,$content) = /^\s*(\d+)\s*,\s*(\d+)\s*\|(.*)$/) {;
			$self->cell($i,$j,$content);
		} else {
			warn "could not process '$_'";
			$rv = undef
		}
	}
	close FILE;
	$rv = 1;
	$self->update() if $self->autoCalc;
	return $rv
}

sub writeCsv {
	my $self = shift;
	my ($csv,$fName) = @_;

	$csv = $self->convert2Csv($self->cells) unless(defined($csv));
	return $self->SUPER::writeCsv($csv,$fName);
}

1; ## make perl happy ...!
