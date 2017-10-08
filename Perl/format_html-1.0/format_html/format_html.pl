#!/usr/bin/perl

#
# indent_html.pl
#
# Made by (Julien Mulot)
# Copyright Julien Mulot
# Login   <mulot_j@epita.fr>
#
# Started on  Fri Dec 15 11:43:26 2000 Julien Mulot
# Last update Fri Dec 15 11:43:26 2000 Julien Mulot
#
# License GPL

#VERSION 1.0

use strict;

my	$space_char = " ";
my	@list_tag_expect = ('BR', 'HR', 'P', 'META', '!DOCTYPE', 'IMG');

my	@list_tag;
my	$space;
my	$all = 0;
my	$is_comment = 0;

&main();


sub	main
  {
    unless (defined($ARGV[0]))
      {
	print STDOUT "you must specifie a file in argument\n";
	exit;
      }
    else
      {
	foreach (@ARGV)
	  {
	    if (-f $_)
	      {
		parse($_);
	      }
	    elsif ($_ eq "-a")
	      {
		$all = 1;
	      }
	    else
	      {
		print STDERR "$_ is not a file or does not exist\n";
	      }
	  }
      }
  }


sub	parse
  {
    my	($file) = @_;
    my	$line;

    open(HTML, "$file") || die("cannot open $file : $!");
    open(NEW, ">$file$$") || die("cannot create $file$$ : $!");
    while ($line = <HTML>)
      {
	if (($line =~ /<!--/) || ($line =~ /<\?/))
	  {
	    $is_comment = 1;
	  }
	if (($line =~ /-->/) || ($line =~ /\?>/))
	  {
	    $is_comment = 0;
	  }
	unless ($is_comment)
	  {
	    $line =~ s/^\t+//;
	    $line =~ s/^ +//;
	    $line =~ s/(<.*?>)/&my_uc($1)/eg;
	    $line = replace_special_char($line);
	    $line = indent_html($line);
	  }
	print NEW $line;
      }
    close(NEW);
    close(HTML);
    rename($file, "$file.bak");
    rename("$file$$", $file);
  }


