;
; stop.S - libledmtx scrollstr module: free _ledmtx_scrollstr_vec entry
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

  ; udata
  extern _ledmtx_scrollstr_bitmap

  global _ledmtx_scrollstr_stop

  code
; extern void ledmtx_scrollstr_stop(__data struct ledmtx_scrollstr_s *)
_ledmtx_scrollstr_stop:
  movlw		1				; argument -> FSR0
  movff		PLUSW1, FSR0L
  movlw		2
  movff		PLUSW1, FSR0H

  movlw		16				; _ledmtx_scrollstr_bitmap&=~*(FSR0+16)
  movf		PLUSW0, w, A
  xorlw		0xff
  andwf		_ledmtx_scrollstr_bitmap, f, A
  movlw		16				; 0 -> *(FSR0+16)
  clrf		PLUSW0, A
  return

  end
