; COM: Unit test for the r393c164 driver
; RUN: %gpasm %ASFLAGS -c -o %t.drv.o %ledmtx_src_dir/driver/libledmtx_r393c164.S
; RUN: %gpasm %ASFLAGS -c -o %t.o %s
; RUN: %gplink %GPLINKFLAGS -o %t.hex %t.o %t.drv.o %ledmtx_src_dir/core/libledmtx_core.lib \
; RUN: 		crt0i.o libdev18f452.lib
; RUN: echo -e 'break w (rcon & 0x04) == 0x00\n \
; RUN:          run\n trace 512\n \
; RUN:          run\n trace 512\n \
; RUN:          run\n trace 512\n \
; RUN:          run\n trace 512\n \
; RUN:          run\n trace 512\n \
; RUN:          run\n trace 512\n \
; RUN:          run\n trace 512\n \
; RUN:          run\n trace 512\n \
; RUN:          quit\n' | %gpsim --cli --processor=p18f452 %t.hex | FileCheck %s

;; COM: gpsim's trace circular buffer has a hardcoded capacity of 4096 entries.
;; COM: Taking into account that it traces _everything_ incl. register reads
;; COM: / writes, it may overflows before execution ends.  Thus, trigger a
;; COM: breakpoint and dump trace after each `_ledmtx_driver_vertrefresh` call.

  radix dec

  include <ledmtx_config.h>
  include _P18FXXX_INC
  include "../test_case_prologue.inc"

  extern _ledmtx_driver_init
  extern _ledmtx_driver_vertrefresh

  global _ledmtx_framebuffer
  global _main
  global _stack_end

  udata 0x1ff
_stack_end	res	1

.test_idata  idata 0x400
; framebuffer size is 32x7 (i.e., stride = 4)
_ledmtx_framebuffer	db 0x00, 0x11, 0x22, 0x33, 0x44, 0x55, 0x66, 0x77
			db 0x00, 0x11, 0x22, 0x33, 0x44, 0x55, 0x66, 0x77
			db 0x00, 0x11, 0x22, 0x33, 0x44, 0x55, 0x66, 0x77
			db 0x00, 0x11, 0x22, 0x33

  code
;; void main(void)
_main:
  TEST_CASE_PROLOGUE		32, 7

  movlw		0xC0
  movwf		TRISA, a
  movlw		0X0F
  movwf		ADCON1, a

  call		_ledmtx_driver_init

;; COM: Check output on I/O pins for each invoke to `_ledmtx_driver_vertrefresh`
;; COM: during a complete refresh cycle.

; CHECK:   Wrote: 0x00{{.}}2 to porta(0x0F80)
; CHECK:   Wrote: 0x001{{.}} to porta(0x0F80)
; CHECK:   Wrote: 0x001{{.}} to porta(0x0F80)
; CHECK:   Wrote: 0x003{{.}} to porta(0x0F80)
; CHECK:   Wrote: 0x003{{.}} to porta(0x0F80)
; CHECK:   Wrote: 0x001{{.}} to porta(0x0F80)
; CHECK:   Wrote: 0x001{{.}} to porta(0x0F80)
; CHECK:   Wrote: 0x003{{.}} to porta(0x0F80)
; CHECK:   Wrote: 0x003{{.}} to porta(0x0F80)
; CHECK:   Wrote: 0x003{{.}} to porta(0x0F80)
; CHECK:   Wrote: 0x001{{.}} to porta(0x0F80)
; CHECK:   Wrote: 0x003{{.}} to porta(0x0F80)
; CHECK:   Wrote: 0x003{{.}} to porta(0x0F80)
; CHECK:   Wrote: 0x003{{.}} to porta(0x0F80)
; CHECK:   Wrote: 0x001{{.}} to porta(0x0F80)
; CHECK:   Wrote: 0x003{{.}} to porta(0x0F80)
; CHECK:   Wrote: 0x003{{.}} to porta(0x0F80)
; CHECK:   Wrote: 0x001{{.}} to porta(0x0F80)
; CHECK:   Wrote: 0x003{{.}} to porta(0x0F80)
; CHECK:   Wrote: 0x003{{.}} to porta(0x0F80)
; CHECK:   Wrote: 0x003{{.}} to porta(0x0F80)
; CHECK:   Wrote: 0x001{{.}} to porta(0x0F80)
; CHECK:   Wrote: 0x003{{.}} to porta(0x0F80)
; CHECK:   Wrote: 0x003{{.}} to porta(0x0F80)
; CHECK:   Wrote: 0x003{{.}} to porta(0x0F80)
; CHECK:   Wrote: 0x003{{.}} to porta(0x0F80)
; CHECK:   Wrote: 0x003{{.}} to porta(0x0F80)
; CHECK:   Wrote: 0x003{{.}} to porta(0x0F80)
; CHECK:   Wrote: 0x003{{.}} to porta(0x0F80)
; CHECK:   Wrote: 0x003{{.}} to porta(0x0F80)
; CHECK:   Wrote: 0x003{{.}} to porta(0x0F80)
; CHECK:   Wrote: 0x003{{.}} to porta(0x0F80)
; CHECK:   Wrote: 0x003{{.}} to porta(0x0F80)
  call		_ledmtx_driver_vertrefresh
  bcf		RCON, PD, a	; hits breakpoint set by `break w (rcon & 0x04) = 0x00`

