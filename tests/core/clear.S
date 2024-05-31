; COM: Unit test for the `ledmtx_clear()` routine
; RUN: %gpasm %ASFLAGS -c -o %t.o %s
; RUN: %gplink %GPLINKFLAGS -o %t.hex %t.o %ledmtx_src_dir/core/libledmtx_core.lib crt0i.o libdev18f452.lib
; RUN: echo -e 'break w (rcon & 0x04) == 0x00\n \
; RUN:          run\n dump\n \
; RUN:          quit\n' | %gpsim --cli --processor=p18f452 %t.hex | FileCheck %s

  radix dec

  include <ledmtx_config.h>
  include _P18FXXX_INC
  include "../test_case_prologue.inc"

  extern _ledmtx_clear

  global _ledmtx_framebuffer
  global _main
  global _stack_end

  udata 0x1ff
_stack_end	res	1

.test_idata  idata 0x400
; framebuffer size is 32x7 (i.e., stride = 4)
_ledmtx_framebuffer	db 0xaa, 0x55, 0xaa, 0x55, 0xaa, 0x55, 0xaa, 0x55
			db 0xaa, 0x55, 0xaa, 0x55, 0xaa, 0x55, 0xaa, 0x55
			db 0xaa, 0x55, 0xaa, 0x55, 0xaa, 0x55, 0xaa, 0x55
			db 0xaa, 0x55, 0xaa, 0x55

  code
;; void main(void)
_main:
  TEST_CASE_PROLOGUE		32, 7

; CHECK: 0400:  00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
; CHECK: 0410:  00 00 00 00 00 00 00 00 00 00 00 00
  movwf		POSTDEC1, a
  call		_ledmtx_clear
  movf		PREINC1, w, a

  bcf		RCON, PD, a	; hits breakpoint set by `break w (rcon & 0x04) = 0x00`
  return

  end
