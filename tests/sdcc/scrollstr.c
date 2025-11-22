// COM: SDCC integration test that exercises the scrollstr module
// RUN: %gpasm %ASFLAGS -c -o %t.drv.o %ledmtx_src_dir/driver/libledmtx_r393c164.S
// RUN: %gpasm %ASFLAGS -c -o %t.fb_at_0x400.o fb_at_0x400.inc
// RUN: %sdcc -c %CFLAGS -o %t.o %s
// RUN: %sdcc %LDFLAGS -o %t.hex %t.o %t.drv.o %t.fb_at_0x400.o %ledmtx_src_dir/font/libledmtx_font5x7.o \
// RUN: 		%ledmtx_src_dir/modules/scrollstr/libledmtx_scrollstr.lib libdev18f452.lib
// RUN: echo -e 'break e _ledmtx_scrollstr_step\n	\
// RUN:          run\n run\n run\n run\n \
// RUN:          run\n run\n run\n run\n \
// RUN:          run\n run\n run\n run\n \
// RUN:          run\n run\n run\n run\n \
// RUN:          run\n run\n run\n run\n \
// RUN:          run\n run\n run\n run\n \
// RUN:          run\n run\n run\n run\n \
// RUN:          run\n run\n run\n run\n \
// RUN:          run\n run\n run\n run\n \
// RUN:          run\n run\n run\n run\n \
// RUN:          dump\n \
// RUN:          quit\n' | %gpsim --cli --processor=p18f452 %t.cod | FileCheck %s
#include <ledmtx_scrollstr.h>
#include <ledmtx_core.h>
#include <ledmtx_fontstd.h>
#include <signal.h>

__CONFIG(__CONFIG1H, _HS_OSC_1H);
__CONFIG(__CONFIG2H, _WDT_OFF_2H);

LEDMTX_BEGIN_MODULES_INIT
LEDMTX_MODULE_INIT(scrollstr)
LEDMTX_END_MODULES_INIT

DEF_INTLOW(low_int)
DEF_HANDLER(SIG_TMR0, _tmr0_handler)
END_DEF

// The ISR for Timer 0.  In this example, in addition to the vertical refresh
// routine, `ledmtx_scrollstr_interrupt()` is called to perform the asynchronous
// text scroll actions.
SIGHANDLERNAKED(_tmr0_handler) {
  LEDMTX_BEGIN_ISR
  LEDMTX_BEGIN_R0
  ledmtx_scrollstr_interrupt();
  LEDMTX_END_R0
  LEDMTX_VERTREFRESH
  LEDMTX_END_ISR
}

char str[] = "scrollstr32x7: using r393c164 driver to refresh a 32x7 display";

void main(void) {
  struct ledmtx_scrollstr_desc s0;

  TRISA = 0xC0;
  ADCON1 = 0x0F;

  ledmtx_init(LEDMTX_INIT_CLEAR | LEDMTX_INIT_TMR0, 32, 7, 0xe9, 0xae, 0x88);
  ledmtx_setfont(ledmtx_font5x7);

  LEDMTX_SCROLLSTR_SET(s0, 2, 0, 0, 32, ledmtx_font_sz_h, (__data char *)str,
                       ledmtx_scrollstr_step, ledmtx_scrollstr_reset);
  ledmtx_scrollstr_start(&s0);

  // COM: Expected framebuffer state after 40 steps
  // COM: _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ * * _ _ _ _ * * _ _ _ _ _ _
  // COM: _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ * _ _ _ _ _ * _ _ _ _ _ _
  // COM: * * * _ _ * _ * * _ _ _ * * * _ _ _ _ * _ _ _ _ _ * _ _ _ _ * *
  // COM: _ _ _ _ _ * * _ _ * _ * _ _ _ * _ _ _ * _ _ _ _ _ * _ _ _ * _ _
  // COM: _ _ _ _ _ * _ _ _ _ _ * _ _ _ * _ _ _ * _ _ _ _ _ * _ _ _ _ * *
  // COM: _ _ _ * _ * _ _ _ _ _ * _ _ _ * _ _ _ * _ _ _ _ _ * _ _ _ _ _ _
  // COM: * * * _ _ * _ _ _ _ _ _ * * * _ _ _ * * * _ _ _ * * * _ _ * * *
  // CHECK: 0400:  00 00 30 c0 00 00 10 40 e5 8e 10 43 06 51 10 44
  // CHECK: 0410:  04 11 10 43 14 11 10 40 e4 0e 38 e7
}
