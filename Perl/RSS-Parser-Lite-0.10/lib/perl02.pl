#!/usr/bin/perl -w
# guardian-list -- list Guardian articles matching keyword

use XML::RSSLite;
use LWP::Simple;
use strict;

# list of keywords we want
my @keywords = qw(perl internet porn iraq Sofi bush);

# get the RSS
my $URL = 'http://www.guardian.co.uk/rss/1,,,00.xml';
my $content = get($URL);
#print "$content";

# parse the RSS
my %result;
parseRSS(\%result, \$content);

# build the regex from keywords
my $re = join "|", @keywords;
$re = qr/\b(?:$re)\b/i;

# print report of matching items
foreach my $item (@{ $result{items} }) {
  my $title = $item->{title};
  $title =~ s{\s+}{ };  $title =~ s{^\s+}{  }; $title =~ s{\s+$}{  };
    print "$title\n\t$item->{link}\n\n";
  if ($title =~ /$re/) {
    print "$title\n\t$item->{link}\n\n";
  }
}
