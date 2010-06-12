include ../config.mk
PKG_PACKAGES=gtkieembed $(PKG_LUA)
NAME=gtkieembed.so
VERSION=`pkg-config --modversion gtkieembed`
include ../flags.mk

$(NAME): ieembed.o
	$(CC) ieembed.o -o $(NAME) $(LDFLAGS)
	
src/iface.c: src/ieembed.def src/ieembed.ovr
	$(GEN) -i "$(PWD)/src/ieembed.ovr" -o "$(PWD)/src/iface.c" -l "$(PWD)/log" -v $(VERSION)

ieembed.o: src/iface.c src/ieembed.c
	$(CC) $(CFLAGS) src/iface.c -o ieembed.o

.PHONY: install
install: $(NAME)
	$(MKDIR) $(DESTDIR)/lib/lua/5.1/lgob/
	$(CP) $(NAME) $(DESTDIR)/lib/lua/5.1/lgob
	
.PHONY: uninstall
uninstall:
	$(RM) $(DESTDIR)/lib/lua/5.1/lgob/$(NAME)
	
clean:
	$(RM) ieembed.o $(NAME) src/iface.c log
	
.PHONY: help
help:
	@echo Options:
	@echo
	@echo AMD64=1 to build for 64 bits
