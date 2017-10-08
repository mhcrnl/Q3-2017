#!/usr/bin/perl -w

my $infile = pop;

while ($infile) {

    @id3ed = `id3ed "$infile" -i`;
    
    $_ = join '', @id3ed;
    
    /songname: (.*?)\n/;

    $songname = $1;

    /artist: (.*?)\n/;

    $artist = $1;

    $songname =~ s/ /_/g;
    $artist =~ s/ /_/g;

    $outfile = $artist . '_-_' . $songname . '.mp3';
    
    $outfile =~ s/__//g;
    
    print $outfile ."\n";
    
    system "mv \"$infile\" \"$outfile\"";

    $infile = pop;

}
