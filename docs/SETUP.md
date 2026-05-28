# Environment Setup

## Prerequisites

### Open Watcom 2.0

The C++ compiler and linker for DOS/4GW targets.

**macOS (Homebrew)**

```bash
brew install open-watcom
```

Then set environment variables:

```bash
export WATCOM=$(brew --prefix open-watcom)
export PATH=$WATCOM/binl64:$PATH
```

**macOS (Manual Download)**

Download from [open-watcom/open-watcom-v2/releases](https://github.com/open-watcom/open-watcom-v2/releases), extract, and set:

```bash
export WATCOM=/path/to/watcom
export PATH=$WATCOM/binl64:$PATH
```

**Linux**

Download from [open-watcom/open-watcom-v2/releases](https://github.com/open-watcom/open-watcom-v2/releases), extract, and set:

```bash
export WATCOM=/path/to/watcom
export PATH=$WATCOM/binl:$PATH
```

**Windows**

Download the Windows installer from [open-watcom/open-watcom-v2/releases](https://github.com/open-watcom/open-watcom-v2/releases) and run it. The installer will set `WATCOM` automatically.

### Open Zinc

The UI framework library for DOS targets. Must be compiled for DOS/4GW.

Set the environment variable:

```bash
export ZINC_HOME=/path/to/zinc
```

The Zinc library should be at `$ZINC_HOME/LIB/OW2/D32_ZIL.LIB`.

### DOSBox-X

The emulator for testing DOS binaries.

**macOS (Homebrew)**

```bash
brew install dosbox-x
```

**macOS (Manual)**

Download from [DOSBox-X releases](https://github.com/joncampbell123/dosbox-x/releases), extract to `/Applications/DOSBox-X.app`, and the runner scripts will find it automatically.

**Linux**

```bash
# Install from your package manager or build from source
```

**Windows**

Download the Windows installer from [DOSBox-X releases](https://github.com/joncampbell123/dosbox-x/releases).

## Verification

Check that everything is set up:

```bash
# Check Open Watcom
which wpp386
wpp386 -v

# Check Open Zinc
ls $ZINC_HOME/LIB/OW2/D32_ZIL.LIB

# Check DOSBox-X
which dosbox-x
dosbox-x -version
```

## Full Environment

Add these to your shell profile (`~/.bashrc`, `~/.zshrc`, etc.):

```bash
# Open Watcom
export WATCOM=/opt/watcom          # or brew --prefix open-watcom
export PATH=$WATCOM/binl64:$PATH   # macOS/Linux, adjust for Windows

# Open Zinc
export ZINC_HOME=/opt/zinc         # or wherever you installed it
export INCLUDE=$ZINC_HOME/INCLUDE  # optional, makefiles set this
```

Then reload your shell:

```bash
source ~/.zshrc  # or ~/.bashrc, ~/.profile, etc.
```
