; COM: Unit test for the `ledmtx_init()` routine
; RUN: %gpasm %ASFLAGS -c -o %t.o %s
; RUN: %gplink %GPLINKFLAGS -o %t.hex %t.o %ledmtx_src_dir/core/libledmtx_core.lib crt0i.o libdev18f452.lib
; RUN: echo -e 'break w (rcon & 0x04) == 0x00\n	run\n \
; RUN:          _ledmtx_config_width\n \
; RUN:          _ledmtx_config_height\n \
; RUN:          _ledmtx_config_stride\n \
; RUN:          _ledmtx_config_tmr0h\n \
; RUN:          _ledmtx_config_tmr0l\n \
; RUN:          _ledmtx_config_t0con\n \
; RUN:          dump\n \
; RUN:          run\n \
; RUN:          dump\n \
; RUN:          break w _TMR0H\n	break w _TMR0L\n	break w _T0CONbits\n \
; RUN:          run\n	run\n	run\n \
; RUN:          quit\n' | %gpsim --cli --processor=p18f452 %t.cod | FileCheck %s

  radix dec

  include <ledmtx_config.h>
  include _P18FXXX_INC

  extern _ledmtx_config_width
  extern _ledmtx_config_height
  extern _ledmtx_config_stride
  extern _ledmtx_config_tmr0h
  extern _ledmtx_config_tmr0l
  extern _ledmtx_config_t0con
  extern _ledmtx_init

  global _ledmtx_framebuffer
  global _ledmtx_driver_init
  global _ledmtx_modules_init
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

LEDMTX_INIT_CLEAR	equ	0x01
LEDMTX_INIT_TMR0	equ	0x02

  code
_ledmtx_driver_init:
  return

_ledmtx_modules_init:
  return

;; void test_init_noflags(void)
_test_init_noflags:
  movlw		0xcc 		; t0con
  movwf		POSTDEC1, a
  movlw		0xbb 		; tmr0l
  movwf		POSTDEC1, a
  movlw		0xaa 		; tmr0h
  movwf		POSTDEC1, a
  movlw		7 		; height
  movwf		POSTDEC1, a
  movlw		32 		; width
  movwf		POSTDEC1, a
  movlw		0 		; flags
  call		_ledmtx_init
  movf		PREINC1, w, a
  movf		PREINC1, w, a
  movf		PREINC1, w, a
  movf		PREINC1, w, a
  movf		PREINC1, w, a
  return


;; void test_init_clear(void)
_test_init_clear:
  movlw		0xcc 		; t0con
  movwf		POSTDEC1, a
  movlw		0xbb 		; tmr0l
  movwf		POSTDEC1, a
  movlw		0xaa 		; tmr0h
  movwf		POSTDEC1, a
  movlw		7 		; height
  movwf		POSTDEC1, a
  movlw		32 		; width
  movwf		POSTDEC1, a
  movlw		LEDMTX_INIT_CLEAR 		; flags
  call		_ledmtx_init
  movf		PREINC1, w, a
  movf		PREINC1, w, a
  movf		PREINC1, w, a
  movf		PREINC1, w, a
  movf		PREINC1, w, a
  return


;; void test_init_noflags(void)
_test_init_tmr0:
  movlw		0xcc 		; t0con
  movwf		POSTDEC1, a
  movlw		0xbb 		; tmr0l
  movwf		POSTDEC1, a
  movlw		0xaa 		; tmr0h
  movwf		POSTDEC1, a
  movlw		7 		; height
  movwf		POSTDEC1, a
  movlw		32 		; width
  movwf		POSTDEC1, a
  movlw		LEDMTX_INIT_TMR0 		; flags
  call		_ledmtx_init
  movf		PREINC1, w, a
  movf		PREINC1, w, a
  movf		PREINC1, w, a
  movf		PREINC1, w, a
  movf		PREINC1, w, a
  return

;; void main(void)
_main:
; CHECK: _ledmtx_config_width = 0x20
; CHECK: _ledmtx_config_height = 0x7
; CHECK: _ledmtx_config_stride = 0x4
; CHECK: _ledmtx_config_tmr0h = 0xaa
; CHECK: _ledmtx_config_tmr0l = 0xbb
; CHECK: _ledmtx_config_t0con = 0xcc
; CHECK: 0400:  aa 55 aa 55 aa 55 aa 55 aa 55 aa 55 aa 55 aa 55
; CHECK: 0410:  aa 55 aa 55 aa 55 aa 55 aa 55 aa 55
  bsf		RCON, PD, a
  call		_test_init_noflags
  bcf		RCON, PD, a	; hits breakpoint set by `break w (rcon & 0x04) = 0x00`

; CHECK: 0400:  00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
; CHECK: 0410:  00 00 00 00 00 00 00 00 00 00 00 00
  bsf		RCON, PD, a
  call		_test_init_clear
  bcf		RCON, PD, a	; hits breakpoint set by `break w (rcon & 0x04) = 0x00`

; CHECK: Wrote: 0x00AA to _TMR0H
; CHECK: Wrote: 0x00BB to _TMR0L
; CHECK: Wrote: 0x00CC to _T0CONbits
  bsf		RCON, PD, a
  call		_test_init_tmr0
  bcf		RCON, PD, a	; hits breakpoint set by `break w (rcon & 0x04) = 0x00`

  return

  end
