;
; setviewport.S - libledmtx core: set alternative viewport (requires driver support)
;
; Copyright (C) 2011-2024  Javier Lopez-Gomez
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
  extern _ledmtx_config_width
  extern _ledmtx_config_height
  extern _ledmtx_viewport_y
  extern _ledmtx_viewport_height
  extern _ledmtx_viewport_xoff
  extern _ledmtx_viewport_stride

  extern _ledmtx_driver_init

  global _ledmtx_setviewport

  code
;; extern void ledmtx_setviewport(unsigned char x, unsigned char y,
;;                                 unsigned char width, unsigned char height)
_ledmtx_setviewport:
;; Bail out if `(x + width) > _ledmtx_config_width || (y + height) > _ledmtx_config_height`
  movlw		1
  movff		PLUSW1, PRODL
  movlw		3
  movf		PLUSW1, w, A
  addwf		PRODL, w, A
  subwf		_ledmtx_config_width, w, A
  bn		@invalid_value
  movlw		2
  movff		PLUSW1, PRODL
  movlw		4
  movf		PLUSW1, w, A
  addwf		PRODL, w, A
  subwf		_ledmtx_config_height, w, A
  bn		@invalid_value

  bcf		INTCON, GIE, A	; Temporarily disable interrupts

  movlw		2
  movff		PLUSW1, _ledmtx_viewport_y
  movlw		4
  movff		PLUSW1, _ledmtx_viewport_height

;; _ledmtx_viewport_xoff = x >> 3
  movlw		1
  rrncf		PLUSW1, f, A
  rrncf		PLUSW1, f, A
  rrncf		PLUSW1, w, A
  andlw		0x1f
  movwf		_ledmtx_viewport_xoff, A
;; _ledmtx_viewport_stride = width >> 3
  movlw		3
  rrncf		PLUSW1, f, A
  rrncf		PLUSW1, f, A
  rrncf		PLUSW1, w, A
  andlw		0x1f
  movwf		_ledmtx_viewport_stride, A

  call		_ledmtx_driver_init
  bsf		INTCON, GIE, A
  retlw		1
@invalid_value:
  retlw		0

  end
