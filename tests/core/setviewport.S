; REQUIRES: LEDMTX_HAVE_VIEWPORT
; COM: Unit test for the `ledmtx_setviewport()` routine
; RUN: %gpasm %ASFLAGS -c -o %t.o %s
; RUN: %gplink %GPLINKFLAGS -o %t.hex %t.o %ledmtx_src_dir/core/libledmtx_core.lib crt0i.o libdev18f452.lib
; RUN: echo -e 'break w (rcon & 0x04) == 0x00\n	run\n \
; RUN:          _WREG\n run\n \
; RUN:          _WREG\n run\n \
; RUN:          _WREG\n \
; RUN:          _ledmtx_viewport_y\n \
; RUN:          _ledmtx_viewport_height\n \
; RUN:          _ledmtx_viewport_xoff\n \
; RUN:          _ledmtx_viewport_stride\n \
; RUN:          quit\n' | %gpsim --cli --processor=p18f452 %t.cod | FileCheck %s

  radix dec

  include <ledmtx_config.h>
  include _P18FXXX_INC
  include "../test_case_prologue.inc"

  extern _ledmtx_setviewport

  global _ledmtx_framebuffer
  global _ledmtx_driver_init
  global _ledmtx_driver_viewport_changed
  global _main
  global _stack_end

  udata 0x1ff
_stack_end	res	1

.test_idata  idata 0x400
_ledmtx_framebuffer	res 28	; unused, but required to link

  code
_ledmtx_driver_init:
  return

_ledmtx_driver_viewport_changed:
  return

;; void test_inval(void)
_test_inval:
; COM: Check failed call due to `x + width` greater than framebuffer width
; CHECK: _WREG = 0x0
  bsf		RCON, PD, a
  movlw		7		; height
  movwf		POSTDEC1, a
  movlw		25		; width
  movwf		POSTDEC1, a
  movlw		0		; y
  movwf		POSTDEC1, a
  movlw		8		; x
  movwf		POSTDEC1, a
  call		_ledmtx_setviewport
  movf		PREINC1, f, a
  movf		PREINC1, f, a
  movf		PREINC1, f, a
  movf		PREINC1, f, a
  bcf		RCON, PD, a	; hits breakpoint set by `break w (rcon & 0x04) = 0x00`

; COM: Check failed call due to `y + height` greater than framebuffer height
; CHECK: _WREG = 0x0
  bsf		RCON, PD, a
  movlw		6		; height
  movwf		POSTDEC1, a
  movlw		32		; width
  movwf		POSTDEC1, a
  movlw		2		; y
  movwf		POSTDEC1, a
  movlw		0		; x
  movwf		POSTDEC1, a
  call		_ledmtx_setviewport
  movf		PREINC1, f, a
  movf		PREINC1, f, a
  movf		PREINC1, f, a
  movf		PREINC1, f, a
  bcf		RCON, PD, a	; hits breakpoint set by `break w (rcon & 0x04) = 0x00`
  return

;; void main(void)
_main:
  TEST_CASE_PROLOGUE		32, 7

  call		_test_inval

; CHECK: _WREG = 0x1
; CHECK: _ledmtx_viewport_y = 0x2
; CHECK: _ledmtx_viewport_height = 0x5
; CHECK: _ledmtx_viewport_xoff = 0x1
; CHECK: _ledmtx_viewport_stride = 0x3
  bsf		RCON, PD, a
  movlw		5		; height
  movwf		POSTDEC1, a
  movlw		24		; width
  movwf		POSTDEC1, a
  movlw		2		; y
  movwf		POSTDEC1, a
  movlw		8		; x
  movwf		POSTDEC1, a
  call		_ledmtx_setviewport
  movf		PREINC1, f, a
  movf		PREINC1, f, a
  movf		PREINC1, f, a
  movf		PREINC1, f, a
  bcf		RCON, PD, a	; hits breakpoint set by `break w (rcon & 0x04) = 0x00`
  return

  end
