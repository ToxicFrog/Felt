include ../config.mk
PKG_PACKAGES=gtksourceview-2.0 $(PKG_LUA)
NAME=gtksourceview.so
VERSION=`pkg-config --modversion gtksourceview-2.0`

ifdef VOLD
	PKG_PACKAGES+=gtksourcecompletion-2.0
endif

include ../flags.mk

ifdef VOLD
	CFLAGS+=-DVOLD
endif

$(NAME): gtksourceview.o
	$(CC) gtksourceview.o -o $(NAME) $(LDFLAGS)

src/iface.c: src/gtksourceview.def src/gtksourceview.ovr
	$(GEN) -i "$(PWD)/src/gtksourceview.ovr" -o "$(PWD)/src/iface.c" -l "$(PWD)/log" -v $(VERSION)

gtksourceview.o: src/iface.c src/gtksourceview.c
	$(CC) $(CFLAGS) src/iface.c -o gtksourceview.o

.PHONY: install
install: $(NAME)
	$(MKDIR) $(DESTDIR)/lib/lua/5.1/lgob/
	$(CP) $(NAME) $(DESTDIR)/lib/lua/5.1/lgob
	
.PHONY: uninstall
uninstall:
	$(RM) $(DESTDIR)/lib/lua/5.1/lgob/$(NAME)
	
clean:
	$(RM) gtksourceview.o $(NAME) src/iface.c log
	
.PHONY: help
help:
	@echo Options:
	@echo
	@echo AMD64=1 to build for 64 bits
	@echo VOLD=1 to build using a separated gtksourcecompletion
