SUBDIRS = perf scrollstr

clean: clean-modules

all clean install:
	list='$(SUBDIRS)'; for subdir in $$list; do \
	  echo "Making $@ in $$subdir"; \
	  (cd $$subdir && $(MAKE) $@); \
	done

clean-modules:
	rm -f *~
