; COM: Unit test for the `ledmtx_scrollstr_init()` routine
; RUN: %gpasm %ASFLAGS -c -o %t.o %s
; RUN: %gplink %GPLINKFLAGS -o %t.hex %t.o %ledmtx_src_dir/core/libledmtx_core.lib \
; RUN: 		 %ledmtx_src_dir/modules/scrollstr/libledmtx_scrollstr.lib crt0i.o libdev18f452.lib
; RUN: echo -e 'break w (rcon & 0x04) == 0x00\n	run\n \
; RUN:          _ledmtx_scrollstr_bitmap\n \
; RUN:          quit\n' | %gpsim --cli --processor=p18f452 %t.cod | FileCheck %s

  radix dec

  include <ledmtx_config.h>
  include _P18FXXX_INC

  extern _ledmtx_scrollstr_bitmap
  extern _ledmtx_scrollstr_init

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
  movlw		0x9C
  movwf		_ledmtx_scrollstr_bitmap, a
; CHECK:  = 0x0
  call		_ledmtx_scrollstr_init

  bcf		RCON, PD, a	; hits breakpoint set by `break w (rcon & 0x04) = 0x00`
  return

  end
