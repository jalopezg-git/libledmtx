CC = sdcc
P18FXXX = 18f452

SRCDIR = ../../src
DRIVER = r393c164

OBJECTS = $(DRIVER:%=libledmtx_%.o) $(SRCDIR)/font/libledmtx_font5x7.o \
  $(SRCDIR)/libledmtx_stdio.o
LDFLAGS = -mpic16 -p$(P18FXXX) --use-non-free -Wl-m -L$(SRCDIR)/core -l libc18f.lib -l libledmtx_core.lib
CFLAGS = -mpic16 -p$(P18FXXX) --fomit-frame-pointer --pstack-model=small --use-non-free -I$(SRCDIR)/../include

OBJECTS += hello32x7.o

all: hello32x7.hex

clean:
	rm -f *~ *.asm *.cod *.hex *.lst *.map *.o

hello32x7.hex: $(OBJECTS)
	$(CC) $(LDFLAGS) -o $@ $^

$(DRIVER:%=libledmtx_%.o): $(DRIVER:%=ledmtx_%.inc)
	(cd $(SRCDIR)/driver && $(MAKE) D=$(DRIVER) O=$(CURDIR) driver)

%.o: %.c
	$(CC) -c $(CFLAGS) -o $@ $<
