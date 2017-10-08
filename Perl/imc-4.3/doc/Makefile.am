## Process this file with automake to produce Makefile.in
EXTRA_DIST = ${PROG}.html ${PROG}.ref ${PROG}.txt

dist-hook:
	@cd $(distdir); \
	for file in ${PROG}.html ${PROG}.txt; do \
          sed 's/\@VERSION\@/${VERSION}/' $$file > $$file.new; \
	  rm $$file; \
	  mv $$file.new $$file; \
	done
