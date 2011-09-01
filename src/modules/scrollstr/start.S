;
; start.S - libledmtx scrollstr module: add pointer to _ledmtx_scrollstr_vec
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
  extern _ledmtx_scrollstr_vec

  global _ledmtx_scrollstr_start

  code
; extern unsigned char ledmtx_scrollstr_start(__data struct ledmtx_scrollstr_s *)
_ledmtx_scrollstr_start:
  lfsr		0, _ledmtx_scrollstr_vec	; _ledmtx_scrollstr_vec -> FSR0
  movlw		0x01
  bcf		STATUS, C, A

@start_loop:
  movwf		POSTDEC1, A			; push WREG
  andwf		_ledmtx_scrollstr_bitmap, w, A	; WREG&_ledmtx_scrollstr_bitmap==0?
  bnz		@start_used

  movlw		2				; argument -> *FSR0
  movff		PLUSW1, POSTINC0
  movlw		3
  movff		PLUSW1, POSTINC0

  movff		PLUSW1, FSR0H			; argument -> FSR0
  movlw		2
  movff		PLUSW1, FSR0L
  movlw		16				; pop WREG -> FSR0+16
  movff		PREINC1, PLUSW0

  movf		INDF1, w, A			; _ledmtx_scrollstr_bitmap|=WREG
  iorwf		_ledmtx_scrollstr_bitmap, f, A
  return

@start_used:
  movf		POSTINC0, f, A			; FSR0+2 -> FSR0
  movf		POSTINC0, f, A
  rlcf		PREINC1, w, A			; pop WREG; shift
  bnz		@start_loop
  retlw		0

  end
