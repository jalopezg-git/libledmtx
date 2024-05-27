; COM: Unit test for the `ledmtx_putpixel()` routine
; RUN: %gpasm %ASFLAGS -c -o %t.o %s
; RUN: %gplink %GPLINKFLAGS -o %t.hex %t.o %ledmtx_src_dir/core/libledmtx_core.lib crt0i.o libdev18f452.lib
; RUN: echo -e 'break w (rcon & 0x04) == 0x00\n \
; RUN:          run\n dump\n \
; RUN:          quit\n' | %gpsim --cli --processor=p18f452 %t.hex | FileCheck %s

  radix dec

  include <ledmtx_config.h>
  include _P18FXXX_INC

  extern _ledmtx_config_stride
  extern _ledmtx_putpixel

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
  movlw		4
  movwf		_ledmtx_config_stride, a

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

; CHECK: 0400:  aa 55 aa 55 aa 55 aa 55 ea 55 aa 55 aa 55 aa 55
; CHECK: 0410:  aa 55 aa 55 aa 55 aa 55 aa 55 aa 55
  movlw		1 		; val
  movwf		POSTDEC1, a
  movlw		2 		; y
  movwf		POSTDEC1, a
  movlw		1 		; x
  movwf		POSTDEC1, a
  call		_ledmtx_putpixel
  movf		PREINC1, w, a
  movf		PREINC1, w, a
  movf		PREINC1, w, a

  movlw		0 		; val
  movwf		POSTDEC1, a
  movlw		1 		; y
  movwf		POSTDEC1, a
  movlw		1 		; x
  movwf		POSTDEC1, a
  call		_ledmtx_putpixel
  movf		PREINC1, w, a
  movf		PREINC1, w, a
  movf		PREINC1, w, a

  bcf		RCON, PD, a	; hits breakpoint set by `break w (rcon & 0x04) = 0x00`
  return

  end
