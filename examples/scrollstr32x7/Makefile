CC = sdcc
P18FXXX = 18f452

SRCDIR = ../../src
DRIVER = r393c164

OBJECTS = $(DRIVER:%=libledmtx_%.o) $(SRCDIR)/font/libledmtx_font5x7.o
LFLAGS = -mpic16 -p$(P18FXXX) -Wl-m -L$(SRCDIR)/core -L$(SRCDIR)/modules/scrollstr \
  -l libledmtx_core.lib -l libledmtx_scrollstr.lib
CFLAGS = -mpic16 -p$(P18FXXX) --fomit-frame-pointer --pstack-model=small -I$(SRCDIR)/../include

OBJECTS += scrollstr32x7.o

all: scrollstr32x7.hex

clean:
	rm -f *~ *.asm *.cod *.hex *.lst *.map *.o

scrollstr32x7.hex: $(OBJECTS)
	$(CC) $(LFLAGS) -o $@ $^

$(DRIVER:%=libledmtx_%.o): $(DRIVER:%=ledmtx_%.inc)
	(cd $(SRCDIR)/driver && $(MAKE) D=$(DRIVER) O=$(CURDIR) driver)

%.o: %.c
	$(CC) -c $(CFLAGS) -o $@ $<
