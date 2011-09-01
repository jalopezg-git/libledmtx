;
; libledmtx_stdio.S - libledmtx stdio support
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
  extern _ledmtx_font_sz_h
  extern _ledmtx_font_mask

  global _ledmtx_stdio_x
  global _ledmtx_stdio_y

.idata_ledmtx_stdio	idata
_ledmtx_stdio_x		db	0
_ledmtx_stdio_y		db	0

  extern _ledmtx_putchar

  global _putchar

  code
; extern void putchar(char c) __wparam
_putchar:
  movwf		PRODL, A		; c=='\n'?
  movlw		0x0a
  cpfseq	PRODL, A
  bra		@putchar_dump

  banksel	_ledmtx_stdio_x		; _ledmtx_stdio_x=0
  clrf		_ledmtx_stdio_x
  incf		_ledmtx_font_sz_h, w, A	; _ledmtx_stdio_y+=(_ledmtx_font_sz_h+1)
  addwf		_ledmtx_stdio_y, f
  return

@putchar_dump:
  movff		PRODL, POSTDEC1		; push args
  movff		_ledmtx_stdio_y, POSTDEC1
  movff		_ledmtx_stdio_x, POSTDEC1
  movff		_ledmtx_font_mask, POSTDEC1
  movlw		0x00
  call		_ledmtx_putchar
  movlw		4
  addwf		FSR1L, f, A

  incf		_ledmtx_font_sz_w, w, A	; _ledmtx_stdio_x+=(_ledmtx_font_sz_w+1)
  banksel	_ledmtx_stdio_x
  addwf		_ledmtx_stdio_x, f
  return

  end
