SUBDIRS = include src support

all clean install:
	list='$(SUBDIRS)'; for subdir in $$list; do \
	  echo "Making $@ in $$subdir"; \
	  (cd $$subdir && $(MAKE) $@); \
	done

clean: clean-libledmtx

clean-libledmtx:
	rm -f *~
