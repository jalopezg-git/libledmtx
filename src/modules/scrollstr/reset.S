;
; reset.S - libledmtx scrollstr module: reset struct values
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

  global _ledmtx_scrollstr_reset

  code
; extern void ledmtx_scrollstr_reset(__data struct ledmtx_scrollstr_s *)
_ledmtx_scrollstr_reset:
  movlw		1		; argument -> FSR0
  movff		PLUSW1, FSR0L
  movlw		2
  movff		PLUSW1, FSR0H

  movlw		1		; timeout -> counter
  movff		PLUSW0, INDF0

  movlw		10
  addwf		FSR0L, f, A
  btfsc		STATUS, C, A
  incf		FSR0H, f, A

  clrf		POSTINC0, A	; 0 -> i
  movlw		1		; 1 -> charoff
  movwf		POSTINC0, A
  movlw		0x80		; 0x80 -> mask
  movwf		POSTINC0, A
  return

  end
