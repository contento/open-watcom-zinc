# Building Open Watcom + Open Zinc Examples

## Quick Start

1. Set up your environment (see [SETUP.md](SETUP.md))
2. Navigate to an example directory
3. Run `wmake` to build
4. Run the launcher script to test

```bash
cd examples/hello-world
wmake
sh run.sh          # macOS/Linux
```

## Build Targets

Each example's `makefile` supports these targets:

```bash
wmake              # Debug build with full symbols
wmake release      # Optimized build, smaller binary
wmake clean        # Remove .obj and .exe files
```

## Understanding the Build

### Compiler

```bash
wpp386 [flags] src/main.cpp
```

**Key flags:**
- `-bt=dos4g` — Build target: DOS/4GW 32-bit extended
- `-3` — Generate 80386 instructions
- `-mf` — Flat memory model (32-bit addressing)
- `-fp3` — 387 FPU instructions
- `-w4` — Warning level 4
- `-d2` — Full debug info (debug build) or `-d0` (release)
- `-ox` — Optimize (release only)

### Linker

```bash
wlink system dos4g name output.exe file input.obj lib zinc.lib ...
```

The `system dos4g` tells the linker to:
1. Link as a DOS/4GW target
2. Include the DOS/4GW runtime stub in the executable
3. Prepare for 32-bit protected mode execution

**Important aliases:** The linker aliases many graphics functions (e.g., `_setpixel_ = _setpixel`) to match Zinc's expectations.

## Zinc Library Building

The first time you build, the `makefile` automatically builds Zinc:

```bash
$(ZINC_LIB): 
	sh ../../scripts/build-zinc-ow2.sh
```

This script:
1. Checks if `$ZINC_HOME` is set
2. Builds Open Zinc for DOS/4GW target
3. Places the library at `$ZINC_HOME/LIB/OW2/D32_ZIL.LIB`

**Note:** This only happens once. To force a rebuild, delete the library file:

```bash
rm $ZINC_HOME/LIB/OW2/D32_ZIL.LIB
wmake
```

## Troubleshooting

### "wpp386: not found"

`$PATH` doesn't include the Open Watcom compiler. Check your environment:

```bash
echo $WATCOM
which wpp386
```

If blank, set `$WATCOM` and add to `$PATH` (see [SETUP.md](SETUP.md)).

### "Cannot open file $ZINC_HOME/LIB/OW2/D32_ZIL.LIB"

Zinc library is missing or `$ZINC_HOME` is wrong. Check:

```bash
echo $ZINC_HOME
ls $ZINC_HOME/LIB/OW2/D32_ZIL.LIB
```

If the file doesn't exist, rebuild Zinc:

```bash
rm $ZINC_HOME/LIB/OW2/D32_ZIL.LIB
wmake
```

### Linker errors about undefined symbols

Typically caused by:
1. Missing linker aliases (check `makefile` has all the graphics aliases)
2. Wrong Zinc library version (must be DOS/4GW)
3. Missing DOS runtime libraries (clib3r.lib, etc.)

## Build Artifacts

After building, you'll see:

```
examples/basic-demo/
├── main.obj        ← compiled object file
├── demo.exe        ← final executable (DOS/4GW stub + code)
└── *.err           ← compiler errors (if any)
```

Clean these up with:

```bash
wmake clean
```

## Environment Variables

The makefiles use these variables:

| Variable | Default | Meaning |
| --- | --- | --- |
| `ZINC_HOME` | `../../vendor/zinc` | Open Zinc root directory |
| `RELEASE` | (unset) | Set to 1 for optimized build |

Override on the command line:

```bash
wmake ZINC_HOME=/custom/path
wmake RELEASE=1
```

## Cross-Compilation

These examples are designed to cross-compile: you build on macOS/Linux/Windows and produce DOS executables.

No special configuration is needed — the Open Watcom linker (`wlink system dos4g`) handles all the details.
