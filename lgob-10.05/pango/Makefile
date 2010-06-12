include ../config.mk
PKG_PACKAGES=pango $(PKG_LUA)
NAME=pango.so
VERSION=`pkg-config --modversion pango`
include ../flags.mk

$(NAME): pango.o
	$(CC) pango.o -o $(NAME) $(LDFLAGS)

src/iface.c: src/pango.def src/pango.ovr
	$(GEN) -i "$(PWD)/src/pango.ovr" -o "$(PWD)/src/iface.c" -l "$(PWD)/log" -v $(VERSION)

pango.o: src/iface.c src/pango.c
	$(CC) $(CFLAGS) src/iface.c -o pango.o

.PHONY: install
install: $(NAME)
	$(MKDIR) $(DESTDIR)/lib/lua/5.1/lgob/
	$(CP) $(NAME) $(DESTDIR)/lib/lua/5.1/lgob
	
.PHONY: uninstall
uninstall:
	$(RM) $(DESTDIR)/lib/lua/5.1/lgob/$(NAME)
	
clean:
	$(RM) pango.o $(NAME) src/iface.c log
	
.PHONY: help
help:
	@echo Options:
	@echo
	@echo AMD64=1 to build for 64 bits
