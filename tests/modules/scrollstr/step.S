; COM: Unit test for the `ledmtx_scrollstr_step()` routine
; RUN: %gpasm %ASFLAGS -c -o %t.o %s
; RUN: %gplink %GPLINKFLAGS -o %t.hex %t.o %ledmtx_src_dir/core/libledmtx_core.lib  %ledmtx_src_dir/font/libledmtx_font5x7.o \
; RUN: 		 %ledmtx_src_dir/modules/scrollstr/libledmtx_scrollstr.lib crt0i.o libdev18f452.lib
; RUN: echo -e 'break w (rcon & 0x04) == 0x00\n \
; RUN:          break e _test_stub_stop\n \
; RUN:          run\n	dump\n	\
; RUN:          run\n	\
; RUN:          quit\n' | %gpsim --cli --processor=p18f452 %t.cod | FileCheck %s

  radix dec

  include <ledmtx_config.h>
  include _P18FXXX_INC

  extern _ledmtx_config_stride
  extern _ledmtx_font
  extern _ledmtx_font_sz_w
  extern _ledmtx_font_sz_h
  extern _ledmtx_font_mask
  extern _ledmtx_font5x7
  extern _ledmtx_scrollstr_step

  global _test_stub_step
  global _test_stub_stop
  global _ledmtx_framebuffer
  global _main
  global _stack_end

  include <scrollstr_desc.inc>

  udata 0x1ff
_stack_end	res	1

.test_idata  idata 0x400
_ledmtx_framebuffer	res 28	; unused, but required to link

N_STEPS_BEFORE_DUMP	equ	19

  code
_test_stub_step:
  return
_test_stub_stop:
  return

;; void main(void)
_main:
  movlw		4
  movwf		_ledmtx_config_stride, a
  movlw		low(_ledmtx_font5x7)
  movwf		_ledmtx_font+0, a
  movlw		high(_ledmtx_font5x7)
  movwf		_ledmtx_font+1, a
  movlw		upper(_ledmtx_font5x7)
  movwf		_ledmtx_font+2, a
  movlw		5
  movwf		_ledmtx_font_sz_w, a
  movlw		7
  movwf		_ledmtx_font_sz_h, a
  movlw		0xf8
  movwf		_ledmtx_font_mask, a

; COM: Dump and check the framebuffer after `N_STEPS_BEFORE_DUMP` steps
  movlw		N_STEPS_BEFORE_DUMP
@before_dump_loop:
  movwf		POSTDEC1, a
  movlw		high(_scrollstr_desc_1)
  movwf		POSTDEC1, a
  movlw		low(_scrollstr_desc_1)
  movwf		POSTDEC1, a
  call		_ledmtx_scrollstr_step
  movf		PREINC1, w, a
  movf		PREINC1, w, a
  movf		PREINC1, w, a
  decfsz	WREG, w, a
  bra		@before_dump_loop

; CHECK: 0410:  1f 38 00 00 10 04 00 00 0e 78 00 00 00 00 00 00
; CHECK: 0420:  00 00 00 00 00 00 00 00 00 00 00 00
  bcf		RCON, PD, a	; hits breakpoint set by `break w (rcon & 0x04) = 0x00`

; COM: Keep calling `ledmtx_scrollstr_step()` until `_test_stub_stop` is invoked
@after_dump_loop:
  movlw		high(_scrollstr_desc_1)
  movwf		POSTDEC1, a
  movlw		low(_scrollstr_desc_1)
  movwf		POSTDEC1, a
  call		_ledmtx_scrollstr_step
  movf		PREINC1, w, a
  movf		PREINC1, w, a
  bra		@after_dump_loop

; CHECK:   BREAK:
  return

  end