; CHECK:   Wrote: 0x00{{.}}1 to porta(0x0F80)
; CHECK:   Wrote: 0x001{{.}} to porta(0x0F80)
; CHECK:   Wrote: 0x001{{.}} to porta(0x0F80)
; CHECK:   Wrote: 0x001{{.}} to porta(0x0F80)
; CHECK:   Wrote: 0x003{{.}} to porta(0x0F80)
; CHECK:   Wrote: 0x001{{.}} to porta(0x0F80)
; CHECK:   Wrote: 0x001{{.}} to porta(0x0F80)
; CHECK:   Wrote: 0x001{{.}} to porta(0x0F80)
; CHECK:   Wrote: 0x003{{.}} to porta(0x0F80)
; CHECK:   Wrote: 0x003{{.}} to porta(0x0F80)
; CHECK:   Wrote: 0x001{{.}} to porta(0x0F80)
; CHECK:   Wrote: 0x001{{.}} to porta(0x0F80)
; CHECK:   Wrote: 0x003{{.}} to porta(0x0F80)
; CHECK:   Wrote: 0x003{{.}} to porta(0x0F80)
; CHECK:   Wrote: 0x001{{.}} to porta(0x0F80)
; CHECK:   Wrote: 0x001{{.}} to porta(0x0F80)
; CHECK:   Wrote: 0x003{{.}} to porta(0x0F80)
; CHECK:   Wrote: 0x001{{.}} to porta(0x0F80)
; CHECK:   Wrote: 0x003{{.}} to porta(0x0F80)
; CHECK:   Wrote: 0x001{{.}} to porta(0x0F80)
; CHECK:   Wrote: 0x003{{.}} to porta(0x0F80)
; CHECK:   Wrote: 0x001{{.}} to porta(0x0F80)
; CHECK:   Wrote: 0x003{{.}} to porta(0x0F80)
; CHECK:   Wrote: 0x001{{.}} to porta(0x0F80)
; CHECK:   Wrote: 0x003{{.}} to porta(0x0F80)
; CHECK:   Wrote: 0x003{{.}} to porta(0x0F80)
; CHECK:   Wrote: 0x003{{.}} to porta(0x0F80)
; CHECK:   Wrote: 0x001{{.}} to porta(0x0F80)
; CHECK:   Wrote: 0x003{{.}} to porta(0x0F80)
; CHECK:   Wrote: 0x003{{.}} to porta(0x0F80)
; CHECK:   Wrote: 0x003{{.}} to porta(0x0F80)
; CHECK:   Wrote: 0x001{{.}} to porta(0x0F80)
; CHECK:   Wrote: 0x003{{.}} to porta(0x0F80)
  call		_ledmtx_driver_vertrefresh
  bcf		RCON, PD, a	; hits breakpoint set by `break w (rcon & 0x04) = 0x00`

