;
; scroll_l.S - libledmtx core: scroll left
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
  extern _ledmtx_config_stride
  extern _ledmtx_framebuffer

.registers	udata_ovr	0x0000
r0x00	res	1

  global _ledmtx_scroll_l

  code
;; extern void ledmtx_scroll_l(unsigned char x, unsigned char y, unsigned char w, unsigned char h)
_ledmtx_scroll_l:
  movff		r0x00, POSTDEC1		; push registers

;; PRODL = x >> 3
  movlw		2
  rrncf		PLUSW1, f, A
  rrncf		PLUSW1, f, A
  rrncf		PLUSW1, w, A
  andlw		0x1f
  movwf		PRODL, A

;; r0x00 = w >> 3
  movlw		4
  rrncf		PLUSW1, f, A
  rrncf		PLUSW1, f, A
  rrncf		PLUSW1, w, A
  andlw		0x1f
  movwf		r0x00, A

;; For each row, this function performs a left shift over a series of contiguous
;; bytes.  Compute the framebuffer address of the right-most byte that is touched
;; in the first row
  addwf		PRODL, w, A		; WREG = r0x00 + PRODL - 1
  decf		WREG, w, A
  lfsr		0, _ledmtx_framebuffer	; FSR0 = _ledmtx_framebuffer
  addwf		FSR0L, f, A		;          + WREG
  btfsc		STATUS, C, A
  incf		FSR0H, f, A
  movlw		3			;          + (y *_ledmtx_config_stride)
  movf		PLUSW1, w, A
  mulwf		_ledmtx_config_stride, A
  movf		PRODL, w, A
  addwf		FSR0L, f, A
  movf		PRODH, w, A
  addwfc	FSR0H, f, A

;; `for (PRODL = h; PRODL != 0; --PRODL) {`
  movlw		5
  movff		PLUSW1, PRODL
@scroll_l_loop:
  movff		r0x00, PRODH		; PRODH = (w >> 3)
  bcf		STATUS, C, A
  clrf		WREG, A

@scroll_l_shift:			; `for (; PRODH !=0; --PRODH) {`
  rlcf		PLUSW0, f, A		; *(FSR0 + WREG) = *(FSR0 + WREG) << 1
  decfsz	WREG, w, A		; `decf` affects Carry bit; `decfsz` does not
  ; nop
  decfsz	PRODH, f, A
  bra		@scroll_l_shift		; `}`

;;; FSR0 += _ledmtx_config_stride
  movf		_ledmtx_config_stride, w, A
  addwf		FSR0L, f, A
  btfsc		STATUS, C, A
  incf		FSR0H, f, A

  decfsz	PRODL, f, A		; `}`
  bra		@scroll_l_loop

  movff		PREINC1, r0x00		; pop registers
  return

  end
