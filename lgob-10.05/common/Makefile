include ../config.mk
PKG_PACKAGES=$(PKG_LUA)
NAME=common.so
include ../flags.mk

# Source
SOURCES=$(wildcard src/*.c)
OBJECTS=$(SOURCES:.c=.o)

# Rules

.PHONY: all
all: $(SOURCES) $(NAME)
	
$(NAME): $(OBJECTS)
	$(CC) $(OBJECTS) -o $@ $(LDFLAGS)

.c.o:
	$(CC) $(CFLAGS) $< -o $@
	
.PHONY: install	
install: all
	$(MKDIR) $(DESTDIR)/lib/lua/5.1/lgob
	$(MKDIR) $(DESTDIR)/include/lgob/common
	$(CP) $(NAME) $(DESTDIR)/lib/lua/5.1/lgob/
	$(CP) src/types.h $(DESTDIR)/include/lgob/common

.PHONY: uninstall	
uninstall:
	$(RM) $(DESTDIR)/lib/lua/5.1/lgob/$(NAME)
	$(RM) $(DESTDIR)/include/lgob/common

.PHONY: clean
clean:
	$(RM) src/*.o $(NAME)
	
.PHONY: help
help:
	@echo Options:
	@echo
	@echo AMD64=1 to build for 64 bits
	@echo DEBUG=1 to enable debug mode
