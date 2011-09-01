;
; init.S - libledmtx perf module: initialisation
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
  extern _ledmtx_config_tmr0h
  extern _ledmtx_config_tmr0l
  extern _ledmtx_perf_tmr0
  extern _ledmtx_perf_intrtimelimit

  global _ledmtx_perf_init

  code
_ledmtx_perf_init:
  banksel	_ledmtx_perf_tmr0

  movff		_ledmtx_config_tmr0l, _ledmtx_perf_tmr0+0
  movff		_ledmtx_config_tmr0h, _ledmtx_perf_tmr0+1

  ; 0xffff-_ledmtx_config_tmr0h:_ledmtx_config_tmr0l -> _ledmtx_perf_intrtimelimit
  setf		_ledmtx_perf_intrtimelimit+0
  setf		_ledmtx_perf_intrtimelimit+1
  movf		_ledmtx_config_tmr0l, w, A
  subwf		_ledmtx_perf_intrtimelimit+0, f
  movf		_ledmtx_config_tmr0h, w, A
  subwfb	_ledmtx_perf_intrtimelimit+1, f
  return

  end
