# Build Guide — Open Watcom + Open Zinc DOS/4GW

A complete reference for building and running DOS 32-bit extended applications with the Open Watcom 2.0 compiler and the Open Zinc UI framework inside DOSBox-X.

---

## Table of Contents

1. [Prerequisites](#1-prerequisites)
2. [Environment Setup](#2-environment-setup)
3. [Project Layout](#3-project-layout)
4. [Building the Zinc Library](#4-building-the-zinc-library)
5. [Building the Demo App](#5-building-the-demo-app)
6. [Building Tutorial Examples](#6-building-tutorial-examples)
7. [Running in DOSBox-X](#7-running-in-dosbox-x)
8. [Known Issues and Workarounds](#8-known-issues-and-workarounds)
9. [Compiler Flags Reference](#9-compiler-flags-reference)
10. [OW 1.x → OW 2.x Symbol Compatibility](#10-ow-1x--ow-2x-symbol-compatibility)

---

## 1. Prerequisites

### Open Watcom 2.0

The project requires **Open Watcom 2.0** (not 1.9). The pre-built Zinc library shipped with Zinc was compiled by OW 1.9 and is binary-incompatible with OW 2.0 — the library must be rebuilt from source (see §4).

- **macOS**: download the `ow2-macOS` release from  
  https://github.com/open-watcom/open-watcom-v2/releases
- **Linux**: download the `ow2-linux` release from the same page.
- The archive unpacks to an `ow2` directory. Set `WATCOM` to that path.

### DOSBox-X

The built EXEs run inside **DOSBox-X** (not vanilla DOSBox — DOSBox-X has better 386 protected-mode support).

- macOS: `brew install --cask dosbox-x`
- Linux: see https://dosbox-x.com

### Open Zinc Source

The Zinc source is vendored at `vendor/zinc/`. No separate download needed.

---

## 2. Environment Setup

```sh
# Point to your Open Watcom 2.0 installation
export WATCOM=/path/to/ow2

# Add the host compiler binaries to PATH
# macOS (64-bit host):
export PATH="$WATCOM/binl64:$PATH"
# Linux (64-bit host):
export PATH="$WATCOM/binl:$PATH"

# Optional — wmake picks these up automatically from the project makefile
export INCLUDE="$WATCOM/h:vendor/zinc/INCLUDE"
```

Verify with:

```sh
wpp386 --version   # should print Open Watcom C++ 2.0
wlink --version    # should print Open Watcom Linker 2.0
```

---

## 3. Project Layout

```
open-watcom-zinc/
├── CLAUDE.md                    project AI instructions
├── BUILD.md                     this file
├── TODO.md                      development plan
├── makefile                     wmake build (demo.exe)
├── src/
│   └── main.cpp                 demo app entry point
├── scripts/
│   ├── build-zinc-ow2.sh        rebuild Zinc library for OW2
│   └── build-tutorials.sh       build HELLO tutorial EXEs
├── tutorials/
│   └── hello/
│       ├── dosbox.conf          DOSBox-X config for tutorials
│       ├── hello1.exe           }
│       ├── hello2.exe           } built by build-tutorials.sh
│       ├── hello3.exe           }
│       └── hello.dat            Zinc resource file (copied from vendor)
├── vendor/
│   ├── watcom/                  Open Watcom headers and libraries
│   └── zinc/
│       ├── INCLUDE/             Zinc public headers
│       ├── SOURCE/              Zinc C++ source (all platforms)
│       ├── TUTOR/               Tutorial examples
│       └── LIB/OW2/
│           └── D32_ZIL.LIB     rebuilt Zinc lib (OW2, DOS/4GW, text+WCC)
├── dosbox-x.conf                DOSBox-X config for demo.exe
└── dosbox-x-headless.conf       headless config (CI / scripted testing)
```

---

## 4. Building the Zinc Library

The pre-built Zinc libraries (under `vendor/zinc/LIB/ow19/`) were compiled with OW 1.9 and use a different C++ name-mangling scheme. They cannot be used with OW 2.0 directly.

Run the rebuild script **once** from the project root:

```sh
sh scripts/build-zinc-ow2.sh
```

This compiles all ~150 Zinc source files and produces:

```
vendor/zinc/LIB/OW2/D32_ZIL.LIB
```

The library is compiled with:
- `-bt=dos4g` — DOS/4GW 32-bit extended target
- `-3 -mf -fp3` — 80386, flat memory model, 387 FPU
- `-dWCC` on `z_app.CPP` — enables `UI_WCC_DISPLAY` (graphics) with automatic fallback to `UI_TEXT_DISPLAY`

The rebuild takes under a minute on modern hardware. Intermediate `.obj` files land in `/tmp/zinc_ow2_obj/` and are discarded.

### When to re-run

Re-run the script if you modify any file in `vendor/zinc/SOURCE/`.

---

## 5. Building the Demo App & Examples

All example makefiles include `scripts/common.mk` — a shared fragment that
handles compiler flags, `z_app.CPP` display mode, and linking. You only need
to define `PROJECT_ROOT`, `TARGET`, and `OBJS` in your example's makefile.

### Display mode selection

Set `ZINC_DISPLAY` to choose the Zinc display driver:

| Value   | Effect |
|---------|--------|
| `TEXT` (default) | Uses `UI_TEXT_DISPLAY` directly — stable on DOSBox-X and real DOS, no graphics dependencies |
| `WCC`            | Tries `UI_WCC_DISPLAY` (VGA), falls back to text if init fails — **may crash DOSBox-X** (see §8) |

```sh
wmake                      # text mode (safe)
wmake ZINC_DISPLAY=WCC     # WCC graphics mode
wmake ZINC_DISPLAY=WCC RELEASE=1  # release build with graphics
```

### Root demo (WCC graphics)

```sh
wmake                      # uses ZINC_DISPLAY=WCC by default
wmake ZINC_DISPLAY=TEXT    # override to text mode
```

---

## 6. Building Tutorial Examples

```sh
sh scripts/build-tutorials.sh
```

Builds three HELLO tutorials into `tutorials/hello/`:

| EXE | Source | Description |
|-----|--------|-------------|
| `hello1.exe` | `TUTOR/HELLO/HELLO1.CPP` | Minimal window — no data file needed |
| `hello2.exe` | `TUTOR/HELLO/HELLO2.CPP` | Adds help system, error system, exit dialog |
| `hello3.exe` | `TUTOR/HELLO/HELLO3.CPP` | Loads windows from `hello.dat` (Zinc Designer output) |

### How it works

The example-based makefiles (hello-world, basic-demo, phone-keypad-fresh, etc.)
include `scripts/common.mk` which handles:
- Standard compiler flags (`-bt=dos4g -3 -mf -fp3 -w4 ...`)
- Display mode: `ZINC_DISPLAY=TEXT` (default, safe) or `ZINC_DISPLAY=WCC` (graphics)
- Recompiling `z_app.CPP` with the right display mode and linking it before the library
- Automatic Zinc library build via `build-zinc-ow2.sh` if `D32_ZIL.LIB` is missing

Each example makefile is now 10-15 lines instead of 60+.

The tutorial shell script (`build-tutorials.sh`) uses the same text-only technique directly.

1. `z_app.CPP` is recompiled with `-dZIL_TEXT_ONLY` (forces `UI_TEXT_DISPLAY` directly).
2. The resulting `z_app_txt.obj` is linked *before* `D32_ZIL.LIB`, so the linker uses the override and skips the WCC/graphics version baked into the library.
3. Because graphics mode is never entered, `graph.lib` is not needed, and none of the OW1→OW2 symbol aliases are required.

This makes tutorials completely stable in DOSBox-X regardless of the WCC graphics issue (see §8).

### Testing a tutorial

Edit `tutorials/hello/dosbox.conf` to set which EXE runs, then:

```sh
dosbox-x -conf tutorials/hello/dosbox.conf
```

Or run from the project root to try each one:

```sh
# Edit the autoexec line in tutorials/hello/dosbox.conf to select the EXE
dosbox-x -conf tutorials/hello/dosbox.conf
```

---

## 7. Running in DOSBox-X

### Configuration

Two configs are provided:

| File | Use |
|------|-----|
| `dosbox-x.conf` | Interactive — opens a window, runs demo.exe |
| `dosbox-x-headless.conf` | Scripted / CI — no GUI window |

Key settings:

```ini
[dosbox]
machine=svga_s3   # must be svga_s3 (plain "vga" is invalid in DOSBox-X 2026)
memsize=16        # 16 MB — enough for DOS/4GW apps

[cpu]
core=dynamic      # fastest for 386 code
cputype=386
cycles=max

[dos]
xms=true          # extended memory (DOS/4GW requires XMS)
ems=true
umb=true
ver=6.22
```

### Mounting

The `[autoexec]` section mounts the project root as `C:`:

```ini
[autoexec]
mount c .         # project root becomes C:
c:
demo.exe
```

For tutorials:

```ini
[autoexec]
mount c tutorials/hello
c:
hello1.exe
```

### Headless mode (scripted testing)

```sh
SDL_VIDEODRIVER=dummy SDL_AUDIODRIVER=dummy \
    dosbox-x -conf dosbox-x-headless.conf -exit
```

---

## 8. Known Issues and Workarounds

### WCC Graphics (`demo.exe`) Crashes DOSBox-X

**Symptom**: `demo.exe` exits with SIGABRT (exit code 134) immediately on startup.

**Root cause**: The Zinc `UI_WCC_DISPLAY` constructor calls `graph.lib` functions (e.g. `_setvideomode`). These functions issue `INT 15h ax=BFDE` (VCPI probe) during initialisation, which causes DOSBox-X 2026 to abort.

**Status**: Under investigation. The crash comes from calling graph functions, not from merely linking `graph.lib`.

**Workaround for stable builds**: Use text-only display by setting `ZINC_DISPLAY=TEXT` on the make command line (or in the makefile). This recompiles `z_app.CPP` with `-dZIL_TEXT_ONLY` and omits `graph.lib` from the link. All example makefiles support this via the shared `scripts/common.mk` fragment — no manual makefile editing needed.

**Workaround for demo.exe**: The `D32_ZIL.LIB` library was compiled with `-dWCC`, which tries WCC graphics first and is supposed to fall back to text if initialisation fails. The fallback is implemented in `vendor/zinc/SOURCE/Z_APP.CPP` lines 180-214. However, the constructor crashes before returning `installed == FALSE`.

### `machine=vga` is Invalid

DOSBox-X 2026 does not accept `machine=vga`. Use `machine=svga_s3` (default) or `machine=vgaonly`.

### OW 2.0 Name Mangling vs. `graph.lib`

`graph.lib` was compiled with OW 1.9. OW 2.0 appends a trailing underscore to `__watcall` functions (`_setvideomode_` instead of `_setvideomode`). The mismatch causes ~35 undefined-symbol linker errors.

Fix: use `alias` directives in the wlink command (see §10).

---

## 9. Compiler Flags Reference

All builds use the following base flags:

| Flag | Meaning |
|------|---------|
| `-bt=dos4g` | Build target: DOS/4GW 32-bit extended |
| `-3` | Generate 80386 instructions |
| `-mf` | Flat memory model (required for 32-bit DOS) |
| `-fp3` | 387 FPU instructions |
| `-dDOS386` | Define used by Zinc source to select DOS/4GW code paths |
| `-zq` | Quiet mode (suppress informational messages) |
| `-w0` | No warnings (Zinc source has many OW2 warnings) |
| `-d2` | Full debug info (debug builds, use `-d0` for release) |
| `-ox` | Maximum optimisation (release builds only) |

Display-mode defines for `z_app.CPP`:

| Define | Effect |
|--------|--------|
| `-dWCC` | Try `UI_WCC_DISPLAY` (VGA graphics), fall back to `UI_TEXT_DISPLAY` |
| `-dZIL_TEXT_ONLY` | Use `UI_TEXT_DISPLAY` directly, never enter graphics mode |

---

## 10. OW 1.x → OW 2.x Symbol Compatibility

OW 2.0 changed name decoration for `__watcall` (the default calling convention). In OW 1.x the symbol is `_name`; in OW 2.x it becomes `_name_` (trailing underscore added). This affects any library compiled with OW 1.x.

### `graph.lib`

The Open Watcom `graph.lib` in `vendor/watcom/lib386/dos/graph.lib` is an OW 1.9 build. When OW 2.0 code calls `_setvideomode(mode)`, the compiler emits a reference to `_setvideomode_`. The library only exports `_setvideomode`.

The makefile bridges this with wlink `alias` directives:

```makefile
alias _setvideomode_ = _setvideomode
alias malloc         = malloc_
```

The second form (`malloc = malloc_`) maps the OW1 CRT name used inside `graph.lib` to the OW2 name exported by `clib3r.lib`.

**Full alias list** (in `makefile`): 27 graph function aliases + 8 CRT/extender aliases.

### Why aliases are safe

The calling convention (`__watcall`) is identical between OW 1.x and OW 2.x — only the exported name changed. Aliasing the name maps calls to the correct binary-compatible implementation.

### Extender symbol aliases

`graph.lib` internally references `_ExtenderRealModeSelector`, `_Extender`, `_DPMI`, and `_STACKLOW`. Under OW 2.0 + DOS/4GW these are provided with a double-underscore prefix (`__ExtenderRealModeSelector` etc.). The makefile aliases these as well.
