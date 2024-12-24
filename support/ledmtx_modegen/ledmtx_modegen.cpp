/*
 * ledmtx_modegen.cpp - simple tool to generate 'video mode' (incl.
 * TMR0H/TMR0L/T0CON registers)
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

#include <getopt.h>
#include <unistd.h>

#include <cstdlib>
#include <iomanip>
#include <iostream>
#include <span>
#include <stdexcept>
#include <string>
#include <vector>

namespace {
void usage(int argc, char *argv[]) {
  // clang-format off
  std::cerr
      << argv[0] << ": simple tool to generate 'video mode' (incl. TMR0H/TMR0L/T0CON registers)\n"
         "Usage: " << argv[0] << " -f OSC_HZ [-d DEFAULT] [-p PREFIX] <WIDTH HEIGHT HW_HEIGHT VERT_REFRESH_HZ>...\n"
         "\nOptions:\n"
         "  --help,    -h                Show this usage message\n"
         "  --osc-hz,  -f OSC_HZ         Set the Microcontroller OSC frequency (in Hz)\n"
         "  --default, -d INDEX          Generate _DEFAULT_XXX preprocessor macros as an alias to <PREFIX>_MODE<INDEX>_XXX\n"
         "  --prefix,  -p PREFIX         Set the prefix for preprocessor definitions; defaults to 'LEDMTX_'\n"
         "\nArguments:\n"
         "  WIDTH             The width of a scanline (in pixels)\n"
         "  HEIGHT            Height (in scanlines)\n"
         "  HW_HEIGHT         Height as seen by the hardware; same as HEIGHT, usually, but see driver documentation\n"
         "  VERT_REFRESH_HZ   Vertical refresh frequency (in Hz), normally 50\n"
         "\nExample: " << argv[0] << " --osc-hz 8000000 --default 0 32 7 7 50 32 7 7 60\n"
         "           The previous command generates configuration for modes (0) 32x7@50Hz and (1) 32x7@60Hz\n"
         "           defaulting to mode 0\n";
  // clang-format on
}

/// Information about a video mode, incl. the generated Timer0 configuration.
struct LedmtxVideoMode {
  unsigned int width;  ///< Width of a scanline, in pixels.
  unsigned int height; ///< Height in scanlines.
  unsigned int
      hardware_height; ///< Height as seen by the hardware (driver-dependent);
                       ///< usually matches 'height', but not necessarily.
  unsigned int vert_refresh; ///< Vertical refresh frequency, in Hz.

  /// Generated Timer0 configuration.
  unsigned char tmr0h{};
  unsigned char tmr0l{};
  unsigned char t0con{};
};

// clang-format off
/// PSA: Timer0 Prescaler Assignment bit. From PIC18Fxxxx datasheet:
/// 1 = Timer0 prescaler is not assigned.  Timer0 clock input bypasses prescaler.
/// 0 = Timer0 prescaler is assigned.  Timer0 clock input comes from prescaler output.
// clang-format on
constexpr unsigned char T0CON_PSA = 0b1000;
constexpr unsigned char T0CON_T0PS_MASK = 0b111;

// clang-format off
/// Generate complete video mode information for \p video_mode.
/// \param tmr0_clock_in [in] Timer0 input clock, i.e. primary OSC frequency divided by 4
/// \param video_mode    [in/out] Vector of incomplete video modes
// clang-format on
void generate_tmr0config(unsigned int tmr0_clock_in,
                         LedmtxVideoMode &video_mode) {
  if (!video_mode.hardware_height || !video_mode.vert_refresh)
    throw std::runtime_error("error: unsupported config: `hardware_height` and "
                             "`vert_refresh` should be != 0");

  const unsigned int isr_hz =
      video_mode.hardware_height * video_mode.vert_refresh;
  unsigned int tmr0_ticks_to_overflow = tmr0_clock_in / isr_hz;
  unsigned char tmr0_prescaler_bits = T0CON_PSA | 0b000;

  // Adjust Timer0 prescaler such that `0x10000 - tmr0_ticks_to_overflow` is
  // representable in TMR0H:TMR0L.
  while (tmr0_ticks_to_overflow > 0x10000) {
    // Maximum prescale value of 1:256 was reached, yet `tmr0_ticks_to_overflow`
    // is not in bounds.
    if ((tmr0_prescaler_bits & T0CON_T0PS_MASK) == T0CON_T0PS_MASK)
      throw std::runtime_error(
          "error: unsupported config: too low refresh rate?");

    tmr0_ticks_to_overflow /= 2;
    if (tmr0_prescaler_bits & T0CON_PSA) {
      tmr0_prescaler_bits &= ~T0CON_PSA;
      continue;
    }
    tmr0_prescaler_bits++;
  }

  if (tmr0_ticks_to_overflow == 0U)
    throw std::runtime_error(
        "error: unsupported config: too high refresh rate");

  const unsigned int tmr0_preload_value = 0x10000 - tmr0_ticks_to_overflow;
  video_mode.tmr0h =
      static_cast<unsigned char>((tmr0_preload_value >> 8) & 0xff);
  video_mode.tmr0l = static_cast<unsigned char>(tmr0_preload_value & 0xff);
  video_mode.t0con =
      static_cast<unsigned char>(0x80 | (tmr0_prescaler_bits & 0x0f));
}

// clang-format off
/// Write mode configuration to standard output in a format parseable by the C
/// preprocessor.
/// \param prefix       The prefix for generated C preprocessor macros
/// \param video_modes  Video modes to dump
/// \param default_idx  The index for the default video mode
/// \param comment      Optional comment
// clang-format on
void dump_config(const std::string &prefix,
                 std::span<const LedmtxVideoMode> video_modes,
                 int default_idx = -1, std::string comment = {}) {
  std::cout << "// ledmtx_modegen: auto-generated video mode configuration ("
            << comment << ")\n"
            << "\n"
            << "#ifndef _" << prefix << "_MODEGEN_MODES\n"
            << "#define _" << prefix << "_MODEGEN_MODES\n\n";

  if (!video_modes.empty() && default_idx != -1) {
    std::cout << "#define " << prefix << "_DEFAULT_WIDTH  " << prefix << "_MODE"
              << default_idx << "_WIDTH\n";
    std::cout << "#define " << prefix << "_DEFAULT_HEIGHT " << prefix << "_MODE"
              << default_idx << "_HEIGHT\n";
    std::cout << "#define " << prefix << "_DEFAULT_TMR0H  " << prefix << "_MODE"
              << default_idx << "_TMR0H\n";
    std::cout << "#define " << prefix << "_DEFAULT_TMR0L  " << prefix << "_MODE"
              << default_idx << "_TMR0L\n";
    std::cout << "#define " << prefix << "_DEFAULT_T0CON  " << prefix << "_MODE"
              << default_idx << "_T0CON\n";
  }

  for (unsigned i = 0; i < video_modes.size(); ++i) {
    const auto &M = video_modes[i];
    std::cout << "\n"
              << std::dec << "/* " << M.width << "x" << M.height << " @ "
              << M.vert_refresh << "Hz */\n";
    std::cout << "#define " << prefix << "_MODE" << i << "_WIDTH  " << M.width
              << "\n";
    std::cout << "#define " << prefix << "_MODE" << i << "_HEIGHT " << M.height
              << "\n";
    std::cout << "#define " << prefix << "_MODE" << std::dec << i
              << "_TMR0H  0x" << std::hex << static_cast<int>(M.tmr0h) << "\n";
    std::cout << "#define " << prefix << "_MODE" << std::dec << i
              << "_TMR0L  0x" << std::hex << static_cast<int>(M.tmr0l) << "\n";
    std::cout << "#define " << prefix << "_MODE" << std::dec << i
              << "_T0CON  0x" << std::hex << static_cast<int>(M.t0con) << "\n";
  }

  std::cout << "\n#endif // _" << prefix << "_MODEGEN_MODES\n";
}
} // anonymous namespace

