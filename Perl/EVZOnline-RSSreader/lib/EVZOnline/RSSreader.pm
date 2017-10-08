package EVZOnline::RSSreader;

use 5.018004;
use strict;
use warnings;

use utf8;
use Carp;
use XML::Feed;

our $VERSION = '0.01_01';

sub new {
	my $class = shift;
	my $self={@_};	#hash referance
	bless($self, $class);		#Transformarea referintei in obiect
	#$Population++;
	#push @Everyone, $self;
	$self->_init;
	return $self;		# We send object back
}

# Preloaded methods go here.

my $feed = XML::Feed->parse(URI->new('http://www.evz.ro/rss.xml'))
	or die XML::Feed->errstr;
print "--------------------".$feed->title."-----------------------\n";

for my $entry ($feed->entries) {
	print "TITLUL: ".$entry->title, "\n";
	#print "SUMAR: ".$entry->summary,"\n";
	print  "LINK: ".$entry->link, "\n\n";
	print "-----------------------------------------------------\n";
	#print $entry->base, "\n";
}

1;
__END__
# Below is stub documentation for your module. You'd better edit it!

=head1 NAME

EVZOnline::RSSreader - Perl extension for read Evenimentul Zilei RSSreader
Depends on RSS::Fee

=head1 SYNOPSIS

  use EVZOnline::RSSreader;
  blah blah blah

=head1 DESCRIPTION

Stub documentation for EVZOnline::RSSreader, created by h2xs. It looks like the
author of the extension was negligent enough to leave the stub
unedited.

Blah blah blah.

=head2 EXPORT

None by default.



=head1 SEE ALSO

Mention other useful documentation such as the documentation of
related modules or operating system documentation (such as man pages
in UNIX), or any relevant external documentation such as RFCs or
standards.

If you have a mailing list set up for your module, mention it here.

If you have a web site set up for your module, mention it here.

=head1 AUTHOR

Mihai C, E<lt>mhcrnl@localdomainE<gt>

=head1 COPYRIGHT AND LICENSE

Copyright (C) 2015 by Mihai C

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself, either Perl version 5.18.4 or,
at your option, any later version of Perl 5 you may have available.


=cut
