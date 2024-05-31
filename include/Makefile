include ../src/make.mk

AUTOGEN = ledmtx_config.h

.ONESHELL:
all: $(AUTOGEN)

clean:
	rm -f *~ $(AUTOGEN)

install: all mkdir-install
	cp *.h *.inc $(INCLUDEDIR)

mkdir-install:
	[ -d $(INCLUDEDIR) ] || mkdir -p $(INCLUDEDIR)

ledmtx_config.h: ledmtx_config.h.in ../src/make.mk
	_P18FXXX="$(P18FXXX)" \
		_P18FXXX_INC="p$(P18FXXX).inc" \
		LEDMTX_HAVE_DOUBLE_BUFFER="$(ENABLE_DOUBLE_BUFFER)" \
		LEDMTX_GITREVISION="$(shell git rev-parse HEAD)" envsubst < ledmtx_config.h.in > ledmtx_config.h
