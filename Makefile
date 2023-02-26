.PHONY: all build clean test

all: build test

include config.mk

clean:
	rm -fr $(BIN) $(LIB) $(OBJ)

build: clamour-build

test: libweb-test libjson-test libdiscord-test clamour-test

include libmbs/makefile.mk
include clamour/makefile.mk
include libdiscord/makefile.mk
include libjson/makefile.mk
include libweb/makefile.mk
