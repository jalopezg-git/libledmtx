; COM: Unit test for the `ledmtx_perf_getintrtime()` routine
; RUN: %gpasm %ASFLAGS -c -o %t.o %s
; RUN: %gplink %GPLINKFLAGS -o %t.hex %t.o %ledmtx_src_dir/core/libledmtx_core.lib \
; RUN: 		 %ledmtx_src_dir/modules/perf/libledmtx_perf.lib crt0i.o libdev18f452.lib
; RUN: echo -e 'break w (rcon & 0x04) == 0x00\n	run\n \
; RUN:          _PRODL\n \
; RUN:          _WREG\n \
; RUN:          quit\n' | %gpsim --cli --processor=p18f452 %t.cod | FileCheck %s

  radix dec

  include <ledmtx_config.h>
  include _P18FXXX_INC
  include "../../test_case_prologue.inc"

  extern _ledmtx_perf_tmr0
  extern _ledmtx_perf_getintrtime

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
  TEST_CASE_PROLOGUE		32, 7

  banksel	_ledmtx_perf_tmr0
  movlw		0xDD
  movwf		_ledmtx_perf_tmr0+1
  movlw		0xCC
  movwf		_ledmtx_perf_tmr0+0

; COM: _PRODL:_WREG = 0xDDCC - 0xAABB
; CHECK: _PRODL = 0x33
; CHECK: _WREG = 0x11
  call		_ledmtx_perf_getintrtime

  bcf		RCON, PD, a	; hits breakpoint set by `break w (rcon & 0x04) = 0x00`
  return

  end
