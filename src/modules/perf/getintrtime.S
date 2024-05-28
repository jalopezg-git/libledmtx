;
; getintrtime.S - return the number of ticks took by the ISR to complete
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
  extern _ledmtx_config_tmr0h
  extern _ledmtx_config_tmr0l
  extern _ledmtx_perf_tmr0

  global _ledmtx_perf_getintrtime

  code
;; extern unsigned int ledmtx_perf_getintrtime(void)
_ledmtx_perf_getintrtime:
  banksel	_ledmtx_perf_tmr0

;; The `TMR0(H|L)` registers are set to the value of `_ledmtx_config_tmr0(h|l)`
;; at the beginning of the ISR; `_ledmtx_perf_tmr0` is set at the end before the
;; `retfie` instruction, thus return (_ledmtx_perf_tmr0
;;	- _ledmtx_config_tmr0h:_ledmtx_config_tmr0l)
  movff		_ledmtx_config_tmr0l, WREG
  subwf		_ledmtx_perf_tmr0+0, w
  movwf		POSTDEC1, A
  movff		_ledmtx_config_tmr0h, WREG
  subwfb	_ledmtx_perf_tmr0+1, w
  movwf		PRODL, A
  movf		PREINC1, w, A
  return

  end
