;
; putstr.S - libledmtx core: put string
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
  extern _ledmtx_font_sz_w
  extern _ledmtx_font_mask
  extern _ledmtx_config_width

.registers	udata_ovr	0x0000
r0x00	res	1

  extern _ledmtx_putchar

  global _ledmtx_putstr

  code
;; extern void ledmtx_putstr(unsigned char x, unsigned char y, __data char *str)
_ledmtx_putstr:
  movff		FSR2H, POSTDEC1		; push registers
  movff		FSR2L, POSTDEC1
  movff		r0x00, POSTDEC1

  movlw		4
  movff		PLUSW1, PRODL		; PRODL = x
  movlw		5
  movff		PLUSW1, PRODH		; PRODH = y
  movlw		6
  movff		PLUSW1, FSR2L		; FSR2 = str
  movlw		7
  movff		PLUSW1, FSR2H

;; r0x00 = _ledmtx_config_width - _ledmtx_font_sz_w, i.e. greatest value for
;; `x` that is still valid
  movff		_ledmtx_config_width, r0x00
  movf		_ledmtx_font_sz_w, w, A
  subwf		r0x00, f, A

@putstr_loop:				; `do {`
  movff		PRODL, POSTDEC1
;; Call `ledmtx_putchar(0, PRODL, PRODH, *FSR2)`
  movff		INDF2, POSTDEC1
  movff		PRODH, POSTDEC1
  movff		PRODL, POSTDEC1
  movff		_ledmtx_font_mask, POSTDEC1
  clrf		WREG, A
  call		_ledmtx_putchar
  movf		PREINC1, f, A
  movf		PREINC1, f, A
  movff		PREINC1, PRODH
  movf		PREINC1, f, A

  movff		PREINC1, PRODL

;; PRODL += (_ledmtx_font_sz_w + 1)
  incf		_ledmtx_font_sz_w, w, A
  addwf		PRODL, f, A

  movf		PREINC2, f, A
  bz		@putstr_ret		; if (*FSR2 == '\0') return;

  movf		r0x00, w, A
  cpfsgt	PRODL, A		; `} while (PRODL <= r0x00)`
  bra		@putstr_loop

@putstr_ret:
  movff		PREINC1, r0x00		; pop registers
  movff		PREINC1, FSR2L
  movff		PREINC1, FSR2H
  return

  end
