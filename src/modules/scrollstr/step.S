;
; step.S - libledmtx scrollstr module: scroll left and put masked char
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

  extern _ledmtx_scroll_l
  extern _ledmtx_putchar
  extern _ledmtx_scrollstr_call_fsr0

  global _ledmtx_scrollstr_step

  code
; extern void ledmtx_scrollstr_step(__data struct ledmtx_scrollstr_s *)
_ledmtx_scrollstr_step:
  movff		FSR2H, POSTDEC1		; push FSR2x
  movff		FSR2L, POSTDEC1
  movlw		3			; argument -> FSR2
  movff		PLUSW1, FSR2L
  movlw		4
  movff		PLUSW1, FSR2H

  movlw		5			; FSR2+5 -> FSR2
  addwf		FSR2L, f, A
  btfsc		STATUS, C, A
  incf		FSR2H, f, A

  movff		_ledmtx_font_sz_h, POSTDEC1
  movff		POSTINC2, POSTDEC1	; push args
  movff		POSTINC2, POSTDEC1
  movff		POSTINC2, POSTDEC1
  call		_ledmtx_scroll_l
  movlw		4
  addwf		FSR1L, f, A

  movff		POSTINC2, FSR0L		; str -> FSR0
  movff		POSTINC2, FSR0H
  movf		POSTINC2, w, A		; i -> WREG
  tstfsz	PLUSW0, A		; str[i]==0?
  bra		@step_putchar

  decfsz	POSTINC2, f, A		; --charoff==0?
  bra		@step_ret

  movf		POSTINC2, f, A
  movlw		4			; push arg
  movff		PLUSW1, POSTDEC1
  movff		PLUSW1, POSTDEC1
  movff		FSR2H, FSR0H		; call end
  movff		FSR2L, FSR0L
  call		_ledmtx_scrollstr_call_fsr0
  movf		PREINC1, f, A
  movf		PREINC1, f, A
  bra		@step_ret

@step_putchar:
  tstfsz	INDF2, A		; charoff==0?
  bra		@step_do_putchar

  incf		POSTINC2, f, A		; charoff++
  movlw		0x80			; 0x80 -> mask
  movwf		INDF2, A
  bra		@step_ret

@step_do_putchar:
  movff		PLUSW0, POSTDEC1	; push arg c
  movlw		-5
  movff		PLUSW2, POSTDEC1	; push arg y
  movlw		-6
  movff		PLUSW2, PRODL
  movlw		-4
  movf		PLUSW2, w, A
  addwf		PRODL, f, A
  movf		INDF2, w, A
  subwf		PRODL, f, A
  movff		PRODL, POSTDEC1		; push arg w+x-charoff
  movlw		1
  movff		PLUSW2, POSTDEC1	; push arg mask
  ; movlw	1
  call		_ledmtx_putchar
  movlw		4
  addwf		FSR1L, f, A

  movf		_ledmtx_font_sz_w, w, A	; charoff<_ledmtx_font_sz_w?
  cpfslt	INDF2, A
  bra		@step_getchar

  incf		POSTINC2, f, A		; charoff++
  rrncf		INDF2, f, A		; shift mask
  bra		@step_ret

@step_getchar:
  movlw		-3			; str -> FSR0
  movff		PLUSW2, FSR0L
  movlw		-2
  movff		PLUSW2, FSR0H
  movlw		-1			; i++
  incf		PLUSW2, f, A
  movf		PLUSW2, w, A
  tstfsz	PLUSW0, A		; str[i]==0?
  bra		@step_getcharnz

  movlw		-6			; w -> charoff
  movff		PLUSW2, INDF2
  bra		@step_ret

@step_getcharnz:
  clrf		INDF2, A		; 0 -> charoff

@step_ret:
  movff		PREINC1, FSR2L		; pop FSR2x
  movff		PREINC1, FSR2H
  return

  end
