include ../config.mk
PKG_PACKAGES=cairo $(PKG_LUA)
NAME=cairo.so
VERSION=`pkg-config --modversion cairo`
include ../flags.mk

$(NAME): cairo.o
	$(CC) cairo.o -o $(NAME) $(LDFLAGS)
	
src/iface.c: src/cairo.def src/cairo.ovr
	$(GEN) -i "$(PWD)/src/cairo.ovr" -o "$(PWD)/src/iface.c" -l "$(PWD)/log" -v $(VERSION)

cairo.o: src/iface.c src/cairo.c
	$(CC) $(CFLAGS) src/iface.c -o cairo.o

.PHONY: install
install: $(NAME)
	$(MKDIR) $(DESTDIR)/lib/lua/5.1/lgob/
	$(CP) $(NAME) $(DESTDIR)/lib/lua/5.1/lgob
	
.PHONY: uninstall
uninstall:
	$(RM) $(DESTDIR)/lib/lua/5.1/lgob/$(NAME)
	
clean:
	$(RM) cairo.o $(NAME) src/iface.c log
	
.PHONY: help
help:
	@echo Options:
	@echo
	@echo AMD64=1 to build for 64 bits
