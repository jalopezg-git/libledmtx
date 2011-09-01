;
; putstr.S - libledmtx core: put string
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
  extern _ledmtx_font_sz_w
  extern _ledmtx_font_mask
  extern _ledmtx_config_width

.registers	udata_ovr	0x0000
r0x00	res	1

  extern _ledmtx_putchar

  global _ledmtx_putstr

  code
; extern void ledmtx_putstr(unsigned char, unsigned char, __data char *)
_ledmtx_putstr:
  movff		FSR2H, POSTDEC1		; push FSR2x, r0x00
  movff		FSR2L, POSTDEC1
  movff		r0x00, POSTDEC1

  movlw		4
  movff		PLUSW1, PRODL		; x -> PRODL
  movlw		5
  movff		PLUSW1, PRODH		; y -> PRODH
  movlw		6
  movff		PLUSW1, FSR2L		; str -> FSR2
  movlw		7
  movff		PLUSW1, FSR2H

  movff		_ledmtx_config_width, r0x00
  movf		_ledmtx_font_sz_w, w, A
  subwf		r0x00, f, A		; _ledmtx_config_width-_ledmtx_font_sz_w -> r0x00

@putstr_loop:
  movff		PRODL, POSTDEC1

  movff		INDF2, POSTDEC1		; push args
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

  incf		_ledmtx_font_sz_w, w, A
  addwf		PRODL, f, A		; PRODL+=(_ledmtx_font_sz_w+1)

  movf		PREINC2, f, A
  bz		@putstr_ret		; PREINC2==0?

  movf		r0x00, w, A
  cpfsgt	PRODL, A		; PRODL>r0x00?
  bra		@putstr_loop

@putstr_ret:
  movff		PREINC1, r0x00		; pop r0x00, FSR2x
  movff		PREINC1, FSR2L
  movff		PREINC1, FSR2H
  return

  end
