#!/usr/lib/perl
##              -w -d:ptkdb

=pod

=head1 ctkCommon.pm

	Extension of the main package with common subroutines.

=head2 Programming notes

=over

=item Coding guides

	Subroutines in this extension must be kept very general.



=back

=head2 maintenance

	Author:	MARCO
	date:	01.01.2007
	History
			24.11.2007 mam Refactoring

=cut

package main;

{
sub alltrim {
	return ltrim(rtrim(shift))
}

sub ltrim {
	my $rv = shift;
	$rv =~ s/^\s+//;
	return $rv
}

sub rtrim {
	my $rv = shift;
	$rv =~ s/\s+$//;
	return $rv
}

sub head {
	use File::Basename;
	my ($file) = @_;
	&main::trace("head");
	my $rv;
	my ($base,$path,$type) = fileparse($file);
	$rv = $path;
	return $rv
}

sub tail {
	use File::Basename;
	my ($file) = @_;
	&main::trace("tail");
	my $rv;
	my ($base,$path,$type) = fileparse($file);
	$rv = ($type) ? "$base$FS$type" : $base;
	return $rv
}

sub makeRelative {
	my ($file) = @_;
	&main::trace("makeRelative");
	my $rv;
	return $file unless(File::Spec->file_name_is_absolute( $file ));
	$rv = File::Spec->abs2rel( $file);
	return $rv
}

sub _name {
	my ($file,$folder) = @_;
	my $rv;
	my $FS = ctkFile->FS;
	my @w = split /[\\\/]/ , $file;
	my $n = shift @w;
	while (($n ne $folder) && @w) {
			$n = shift(@w)
	}
	$rv = (@w) ? join($FS,@w) : $file;
	return $rv
	}


sub getDateAndTime {
	my ($now) = shift;
	$now = localtime unless($now);

	my $rv = sprintf('%04d %02d %02d - %02d:%02d:%02d',
			$now->year+1900, $now->mon+1,$now->mday,
			$now->hour, $now->min, $now->sec) ;
	return $rv;
}

sub Log { &main::log(@_)}
sub log {
	map {
		shift @cacheLog if (@main::cacheLog > $main::cacheLogSize );
		push @main::cacheLog, $_;
		print "\n".&main::getDateAndTime().' '.$_
	} @_;

}

sub Trace { &main::trace(@_) }
sub trace {
	&main::log(@_) if ($main::debug);
}

}
1; ## -----------------------------------

