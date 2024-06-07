; -*- Asm -*-
; This file provides useful macros to initialize common values used in all tests.

  radix dec

  extern _ledmtx_config_width
  extern _ledmtx_config_height
  extern _ledmtx_config_stride
  extern _ledmtx_config_tmr0h
  extern _ledmtx_config_tmr0l
  extern _ledmtx_frontbuffer
  extern _ledmtx_backbuffer
  extern _ledmtx_viewport_y
  extern _ledmtx_viewport_height
  extern _ledmtx_viewport_xoff
  extern _ledmtx_viewport_stride

  extern _ledmtx_font
  extern _ledmtx_font_sz_w
  extern _ledmtx_font_sz_h
  extern _ledmtx_font_mask
  extern _ledmtx_font5x7

TEST_CASE_PROLOGUE	macro fb_width, fb_height
  movlw		fb_width
  movwf		_ledmtx_config_width, a
  movlw		fb_height
  movwf		_ledmtx_config_height, a
  movlw		(fb_width >> 3)
  movwf		_ledmtx_config_stride, a
#if (LEDMTX_HAVE_DOUBLE_BUFFER == 1)
  movlw	low(_ledmtx_framebuffer)
  movff	WREG, _ledmtx_frontbuffer+0
  movff	WREG, _ledmtx_backbuffer+0
  movlw	high(_ledmtx_framebuffer)
  movff	WREG, _ledmtx_frontbuffer+1
  movff	WREG, _ledmtx_backbuffer+1
  bsf		RCON, POR, A
#endif
#if (LEDMTX_HAVE_VIEWPORT == 1)
  movlw	0
  movwf	_ledmtx_viewport_xoff, A
  movwf	_ledmtx_viewport_y, A
  movff	_ledmtx_config_stride, _ledmtx_viewport_stride
  movff	_ledmtx_config_height, _ledmtx_viewport_height
#endif

  movlw		0xAA
  movff		WREG, _ledmtx_config_tmr0h
  movlw		0xBB
  movff		WREG, _ledmtx_config_tmr0l
  endm

USE_DEFAULT_FONT	macro
  movlw		low(_ledmtx_font5x7)
  movwf		_ledmtx_font+0, a
  movlw		high(_ledmtx_font5x7)
  movwf		_ledmtx_font+1, a
  movlw		upper(_ledmtx_font5x7)
  movwf		_ledmtx_font+2, a
  movlw		5
  movwf		_ledmtx_font_sz_w, a
  movlw		7
  movwf		_ledmtx_font_sz_h, a
  movlw		0xf8
  movwf		_ledmtx_font_mask, a
  endm
