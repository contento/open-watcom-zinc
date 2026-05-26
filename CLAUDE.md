# Open Watcom + Open Zinc DOS Demo

## Project Overview

A demonstration application using **Open Watcom 2.0** compiler and **Open Zinc** UI framework, targeting **32-bit DOS Extended** (DOS/4GW) for DOS 6.x environments. The built binary must run correctly in **DOSBox-X** configured in 386 protected mode.

## Tech Stack

| Component | Version / Notes |
|-----------|----------------|
| Compiler  | Open Watcom 2.0 (`wpp386` for C++, `wcc386` for C) |
| Linker    | `wlink` with `system dos4g` |
| DOS Extender | DOS/4GW (bundled with Open Watcom) |
| UI Framework | Open Zinc (text-mode DOS target) |
| Runtime target | DOS 6.x, 80386+ CPU |
| Emulator | DOSBox-X with `machine=svga_s3`, `core=dynamic` |

## Directory Layout

```
open-watcom-zinc/
├── CLAUDE.md                  ← this file
├── TODO.md                    ← development plan
├── .github/
│   └── copilot-instructions.md
├── src/
│   └── main.cpp               ← application entry point
├── makefile                   ← Open Watcom wmake build file
├── dosbox-x.conf              ← DOSBox-X config for testing
└── run.bat                    ← launch script inside DOSBox-X
```

## Prerequisites

### On the host (macOS / Linux)

1. **Open Watcom 2.0** installed, `$WATCOM` env var set to its root.
   - macOS: install via Homebrew or download from https://github.com/open-watcom/open-watcom-v2/releases
   - Add `$WATCOM/binl` (Linux) or `$WATCOM/binl64` (macOS) to `$PATH`

2. **Open Zinc** source compiled for DOS/4GW target.
   - Set `$ZINC_HOME` to the Zinc root (where `include/` and `lib/` live).
   - The DOS/4GW 32-bit library is typically `$ZINC_HOME/lib/zinc32d.lib`.

3. **DOSBox-X** for testing.
   - Use `dosbox-x.conf` in this repo.

### Environment variables

```sh
export WATCOM=/opt/watcom          # Open Watcom root
export PATH=$WATCOM/binl64:$PATH   # add compiler binaries
export ZINC_HOME=/opt/zinc         # Open Zinc root
export INCLUDE=$ZINC_HOME/include  # Zinc headers (optional, also set in makefile)
```

## Building

```sh
cd open-watcom-zinc
wmake                  # builds demo.exe
wmake clean            # removes .obj and .exe
```

## Running in DOSBox-X

```sh
dosbox-x -conf dosbox-x.conf
# inside DOSBox-X:
C:\> run.bat
```

## Coding Conventions

- C++98 — Open Watcom 2.0 supports C++11 partially; stick to C++98 for maximum Zinc compatibility.
- Prefer Zinc's own string/memory helpers (`ZIL_STRING`, `ZIL_ICHAR`) over `std::string`.
- All UI construction goes through Zinc `UIW_*` objects; never call DOS int 21h directly from UI code.
- Event handling: override `Event()` in `UIW_WINDOW` subclasses, return `EVENT_TYPE`.
- `wmake` is the build tool — the makefile syntax is Open Watcom `wmake`, **not** GNU make.

## Key wmake Flags Explained

| Flag | Meaning |
|------|---------|
| `-bt=dos4g` | Build target: DOS/4GW 32-bit extended |
| `-3` | Generate 80386 instructions |
| `-mf` | Flat memory model (32-bit) |
| `-fp3` | 387 FPU instructions |
| `-s` | Disable stack overflow checks (smaller binary) |
| `-w4` | Warning level 4 |
| `-d2` | Full debug info (use `-d0` for release) |

## DOSBox-X Notes

- `machine=svga_s3` gives reliable VESA support if switching to graphics mode.
- `core=dynamic` is fastest for 386 code.
- `memsize=16` (16 MB) is plenty for DOS/4GW apps.
- The DOS/4GW extender loads automatically from the stub prepended to `demo.exe`.
