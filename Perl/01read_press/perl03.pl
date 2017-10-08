#!/usr/bin/perl -w
# guardian-list -- list Guardian articles matching keyword

use XML::RSSLite;
use LWP::Simple;
use strict;
use utf8;

# list of keywords we want
my @keywords = qw(perl internet porn iraq Sofi bush);

# get the RSS
my $URL = 'http://evz.ro/rss.xml';
my $content = get($URL);
#print "$content";

# parse the RSS
my %result;
parseRSS(\%result, \$content);

# build the regex from keywords
my $re = join "|", @keywords;
$re = qr/\b(?:$re)\b/i;

my $fh;
my $filem = "text.txt";
open($fh, '>', $filem) or die "Could not open '$filem' $!";

# print report of matching items
foreach my $item (@{ $result{items} }) {
  my $title = $item->{title};
  my $description = $item->{description};
  $title =~ s{\s+}{ };  $title =~ s{^\s+}{  }; $title =~ s{\s+$}{  };
    print $fh "$title\n\t$item->{link}\n\n$description";
  if ($title =~ /$re/) {
    print "$title\n\t$item->{link}\n\n";
  }
}
__END__
# Below is stub documentation for your module. You'd better edit it!

=head1 NAME

EVZOnline::RSSreader - Perl extension for read Evenimentul Zilei RSSreader
Depends on RSS::Feed

=head1 SYNOPSIS

   $ perl perl03.pl
  

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
