#include <ledmtx_core.h>
#include <ledmtx_font5x7.h>
#include <stdio.h>
#include <signal.h>

__CONFIG(__CONFIG1H, _OSC_HS_1H);
__CONFIG(__CONFIG2H, _WDT_OFF_2H);
__CONFIG(__CONFIG4L, _LVP_OFF_4L);

LEDMTX_BEGIN_MODULES_INIT
LEDMTX_END_MODULES_INIT

LEDMTX_FRAMEBUFFER_RES(28)

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
  TRISA = 0xe0;
  ADCON1 = 0x0f;
  
  ledmtx_init(LEDMTX_INIT_CLEAR | LEDMTX_INIT_TMR0, 32, 7, 0xe9, 0xae, 0x88);
  ledmtx_setfont(ledmtx_font5x7);
  stdout = STREAM_USER;
  
  printf ("hello\n");
}
