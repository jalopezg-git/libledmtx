;
; step.S - Scroll area to left and draw masked character
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
  extern _ledmtx_font_sz_w
  extern _ledmtx_font_sz_h

  extern _ledmtx_scroll_l
  extern _ledmtx_putchar
  extern _ledmtx_scrollstr_call_fsr0

  global _ledmtx_scrollstr_step

  code
;; extern void ledmtx_scrollstr_step(__data struct ledmtx_scrollstr_desc *desc)
_ledmtx_scrollstr_step:
  movff		FSR2H, POSTDEC1		; push FSR2x
  movff		FSR2L, POSTDEC1
  movlw		3			; FSR2 = desc
  movff		PLUSW1, FSR2L
  movlw		4
  movff		PLUSW1, FSR2H

  movlw		5			; FSR2 = FSR2 + 5
  addwf		FSR2L, f, A
  btfsc		STATUS, C, A
  incf		FSR2H, f, A

;; Call `ledmtx_scroll_l()`
  movff		_ledmtx_font_sz_h, POSTDEC1
  movff		POSTINC2, POSTDEC1
  movff		POSTINC2, POSTDEC1
  movff		POSTINC2, POSTDEC1
  call		_ledmtx_scroll_l
  movlw		4
  addwf		FSR1L, f, A

  movff		POSTINC2, FSR0L		; FSR0 = desc->str
  movff		POSTINC2, FSR0H
  movf		POSTINC2, w, A		; WREG = desc->i
  tstfsz	PLUSW0, A		; if (desc->str[i] != '\0') goto @step_putchar
  bra		@step_putchar

;; If at the end of the string, continue scrolling until the text disappears
;; (`charoff` holds the number of remaining steps; see line 134)
  decfsz	POSTINC2, f, A		; if (--(desc->charoff) == 0)
  bra		@step_ret

;; Indirect call to `desc->end()`
  movf		POSTINC2, f, A
  movlw		4
  movff		PLUSW1, POSTDEC1
  movff		PLUSW1, POSTDEC1
  movff		FSR2H, FSR0H
  movff		FSR2L, FSR0L
  call		_ledmtx_scrollstr_call_fsr0
  movf		PREINC1, f, A
  movf		PREINC1, f, A
  bra		@step_ret

;; Draw (part of) the next character
@step_putchar:
  tstfsz	INDF2, A		; if (desc->charoff == 0)
  bra		@step_do_putchar

  incf		POSTINC2, f, A		; 	desc->charoff++
  movlw		0x80			; 	desc->mask = 0x80
  movwf		INDF2, A
  bra		@step_ret

@step_do_putchar:
;; Call `ledmtx_putchar()`
  movff		PLUSW0, POSTDEC1	; push arg `c`
  movlw		-5
  movff		PLUSW2, POSTDEC1	; push arg `y`
  movlw		-6
  movff		PLUSW2, PRODL
  movlw		-4
  movf		PLUSW2, w, A
  addwf		PRODL, f, A
  movf		INDF2, w, A
  subwf		PRODL, f, A
  movff		PRODL, POSTDEC1		; push arg `x`, i.e. `desc->w + desc->x - desc->charoff`
  movlw		1
  movff		PLUSW2, POSTDEC1	; push arg `mask`
  ; movlw	1			; `op`
  call		_ledmtx_putchar
  movlw		4
  addwf		FSR1L, f, A

;; Still putting the same character, i.e. `desc->charoff < _ledmtx_font_sz_w`?
;; Prepare `charoff` and `mask` for the next call to `ledmtx_putchar()`;
;; otherwise, jump to the next character.
  movf		_ledmtx_font_sz_w, w, A
  cpfslt	INDF2, A
  bra		@step_getchar

  incf		POSTINC2, f, A		; desc->charoff++
  rrncf		INDF2, f, A		; desc->mask = (desc->mask << 1)
  bra		@step_ret

@step_getchar:
  movlw		-3			; FSR0 = desc->str
  movff		PLUSW2, FSR0L
  movlw		-2
  movff		PLUSW2, FSR0H
  movlw		-1			; desc->i++
  incf		PLUSW2, f, A

  movf		PLUSW2, w, A
  tstfsz	PLUSW0, A		; if (desc->str[i] == '\0')
  bra		@step_getcharnz
  movlw		-6			; 	desc->charoff = desc->w
  movff		PLUSW2, INDF2
  bra		@step_ret

@step_getcharnz:			; else
  clrf		INDF2, A		; 	desc->charoff = 0

@step_ret:
  movff		PREINC1, FSR2L		; pop FSR2x
  movff		PREINC1, FSR2H
  return

  end
