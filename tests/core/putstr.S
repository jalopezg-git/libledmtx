; COM: Unit test for the `ledmtx_putstr()` routine
; RUN: %gpasm %ASFLAGS -c -o %t.o %s
; RUN: %gplink %GPLINKFLAGS -o %t.hex %t.o %ledmtx_src_dir/core/libledmtx_core.lib %ledmtx_src_dir/font/libledmtx_font5x7.o \
; RUN: 		crt0i.o libdev18f452.lib
; RUN: echo -e 'break w (rcon & 0x04) == 0x00\n \
; RUN:          run\n dump\n \
; RUN:          quit\n' | %gpsim --cli --processor=p18f452 %t.hex | FileCheck %s

  radix dec

  include <ledmtx_config.h>
  include _P18FXXX_INC

  extern _ledmtx_config_stride
  extern _ledmtx_font
  extern _ledmtx_font_sz_w
  extern _ledmtx_font_sz_h
  extern _ledmtx_font_mask
  extern _ledmtx_font5x7
  extern _ledmtx_putstr

  global _ledmtx_framebuffer
  global _main
  global _stack_end

  udata 0x1ff
_stack_end	res	1

  idata
_str	db 'T', 'e', 's', 't', '$', 0x00

.test_idata  idata 0x400
_ledmtx_framebuffer	res 28	; framebuffer size is 32x7 (i.e., stride = 4)

  code
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

; COM: * * * * * _ _ _ _ _ _ _ _ _ _ _ _ _ _ * _ _ _ _ _ _ * _ _ _ _ _ 
; COM: _ _ * _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ * _ _ _ _ _ * * * * _ _ _ 
; COM: _ _ * _ _ _ _ * * * _ _ _ * * * _ _ * * * _ _ _ * _ * _ _ _ _ _ 
; COM: _ _ * _ _ _ * _ _ _ * _ * _ _ _ _ _ _ * _ _ _ _ _ * * * _ _ _ _ 
; COM: _ _ * _ _ _ * * * * * _ _ * * * _ _ _ * _ _ _ _ _ _ * _ * _ _ _ 
; COM: _ _ * _ _ _ * _ _ _ _ _ _ _ _ _ * _ _ * _ _ * _ * * * * _ _ _ _ 
; COM: _ _ * _ _ _ _ * * * _ _ * * * * _ _ _ _ * * _ _ _ _ * _ _ _ _ _ 
; CHECK: 0400:  f8 00 10 20 20 00 10 78 21 c7 38 a0 22 28 10 70
; CHECK: 0410:  23 e7 10 28 22 00 92 f0 21 cf 0c 20
  movlw		high(_str) 		; str
  movwf		POSTDEC1, a
  movlw		low(_str)
  movwf		POSTDEC1, a
  movlw		0 		; y
  movwf		POSTDEC1, a
  movlw		0 		; x
  movwf		POSTDEC1, a
  call		_ledmtx_putstr
  movf		PREINC1, w, a
  movf		PREINC1, w, a
  movf		PREINC1, w, a
  movf		PREINC1, w, a

  bcf		RCON, PD, a	; hits breakpoint set by `break w (rcon & 0x04) = 0x00`
  return

  end
