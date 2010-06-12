include ../config.mk
PKG_PACKAGES=gtk+-2.0 $(PKG_LUA)
NAME=gtk.so
VERSION=`pkg-config --modversion gtk+-2.0`
include ../flags.mk

$(NAME): gtk.o
	$(CC) gtk.o -o $(NAME) $(LDFLAGS)

src/iface.c: src/gtk.def src/gtk.ovr
	$(GEN) -i "$(PWD)/src/gtk.ovr" -o "$(PWD)/src/iface.c" -l "$(PWD)/log" -v $(VERSION)

gtk.o: src/iface.c src/gtk.c src/caux.c
	$(CC) $(CFLAGS) src/iface.c -o gtk.o

.PHONY: install
install: $(NAME)
	$(MKDIR) $(DESTDIR)/lib/lua/5.1/lgob/
	$(CP) $(NAME) $(DESTDIR)/lib/lua/5.1/lgob
	
.PHONY: uninstall
uninstall:
	$(RM) $(DESTDIR)/lib/lua/5.1/lgob/$(NAME)
	
clean:
	$(RM) gtk.o $(NAME) src/iface.c log
	
.PHONY: help
help:
	@echo Options:
	@echo
	@echo AMD64=1 to build for 64 bits
