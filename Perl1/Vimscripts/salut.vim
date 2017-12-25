"this is first script in Vim
":help usr_41.txt -> info for scripting
":help function-list -> lita de functii

"Aceasta este o prima functie care poate fi apelata in urmatorul mod:
":w
":source salut.vim
":call Salut()
:function! Salut()
:   echo "Salut!"
:endfunction
"----------------------------------------------------F
:function! Salut1()
:   let str = "Salut Romania!"
:   return str
:endfunction
"-----------------------------------------------------
"Vimscript function can take arguments
:function! AfiseazaNumele(nume)
:   echom "Salut! Numele tau este: "
:   echom a:nume
:endfunction
"~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
"File perl
:function! PerlFile(file)
:   "let datazi = date
:   execute ":vsplit ".a:file
:   echom "#!/usr/bin/perl"
:   echom "#file: ".a:file
:endfunction
"~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
"File vimscript
:function! VimFile(file)
:   execute ":vsplit ".a:file
":   let fila = "a:file"
":   vsplit fila
:   s/^/#!\/usr\/bin\/perl / 
":   s/$/# /
:   $read !date
:   s/^/# Creations date: /
:endfunction
":call PerlFile("01script.pl")
":call VimFile("01vimscript.vim")
:call AfiseazaNumele("Vasile")
:call Salut()
:call Salut1()
:echom Salut1()

