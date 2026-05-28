# CLAUDE.md — Always use this file as the primary project reference.

> **Instruction:** Always read and follow CLAUDE.md before any task in this project.

# Open Watcom + Open Zinc DOS Examples

## Project Overview

A collection of example applications using **Open Watcom 2.0** compiler and **Open Zinc** UI framework, targeting **32-bit DOS Extended** (DOS/4GW) for DOS 6.x environments. All binaries run correctly in **DOSBox-X** configured in 386 protected mode.

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
├── CLAUDE.md                      ← this file
├── README.md                      ← overview & examples list
├── TODO.md                        ← development plan
├── docs/
│   ├── BUILDING.md                ← detailed build instructions
│   ├── SETUP.md                   ← environment setup
│   └── CONTRIBUTING.md            ← how to add new examples
├── examples/
│   ├── hello-world/               ← minimal tutorial
│   │   ├── src/main.cpp
│   │   ├── makefile
│   │   ├── README.md
│   │   ├── dosbox-x.conf
│   │   ├── run.sh
│   │   └── run.bat
│   └── basic-demo/                ← feature-rich demo
│       ├── src/main.cpp
│       ├── makefile
│       ├── README.md
│       ├── dosbox-x.conf
│       ├── run.sh
│       └── run.bat
├── scripts/
│   └── build-zinc-ow2.sh          ← shared build script
├── vendor/                        ← shared dependencies
│   ├── zinc/
│   └── watcom/
├── .github/
└── .gitignore
```

## Examples

### hello-world

Start here. A minimal Open Zinc application showcasing:
- Basic window creation
- Simple UI layout
- Button event handling

```bash
cd examples/hello-world
wmake && sh run.sh
```

### basic-demo

A feature-rich demo with:
- Multiple UI components (input fields, text output, menus)
- Modal dialogs
- Event handling and message passing
- Debug logging

```bash
cd examples/basic-demo
wmake && sh run.sh
```

## Prerequisites

See [docs/SETUP.md](docs/SETUP.md) for detailed environment setup instructions.

### Quick Setup

1. **Open Watcom 2.0** — `$WATCOM` env var set to its root
2. **Open Zinc** — `$ZINC_HOME` pointing to Zinc root (with `include/` and `lib/` subdirs)
3. **DOSBox-X** — for testing

## Building & Running

Each example is self-contained. To build and run:

```bash
cd examples/hello-world    # or examples/basic-demo
wmake                      # debug build
sh run.sh                  # launch in DOSBox-X (macOS/Linux)
run.bat                    # launch in DOSBox-X (Windows)
```

See [docs/BUILDING.md](docs/BUILDING.md) for detailed build instructions.

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
