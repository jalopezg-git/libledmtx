/*
 * ledmtx_scrollstr.h - libledmtx scrollstr module header
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

#ifndef __LEDMTX_SCROLLSTR_H__
#define __LEDMTX_SCROLLSTR_H__

#include <ledmtx_r0reg_fsr2.h>
#include <ledmtx_r0reg_tblrd.h>

extern char ledmtx_scrollstr_init;

struct ledmtx_scrollstr_s {
  unsigned char counter;
  unsigned char timeout;
  __far void (*step)(__data struct ledmtx_scrollstr_s *);
  unsigned char w;
  unsigned char y;
  unsigned char x;
  __data char *str;
  char i;
  unsigned char charoff;
  unsigned char mask;
  __far void (*end)(__data struct ledmtx_scrollstr_s *);
  unsigned char bitmap_mask;
};

#define LEDMTX_SCROLLSTR_SET(arg, _timeout, _x, _y, _w, _str, _step, _end) \
do {                                                                       \
  (arg).counter = (arg).timeout = _timeout;                                \
  (arg).step = _step;                                                      \
  (arg).w = _w;                                                            \
  (arg).y = _y;                                                            \
  (arg).x = _x;                                                            \
  (arg).str = _str;                                                        \
  (arg).i = 0;                                                             \
  (arg).charoff = 1;                                                       \
  (arg).mask = 0x80;                                                       \
  (arg).end = _end;                                                        \
  (arg).bitmap_mask = 0x00;                                                \
} while(0)

extern void ledmtx_scrollstr_reset(__data struct ledmtx_scrollstr_s *arg);

extern void ledmtx_scrollstr_interrupt(void) __naked;
extern unsigned char ledmtx_scrollstr_start(__data struct ledmtx_scrollstr_s *arg);
extern void ledmtx_scrollstr_stop(__data struct ledmtx_scrollstr_s *arg);

extern void ledmtx_scrollstr_step(__data struct ledmtx_scrollstr_s *arg);

#endif
