# libledmtx: a library to drive LED dot-matrix displays written in PIC18 assembler

## Introduction
The libledmtx project was developed as a subproject of [p18clock](https://github.com/jalopezg-git/p18clock).
The library is completely written in PIC18 assembler and follows the call convention of the [SDCC](http://sdcc.sourceforge.net/) pic16 port.
Exported routines are meant to be called in by C code.
If you intend to issue calls from assembler, make sure that you follow the [pic16 port](http://sdcc.sourceforge.net/doc/sdccman.pdf) call convention.

![libledmtx driving a LED display](doc/demo.jpg)

## Building libledmtx
Before compiling the library make sure you have this installed:
- [gputils](https://gputils.sourceforge.io/) (the GNU PIC utilities), providing an assembler, librarian, and linker
- GNU make
- GNU gettext-runtime (provides `envsubst`)

To build libledmtx change to the directory where you extracted libledmtx and type
```bash
$ make

# To also compile the included examples
$ cd examples/
$ make
````

### Optional features
Additional features can be enabled / disabled by appending a list of `ENABLE_xxx=(0|1)` to the make command line, e.g. to build libledmtx with support for double buffer

```bash
$ make ENABLE_DOUBLE_BUFFER=1
```

#### Double buffer
libledmtx can be optionally built to support double buffer configuration.  To do so, you can append `ENABLE_DOUBLE_BUFFER=1` to the make command line.
Note that, in a double-buffer build, both the frontbuffer and backbuffer point to the same buffer by default.  See [`ledmtx_setbackbuffer()`](https://github.com/jalopezg-git/libledmtx/blob/master/include/ledmtx_core.h#L191) for details.

The feature is disabled by default.  Enabling it uses +4 additional bytes of RAM and makes each library function that touches a buffer +2 cycles slower, including the driver's vertical refresh routine.
This is, in general, acceptable for most applications though.

#### User-defined viewport
Set `ENABLE_VIEWPORT=1` to build a viewport-aware version of libledmtx, i.e. enable support for having a framebuffer larger than the physical display.
In this case, `libledmtx_init()` sets both, the framebuffer and initial viewport geometry.  The visible rectangle can be set as many times as needed via [`ledmtx_setviewport()`](https://github.com/jalopezg-git/libledmtx/blob/master/include/ledmtx_core.h#L147).

This feature is disabled by default.  When enabled, it uses +4 additional bytes of RAM in the access bank and makes the driver vertical refresh routine slightly slower (~5 cycles).

## Testing
The test suite is based on LLVM's lit.  Besides the dependencies required to build libledmtx, running tests also requires:
- llvm (provides `lit`)
- SDCC
- gpsim (The GNUPIC Simulator)

Tests can be simply run as follows:
```bash
$ lit tests/
```

## Installing
To install the library files change to the directory where you extracted libledmtx and run `make install` providing the path to the installation directories as in
```bash
$ make LIBDIR=/path/to/lib INCLUDEDIR=/path/to/include BINDIR=/path/to/bin install
```
E.g.,
```bash
$ make LIBDIR=$HOME/libledmtx/lib INCLUDEDIR=$HOME/libledmtx/include BINDIR=$HOME/libledmtx/bin install
```

## Hardware
Refer to docs in the [hardware](https://github.com/jalopezg-git/libledmtx/tree/master/doc/hardware/) directory.
The r393c164 driver requires a `ledmtx_r393c164.inc` configuration file that specifies which I/O port and pins to use for each output signal.
The used I/O port still should be manually configured writing to the `TRISx` / `ADCON1` registers.

## Examples
Some minimal examples are available in the [examples](https://github.com/jalopezg-git/libledmtx/tree/master/examples/) directory.
- [hello32x7](https://github.com/jalopezg-git/libledmtx/blob/master/examples/hello32x7/hello32x7.c), a simple program that prints "hello" using `printf()` (via the `STREAM_USER` stdio stream).
- [scrollstr32x7](https://github.com/jalopezg-git/libledmtx/blob/master/examples/scrollstr32x7/scrollstr32x7.c), that exercises the scrollstr module to asynchronously scroll a long text.

## How does it work?
libledmtx reserves part of the device's RAM as video memory (framebuffer).  The framebuffer is encoded left to right, top to bottom, 1bpp, i.e. each byte holds the value of 8 pixels.
The library has two distinct parts: a set of routines that alter the contents of the framebuffer, and the 'driver', which periodically reads (parts of) the framebuffer and changes the state of the appropriate MCU I/O pins in order to drive the simple video hardware (see [Hardware](https://github.com/jalopezg-git/libledmtx/#hardware)).
The driver is usually activated as part of the libledmtx interrupt service routine (ISR).

For the sake of efficiency, libledmtx tries to avoid using the `BSR` register where possible; thus, frequently accessed data is kept in the Access Bank.
Note that neither SDCC nor libledmtx support the PIC18 Extended Instruction Set (XINST).

![libledmtx overview](doc/overview.png)

libledmtx offers a [core](https://github.com/jalopezg-git/libledmtx/blob/master/include/ledmtx_core.h) set of routines (e.g. `ledmtx_putpixel()`, `ledmtx_setfont()`, or `ledmtx_putchar()`), and a set of modules that can be optionally linked in order to extend the core's capabilities.  Specifically, the following modules are supported:
- `scrollstr`: helper for character string scroll.  Allows automatic scroll of up to 8 strings from the ISR (see [`ledmtx_scrollstr_start()`](https://github.com/jalopezg-git/libledmtx/blob/master/include/ledmtx_scrollstr.h)).
- `perf`: measures time taken to service the libledmtx interrupt.

As of june 2024, libledmtx can work with multiple buffers (experimental).  In this configuration, the driver reads from the frontbuffer, whereas the framebuffer manipulation routines act on the backbuffer.  Once the backbuffer is ready, buffers can be swapped by using `ledmtx_swapbuffers()`.
In this case, buffers are pointed to by `ledmtx_frontbuffer` and `ledmtx_backbuffer`.  Given the additional level of indirection, all routines that need to load buffer addresses had the `lfsr` instruction replaced by two `movff` instructions, making them two cycles slower.  This overhead is, in general, acceptable for most of the purposes.

The addition of this feature also allows for changing the viewport, i.e. having a framebuffer larger than the actual display and only making part of it visible (TBD).

## Issues / limits
core:
- Maximum framebuffer size:	255x255
- Maximum size of a character:		8x255 (greater than VGA 8x14 is probably useless?)

r393c164 driver:
- High row count most probably looks dimmed, due to multiplexing.

scrollstr module:
- Auto-scroll vector capacity:		8 entries
- Maximum string length:		128 chars (including `\0`)

## Notes on linking against libledmtx
This section provides general guidelines to use and link libledmtx in your project.

1. Copy [`Makefile.template`](https://github.com/jalopezg-git/libledmtx/blob/master/doc/Makefile.template) to you project directory and tune it.
In particular, the value of the `P18FXXX`, `LIBDIR`, `INCLUDEDIR`, `O` and `modules` variables should be set accordingly.
`LIBDIR` and `INCLUDEDIR` should point to the libledmtx install directories.
`O` and `MODULES` list additional libledmtx objects and/or libraries that should be linked.
The `OBJECTS +=` line should list your project object files.

2. Write configuration file for the driver.
For the r393c164 driver, the file `ledmtx_r393c164.inc` (located in your project's directory), should look like this.  The I/O port and pins should be changed to reflect your wiring.
```
  LEDMTX_R393C164_IOPORT	equ	PORTA
  LEDMTX_R393C164_RCLK		equ	RA0
  LEDMTX_R393C164_RRST		equ	RA1
  LEDMTX_R393C164_RENA		equ	RA2
  LEDMTX_R393C164_CCLK		equ	RA3
  LEDMTX_R393C164_CDAT		equ	RA4
```

3. The `LEDMTX_BEGIN_MODULES_INIT` / `LEDMTX_END_MODULES_INIT` section is mandatory even if you are not using any module.
Header files for any module should be `#include`d before `ledmtx_core.h`.
A framebuffer (i.e., a small data memory area that stores the current frame) should be declared as follows:
```c
  LEDMTX_FRAMEBUFFER_RES(size)
```
where $size = height * ceil(width / 8)$.

4. If you are using TMR0 interrupts to call the driver-specific routine for vertical refresh, you should also include the following code:
```c
  DEF_INTLOW(low_int)
  DEF_HANDLER(SIG_TMR0, _tmr0_handler)
  END_DEF

  SIGHANDLERNAKED(_tmr0_handler)
  {
    LEDMTX_BEGIN_ISR
    LEDMTX_VERTREFRESH
    LEDMTX_END_ISR
  }
```

5. `ledmtx_init()` should be called on initialisation.  If you intend to use Timer0 to drive the display, you should compute proper values for the `TMR0H`, `TMR0L` and `T0CON` registers.
The `ledmtx_tmr0config` tool included in the [support/](https://github.com/jalopezg-git/libledmtx/tree/master/support/) directory automates this task.
Example:
```c
  // Initialize libledmtx for a 32x7 @ 50Hz display (assuming Fosc == 8MHz)
  // The last three arguments were computed by `$ ledmtx_tmr0config 7 50 8000000`
  ledmtx_init(LEDMTX_INIT_CLEAR | LEDMTX_INIT_TMR0, 32, 7, 0xe9, 0xae, 0x88)
```

## Contributing
Contributions either in the form of new features / fixes, hardware improvements, or documentation are welcome :+1:.
Feel free to open a pull request if you have something to say!
