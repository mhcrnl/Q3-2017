## File to include in other Makefile's, defining common commands
# $Id: Makefile.inc,v 1.1 2002/01/26 18:31:19 verthezp Exp $
# $Name: R4_3 $

define replace-VERSION
  cd $(distdir); \
  for file in $(VERSIONED_FILES); do \
  sed 's/\@VERSION\@/${VERSION}/' $$file > $$file.new; \
  rm $$file; \
  mv $$file.new $$file; \
  done
endef

define finish-perl-script
  rm -f $@
  echo "#!" $(PERL) "-w" > $@
  sed "s|use diagnostics;|$(PERL_DIAGNOSTICS)|" $< >> $@
  chmod ugo+x $@
  $(PERL) -c $@
endef
