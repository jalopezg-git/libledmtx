; COM: Unit test for the `ledmtx_putchar()` routine
; RUN: %gpasm %ASFLAGS -c -o %t.o %s
; RUN: %gplink %GPLINKFLAGS -o %t.hex %t.o %ledmtx_src_dir/core/libledmtx_core.lib %ledmtx_src_dir/font/libledmtx_font5x7.o \
; RUN: 		crt0i.o libdev18f452.lib
; RUN: echo -e 'break w (rcon & 0x04) == 0x00\n \
; RUN:          run\n dump\n \
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
  extern _ledmtx_putchar

  global _ledmtx_framebuffer
  global _test_putchar_cpy
  global _test_putchar_ior
  global _main
  global _stack_end

  udata 0x1ff
_stack_end	res	1

.test_idata  idata 0x400
_ledmtx_framebuffer	res 28	; framebuffer size is 32x7 (i.e., stride = 4)

LEDMTX_PUTCHAR_CPY	equ	0x00
LEDMTX_PUTCHAR_IOR	equ	0x01

  code
;; void test_putchar_cpy(void)
_test_putchar_cpy:
  movlw		'H' 		; c
  movwf		POSTDEC1, a
  movlw		0 		; y
  movwf		POSTDEC1, a
  movlw		0 		; x
  movwf		POSTDEC1, a
  movlw		0xff 		; mask
  movwf		POSTDEC1, a
  movlw		LEDMTX_PUTCHAR_CPY 		; op
  call		_ledmtx_putchar
  movf		PREINC1, w, a
  movf		PREINC1, w, a
  movf		PREINC1, w, a
  movf		PREINC1, w, a

; COM: put char at x=6, i.e. unaligned to octet boundary
  movlw		'i' 		; c
  movwf		POSTDEC1, a
  movlw		0 		; y
  movwf		POSTDEC1, a
  movlw		6 		; x
  movwf		POSTDEC1, a
  movlw		0xff 		; mask
  movwf		POSTDEC1, a
  movlw		LEDMTX_PUTCHAR_CPY 		; op
  call		_ledmtx_putchar
  movf		PREINC1, w, a
  movf		PREINC1, w, a
  movf		PREINC1, w, a
  movf		PREINC1, w, a

  movlw		'!' 		; c
  movwf		POSTDEC1, a
  movlw		0 		; y
  movwf		POSTDEC1, a
  movlw		12 		; x
  movwf		POSTDEC1, a
  movlw		0xff 		; mask
  movwf		POSTDEC1, a
  movlw		LEDMTX_PUTCHAR_CPY 		; op
  call		_ledmtx_putchar
  movf		PREINC1, w, a
  movf		PREINC1, w, a
  movf		PREINC1, w, a
  movf		PREINC1, w, a

  return

;; void test_putchar_ior(void)
_test_putchar_ior:
  movlw		'2' 		; c
  movwf		POSTDEC1, a
  movlw		0 		; y
  movwf		POSTDEC1, a
  movlw		12 		; x
  movwf		POSTDEC1, a
  movlw		0xaa 		; mask
  movwf		POSTDEC1, a
  movlw		LEDMTX_PUTCHAR_IOR 		; op
  call		_ledmtx_putchar
  movf		PREINC1, w, a
  movf		PREINC1, w, a
  movf		PREINC1, w, a
  movf		PREINC1, w, a

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

; COM: * _ _ _ * _ _ _ * _ _ _ _ _ * _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ 
; COM: * _ _ _ * _ _ _ _ _ _ _ _ _ * _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ 
; COM: * _ _ _ * _ _ * * _ _ _ _ _ * _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ 
; COM: * * * * * _ _ _ * _ _ _ _ _ * _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ 
; COM: * _ _ _ * _ _ _ * _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ 
; COM: * _ _ _ * _ _ _ * _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ 
; COM: * _ _ _ * _ _ * * * _ _ _ _ * _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ 
; CHECK: 0400:  88 82 00 00 88 02 00 00 89 82 00 00 f8 82 00 00
; CHECK: 0410:  88 80 00 00 88 80 00 00 89 c2 00 00
  bsf		RCON, PD, a
  call		_test_putchar_cpy
  bcf		RCON, PD, a	; hits breakpoint set by `break w (rcon & 0x04) = 0x00`

; COM: * _ _ _ * _ _ _ * _ _ _ _ _ * _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ 
; COM: * _ _ _ * _ _ _ _ _ _ _ * _ * _ * _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ 
; COM: * _ _ _ * _ _ * * _ _ _ _ _ * _ * _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ 
; COM: * * * * * _ _ _ * _ _ _ _ _ * _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ 
; COM: * _ _ _ * _ _ _ * _ _ _ _ _ * _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ 
; COM: * _ _ _ * _ _ _ * _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ 
; COM: * _ _ _ * _ _ * * * _ _ * _ * _ * _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ 
; CHECK: 0400:  88 82 00 00 88 0a 80 00 89 82 80 00 f8 82 00 00
; CHECK: 0410:  88 82 00 00 88 80 00 00 89 ca 80 00
  bsf		RCON, PD, a
  call		_test_putchar_ior
  bcf		RCON, PD, a	; hits breakpoint set by `break w (rcon & 0x04) = 0x00`
  return

  end
