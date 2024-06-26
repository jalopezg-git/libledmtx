/*
 * ledmtx_core.h - libledmtx core header
 *
 * Copyright (C) 2011-2024  Javier Lopez-Gomez
 *
 * This program is free software; you can redistribute it and/or modify
 * it under the terms of the GNU Library General Public License as published by
 * the Free Software Foundation; either version 2 of the License, or
 * (at your option) any later version.
 *
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU Library General Public License for more details.
 *
 * You should have received a copy of the GNU Library General Public License
 * along with this program; if not, write to the Free Software
 * Foundation, Inc., 59 Temple Place - Suite 330, Boston, MA 02111-1307, USA
 */

#ifndef __LEDMTX_CORE_H__
#define __LEDMTX_CORE_H__

#include <pic18fregs.h>

#ifdef STACK_MODEL_LARGE
  #error Unsupported stack model
#endif

extern char ledmtx_driver_row;
extern char ledmtx_driver_vertrefresh;
extern char ledmtx_config_width;
extern char ledmtx_config_height;
extern char ledmtx_config_stride;
extern char ledmtx_config_tmr0h;
extern char ledmtx_config_tmr0l;
extern char ledmtx_config_t0con;

#define LEDMTX_BEGIN_MODULES_INIT \
  void ledmtx_modules_init(void) __naked {

#define LEDMTX_MODULE_INIT(module) \
  __asm call _ledmtx_ ## module ## _init __endasm;

#define LEDMTX_END_MODULES_INIT \
  __asm return __endasm;        \
  }

#ifndef __LEDMTX_R0REG_FSR2_H__
  #define LEDMTX_R0_STORE_FSR2
  #define LEDMTX_R0_RESTORE_FSR2
#endif

#ifndef __LEDMTX_R0REG_TBLRD_H__
  #define LEDMTX_R0_STORE_TBLRD
  #define LEDMTX_R0_RESTORE_TBLRD
#endif

/// Declare a framebuffer of size `size` (in bytes)
#define LEDMTX_FRAMEBUFFER_RES(size) \
  unsigned char ledmtx_framebuffer[size];

/// Declare `_name` as backing storage for the backbuffer.  Typically, this is
/// combined with a call to `ledmtx_setbackbuffer(_name)` somewhere else.
#define LEDMTX_DECLARE_BACKBUFFER(_name) \
  unsigned char _name[sizeof(ledmtx_framebuffer)];

extern __data unsigned char *ledmtx_frontbuffer; /// A pointer to the frontbuffer
extern __data unsigned char *ledmtx_backbuffer;  /// A pointer to the backbuffer

/// Prologue for the ISR of a timer interrupt (usually Timer0).  Such ISR is
/// responsible for carrying out the display vertical refresh.
#define LEDMTX_BEGIN_ISR                              \
  __asm bcf   _INTCON, 2, 0 __endasm; /* TMR0IF, A */ \
  __asm movff _ledmtx_config_tmr0h, _TMR0H __endasm;  \
  __asm movff _ledmtx_config_tmr0l, _TMR0L __endasm;  \
  __asm movff _STATUS, _POSTDEC1 __endasm;            \
  __asm movwf _POSTDEC1, 0 __endasm; /* A */          \
  /* __asm movff _BSR, _POSTDEC1 __endasm; */         \
  __asm movff _PRODH, _POSTDEC1 __endasm;             \
  __asm movff _PRODL, _POSTDEC1 __endasm;             \
  __asm movff _FSR0H, _POSTDEC1 __endasm;             \
  __asm movff _FSR0L, _POSTDEC1 __endasm;

#ifndef LEDMTX_RETFIE
  #define LEDMTX_RETFIE           __asm retfie __endasm;
#endif

/// Epilogue of the ISR
#define LEDMTX_END_ISR                         \
  __asm movff _PREINC1, _FSR0L __endasm;       \
  __asm movff _PREINC1, _FSR0H __endasm;       \
  __asm movff _PREINC1, _PRODL __endasm;       \
  __asm movff _PREINC1, _PRODH __endasm;       \
  /* __asm movff _PREINC1, _BSR __endasm; */   \
  __asm movf  _PREINC1, w, 0 __endasm; /* A */ \
  __asm movff _PREINC1, _STATUS __endasm;      \
  LEDMTX_RETFIE

/// Issue a call to the driver-specific routine for vertical refresh
#define LEDMTX_VERTREFRESH        __asm call _ledmtx_driver_vertrefresh __endasm;

/// Begin of a section of code that is only executed for the first scanline, i.e.
/// once for each full scan
#define LEDMTX_BEGIN_R0                                \
  __asm tstfsz _ledmtx_driver_row, 0 __endasm; /* A */ \
  __asm bra    @ledmtx_end_r0 __endasm;                \
  LEDMTX_R0_STORE_FSR2                                 \
  LEDMTX_R0_STORE_TBLRD

/// Mark the end of a `LEDMTX_BEGIN_R0` section
#define LEDMTX_END_R0             \
  LEDMTX_R0_RESTORE_TBLRD         \
  LEDMTX_R0_RESTORE_FSR2          \
  __asm @ledmtx_end_r0: __endasm;

