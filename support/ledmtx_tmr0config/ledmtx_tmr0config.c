/*
 * ledmtx_tmr0config.c - compute TMR0H, TMR0L and T0CON values
 *
 * Copyright (C) 2011  Javier L. Gomez
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

#include <stdio.h>
#include <stdlib.h>

void usage(void)
{
  fprintf (stderr,
	   "ledmtx_tmr0config: compute TMR0H, TMR0L and T0CON values\n"
	   "Usage: ledmtx_tmr0config <hwheight> <hz> <osc_hz>\n"
	   "Arguments:\n"
	   "  <hwheight>        hardware height, see driver doc\n"
	   "  <hz>              vertrefresh hz, normally 50\n"
	   "  <osc_hz>          microcontroller osc hz\n");
}

int main(int argc, char **argv)
{
  unsigned int hwheight, hz, osc_hz;
  unsigned int isr_hz, tcy;
  unsigned char prescaler = 0x0f;
  
  if (argc != 4)
    {
      usage ();
      return 1;
    }
  hwheight = atoi (*++argv);
  hz = atoi (*++argv);
  osc_hz = atoi (*++argv);
  if (hwheight == 0 || hz == 0 || osc_hz == 0)
    {
      usage ();
      return 1;
    }
  
  osc_hz /= 4;
  isr_hz = hwheight * hz;
  for (tcy = osc_hz / isr_hz; tcy > 0x10000; tcy /= 2)
    {
      if (++prescaler & 0x08)
        {
	  fprintf (stderr, "error: unsupported config\n");
	  return 1;
	}
    }
  
  if (prescaler & 0x08)
    prescaler = 0x08;
  tcy = 0x10000 - tcy;
  
  printf ("TMR0H:0x%02x\nTMR0L:0x%02x\nT0CON:0x%02x\n",
	  (unsigned char) ((tcy >> 8) & 0xff),
	  (unsigned char) (tcy & 0xff),
	  (unsigned char) (0x80 | (prescaler & 0x0f)));
  return 0;
}
