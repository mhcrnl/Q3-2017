#!/usr/bin/perl -w

use strict;
use LWP::Simple;
my $html = get("http://www.amazon.com/exec/obidos/ASIN/1565922433")
  or die "Couldn't fetch the Perl Cookbook's page.";
  #print "$html";
  
 $html =~ m{Amazon\.com Sales Rank: </b> ([\d,]+) </font><br>};
my $sales_rank = $1;
$sales_rank =~ tr[,][]d;    # 4,070 becomes 4070

print "$sales_rank\n";