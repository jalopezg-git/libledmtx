// COM: SDCC integration test that exercises support for stdio
// RUN: %gpasm %ASFLAGS -c -o %t.drv.o %ledmtx_src_dir/driver/libledmtx_r393c164.S
// RUN: %gpasm %ASFLAGS -c -o %t.fb_at_0x400.o fb_at_0x400.inc
// RUN: %sdcc -c %CFLAGS -o %t.o %s
// RUN: %sdcc %LDFLAGS -o %t.hex %t.o %t.drv.o %t.fb_at_0x400.o %ledmtx_src_dir/font/libledmtx_font5x7.o \
// RUN: 		%ledmtx_src_dir/libledmtx_stdio.o libdev18f452.lib
// RUN: echo -e 'break e _fini\n	\
// RUN:          run\n dump\n \
// RUN:          quit\n' | %gpsim --cli --processor=p18f452 %t.cod | FileCheck %s
#include <ledmtx_core.h>
#include <ledmtx_fontstd.h>
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

void fini(void)
{
}

void main(void)
{
  TRISA = 0xC0;
  ADCON1 = 0x0F;

  ledmtx_init(LEDMTX_INIT_CLEAR | LEDMTX_INIT_TMR0, 32, 7, 0xe9, 0xae, 0x88);
  ledmtx_setfont(ledmtx_font5x7);
  stdout = STREAM_USER;
  
  printf ("bye\rhello\n");
  // COM: * _ _ _ _ _ _ _ _ _ _ _ _ * * _ _ _ _ * * _ _ _ _ _ _ _ _ _ _ _ 
  // COM: * _ _ _ _ _ _ _ _ _ _ _ _ _ * _ _ _ _ _ * _ _ _ _ _ _ _ _ _ _ _ 
  // COM: * _ * * _ _ _ * * * _ _ _ _ * _ _ _ _ _ * _ _ _ _ * * * _ _ _ _ 
  // COM: * * _ _ * _ * _ _ _ * _ _ _ * _ _ _ _ _ * _ _ _ * _ _ _ * _ _ _ 
  // COM: * _ _ _ * _ * * * * * _ _ _ * _ _ _ _ _ * _ _ _ * _ _ _ * _ _ _ 
  // COM: * _ _ _ * _ * _ _ _ _ _ _ _ * _ _ _ _ _ * _ _ _ * _ _ _ * _ _ _ 
  // COM: * _ _ _ * _ _ * * * _ _ _ * * * _ _ _ * * * _ _ _ * * * _ _ _ _ 
  // CHECK: 0400:  80 06 18 00 80 02 08 00 b1 c2 08 70 ca 22 08 88
  // CHECK: 0410:  8b e2 08 88 8a 02 08 88 89 c7 1c 70
  fini();
}
