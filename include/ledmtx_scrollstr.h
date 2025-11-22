/*
 * ledmtx_scrollstr.h - libledmtx scrollstr module header
 *
 * Copyright (C) 2011, 2023  Javier Lopez-Gomez
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

/// Structure that describes an action to asynchronously scroll a string directly
/// from a timer ISR
struct ledmtx_scrollstr_desc {
  unsigned char counter;
  unsigned char timeout;        ///< Interval between steps
  __far void (*step)(__data struct ledmtx_scrollstr_desc *);   ///< The step function
  unsigned char h;              ///< Height of the region; usually just `ledmtx_font_sz_h`
  unsigned char w;              ///< Width of the region
  unsigned char y;              ///< The (y) coordinate of the region
  unsigned char x;              ///< The (x) coordinate of the region
  __data char *str;             ///< A pointer to a NUL-terminated string
  char i;                       ///< Index of the character currently being drawn
  unsigned char charoff;        ///< An offset, relative to `w + x`, used to draw the character
  unsigned char mask;           ///< Character mask passed to `ledmtx_putchar()`
  __far void (*end)(__data struct ledmtx_scrollstr_desc *);    ///< A function to be called at end
  unsigned char bitmap_mask;    ///< Mask that specifies which entry is used in `ledmtx_scroll_vec`
};

// FIXME: this should probably be turned into a function instead.
/// Helper to initialize a `struct ledmtx_scrollstr_desc`
#define LEDMTX_SCROLLSTR_SET(desc, _timeout, _x, _y, _w, _h, _str, _step, _end) \
do {                                                                        \
  (desc).counter = (desc).timeout = _timeout;                               \
  (desc).step = _step;                                                      \
  (desc).h = _h;                                                            \
  (desc).w = _w;                                                            \
  (desc).y = _y;                                                            \
  (desc).x = _x;                                                            \
  (desc).str = _str;                                                        \
  (desc).i = 0;                                                             \
  (desc).charoff = 1;                                                       \
  (desc).mask = 0x80;                                                       \
  (desc).end = _end;                                                        \
  (desc).bitmap_mask = 0x00;                                                \
} while(0)

/// Takes care of all asynchronous scroll actions that were started by
/// `ledmtx_scrollstr_start()`.  It should be called from within the ISR.
extern void ledmtx_scrollstr_interrupt(void) __naked;

/// Return a descriptor to a ready state so that `ledmtx_scrollstr_start()` can
/// be called again on it
extern void ledmtx_scrollstr_reset(__data struct ledmtx_scrollstr_desc *desc);

/// Start an asynchronous scroll of the character string referenced in `desc`
extern unsigned char ledmtx_scrollstr_start(__data struct ledmtx_scrollstr_desc *desc);

/// Stop an asynchronous scroll
extern void ledmtx_scrollstr_stop(__data struct ledmtx_scrollstr_desc *desc);

/// Manually carry out a scroll left + put character step.  Usually, this routine
/// is called indirectly from the ISR for all scheduled actions.
extern void ledmtx_scrollstr_step(__data struct ledmtx_scrollstr_desc *desc);

#endif
