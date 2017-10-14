
=head1 ctkFile

	The class ctkFile provides funtionalities related to files .

=head2 Syntax

	my $f = ctkFile->new([fileName,< file name>][, intent , <intent>] [,debug, <debug mode>]);
	$f->open([<intent>]);
	$f->close();
	$f->lock();
	$f->unlock();

	my $line = $f->get();
	my @lines = $f->get();

	$f->print(<lines>);

	my $fName = $f->normalizeFileName(<file Name>);
	my $head = $f->head(<filename>);
	my $tail = $f->tail(<filename>);

	$f->backup();

=head2 Methods

=over

=item Public methods

	new
	destroy

	fileName

	open
	close

	lock
	unlock

	get
	print

	head
	normalizeFileName
	tail

=item Private methods

	trace

=item Data member

	fileName
	intent
	handle

=item Class member

	debug
	FS

=back

=cut

package ctkFile;

use vars (qw/$VERSION/);

use File::Spec;
use File::Basename;

$VERSION = 1.05;

use constant DEFAULTINTENT => '<';

my $debug = 0;

my $FS = ($^O =~ /win/i) ? '\\' : '/';

sub new {
	my $class = shift;
	my (%args) = @_;
	$class = ref $class || $class;
	my $self = {};
	$debug = delete $args{debug} if (exists $args{debug});
	$self->{fileName} = delete $args{fileName} if (exists $args{fileName});
	$self->{handle} = undef;
	$self->{intent} = DEFAULTINTENT;
	bless $self, $class;
	$self->trace("new $self");
	return $self
}

sub destroy {
	my $self = shift;
	$self->close if(defined($self->{handle}));
	undef $self
}

sub FS {
	return $FS
}

sub fileName {
	my $self = shift;
	$self->{fileName} = shift if(@_);
	return $self->{fileName}
}

sub open {
	my $self = shift;
	my ($intent) = @_;
	my $rv;
	local *H;
	my $fName = $self->fileName;

	return 0 unless(defined($fName) && $fName =~ /\S+/);
	return 0 if(defined ($self->{handle}));
	$intent = $self->{intent} unless(defined($intent));
	return 0 unless ($intent =~ /^(<|>|\+<|\+>)$/);
	$self->{intent} = $intent;
	$self->{handle} = undef;

	$rv = CORE::open(H,"$intent$fName");
	$self->{handle} = *H if ($rv);
	return $rv;
}

sub close {
	my $self = shift;
	return 1 unless(defined ($self->{handle}));
	local *H = $self->{handle};
	CORE::close(H);
	$self->{handle} = undef;
	$self->{intent} = DEFAULTINTENT;
	return 1
}

sub lock {
	my $self = shift;
	my $rv;
	return 0 unless(defined ($self->{handle}));
	local *H = $self->{handle};
	use Fcntl qw(:flock);
	$rv = CORE::flock(H, LOCK_EX);
	return $rv
}
sub unlock {
	my $self = shift;
	my $rv;
	return 1 unless(defined ($self->{handle}));
	local *H = $self->{handle};
	$rv = CORE::flock(H, LOCK_UN);
	return $v
}

sub get {
	my $self = shift;

	$self->open(DEFAULTINTENT) unless( defined($self->{handle}));

	local *H = $self->{handle} if(defined($self->{handle}));

	if (wantarray) {
		return () unless (defined(H));
		my @rv = ();
		while (<H>) {
			push @rv, $_
		}
		return @rv;
	} else {
		my $rv = <H> if (defined(H));
		return $rv;
	}
}

sub print {
	my $self = shift;
	my $rv;

	$self->open('>') unless( defined($self->{handle}));

	local *H = $self->{handle};
	return 0 unless (defined(H));
	map {
		CORE::print H $_ ;
		$rv++
	} @_ ;
	return $rv;
}

sub normalizeFileName { ## this sub works always
	my $self = shift;
	my ($fName) = @_;
	my $rv;
	$self->trace("normalizeFileName");
	$fName = $self->fileName unless(defined($file));
	if ( $fName =~ /[\\\/]/ ) {
		$rv = $fName;
		if ($^O =~/win/i) {
				$rv =~ s/[\\\/]/\\/g;
		} else {
				$rv =~ s/[\\\/]/\//g;
		}
	} else {
		$rv = $fName
	}
	return $rv
}

sub head {
	my $self = shift;
	my ($file) = @_;
	$file = $self->fileName unless(defined($file));
	$self->trace("head");
	my $rv;
	my ($base,$path,$type) = fileparse($file);
	$rv = $path;
	return $rv
}

sub tail {
	my $self = shift;
	my ($file) = @_;
	$file = $self->fileName unless(defined($file));
	$self->trace("tail");
	my $rv;
	my ($base,$path,$type) = fileparse($file);
	$rv = ($type) ? "$base$FS$type" : $base;
	return $rv
}

sub backup {
	my $self = shift;
	my $rv;
	my $file = $self->{fileName};
	if (-f $file) {
		unlink "$file.bak" if (-f "$file.bak");
		rename "$file","$file.bak";
		$self->trace("File '$file' saved as backup");
		$rv = 1
	} else {}
	return $rv
}

sub trace {
	my $self = shift;
	&main::trace(@_) if ($debug);
}
BEGIN {1}
END{1}
1; ## make perl happy ...
