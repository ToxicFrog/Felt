include ../config.mk
include ../flags.mk
FORPKGDIR=$(DESTDIR)

# Rules

.PHONY: compile
compile:
	

.PHONY: install	
install:
	$(MKDIR) $(DESTDIR)/bin
	$(MKDIR) $(DESTDIR)/share/lua/5.1/lgob
	$(CP) src/*.lua $(DESTDIR)/share/lua/5.1/lgob
	$(SED) 's|DESTDIR|$(FORPKGDIR)|' < src/lgob-generator > $(DESTDIR)/bin/lgob-generator
	$(SED) 's|DESTDIR|$(FORPKGDIR)|' < src/lgob-gir-parser > $(DESTDIR)/bin/lgob-gir-parser
	$(EP) $(DESTDIR)/bin/lgob-generator
	$(EP) $(DESTDIR)/bin/lgob-gir-parser

.PHONY: uninstall
uninstall:
	$(RM) $(DESTDIR)/share/lua/5.1/lgob
	$(RM) $(DESTDIR)/bin/lgob-generator
	$(RM) $(DESTDIR)/bin/lgob-gir-parser

.PHONY: clean
clean:
