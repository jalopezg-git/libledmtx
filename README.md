# libledmtx: a library for LED dot-matrix handling written in PIC18 assembler

## Introduction
The libledmtx project was developed as a subproject of p18clock.  libledmtx
drives LED dot matrix displays.  It has been completely written in PIC18
assembler and links against code compiled with the pic16 port of sdcc, but
it can be linked against assembler code as long as you follow sdcc call
convention.

## Building libledmtx
Before compiling the library make sure you have this installed:
- gputils
- make

To compile libledmtx change to the directory where you extracted libledmtx
and type `make`.  To compile the examples included, change to the examples
directory and type `make`.

## Installing
To install the library files change to the directory where you extracted
libledmtx and type `make LIBDIR=xxx INCLUDEDIR=xxx BINDIR=xxx install`.  Paths
should be absolute.  Example:
```
$ make LIBDIR=/usr/home/bart/projects/sdcc-pic16/libledmtx/lib
 INCLUDEDIR=/usr/home/bart/projects/sdcc-pic16/libledmtx/include
 BINDIR=/usr/home/bart/projects/sdcc-pic16/libledmtx/bin
```

## Hardware
Refer to docs in the hardware directory.  You may have to manually configure
I/O ports.  Normally this is done with TRISx/ADCON1.

## Limits
core:
- Framebuffer size:	255x255
- Font size limit:		8x255 (greater than VGA 8x14 is probably useless)
- For the `scroll_l()` and `scroll_r()` functions, the 3 least-significant-bits of `x` and `width` are ignored.

r393c164 driver:
- High row count probably looks dimmed, due to multiplexing.

scrollstr module:
- Auto scroll vector capacity:		8 entries
- Maximum string length:		128 chars (including \0)

Obviously, this is limited by your data/program memory size.

## Notes on linking against libledmtx
- Copy `Makefile.template` to you project directory and tune it.
  Change the value of the `P18FXXX`, `LIBDIR`, `INCLUDEDIR`, `O` and `modules`
  variables.  LIBDIR and INCLUDEDIR should point to libledmtx install
  directories.  `O` and `MODULES` list additional libledmtx objects/libraries
  that should be linked.  `OBJECTS +=` line should list your project object
  files.

- Write config file for the driver.
  For the r393c164 driver, the file `ledmtx_r393c164.inc` (located in your
  project's directory), should look like
  this.  Change the values of the symbols appropiate for your hardware.

  LEDMTX_R393C164_IOPORT	equ	PORTA
  LEDMTX_R393C164_RCLK		equ	RA0
  LEDMTX_R393C164_RRST		equ	RA1
  LEDMTX_R393C164_RENA		equ	RA2
  LEDMTX_R393C164_CCLK		equ	RA3
  LEDMTX_R393C164_CDAT		equ	RA4

- LEDMTX_BEGIN_MODULES_INIT/LEDMTX_END_MODULES_INIT macros are mandatory
  even if you are not using any module.  .h files for modules should be
  included before ledmtx_core.h.  Declare framebuffer using the following macro:
```
  LEDMTX_FRAMEBUFFER_RES(size)
```
where size=height*ceil(width/8).

- If you are using TMR0 interrupts to call driver vertical refresh routine,
  you should also include this code:

```
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

- `ledmtx_init()` should be called on initialisation.  If you are using TMR0
  to call driver vertrefresh routine, you should compute TMR0H, TMR0L and
  T0CON values using the `ledmtx_tmr0config` tool (included in the support/
  directory).  Example:

```
  /* init libledmtx 32x7@50hz display (Fosc=8mhz) */
  ledmtx_init(LEDMTX_INIT_CLEAR|LEDMTX_INIT_TMR0,32,7,0xe9,0xae,0x88)
```

## Contributing
Users are welcome to contribute this project either with code, fixes
or hardware.  If you are interested feel free to drop a mail to
`<jalopezg AT inf.uc3m.es>`.
