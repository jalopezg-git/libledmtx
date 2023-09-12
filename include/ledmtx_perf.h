/*
 * ledmtx_perf.h - libledmtx perf module header
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

#ifndef __LEDMTX_PERF_H__
#define __LEDMTX_PERF_H__

#include <pic18fregs.h>

extern char ledmtx_perf_init;

extern char ledmtx_perf_tmr0;
/// The number of ticks before the next interrupt
extern unsigned int ledmtx_perf_intrtimelimit;

#define LEDMTX_RETFIE                               \
  __asm movff _TMR0L, _ledmtx_perf_tmr0+0 __endasm; \
  __asm movff _TMR0H, _ledmtx_perf_tmr0+1 __endasm; \
  __asm retfie __endasm;

/// Return the number of ticks took by the ISR to complete.
/// `ledmtx_perf_getintrtime() / ledmtx_perf_intrtimelimit` gives an idea of the
/// CPU time used by the ISR, which can be used to monitor / optimize the ISR.
extern unsigned int ledmtx_perf_getintrtime(void);

#endif
