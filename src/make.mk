# Target device
P18FXXX = 18f452

GPLIB = gplib
AS = gpasm
INCLUDEDIR ?= $(SRCDIR)/../include
ASFLAGS = -I$(SRCDIR) -I$(INCLUDEDIR) -p $(P18FXXX) -w 0

# Optional features
ifdef ENABLE_DOUBLE_BUFFER
ENABLE_DOUBLE_BUFFER = 1
endif
ENABLE_DOUBLE_BUFFER ?= 0
