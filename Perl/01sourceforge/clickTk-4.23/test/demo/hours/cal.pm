
=pod

=head1 Class cal

	The class cal provides some calendar functions.


=head2 Syntax

	use cal;

	my $name = cal::dayName('Feb', 14);

	my $im = cal::indexOfMonth('Feb');

	my $days = cal::daysOfMonth('Feb');

	my $m1 = cal::indexOfMonthDay1('Feb');

=head2 Programming notes

=over

=item Data members

	Data members are class data member and read-only.

		@month      list of the number of days per month,
		@monthName  list of the month names,
		@day        list of the day names,

		$jan1       weekday of the first da of the year, (1 .. 7).

		debug       activate debg mode (0,1)

=item Constructor & desctructor

	No specific processing.

=item Methods

	dayName          the name of the given couple (month,day number) 
	indexOfMonth     0..11 index of the given month name
	daysOfMonth      28..31, number of days of the given month
	indexOfMonthDay1 1-7, weekday of the 1st day of the given month 

=item Limited to one year (currently 2007)

=back

=head2 Maintenance

	Author:	MARCO
	date:	28.11.2006
	History 
			28.11.2006 MO00001 mam First draft
			11.02.2007 MO00002 mam 2007

=cut

package cal;

our $VERSION = 1.02;

our $debug = 0;

our @month = (31,28,31,30,31,30,31,31,30,31,30,31);
our @monthName =(qw/Januar Februar März April Mai Juni Juli August September Oktober November Dezember/);
our @day =(qw/Montag Dienstag Mittwoch Donnerstag Freitag Samstag Sonntag/);

our $jan1 = 1;		## 2007
our $year = 2007;

BEGIN {}
END{}

sub _weekday {
	my ($i) = @_;
	my $rv = $i % 7;
	$rv = 7 unless ($rv);
	return $rv;
}

sub dayName {
	my ($thisMonth,$i) = @_;
	my $m1 = indexOfMonthDay1($thisMonth);

	my $rv = $day[_weekday($m1+ $i) - 1];
	return $rv;
}

sub indexOfMonth {
	my ($thisMonth) = @_;
	my $rv;
	for (my $i = 0;$i < 12 ; $i++) {
		if ($monthName[$i] =~ /^$thisMonth/i) {
			$rv = $i;
			last
		}
	}
	return $rv
}
sub daysOfMonth {
	my ($thisMonth) = @_;
	my $rv;
	$rv = $month[indexOfMonth($thisMonth)];
	return $rv;
}
sub indexOfMonthDay1 {
	my ($thisMonth) = @_;
	my $rv = 0;
	my $i = indexOfMonth($thisMonth);
	while($i-- > 0) {
		$rv += $month[$i]
	}
	$rv = _weekday($jan1 + $rv);
	return $rv;
}
1; ## -----------------------------------

