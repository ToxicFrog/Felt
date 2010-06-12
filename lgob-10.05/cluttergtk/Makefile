include ../config.mk
PKG_PACKAGES=clutter-gtk-0.10 $(PKG_LUA)
NAME=cluttergtk.so
VERSION=`pkg-config --modversion clutter-gtk-0.10`
include ../flags.mk

$(NAME): cluttergtk.o
	$(CC) cluttergtk.o -o $(NAME) $(LDFLAGS)

src/iface.c: src/cluttergtk.def src/cluttergtk.ovr
	$(GEN) -i "$(PWD)/src/cluttergtk.ovr" -o "$(PWD)/src/iface.c" -l "$(PWD)/log" -v $(VERSION)

cluttergtk.o: src/iface.c src/cluttergtk.c
	$(CC) $(CFLAGS) src/iface.c -o cluttergtk.o

.PHONY: install
install: $(NAME)
	$(MKDIR) $(DESTDIR)/lib/lua/5.1/lgob/
	$(CP) $(NAME) $(DESTDIR)/lib/lua/5.1/lgob
	
.PHONY: uninstall
uninstall:
	$(RM) $(DESTDIR)/lib/lua/5.1/lgob/$(NAME)
	
clean:
	$(RM) cluttergtk.o $(NAME) src/iface.c log
	
.PHONY: help
help:
	@echo Options:
	@echo
	@echo AMD64=1 to build for 64 bits
