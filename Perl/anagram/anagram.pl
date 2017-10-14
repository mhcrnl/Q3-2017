#!/usr/bin/perl

# $getwordlistcommand 
# 	This command will extract the necessary word list to construct anagrams.
# 	If the aspell package is installed, use "aspell dump master" to use the 
# 	default word list or "aspell dump master wordlist" to use another.
# 	Aspell has many word lists available.
#	Check dir /usr/lib/aspell/ to see which lists have been installed.
# $getwordlistcommand = "aspell dump master";			# default language
# $getwordlistcommand = "aspell dump master dutch";
# $getwordlistcommand = "aspell dump master nederlands"; 	# same as dutch
# $getwordlistcommand = "aspell dump master english.multi";
# $getwordlistcommand = "cat /home/bert/mywordlist";		# use Bert's word list
$getwordlistcommand = "aspell dump master";

# If the input text is longer than 20 characters, an override is needed.
$inputlimit = 20;

# Don't split the input up in more than 3 words.
$maxlevel = 3;

# Set autoflush on. Output will be visible without delay.
$| = 1;

print "anagram.pl v0.1 - © 2001-2002 Onno Zweers.\n";
print 'Visit http://sourceforge.net/projects/kanagram/ for more info.' . "\n";

$startingtime = time;

#	No parameters? Help text.
if (!@ARGV) {
  $this_script = $0;		# What is the name of this script?
  $this_script =~ s#.*/##g;	# Remove path name, keep only file name
  print "\n$this_script usage:\n";
  print "$this_script [-o]  text\n";
  print "  -o = override input limit. Processing may take a very long time.\n\n";
  print "Example:\n";
  print "  $this_script Onno Zweers\n";
  print "  $this_script -o William Shakespeare\n";
  die "\n";
}

$input = lc join(' ', @ARGV);

#	Does the user want to override the input limit?
$input =~ s/\s+(\-o)\s+//;
$override = ($1 eq '-o');
if ($override) { print "Override of input limit requested.\n"; }

#	The rest of the input parameters is food for anagrams.
#	Remove all white spaces from the input.
$input =~ s/\s//g;

$input = &sortletters($input);
#	Replace characters like e-accents and ,.?!
$input =~ s/[öòóô]/o/g;
$input =~ s/[ëèéê]/e/g;
$input =~ s/[üùúû]/u/g;
$input =~ s/[áàäâ]/a/g;
$input =~ s/[ïìíî]/i/g;
$input =~ s/[ñ]/n/g;
$input =~ s/[ç]/c/g;
$input =~ s/[`'"!?]//g;

#	Check for unexpected characters in input.
if ($input =~ m/([^a-z])/) {
  print "\nWarning: Unexpected character \"$1\" found in \"$input\".\n";
}

#	Check input limit.
unless ($override) {
  if (length($input) > $inputlimit) {
    die "Input has more than $inputlimit characters. It may take a VERY long time. Use -o to override.\n";
  }
}

#	We put the letters of the input in an array for faster calculations.
@inputletters = split(//, $input);

# Perhaps we can remove this...
@subgroups = &lettersubgroups($input);

#	Now check the list of subgroups against the word list.
#	We need to read the word list into an array, but only the words
#	that could be made from the user input.

print "Loading word list...\n";
$word_number = 0;
$words_loaded = 0;
WORD: foreach $word (split(/\n/, `$getwordlistcommand`)) {
  $word_number++;
  #	Show the user that we are doing something.
  if ($word_number % 10000 == 0) { print "."; }
  $_ = $word;
  next WORD if /^#/;	# If word begins with a # we skip it.
  s/^\s*//;
  s/\s*$//;
  s/[`'"\!\?\-\(\)\.]//g;
  s/\s//g;
  next WORD if ($_ eq ""); 
  next WORD if (length($_) > length($input));
  $_ = lc;		# Lower case for processing.
  s/[öòóô]/o/g;		# Remove accents
  s/[ëèéê]/e/g;
  s/[üùúû]/u/g;
  s/[Ü]/u/g;
  s/[áàäâ]/a/g;
  s/[ïìíî]/i/g;
  s/[ñ]/n/g;
  s/[ç]/c/g;
  if (/([^a-z])/) {
    print "\nWarning: Unexpected character \"$1\" found in word \"$word\" in the wordlist.\n";
  }
  if (&is_subgroup_of_inputletters($_,$input)) {
    #	This word can be made from the letters of the input text.
    #	We save this word to our selected word list for further use.
    $lettergroup = &sortletters($_);
    if ($wordlist{$lettergroup} eq "") {
      $wordlist{$lettergroup} = $word;
    } else { 
      $wordlist{$lettergroup} .= '/' . $word;
    }
    $words_loaded++;
  }
}
print "\n$words_loaded relevant words selected from $word_number words in word list.\n";
print "Now analysing input \"$input\".\n";


