include ../config.mk
PKG_PACKAGES=clutter-1.0 $(PKG_LUA)
NAME=clutter.so
VERSION=`pkg-config --modversion clutter-1.0`
include ../flags.mk

$(NAME): clutter.o
	$(CC) clutter.o -o $(NAME) $(LDFLAGS)

src/iface.c: src/clutter.def src/clutter.ovr
	$(GEN) -i "$(PWD)/src/clutter.ovr" -o "$(PWD)/src/iface.c" -l "$(PWD)/log" -v $(VERSION)

clutter.o: src/iface.c src/clutter.c
	$(CC) $(CFLAGS) src/iface.c -o clutter.o

.PHONY: install
install: $(NAME)
	$(MKDIR) $(DESTDIR)/lib/lua/5.1/lgob/
	$(CP) $(NAME) $(DESTDIR)/lib/lua/5.1/lgob
	
.PHONY: uninstall
uninstall:
	$(RM) $(DESTDIR)/lib/lua/5.1/lgob/$(NAME)
	
clean:
	$(RM) clutter.o $(NAME) src/iface.c log
	
.PHONY: help
help:
	@echo Options:
	@echo
	@echo AMD64=1 to build for 64 bits
