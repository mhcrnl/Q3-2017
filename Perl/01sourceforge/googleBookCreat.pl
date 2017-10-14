#!/usr/bin/perl
# Dan's Google Journal Book Creator
# Author: Daniel Graham 3/16/2012
# Copyright (c) Daniel Edward Graham 3/16/2012-3/16/2013
# License: LGPL 3.0 
#
# known to work with Linux (Fedora) and Perl 5.12.2
#
# How to use:
# 
# Journals should be in the ./JOURNAL/* directory.
# File names should be like:
# J120315.txt   For March 15, 2012 journal.
# In the journal file itself, use something like 
# the following at the top:
#
# TPEW
# 5:00 PM CST, March 15, 2012, Thursday
# 361 Jefferson Street, Natchitoches, LA 71457
# sitting in living room
# Daniel Graham 
#
# Pictures should be in ./PICTURES/* directory
# Captions for pictures should have same filename, 
# except with extension ".txt"
#
# Usage:
# ./googleBookCreat.pl 070304 100323 
#
# This creates three Google books (PDF's) with Table of Contents
# ./mybook1/mybook1.pdf (journals through 3/4/2007)
# ./mybook2/mybook2.pdf (journals through 3/23/2010)
# ./mybook3/mybook3.pdf (rest of journals)
#
# expects ./PICTURES/logo0.jpg
#         ./PICTURES/logo1.jpg
#         ./PICTURES/logo2.jpg
# for cover logos
#
# It requires the "htmldoc" program
# available at http://www.htmldoc.org 
#
# Note: one would need to change author, title, etc.
# information in the code, below.
# License: Free to use, modify, or distribute 
#
# 
use strict;
use warnings;
use CGI qw(escapeHTML);
use File::Basename qw(basename);
use File::Copy qw(copy);

use open ':encoding(utf8)';

my @book_arr = glob("./JOURNAL/J*");
@book_arr = sort @book_arr;
my @picture_arr = glob("./PICTURES/*.*");
my $book_num = 0;
my @html_book;
my @TOC;
my @SMIL;
my @OPF;
my @NCX;

my ($toc, $tocf, @INNERLIST, %INDEX, $il, $il2, $TOC);

