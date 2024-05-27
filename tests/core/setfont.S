; COM: Unit test for the `ledmtx_setfont()` routine
; RUN: %gpasm %ASFLAGS -c -o %t.o %s
; RUN: %gplink %GPLINKFLAGS -o %t.hex %t.o %ledmtx_src_dir/core/libledmtx_core.lib %ledmtx_src_dir/font/libledmtx_font5x7.o \
; RUN: 		crt0i.o libdev18f452.lib
; RUN: echo -e 'break w (rcon & 0x04) == 0x00\n	run\n \
; RUN:          _ledmtx_font\n \
; RUN:          _ledmtx_font_sz_w\n \
; RUN:          _ledmtx_font_sz_h\n \
; RUN:          _ledmtx_font_mask\n \
; RUN:          quit\n' | %gpsim --cli --processor=p18f452 %t.cod | FileCheck %s

  radix dec

  include <ledmtx_config.h>
  include _P18FXXX_INC

  extern _ledmtx_font
  extern _ledmtx_font_sz_w
  extern _ledmtx_font_sz_h
  extern _ledmtx_font_mask
  extern _ledmtx_font5x7
  extern _ledmtx_setfont

  global _ledmtx_framebuffer
  global _main
  global _stack_end

  udata 0x1ff
_stack_end	res	1

.test_idata  idata 0x400
_ledmtx_framebuffer	res 28	; unused, but required to link

  code
;; void main(void)
_main:
; CHECK-NOT: _ledmtx_font = 0x0
; CHECK: _ledmtx_font_sz_w = 0x5
; CHECK: _ledmtx_font_sz_h = 0x7
; CHECK: _ledmtx_font_mask = 0xf8
  movlw		upper(_ledmtx_font5x7) 		; font
  movwf		POSTDEC1, a
  movlw		high(_ledmtx_font5x7)
  movwf		POSTDEC1, a
  movlw		low(_ledmtx_font5x7)
  movwf		POSTDEC1, a
  call		_ledmtx_setfont
  movf		PREINC1, w, a
  movf		PREINC1, w, a
  movf		PREINC1, w, a

  bcf		RCON, PD, a	; hits breakpoint set by `break w (rcon & 0x04) = 0x00`
  return

  end
