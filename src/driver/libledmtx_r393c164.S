;
; libledmtx_r393c164.S - libledmtx hardware driver
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
  include <ledmtx_r393c164.inc>

  ; udata
  extern _ledmtx_config_stride
  extern _ledmtx_config_height
  extern _ledmtx_framebuffer

  global _ledmtx_driver_row
  global _ledmtx_driver_init
  global _ledmtx_driver_vertrefresh

.udata_acs_ledmtx_driver	udata_acs
_ledmtx_driver_row	res	1

OUTBIT	macro	register, bit
  bcf	LEDMTX_R393C164_IOPORT, LEDMTX_R393C164_CDAT, A	; CDAT is NOT register<bit>
  btfss register, bit, A
  bsf	LEDMTX_R393C164_IOPORT, LEDMTX_R393C164_CDAT, A	;        _
  bsf	LEDMTX_R393C164_IOPORT, LEDMTX_R393C164_CCLK, A	; CCLK _| |_
  bcf	LEDMTX_R393C164_IOPORT, LEDMTX_R393C164_CCLK, A
  endm

  code
_ledmtx_driver_init:
  clrf _ledmtx_driver_row, A
  return

_ledmtx_driver_vertrefresh:
  lfsr		0, _ledmtx_framebuffer		; _ledmtx_framebuffer
  incf		_ledmtx_driver_row, w, A	; +(_ledmtx_driver_row+1)*_ledmtx_config_stride
  mulwf		_ledmtx_config_stride, A
  movf		PRODL, w, A
  addwf		FSR0L, f, A
  movf		PRODH, w, A
  addwfc	FSR0H, f, A
  movf		POSTDEC0, f, A			; -1 -> FSR0
  movf		_ledmtx_config_stride, w, A	; _ledmtx_config_stride -> WREG

  bcf		LEDMTX_R393C164_IOPORT, LEDMTX_R393C164_RENA, A

  tstfsz	_ledmtx_driver_row, A		; _ledmtx_driver_row==0?
  bra		@vertrefresh_rclk
  bsf		LEDMTX_R393C164_IOPORT, LEDMTX_R393C164_RRST, A	;        _
  bcf		LEDMTX_R393C164_IOPORT, LEDMTX_R393C164_RRST, A	; RRST _| |_
  bra		@vertrefresh_loop

@vertrefresh_rclk:
  bsf		LEDMTX_R393C164_IOPORT, LEDMTX_R393C164_RCLK, A	;        _
  bcf		LEDMTX_R393C164_IOPORT, LEDMTX_R393C164_RCLK, A	; RCLK _| |_

@vertrefresh_loop:
  OUTBIT	INDF0, 0			; output byte
  OUTBIT	INDF0, 1
  OUTBIT	INDF0, 2
  OUTBIT	INDF0, 3
  OUTBIT	INDF0, 4
  OUTBIT	INDF0, 5
  OUTBIT	INDF0, 6
  OUTBIT	POSTDEC0, 7

  decfsz	WREG, w, A			; loop while --WREG!=0
  bra		@vertrefresh_loop

  bsf		LEDMTX_R393C164_IOPORT, LEDMTX_R393C164_RENA, A

  incf		_ledmtx_driver_row, f, A	; _ledmtx_driver_row++
  movf		_ledmtx_config_height, w, A
  cpfslt	_ledmtx_driver_row, A		; if _ledmtx_driver_row==_ledmtx_config_height
  clrf		_ledmtx_driver_row, A		; 0 -> _ledmtx_driver_row
  return

  end
