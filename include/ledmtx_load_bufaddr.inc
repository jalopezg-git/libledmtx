; -*- Assembler -*-
; This file provides the `LOAD_BUFADDR_IN_FSR0` macro that inserts the required
; instructions to load the address of a buffer in FSR0.
;
; The macro takes the name of an extern symbol in a `udata` section that
; resolves to the RAM address of such buffer, i.e. `_ledmtx_frontbuffer` refers
; to a 2-byte storage that contains a pointer to the address of the front
; buffer.
; Note that in single buffer configuration, the argument is discarded and the
; address of `_ledmtx_framebuffer` is always loaded.

  include <ledmtx_config.h>

#ifndef __LEDMTX_LOAD_BUFADDR_INC__
#define __LEDMTX_LOAD_BUFADDR_INC__

  extern _ledmtx_frontbuffer
  extern _ledmtx_backbuffer
  extern _ledmtx_framebuffer

LOAD_BUFADDR_IN_FSR0	macro	buffer
#if (LEDMTX_HAVE_DOUBLE_BUFFER == 1)
  movff		buffer+0, FSR0L
  movff		buffer+1, FSR0H
#else
  lfsr		0, _ledmtx_framebuffer
#endif
  endm

;; RCON<POR> is typically used to signal a Power-on Reset.  Once the device has
;; booted it is most likely useless.  Reuse it to indicate 'do-swapbuffers-on-vsync'.
CLEAR_SWAPBUFFERS_ON_VSYNC	macro
  bsf		RCON, POR, A
  endm

SET_SWAPBUFFERS_ON_VSYNC	macro
  bcf		RCON, POR, A
  endm

#endif
