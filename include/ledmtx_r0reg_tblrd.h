/*
 * ledmtx_r0reg_tblrd.h - store/restore EECON1, TBLPTRx and TABLAT when
 *                        entering/exiting LEDMTX_R0 section
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

#ifndef __LEDMTX_R0REG_TBLRD_H__
#define __LEDMTX_R0REG_TBLRD_H__

#define LEDMTX_R0_STORE_TBLRD               \
  __asm movff _EECON1, _POSTDEC1 __endasm;  \
  __asm movff _TBLPTRU, _POSTDEC1 __endasm; \
  __asm movff _TBLPTRH, _POSTDEC1 __endasm; \
  __asm movff _TBLPTRL, _POSTDEC1 __endasm; \
  __asm movff _TABLAT, _POSTDEC1 __endasm;

#define LEDMTX_R0_RESTORE_TBLRD            \
  __asm movff _PREINC1, _TABLAT __endasm;  \
  __asm movff _PREINC1, _TBLPTRL __endasm; \
  __asm movff _PREINC1, _TBLPTRH __endasm; \
  __asm movff _PREINC1, _TBLPTRU __endasm; \
  __asm movff _PREINC1, _EECON1 __endasm;

#endif
