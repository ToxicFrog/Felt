include ../config.mk
PKG_PACKAGES=gtkspell-2.0 $(PKG_LUA)
NAME=gtkspell.so
VERSION=`pkg-config --modversion gtkspell-2.0`
include ../flags.mk

$(NAME): gtkspell.o
	$(CC) gtkspell.o -o $(NAME) $(LDFLAGS)

src/iface.c: src/gtkspell.def src/gtkspell.ovr
	$(GEN) -i "$(PWD)/src/gtkspell.ovr" -o "$(PWD)/src/iface.c" -l "$(PWD)/log" -v $(VERSION)

gtkspell.o: src/iface.c src/gtkspell.c
	$(CC) $(CFLAGS) src/iface.c -o gtkspell.o

.PHONY: install
install: $(NAME)
	$(MKDIR) $(DESTDIR)/lib/lua/5.1/lgob/
	$(CP) $(NAME) $(DESTDIR)/lib/lua/5.1/lgob
	
.PHONY: uninstall
uninstall:
	$(RM) $(DESTDIR)/lib/lua/5.1/lgob/$(NAME)
	
clean:
	$(RM) gtkspell.o $(NAME) src/iface.c log
	
.PHONY: help
help:
	@echo Options:
	@echo
	@echo AMD64=1 to build for 64 bits
