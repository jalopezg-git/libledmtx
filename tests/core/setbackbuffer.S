; REQUIRES: LEDMTX_HAVE_DOUBLE_BUFFER
; COM: Unit test for the `ledmtx_setbackbuffer()` routine
; RUN: %gpasm %ASFLAGS -c -o %t.o %s
; RUN: %gplink %GPLINKFLAGS -o %t.hex %t.o %ledmtx_src_dir/core/libledmtx_core.lib crt0i.o libdev18f452.lib
; RUN: echo -e 'break w (rcon & 0x04) == 0x00\n	run\n \
; RUN:          dump\n \
; RUN:          r0x00\n \
; RUN:          r0x01\n \
; RUN:          quit\n' | %gpsim --cli --processor=p18f452 %t.cod | FileCheck %s

  radix dec

  include <ledmtx_config.h>
  include _P18FXXX_INC
  include "../test_case_prologue.inc"

  extern _ledmtx_setbackbuffer
  extern _ledmtx_putpixel

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

  code
;; void main(void)
_main:
  TEST_CASE_PROLOGUE		32, 7

  movlw		high(_ledmtx_backbuffer_storage)
  movwf		POSTDEC1, a
  movlw		low(_ledmtx_backbuffer_storage)
  movwf		POSTDEC1, a
  call		_ledmtx_setbackbuffer
  movf		PREINC1, w, a
  movf		PREINC1, w, a

; COM: Check that only the backbuffer is touched by the call below
; CHECK: 0400:  00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
; CHECK: 0410:  00 00 00 00 00 00 00 00 00 00 00 00
; CHECK: 0420:  00 00 00 00 40 00 00 00 00 00 00 00 00 00 00 00
; CHECK: 0430:  00 00 00 00 00 00 00 00 00 00 00 00
  movlw		1 		; val
  movwf		POSTDEC1, a
  movlw		1 		; y
  movwf		POSTDEC1, a
  movlw		1 		; x
  movwf		POSTDEC1, a
  call		_ledmtx_putpixel
  movf		PREINC1, w, a
  movf		PREINC1, w, a
  movf		PREINC1, w, a

; COM: Check that `ledmtx_backbuffer` contains the expected data.  The
; COM: actual address depends on linker; the XOR below gives us 0x0000 though.
; CHECK: r0x00 = 0x0
; CHECK: r0x01 = 0x0
  movlw		low(_ledmtx_backbuffer_storage)
  xorwf		_ledmtx_backbuffer+0, w
  movwf		r0x00, a
  movlw		high(_ledmtx_backbuffer_storage)
  xorwf		_ledmtx_backbuffer+1, w
  movwf		r0x01, a

  bcf		RCON, PD, a	; hits breakpoint set by `break w (rcon & 0x04) = 0x00`
  return

  end
