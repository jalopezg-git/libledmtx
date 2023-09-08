;
; setfont.S - libledmtx core: set font for text operations
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

  include <p18fxxx.inc>

  ; udata
  extern _ledmtx_font
  extern _ledmtx_font_sz_w
  extern _ledmtx_font_sz_h
  extern _ledmtx_font_mask

  global _ledmtx_setfont

  code
;; extern void ledmtx_setfont(__far void (*font)(void))
_ledmtx_setfont:
;; _ledmtx_font = font
  movlw		1
  movff		PLUSW1, _ledmtx_font+0
  movlw		2
  movff		PLUSW1, _ledmtx_font+1
  movlw		3
  movff		PLUSW1, _ledmtx_font+2

  bsf		EECON1, EEPGD, A
  bcf		EECON1, CFGS, A
  movff		_ledmtx_font+0, TBLPTRL	; _ledmtx_font -> TBLPTRU:TBLPTRH:TBLPTRL
  movff		_ledmtx_font+1, TBLPTRH
  movff		_ledmtx_font+2, TBLPTRU

  tblrd*+				; _ledmtx_font_sz_w = *(TBLPTR++)
  movf		TABLAT, w, A
  movwf		_ledmtx_font_sz_w, A

;; Initialize `_leftmtx_font_mask`.  Glyphs are left-aligned; a bit is set if
;; its state is defined by the font
  clrf		_ledmtx_font_mask, A
@setfont_shift:
  bsf		STATUS, C, A
  rrcf		_ledmtx_font_mask, f, A
  decfsz	WREG, w, A
  bra		@setfont_shift

  tblrd*+				; _ledmtx_font_sz_h = *(TBLPTR++)
  movff		TABLAT, _ledmtx_font_sz_h
  return

  end
