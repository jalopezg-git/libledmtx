;
; putpixel.S - libledmtx core: put pixel
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
  extern _ledmtx_config_stride
  extern _ledmtx_framebuffer

.registers	udata_ovr	0x0000
r0x00	res	1

  global _ledmtx_putpixel

  code
;; extern void ledmtx_putpixel(unsigned char x, unsigned char y, unsigned char val)
_ledmtx_putpixel:
  movff		r0x00, POSTDEC1		; push r0x0? registers

  movlw		2			; r0x00 = (x & 0x07)
  movf		PLUSW1, w, A
  andlw		0x07
  movwf		r0x00, A

  movlw		2			; WREG = x >> 3
  rrncf		PLUSW1, f, A
  rrncf		PLUSW1, f, A
  rrncf		PLUSW1, w, A
  andlw		0x1f

;; Compute framebuffer address of the byte to touch
  lfsr		0, _ledmtx_framebuffer	; FSR0 = _ledmtx_framebuffer
  addwf		FSR0L, f, A		;          + (x >> 3)
  btfsc		STATUS, C, A
  incf		FSR0H, f, A
  movlw		3			;          + (y * _ledmtx_config_stride)
  movf		PLUSW1, w, A
  mulwf		_ledmtx_config_stride, A
  movf		PRODL, w, A
  addwf		FSR0L, f, A
  movf		PRODH, w, A
  addwfc	FSR0H, f, A

  movlw		4			; PRODL = val
  movff		PLUSW1, PRODL

;; WREG holds the mask of the bit to touch; initialize to 0x80 and shift by `(x & 0x07)`
  movlw		0x80
  movf		r0x00, f, A
  bz		@putpixel_do
@putpixel_shift:
  rrncf		WREG, w, A
  decfsz	r0x00, f, A
  bra		@putpixel_shift

@putpixel_do:
  tstfsz	PRODL, A
  bra		@putpixel_nz
  xorlw		0xff			; if `val == 0`, do `*FSR0 &= ~WREG`
  andwf		INDF0, f, A
  bra		@putpixel_ret
@putpixel_nz:
  iorwf		INDF0, f, A		; otherwise, `*FSR0 |= WREG`

@putpixel_ret:
  movff		PREINC1, r0x00		; pop r0x0? registers
  return

  end
