dnl Own functions
dnl AC_TRY_PERL(SCRIPT [, ACTION-IF-TRUE [, ACTION-IF-FALSE]])
AC_DEFUN([AC_TRY_PERL],
[cat > conftest.pl <<EOF
[$1]
EOF
ac_try="$PERL conftest.pl >/dev/null 2>conftest.out"
AC_TRY_EVAL(ac_try)
ac_err=`cat conftest.out`
if test -z "$ac_err"; then
  ifelse([$2], , :, [rm -rf conftest*
  $2])
else
  echo "$ac_err" >&AC_FD_CC
  echo "configure: failed program was:" >&AC_FD_CC
  cat conftest.pl >&AC_FD_CC
  ifelse([$3], , , [  rm -rf conftest*
  $3])
fi
rm -f conftest*])

dnl AC_GET_PERL(VARIABLE, SCRIPT)
AC_DEFUN([AC_GET_PERL],
[cat > conftest.pl <<EOF
[$2]
EOF
ac_try="$PERL conftest.pl >conftest.out 2>/dev/null"
AC_TRY_EVAL(ac_try)
$1=`cat conftest.out`
AC_MSG_RESULT([$]$1)
AC_SUBST($1)
])

