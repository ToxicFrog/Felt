include ../config.mk
PKG_PACKAGES=gdk-2.0 $(PKG_LUA)
NAME=gdk.so
VERSION=`pkg-config --modversion gdk-2.0`
include ../flags.mk

$(NAME): gdk.o
	$(CC) gdk.o -o $(NAME) $(LDFLAGS)

src/iface.c: src/gdk.def src/gdk.ovr
	$(GEN) -i "$(PWD)/src/gdk.ovr" -o "$(PWD)/src/iface.c" -l "$(PWD)/log" -v $(VERSION)

gdk.o: src/iface.c src/gdk.c
	$(CC) $(CFLAGS) src/iface.c -o gdk.o

.PHONY: install
install: $(NAME)
	$(MKDIR) $(DESTDIR)/lib/lua/5.1/lgob/
	$(CP) $(NAME) $(DESTDIR)/lib/lua/5.1/lgob
	
.PHONY: uninstall
uninstall:
	$(RM) $(DESTDIR)/lib/lua/5.1/lgob/$(NAME)
	
clean:
	$(RM) gdk.o $(NAME) src/iface.c log
	
.PHONY: help
help:
	@echo Options:
	@echo
	@echo AMD64=1 to build for 64 bits
