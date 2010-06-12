include ../config.mk
PKG_PACKAGES=$(PKG_LUA)
NAME=_loader.so
VERSION=`pkg-config --modversion gtkieembed`
include ../flags.mk

$(NAME): src/loader.c
	$(CC) src/loader.c $(CFLAGS) -D $(OS)
	$(CC) loader.o -o $(NAME) $(LDFLAGS)

.PHONY: install
install: $(NAME)
	$(MKDIR) $(DESTDIR)/lib/lua/5.1/lgob/
	$(MKDIR) $(DESTDIR)/share/lua/5.1/lgob/
	$(CP) $(NAME) $(DESTDIR)/lib/lua/5.1/lgob
	$(CP) src/loader.lua $(DESTDIR)/share/lua/5.1/lgob/loader.lua 
	
.PHONY: uninstall
uninstall:
	$(RM) $(DESTDIR)/lib/lua/5.1/lgob/$(NAME)
	$(RM) $(DESTDIR)/share/lua/5.1/lgob/loader.lua
	
clean:
	$(RM) loader.o $(NAME)
	
.PHONY: help
help:
	@echo Options:
	@echo
	@echo AMD64=1 to build for 64 bits
