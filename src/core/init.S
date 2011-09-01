;
; init.S - libledmtx core initialisation
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
  extern _ledmtx_config_width
  extern _ledmtx_config_height
  extern _ledmtx_config_stride
  extern _ledmtx_config_tmr0h
  extern _ledmtx_config_tmr0l
  extern _ledmtx_config_t0con

  extern _ledmtx_driver_init
  extern _ledmtx_modules_init
  extern _ledmtx_clear

  global _ledmtx_init

  code
; extern void ledmtx_init(unsigned char, unsigned char, unsigned char, unsigned char, unsigned char, unsigned char) __wparam
_ledmtx_init:
  movwf	POSTDEC1, A

  movlw	2
  movff	PLUSW1, _ledmtx_config_width
  movf	PLUSW1, w, A			; compute _ledmtx_config_stride
  rrncf	WREG, w, A
  rrncf	WREG, w, A
  rrncf	WREG, w, A
  andlw	0x1f
  movwf	_ledmtx_config_stride, A
  movf	_ledmtx_config_width, w, A
  andlw	0x07
  bz	$+4
  incf	_ledmtx_config_stride, f, A
  movlw	3
  movff	PLUSW1, _ledmtx_config_height
  movlw	4
  movff	PLUSW1, _ledmtx_config_tmr0h
  movlw	5
  movff	PLUSW1, _ledmtx_config_tmr0l
  movlw	6
  movff	PLUSW1, _ledmtx_config_t0con

  call	_ledmtx_driver_init
  call	_ledmtx_modules_init
  movf	PREINC1, w, A

  btfss	WREG, 0, A			; clear framebuffer?
  bra	@init_skip_clr

  movwf	POSTDEC1, A
  call	_ledmtx_clear
  movf	PREINC1, w, A

@init_skip_clr:
  btfss	WREG, 1, A			; config TMR0?
  bra	@init_skip_t0

  bsf	RCON, IPEN, A
  movlw	0xe0
  iorwf	INTCON, f, A
  bcf	INTCON, TMR0IF, A
  bcf	INTCON2, TMR0IP, A
  movff	_ledmtx_config_tmr0h, TMR0H
  movff	_ledmtx_config_tmr0l, TMR0L
  movff	_ledmtx_config_t0con, T0CON

@init_skip_t0:
  return

  end
