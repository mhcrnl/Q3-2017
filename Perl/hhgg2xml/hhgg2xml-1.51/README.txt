
 hhgg2xml                  (c) Andrew Flegg 2000. Released under the
 ~~~~~~~~                                         Artistic Licence.
 http://www.bleb.org/software/pda/                v1.51 (25-Jan-2001)
 mailto:andrew@bleb.org


Intro
-----
 H2G2.com is an Internet version of The Hitchhiker's Guide to the Galaxy[TM],
 produced by Douglas Adams and the Digital Village. Seemingly inspired by
 the PGG it has the benefit of being called "official"

 hhgg2xml is a Perl script which reads can operate in two modes:

     1) Downloading information from H2G2.com using LWP::Simple and
        storing in a variety of formats,
  or 2) Rereading previously output XML files and reoutputting them in
        a different format, such as TomeRaider 2's TRML language.


Usage
-----
 Place hhgg2xml in your PATH, eg. /usr/local/bin/.

 Syntax:
     hhgg2xml [options] [<article> ...]

 Options:
     -h, --help           Output a brief help summary of the command line
                          options and other salient information on using
                          the program.

     -nr, --nonrecursive  Process all the articles listed on the command
                          line and exit. Implicit when -l is specified it
                          will travel from one page to all others linked
                          from it when not specified.

     -s, --single         Do not output each article in its own file, instead
                          sort them by title and output to stdout.

     -o TYPE,             Specify the output mode to use, ie. what file
     --mode=TYPE          format the output should take. If TYPE is not
                          specified then a list is given of the currently
                          supported modes.

 When fetching from the web, if the article number ends in ".h2g2", the
 program will assume this to be an already fetched page which has been
 stored as XML and will reread it. This is useful for downloading whole
 sections in batches and producing a single TomeRaider document at a later
 date. If specified the page will also not be refetched.


Examples
--------
 An example "starting page" is included in the distribution as `C0.h2g2'.

 1) To fetch a page and store it locally as XML, which can then be processed
    later:
         $ hhgg2xml --nonrecursive A26543

 2) To convert the file fetched in (1) into a text document:
         $ hhgg2xml --mode=Text A26543.h2g2 | less

 3) To fetch the whole `Life' branch, and store them locally as XML:
         $ hhgg2xml C72

 4) To convert the downloaded XML files to a single TomeRaider 2 document
    suitable for viewing on the Psion and Palm versions of TomeRaider:
         $ hhgg2xml --single --mode=TRML_Palm *.h2g2 >life.tab

 5) To convert downloaded XML to a single TomeRaider 2 document for the
    Windows viewer, containing a title page, the articles and then the
    sections:
         $ hhgg2xml --single --mode=TRML_Win32 C0.h2g2 >hhgg.tab
         $ hhgg2xml --single --mode=TRML_Win32 A*.h2g2 >>hhgg.tab
         $ hhgg2xml --single --mode=TRML_Win32 C*.h2g2 >>hhgg.tab


Bugs
----
 Whilst browing I've come across the following problems which could be
 problems with the EPOC TomeRaider viewer and need to investigated 
 before the next release:
   * A144334 - DL/DT and DD

 If you find any other articles with problems please let me know which
 of the output modes it is present in and a fix if possible.

 I expect *many* articles to have problems due to the nature of this
 program and even the ``best'' instance of the program is still going to
 imperfect.


Changes
-------

 1.51   25-Jan-2000     Better handling of blank articles and miscellaneous
                        output tweaks
 1.50   23-Jan-2000     Changed to use the GuideML if available
 1.00   27-Jul-2000     Initial release.


Author & Disclaimer
-------------------
 hhgg2xml is released under the Artistic Licence, see:
    http://www.opensource.org/licenses/artistic-license.html

 The author, Andrew Flegg, is not connected with H2G2.com, The Digital
 Village or Douglas Adams except as a fan. Output from this program may
 contravene H2G2's redistribution rights if you make them available. However,
 this program itself should not infringe their copyright. As an unofficial
 product, however, it may become inoperable if H2G2.com change the format
 of their pages or specifically block access to this program.

 hhgg2xml may be distributed freely but must include this README with any
 packaging.