sub	indent_html
  {
    my	($line) = @_;
    my	$result;
    my	$tag;
    my	$elt;
    my	$line2;
    my	$tag2;
    my	$i;

    if (($line =~ /^</) && ($line !~ /^<!--/))
      {
	unless (&is_tag_expect($line))
	  {
	    if ($line =~ /^<\// )
	      {
		($tag) = $line =~ /^<\/(\w+)/;
		$i = $#list_tag;
		foreach $elt (reverse (@list_tag))
		  {
		    if ($elt =~ /^$tag\s*/)
		      {
			($space) = $elt =~ /^$tag(\s+)/;
			splice(@list_tag, $i, 1);
			last;
		      }
		    $i--;
		  }
		if (defined($space))
		  {
		    $result = "$space" . "$line";
		  }
		else
		  {
		    $result = $line;
		  }
	      }
	    else
	      {
		if (defined($space))
		  {
		    $result = "$space" . "$line";
		  }
		else
		  {
		    $result = $line;
		  }
		($tag) = $line =~ /^<(\w+)/;
		if ($line !~ /<\/$tag>\s+$/)
		  {
		    if (defined($space))
		      {
			$tag = "$tag" . "$space";
		      }
		    else
		      {
			$tag = "$tag";
		      }
		    push(@list_tag, $tag);
		    $space .= $space_char;
		  }
		elsif ($all)
		  {
		    ($line2) = $line =~ /^<(.*?)>/;
		    $tag2 = $tag;
		    if (defined($space))
		      {
			print NEW "$space" . "<$line2>\n";
			$tag = "$tag" . "$space";
		      }
		    else
		      {
			print NEW "<$line2>\n";
			$tag = "$tag";
		      }
		    push(@list_tag, $tag);
		    $space .= $space_char;
		    ($line2) = $line =~ /^<$tag2.*?>(.*)<\/$tag2>\s+$/;
		    print NEW &indent_html("$line2\n");
		    $result = &indent_html("</$tag2>\n");
		  }
	      }
	  }
	else
	  {
	    if (defined($space))
	      {
		$result = "$space" . "$line";
	      }
	    else
	      {
		$result = $line;
	      }
	  }
      }
    else
      {
	$result = "$space" . "$line";
      }
    return ($result);
  }


sub	my_uc
  {
    my	($str) = @_;
    my	@string;

    if ($str !~ /^<!--/)
      {
	if ($str =~ /".*"/)
	  {
	    @string = $str =~ /"(.*?)"/g;
	    $str =~ s/".*?"/"#"/g;
	    $str = uc($str);
	    foreach (@string)
	      {
		$str =~ s/"#"/"$_"/;
	      }
	    #print "@string\n";
	  }
	else
	  {
	    $str = uc($str);
	  }
      }
    return ($str);
  }


sub	replace_special_char
  {
    ($_) = @_;

    s/&#39;/'/g;     # Remise des apostrophes normales
      s/�/&iexcl;/g;   # 161
    s/�/&cent;/g;    # 162
    s/�/&pound;/g;   # 163
    s/�/&curren;/g;  # 164
    s/�/yen;/g;      # 165
    s/�/brvbar;/g;   # 166
    s/�/&sect;/g;    # 167
    s/�/&uml;/g;     # 168
    s/�/&copy;/g;    # 169
    s/�/&ordf;/g;    # 170
    s/�/&laquo;/g;   # 171
       s/�/&not;/g;     # 172
       s/�/&shy;/g;     # 173
       s/�/&reg;/g;     # 174
       s/�/&macr;/g;    # 175
       s/�/&deg;/g;     # 176
       s/�/&plusmn;/g;  # 177
       s/�/&sup2;/g;    # 178
       s/�/&sup3;/g;    # 179
       s/�/&acute;/g;   # 180
       s/�/&micro;/g;   # 181
       s/�/&para;/g;    # 182
       s/�/&middot;/g;  # 183
       s/�/&cedil;/g;   # 184
       s/�/&sup1;/g;    # 185
       s/�/&ordm;/g;    # 186
       s/�/&raquo;/g;   # 187
    s/�/&frac14;/g;  # 188
    s/�/&frac12;/g;  # 189
    s/�/&frac34;/g;  # 190
    s/�/&iquest;/g;  # 191
    s/�/&Agrave;/g;  # 192
    s/�/&Aacute;/g;  # 193
    s/�/&Acirc;/g;   # 194
    s/�/&Atilde;/g;  # 195
    s/�/&Auml;/g;    # 196
    s/�/&Aring;/g;   # 197
    s/�/&AElig;/g;   # 198
    s/�/&Ccedil;/g;  # 199
    s/�/&Egrave;/g;  # 200
    s/�/&Eacute;/g;  # 201
    s/�/&Ecirc;/g;   # 202
    s/�/&Euml;/g;    # 203
    s/�/&Igrave;/g;  # 204
    s/�/&Iacute;/g;  # 205
    s/�/&Icirc;/g;   # 206
    s/�/&Iuml;/g;    # 207
    s/�/&ETH;/g;     # 208
    s/�/&Ntilde;/g;  # 209
    s/�/&Ograve;/g;  # 210
    s/�/&Oacute;/g;  # 211
    s/�/&Ocirc;/g;   # 212
    s/�/&Otilde;/g;  # 213
    s/�/&Ouml;/g;    # 214
    s/�/&times;/g;   # 215
    s/�/&Oslash;/g;  # 216
    s/�/&Ugrave;/g;  # 217
    s/�/&Uacute;/g;  # 218
    s/�/&Ucirc;/g;   # 219
    s/�/&Uuml;/g;    # 220
    s/�/&Yacute;/g;  # 221
    s/�/&THORN;/g;   # 222
    s/�/&szlig;/g;   # 223
    s/�/&agrave;/g;  # 224
    s/�/&aacute;/g;  # 225
    s/�/&acirc;/g;   # 226
    s/�/&atilde;/g;  # 227
    s/�/&auml;/g;    # 228
    s/�/&aring;/g;   # 229
    s/�/&aelig;/g;   # 230
    s/�/&ccedil;/g;  # 231
    s/�/&egrave;/g;  # 232
    s/�/&eacute;/g;  # 233
    s/�/&ecirc;/g;   # 234
    s/�/&euml;/g;    # 235
    s/�/&igrave;/g;  # 236
    s/�/&iacute;/g;  # 237
    s/�/&icirc;/g;   # 238
    s/�/&iuml;/g;    # 239
    s/�/&eth;/g;     # 240
    s/�/&ntilde;/g;  # 241
    s/�/&oacute;/g;  # 243
    s/�/&ocirc;/g;   # 244
    s/�/&otilde;/g;  # 245
    s/�/&ouml;/g;    # 246
    s/�/&divide;/g;  # 247
    s/�/&oslash;/g;  # 248
    s/�/&ugrave;/g;  # 249
    s/�/&uacute;/g;  # 250
    s/�/&ucirc;/g;   # 251
    s/�/&uuml;/g;    # 252
    s/�/&yacute;/g;  # 253
    s/�/&thorn;/g;   # 254
    s/�/&yuml;/g;    # 255
    $_;
  }


sub	is_tag_expect
  {
    my	($line) = @_;

    foreach (@list_tag_expect)
      {
	if ($line =~ /^<$_/)
	  {
	    return (1);
	  }
      }
    return (0);
  }
