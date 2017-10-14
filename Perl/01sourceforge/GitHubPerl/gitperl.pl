#!/usr/bin/perl

use Net::GitHub::V3;
use v5.010;

# unauthenticated
my $gh = Net::GitHub::V3->new;
my $search = $gh->search;
say $search;
 my $repos = $gh->repos;
 say $repos;
 $repos->set_default_user_repo('fayland', 'perl-net-github');
 
  my @rp = $repos->list_all;
  say @rp;
  my @rp = $repos->list_all(500);
  say @rp;
my @data = @{ $search->repositories({ q => 'docker+created:>2014-09-01',
                                      per_page => 100 })->{items} };
say @data;
while ($search->has_next_page) {
    sleep 12; # 5 queries max per minute
    push @data, @{ $search->next_page->{items} };
}

my %languages;

for my $repo (@data) {
    my $language = $repo->{language} ? $repo->{language} : 'Other';
    $languages{ $language }++;
}

for (sort { $languages{$b} <=> $languages{$a} } keys %languages) {
    printf "%10s: %5i\n", $_, $languages{$_};
}