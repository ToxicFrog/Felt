include ../config.mk
PKG_PACKAGES=pangocairo $(PKG_LUA)
NAME=pangocairo.so
VERSION=`pkg-config --modversion pangocairo`
include ../flags.mk

$(NAME): pangocairo.o
	$(CC) pangocairo.o -o $(NAME) $(LDFLAGS)

src/iface.c: src/pangocairo.def src/pangocairo.ovr
	$(GEN) -i "$(PWD)/src/pangocairo.ovr" -o "$(PWD)/src/iface.c" -l "$(PWD)/log" -v $(VERSION)

pangocairo.o: src/iface.c src/pangocairo.c
	$(CC) $(CFLAGS) src/iface.c -o pangocairo.o

.PHONY: install
install: $(NAME)
	$(MKDIR) $(DESTDIR)/lib/lua/5.1/lgob/
	$(CP) $(NAME) $(DESTDIR)/lib/lua/5.1/lgob
	
.PHONY: uninstall
uninstall:
	$(RM) $(DESTDIR)/lib/lua/5.1/lgob/$(NAME)
	
clean:
	$(RM) pangocairo.o $(NAME) src/iface.c log
	
.PHONY: help
help:
	@echo Options:
	@echo
	@echo AMD64=1 to build for 64 bits
