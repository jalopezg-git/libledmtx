;
; putchar.S - libledmtx core: put character
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
  extern _ledmtx_font
  extern _ledmtx_font_sz_h
  extern _ledmtx_config_stride
  extern _ledmtx_framebuffer

.registers	udata_ovr	0x0000
r0x00	res	1
r0x01	res	1
r0x02	res	1
r0x03	res	1

  global _ledmtx_putchar

  code
;; extern void ledmtx_putchar(unsigned char op, unsigned char mask,
;;                            unsigned char x, unsigned char y, char c) __wparam
_ledmtx_putchar:
  movff		r0x00, POSTDEC1		; push r0x0? registers
  movff		r0x01, POSTDEC1
  movff		r0x02, POSTDEC1
  movff		r0x03, POSTDEC1

  movwf		r0x03, A		; r0x03 = op

;; `mask` determines the mask to apply when copying character bits.  However,
;; the framebuffer packs the state of 8 pixels per octet and, depending on
;; where `x` lies, we may need to touch two bytes (i.e., part of the character
;; is represented in byte $I$ and byte $I+1$).
;; Thus, extend the mask to two bytes and store in r0x01:r0x00
  movlw		5
  movff		PLUSW1, r0x01
  clrf		r0x00, A

  movlw		6
  movf		PLUSW1, w, A
  andlw		0x07
  movwf		r0x02, A		; r0x02 = (x & 0x07)
;; Shift mask to right by `(x & 0x07)` bits, if needed
  bz		@putchar_docpy
@putchar_shift:
  bcf		STATUS, C, A		; shift right r0x01:r0x00
  rrcf		r0x01, f, A
  rrcf		r0x00, f, A
  decfsz	WREG, w, A
  bra		@putchar_shift

@putchar_docpy:
  movlw		6			; WREG = x >> 3
  rrncf		PLUSW1, f, A
  rrncf		PLUSW1, f, A
  rrncf		PLUSW1, w, A
  andlw		0x1f

;; Compute the framebuffer address of the first byte where character data
;; should be copied
  lfsr		0, _ledmtx_framebuffer	; FSR0 = _ledmtx_framebuffer
  addwf		FSR0L, f, A		;          + (x >> 3)
  btfsc		STATUS, C, A
  incf		FSR0H, f, A
  movlw		7			;          + (y * _ledmtx_config_stride)
  movf		PLUSW1, w, A
  mulwf		_ledmtx_config_stride, A
  movf		PRODL, w, A
  addwf		FSR0L, f, A
  movf		PRODH, w, A
  addwfc	FSR0H, f, A

  bsf		EECON1, EEPGD, A
  bcf		EECON1, CFGS, A
;; Compute the start address (in program memory) of the character to copy
  movff		_ledmtx_font+0, TBLPTRL	; TBLPTR = _ledmtx_font
  movff		_ledmtx_font+1, TBLPTRH
  movff		_ledmtx_font+2, TBLPTRU
  movlw		8			;            + (c * _ledmtx_font_sz_h)
  movf		PLUSW1, w, A
  mulwf		_ledmtx_font_sz_h, A
  movf		PRODL, w, A
  addwf		TBLPTRL, f, A
  movf		PRODH, w, A
  addwfc	TBLPTRH, f, A
  btfsc		STATUS, C, A
  incf		TBLPTRU, f, A
  tblrd*+				;            + 2
  tblrd*+

;; switch (op) { ... }
  movf		r0x03, w, A
  bz		_ledmtx_putchar_cpycpy	; case LEDMTX_PUTCHAR_CPY:
  ;bnz		_ledmtx_putchar_cpyior	; default:

_ledmtx_putchar_cpyior:
  movff		_ledmtx_font_sz_h, r0x03	; r0x03 = _ledmtx_font_size_h

@putchar_cpyior_loop:			; `do {`
  tblrd*+

;; Right shift character bits by `(x & 0x07)`
  movf		r0x02, w, A
  bz		@putchar_cpyior_do
@putchar_cpyior_shift:
  bcf		STATUS, C, A		; shift right TABLAT:PRODL
  rrcf		TABLAT, f, A
  rrcf		PRODL, f, A
  decfsz	WREG, w, A
  bra		@putchar_cpyior_shift

@putchar_cpyior_do
;; *(FSR0++) |= (character & mask)
  movf		TABLAT, w, A
  andwf		r0x01, w, A
  iorwf		POSTINC0, f, A		; byte 1
  movf		PRODL, w, A
  andwf		r0x00, w, A
  iorwf		POSTDEC0, f, A		; byte 0
;; FSR0 += _ledmtx_config_stride
  movf		_ledmtx_config_stride, w, A
  addwf		FSR0L, f, A
  btfsc		STATUS, C, A
  incf		FSR0H, f, A

  decfsz	r0x03, f, A		; `} while (r0x03 != 0)`
  bra		@putchar_cpyior_loop

  movff		PREINC1, r0x03		; pop r0x0? registers
  movff		PREINC1, r0x02
  movff		PREINC1, r0x01
  movff		PREINC1, r0x00
  return

_ledmtx_putchar_cpycpy:
  movff		_ledmtx_font_sz_h, r0x03	; r0x03 = _ledmtx_font_size_h

@putchar_cpycpy_loop:			; `do {`
  tblrd*+

;; Right shift character bits by `(x & 0x07)`
  movf		r0x02, w, A
  bz		@putchar_cpycpy_tsth
@putchar_cpycpy_shift:
  bcf		STATUS, C, A		; shift right TABLAT:PRODL
  rrcf		TABLAT, f, A
  rrcf		PRODL, f, A
  decfsz	WREG, w, A
  bra		@putchar_cpycpy_shift

;; Carry out `*(FSR0) &= ~mask` and `*(FSR0) |= (character & mask)` for each byte
@putchar_cpycpy_tsth:
  movf		r0x01, w, A		; byte 1
  bz		@putchar_cpycpy_tstl
@putchar_cpycpy_h:
  xorlw		0xff
  andwf		INDF0, f, A
  movf		TABLAT, w, A
  andwf		r0x01, w, A
  iorwf		INDF0, f, A

@putchar_cpycpy_tstl:
  movf		r0x00, w, A		; byte 0
  bz		@putchar_cpycpy_lz
@putchar_cpycpy_l:
  xorlw		0xff
  andwf		PREINC0, f, A
  movf		PRODL, w, A
  andwf		r0x00, w, A
  iorwf		POSTDEC0, f, A

@putchar_cpycpy_lz:
;; FSR0 += _ledmtx_config_stride
  movf		_ledmtx_config_stride, w, A
  addwf		FSR0L, f, A
  btfsc		STATUS, C, A
  incf		FSR0H, f, A

  decfsz	r0x03, f, A		; `} while (r0x03 != 0)`
  bra		@putchar_cpycpy_loop

  movff		PREINC1, r0x03		; pop r0x0? registers
  movff		PREINC1, r0x02
  movff		PREINC1, r0x01
  movff		PREINC1, r0x00
  return

  end