static const struct option longopts[] = {
    {"help", /*has_arg=*/false, nullptr, 'h'},
    {"osc-hz", /*has_arg=*/true, nullptr, 'f'},
    {"default", /*has_arg=*/true, nullptr, 'd'},
    {"prefix", /*has_arg=*/true, nullptr, 'p'},
    {nullptr, 0, nullptr, 0}};

int main(int argc, char *argv[]) try {
  unsigned int osc_hz = 0U;
  int default_mode_idx = -1;
  std::string prefix{"LEDMTX_"};
  std::vector<LedmtxVideoMode> video_modes;

  int opt;
  while ((opt = getopt_long(argc, argv, "hf:d:p:", &longopts[0], nullptr)) !=
         -1) {
    switch (opt) {
    case 'f':
      osc_hz = atoi(optarg);
      break;
    case 'd':
      default_mode_idx = atoi(optarg);
      break;
    case 'p':
      prefix = optarg;
      break;
    default:
      usage(argc, argv);
      exit((opt == 'h') ? EXIT_SUCCESS : EXIT_FAILURE);
    }
  }

  const unsigned int tmr0_hz_in = osc_hz / 4;
  if (tmr0_hz_in == 0U) {
    std::cerr << "Timer0 input frequency should be != 0" << std::endl;
    usage(argc, argv);
    return EXIT_FAILURE;
  }
  if (optind >= argc || ((argc - optind) % 4) != 0) {
    std::cerr << "Missing or incomplete video mode description!" << std::endl;
    usage(argc, argv);
    return EXIT_FAILURE;
  }

  const size_t N_descriptions = (argc - optind) / 4;
  for (unsigned i = 0, tuple_begin = optind; i < N_descriptions;
       ++i, tuple_begin += 4) {
    video_modes.push_back(LedmtxVideoMode{
        static_cast<unsigned int>(atoi(argv[tuple_begin + 0])),
        static_cast<unsigned int>(atoi(argv[tuple_begin + 1])),
        static_cast<unsigned int>(atoi(argv[tuple_begin + 2])),
        static_cast<unsigned int>(atoi(argv[tuple_begin + 3]))});
  }
  for (LedmtxVideoMode &video_mode : video_modes) {
    generate_tmr0config(tmr0_hz_in, video_mode);
  }
  dump_config(prefix, video_modes, default_mode_idx,
              "for Fosc = " + std::to_string(osc_hz) + "Hz");

  return EXIT_SUCCESS;
} catch (const std::exception &e) {
  std::cerr << "Unhandled exception: " << e.what() << std::endl;
  return EXIT_FAILURE;
}
