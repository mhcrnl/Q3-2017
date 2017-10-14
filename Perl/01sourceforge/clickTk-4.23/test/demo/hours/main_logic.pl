=head2 

	Subroutines for main.pl

=cut

sub Trace { &main::trace(@_);}
sub trace {
	&main::Log(@_) if ($debug);
}
sub Log { &main::log(@_)}
sub log { 
	map {print "\n$_"} @_;
}
sub thisYear {
	$now = localtime unless(defined($now));
	my $rv = sprintf('%04d',$now->year+1900) ;
	return $rv
}
sub thisMonth{
	$now = localtime unless(defined($now));
	my $rv = sprintf('%04d',$now->mon+1) ;
	return $rv
}
sub thisDay{
	$now = localtime unless(defined($now));
	my $rv = sprintf('%04d',$now->mday) ;
	return $rv
}
sub thisDate{
	$now = localtime unless(defined($now));
	my $rv = sprintf('%02d.%02d.%04d',main::thisDay,main::thisMonth,main::thisYear) ;
	return $rv
}
sub getDateAndTime {
	my ($now) = shift;
	$now = localtime unless(defined($now));
	my $rv = sprintf('%04d %02d %02d - %02d:%02d:%02d', 
				$now->year+1900, $now->mon+1,$now->mday,
				$now->hour, $now->min, $now->sec) ;
	return $rv;
}
1;## make perl happy