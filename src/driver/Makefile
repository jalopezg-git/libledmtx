include ../make.mk

SRCDIR = ..
SOURCES = libledmtx_r393c164.S Makefile

ifdef O
AFLAGS += -I $(O)
endif

all: ;

clean:
	rm -f *~

install: all mkdir-install
	list='$(SOURCES)'; for s in $$list; do \
	  cp $$s $(LIBDIR)/driver/$$s; \
	done

mkdir-install:
	[ -d $(LIBDIR)/driver ] || mkdir -p $(LIBDIR)/driver

driver: $(D:%=$(O)/libledmtx_%.o)

$(O)/%.o: %.S
	$(AS) -c $(AFLAGS) -o $@ $<
