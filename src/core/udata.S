;
; udata.S - libledmtx core: udata section
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

  global _ledmtx_font
  global _ledmtx_font_sz_w
  global _ledmtx_font_sz_h
  global _ledmtx_font_mask
  global _ledmtx_config_width
  global _ledmtx_config_height
  global _ledmtx_config_stride
  global _ledmtx_config_tmr0h
  global _ledmtx_config_tmr0l
  global _ledmtx_config_t0con

.udata_acs_ledmtx	udata_acs
_ledmtx_font		res 3	; The address in program memory of the current font
_ledmtx_font_sz_w	res 1	; The width of a character (pixels)
_ledmtx_font_sz_h	res 1	; The height of a character (pixels)
_ledmtx_font_mask	res 1	; The bitmask of a character
_ledmtx_config_width	res 1	; The width of the framebuffer (pixels)
_ledmtx_config_height	res 1	; The height of the framebuffer (pixels)
_ledmtx_config_stride	res 1	; The length of a scanline (bytes)

; These are not required to be in the Access RAM as they are always accessed
; using `movff`.
.udata_ledmtx		udata
_ledmtx_config_tmr0h	res 1	; The value that is preloaded in TMR0H
_ledmtx_config_tmr0l	res 1	; The value that is preloaded in TMR0L
_ledmtx_config_t0con	res 1	; The T0CON that was used in the call to `ledmtx_init()`

  end
