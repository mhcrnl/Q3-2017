=head1 ctkNumEntry

	Interface composite NumEntry:

	- provide some standard messages
	- set up argument list
	- send message to constructor
	- validate arguments

=cut

package ctkNumEntry ;

use vars (qw/$VERSION/) ;


$VERSION = 1.01;

use NumEntry 1.04;

sub numEntry {
	my ($parent,%par) = @_;
	&main::trace("numEntry");
	$par{-maxvalue} = 9999 unless (exists $par{-maxvalue});

	return $parent->NumEntry(%par);
}

sub numEntryPercent {			## n MO02303
	my ($parent,%par) = @_;
	&main::trace("numEntryPercent");
	$par{-maxvalue} = 100 unless (exists $par{-maxvalue} && $par{-maxvalue} <= 100);
	$par{-incvalue} = 2 unless (exists $par{-incvalue});

	return $parent->NumEntry(%par);
}

sub numEntry01 {			## n MO02303
	my ($parent,%par) = @_;
	&main::trace("numEntry01");
	$par{-maxvalue} = 1 unless (exists $par{-maxvalue}&& $par{-maxvalue} <= 1);
	$par{-incvalue} = 0.05 unless (exists $par{-incvalue});
	$par{-width} = 5 unless (exists $par{-width});

	return $parent->NumEntry(%par);
}
##
BEGIN {1}
END {1}
1; ## make perl compiler happy
