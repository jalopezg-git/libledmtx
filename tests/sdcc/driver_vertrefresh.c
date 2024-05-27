// COM: SDCC integration test checking that ISR invokes `_ledmtx_driver_vertrefresh`
// RUN: %gpasm %ASFLAGS -c -o %t.drv.o %ledmtx_src_dir/driver/libledmtx_r393c164.S
// RUN: %gpasm %ASFLAGS -c -o %t.fb_at_0x400.o fb_at_0x400.inc
// RUN: %sdcc -c %CFLAGS -o %t.o %s
// RUN: %sdcc %LDFLAGS -o %t.hex %t.o %t.drv.o %t.fb_at_0x400.o %ledmtx_src_dir/font/libledmtx_font5x7.o libdev18f452.lib
// RUN: echo -e 'break e _ledmtx_driver_vertrefresh\n \
// RUN:          run\n	run\n \
// RUN:          quit\n' | %gpsim --cli --processor=p18f452 %t.cod | FileCheck %s
#include <ledmtx_core.h>
#include <ledmtx_font5x7.h>
#include <stdio.h>
#include <signal.h>

__CONFIG(__CONFIG1H, _HS_OSC_1H);
__CONFIG(__CONFIG2H, _WDT_OFF_2H);

LEDMTX_BEGIN_MODULES_INIT
LEDMTX_END_MODULES_INIT

DEF_INTLOW(low_int)
DEF_HANDLER(SIG_TMR0, _tmr0_handler)
END_DEF

SIGHANDLERNAKED(_tmr0_handler)
{
  LEDMTX_BEGIN_ISR
    LEDMTX_VERTREFRESH
  LEDMTX_END_ISR
}

void main(void)
{
  TRISA = 0xC0;
  ADCON1 = 0x0F;

  ledmtx_init(LEDMTX_INIT_CLEAR | LEDMTX_INIT_TMR0, 32, 7, 0xe9, 0xae, 0x88);

  // CHECK:   BREAK:
  // CHECK-NEXT:  call
  // CHECK:   BREAK:
  // CHECK-NEXT:  call
}
