include make.mk

SRCDIR = .
OBJECTS = libledmtx_stdio.o
SUBDIRS = core driver font modules

all: $(OBJECTS)
clean: clean-src
install: install-src

all clean install:
	list='$(SUBDIRS)'; for subdir in $$list; do \
	  echo "Making $@ in $$subdir"; \
	  (cd $$subdir && $(MAKE) $@) ; \
	done

clean-src:
	rm -f *~ *.inc *.lst *.o

install-src: all mkdir-install
	cp make.mk $(LIBDIR)/make.mk
	list='$(OBJECTS)'; for o in $$list; do \
	  cp $$o $(LIBDIR)/$$o; \
	done

mkdir-install:
	[ -d $(LIBDIR) ] || mkdir -p $(LIBDIR)

%.o: %.S
	$(AS) -c $(ASFLAGS) -o $@ $<
