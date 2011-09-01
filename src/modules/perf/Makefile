include ../../make.mk

SRCDIR = ../..
OBJECTS = getintrtime.o init.o udata.o

all: libledmtx_perf.lib

clean:
	rm -f *~ *.lib *.lst *.o

install: all mkdir-install
	cp libledmtx_perf.lib $(LIBDIR)/libledmtx_perf.lib

mkdir-install:
	[ -d $(LIBDIR) ] || mkdir -p $(LIBDIR)

libledmtx_perf.lib: $(OBJECTS)
	$(GPLIB) -c $@ $^

%.o: %.S
	$(AS) -c $(AFLAGS) -o $@ $<
