CFLAGS = -Wall -Wpedantic -O2 -std=c++20

OBJECTS = ledmtx_modegen.o

all: ledmtx_modegen

clean:
	rm -f *~ *.o ledmtx_modegen

install: all mkdir-install
	cp ledmtx_modegen $(BINDIR)/ledmtx_modegen

mkdir-install:
	[ -d $(BINDIR) ] || mkdir -p $(BINDIR)

ledmtx_modegen: $(OBJECTS)
	$(CXX) -o $@ $^

%.o: %.cpp
	$(CXX) -c $(CFLAGS) -o $@ $<
