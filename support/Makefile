SUBDIRS = ledmtx_tmr0config

all clean install:
	list='$(SUBDIRS)'; for subdir in $$list; do \
	  echo "Making $@ in $$subdir"; \
	  (cd $$subdir && $(MAKE) $@); \
	done

clean: clean-support

clean-support:
	rm -f *~
