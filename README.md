# Open Watcom + Open Zinc — DOS/4GW Demo

A minimal C++ demo application built with **[Open Watcom 2.0](https://github.com/open-watcom/open-watcom-v2)** and the **[Open Zinc](https://github.com/jdahlin/zinc)** portable UI framework, targeting **32-bit DOS Extended** (DOS/4GW) on an 80386 CPU.

The binary runs on MS-DOS 6.x and is tested in **[DOSBox-X](https://dosbox-x.com)** configured as a 386 machine.

![Target](https://img.shields.io/badge/target-DOS%206.x%20%2F%20DOS%2F4GW-blue)
![CPU](https://img.shields.io/badge/CPU-80386%2B-green)
![Compiler](https://img.shields.io/badge/compiler-Open%20Watcom%202.0-orange)
![License](https://img.shields.io/badge/license-GPLv2-red)

---

## Screenshot

```
┌─────────────────────────────────────────────────────────────────────────────┐
│  Open Watcom + Open Zinc --- DOS/4GW 386 Demo                 File   Help  │
├─────────────────────────────────────────────────────────────────────────────┤
│                                                                             │
│  Welcome! This app runs on DOS 6.x with 80386 extended memory.             │
│                                                                             │
│  Click the button below or type in the input field.                        │
│                                                                             │
│  Input:  [______________________________]                                   │
│                                                                             │
│  [ Click Me! ]    [ Echo Input ]    [    Exit    ]                         │
└─────────────────────────────────────────────────────────────────────────────┘
```

---

## Features

- Text-mode Zinc UI running under DOS/4GW 32-bit extended memory
- Menu bar (File → Exit, Help → About)
- Click counter button
- Input field with echo-to-label feedback
- Modal "About" dialog showing build target info
- Builds with a single `wmake` command

---

## Prerequisites

### Compiler — Open Watcom 2.0

Download from the [Open Watcom v2 releases](https://github.com/open-watcom/open-watcom-v2/releases) page.

```sh
# macOS example
export WATCOM=/opt/watcom
export PATH=$WATCOM/binl64:$PATH   # or binl on Linux
```

Verify:
```sh
wpp386 --version
```

### UI Library — Open Zinc

Clone and compile Open Zinc for the `dos4g` target using Open Watcom:

```sh
git clone https://github.com/jdahlin/zinc $ZINC_HOME
cd $ZINC_HOME
# follow Zinc's build instructions for the DOS/4GW target
```

Set the environment variable:
```sh
export ZINC_HOME=/opt/zinc   # adjust to your path
```

The library used by the makefile: `$ZINC_HOME/lib/zinc32d.lib`  
Headers: `$ZINC_HOME/include/`

### Emulator — DOSBox-X

Install from [dosbox-x.com](https://dosbox-x.com) or via Homebrew:

```sh
brew install dosbox-x
```

---

## Building

```sh
cd open-watcom-zinc

wmake           # debug build  → demo.exe
wmake release   # optimised    → demo.exe (no debug info)
wmake clean     # remove .obj / .exe
```

`wmake` is the Open Watcom make utility — **not** GNU make.

---

## Running in DOSBox-X

The `dosbox-x.conf` in this repo configures:

| Setting | Value |
|---------|-------|
| Machine | `svga_s3` |
| DOS version | 6.22 |
| CPU | 386 dynamic core |
| Memory | 16 MB |

```sh
# From the repo root on the host:
dosbox-x -conf dosbox-x.conf
```

Inside DOSBox-X the repo directory is mounted as `C:\`. Run:

```
C:\> run.bat
```

---

## Project Structure

```
open-watcom-zinc/
├── src/
│   └── main.cpp               application source
├── makefile                   wmake build file
├── dosbox-x.conf              DOSBox-X machine config
├── run.bat                    launch script (inside DOSBox-X)
├── CLAUDE.md                  AI assistant context
├── .github/
│   └── copilot-instructions.md  GitHub Copilot rules
└── TODO.md                    development plan
```

---

## Compiler Flags Reference

| Flag | Effect |
|------|--------|
| `-bt=dos4g` | Target DOS/4GW 32-bit extended |
| `-3` | Emit 80386 instructions |
| `-mf` | Flat 32-bit memory model |
| `-fp3` | 387 FPU code |
| `-d2` | Full debug info (debug build) |
| `-ox -s` | Optimise + no stack checks (release) |

---

## License

This project is licensed under the **GNU General Public License v2.0**.  
See [LICENSE](LICENSE) for the full text.

Open Watcom is licensed under the [Sybase Open Watcom Public License 1.0](https://github.com/open-watcom/open-watcom-v2/blob/master/license.txt).  
Open Zinc retains its original license — check the Zinc repository for details.
