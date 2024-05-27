; COM: Unit test for the `ledmtx_scrollstr_reset()` routine
; RUN: %gpasm %ASFLAGS -c -o %t.o %s
; RUN: %gplink %GPLINKFLAGS -o %t.hex %t.o %ledmtx_src_dir/core/libledmtx_core.lib \
; RUN: 		 %ledmtx_src_dir/modules/scrollstr/libledmtx_scrollstr.lib crt0i.o libdev18f452.lib
; RUN: echo -e 'break w (rcon & 0x04) == 0x00\n \
; RUN:          run\n	_ledmtx_scrollstr_bitmap\n	r0x00\n	r0x01\n	r0x02\n	r0x03\n	_PRODH\n	_PRODL\n	\
; RUN:          run\n	_ledmtx_scrollstr_bitmap\n \
; RUN:          quit\n' | %gpsim --cli --processor=p18f452 %t.cod | FileCheck %s

  radix dec

  include <ledmtx_config.h>
  include _P18FXXX_INC

  extern _ledmtx_scrollstr_bitmap
  extern _ledmtx_scrollstr_vec
  extern _ledmtx_scrollstr_start
  extern _ledmtx_scrollstr_stop

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

;; void test_start(void)
_test_start:
  movlw		high(_scrollstr_desc_1)
  movwf		POSTDEC1, a
  movlw		low(_scrollstr_desc_1)
  movwf		POSTDEC1, a
  call		_ledmtx_scrollstr_start
  movf		PREINC1, w, a
  movf		PREINC1, w, a

  movlw		high(_scrollstr_desc_2)
  movwf		POSTDEC1, a
  movlw		low(_scrollstr_desc_2)
  movwf		POSTDEC1, a
  call		_ledmtx_scrollstr_start
  movf		PREINC1, w, a
  movf		PREINC1, w, a
  return

;; void test_stop(void)
_test_stop:
  movlw		high(_scrollstr_desc_1)
  movwf		POSTDEC1, a
  movlw		low(_scrollstr_desc_1)
  movwf		POSTDEC1, a
  call		_ledmtx_scrollstr_stop
  movf		PREINC1, w, a
  movf		PREINC1, w, a
  return

;; void main(void)
_main:
  clrf		_ledmtx_scrollstr_bitmap, a

; CHECK: _ledmtx_scrollstr_bitmap = 0x3
; CHECK: r0x00 = 0x0
; CHECK: r0x01 = 0x0
; CHECK: r0x02 = 0x0
; CHECK: r0x03 = 0x0
; CHECK: _PRODH = 0x1
; CHECK: _PRODL = 0x2
  bsf		RCON, PD, a
  call		_test_start
; COM: Check that `ledmtx_scrollstr_vec[]` contains the expected data.  The
; COM: actual address of `_scrollstr_desc_(1|2)` depends on linker; XOR its value
; COM: with the relocated address so that it gives us 0x0000.
  lfsr		0, _ledmtx_scrollstr_vec
  movlw		low(_scrollstr_desc_1)
  xorwf		POSTINC0, w
  movwf		r0x00, a
  movlw		high(_scrollstr_desc_1)
  xorwf		POSTINC0, w
  movwf		r0x01, a
  movlw		low(_scrollstr_desc_2)
  xorwf		POSTINC0, w
  movwf		r0x02, a
  movlw		high(_scrollstr_desc_2)
  xorwf		POSTINC0, w
  movwf		r0x03, a
; COM: Check the `bitmap_mask` member on both descriptors
  lfsr		0, _scrollstr_desc_1
  movlw		16
  movff		PLUSW0,	PRODH	; bitmap_mask
  lfsr		0, _scrollstr_desc_2
  movlw		16
  movff		PLUSW0,	PRODL	; bitmap_mask
  bcf		RCON, PD, a	; hits breakpoint set by `break w (rcon & 0x04) = 0x00`

; CHECK: _ledmtx_scrollstr_bitmap = 0x2
  bsf		RCON, PD, a
  call		_test_stop
  bcf		RCON, PD, a	; hits breakpoint set by `break w (rcon & 0x04) = 0x00`
  return

  end
