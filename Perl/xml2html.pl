#! /usr/bin/perl
use strict;
use XML::Parser;
use Data::Dumper;

my $header=<<HTML;

<!-- SPPUpdate header -->
<title>Satya's LJ archive</title>
<meta name="keywords" content="about, personal, college, html author,satyajit">
<meta name="description" content="LJ archive for Satya">
<!-- SPPUpdate body -->

<h1 align="center">$ARGV[0]</h1>

HTML

my $footer=<<HTML;
<!-- SPPUpdate footer -->

</body>
</html>
HTML

my $xml;

open(I,"<$ARGV[0]") || die "$ARGV[0]: $!\n";

while(<I>) {
    $xml.=$_;
    }
close(I);

my $p=new XML::Parser(ErrorContext=>2,Style=>'Tree');

my $arr=$p->parse($xml);

my @doc=@{$arr->[1]};

print $header;

my $i;
for($i=0;$i<=$#doc;$i++) {
    &entry($doc[$i+1]) if $doc[$i] eq 'entry';
    }

print $footer;

close(O);

exit;


sub field() {

my $arr=shift;
my $label=shift;
my $span1=shift;
my $span2=shift;

return if $arr->[2] eq '';

print<<HTML;
<span class="$span2">$label</span>
<span class="$span1">$arr->[2]</span><br />
HTML

} #sub field


sub event()	{

my $arr=shift;
my $txt=$arr->[2];

$txt=~s!(http://.*?)(\s|$)!<a href="$1">$1</a>$2!g;
$txt=~s!\n!<br />\n!g;
$txt=~s!  ! &nbsp;!g;

return qq[<p class="ljevent">] . $txt . '</p>';

} #event


sub entry() {

my $arr=shift;
my $i;
my $event;

print qq[\n<div class="ljentry">\n<p class="ljheader">\n];

for($i=0;$i<=$#{$arr};$i+=1) {
    &field($arr->[$i+1],"Event time: ",'etime','letime') if $arr->[$i] eq 'eventtime';
    &field($arr->[$i+1],"Log time: ",'ltime','lltime') if $arr->[$i] eq 'logtime';
    &field($arr->[$i+1],"Subject: ",'subject','lsubject') if $arr->[$i] eq 'subject';
    &field($arr->[$i+1],"Music: ",'music','lmusic') if $arr->[$i] eq 'current_music';
    &field($arr->[$i+1],"Mood: ",'mood','lmood') if $arr->[$i] eq 'current_mood';
    $event=&event($arr->[$i+1]) if $arr->[$i] eq 'event';
    }
print qq[</p>\n$event\n</div>\n];

} #sub entry

__END__
