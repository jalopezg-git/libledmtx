;
; putchar.S - libledmtx core: put character
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
; extern void ledmtx_putchar(unsigned char, unsigned char, unsigned char, unsigned char, char) __wparam
_ledmtx_putchar:
  movff		r0x00, POSTDEC1		; push r0x00, r0x01, r0x02, r0x03
  movff		r0x01, POSTDEC1
  movff		r0x02, POSTDEC1
  movff		r0x03, POSTDEC1

  movwf		r0x03, A		; cpy -> r0x03

  movlw		5			; mask is r0x01:r0x00
  movff		PLUSW1, r0x01
  clrf		r0x00, A

  movlw		6			; 3 LSb of x -> r0x02
  movf		PLUSW1, w, A
  andlw		0x07
  movwf		r0x02, A
  bz		@putchar_docpy		; shift mask?

@putchar_shift:
  bcf		STATUS, C, A		; shift r0x01:r0x00
  rrcf		r0x01, f, A
  rrcf		r0x00, f, A
  decfsz	WREG, w, A
  bra		@putchar_shift

@putchar_docpy:
  movlw		6			; x >> 3 -> WREG
  rrncf		PLUSW1, f, A
  rrncf		PLUSW1, f, A
  rrncf		PLUSW1, w, A
  andlw		0x1f

  lfsr		0, _ledmtx_framebuffer	; _ledmtx_framebuffer
  addwf		FSR0L, f, A		; +WREG
  btfsc		STATUS, C, A
  incf		FSR0H, f, A
  movlw		7			; +y*_ledmtx_config_stride -> FSR0
  movf		PLUSW1, w, A
  mulwf		_ledmtx_config_stride, A
  movf		PRODL, w, A
  addwf		FSR0L, f, A
  movf		PRODH, w, A
  addwfc	FSR0H, f, A

  bsf		EECON1, EEPGD, A
  bcf		EECON1, CFGS, A

  movff		_ledmtx_font+0, TBLPTRL	; _ledmtx_font
  movff		_ledmtx_font+1, TBLPTRH
  movff		_ledmtx_font+2, TBLPTRU
  movlw		8			; +c*_ledmtx_font_sz_h
  movf		PLUSW1, w, A
  mulwf		_ledmtx_font_sz_h, A
  movf		PRODL, w, A
  addwf		TBLPTRL, f, A
  movf		PRODH, w, A
  addwfc	TBLPTRH, f, A
  btfsc		STATUS, C, A
  incf		TBLPTRU, f, A
  tblrd*+				; +2 -> TBLPTRU:TBLPTRH:TBLPTRL
  tblrd*+

  movf		r0x03, w, A		; _ledmtx_putchar_cpycpy if cpy==0
  bz		_ledmtx_putchar_cpycpy
  ;bnz		_ledmtx_putchar_cpyior

_ledmtx_putchar_cpyior:
  movff		_ledmtx_font_sz_h, r0x03

@putchar_cpyior_loop:
  tblrd*+

  movf		r0x02, w, A		; r0x02 is 3 LSb of x
  bz		@putchar_cpyior_do	; shift char bits?

@putchar_cpyior_shift:
  bcf		STATUS, C, A		; shift TABLAT:PRODL
  rrcf		TABLAT, f, A
  rrcf		PRODL, f, A
  decfsz	WREG, w, A
  bra		@putchar_cpyior_shift

@putchar_cpyior_do
  movf		TABLAT, w, A		; framebufferbits|=(charbits&mask)
  andwf		r0x01, w, A
  iorwf		POSTINC0, f, A		; byte 1

  movf		PRODL, w, A
  andwf		r0x00, w, A
  iorwf		POSTDEC0, f, A		; byte 0

  movf		_ledmtx_config_stride, w, A
  addwf		FSR0L, f, A		; FSR0+=_ledmtx_config_stride
  btfsc		STATUS, C, A
  incf		FSR0H, f, A

  decfsz	r0x03, f, A		; loop while r0x03!=0
  bra		@putchar_cpyior_loop

  movff		PREINC1, r0x03		; pop r0x03, r0x02, r0x01, r0x00
  movff		PREINC1, r0x02
  movff		PREINC1, r0x01
  movff		PREINC1, r0x00
  return

_ledmtx_putchar_cpycpy:
  movff		_ledmtx_font_sz_h, r0x03

@putchar_cpycpy_loop:
  tblrd*+

  movf		r0x02, w, A		; r0x02 is 3 LSb of x
  bz		@putchar_cpycpy_tsth	; shift char bits?

@putchar_cpycpy_shift:
  bcf		STATUS, C, A		; shift TABLAT:PRODL
  rrcf		TABLAT, f, A
  rrcf		PRODL, f, A
  decfsz	WREG, w, A
  bra		@putchar_cpycpy_shift

@putchar_cpycpy_tsth:
  movf		r0x01, w, A		; byte 1 of mask==0?
  bz		@putchar_cpycpy_tstl

@putchar_cpycpy_h:
  xorlw		0xff			; framebufferbits&=~mask
  andwf		INDF0, f, A
  movf		TABLAT, w, A		; framebufferbits|=(charbits&mask)
  andwf		r0x01, w, A
  iorwf		INDF0, f, A

@putchar_cpycpy_tstl:
  movf		r0x00, w, A		; byte 0 of mask==0?
  bz		@putchar_cpycpy_lz

@putchar_cpycpy_l:
  xorlw		0xff
  andwf		PREINC0, f, A
  movf		PRODL, w, A
  andwf		r0x00, w, A
  iorwf		POSTDEC0, f, A

@putchar_cpycpy_lz:
  movf		_ledmtx_config_stride, w, A
  addwf		FSR0L, f, A		; FSR0+=_ledmtx_config_stride
  btfsc		STATUS, C, A
  incf		FSR0H, f, A

  decfsz	r0x03, f, A		; loop while r0x03!=0
  bra		@putchar_cpycpy_loop

  movff		PREINC1, r0x03		; pop r0x03, r0x02, r0x01, r0x00
  movff		PREINC1, r0x02
  movff		PREINC1, r0x01
  movff		PREINC1, r0x00
  return

  end