my $title = "Voyages of the Dawn Treader Volume XXVOLXX";
my $author = "Daniel Edward Graham";
my $header = "<html><head><title>$title</title></head><body><h1>$title</h1>XXTOCXX";
$header .= "<h2>Introduction</h2>";
$header .= "<br><br> The events portrayed in this novel are fiction. Any correspondence with reality is purely coincidental";
$header .= "<br><br> Thought of this title on December 20, 2012 while appreciating the dawn, from the window, at 361 Rue Jefferson";
$header .= "<br><br> This is an unedited version of Rainbow, Sunshine, and Stars (prayers included)";
$header .= "<br><br> Rainbow, Sunshine, and Stars (my wife)<br>Rainbow => The atmospheric event like I witnessed leaving work in Deerfield, IL while talking to my wife on the phone.<br>Sunshine => The sun is described at twilight in the events<br>Stars => Reminds me of how when I was homeless in Cleveland in 2003, I saw a star, planet, or satellite and imagined it was my wife's mother watching over me from China. Also, the star my wife and I saw from TJ Park in Irving, TX one year.<br><br>Do Your Ears Hang Low? => A song from the boy-scouts that my father and I used to sing.<br><br>In this book you will learn the following:<br>1. What it is like to be a struggling software engineer.<br>2. Now successfully taking less antipsychotic medication<br>3. Successfully quit smoking over a year ago.<br>4. See in pictures the places I have travelled.<br><br>Published by Daniel E. Graham (First Team Software)<br>P.O. Box 360053<br>Milpitas, CA<br>95036<br><br>Copyright 2004-2012 All Rights Reserved.<br>";
$header .= "<br><br>See <a href=\"http://www.firstteamsoft.com\">http://www.firstteamsoft.com</a> for eBook publishing services.";
$header .= "<br><br>From Natchitoches meat pies to crawfish po-boys. Twilight at a Natchitoches mansion.";
$header .= "From dining in Manhattan to a private view of the majestic Cathedral of St. Paul";
$header .= "These are the travels, love stories, and ponderings of a Perl engineer.";
$header .= "From his entrepreneurial ideas, to family stories, to his reuniting with his wife.<br><br>";
$header .= "<br><br> Also the author of the infamous <a href=\"http://www.zoomoliun.com\">zoomoliun.com</a> blog.";
my $last_place = "";
my $html_text = $header;
unlink "tmp.txt";
foreach my $j (@book_arr) {
    system("dos2unix -n $j tmp.txt > /dev/null 2>&1");
    wait;
    open (INFILE, "tmp.txt") or print $j."\n";
    my $text = join("", <INFILE>);
    close(INFILE);
    unlink "tmp.txt";
    $text = escapeHTML($text);
    my ($time, $place, $event, $whom) = ("", "", "", "");
    if ($text =~ /^TPEW.*?\n(.*?)\n(.*?)\n(.*?)\n(.*?)\n/) {
        ($time, $place, $event, $whom) = ($1, $2, $3, $4); 
    }
    $text =~ s/TPEW.*?\n(.*?)\n(.*?)\n(.*?)\n(.*?)\n/TPEW<br>$1<br>$2<br>$3<br>$4<br><br>/g;
    $text =~ s/([^\n])\n([^\n\d])/$1 $2/g;
    my $place_cmp = lc($place);
    $place_cmp =~ s/^([^\,]+).*$/$1/g;
    $place_cmp =~ s/pkwy\./parkway/g;
    $place_cmp =~ s/ave\./avenue/g;
    $place_cmp =~ s/st\./saint/g;
    $place_cmp =~ s/w\./w/g;
    $place_cmp =~ s/place\: *//g;
    if ($place_cmp ne $last_place) {
         $html_text .= "<h2>".$place."</h2>";
         $last_place = $place_cmp;
    }
    $html_text .= "<h3>".$time."</h3>" if ($time);
    $text =~ s/\n/\<br\>/g;
#    $text =~ s/Dear\sJesus.*?Amen//gi;
    $html_text .= $text; 
    if ($book_num <= $#ARGV && $j =~ /$ARGV[$book_num]/) {
        $html_text .= "<h2>PICTURES</h2>";
        foreach my $p (@picture_arr) {
            my $caption = "";
            next if ($p =~ /\.txt$/ || $p =~ /logo\d\.jpg/);
            my $c = $p;
            $c =~ s/\.[^\.]+$/\.txt/g;
            if (-e $c) {
                open(IN, $c);
                $caption = join("", <IN>);
                close(IN);
            }
            $caption =~ s/\n/\<br\>/g;
            $html_text .= "<img src=\"".basename($p)."\"/><br><br>";
            $html_text .= $caption."<br><br>"; 
        }
        $html_text .= "</body></html>";
        my $old_html = $html_text;
        ($TOC, $html_text) = buildHtmlToc($html_text, "mybook".($book_num+1).".htm");
        $TOC[$book_num] = "<html><head></head><body>".$TOC."</body></html>";
        $TOC[$book_num] =~ s/href\=\"/href\=\"XXSRCXX/g;
        $OPF[$book_num] = buildOpf();
        $SMIL[$book_num] = buildSmil();
        $NCX[$book_num] = buildNcx($old_html);
        my $vol = $book_num + 1;
        $html_text =~ s/XXVOLXX/$vol/;
        $html_text =~ s/XXVOLXX/$vol/;
#        $html_text =~ s/XXTOCXX/$TOC/;
        $html_text =~ s/XXTOCXX//;
        $html_book[$book_num++] = $html_text;
        $html_text = $header;
    }
}
$html_text .= "<h2>PICTURES</h2>";
foreach my $p (@picture_arr) {
    my $caption = "";
    next if ($p =~ /\.txt$/ || $p =~ /logo\d\.jpg/);
    my $c = $p;
    $c =~ s/\.[^\.]+$/\.txt/g;
    if (-e $c) {
        open(IN, $c);
        $caption = join("", <IN>);
        close(IN);
    }
    $caption =~ s/\n/\<br\>/g;
    $html_text .= "<img src=\"".basename($p)."\"/><br><br>";
    $html_text .= $caption."<br><br>"; 
}
$html_text .= "</body></html>";
my $old_html = $html_text;
($TOC, $html_text) = buildHtmlToc($html_text, "mybook".($book_num+1).".htm");
$TOC[$book_num] = "<html><head></head><body>".$TOC."</body></html>";
$TOC[$book_num] =~ s/href\=\"/href\=\"XXSRCXX/g;
$OPF[$book_num] = buildOpf();
$SMIL[$book_num] = buildSmil();
$NCX[$book_num] = buildNcx($old_html);
my $vol = $book_num + 1;
$html_text =~ s/XXVOLXX/$vol/;
$html_text =~ s/XXVOLXX/$vol/;
$html_text =~ s/XXTOCXX/$TOC/;
$html_book[$book_num++] = $html_text;

