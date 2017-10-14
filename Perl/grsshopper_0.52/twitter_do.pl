#!/usr/bin/perl

use warnings;
use strict;
use Data::Dumper;
use Net::Twitter;
use Getopt::Long;

my %opts = (
	    username   => 'cultured_perl',
	    maxresults => 15,
	    rpp        => 15,
	   );

GetOptions(
	   \%opts,
	   "passwordfile|pf=s",
	   "username|u=s",
	   "password|p=s",
	   "maxresults|n=i",
	   "rpp|r=i",
	   "post|o=s",
	   "popularity|y",
	   "verbose|v",
	   "help|h",
	  );

if (exists $opts{passwordfile} && !exists $opts{password} )
{
 open PF, "<", $opts{passwordfile} or die "Couldn't open $opts{passwordfile}: $!";
 $opts{password} = <PF>;
 close PF;
 chomp $opts{password};
}

# require the password AND at least one search term OR a post
die usage() unless (defined $opts{password} && exists $opts{post}) || scalar @ARGV;
# handle -h
print usage() && exit(0) if exists $opts{help};

my $handle = Net::Twitter->new({
				username => $opts{username},
				password => $opts{password}
			       });

do_post($opts{post}) if exists $opts{post};

foreach my $term (@ARGV)
{
 do_search($term);
}

sub do_search
{
 my $term = shift @_;

 my $page = 1;
 my @results;

 while (scalar @results < $opts{maxresults})
 {
  my $rset = $handle->search({query=>$term, page => $page, rpp => $opts{rpp} });
  print "Searching for $term (page $page)\n" if $opts{verbose};
  if (ref $rset eq 'HASH' && exists $rset->{results})
  {
   # break out if no results came back
   last unless @{$rset->{results}};
   push @results, @{$rset->{results}};
   printf "Now we have %d entries\n", scalar @results if $opts{verbose};
  }

  # go to the next page
  $page++;
 }

 print_post($_) foreach @results;
} 

{
 my %popularity;			# this hash is scoped to the print_post function only

 sub print_post
 {
  my $t = shift @_;
  
  printf("%s (on %s)\n\t%s\n", $t->{from_user}, $t->{created_at}, $t->{text});
  
  if ($opts{verbose})
  {
   foreach my $key (sort keys %$t)
   {
    my $v = $t->{$key};
    $v = '(UNDEFINED)' unless defined $v;
    print "...$key=$v\n";
   }
  }

  if (exists $opts{popularity})
  {
   my $user = $t->{from_user};
   unless (exists $popularity{$user})
   {
    $popularity{$user} = scalar @{$handle->friends_ids($user)}/2 + 2* scalar @{$handle->followers_ids($user)};
   }

   print "\n\tPOPULARITY for $user = $popularity{$user}\n";

   my $sum = 0;
   $sum += $_ foreach values %popularity;
   
   printf "\tAVERAGE POPULARITY = %.2f\n", $sum / scalar keys %popularity;
  }
 }
}

sub do_post
{
 my $post = shift @_;

 $post = '(UNDEFINED)' unless defined $post;
 my $ret = $handle->update({status => $post});
 warn "Could not post the update" unless defined $ret;
 if ($ret->{text} eq $post)
 {
  print "Successfully posted [$post].\n";
 }
 else
 {
  warn "Posted string [$ret->{text}] is different from given [$post]";
 }
}

sub usage
{
 return <<EOHIPPUS

 $0 [OPTIONS] SEARCH1 [SEARCH2 ...]

Note that you can search without a valid login.

Options:
 --help or -h                    : this help
 --verbose or -v                 : print more verbose output
 --rpp=100 or -r 100             : 100 results per page
 --maxresults=100 or -n 100      : return at most 100 search matches
 --popularity or -y              : analyze user popularity for search results
 --post=NEWS or -o NEWS          : post on Twitter
 --username=NAME or -u NAME      : specify the Twitter username
 --passwordfile=FILE or -pf FILE : specify a file that contains
                                   the Twitter password
 --password=PASS or -p PASS      : specify the Twitter password
EOHIPPUS
}
