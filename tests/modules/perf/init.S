; COM: Unit test for the `ledmtx_perf_init()` routine
; RUN: %gpasm %ASFLAGS -c -o %t.o %s
; RUN: %gplink %GPLINKFLAGS -o %t.hex %t.o %ledmtx_src_dir/core/libledmtx_core.lib \
; RUN: 		 %ledmtx_src_dir/modules/perf/libledmtx_perf.lib crt0i.o libdev18f452.lib
; RUN: echo -e 'break w (rcon & 0x04) == 0x00\n	run\n \
; RUN:          _ledmtx_perf_tmr0\n \
; RUN:          _ledmtx_perf_intrtimelimit\n \
; RUN:          quit\n' | %gpsim --cli --processor=p18f452 %t.cod | FileCheck %s

  radix dec

  include <ledmtx_config.h>
  include _P18FXXX_INC

  extern _ledmtx_config_tmr0h
  extern _ledmtx_config_tmr0l
  extern _ledmtx_perf_tmr0
  extern _ledmtx_perf_intrtimelimit
  extern _ledmtx_perf_init

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
  movlw		0xAA
  movwf		_ledmtx_config_tmr0h, a
  movlw		0xBB
  movwf		_ledmtx_config_tmr0l, a

; COM: FIXME: cannot check _ledmtx_perf_tmr0+1 == 0xAA (missing symbol)
; CHECK: _ledmtx_perf_tmr0 = 0xbb
; COM: 0xFFFF - 0xAABB = 0x5544
; COM:                       ^^
; CHECK: _ledmtx_perf_intrtimelimit = 0x44
  call		_ledmtx_perf_init

  bcf		RCON, PD, a	; hits breakpoint set by `break w (rcon & 0x04) = 0x00`
  return

  end
