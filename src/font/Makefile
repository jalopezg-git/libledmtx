include ../make.mk

SRCDIR = ..
OBJECTS = libledmtx_font5x7.o

all: $(OBJECTS)

clean:
	rm -f *~ *.lst *.o

install: all mkdir-install
	list='$(OBJECTS)'; for o in $$list; do \
	  cp $$o $(LIBDIR)/$$o; \
	done

mkdir-install:
	[ -d $(LIBDIR) ] || mkdir -p $(LIBDIR)

%.o: %.S
	$(AS) -c $(AFLAGS) -o $@ $<
