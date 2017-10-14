
=pod

=head1 Class hours

	This class generates an empty spreadsheet to enter project's
	expenses (time) while of the given month.
	Of course it generates formula to compute dayly, weekly and
	monthly totals.

=head2 Syntax

	my $sheet = hours->new(year => <year>, month => <month>);

	$sheet->generate();

	$sheet->writeCsv(undef,<file name>);

	$sheet->destroy;

=head2 Programming notes

=over

=item Base classes

		- csv
		- spreadsheet

=item Used classes

	cal

=item Exceptions

	- not supported year
	- IO

=item Unit tests

	See script csv.pl , subroutine main::DoTest6

=back

=head2 Maintenance

	Author:	Marco
	date:	29.11.2006
	History
			29.11.2006 First draft
			28.02.2007 version 1.02

=cut

package hours;

use base (qw/spreadsheet/);

use Time::localtime;

our $VERSION = 1.02;

our $debug = 0;

sub new {
	my $class = shift;
	my (%args) = @_;
	$class = ref($class) || $class ;
	my $self = $class->SUPER::new(%args);
	$self->_init(%args);

	return $self
}

sub destroy {
	my $self = shift;
	$self->SUPER::destroy(@_);
}

sub year {return shift->{_year}}
sub month {return shift->{_month}}

sub _init {
	my $self = shift;
	my (%args) = @_;
	$self->{_syntax} = 'EXCEL';
	$self->{_year} = delete $args{year} if exists $args{year};
	$self->{_month} = delete $args{month} if exists $args{month};
	die "year not supported, pls check package cal!" unless int($cal::year) == int($self->year);
	return 1
}

sub generate {
	my $self = shift;
	my ($year, $thisMonth) = @_;
	my $rv;

	$year = $self->year unless defined $year;
	$thisMonth = $self->month unless defined $thisMonth;

	if ($self->_generate($year,$thisMonth)) {
		$thisMonth = $cal::monthName[cal::indexOfMonth($thisMonth)];
		$self->writeCsv(undef,"$thisMonth$year");
		main::log("spreadsheet successfully exported to '$thisMonth$year'");
		$rv = 1
	}
	return $rv
}

sub _generate {
	my $self = shift;
	my ($jahr, $thisMonth) = @_;
	my $rv;

	my $SUM = 'SUM';	## 'SUMME'
	my $sheet = $self;

	my $im = 0;
	my $m1 = 0;
	my $days = 0;
	$im = cal::indexOfMonth($thisMonth);
	$days = cal::daysOfMonth($thisMonth);
	$m1 = cal::indexOfMonthDay1($thisMonth);
	$thisMonth = $cal::monthName[$im];

	$self->trace("Doing _generate using ","im = $im, jan1 = $cal::jan1, m1 = $m1 $cal::day[$m1-1]");

	$sheet->fill(0,0,(1 + 2 * $days + 1) - 1,9,'');
	my $w =sprintf('%02d.%04d',$im+1,$jahr);

	my $d = 0;
	my $sum;
	$sheet->cell($d,0,'Row');
	$sheet->cell($d,1,'Date');
	$sheet->cell($d,2,'weekday');
	$sheet->cell($d,3,'From');
	$sheet->cell($d,4,'To');
	$sheet->cell($d,5,'Other');
	$sheet->cell($d,6,'M&EDoc');
	$sheet->cell($d,7,'Activity');
	$sheet->cell($d,8,'Hours/day');
	$sheet->cell($d,9,'Hours/week');
	$d++;
	$sum =$d;
	map {
		$sheet->cell($d,0,sprintf('%02d',$d));
		$sheet->cell($d,1,sprintf('%02d.%s',$_+1,$w));
		$sheet->cell($d,2,cal::dayName($thisMonth,$_));
		$sheet->cell($d,3,'9');
		$sheet->cell($d,4,"12");
		$sheet->cell($d,5,"0");
		$sheet->cell($d,6,"=".$sheet->xcell($d,4)." - ".$sheet->xcell($d,3));
		$sheet->cell($d,7,"Activity");
		$sheet->cell($d,8,' ');
		$sheet->cell($d,9,' ');
		$d++;
		$sheet->cell($d,0,sprintf('%02d',$d));
		$sheet->cell($d,1,'      ');
		$sheet->cell($d,2,'      ');
		$sheet->cell($d,3,'='.$sheet->xcell($d-1,4)." + 1");
		$sheet->cell($d,4,"17");
		$sheet->cell($d,5,"0");
		$sheet->cell($d,6,"=".$sheet->xcell($d,4)." - ".$sheet->xcell($d,3));
		$sheet->cell($d,7,"Activity");
		$sheet->cell($d,8,"=$SUM(".$sheet->xcellRange($d-1,5,$d,6).')');
		if ($sheet->value($d-1,2) =~/sonntag/i) {
			$sheet->cell($d,9,"=$SUM(".$sheet->xcellRange($sum,8,$d,8).')');
			$sum = $d;
			$sum++
		} else {
			$sheet->cell($d,9,' ');
		}
		$d++
	} 0..$days-1 ;
	$sheet->cell($d,0,sprintf('%02d',$d));
	$sheet->cell($d,1,'      ');
	$sheet->cell($d,2,'      ');
	$sheet->cell($d,3,'    ');
	$sheet->cell($d,4,'    ');
	$sheet->cell($d,5,'    ');
	$sheet->cell($d,6,'    ');
	$sheet->cell($d,7,'            ');
	$sheet->cell($d,8,'            ');
	if ($d != $sum) {
		$sheet->cell($d,9,"=$SUM(".$sheet->xcellRange($sum,8,$d,8).')');
	} else {
		$sheet->cell($d,9,' ');
	}
	$sum = $d;
	$d++;
	$sheet->cell($d,0,sprintf('%02d',$d));
	map{$sheet->cell($d,$_,$sheet->cell($d-1,$_))} 1..8;
	$sheet->cell($d,1,'Total');
	$sheet->cell($d,9,"=$SUM(".$sheet->xcellRange(1,9,$sum,9).')');

	if ($sheet->update()) {
		my $w = $sheet->cells;
		my $lw = scalar(@$w); $lw--;
		map {
			my $i = $_;
			my $s = sprintf('%3s',$sheet->value($i,0));
			map {
				$s .= "\t".sprintf('%12s',$sheet->value($i,$_))
			} 1..9;
			$self->trace("\t$i $s")
		} 0..$lw;
		$rv = 1;
	} else {
		$self->log("There are errors in the spreadsheet, pls check cell formulas!");
		$rv = 0
	}
	return $rv
}
sub Trace { shift->trace(@_);}
sub trace {
	shift->log(@_) if ($debug);
}

sub Log { shift->log(@_)}
sub log {
	my $self = shift;
	map {print "\n\t".$self->getDateAndTime()." $_"} @_;
}

sub getDateAndTime {
	my $self = shift;
	my $now = shift;
	$now = localtime unless(defined($now));

	my $rv = sprintf('%04d %02d %02d - %02d:%02d:%02d',
				  $now->year+1900, $now->mon+1,$now->mday,
				  $now->hour, $now->min, $now->sec) ;
	return $rv;
}

## sub import {}

BEGIN { 1 }
END {1 }

1; ## -----------------------------------
