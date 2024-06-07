; -*- Asm -*-
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

  extern _ledmtx_viewport_y
  extern _ledmtx_viewport_height
  extern _ledmtx_viewport_xoff
  extern _ledmtx_viewport_stride

LOAD_BUFADDR_IN_FSR0	macro	buffer
#if (LEDMTX_HAVE_DOUBLE_BUFFER == 1)
  movff		buffer+0, FSR0L
  movff		buffer+1, FSR0H
#else
  lfsr		0, _ledmtx_framebuffer
#endif
  endm

;; Provided that FSR0 points at beginning of frontbuffer (see `LOAD_BUFADDR_IN_FSR0`),
;; adjust it to point at end of row `nr`.
;; At end, PRODL shall equal the stride of the viewport.
AT_END_OF_VIEWPORT_ROW	macro	nr
#if (LEDMTX_HAVE_VIEWPORT != 1)
  ; Slightly faster version for viewport-disabled builds.
  ; Compute the result of the expression `FSR0 += ((nr + 1) * _ledmtx_config_stride) - 1`
  incf		nr, w, A
  mulwf		_ledmtx_config_stride, A
  movf		PRODL, w, A
  addwf		FSR0L, f, A
  movf		PRODH, w, A
  addwfc	FSR0H, f, A
  movf		POSTDEC0, f, A
  movff		_ledmtx_config_stride, PRODL
#else
  ; Compute the result of the expression `FSR0 += ((_ledmtx_viewport_y + nr) * _ledmtx_config_stride)
  ;                                               + (_ledmtx_viewport_xoff + _ledmtx_viewport_stride) - 1`
  movf		_ledmtx_viewport_y, w, A
  addwf		nr, w, A	; cannot overflow as `(_ledmtx_viewport_y + nr) <= _ledmtx_config_height`
  mulwf		_ledmtx_config_stride, A
  movf		PRODL, w, A
  addwf		FSR0L, f, A
  movf		PRODH, w, A
  addwfc	FSR0H, f, A
  movff		_ledmtx_viewport_stride, PRODL
  decf		PRODL, w, A
  addwf		_ledmtx_viewport_xoff, w, A	; cannot overflow either
  addwf		FSR0L, f, A
  clrf		WREG, A
  addwfc	FSR0H, f, A
#endif
  endm

#if (LEDMTX_HAVE_VIEWPORT != 1)
#define _ledmtx_viewport_height	_ledmtx_config_height
#endif

;; RCON<POR> is typically used to signal a Power-on Reset.  Once the device has
;; booted it is most likely useless.  Reuse it to indicate 'do-swapbuffers-on-vsync'.
CLEAR_SWAPBUFFERS_ON_VSYNC	macro
  bsf		RCON, POR, A
  endm

SET_SWAPBUFFERS_ON_VSYNC	macro
  bcf		RCON, POR, A
  endm

#endif
