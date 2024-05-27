; COM: Unit test for the `ledmtx_scrollstr_reset()` routine
; RUN: %gpasm %ASFLAGS -c -o %t.o %s
; RUN: %gplink %GPLINKFLAGS -o %t.hex %t.o %ledmtx_src_dir/core/libledmtx_core.lib \
; RUN: 		 %ledmtx_src_dir/modules/scrollstr/libledmtx_scrollstr.lib crt0i.o libdev18f452.lib
; RUN: echo -e 'break w (rcon & 0x04) == 0x00\n	run\n \
; RUN:          r0x00\n \
; RUN:          r0x01\n \
; RUN:          r0x02\n \
; RUN:          r0x03\n \
; RUN:          quit\n' | %gpsim --cli --processor=p18f452 %t.cod | FileCheck %s

  radix dec

  include <ledmtx_config.h>
  include _P18FXXX_INC

  extern _ledmtx_scrollstr_reset

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

.registers	udata_ovr	0x0000
r0x00	res	1
r0x01	res	1
r0x02	res	1
r0x03	res	1

  code
_test_stub_step:
  return
_test_stub_stop:
  return

;; void main(void)
_main:
; COM: Clobber the ledmtx_scrollstr_desc members that `ledmtx_scrollstr_reset()`
; COM: should restore.
  movlw		0x9C
  movwf		r0x00, a
  lfsr		0, _scrollstr_desc_1
  movlw		0
  movff		r0x00, PLUSW0	; counter
  movlw		10
  movff		r0x00, PLUSW0	; i
  movlw		11
  movff		r0x00, PLUSW0	; charoff
  movlw		12
  movff		r0x00, PLUSW0	; mask

  movlw		high(_scrollstr_desc_1)
  movwf		POSTDEC1, a
  movlw		low(_scrollstr_desc_1)
  movwf		POSTDEC1, a
  call		_ledmtx_scrollstr_reset
  movf		PREINC1, w, a
  movf		PREINC1, w, a

; CHECK: r0x00 = 0x2
; CHECK: r0x01 = 0x0
; CHECK: r0x02 = 0x1
; CHECK: r0x03 = 0x80
  lfsr		0, _scrollstr_desc_1
  movlw		0
  movff		PLUSW0, r0x00	; counter
  movlw		10
  movff		PLUSW0, r0x01	; i
  movlw		11
  movff		PLUSW0, r0x02	; charoff
  movlw		12
  movff		PLUSW0, r0x03	; mask

  bcf		RCON, PD, a	; hits breakpoint set by `break w (rcon & 0x04) = 0x00`
  return

  end
