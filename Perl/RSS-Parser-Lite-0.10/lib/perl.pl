#! /usr/bin/perl

use Lite;
        use LWP::Simple;
        
        my $xml = get("http://url.to.rss");
        my $rp = new Lite;
        $rp->parse($xml);
        
        print $rp->get('title') . " " . $rp->get('url') . " " . $rp->get('description') . "\n";

        for (my $i = 0; $i < $rp->count(); $i++) {
                my $it = $rp->get($i);
                print $it->get('title') . " " . $it->get('url') . " " . $it->get('description') . "\n";
        }
