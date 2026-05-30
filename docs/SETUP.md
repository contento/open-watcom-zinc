# Environment Setup

## Quick Start

Run the setup script for your platform — it downloads Open Watcom 2.0 and
Open Zinc into `vendor/` and builds the Zinc library:

**macOS / Linux**
```bash
bash scripts/setup.sh         # install
source scripts/setup.sh        # add to current shell
```

**Windows (PowerShell)**
```powershell
.\scripts\setup.ps1           # dot-source to persist env vars
```

Then build any example:
```bash
cd examples/hello-world
wmake                          # debug build (text mode, safe on DOSBox-X)
wmake ZINC_DISPLAY=WCC        # VGA graphics (may crash DOSBox-X, see BUILD.md)
```

## What the setup scripts do

1. Download Open Watcom 2.0 snapshot (~140 MB) and extract to `vendor/watcom/`
2. Download Open Zinc source to `vendor/zinc/`
3. Build `D32_ZIL.LIB` (Zinc library for OW2) into `vendor/zinc/LIB/OW2/`

After setup, `WATCOM`, `ZINC_HOME`, and `PATH` point to the vendored copies.
The makefiles resolve these paths automatically — no manual configuration needed.

## Manual Installation

If you prefer a system-wide install:

**macOS**
```bash
brew install open-watcom
export WATCOM=$(brew --prefix open-watcom)
export PATH=$WATCOM/binl64:$PATH
```

**Linux** — download from [releases](https://github.com/open-watcom/open-watcom-v2/releases):
```bash
# Download open-watcom-2_0-c-linux-x64 from Current-build release
export WATCOM=/opt/watcom
export PATH=$WATCOM/binl64:$PATH
```

**Windows** — download the installer from [releases](https://github.com/open-watcom/open-watcom-v2/releases) and run. The installer sets `WATCOM` automatically.

## DOSBox-X

Install DOSBox-X to test the built EXEs:

**macOS**
```bash
brew install --cask dosbox-x
```

**Linux / Windows** — see [DOSBox-X releases](https://github.com/joncampbell123/dosbox-x/releases)

## Verification

```bash
wpp386 -v
ls vendor/zinc/LIB/OW2/D32_ZIL.LIB
dosbox-x -version
```