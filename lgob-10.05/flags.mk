# Compiler flags
CFLAGS=-c -pipe -Wall `pkg-config --cflags $(PKG_PACKAGES)`
LDFLAGS=-shared `pkg-config --libs $(PKG_PACKAGES)`

# Includes
ifdef INCDIR
	CFLAGS+=-I$(INCDIR)
endif

ifdef DESTDIR
	CFLAGS+=-I$(DESTDIR)/include
endif

ifdef LIBDIR
	LDFLAGS+=-L$(LIBDIR)
endif

# Options
ifdef AMD64
	CFLAGS+=-fPIC -DAMD64
else
	CFLAGS+=-fpic
endif

# Options
ifdef DEBUG
	CFLAGS+=-g -O0 -DIDEBUG
else
	CFLAGS+=-Os
endif
