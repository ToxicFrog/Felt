include ../config.mk
PKG_PACKAGES=poppler-glib $(PKG_LUA)
NAME=poppler.so
VERSION=`pkg-config --modversion poppler-glib`
include ../flags.mk

$(NAME): poppler.o
	$(CC) poppler.o -o $(NAME) $(LDFLAGS)

src/iface.c: src/poppler.def src/poppler.ovr
	$(GEN) -i "$(PWD)/src/poppler.ovr" -o "$(PWD)/src/iface.c" -l "$(PWD)/log" -v $(VERSION)

poppler.o: src/iface.c src/poppler.c
	$(CC) $(CFLAGS) src/iface.c -o poppler.o

.PHONY: install
install: $(NAME)
	$(MKDIR) $(DESTDIR)/lib/lua/5.1/lgob/
	$(CP) $(NAME) $(DESTDIR)/lib/lua/5.1/lgob
	
.PHONY: uninstall
uninstall:
	$(RM) $(DESTDIR)/lib/lua/5.1/lgob/$(NAME)
	
clean:
	$(RM) poppler.o $(NAME) src/iface.c log
	
.PHONY: help
help:
	@echo Options:
	@echo
	@echo AMD64=1 to build for 64 bits
