;
; reset.S - reset descriptor to known values so that `ledmtx_scrollstr_start()`
;           can be called again
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

  global _ledmtx_scrollstr_reset

  code
;; extern void ledmtx_scrollstr_reset(__data struct ledmtx_scrollstr_desc *desc)
_ledmtx_scrollstr_reset:
  movlw		1		; FSR0 = desc
  movff		PLUSW1, FSR0L
  movlw		2
  movff		PLUSW1, FSR0H

  movlw		1		; counter = timeout
  movff		PLUSW0, INDF0

  movlw		11
  addwf		FSR0L, f, A
  btfsc		STATUS, C, A
  incf		FSR0H, f, A
  clrf		POSTINC0, A	; i = 0
  movlw		1		; charoff = 1
  movwf		POSTINC0, A
  movlw		0x80		; mask = 0x80
  movwf		POSTINC0, A
  return

  end