for (my $i = 0; $i < @html_book; $i++) {
    mkdir "./mybook".($i+1);
    unlink "./mybook".($i+1)."/*.*";
    my $outfile = "./mybook".($i+1)."/mybook".($i+1).".htm";
    open(OUTFILE, ">$outfile");
    print OUTFILE $html_book[$i];
    close(OUTFILE);
    $outfile = "./mybook".($i+1)."/mybook".($i+1).".opf";
    open(OUTFILE, ">$outfile");
    print OUTFILE fixtag($OPF[$i], "mybook".($i+1).".htm", "logo".$i.".jpg", $i+1);
    close(OUTFILE);
    $outfile = "./mybook".($i+1)."/rs.smil";
    open(OUTFILE, ">$outfile");
    print OUTFILE fixtag($SMIL[$i], "mybook".($i+1).".htm", "logo".$i.".jpg", $i+1);
    close(OUTFILE);
    $outfile = "./mybook".($i+1)."/toc.ncx";
    open(OUTFILE, ">$outfile");
    print OUTFILE fixtag($NCX[$i], "mybook".($i+1).".htm", "logo".$i.".jpg", $i+1);
    close(OUTFILE);
    $outfile = "./mybook".($i+1)."/toc.htm";
    open(OUTFILE, ">$outfile");
    print OUTFILE fixtag($TOC[$i], "mybook".($i+1).".htm", "logo".$i.".jpg", $i+1);
    close(OUTFILE);
    foreach (@picture_arr) {
       copy $_, "./mybook".($i+1)."/".basename($_); 
    }
    copy "./PICTURES/logo${i}.jpg", "./mybook".($i+1)."/logo${i}.jpg"; 
#    copy "./kindlegen", "./mybook".($i+1)."/kindlegen";
    chdir "./mybook".($i+1);
#    chmod 0777, "./kindlegen";
#    system("./kindlegen ./mybook".($i+1).".opf");
#    wait;
    my $infile = "./mybook".($i+1).".htm";
    my $outfile = "./mybook".($i+1).".pdf";
    unlink "$outfile";
    my $cmd = "htmldoc --titlefile logo$i.jpg --book -f $outfile $infile";
    system($cmd);
    wait;
    chdir "..";
}

sub buildHtmlToc {
    my ($html_txt, $src) = @_;
    $toc = "<h2>Table of Contents</h2><br><br><UL>";
    $tocf = 0;
    @INNERLIST = ();
    %INDEX = ();
    $il = 0;
    $html_txt =~ s/\<h2\>(.*?)\<\/h2\>/&indsub($1)/eg;
    $il2 = 0;
    $html_txt =~ s/\<h3\>(.*?)\<\/h3\>/&indsub2($1)/eg;
    $il = "0";
    $il2 = "0";
    my @html = split /\<br\>/, $html_txt;
    my $hold = "";
    foreach my $x (@html) {
       if ($x =~ /\<h2\>/) {
           indsub3($hold);
           $hold = "";
       }
       $hold .= $x;
    } 
    my $in = "INNERLIST".sprintf("%03d",($il-1));
    my @IL = @INNERLIST;
    my $rep = join("", splice(@IL, $il2, @IL - $il2));
    $toc =~ s/$in/$rep/g;
    $toc .= "</UL>";
    return ($toc, $html_txt);
}

