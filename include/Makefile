all: ;

clean:
	rm -f *~

install: all mkdir-install
	cp *.h $(INCLUDEDIR)

mkdir-install:
	[ -d $(INCLUDEDIR) ] || mkdir -p $(INCLUDEDIR)
