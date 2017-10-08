#
# Project: grandfatherclock
# File:    installation script
# Type:    make(1) script
#



#
# Constants
#
           NAME=grandfatherclock
        VERSION=1.0.1
        RELEASE=1suse

         RPMDIR=/usr/src/packages
         BINDIR=/usr/bin
         MANDIR=/usr/man
         ETCDIR=/etc/$(NAME)



#
# Generic Targets
#
usage:
	@echo "make usage"
	@echo "  report usage"
	@echo "make unpack"
	@echo "  expand tar.gz package"
	@echo "  requires $(NAME)-$(VERSION).tar.gz"
	@echo "make install"
	@echo "  integrate into system"
	@echo "  requires $(NAME)-$(VERSION)/"
	@echo "  edit Makefile to change installation directories"
	@echo "make uninstall"
	@echo "  disconnect from system"
	@echo "  edit Makefile to change installation directories"
	@echo "make clean"
	@echo "  remove unpacked from system"
	@echo "make realclean"
	@echo "  remove packages"
	@echo "make changes"
	@echo "  compare $(NAME)-$(VERSION)/"
	@echo "  to installation
	@echo "make tgz"
	@echo "  rebuild tar.gz package"
	@echo "  requires $(NAME)-$(VERSION)/"
	@echo "make rpm"
	@echo "  build rpm packages"
	@echo "  requires $(NAME)-$(VERSION)/"

unpack:
	tar -zxvf $(NAME)-$(VERSION).tar.gz

install:
	if test -L $(BINDIR)/$(NAME); then rm $(BINDIR)/$(NAME); fi
	ln -s `pwd`/$(NAME)-$(VERSION)/bin/$(NAME) $(BINDIR)/$(NAME)
	mkdir -p $(ETCDIR)
	cp $(NAME)-$(VERSION)/etc/grandfatherclockrc $(ETCDIR)/$(NAME)rc
	gzip -c $(NAME)-$(VERSION)/doc/grandfatherclock.6 > $(MANDIR)/man6/$(NAME).6.gz

uninstall:
	-rm $(BINDIR)/$(NAME)
	-rm -r $(ETCDIR)
	-rm -r $(MANDIR)/man6/$(NAME).6.gz

clean:
	-rm -r $(NAME)-$(VERSION)/
	-rm -r $(RPMDIR)/BUILD/$(NAME)-$(VERSION)/
	-rm $(RPMDIR)/SOURCES/$(NAME)-$(VERSION).tar.gz
	-rm $(RPMDIR)/SPECS/$(NAME).spec
	-rm $(RPMDIR)/SRPMS/$(NAME)-$(VERSION)-$(RELEASE).src.rpm
	-rm $(RPMDIR)/RPMS/noarch/$(NAME)-$(VERSION)-$(RELEASE).noarch.rpm

realclean: uninstall clean
	-rm $(NAME)-$(VERSION).tar.gz
	-rm $(NAME)-$(VERSION)-$(RELEASE).src.rpm
	-rm $(NAME)-$(VERSION)-$(RELEASE).noarch.rpm

changes:
	@for f in $$(cd $(NAME)-$(VERSION); find . -type f -print); \
	do \
	  if ! cmp -s $(NAME)-$(VERSION)/$$f /opt/$(NAME)/$$f; \
	  then \
	    echo $$f; \
	  fi; \
	done

tgz: $(NAME)-$(VERSION).tar.gz

rpm: $(NAME)-$(VERSION)-$(RELEASE).src.rpm $(NAME)-$(VERSION)-$(RELEASE).noarch.rpm

.ALWAYS:



#
# Specific Targets
#
$(NAME)-$(VERSION).tar.gz: .ALWAYS
	@if grep -q "NAME=$(NAME)" $(NAME)-$(VERSION)/doc/Makefile ;\
	then true; else \
	  echo "ERROR: NAME=$(NAME) mismatch with $(NAME)-$(VERSION)/doc/Makefile" ;\
	  exit 2 ;\
	fi
	@if grep -q "VERSION=$(VERSION)" $(NAME)-$(VERSION)/doc/Makefile ;\
	then true; else \
	  echo "ERROR: VERSION=$(VERSION) mismatch with $(NAME)-$(VERSION)/doc/Makefile" ;\
	  exit 2 ;\
	fi
	@if grep -q "RELEASE=$(RELEASE)" $(NAME)-$(VERSION)/doc/Makefile ;\
	then true; else \
	  echo "ERROR: RELEASE=$(RELEASE) mismatch with $(NAME)-$(VERSION)/doc/Makefile" ;\
	  exit 2 ;\
	fi
	@if grep -q "define name $(NAME)" $(NAME)-$(VERSION)/doc/$(NAME).spec ;\
	then true; else \
	  echo "ERROR: define name $(NAME) mismatch with $(NAME)-$(VERSION)/doc/$(NAME).spec" ;\
	  exit 2 ;\
	fi
	@if grep -q "define version $(VERSION)" $(NAME)-$(VERSION)/doc/$(NAME).spec ;\
	then true; else \
	  echo "ERROR: define version $(VERSION) mismatch with $(NAME)-$(VERSION)/doc/$(NAME).spec" ;\
	  exit 2 ;\
	fi
	@if grep -q "define release $(RELEASE)" $(NAME)-$(VERSION)/doc/$(NAME).spec ;\
	then true; else \
	  echo "ERROR: define release $(RELEASE) mismatch with $(NAME)-$(VERSION)/doc/$(NAME).spec" ;\
	  exit 2 ;\
	fi
	tar -zcvf $(NAME)-$(VERSION).tar.gz $(NAME)-$(VERSION)

$(NAME)-$(VERSION)-$(RELEASE).src.rpm $(NAME)-$(VERSION)-$(RELEASE).noarch.rpm: $(NAME)-$(VERSION).tar.gz
	cp $(NAME)-$(VERSION)/doc/$(NAME).spec $(RPMDIR)/SPECS/
	cp $(NAME)-$(VERSION).tar.gz $(RPMDIR)/SOURCES/
	rpm -ba --target=noarch $(NAME)-$(VERSION)/doc/$(NAME).spec
	cp $(RPMDIR)/SRPMS/$(NAME)-$(VERSION)-$(RELEASE).src.rpm .
	cp $(RPMDIR)/RPMS/noarch/$(NAME)-$(VERSION)-$(RELEASE).noarch.rpm .
