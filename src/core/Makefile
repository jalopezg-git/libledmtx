include ../make.mk

SRCDIR = ..
OBJECTS = clear.o init.o putchar.o putpixel.o putstr.o scroll_l.o scroll_r.o setfont.o udata.o
ifeq ($(ENABLE_DOUBLE_BUFFER), 1)
OBJECTS += setbackbuffer.o swapbuffers.o
endif
ifeq ($(ENABLE_VIEWPORT), 1)
OBJECTS += setviewport.o
endif

all: libledmtx_core.lib

clean:
	rm -f *~ *.lib *.lst *.o

install: all mkdir-install
	cp libledmtx_core.lib $(LIBDIR)/libledmtx_core.lib

mkdir-install:
	[ -d $(LIBDIR) ] || mkdir -p $(LIBDIR)

libledmtx_core.lib: $(OBJECTS)
	$(GPLIB) -c $@ $^

%.o: %.S
	$(AS) -c $(ASFLAGS) -o $@ $<
