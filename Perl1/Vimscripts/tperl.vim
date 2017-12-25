"Creations date: Sun Nov 12 11:34:22 EET 2017
"--------------------------------

let lines = ["#!/usr/bin/perl\n","#Author: mhcrnl@gmail.com\n","#Create Date:",execute ":!date","\n","use strict;\n","use warnings;\n","#----Futures:\n","use 5.010;\n","#----Modules:\n"]

:function! PerlFile(file)
:   execute ":vsplit ".a:file
:   s/^/#!\/usr\/bin\/perl /
:   $read !date
:   s/^/#Create date: /
:   s/^/ /
:   s/^/#Author: mhcrnl@gmail.com /
:
:endfunction

:function! PerlFile1(file)
:   let a:dir = input("Insert name for director:")
:   !mkdir dir
:   execute ":vsplit ".a:file
:   call writefile(lines, a:file)
:endfunction

:echo lines
:call PerlFile1("02script.pl")
