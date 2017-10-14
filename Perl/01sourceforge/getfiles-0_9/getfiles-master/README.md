# getfiles
Tool to download all the files of the desired type from a web page

First use CPAN to install these modules: File::Fetch; use LWP::UserAgent(); HTML::SimpleLinkExtor;

# How to use it:

1) CD into the directory you want the files to be saved to
2) Run:

getfiles 'http://yourdownain.com/filesdir.html' mp3

This will download all the MP3 files from that page.

3) It is reccommended to put the URL in single quotes (') so that the shell doesn't munge the characters

==

Notes:

This does not search recursively down the file tree. Only the given URL is searched, intentionally.
This can only download files linked to via a <a> tag.

