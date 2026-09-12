APPNAME = spd_dump
LIBUSB  ?= 1

CC      ?= cc
CFLAGS  ?= -O2 -Wall -Wextra -std=c99 -pedantic -Wno-unused
LIBS    ?= -lm -lpthread

CFLAGS += -DUSE_LIBUSB=$(LIBUSB)

ifeq ($(LIBUSB), 1)
CFLAGS += $(shell pkg-config --cflags libusb-1.0 2>/dev/null)
LIBS   += $(shell pkg-config --libs   libusb-1.0 2>/dev/null)
endif

.PHONY: all clean

all: GITVER.h $(APPNAME)

clean:
	$(RM) GITVER.h $(APPNAME)

GITVER.h:
	echo "#define GIT_VER \"$(shell git rev-parse --abbrev-ref HEAD)\"" > GITVER.h
	echo "#define GIT_SHA1 \"$(shell git rev-parse HEAD)\"" >> GITVER.h

$(APPNAME): $(APPNAME).c common.c
	$(CC) $(CFLAGS) -o $@ $^ $(LIBS)
