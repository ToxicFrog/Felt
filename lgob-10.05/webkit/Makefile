include ../config.mk
PKG_PACKAGES=webkit-1.0 $(PKG_LUA)
NAME=webkit.so
VERSION=`pkg-config --modversion webkit-1.0`
include ../flags.mk

$(NAME): webkit.o
	$(CC) webkit.o -o $(NAME) $(LDFLAGS)

src/iface.c: src/webkit.def src/webkit.ovr
	$(GEN) -i "$(PWD)/src/webkit.ovr" -o "$(PWD)/src/iface.c" -l "$(PWD)/log" -v $(VERSION)

webkit.o: src/iface.c src/webkit.c
	$(CC) $(CFLAGS) src/iface.c -o webkit.o

.PHONY: install
install: $(NAME)
	$(MKDIR) $(DESTDIR)/lib/lua/5.1/lgob/
	$(CP) $(NAME) $(DESTDIR)/lib/lua/5.1/lgob
	
.PHONY: uninstall
uninstall:
	$(RM) $(DESTDIR)/lib/lua/5.1/lgob/$(NAME)
	
clean:
	$(RM) webkit.o $(NAME) src/iface.c log
	
.PHONY: help
help:
	@echo Options:
	@echo
	@echo AMD64=1 to build for 64 bits
