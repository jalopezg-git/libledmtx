CFLAGS = -Wall -O2 -fomit-frame-pointer

OBJECTS = ledmtx_tmr0config.o

all: ledmtx_tmr0config

clean:
	rm -f *~ *.o ledmtx_tmr0config

install: all mkdir-install
	cp ledmtx_tmr0config $(BINDIR)/ledmtx_tmr0config

mkdir-install:
	[ -d $(BINDIR) ] || mkdir -p $(BINDIR)

ledmtx_tmr0config: $(OBJECTS)
	$(CC) -o $@ $^

%.o: %.c
	$(CC) -c $(CFLAGS) -o $@ $<
