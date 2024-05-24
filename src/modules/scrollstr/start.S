;
; start.S - Find a free slot in `_ledmtx_scrollstr_vec` and schedule `desc` for
;           the next ISR call
;
; Copyright (C) 2011, 2023  Javier Lopez-Gomez
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
  include _P18FXXX_INC

  ; udata
  extern _ledmtx_scrollstr_bitmap
  extern _ledmtx_scrollstr_vec

  global _ledmtx_scrollstr_start

  code
;; extern unsigned char ledmtx_scrollstr_start(__data struct ledmtx_scrollstr_desc *desc)
_ledmtx_scrollstr_start:
  lfsr		0, _ledmtx_scrollstr_vec	; FSR0 = _ledmtx_scrollstr_vec

;; While iterating, WREG holds a bitmask that has a single 1 corresponding to
;; the  position of the current entry.
  movlw		0x01
  bcf		STATUS, C, A
@start_loop:				       	; `do {`
;; Find a free slot in `_ledmtx_scrollstr_vec`
  movwf		POSTDEC1, A			;	push WREG
  andwf		_ledmtx_scrollstr_bitmap, w, A	;	if (WREG & ~_ledmtx_scrollstr_bitmap)
  bnz		@start_used

;; Set `_ledmtx_scrollstr_vec[i] = desc`, where `i` is some free slot
  movlw		2
  movff		PLUSW1, POSTINC0
  movlw		3
  movff		PLUSW1, POSTINC0

;; Set `desc->mask = WREG`
  movff		PLUSW1, FSR0H			; FSR0 = desc
  movlw		2
  movff		PLUSW1, FSR0L
  movlw		16				; *(FRS0 + 16) = WREG
  movff		PREINC1, PLUSW0

  movf		INDF1, w, A			; _ledmtx_scrollstr_bitmap |= WREG
  iorwf		_ledmtx_scrollstr_bitmap, f, A
  return

@start_used:
  movf		POSTINC0, f, A			; FSR0 += 2
  movf		POSTINC0, f, A
  rlcf		PREINC1, w, A			; WREG = WREG << 1
  bnz		@start_loop			; `} while (WREG)`
  retlw		0

  end
