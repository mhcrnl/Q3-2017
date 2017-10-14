#!/bin/sh
##
##    linux cshell to start up clickTk session in a separate terminal session
## 
echo 'ctk_w now working ... '
PERL5LIB='/opt/ActivePerl-5.8/lib'
env PERL5LIB=$PERL5LIB xterm -e /opt/ActivePerl-5.8/bin/perl ctk_w.pl
echo 'OK done'
 