#	The lettergroups that make words are now in %wordlist.

#	Take the lettergroups that make words and sort the by length.
#	The longest first. We will use this in the subroutine for 
#	checking anagrams.
@selectedlettergroups = sort {length($b) <=> length($a)} keys %wordlist;



#	The following subroutine is recursive: it calls itself.
#	Parameters: 
#	 - the remaining letters
#	 - the anagram so far
#	 - the level of recursion
&checkforanagrams($input, "", 1);


#	If there are anagrams, they are now in array @anagrams.

#	Filter out the double solutions and print output.
$number_of_anagrams = 0;
$previousanagram = '';
foreach $anagram (sort @anagrams) {
  if ($anagram ne $previousanagram) {
    print "$anagram\n";
    $number_of_anagrams++;
  }
  $previousanagram = $anagram;
}

print "\nNumber of anagrams found: $number_of_anagrams.\n";

#	Calculate how much time it took.
$endtime = time;
$duration = $endtime - $startingtime;
($sec, $min, $hour, $mday, $month, $year, $wday, $ydag, $something) = gmtime($duration);
$sec += (60 * $min) + (3600 * $hour);
print "This took $sec seconds.\n";


###########################################
#                                         #
#          S U B R O U T I N E S          #
#                                         #
###########################################


sub sortletters {
  #	Turns "fart" into "afrt". Why? It smells better.
  my $word = shift(@_);
  #	How does the next statement work?
  #	First: string $word is split into an array of letters.  		onno -> o n n o
  #	Second: the array is sorted with the sort statement.			o n n o -> n n o o
  #	Then the array elements are joined together with '' (nothing) as glue.	n n o o -> nnoo
  #	Lastly, the output is returned to the caller of this subroutine.
  return join ('', sort split(//, $word));
}



sub checkforanagrams {
  my $availableletters = shift(@_);
  my $anagramsofar = shift(@_);
  my $level = shift(@_) + 1;	# We are now 1 level deeper.
  if (&already_checked($availableletters)) { return };
  foreach $lettergroup (@selectedlettergroups) {
    #	Does this lettergroup take more letters than available? Then skip.
    if (length($lettergroup) > length($availableletters)) {
      next; 
    }
    #
    #	Compare this lettergroup with the available letters.
    ($excessletters, $remainingletters)  = &delete_equal_letters ($lettergroup, $availableletters);
    #
    #	Does this lettergroup use letters that are not available?
    #	Then skip to the next lettergroup.
    if ($excessletters ne "") {
      next;
    }
    #	Do we have letters left?
    if ($remainingletters ne "") {
      #		Can the remaining letters make a word? 
      #		Then we have an anagram.
      if ($wordlist{$remainingletters} ne "") {
        &save_anagram($anagramsofar, $lettergroup, $remainingletters);
      }
      #		Anagram or not, if there's 2 or more letters left, we can
      #		try to run them through this routine again to search for anagrams.
      #		The next special case for length = 2 speeds up the program
      #		a little bit (a few % at most).
      if (length($remainingletters) == 2) {
        my ($part1, $part2) = split (//, $remainingletters);
        if (($wordlist{$part1} ne "") and ($wordlist{$part2} ne "")) {
          &save_anagram ($anagramsofar, $lettergroup, $part1, $part2);
        }
      }
      if (length($remainingletters) > 2) {
        if ($level < $maxlevel) {
          &checkforanagrams ($remainingletters, $anagramsofar . '|' . $lettergroup, $level);
        }
      }
    } else {
      #	No, we don't have any letters left. It means that we have an anagram.
      &save_anagram ($anagramsofar, $lettergroup);
    }
  }
  #	We have finished with these available letters. Mark them as checked.
  #	Why marking? For not checking the same combination twice.
  &mark_checked ($availableletters);
}


sub save_anagram {
  #	There can be 2 or 3 parameters. Possibly one of them
  #	consists of more than 1 lettergroup, separated by '|'.
  #	We split all letter groups for sorting.
  my $unsorted_anagram = join ('|', @_);
  my @lettergroups = split (/\|/, $unsorted_anagram);
  my @words = ();
  foreach (@lettergroups) {
    if ($_ ne "") {
      push @words, $wordlist{$_};
    }
  }
  my $sorted_anagram = join(" ", sort @words), "\n";
  push @anagrams, $sorted_anagram;
}


sub mark_checked {
  #	If we have checked a group of available letters,
  #	this subroutine will mark it as having been checked.
  $checked{$_[0]} = 1;
}


sub already_checked {
  #	If this combination of available letters has been checked already,
  #	we don't have to check it again.
  return $checked{$_[0]};
}


sub delete_equal_letters {
  #	Compares two strings and erases the 
  #	letters that are in both strings.
  #	For instance:
  #	two strings "onno" and "sunny" will be
  #	changed into "oo" and "suy"
  my @letters1 = split(//, $_[0]);
  my @letters2 = split(//, $_[1]);
OUTER: for ($c1 = 0; $c1 < (@letters1); $c1++) {
INNER:   for ($c2 = 0; $c2 < (@letters2); $c2++) {
           if ($letters1[$c1] eq $letters2[$c2]) {
             #	We have found here two letters that
             #	are the same. We will replace them
             #	by an empty string.
             $letters1[$c1] = ""; 
             $letters2[$c2] = "";
             #	We'll move on to the next letter
             #	of the first string.
             next OUTER;
           }
         }  
       }
  #	Now we'll put the letters that remain
  #	back into the parameters.
  return (join('', @letters1), join('', @letters2));
}


sub is_subgroup_of_inputletters {
  #	Compares a string with the input and says "true" if  
  #	the letters in the string are a 
  # 	subset of the letters in the input.
  #	For instance:
  #	"abc"  and "abcde" = true;
  #	"abcf" and "abcde" = false;
  #	"abbc" and "abcde" = false.
  my $inputletters = $input;
  foreach $letter (split(//, $_[0])) {
    # Try to remove this letter from the second string.
    # If it fails, the parameter is not a subgroup of the inputletters.
    if (($inputletters =~ s/$letter//) == 0) {
      return 0;
    }
  }
  return 1;
}


sub OLD_is_subgroup_of_inputletters {
  # Don't use this one, it's slow!
  #	Compares two sorted strings and says true if  
  #	the letters in the first string are a 
  # 	subset of the letters in the second.
  #	For instance:
  #	"abc"  and "abcde" = true;
  #	"abcf" and "abcde" = false;
  #	"abbc" and "abcde" = false;
  #	"cba"  and "abcde" = false (because we assume sorted strings!)
  my @letters1 = split(//, $_[0]);
  my @letters2 = @inputletters;
OUTER: for ($c1 = 0; $c1 < (@letters1); $c1++) {
INNER:   for ($c2 = 0; $c2 < (@letters2); $c2++) {
           if ($letters1[$c1] eq $letters2[$c2]) {
             #	We have found here two letters that
             #	are the same. We will replace them
             #	by an empty string.
             $letters1[$c1] = ""; 
             $letters2[$c2] = "";
             #	We'll move on to the next letter
             #	of the first string.
             next OUTER;
           }
         }
         #	We didn't find a matching letter in second letterset.
         #	We might as well exit now.
         return 0;
       }
  #	Equal letters are eleminated.
  #	First string should be empty. Then it is a subset.
  return (length(join('', @letters1)) == 0);
}


sub lettersubgroups {
  my $lettergroup = shift(@_);
  my @letters = split(//, $lettergroup);
  foreach $letter (@letters) {
    $lettercount{$letter}++		# onno -> n=2, o=2
  }
  my $numberofcombinations = 1;
  my @letterlist = ();
  my @aantallen = ();
  foreach $letter (sort keys %lettercount) {
    push @letterlist, $letter;				#  n, o
    push @aantallen, $lettercount{$letter};		#  2, 2
    $numberofcombinations = $numberofcombinations * ($lettercount{$letter} + 1);	#  9 = (2+1) * (2+1)
  }
  $numberofcombinations--;		#  8 = 9 - 1   (n, nn, nno, nnoo, no, noo, o, oo, but an empty string doesn't count!)
  my $aantalletters = (@letters);	#  4  (n, n, o, o)
  my $aantalverschillendeletters = (@letterlist);	#  2  (n, o)
  #	First combination: no letters selected.
  my @sel = ();
  #	The list with subgroups is empty. We're going
  #	to fill it now.
  my @subgroups = ();
  #	Bekijk alle mogelijke combinaties van letters.
  for ($c = 0; $c < $numberofcombinations; $c++) {
    $subgroup = '';
    $remainingletters = '';
    $overflow = 1;
    # Bekijk voor alle verschillende letters hoeveel we er selecteren.
    for ($i = 0; $i < $aantalverschillendeletters; $i++) {
      if ($overflow == 1) {
        # Is voor deze letter het hoogste aantal bereikt?
        if ($sel[$i] == $aantallen[$i]) {
          $sel[$i] = 0;   # aantal voor deze letter terug op nul
          # $overflow blijft 1: aantal voor volgende letter ophogen
        } else {
          $sel[$i]++;     # aantal voor deze letter ophogen
          $overflow = 0;  # andere aantallen met rust laten
        }
      }
      # Lettergroup opbouwen: deze letter * het geselecteerde aantal.
      for ($n = 0; $n < $aantallen[$i]; $n++) {
        #	Is this letter among the selected?
        if ($n < $sel[$i]) { 
          #	Yes, add it to the selected letters.
          $subgroup .= $letterlist[$i];
        } else {
          #	No, add it to the remaining letters.
          $remainingletters .= $letterlist[$i];
        }
      }
    }
    #	Combination of letters found.
    #	If the wordlist is loaded, we'll check this lettergroup.
    #	If not, we assume it is OK. The wordlist will 
    #	be loaded later.
    if ($wordlistloaded eq "yes") {
      #	Is this lettergroup in the wordlist?
      if ($wordlist{$subgroup} ne "") {
        push @subgroups, "$subgroup $remainingletters";
      }
    } else {
      push @subgroups, "$subgroup $remainingletters";
    }
  }  
  return sort @subgroups;
}




sub checkremaininglettergroup {
  #	Input for this subroutine is something like this:
  #	checkedlettergroup1|checkedlettergroup2 remainingletters
  #	(Notice the | and the space!)
  #	This subroutine is called recursively, until there
  #	are not enough letters remaining to be checked.
  my $input = $_[0];
  my ($checkedlettergroups, $remainingletters) = split (/ /, $input);
  if (length($remainingletters) == 0) {
    $newanagram = join ("|", sort split (/\|/, $checkedlettergroups));
    push @anagrams, $newanagram;
  } else {
    #	There are 1 or more remaining letters.
    if ($wordlist{$remainingletters} ne "") {
      $checkedlettergroups .= "|" . $remainingletters;
      $newanagram = join ("|", sort split (/\|/, $checkedlettergroups));
      push @anagrams, $newanagram;
    }
    if (length($remainingletters) > 1) {
      #	There are 2 or more remaining letters.
      #	We can split them up in different subgroups.
      @subgroups = &lettersubgroups ($remainingletters);
      foreach (@subgroups) {
        #  $_ has the format "checkedlettergroup remainingletters".
        #  We put the previously checked lettergroups in front
        #  of it and we call this same subroutine recursively.
        #  The parmameters will be:
        #  checkedlettergroup1|chkltrgrp2|chkltrgrp3 remainingletters
        &checkremaininglettergroup ($checkedlettergroups . "|" . $_);
      }
    }
  }
}










