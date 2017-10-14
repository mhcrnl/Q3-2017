#!/usr/lib/perl
##              -w -d:ptkdb

=pod

=head1 ctkImages

	This class models the operations of clickTk with
	images.

=head2 Programming notes

=over

=item Methods

	loadAll

=items Globals


=back

=head2 maintenance

	Author:	MARCO
	date:	01.01.2007
	History
			06.12.2007 refactoring
			14.03.2008 version 1.03

=cut

package ctkImages;

our $VERSION = 1.03;

our $debug = 0;

my $FS = ctkFile->FS;

=head2 loadImages

=cut

sub loadAll {
	my $self = shift;
	my ($folder) = @_;
	my $rv = {};
	my $mw = &main::getmw;
	&main::trace("loadAll");
	$folder = '.' unless(defined($folder));
	local *DIR;
	opendir(DIR, $folder) || return undef;
	my @wPics;
	my $f;
	@wPics = grep {
			/\w+\.(gif|xpm)$/
			} sort readdir(DIR);
	closedir DIR;
	foreach (@wPics) {
		$f = "$folder$FS$_";
		s/\.(gif|xpm)$//;
		$rv->{lc($_)} = $mw->Photo(-file=>$f) unless exists $rv->{lc($_)};
	}
	return $rv;
}

sub fileSelect {
	my $self = shift;
	my ($hwnd,$file) = @_ ;

	&main::trace("fileSelect");

	$file = ctkProject->fileName('*.gif') unless(defined($file));
	$file = ctkProject->fileName('*.gif') unless(-f $file);
	$file =~ s/^\s+//;
	$file =~ s/\s+$//;

	# open file dialog box
	if($^O =~ /(^mswin)|(^$)/i) {
		$file =~ s/\//\\/g;
		my @types = ( ["Bitmap",'.bmp'],["gif",'.gif'],["XPM",'.xpm'], ["All files", '.*'] );
		$file = $hwnd->getOpenFile(-filetypes => \@types,
					-initialfile => $file,
					-defaultextension => '.gif',
					-title => &std::_title('Select image file name.'));
	} else {
		$file =~ s/\\/\//g;		## i MO03602
		my $initialDir = ctkFile->head($file);
		$file = $hwnd->FileSelect(-directory => $initialDir,
					-initialfile => $file,
					-title=>&std::_title('Select image file name.'))->Show;
	}
	return ($file) ? $file : undef;
}

1; ## -----------------------------------

