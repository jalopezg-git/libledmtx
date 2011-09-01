;
; putpixel.S - libledmtx core: put pixel
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
  extern _ledmtx_config_stride
  extern _ledmtx_framebuffer

.registers	udata_ovr	0x0000
r0x00	res	1

  global _ledmtx_putpixel

  code
; extern void ledmtx_putpixel(unsigned char, unsigned char, unsigned char)
_ledmtx_putpixel:
  movff		r0x00, POSTDEC1		; push r0x00

  movlw		2			; 3 LSb of x -> r0x00
  movf		PLUSW1, w, A
  andlw		0x07
  movwf		r0x00, A

  movlw		2			; x >> 3 -> WREG
  rrncf		PLUSW1, f, A
  rrncf		PLUSW1, f, A
  rrncf		PLUSW1, w, A
  andlw		0x1f

  lfsr		0, _ledmtx_framebuffer	; _ledmtx_framebuffer
  addwf		FSR0L, f, A		; +WREG
  btfsc		STATUS, C, A
  incf		FSR0H, f, A
  movlw		3			; +y*_ledmtx_config_stride -> FSR0
  movf		PLUSW1, w, A
  mulwf		_ledmtx_config_stride, A
  movf		PRODL, w, A
  addwf		FSR0L, f, A
  movf		PRODH, w, A
  addwfc	FSR0H, f, A

  movlw		4			; val -> PRODL
  movff		PLUSW1, PRODL

  movlw		0x80
  movf		r0x00, f, A		; 3 LSb of x==0?
  bz		@putpixel_do

@putpixel_shift:
  rrncf		WREG, w, A		; shift WREG
  decfsz	r0x00, f, A
  bra		@putpixel_shift

@putpixel_do:
  tstfsz	PRODL, A		; val==0?
  bra		@putpixel_nz

  xorlw		0xff			; framebufferbits&=~WREG
  andwf		INDF0, f, A
  bra		@putpixel_ret

@putpixel_nz:
  iorwf		INDF0, f, A		; framebuffer|=WREG

@putpixel_ret:
  movff		PREINC1, r0x00		; pop r0x00
  return

  end