; CHECK:   Wrote: 0x00{{.}}1 to porta(0x0F80)
; CHECK:   Wrote: 0x001{{.}} to porta(0x0F80)
; CHECK:   Wrote: 0x001{{.}} to porta(0x0F80)
; CHECK:   Wrote: 0x003{{.}} to porta(0x0F80)
; CHECK:   Wrote: 0x003{{.}} to porta(0x0F80)
; CHECK:   Wrote: 0x001{{.}} to porta(0x0F80)
; CHECK:   Wrote: 0x001{{.}} to porta(0x0F80)
; CHECK:   Wrote: 0x003{{.}} to porta(0x0F80)
; CHECK:   Wrote: 0x003{{.}} to porta(0x0F80)
; CHECK:   Wrote: 0x003{{.}} to porta(0x0F80)
; CHECK:   Wrote: 0x001{{.}} to porta(0x0F80)
; CHECK:   Wrote: 0x003{{.}} to porta(0x0F80)
; CHECK:   Wrote: 0x003{{.}} to porta(0x0F80)
; CHECK:   Wrote: 0x003{{.}} to porta(0x0F80)
; CHECK:   Wrote: 0x001{{.}} to porta(0x0F80)
; CHECK:   Wrote: 0x003{{.}} to porta(0x0F80)
; CHECK:   Wrote: 0x003{{.}} to porta(0x0F80)
; CHECK:   Wrote: 0x001{{.}} to porta(0x0F80)
; CHECK:   Wrote: 0x003{{.}} to porta(0x0F80)
; CHECK:   Wrote: 0x003{{.}} to porta(0x0F80)
; CHECK:   Wrote: 0x003{{.}} to porta(0x0F80)
; CHECK:   Wrote: 0x001{{.}} to porta(0x0F80)
; CHECK:   Wrote: 0x003{{.}} to porta(0x0F80)
; CHECK:   Wrote: 0x003{{.}} to porta(0x0F80)
; CHECK:   Wrote: 0x003{{.}} to porta(0x0F80)
; CHECK:   Wrote: 0x003{{.}} to porta(0x0F80)
; CHECK:   Wrote: 0x003{{.}} to porta(0x0F80)
; CHECK:   Wrote: 0x003{{.}} to porta(0x0F80)
; CHECK:   Wrote: 0x003{{.}} to porta(0x0F80)
; CHECK:   Wrote: 0x003{{.}} to porta(0x0F80)
; CHECK:   Wrote: 0x003{{.}} to porta(0x0F80)
; CHECK:   Wrote: 0x003{{.}} to porta(0x0F80)
; CHECK:   Wrote: 0x003{{.}} to porta(0x0F80)
  call		_ledmtx_driver_vertrefresh
  bcf		RCON, PD, a	; hits breakpoint set by `break w (rcon & 0x04) = 0x00`

; CHECK:   Wrote: 0x00{{.}}1 to porta(0x0F80)
; CHECK:   Wrote: 0x001{{.}} to porta(0x0F80)
; CHECK:   Wrote: 0x001{{.}} to porta(0x0F80)
; CHECK:   Wrote: 0x001{{.}} to porta(0x0F80)
; CHECK:   Wrote: 0x003{{.}} to porta(0x0F80)
; CHECK:   Wrote: 0x001{{.}} to porta(0x0F80)
; CHECK:   Wrote: 0x001{{.}} to porta(0x0F80)
; CHECK:   Wrote: 0x001{{.}} to porta(0x0F80)
; CHECK:   Wrote: 0x003{{.}} to porta(0x0F80)
; CHECK:   Wrote: 0x003{{.}} to porta(0x0F80)
; CHECK:   Wrote: 0x001{{.}} to porta(0x0F80)
; CHECK:   Wrote: 0x001{{.}} to porta(0x0F80)
; CHECK:   Wrote: 0x003{{.}} to porta(0x0F80)
; CHECK:   Wrote: 0x003{{.}} to porta(0x0F80)
; CHECK:   Wrote: 0x001{{.}} to porta(0x0F80)
; CHECK:   Wrote: 0x001{{.}} to porta(0x0F80)
; CHECK:   Wrote: 0x003{{.}} to porta(0x0F80)
; CHECK:   Wrote: 0x001{{.}} to porta(0x0F80)
; CHECK:   Wrote: 0x003{{.}} to porta(0x0F80)
; CHECK:   Wrote: 0x001{{.}} to porta(0x0F80)
; CHECK:   Wrote: 0x003{{.}} to porta(0x0F80)
; CHECK:   Wrote: 0x001{{.}} to porta(0x0F80)
; CHECK:   Wrote: 0x003{{.}} to porta(0x0F80)
; CHECK:   Wrote: 0x001{{.}} to porta(0x0F80)
; CHECK:   Wrote: 0x003{{.}} to porta(0x0F80)
; CHECK:   Wrote: 0x003{{.}} to porta(0x0F80)
; CHECK:   Wrote: 0x003{{.}} to porta(0x0F80)
; CHECK:   Wrote: 0x001{{.}} to porta(0x0F80)
; CHECK:   Wrote: 0x003{{.}} to porta(0x0F80)
; CHECK:   Wrote: 0x003{{.}} to porta(0x0F80)
; CHECK:   Wrote: 0x003{{.}} to porta(0x0F80)
; CHECK:   Wrote: 0x001{{.}} to porta(0x0F80)
; CHECK:   Wrote: 0x003{{.}} to porta(0x0F80)
  call		_ledmtx_driver_vertrefresh
  bcf		RCON, PD, a	; hits breakpoint set by `break w (rcon & 0x04) = 0x00`

