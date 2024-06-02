; REQUIRES: LEDMTX_HAVE_DOUBLE_BUFFER
; COM: Unit test for the `ledmtx_swapbuffers()` and `ledmtx_swapbuffers_on_vsync()` routines
; RUN: %gpasm %ASFLAGS -c -o %t.o %s
; RUN: %gplink %GPLINKFLAGS -o %t.hex %t.o %ledmtx_src_dir/core/libledmtx_core.lib crt0i.o libdev18f452.lib
; RUN: echo -e 'break w (rcon & 0x04) == 0x00\n	run\n \
; RUN:          _RCON\n	run\n \
; RUN:          _RCON\n \
; RUN:          r0x00\n \
; RUN:          r0x01\n \
; RUN:          r0x02\n \
; RUN:          r0x03\n \
; RUN:          quit\n' | %gpsim --cli --processor=p18f452 %t.cod | FileCheck %s

  radix dec

  include <ledmtx_config.h>
  include _P18FXXX_INC
  include "../test_case_prologue.inc"

  extern _ledmtx_swapbuffers
  extern _ledmtx_swapbuffers_on_vsync

  global _ledmtx_framebuffer
  global _main
  global _stack_end

  udata 0x1ff
_stack_end	res	1

.test_idata  idata 0x400
; framebuffer size is 32x7 (i.e., stride = 4) + 4-byte padding
_ledmtx_framebuffer		res 32
_ledmtx_backbuffer_storage	res 28

.registers	udata_ovr	0x0000
r0x00	res	1
r0x01	res	1
r0x02	res	1
r0x03	res	1

  code
;; void main(void)
_main:
  TEST_CASE_PROLOGUE		32, 7

  movlw		high(_ledmtx_backbuffer_storage)
  movff		WREG, _ledmtx_backbuffer+1
  movlw		low(_ledmtx_backbuffer_storage)
  movff		WREG, _ledmtx_backbuffer+0

; CHECK: _RCONbits = 0x{{.}}8
  bsf		RCON, PD, a
  call		_ledmtx_swapbuffers_on_vsync
  bcf		RCON, PD, a	; hits breakpoint set by `break w (rcon & 0x04) = 0x00`

; COM: Check that pointers in `ledmtx_(front|back)buffer` have been swapped and
; COM: that swapbuffers-on-vsync flags has been cleared, i.e. _RCON<POR> is set.
; CHECK: _RCONbits = 0x{{.}}a
; CHECK: r0x00 = 0x0
; CHECK: r0x01 = 0x0
; CHECK: r0x02 = 0x0
; CHECK: r0x03 = 0x0
  bsf		RCON, PD, a
  call		_ledmtx_swapbuffers

  movff		_ledmtx_frontbuffer+0, WREG
  xorlw		low(_ledmtx_backbuffer_storage)
  movwf		r0x00, a
  movff		_ledmtx_frontbuffer+1, WREG
  xorlw		high(_ledmtx_backbuffer_storage)
  movwf		r0x01, a
  movff		_ledmtx_backbuffer+0, WREG
  xorlw		low(_ledmtx_framebuffer)
  movwf		r0x02, a
  movff		_ledmtx_backbuffer+1, WREG
  xorlw		high(_ledmtx_framebuffer)
  movwf		r0x03, a

  bcf		RCON, PD, a	; hits breakpoint set by `break w (rcon & 0x04) = 0x00`
  return

  end
