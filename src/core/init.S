;
; init.S - libledmtx core initialisation
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
  include <ledmtx_load_bufaddr.inc>

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
;; extern void ledmtx_init(unsigned char flags, unsigned char width, unsigned char height,
;;                         unsigned char tmr0h, unsigned char tmr0l, unsigned char t0con) __wparam
_ledmtx_init:
  movwf	POSTDEC1, A

;; Set initial values for `_ledmtx_config_xxx`
  movlw	2
  movff	PLUSW1, _ledmtx_config_width
  movf	PLUSW1, w, A			; _ledmtx_config_stride = ceil(_ledmtx_config_width / 8)
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

;; Initialize `_ledmtx_(front|back)buffer` to point to _ledmtx_framebuffer
#if (LEDMTX_HAVE_DOUBLE_BUFFER == 1)
  movlw	low(_ledmtx_framebuffer)
  movff	WREG, _ledmtx_frontbuffer+0
  movff	WREG, _ledmtx_backbuffer+0
  movlw	high(_ledmtx_framebuffer)
  movff	WREG, _ledmtx_frontbuffer+1
  movff	WREG, _ledmtx_backbuffer+1
  CLEAR_SWAPBUFFERS_ON_VSYNC
#endif

;; Initialize viewport to `<_ledmtx_config_stride> X <_ledmtx_config_height>` at (0,0)
#if (LEDMTX_HAVE_VIEWPORT == 1)
  movlw	0
  movwf	_ledmtx_viewport_xoff, A
  movwf	_ledmtx_viewport_y, A
  movff	_ledmtx_config_stride, _ledmtx_viewport_stride
  movff	_ledmtx_config_height, _ledmtx_viewport_height
#endif

;; Initialize driver and modules
  call	_ledmtx_driver_init
  call	_ledmtx_modules_init

;; Clear framebuffer if `(flags & LEDMTX_INIT_CLEAR)`
  movf	PREINC1, w, A
  btfss	WREG, 0, A
  bra	@init_skip_clr

  movwf	POSTDEC1, A
  call	_ledmtx_clear
  movf	PREINC1, w, A

@init_skip_clr:
;; Setup TMR0 if `(flags & LEDMTX_INIT_TMR0)`
  btfss	WREG, 1, A
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