; CHECK:   Wrote: 0x00{{.}}1 to porta(0x0F80)
; CHECK:   Wrote: 0x001{{.}} to porta(0x0F80)
; CHECK:   Wrote: 0x001{{.}} to porta(0x0F80)
; CHECK:   Wrote: 0x003{{.}} to porta(0x0F80)
; CHECK:   Wrote: 0x003{{.}} to porta(0x0F80)
; CHECK:   Wrote: 0x001{{.}} to porta(0x0F80)
; CHECK:   Wrote: 0x001{{.}} to porta(0x0F80)
; CHECK:   Wrote: 0x003{{.}} to porta(0x0F80)
; CHECK:   Wrote: 0x003{{.}} to porta(0x0F80)
; CHECK:   Wrote: 0x003{{.}} to porta(0x0F80)
; CHECK:   Wrote: 0x001{{.}} to porta(0x0F80)
; CHECK:   Wrote: 0x003{{.}} to porta(0x0F80)
; CHECK:   Wrote: 0x003{{.}} to porta(0x0F80)
; CHECK:   Wrote: 0x003{{.}} to porta(0x0F80)
; CHECK:   Wrote: 0x001{{.}} to porta(0x0F80)
; CHECK:   Wrote: 0x003{{.}} to porta(0x0F80)
; CHECK:   Wrote: 0x003{{.}} to porta(0x0F80)
; CHECK:   Wrote: 0x001{{.}} to porta(0x0F80)
; CHECK:   Wrote: 0x003{{.}} to porta(0x0F80)
; CHECK:   Wrote: 0x003{{.}} to porta(0x0F80)
; CHECK:   Wrote: 0x003{{.}} to porta(0x0F80)
; CHECK:   Wrote: 0x001{{.}} to porta(0x0F80)
; CHECK:   Wrote: 0x003{{.}} to porta(0x0F80)
; CHECK:   Wrote: 0x003{{.}} to porta(0x0F80)
; CHECK:   Wrote: 0x003{{.}} to porta(0x0F80)
; CHECK:   Wrote: 0x003{{.}} to porta(0x0F80)
; CHECK:   Wrote: 0x003{{.}} to porta(0x0F80)
; CHECK:   Wrote: 0x003{{.}} to porta(0x0F80)
; CHECK:   Wrote: 0x003{{.}} to porta(0x0F80)
; CHECK:   Wrote: 0x003{{.}} to porta(0x0F80)
; CHECK:   Wrote: 0x003{{.}} to porta(0x0F80)
; CHECK:   Wrote: 0x003{{.}} to porta(0x0F80)
; CHECK:   Wrote: 0x003{{.}} to porta(0x0F80)
  call		_ledmtx_driver_vertrefresh
  bcf		RCON, PD, a	; hits breakpoint set by `break w (rcon & 0x04) = 0x00`

