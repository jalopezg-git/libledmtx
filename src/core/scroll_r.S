;
; scroll_r.S - libledmtx core: scroll right
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

  global _ledmtx_scroll_r

  code
; extern void ledmtx_scroll_r(unsigned char, unsigned char, unsigned char, unsigned char)
_ledmtx_scroll_r:
  movff		r0x00, POSTDEC1		; push r0x00

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

  movlw		4			; w >> 3 -> r0x00
  rrncf		PLUSW1, f, A
  rrncf		PLUSW1, f, A
  rrncf		PLUSW1, w, A
  andlw		0x1f
  movwf		r0x00, A

  movlw		5			; h -> PRODL
  movff		PLUSW1, PRODL

@scroll_r_loop:
  movff		r0x00, PRODH
  bcf		STATUS, C, A
  clrf		WREG, A

@scroll_r_shift:
  rrcf		PLUSW0, f, A		; shift
  incfsz	WREG, w, A		; incf affects Carry bit; incfsz do not
  ; nop
  decfsz	PRODH, f, A		; loop while --PRODH!=0
  bra		@scroll_r_shift

  movf		_ledmtx_config_stride, w, A
  addwf		FSR0L, f, A		; FSR0+=_ledmtx_config_stride
  btfsc		STATUS, C, A
  incf		FSR0H, f, A

  decfsz	PRODL, f, A		; loop while --PRODL!=0
  bra		@scroll_r_loop

  movff		PREINC1, r0x00		; pop r0x00
  return

  end
