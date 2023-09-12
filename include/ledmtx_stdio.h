/*
 * ledmtx_stdio.h - libledmtx stdio support header
 *
 * Copyright (C) 2011, 2023  Javier Lopez-Gomez
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

#ifndef __LEDMTX_STDIO_H__
#define __LEDMTX_STDIO_H__

extern unsigned char ledmtx_stdio_x;
extern unsigned char ledmtx_stdio_y;

/// Set the (x,y) as the coordinates for the next stdio call, e.g. `printf()`
#define LEDMTX_GOTO(x, y)       do { ledmtx_stdio_x = x; ledmtx_stdio_y = y; } while(0)

/// Set the (0,0) as the coordinates for the next stdio call
#define LEDMTX_HOME()           do { ledmtx_stdio_x = ledmtx_stdio_y = 0; } while(0)

#endif
