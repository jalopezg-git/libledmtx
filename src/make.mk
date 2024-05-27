# Target device
P18FXXX = 18f452

GPLIB = gplib
AS = gpasm
INCLUDEDIR ?= $(SRCDIR)/../include
ASFLAGS = -I$(SRCDIR) -I$(INCLUDEDIR) -p $(P18FXXX) -w 0
