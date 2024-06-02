;
; swapbuffers.S - libledmtx core: swap the front / back buffer addresses
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

  global _ledmtx_swapbuffers
  global _ledmtx_swapbuffers_on_vsync

  code
;; extern void ledmtx_swapbuffers(void)
_ledmtx_swapbuffers:
;; Temporarily disable interrupts given that another call to `ledmtx_swapbuffers()`
;; may also happen from ISR.
  bcf		INTCON, GIE, A
  movff		_ledmtx_backbuffer+0, PRODL
  movff		_ledmtx_frontbuffer+0, _ledmtx_backbuffer+0
  movff		PRODL, _ledmtx_frontbuffer+0
  movff		_ledmtx_backbuffer+1, PRODL
  movff		_ledmtx_frontbuffer+1, _ledmtx_backbuffer+1
  movff		PRODL, _ledmtx_frontbuffer+1
  bsf		INTCON, GIE, A
  CLEAR_SWAPBUFFERS_ON_VSYNC
  return

;; extern void ledmtx_swapbuffers_on_vsync(void)
_ledmtx_swapbuffers_on_vsync:
  SET_SWAPBUFFERS_ON_VSYNC
  return

  end