/* Flags for `ledmtx_init()` */
#define LEDMTX_INIT_CLEAR         0x01         ///< Clear the framebuffer
#define LEDMTX_INIT_TMR0          0x02         ///< Initialize Timer 0

/* Constants that may be used as the `op` argument in `ledmtx_putchar()` */
#define LEDMTX_PUTCHAR_CPY        0x00         ///< Copy character bits
#define LEDMTX_PUTCHAR_IOR        0x01         ///< Bitwise OR

extern unsigned char ledmtx_font_sz_w; /// Width of the current font (pixels)
extern unsigned char ledmtx_font_sz_h; /// Height of the current font (pixels)
extern unsigned char ledmtx_font_mask; /// The character mask

/// \brief  Initialize the library and setup the display driver.
/// In a double buffer build, `ledmtx_(front|back)buffer` shall be initialized
/// to point to `ledmtx_framebuffer` by default.  This makes it possible to use
/// a double-buffer build without any changes to user code.
/// The user is responsible for calling `ledmtx_setbackbuffer()` to set an
/// alternative buffer.
///
/// \param flags A combination of one or more `LEDMTX_INIT_xxx` constants
/// \param width The width of the framebuffer in pixels
/// \param height The height of the framebuffer in pixels
/// \param tmr0h If `LEDMTX_INIT_TMR0` is specified in `flags`, the value used
///              to preload TMR0H
/// \param tmr0l If `LEDMTX_INIT_TMR0` is specified in `flags`, the value used
///              to preload TMR0L
/// \param T0C0N The value to be copied to the Timer 0 configuration register
extern void ledmtx_init(unsigned char flags, unsigned char width, unsigned char height,
                        unsigned char tmr0h, unsigned char tmr0l, unsigned char t0con) __wparam;

/// \brief  Set the viewport, i.e. the rectangle of pixels visible on the physical device.
/// This enables the allocation of framebuffer larger than the actual display.  The initial
/// viewport set by `ledmtx_init()` matches the geometry of the framebuffer.
/// \param x The (x) coordinate; should be a multiple of 8.
/// \param y The (y) coordinate
/// \param width The width of the visible area; should be a multiple of 8.
/// \param height The height of the visible area
/// \return 1 on success; 0 otherwise
extern char ledmtx_setviewport(unsigned char x, unsigned char y,
                               unsigned char width, unsigned char height);

/// Clear the framebuffer
extern void ledmtx_clear(void);

/// Set the value of a pixel
extern void ledmtx_putpixel(unsigned char x, unsigned char y, unsigned char val);

/// Set the current font for text operations
extern void ledmtx_setfont(__far void (*font)(void));

/// Put a character using the current font
/// \param op One of the constants `LEDMTX_PUTCHAR_xxx`
/// \param mask The mask to apply for each of the scanlines.  This can be used
///             to mask out parts of a glyph
/// \param x The (x) coordinate
/// \param y The (y) coordinate
/// \param c The character
extern void ledmtx_putchar(unsigned char op, unsigned char mask, unsigned char x, unsigned char y,
                           char c) __wparam;

/// Put a string of characters.  Characters that are not fully visible are cropped
/// \param x The (x) coordinate
/// \param y The (y) coordinate
/// \param str A pointer to the first character of a NUL-terminated string
extern void ledmtx_putstr(unsigned char x, unsigned char y, __data char *str);

/// Scroll left a region of size w X h, located at (x, y).  `x` and `w` should
/// be a multiple of 8
extern void ledmtx_scroll_l(unsigned char x, unsigned char y, unsigned char w, unsigned char h);

/// Scroll right a region of size w X h, located at (x, y).  `x` and `w` should
/// be a multiple of 8
extern void ledmtx_scroll_r(unsigned char x, unsigned char y, unsigned char w, unsigned char h);

/// On a build that supports double buffer, set the address of the backbuffer, i.e.
/// the buffer written to by most other operations, e.g. by `ledmtx_putchar()`.
/// Once the backbuffer is done, `ledmtx_swapbuffers()` can be called to swap the
/// front and the back buffer.
///
/// \param buf Address of the backbuffer
extern void ledmtx_setbackbuffer(__data unsigned char *buf);

/// Queue a swap of front and back buffers on the next vertical sync
extern void ledmtx_swapbuffers_on_vsync(void);

/// Immediately swap the front and the backbuffer.  If a swap was queued on vsync,
/// it is cancelled.  The user is responsible for clearing the acquired backbuffer
/// before calling any other routine on it.
/// Interrupts are temporarily disabled given that another call to `ledmtx_swapbuffers()`
/// may happen from ISR.
extern void ledmtx_swapbuffers(void);

/// Conditionally swap front and back buffers if the action was previously queued
/// via `ledmtx_swapbuffers_on_vsync()`.  This is intended to be placed in the
/// R0 section of ISR, i.e.
/// ```
/// LEDMTX_BEGIN_R0
///   ledmtx_swapbuffers_if_queued();
/// LEDMTX_END_R0
/// ```
#define ledmtx_swapbuffers_if_queued()		 \
  __asm btfss _RCON, 1, 0 __endasm; /* POR, A */ \
  __asm call _ledmtx_swapbuffers __endasm;

#endif
