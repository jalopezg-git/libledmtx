;
; setbackbuffer.S - libledmtx core: set the address of the backbuffer, i.e. the
;	buffer written to by most other operations
;
; Copyright (C) 2011-2024  Javier Lopez-Gomez
;
; This program is free software; you can redistribute it and/or modify
; it under the terms of the GNU Library General Public License as published by
; the Free Software Foundation; either version 2 of the License, or
; (at your option) any later version.
;
; This program is distributed in the hope that it will be useful,
; but WITHOUT ANY WARRANTY; without even the implied warranty of
; MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
; GNU Library General Public License for more details.
;
; You should have received a copy of the GNU Library General Public License
; along with this program; if not, write to the Free Software
; Foundation, Inc., 59 Temple Place - Suite 330, Boston, MA 02111-1307, USA
;

  radix dec

  include <ledmtx_config.h>
  include <ledmtx_load_bufaddr.inc>
  include _P18FXXX_INC

  global _ledmtx_setbackbuffer

  code
;; extern void ledmtx_setbackbuffer(__data unsigned char *)
_ledmtx_setbackbuffer:
;; Temporarily disable interrupts given that (i) write to `_ledmtx_backbuffer`
;; is not atomic, and (ii) `ledmtx_swapbuffers()` may be called from ISR.
  bcf		INTCON, GIE, A
  movlw		1
  movff		PLUSW1, _ledmtx_backbuffer+0
  movlw		2
  movff		PLUSW1, _ledmtx_backbuffer+1
  bsf		INTCON, GIE, A
  return

  end
