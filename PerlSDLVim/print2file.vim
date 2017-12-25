
:function! PrintFile(fname)
:   call system("a2ps ". a:fname)
:   call delete(a:fname)
:   return v:shell_error
:endfunction


