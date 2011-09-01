include ../../make.mk

SRCDIR = ../..
OBJECTS = call_fsr0.o init.o interrupt.o reset.o start.o step.o stop.o udata.o

all: libledmtx_scrollstr.lib

clean:
	rm -f *~ *.lib *.lst *.o

install: all mkdir-install
	cp libledmtx_scrollstr.lib $(LIBDIR)/libledmtx_scrollstr.lib

mkdir-install:
	[ -d $(LIBDIR) ] || mkdir -p $(LIBDIR)

libledmtx_scrollstr.lib: $(OBJECTS)
	$(GPLIB) -c $@ $^

%.o: %.S
	$(AS) -c $(AFLAGS) -o $@ $<
