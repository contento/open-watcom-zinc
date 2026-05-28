# Open Watcom + Open Zinc: DOS Examples

A collection of example applications for **DOS/4GW 32-bit extended** mode, built with **[Open Watcom 2.0](https://github.com/open-watcom/open-watcom-v2)** and the **[Open Zinc](http://www.openzinc.com/)** portable UI framework.

All examples run on MS-DOS 6.x and are tested in **[DOSBox-X](https://dosbox-x.com)** configured as a 386 machine.

![Target](https://img.shields.io/badge/target-DOS%206.x%20%2F%20DOS%2F4GW-blue)
![CPU](https://img.shields.io/badge/CPU-80386%2B-green)
![Compiler](https://img.shields.io/badge/compiler-Open%20Watcom%202.0-orange)
![License](https://img.shields.io/badge/license-LGPLv2%2B-blue)

---

## Examples

### [hello-world](examples/hello-world/) — Start here

A minimal tutorial showing the basics:

- Creating a simple window
- Adding UI elements
- Handling events
- Building and running

```bash
cd examples/hello-world
wmake && sh run.sh
```

### [basic-demo](examples/basic-demo/) — Advanced features

A feature-rich demo demonstrating:

- Multiple UI components (input, text, menus)
- Modal dialogs
- Event handling and message passing
- String manipulation and dynamic output
- Debug logging

```bash
cd examples/basic-demo
wmake && sh run.sh
```

### [basic-demo-text](examples/basic-demo-text/) — Text mode only

Same feature-rich demo as basic-demo, but dedicated to **text-mode-only** functionality:

- No graphics drivers
- Open Zinc's text UI (`UIW_*` classes)
- All features work in 80x25 terminal
- Clean reference for text-mode DOS applications

```bash
cd examples/basic-demo-text
wmake && sh run.sh
```

---

## Quick Start

### 1. Setup Environment

**macOS (Homebrew):**

```bash
brew install open-watcom dosbox-x
export WATCOM=$(brew --prefix open-watcom)
export PATH=$WATCOM/binl64:$PATH
export ZINC_HOME=/path/to/zinc      # install separately
```

**Linux:**

```bash
# Install from your package manager or download from GitHub
export WATCOM=/opt/watcom
export PATH=$WATCOM/binl:$PATH
export ZINC_HOME=/opt/zinc
```

**Windows:**

Download and install from official sources:
- Open Watcom: https://github.com/open-watcom/open-watcom-v2/releases
- DOSBox-X: https://dosbox-x.com

Then set environment variables in System → Environment Variables.

See [docs/SETUP.md](docs/SETUP.md) for detailed instructions.

### 2. Build & Run

```bash
cd examples/hello-world
wmake              # compile and link
sh run.sh          # launch in DOSBox-X (macOS/Linux)
# or: run.bat      # (Windows)
```

---

## Project Structure

```
open-watcom-zinc/
├── examples/
│   ├── hello-world/            ← start here
│   │   ├── src/main.cpp
│   │   ├── makefile
│   │   ├── README.md
│   │   ├── dosbox-x.conf
│   │   ├── run.sh
│   │   └── run.bat
│   ├── basic-demo/             ← advanced features
│   │   ├── src/main.cpp
│   │   ├── makefile
│   │   ├── README.md
│   │   ├── dosbox-x.conf
│   │   ├── run.sh
│   │   └── run.bat
│   └── basic-demo-text/        ← text mode only
│       ├── src/main.cpp
│       ├── makefile
│       ├── README.md
│       ├── dosbox-x.conf
│       ├── run.sh
│       └── run.bat
├── docs/
│   ├── SETUP.md                ← environment setup
│   ├── BUILDING.md             ← build details
│   └── CONTRIBUTING.md         ← add new examples
├── scripts/
│   └── build-zinc-ow2.sh       ← shared build script
├── vendor/                     ← shared dependencies
│   ├── zinc/
│   └── watcom/
├── CLAUDE.md                   ← codebase conventions
├── LICENSE
└── TODO.md
```

Each example is **self-contained** with its own source, makefile, and run scripts. All examples **share** the vendor libraries and build utilities.

---

## Features

- **Text-mode UI** — Open Zinc running under DOS/4GW 32-bit extended memory
- **Cross-platform build** — Compile on macOS, Linux, or Windows to produce DOS binaries
- **Self-contained examples** — Each example includes everything needed to build and run
- **DOSBox-X integration** — Launch directly from the host with `sh run.sh` or `run.bat`
- **Progressive learning** — Start with hello-world, advance to feature-rich demos

---

## Tech Stack

| Component | Details |
| --- | --- |
| Compiler | Open Watcom 2.0 (`wpp386` for C++, `wcc386` for C) |
| Linker | `wlink` with `system dos4g` target |
| DOS Extender | DOS/4GW (bundled with Open Watcom) |
| UI Framework | Open Zinc (text-mode DOS) |
| Runtime | DOS 6.x on 80386+ CPU (or DOSBox-X emulator) |
| Language | C++98 for maximum Zinc compatibility |

---

## Building

Each example builds independently:

```bash
cd examples/[example-name]
wmake              # debug build
wmake release      # optimized build
wmake clean        # clean up
```

The makefile automatically:
1. Resolves shared vendor paths
2. Builds Zinc if needed
3. Compiles with DOS/4GW settings
4. Links with required aliases

See [docs/BUILDING.md](docs/BUILDING.md) for detailed build instructions and troubleshooting.

---

## Running in DOSBox-X

**From the host (macOS / Linux):**

```bash
cd examples/hello-world
sh run.sh          # build + launch
sh run.sh -s       # launch shell only (no auto-run)
```

**From the host (Windows):**

```batch
cd examples\hello-world
run.bat            # build + launch
```

**Inside DOSBox-X:**

```
C:\> demo.exe      # run directly
C:\> run.bat       # or use the batch launcher
```

---

## Documentation

- [CLAUDE.md](CLAUDE.md) — Codebase structure and coding conventions
- [docs/SETUP.md](docs/SETUP.md) — Environment setup and prerequisites
- [docs/BUILDING.md](docs/BUILDING.md) — Build system details and troubleshooting
- [docs/CONTRIBUTING.md](docs/CONTRIBUTING.md) — How to add new examples
- Example READMEs — Learn from each example's documentation

---

## Coding Conventions

- **C++98** — No C++11+ features (maximum Zinc compatibility)
- **Zinc objects** — Use `UIW_*` classes for all UI
- **No direct DOS calls** — Access DOS through the runtime, never `int 21h` from UI code
- **Event-driven** — Override `Event()` in `UIW_WINDOW` subclasses
- **wmake only** — Use Open Watcom's `wmake`, not GNU make

See [CLAUDE.md](CLAUDE.md) for full conventions and compiler flag reference.

---

## License

This project is licensed under the **GNU Lesser General Public License v2.1 or later (LGPLv2+)**.  
See [LICENSE](LICENSE) for the full text.

**Upstream licenses:**
- Open Watcom: [Sybase Open Watcom Public License 1.0](https://github.com/open-watcom/open-watcom-v2/blob/master/license.txt)
- Open Zinc: LGPL — see [openzinc.com](http://www.openzinc.com/)
