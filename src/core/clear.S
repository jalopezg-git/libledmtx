;
; clear.S - libledmtx core: clear framebuffer
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
  extern _ledmtx_config_height
  extern _ledmtx_config_stride
  extern _ledmtx_framebuffer

  global _ledmtx_clear

  code
; extern void ledmtx_clear(void)
_ledmtx_clear:
  lfsr		0, _ledmtx_framebuffer		; FSR0 points to _ledmtx_framebuffer
  movf		_ledmtx_config_height, w, A	; compute framebuffer size
  mulwf		_ledmtx_config_stride, A

@clear_loop:
  clrf		POSTINC0, A			; *FSR0++=0
  decf		PRODL, f, A			; PRODH:PRODL--
  btfss		STATUS, C, A
  decf		PRODH, f, A
  tstfsz	PRODH, A			; loop while PRODH:PRODL!=0
  bra		@clear_loop
  tstfsz	PRODL, A
  bra		@clear_loop
  return

  end
