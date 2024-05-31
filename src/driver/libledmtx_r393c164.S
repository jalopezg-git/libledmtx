;
; libledmtx_r393c164.S - libledmtx 'r393c164' display hardware driver
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
  include <ledmtx_load_bufaddr.inc>
  include _P18FXXX_INC
  include <ledmtx_r393c164.inc>

  ; udata
  extern _ledmtx_config_stride
  extern _ledmtx_config_height

  global _ledmtx_driver_row
  global _ledmtx_driver_init
  global _ledmtx_driver_vertrefresh

.udata_acs_ledmtx_driver	udata_acs
_ledmtx_driver_row	res	1

;; Output the 1's complement of `register<bit>` to the LEDMTX_R393C164_CDAT pin,
;; after which the LEDMTX_R393C164_CCLK pin is pulsed.
OUTBIT	macro	register, bit
  andwf	LEDMTX_R393C164_IOPORT, f, A			; set both `CDAT` and `CCLK` to 0
  btfss	register, bit, A				; `CDAT = ~register<bit>`
  bsf	LEDMTX_R393C164_IOPORT, LEDMTX_R393C164_CDAT, A	;        _
  bsf	LEDMTX_R393C164_IOPORT, LEDMTX_R393C164_CCLK, A	; CCLK _|
  endm

  code
_ledmtx_driver_init:
  clrf _ledmtx_driver_row, A
  return

;; The display is multiplexed, i.e., only one row is driven at a time.
;; Shift out the (negated) value of all bits in the selected row and advance to
;; the next row.  This is usually called as part of a timer ISR.
_ledmtx_driver_vertrefresh:
;; Compute the framebuffer address of the start of the next row
  LOAD_BUFADDR_IN_FSR0	_ledmtx_frontbuffer	; FSR0 = _ledmtx_frontbuffer
  incf		_ledmtx_driver_row, w, A	;          + (_ledmtx_driver_row + 1) * _ledmtx_config_stride
  mulwf		_ledmtx_config_stride, A
  movf		PRODL, w, A
  addwf		FSR0L, f, A
  movf		PRODH, w, A
  addwfc	FSR0H, f, A
  movf		POSTDEC0, f, A			;          - 1
  movff		_ledmtx_config_stride, PRODL	; PRODL = _ledmtx_config_stride

;; Disable row selection temporarily, to avoid glitches while data is shifted out
  bcf		LEDMTX_R393C164_IOPORT, LEDMTX_R393C164_RENA, A

; TODO: control flow may be simplified using `movf` + `bz`, but test fails for some reason
  tstfsz	_ledmtx_driver_row, A		; if (_ledmtx_driver_row == 0)
  bra		@vertrefresh_rclk
  bsf		LEDMTX_R393C164_IOPORT, LEDMTX_R393C164_RRST, A	;	        _
  bcf		LEDMTX_R393C164_IOPORT, LEDMTX_R393C164_RRST, A	;	 RRST _| |_
  bra		@vertrefresh_loop_prologue
@vertrefresh_rclk:
  bsf		LEDMTX_R393C164_IOPORT, LEDMTX_R393C164_RCLK, A	;        _
  bcf		LEDMTX_R393C164_IOPORT, LEDMTX_R393C164_RCLK, A	; RCLK _| |_

@vertrefresh_loop_prologue:
  movlw		~((1 << LEDMTX_R393C164_CDAT) | (1 << LEDMTX_R393C164_CCLK))	; Setup mask used in OUTBIT
@vertrefresh_loop:				; `do {`
  OUTBIT	INDF0, 0			; 	shift out *(FSR0)
  OUTBIT	INDF0, 1
  OUTBIT	INDF0, 2
  OUTBIT	INDF0, 3
  OUTBIT	INDF0, 4
  OUTBIT	INDF0, 5
  OUTBIT	INDF0, 6
  OUTBIT	POSTDEC0, 7
  decfsz	PRODL, f, A			; `} while (--PRODL != 0)`
  bra		@vertrefresh_loop

;; Re-enable row selection
  bsf		LEDMTX_R393C164_IOPORT, LEDMTX_R393C164_RENA, A

  incf		_ledmtx_driver_row, f, A	; _ledmtx_driver_row++
  movf		_ledmtx_config_height, w, A
  cpfslt	_ledmtx_driver_row, A		; if (_ledmtx_driver_row == _ledmtx_config_height)
  clrf		_ledmtx_driver_row, A		; 	_ledmtx_driver_row = 0
  return

  end