; CHECK:   Wrote: 0x00{{.}}1 to porta(0x0F80)
; CHECK:   Wrote: 0x001{{.}} to porta(0x0F80)
; CHECK:   Wrote: 0x001{{.}} to porta(0x0F80)
; CHECK:   Wrote: 0x001{{.}} to porta(0x0F80)
; CHECK:   Wrote: 0x003{{.}} to porta(0x0F80)
; CHECK:   Wrote: 0x001{{.}} to porta(0x0F80)
; CHECK:   Wrote: 0x001{{.}} to porta(0x0F80)
; CHECK:   Wrote: 0x001{{.}} to porta(0x0F80)
; CHECK:   Wrote: 0x003{{.}} to porta(0x0F80)
; CHECK:   Wrote: 0x003{{.}} to porta(0x0F80)
; CHECK:   Wrote: 0x001{{.}} to porta(0x0F80)
; CHECK:   Wrote: 0x001{{.}} to porta(0x0F80)
; CHECK:   Wrote: 0x003{{.}} to porta(0x0F80)
; CHECK:   Wrote: 0x003{{.}} to porta(0x0F80)
; CHECK:   Wrote: 0x001{{.}} to porta(0x0F80)
; CHECK:   Wrote: 0x001{{.}} to porta(0x0F80)
; CHECK:   Wrote: 0x003{{.}} to porta(0x0F80)
; CHECK:   Wrote: 0x001{{.}} to porta(0x0F80)
; CHECK:   Wrote: 0x003{{.}} to porta(0x0F80)
; CHECK:   Wrote: 0x001{{.}} to porta(0x0F80)
; CHECK:   Wrote: 0x003{{.}} to porta(0x0F80)
; CHECK:   Wrote: 0x001{{.}} to porta(0x0F80)
; CHECK:   Wrote: 0x003{{.}} to porta(0x0F80)
; CHECK:   Wrote: 0x001{{.}} to porta(0x0F80)
; CHECK:   Wrote: 0x003{{.}} to porta(0x0F80)
; CHECK:   Wrote: 0x003{{.}} to porta(0x0F80)
; CHECK:   Wrote: 0x003{{.}} to porta(0x0F80)
; CHECK:   Wrote: 0x001{{.}} to porta(0x0F80)
; CHECK:   Wrote: 0x003{{.}} to porta(0x0F80)
; CHECK:   Wrote: 0x003{{.}} to porta(0x0F80)
; CHECK:   Wrote: 0x003{{.}} to porta(0x0F80)
; CHECK:   Wrote: 0x001{{.}} to porta(0x0F80)
; CHECK:   Wrote: 0x003{{.}} to porta(0x0F80)
  call		_ledmtx_driver_vertrefresh
  bcf		RCON, PD, a	; hits breakpoint set by `break w (rcon & 0x04) = 0x00`

; CHECK:   Wrote: 0x00{{.}}1 to porta(0x0F80)
; CHECK:   Wrote: 0x001{{.}} to porta(0x0F80)
; CHECK:   Wrote: 0x001{{.}} to porta(0x0F80)
; CHECK:   Wrote: 0x003{{.}} to porta(0x0F80)
; CHECK:   Wrote: 0x003{{.}} to porta(0x0F80)
; CHECK:   Wrote: 0x001{{.}} to porta(0x0F80)
; CHECK:   Wrote: 0x001{{.}} to porta(0x0F80)
; CHECK:   Wrote: 0x003{{.}} to porta(0x0F80)
; CHECK:   Wrote: 0x003{{.}} to porta(0x0F80)
; CHECK:   Wrote: 0x003{{.}} to porta(0x0F80)
; CHECK:   Wrote: 0x001{{.}} to porta(0x0F80)
; CHECK:   Wrote: 0x003{{.}} to porta(0x0F80)
; CHECK:   Wrote: 0x003{{.}} to porta(0x0F80)
; CHECK:   Wrote: 0x003{{.}} to porta(0x0F80)
; CHECK:   Wrote: 0x001{{.}} to porta(0x0F80)
; CHECK:   Wrote: 0x003{{.}} to porta(0x0F80)
; CHECK:   Wrote: 0x003{{.}} to porta(0x0F80)
; CHECK:   Wrote: 0x001{{.}} to porta(0x0F80)
; CHECK:   Wrote: 0x003{{.}} to porta(0x0F80)
; CHECK:   Wrote: 0x003{{.}} to porta(0x0F80)
; CHECK:   Wrote: 0x003{{.}} to porta(0x0F80)
; CHECK:   Wrote: 0x001{{.}} to porta(0x0F80)
; CHECK:   Wrote: 0x003{{.}} to porta(0x0F80)
; CHECK:   Wrote: 0x003{{.}} to porta(0x0F80)
; CHECK:   Wrote: 0x003{{.}} to porta(0x0F80)
; CHECK:   Wrote: 0x003{{.}} to porta(0x0F80)
; CHECK:   Wrote: 0x003{{.}} to porta(0x0F80)
; CHECK:   Wrote: 0x003{{.}} to porta(0x0F80)
; CHECK:   Wrote: 0x003{{.}} to porta(0x0F80)
; CHECK:   Wrote: 0x003{{.}} to porta(0x0F80)
; CHECK:   Wrote: 0x003{{.}} to porta(0x0F80)
; CHECK:   Wrote: 0x003{{.}} to porta(0x0F80)
; CHECK:   Wrote: 0x003{{.}} to porta(0x0F80)
  call		_ledmtx_driver_vertrefresh
  bcf		RCON, PD, a	; hits breakpoint set by `break w (rcon & 0x04) = 0x00`

