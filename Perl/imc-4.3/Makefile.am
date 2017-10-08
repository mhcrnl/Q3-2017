## Process this file with automake to produce Makefile.in
bin_SCRIPTS = imc
man_MANS = ${PROG}.1
CLEANFILES = $(bin_SCRIPTS)
EXTRA_DIST = $(man_MANS) ${PROG}.dist make.pl Todo Makefile.inc
SUBDIRS = . examples doc
VERSIONED_FILES = README ${PROG}.1 ${PROG}.dist

include $(top_srcdir)/Makefile.inc

imc: $(srcdir)/${PROG}.dist
	${PERL} ${srcdir}/make.pl ${CONFIG}
	chmod 755 ${PROG}
	perl -c ${PROG}

dist-hook:
	$(replace-VERSION)

check:	${top_builddir}/${PROG}