sub buildSmil {
    my $uid = "XXTITLEXX";
    $uid =~ s/[^0-9A-Za-z]/\_/g;
    my $txt = <<EOF
<?xml version="1.0"  encoding="UTF-8"?>
<!DOCTYPE smil PUBLIC "-//NISO//DTD dtbsmil 2005-1//EN" 
  "http://www.daisy.org/z3986/2005/dtbsmil-2005-1.dtd">
<smil xmlns="http://www.w3.org/2001/SMIL20/">
    <head>
       <meta name="dtb:uid" content="$uid" />
       <meta name="dtb:generator" content="smilgen2.4" />
       <layout>
          <region id="text" top="0%" left="0%" right="0%" bottom="15%"/>
       </layout>
       <customAttributes>
          <customTest id="pagenum" defaultState="false" override="visible"/>
       </customAttributes>
    </head>
    <body>
   <seq id="baseseq" >
EOF
;
foreach my $link (@INNERLIST) {
    $link =~ s/^.*href\=\"(.*)\".*$/$1/g;
    my $id = $link;
    $id =~ s/^.*\#(.*)$/$1/g;
    $txt .= <<EOF 
      <par id="$id">
         <text region="text" src="XXSRCXX$link" />
      </par>
EOF
;
}
$txt .= qq{ </seq>
</body>
</smil> };
return $txt;
}

sub buildNcx {
    my $uid = "XXTITLEXX";
    $uid =~ s/[^0-9A-Za-z]/\_/g;
    my $html_txt = shift;
    my $txt = <<EOF
<?xml version="1.0"  encoding="UTF-8"?>
<!DOCTYPE ncx PUBLIC "-//NISO//DTD ncx 2005-1//EN" 
  "http://www.daisy.org/z3986/2005/ncx-2005-1.dtd">
<ncx version="2005-1" xml:lang="en" xmlns="http://www.daisy.org/z3986/2005/ncx/">
  <head>
    <smilCustomTest id="pagenum" defaultState="false" 
    override="visible" bookStruct="PAGE_NUMBER"/>
    <smilCustomTest id="note" defaultState="true" 
    override="visible" bookStruct="NOTE"/>
    <meta name="dtb:uid" content="$uid"/>
    <meta name="dtb:generator" content="NLSv001"/>
  </head>
  <docTitle>
     <text>XXTITLEXX</text> 
     <img src="XXLOGOXX" />
  </docTitle>
  <docAuthor>
       <text>XXAUTHORXX</text> 
  </docAuthor>
EOF
;
    $toc = "<navMap>";
    $tocf = 0;
    @INNERLIST = ();
    %INDEX = ();
    $il = 0;
    $html_txt =~ s/\<h2\>(.*?)\<\/h2\>/&indsubn($1)/eg;
    $il2 = 0;
    $html_txt =~ s/\<h3\>(.*?)\<\/h3\>/&indsub2n($1)/eg;
    $il = "0";
    $il2 = "0";
    my @html = split /\<br\>/, $html_txt;
    my $hold = "";
    foreach my $x (@html) {
       if ($x =~ /\<h2\>/) {
           indsub3n($hold);
           $hold = "";
       }
       $hold .= $x;
    } 
    my $in = "INNERLIST".sprintf("%03d",($il-1));
    my @IL = @INNERLIST;
    my $rep = join("", splice(@IL, $il2, @IL - $il2));
    $toc =~ s/$in/$rep/g;
    $toc .= "</navPoint></navMap>";
    $txt .= $toc;
    $txt .= "</ncx>";
    return $txt;
}

sub buildOpf {
    my $txt = <<EOF
<?xml version="1.0"?>

<package>
    <metadata><dc-metadata xmlns:dc="http://purl.org/dc/elements/1.1/" xmlns:oebpackage="http://openebook.org/namespaces/oeb-package/1.0/">

<dc:Title>XXTITLEXX</dc:Title>          
<dc:Language>en</dc:Language>
<dc:Author>XXAUTHORXX</dc:Author>
  </dc-metadata>
<meta name="cover" content="my-cover-image" />
</metadata>
<manifest>
<item href="XXLOGOXX" id="my-cover-image" media-type="image/jpeg" ></item>
<item id="toc1" media-type="application/x-dtbncx+xml" href="toc.ncx"></item>
<item id="toc" media-type="text/x-oeb1-document" href="toc.htm"></item>
<item id="item1" media-type="text/x-oeb1-document" href="XXSRCXX"></item>
  <item id="SMIL" href="rs.smil" media-type="application/smil" />
</manifest>

<spine toc="toc1">
<itemref idref="toc">
<itemref idref="item1">

</spine>

<tours></tours>

<guide>
<reference type="toc" title="Table of Contents" href="toc.htm">

<reference type="start" title="Startup Page" href="XXSRCXX#Introduction0";></reference>

</guide>

</package>
EOF
;
return $txt;
}