; CHECK:   Wrote: 0x00{{.}}2 to porta(0x0F80)
; CHECK:   Wrote: 0x001{{.}} to porta(0x0F80)
; CHECK:   Wrote: 0x001{{.}} to porta(0x0F80)
; CHECK:   Wrote: 0x003{{.}} to porta(0x0F80)
; CHECK:   Wrote: 0x003{{.}} to porta(0x0F80)
; CHECK:   Wrote: 0x001{{.}} to porta(0x0F80)
; CHECK:   Wrote: 0x001{{.}} to porta(0x0F80)
; CHECK:   Wrote: 0x003{{.}} to porta(0x0F80)
; CHECK:   Wrote: 0x003{{.}} to porta(0x0F80)
; CHECK:   Wrote: 0x003{{.}} to porta(0x0F80)
; CHECK:   Wrote: 0x001{{.}} to porta(0x0F80)
; CHECK:   Wrote: 0x003{{.}} to porta(0x0F80)
; CHECK:   Wrote: 0x003{{.}} to porta(0x0F80)
; CHECK:   Wrote: 0x003{{.}} to porta(0x0F80)
; CHECK:   Wrote: 0x001{{.}} to porta(0x0F80)
; CHECK:   Wrote: 0x003{{.}} to porta(0x0F80)
; CHECK:   Wrote: 0x003{{.}} to porta(0x0F80)
; CHECK:   Wrote: 0x001{{.}} to porta(0x0F80)
; CHECK:   Wrote: 0x003{{.}} to porta(0x0F80)
; CHECK:   Wrote: 0x003{{.}} to porta(0x0F80)
; CHECK:   Wrote: 0x003{{.}} to porta(0x0F80)
; CHECK:   Wrote: 0x001{{.}} to porta(0x0F80)
; CHECK:   Wrote: 0x003{{.}} to porta(0x0F80)
; CHECK:   Wrote: 0x003{{.}} to porta(0x0F80)
; CHECK:   Wrote: 0x003{{.}} to porta(0x0F80)
; CHECK:   Wrote: 0x003{{.}} to porta(0x0F80)
; CHECK:   Wrote: 0x003{{.}} to porta(0x0F80)
; CHECK:   Wrote: 0x003{{.}} to porta(0x0F80)
; CHECK:   Wrote: 0x003{{.}} to porta(0x0F80)
; CHECK:   Wrote: 0x003{{.}} to porta(0x0F80)
; CHECK:   Wrote: 0x003{{.}} to porta(0x0F80)
; CHECK:   Wrote: 0x003{{.}} to porta(0x0F80)
; CHECK:   Wrote: 0x003{{.}} to porta(0x0F80)
  call		_ledmtx_driver_vertrefresh
  bcf		RCON, PD, a	; hits breakpoint set by `break w (rcon & 0x04) = 0x00`

  return

  end
