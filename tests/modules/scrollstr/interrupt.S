; COM: Unit test for the `ledmtx_scrollstr_interrupt()` routine
; RUN: %gpasm %ASFLAGS -c -o %t.o %s
; RUN: %gplink %GPLINKFLAGS -o %t.hex %t.o %ledmtx_src_dir/core/libledmtx_core.lib \
; RUN: 		 %ledmtx_src_dir/modules/scrollstr/libledmtx_scrollstr.lib crt0i.o libdev18f452.lib
; RUN: echo -e 'break e _test_stub_step\n \
; RUN:          run\n \
; RUN:          run\n \
; RUN:          quit\n' | %gpsim --cli --processor=p18f452 %t.cod | FileCheck %s

  radix dec

  include <ledmtx_config.h>
  include _P18FXXX_INC

  extern _ledmtx_scrollstr_bitmap
  extern _ledmtx_scrollstr_vec
  extern _ledmtx_scrollstr_interrupt

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

  code
_test_stub_step:
; COM: TODO: validate that `test_stub_step()` is called with the correct
; COM: argument each time.
  return
_test_stub_stop:
  return

;; void main(void)
_main:
  movlw		0x05
  movwf		_ledmtx_scrollstr_bitmap, a
  lfsr		0, _ledmtx_scrollstr_vec

  movlw		low(_scrollstr_desc_1)
  movwf		POSTINC0, a
  movlw		high(_scrollstr_desc_1)
  movwf		POSTINC0, a

  movlw		0
  movwf		POSTINC0, a
  movwf		POSTINC0, a

  movlw		low(_scrollstr_desc_2)
  movwf		POSTINC0, a
  movlw		high(_scrollstr_desc_2)
  movwf		POSTINC0, a

  call		_ledmtx_scrollstr_interrupt
; COM: Check that we hit `_test_stub_step` twice on the second call, i.e. one
; COM: for each registered descriptor
; CHECK:   BREAK:
; CHECK:   BREAK:
  call		_ledmtx_scrollstr_interrupt
  return

  end
