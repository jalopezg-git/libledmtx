CC = sdcc
P18FXXX = 18f452

# 32x7 @ 50Hz (for uC OSC frequency = 8 MHz)
OSC_HZ = 8000000
VIDEO_MODE_DESC = 32 7 7 50

SRCDIR = ../../src
DRIVER = r393c164

OBJECTS = $(DRIVER:%=libledmtx_%.o) $(SRCDIR)/font/libledmtx_font5x7.o
LDFLAGS = -mpic16 -p$(P18FXXX) --use-non-free -Wl-m -L$(SRCDIR)/core -L$(SRCDIR)/modules/scrollstr \
  -l libledmtx_core.lib -l libledmtx_scrollstr.lib
CFLAGS = -mpic16 -p$(P18FXXX) --fomit-frame-pointer --pstack-model=small --use-non-free -I$(SRCDIR)/../include

OBJECTS += scrollstr32x7.o

all: ledmtx_modegen_modes.h scrollstr32x7.hex

clean:
	rm -f *~ *.asm *.cod *.hex *.lst *.map *.o ledmtx_modegen_modes.h

ledmtx_modegen_modes.h:
	$(SRCDIR)/../support/ledmtx_modegen/ledmtx_modegen --osc-hz $(OSC_HZ) --default=0 $(VIDEO_MODE_DESC) > $@

scrollstr32x7.hex: $(OBJECTS)
	$(CC) $(LDFLAGS) -o $@ $^

$(DRIVER:%=libledmtx_%.o): $(DRIVER:%=ledmtx_%.inc)
	(cd $(SRCDIR)/driver && $(MAKE) D=$(DRIVER) O=$(CURDIR) driver)

%.o: %.c
	$(CC) -c $(CFLAGS) -o $@ $<
