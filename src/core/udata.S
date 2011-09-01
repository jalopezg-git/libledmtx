;
; udata.S - libledmtx core: udata section
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
_ledmtx_font		res 3
_ledmtx_font_sz_w	res 1
_ledmtx_font_sz_h	res 1
_ledmtx_font_mask	res 1
_ledmtx_config_width	res 1
_ledmtx_config_height	res 1
_ledmtx_config_stride	res 1
_ledmtx_config_tmr0h	res 1
_ledmtx_config_tmr0l	res 1
_ledmtx_config_t0con	res 1

  end
