include ../config.mk
PKG_PACKAGES=gstreamer-0.10 $(PKG_LUA)
NAME=gst.so
VERSION=`pkg-config --modversion gstreamer-0.10`
include ../flags.mk

ifndef WITHOUT_XOVERLAY
	PKG_PACKAGES += gstreamer-interfaces-0.10
	CFLAGS += -DWITH_XOVERLAY
endif

# Source
SOURCES=$(wildcard src/*.c)

# Rules

.PHONY: all
all: $(SOURCES) $(NAME)
	
$(NAME): gst.o
	$(CC) gst.o -o $(NAME) $(LDFLAGS)

gst.o: $(SOURCES)
	$(CC) $(CFLAGS) src/interface.c -o gst.o

.PHONY: install	
install: all
	$(MKDIR) $(DESTDIR)/lib/lua/5.1/lgob
	$(CP) $(NAME) $(DESTDIR)/lib/lua/5.1/lgob

.PHONY: clean
clean:
	$(RM) *.o $(NAME) 
	
.PHONY: help
help:
	@echo Options:
	@echo
	@echo AMD64=1 to build for 64 bits
	@echo DEBUG=1 to enable debug mode
	@echo WITHOUT_XOVERLAY=1 to disable XOverlay
