#include <ledmtx_scrollstr.h>
#include <ledmtx_core.h>
#include <ledmtx_font5x7.h>
#include <signal.h>

__CONFIG(__CONFIG1H, _HS_OSC_1H);
__CONFIG(__CONFIG2H, _WDT_OFF_2H);
__CONFIG(__CONFIG4L, _LVP_OFF_4L);

LEDMTX_BEGIN_MODULES_INIT
LEDMTX_MODULE_INIT(scrollstr)
LEDMTX_END_MODULES_INIT

// Reserve enough memory for a 32x7 framebuffer
LEDMTX_FRAMEBUFFER_RES(28)

DEF_INTLOW(low_int)
DEF_HANDLER(SIG_TMR0, _tmr0_handler)
END_DEF

// The ISR for Timer 0.  In this example, in addition to the vertical refresh
// routine, `ledmtx_scrollstr_interrupt()` is called to perform the asynchronous
// text scroll actions.
SIGHANDLERNAKED(_tmr0_handler)
{
  LEDMTX_BEGIN_ISR
    LEDMTX_BEGIN_R0
      ledmtx_scrollstr_interrupt();
    LEDMTX_END_R0
    LEDMTX_VERTREFRESH
  LEDMTX_END_ISR
}

char str[] = "scrollstr32x7: using r393c164 driver to refresh a 32x7 display";

void main(void)
{
  struct ledmtx_scrollstr_desc s0;
  
  TRISA = 0xe0;
  ADCON1 = 0x0f;
  
  // `ledmtx_tmr0config` was used to obtain the values for TMR0H, TMR0L, T0CON,
  // as in
  // ```bash
  // $ ./ledmtx_tmr0config 7 50 8000000`
  // ```
  ledmtx_init(LEDMTX_INIT_CLEAR | LEDMTX_INIT_TMR0, 32, 7, 0xe9, 0xae, 0x88);
  ledmtx_setfont(ledmtx_font5x7);
  
  LEDMTX_SCROLLSTR_SET(s0, 2, 0, 0, 32, (__data char*)str,
		       ledmtx_scrollstr_step, ledmtx_scrollstr_reset);
  ledmtx_scrollstr_start(&s0);
}
