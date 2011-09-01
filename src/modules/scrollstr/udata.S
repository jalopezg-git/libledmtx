;
; udata.S - libledmtx scrollstr module: udata section
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

  global _ledmtx_scrollstr_bitmap
  global _ledmtx_scrollstr_vec

.udata_acs_ledmtx_scrollstr	udata_acs
_ledmtx_scrollstr_bitmap	res	1

.udata_ledmtx_scrollstr	udata
_ledmtx_scrollstr_vec	res	16

  end
