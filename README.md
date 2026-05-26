# Open Watcom + Open Zinc — DOS/4GW Demo

A minimal C++ demo application built with **[Open Watcom 2.0](https://github.com/open-watcom/open-watcom-v2)** and the **[Open Zinc](http://www.openzinc.com/)** portable UI framework, targeting **32-bit DOS Extended** (DOS/4GW) on an 80386 CPU.

The binary runs on MS-DOS 6.x and is tested in **[DOSBox-X](https://dosbox-x.com)** configured as a 386 machine.

![Target](https://img.shields.io/badge/target-DOS%206.x%20%2F%20DOS%2F4GW-blue)
![CPU](https://img.shields.io/badge/CPU-80386%2B-green)
![Compiler](https://img.shields.io/badge/compiler-Open%20Watcom%202.0-orange)
![License](https://img.shields.io/badge/license-LGPLv2%2B-blue)

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
- Builds with a single `wmake` command on any host platform

---

## Getting Started

**Open Watcom and Open Zinc are downloaded and built automatically** by the setup scripts. The only manual prerequisite is [DOSBox-X](https://dosbox-x.com) for running the final binary.

### macOS / Linux

```sh
bash scripts/setup.sh
```

This will:
1. Download Open Watcom from GitHub Releases into `vendor/watcom/`
2. Download Open Zinc from [openzinc.com](http://www.openzinc.com/) into `vendor/zinc/`
3. Build Open Zinc for the DOS/4GW target
4. Print the env vars to add to your shell profile

Then install DOSBox-X:

```sh
# macOS
brew install dosbox-x

# Debian / Ubuntu
sudo apt install dosbox-x

# Fedora / RHEL
sudo dnf install dosbox-x
```

### Windows

```bat
scripts\setup.bat
```

Same steps as above using `curl` and PowerShell's `Expand-Archive` (built into Windows 10+).

Then install DOSBox-X from [dosbox-x.com](https://dosbox-x.com).

### Manual setup (advanced)

If you prefer to manage the tools yourself, set these environment variables before running `wmake`:

| Variable | macOS / Linux | Windows |
|----------|---------------|---------|
| Compiler root | `export WATCOM=/opt/watcom` | `set WATCOM=C:\WATCOM` |
| Zinc root | `export ZINC_HOME=/opt/zinc` | `set ZINC_HOME=C:\zinc` |
| PATH (64-bit host) | `$WATCOM/binl64` | `%WATCOM%\binnt64` |
| PATH (32-bit Linux) | `$WATCOM/binl` | — |

The `vendor/zinc` fallback is used automatically when `ZINC_HOME` is not set.

---

## Building

```sh
# macOS / Linux
cd open-watcom-zinc
wmake           # debug build   → demo.exe
wmake release   # optimised     → demo.exe (no debug info)
wmake clean     # remove .obj / .exe
```

```bat
REM Windows (cmd)
cd open-watcom-zinc
wmake           & REM debug build
wmake release   & REM optimised
wmake clean
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

**macOS / Linux:**
```sh
dosbox-x -conf dosbox-x.conf
```

**Windows:**
```bat
dosbox-x.exe -conf dosbox-x.conf
```

The repo directory is mounted as `C:\` automatically. Inside DOSBox-X:

```
C:\> run.bat
```

---

## Project Structure

```
open-watcom-zinc/
├── src/
│   └── main.cpp               application source
├── makefile                   wmake build file (Open Watcom syntax)
├── dosbox-x.conf              DOSBox-X machine config
├── run.bat                    launch script (runs inside DOSBox-X)
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

This project is licensed under the **GNU Lesser General Public License v2.1 or later (LGPLv2+)**.  
See [LICENSE](LICENSE) for the full text.

**Upstream licenses:**
- Open Watcom is licensed under the [Sybase Open Watcom Public License 1.0](https://github.com/open-watcom/open-watcom-v2/blob/master/license.txt).
- Open Zinc is licensed under the LGPL — see [openzinc.com](http://www.openzinc.com/) for details.
