include ../config.mk
PKG_PACKAGES=vte $(PKG_LUA)
NAME=vte.so
VERSION=`pkg-config --modversion vte`
include ../flags.mk

$(NAME): vte.o
	$(CC) vte.o -o $(NAME) $(LDFLAGS)

src/iface.c: src/vte.def src/vte.ovr
	$(GEN) -i "$(PWD)/src/vte.ovr" -o "$(PWD)/src/iface.c" -l "$(PWD)/log" -v $(VERSION)

vte.o: src/iface.c src/vte.c
	$(CC) $(CFLAGS) src/iface.c -o vte.o

.PHONY: install
install: $(NAME)
	$(MKDIR) $(DESTDIR)/lib/lua/5.1/lgob/
	$(CP) $(NAME) $(DESTDIR)/lib/lua/5.1/lgob
	
.PHONY: uninstall
uninstall:
	$(RM) $(DESTDIR)/lib/lua/5.1/lgob/$(NAME)
	
clean:
	$(RM) vte.o $(NAME) src/iface.c log
	
.PHONY: help
help:
	@echo Options:
	@echo
	@echo AMD64=1 to build for 64 bits
