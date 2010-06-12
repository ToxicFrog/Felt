include ../config.mk
PKG_PACKAGES=gobject-2.0 gthread-2.0 $(PKG_LUA)
NAME=gobject.so
VERSION=`pkg-config --modversion glib-2.0`
include ../flags.mk

# Rules

.PHONY: all
all: $(NAME)
	
$(NAME): gobject.o
	$(CC) gobject.o -o $(NAME) $(LDFLAGS)
	
gobject.o: src/iface.c src/glib.c
	$(CC) $(CFLAGS) src/iface.c -o gobject.o
	
src/iface.c: src/glib.def src/glib.ovr
	$(GEN) -i "$(PWD)/src/glib.ovr" -o "$(PWD)/src/iface.c" -l "$(PWD)/log" -v $(VERSION)

.PHONY: install	
install: all
	$(MKDIR) $(DESTDIR)/lib/lua/5.1/lgob
	$(MKDIR) $(DESTDIR)/include/lgob/gobject
	$(CP) $(NAME) $(DESTDIR)/lib/lua/5.1/lgob/
	$(CP) src/types.h $(DESTDIR)/include/lgob/gobject

.PHONY: uninstall	
uninstall:
	$(RM) $(DESTDIR)/lib/lua/5.1/lgob/$(NAME)
	$(RM) $(DESTDIR)/include/lgob/gobject

.PHONY: clean
clean:
	$(RM) *.o $(NAME) log src/iface.c
	
.PHONY: help
help:
	@echo Options:
	@echo
	@echo AMD64=1 to build for 64 bits
	@echo DEBUG=1 to enable debug mode