sub indsub {
        my $nm = shift;
        chomp($nm);
        $toc .= "</UL>" if $tocf;
        my $nmi = $nm;
        $nmi =~ s/[^a-zA-Z0-9]/\_/g;
        $nmi = $nmi.($INDEX{$nmi}++);
        $toc .= "<LI><a href=\"#".$nmi."\">".$nm."</a><br>";
  my $ret = "<br><h2><a name=\"".$nmi."\">$nm</a></h2><br>";
        $toc .= "<UL>INNERLIST".sprintf("%03d",($il++));
        $tocf = 1;
        return $ret;
}

sub indsub2 {
        my $nm = shift;
        chomp($nm);
        my $nmi = $nm;
        $nmi =~ s/[^a-zA-Z0-9]/\_/g;
        $nmi = $nmi.($INDEX{$nmi}++);
        my $tocsub = "<LI><a href=\"#".$nmi."\">".$nm."</a><br>";
        $INNERLIST[$il2++] = $tocsub;
  my $ret = "<br><h3><a name=\"".$nmi."\">$nm</a></h3>";
        return $ret;
}

sub indsub3 {
        my $nm = shift;
        chomp($nm);
        my $ret = "<h2>$nm<h2>";
        my $cnt = ($nm =~ s/\<h3\>/x/g);
        my $in = "INNERLIST".sprintf("%03d",($il-1));
        $il++;
        my @IL = @INNERLIST;
        my $rep = join("", splice @IL, $il2, $cnt);
        $il2 += $cnt;
        $toc =~ s/$in/$rep/g; 
        return $ret;
}

sub indsubn {
        my $nm = shift;
        chomp($nm);
        my $nmi = $nm;
        $nmi =~ s/[^a-zA-Z0-9]/\_/g;
        $nmi = $nmi.($INDEX{$nmi}++);
  my $ret = "<br><h2><a name=\"".$nmi."\">$nm</a></h2><br>";
        $toc .= "</navPoint>" if $tocf;
        $toc .= <<EOF
<navPoint class="section" id="$nmi">
          <navLabel>
            <text>$nm</text>
          </navLabel>
          <content src="XXSRCXX#$nmi" />
EOF
;
$toc .= "INNERLIST".sprintf("%03d",($il++));
        $tocf = 1;
        return $ret;
}

sub indsub2n {
        my $nm = shift;
        chomp($nm);
        my $nmi = $nm;
        $nmi =~ s/[^a-zA-Z0-9]/\_/g;
        $nmi = $nmi.($INDEX{$nmi}++);
        my $tocsub = <<EOF
<navPoint class="subsection" id="$nmi">
          <navLabel>
            <text>$nm</text>
          </navLabel>
          <content src="XXSRCXX#$nmi" />
</navPoint>
EOF
;
        $INNERLIST[$il2++] = $tocsub;
      my $ret = "<br><h3><a name=\"".$nmi."\">$nm</a></h3>";
        return $ret;
}

sub indsub3n {
        my $nm = shift;
        chomp($nm);
        my $ret = "<h2>$nm<h2>";
        my $cnt = ($nm =~ s/\<h3\>/x/g);
        my $in = "INNERLIST".sprintf("%03d",($il-1));
        $il++;
        my @IL = @INNERLIST;
        my $rep = join("", splice @IL, $il2, $cnt);
        $il2 += $cnt;
        $toc =~ s/$in/$rep/g; 
        return $ret;
}

sub fixtag {
    my ($str, $src, $logo, $vol) = @_;
    $str =~ s/XXTITLEXX/$title/g;
    $str =~ s/XXAUTHORXX/$author/g;
    $str =~ s/XXSRCXX/$src/g;
    $str =~ s/XXLOGOXX/$logo/g;
    $str =~ s/XXVOLXX/$vol/g;
    return $str;
}
