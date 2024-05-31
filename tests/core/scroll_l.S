; COM: Unit test for the `ledmtx_scroll_l()` routine
; RUN: %gpasm %ASFLAGS -c -o %t.o %s
; RUN: %gplink %GPLINKFLAGS -o %t.hex %t.o %ledmtx_src_dir/core/libledmtx_core.lib crt0i.o libdev18f452.lib
; RUN: echo -e 'break w (rcon & 0x04) == 0x00\n \
; RUN:          run\n dump\n \
; RUN:          run\n dump\n \
; RUN:          quit\n' | %gpsim --cli --processor=p18f452 %t.hex | FileCheck %s

  radix dec

  include <ledmtx_config.h>
  include _P18FXXX_INC
  include "../test_case_prologue.inc"

  extern _ledmtx_scroll_l

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
;; void test_scroll_l_aligned(void)
_test_scroll_l_aligned:
  movlw		4 		; h
  movwf		POSTDEC1, a
  movlw		8 		; w
  movwf		POSTDEC1, a
  movlw		1 		; y
  movwf		POSTDEC1, a
  movlw		8 		; x
  movwf		POSTDEC1, a
  call		_ledmtx_scroll_l
  movf		PREINC1, w, a
  movf		PREINC1, w, a
  movf		PREINC1, w, a
  movf		PREINC1, w, a
  return

;; void test_scroll_l_unaligned(void)
_test_scroll_l_unaligned:
; COM: Implementation requires `x` and `w` to be a multiple of 8.  If not, the 3
; COM: LSb will be truncated so this becomes `ledmtx_scroll_l(0, 0, 16, 7)`
  movlw		7 		; h
  movwf		POSTDEC1, a
  movlw		17 		; w
  movwf		POSTDEC1, a
  movlw		0 		; y
  movwf		POSTDEC1, a
  movlw		1 		; x
  movwf		POSTDEC1, a
  call		_ledmtx_scroll_l
  movf		PREINC1, w, a
  movf		PREINC1, w, a
  movf		PREINC1, w, a
  movf		PREINC1, w, a
  return

;; void main(void)
_main:
  TEST_CASE_PROLOGUE		32, 7

; CHECK: 0400:  aa 55 aa 55 aa aa aa 55 aa aa aa 55 aa aa aa 55
; CHECK: 0410:  aa aa aa 55 aa 55 aa 55 aa 55 aa 55
  bsf		RCON, PD, a
  call		_test_scroll_l_aligned
  bcf		RCON, PD, a	; hits breakpoint set by `break w (rcon & 0x04) = 0x00`

; CHECK: 0400:  54 aa aa 55 55 54 aa 55 55 54 aa 55 55 54 aa 55
; CHECK: 0410:  55 54 aa 55 54 aa aa 55 54 aa aa 55
  bsf		RCON, PD, a
  call		_test_scroll_l_unaligned
  bcf		RCON, PD, a	; hits breakpoint set by `break w (rcon & 0x04) = 0x00`

  return

  end
