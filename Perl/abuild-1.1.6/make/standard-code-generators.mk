# Support for these code generators was added to abuild before plugins
# were implemented.  They should have been implemented as plugins, but
# people are using them, and they are simple, so we let them stick
# around.  Support for them is exercised in abuild-misc.test.

# Flex rules that are separate from lex rules

FLEX := flex
ifdef FLEX_CACHE
 define flex_to_c
	@$(PRINT) Generating $@ from $< with $(FLEX)
	$(RM) $@
	$(CODEGEN_WRAPPER) --cache $(FLEX_CACHE) \
	    --input $< --output $@ --command \
	    $(FLEX) -o$@ $<
 endef
else
 define flex_to_c
	@$(PRINT) Generating $@ from $< with $(FLEX)
	$(RM) $@
	$(FLEX) -o$@ $<
 endef
endif

%.fl.cc: %.fl
	$(flex_to_c)

%.fl.cpp: %.fl
	$(flex_to_c)

%.fl.c: %.l
	$(flex_to_c)

# Caching generated files for the C++ scanner can't be done reliably
# because of the need for the file FlexLexer.h.  Besides, the C++
# scanner is experimental, broken, and subject to being removed in a
# future version of flex.  It should really not be used now that
# %option reentrant is available for creating re-entrant scanners.
FlexLexer.%.cc: %.fl
	@$(PRINT) "Generating $@ from $<"
	$(FLEX) -Pyy_$(notdir $(basename $<)) -+ -s -o$@ $<

# Bison rules

BISON := bison
ifdef BISON_CACHE
 %.tab.cc %.tab.hh: %.yy
	@$(PRINT) "Generating $@ from $<"
	$(CODEGEN_WRAPPER) --cache $(BISON_CACHE) \
	    --input $< --output $(basename $@).cc $(basename $@).hh \
	    --command $(BISON) -p $(notdir $(basename $<)) -t -d $<
else
 %.tab.cc %.tab.hh: %.yy
	@$(PRINT) "Generating $@ from $<"
	$(BISON) -p $(notdir $(basename $<)) -t -d $<
endif

# Lex rules

LEX := lex
define lex_to_c
	@$(PRINT) Generating $@ from $< with $(LEX)
	$(RM) $@
	$(LEX) -o$@ $<
endef

%.ll.cc: %.ll
	$(lex_to_c)

%.ll.cpp: %.ll
	$(lex_to_c)

%.l.c: %.l
	$(lex_to_c)

# Sun RPC rules

RPCGEN := rpcgen
# make sure make does not remove the generated header file
.PRECIOUS: %_rpc.h

%_rpc.h: %.x
	@$(PRINT) Generating $@ from $< with $(RPCGEN)
	$(RM) $@
	$(RPCGEN) -h -o $@ $<

%_rpc_xdr.c: %_rpc.h
	@$(PRINT) Generating $@ from $< with $(RPCGEN)
	$(RM) $@
	$(RPCGEN) -c -o $@ $(SRCDIR)/$*.x
	sed -e 's/#include \"\.\.\/$*\.h/#include \"$*_rpc\.h/' $@ > $@.tmp
	mv $@.tmp $@

%_rpc_svc.c: %_rpc.h
	@$(PRINT) Generating $@ from $< with $(RPCGEN)
	$(RM) $@
	$(RPCGEN) -m -o $@ $(SRCDIR)/$*.x
	sed -e 's/#include \"\.\.\/$*\.h/#include \"$*_rpc\.h/' $@ > $@.tmp
	mv $@.tmp $@

%_rpc_clnt.c: %_rpc.h
	@$(PRINT) Generating $@ from $< with $(RPCGEN)
	$(RM) $@
	$(RPCGEN) -l -o $@ $(SRCDIR)/$*.x
	sed -e 's/#include \"\.\.\/$*\.h/#include \"$*_rpc\.h/' $@ > $@.tmp
	mv $@.tmp $@
