/*
 * ledmtx_core.h - libledmtx core header
 *
 * Copyright (C) 2011  Javier L. Gomez
 *
 * This program is free software; you can redistribute it and/or modify
 * it under the terms of the GNU Library General Public License as published by
 * the Free Software Foundation; either version 2 of the License, or
 * (at your option) any later version.
 *
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU Library General Public License for more details.
 *
 * You should have received a copy of the GNU Library General Public License
 * along with this program; if not, write to the Free Software
 * Foundation, Inc., 59 Temple Place - Suite 330, Boston, MA 02111-1307, USA
 */

#ifndef __LEDMTX_CORE_H__
#define __LEDMTX_CORE_H__

#include <pic18fregs.h>

#ifndef STACK_MODEL_SMALL
  #error Unsupported stack model
#endif

extern char ledmtx_driver_row;
extern char ledmtx_driver_vertrefresh;
extern char ledmtx_config_width;
extern char ledmtx_config_height;
extern char ledmtx_config_stride;
extern char ledmtx_config_tmr0h;
extern char ledmtx_config_tmr0l;
extern char ledmtx_config_t0con;

#define LEDMTX_BEGIN_MODULES_INIT \
  void ledmtx_modules_init(void) __naked {

#define LEDMTX_MODULE_INIT(module) \
  __asm call _ledmtx_ ## module ## _init __endasm;

#define LEDMTX_END_MODULES_INIT \
  __asm return __endasm;        \
  }

#ifndef __LEDMTX_R0REG_FSR2_H__
  #define LEDMTX_R0_STORE_FSR2
  #define LEDMTX_R0_RESTORE_FSR2
#endif

#ifndef __LEDMTX_R0REG_TBLRD_H__
  #define LEDMTX_R0_STORE_TBLRD
  #define LEDMTX_R0_RESTORE_TBLRD
#endif

#define LEDMTX_FRAMEBUFFER_RES(size) \
  unsigned char ledmtx_framebuffer[size];

#define LEDMTX_BEGIN_ISR                              \
  __asm bcf   _INTCON, 2, 0 __endasm; /* TMR0IF, A */ \
  __asm movff _ledmtx_config_tmr0h, _TMR0H __endasm;  \
  __asm movff _ledmtx_config_tmr0l, _TMR0L __endasm;  \
  __asm movff _STATUS, _POSTDEC1 __endasm;            \
  __asm movwf _POSTDEC1, 0 __endasm; /* A */          \
  /* __asm movff _BSR, _POSTDEC1 __endasm; */         \
  __asm movff _PRODH, _POSTDEC1 __endasm;             \
  __asm movff _PRODL, _POSTDEC1 __endasm;             \
  __asm movff _FSR0H, _POSTDEC1 __endasm;             \
  __asm movff _FSR0L, _POSTDEC1 __endasm;

#ifndef LEDMTX_RETFIE
  #define LEDMTX_RETFIE           __asm retfie __endasm;
#endif

#define LEDMTX_END_ISR                         \
  __asm movff _PREINC1, _FSR0L __endasm;       \
  __asm movff _PREINC1, _FSR0H __endasm;       \
  __asm movff _PREINC1, _PRODL __endasm;       \
  __asm movff _PREINC1, _PRODH __endasm;       \
  /* __asm movff _PREINC1, _BSR __endasm; */   \
  __asm movf  _PREINC1, w, 0 __endasm; /* A */ \
  __asm movff _PREINC1, _STATUS __endasm;      \
  LEDMTX_RETFIE

#define LEDMTX_VERTREFRESH        __asm call _ledmtx_driver_vertrefresh __endasm;

#define LEDMTX_BEGIN_R0                                \
  __asm tstfsz _ledmtx_driver_row, 0 __endasm; /* A */ \
  __asm bra    @ledmtx_end_r0 __endasm;                \
  LEDMTX_R0_STORE_FSR2                                 \
  LEDMTX_R0_STORE_TBLRD

#define LEDMTX_END_R0             \
  LEDMTX_R0_RESTORE_TBLRD         \
  LEDMTX_R0_RESTORE_FSR2          \
  __asm @ledmtx_end_r0: __endasm;

#define LEDMTX_INIT_CLEAR         0x01
#define LEDMTX_INIT_TMR0          0x02

#define LEDMTX_PUTCHAR_CPY        0x00
#define LEDMTX_PUTCHAR_IOR        0x01

extern unsigned char ledmtx_font_sz_w;
extern unsigned char ledmtx_font_sz_h;
extern unsigned char ledmtx_font_mask;

extern void ledmtx_init(unsigned char arg, unsigned char width, unsigned char height, unsigned char tmr0h, unsigned char tmr0l, unsigned char t0con) __wparam;

extern void ledmtx_clear(void);
extern void ledmtx_putpixel(unsigned char x, unsigned char y, unsigned char val);

extern void ledmtx_putchar(unsigned char cpy, unsigned char mask, unsigned char x, unsigned char y, char c) __wparam;
extern void ledmtx_putstr(unsigned char x, unsigned char y, __data char *str);
extern void ledmtx_setfont(__far void (*font)(void));

extern void ledmtx_scroll_l(unsigned char x, unsigned char y, unsigned char w, unsigned char h);
extern void ledmtx_scroll_r(unsigned char x, unsigned char y, unsigned char w, unsigned char h);

#endif
