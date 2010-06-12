include ../config.mk
PKG_PACKAGES=goocanvas $(PKG_LUA)
NAME=goocanvas.so
VERSION=`pkg-config --modversion goocanvas`
include ../flags.mk

# Options
ifdef AMD64
	CFLAGS+=-fPIC -DAMD64
else
	CFLAGS+=-fpic
endif

$(NAME): goocanvas.o
	$(CC) goocanvas.o -o $(NAME) $(LDFLAGS)

src/iface.c: src/goocanvas.def src/goocanvas.ovr
	$(GEN) -i "$(PWD)/src/goocanvas.ovr" -o "$(PWD)/src/iface.c" -l "$(PWD)/log" -v $(VERSION)

goocanvas.o: src/iface.c src/goocanvas.c
	$(CC) $(CFLAGS) src/iface.c -o goocanvas.o

.PHONY: install
install: $(NAME)
	$(MKDIR) $(DESTDIR)/lib/lua/5.1/lgob/
	$(CP) $(NAME) $(DESTDIR)/lib/lua/5.1/lgob
	
.PHONY: uninstall
uninstall:
	$(RM) $(DESTDIR)/lib/lua/5.1/lgob/$(NAME)
	
clean:
	$(RM) goocanvas.o $(NAME) src/iface.c log
	
.PHONY: help
help:
	@echo Options:
	@echo
	@echo AMD64=1 to build for 64 bits
