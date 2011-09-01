;
; call_fsr0.S - libledmtx scrollstr module: call routine using FSR0
;
; Copyright (C) 2011  Javier L. Gomez
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

  include <p18fxxx.inc>

  global _ledmtx_scrollstr_call_fsr0

  code
_ledmtx_scrollstr_call_fsr0:
  movf		POSTINC0, w, A
  movff		POSTINC0, PCLATH
  movff		POSTINC0, PCLATU
  movwf		PCL, A

  end
