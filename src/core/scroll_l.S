;
; scroll_l.S - libledmtx core: scroll left
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

  global _ledmtx_scroll_l

  code
; extern void ledmtx_scroll_l(unsigned char, unsigned char, unsigned char, unsigned char)
_ledmtx_scroll_l:
  movff		r0x00, POSTDEC1		; push r0x00

  movlw		2			; x >> 3 -> PRODL
  rrncf		PLUSW1, f, A
  rrncf		PLUSW1, f, A
  rrncf		PLUSW1, w, A
  andlw		0x1f
  movwf		PRODL, A

  movlw		4			; w >> 3 -> r0x00
  rrncf		PLUSW1, f, A
  rrncf		PLUSW1, f, A
  rrncf		PLUSW1, w, A
  andlw		0x1f
  movwf		r0x00, A
  addwf		PRODL, w, A		; r0x00+PRODL-1 -> WREG
  decf		WREG, w, A

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

  movlw		5
  movff		PLUSW1, PRODL		; h -> PRODL

@scroll_l_loop:
  movff		r0x00, PRODH
  bcf		STATUS, C, A
  clrf		WREG, A

@scroll_l_shift:
  rlcf		PLUSW0, f, A		; shift
  decfsz	WREG, w, A		; decf affects Carry bit; decfsz do not 
  ; nop
  decfsz	PRODH, f, A		; loop while --PRODH!=0
  bra		@scroll_l_shift

  movf		_ledmtx_config_stride, w, A
  addwf		FSR0L, f, A		; FSR0+=_ledmtx_config_stride
  btfsc		STATUS, C, A
  incf		FSR0H, f, A

  decfsz	PRODL, f, A		; loop while --PRODL!=0
  bra		@scroll_l_loop

  movff		PREINC1, r0x00		; pop r0x00
  return

  end
