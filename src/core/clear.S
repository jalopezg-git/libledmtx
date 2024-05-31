;
; clear.S - libledmtx core: clear framebuffer
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

  ; udata
  extern _ledmtx_config_height
  extern _ledmtx_config_stride

  global _ledmtx_clear

	code
;; extern void ledmtx_clear(void)
_ledmtx_clear:
  LOAD_BUFADDR_IN_FSR0	_ledmtx_backbuffer
  movf		_ledmtx_config_height, w, A	; PRODH:PRODL holds framebuffer size in bytes
  mulwf		_ledmtx_config_stride, A

;; Essentially equivalent to a `memset(&ledmtx_framebuffer, 0, ledmtx_config_height * ledmtx_config_stride)`
@clear_loop:
  clrf		POSTINC0, A			; *(FSR0++) = 0
  decf		PRODL, f, A			; PRODH:PRODL--
  btfss		STATUS, C, A
  decf		PRODH, f, A
  tstfsz	PRODH, A			; while PRODH:PRODL != 0
  bra		@clear_loop
  tstfsz	PRODL, A
  bra		@clear_loop
  return

  end
