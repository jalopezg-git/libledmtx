SUBDIRS = hello32x7 scrollstr32x7

all clean:
	list='$(SUBDIRS)'; for subdir in $$list; do \
	  echo "Making $@ in $$subdir"; \
	  (cd $$subdir && $(MAKE) $@); \
	done

clean: clean-examples

clean-examples:
	rm -f *~
