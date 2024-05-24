;
; interrupt.S - decrement counter and call `step()` as appropriate for
;               `_ledmtx_scrollstr_vec` entries
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

  extern _ledmtx_scrollstr_call_fsr0

  global _ledmtx_scrollstr_interrupt

  code
;; extern void ledmtx_scrollstr_interrupt(void)
_ledmtx_scrollstr_interrupt:
  lfsr		2, _ledmtx_scrollstr_vec	; FSR2 = _ledmtx_scrollstr_vec

  movlw		0x01
@interrupt_loop:				; `do {`
  movwf		POSTDEC1, A
  andwf		_ledmtx_scrollstr_bitmap, w, A	; if (WREG & ~_ledmtx_scrollstr_bitmap)
  bz		@interrupt_free

  movff		POSTINC2, FSR0L			; FSR0 = *(FSR2); FSR2 += 2
  movff		POSTINC2, FSR0H
  decfsz	INDF0, f, A			; if (--counter != 0)
  bra		@interrupt_nz

;; Issue indirect call to the `step()` function
  movff		FSR0H, POSTDEC1
  movff		FSR0L, POSTDEC1
  movlw		1
  movff		PLUSW0, POSTINC0		; 	counter = timeout
  movf		POSTINC0, f, A
  call		_ledmtx_scrollstr_call_fsr0
  movf		PREINC1, f, A
  movf		PREINC1, f, A
  bra		@interrupt_nz

@interrupt_free:
  movf		POSTINC2, f, A			; FSR2 += 2
  movf		POSTINC2, f, A

@interrupt_nz:
  bcf		STATUS, C, A
  rlcf		PREINC1, w, A			; WREG = WREG << 1
  bnz		@interrupt_loop			; `} while (WREG)`
  return

  end
