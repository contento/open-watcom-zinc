# Handoff: Open Watcom + Zinc DOS Examples

**Date:** 2026-05-28  
**Status:** Partially Working — Key Issues Identified

## What Works ✅

### Tutorials (vendor/zinc/TUTOR/HELLO)
- **hello1.exe** — Builds and runs successfully in DOSBox-X
- **hello2.exe** — Builds and runs successfully in DOSBox-X
- Built via `scripts/build-tutorials.sh`

### Key Fix Applied
The original issue: **Zinc library was precompiled for Open Watcom 1.9**, but the project uses **Open Watcom 2.0**, which changed C++ name mangling. This made the prebuilt library binary-incompatible.

**Solution:** Rebuilt the Zinc library from source using OW2:
```bash
sh scripts/build-zinc-ow2.sh
```

This compiles all Zinc source files and creates `vendor/zinc/LIB/OW2/D32_ZIL.LIB`.

### Text-Only Linking Fix
For text-mode DOS apps, the tutorials use a special technique:
1. Compile `z_app.CPP` with `-dZIL_TEXT_ONLY` flag
2. Link the resulting object **before** the main Zinc library
3. This overrides the library's UI_APPLICATION with a text-only version
4. **Avoids needing graph.lib** (which had missing symbols)

**Updated all example makefiles** to use this approach:
- examples/hello-world/makefile
- examples/basic-demo/makefile
- examples/basic-demo-text/makefile
- examples/phone-keypad/makefile
- examples/phone-keypad-fresh/makefile

## What Doesn't Work ❌

### Examples (examples/* directories)
- **hello-world, basic-demo, basic-demo-text, phone-keypad variants**
- Build successfully but **crash at runtime** with triple fault in DOSBox-X
- Symptom: "Packed file is corrupt" warning, followed by CPU exceptions

**Hypothesis:** Despite having the correct font path (`vendor/zinc/BIN/HELVB.FON`), something in the executable initialization is broken. Possible causes:
1. Executable is genuinely corrupt (rebuild didn't work)
2. Linking order or flags differ from tutorials
3. Example source code has issues not present in hello1/hello2/hello3

### hello3.exe
- Built by build-tutorials.sh but crashes at runtime
- Loads windows from hello.dat (more complex than hello1/hello2)
- May indicate an issue with the Zinc Designer file format handling

## Configuration Changes

### Mouse Support
Added `[mouse]` section with `mouse=true` to all dosbox-x.conf files:
- Root dosbox-x.conf
- All examples/*/dosbox-x.conf
- tutorials/hello/dosbox-x.conf (created)

### DOS Aliases
Added DOSKEY aliases to root dosbox-x.conf for convenience (ls, rm, cp, etc.).
Note: IDE flags these as unknown, but they work at runtime.

## Next Steps

### To Fix Examples
1. **Compare example makefiles with build-tutorials.sh** — they should be identical in linking strategy
2. **Check if .obj files are actually being relinked** — add verbose output to wmake
3. **Try building with response file** (like tutorials do) instead of inline linker directives
4. **Verify CXXFLAGS are identical** between examples and tutorials
5. **Examine example source code** for initialization issues that tutorials don't have

### To Fix hello3
- Debug the Zinc Designer data loading (hello.dat parsing)
- Check if hello.dat is valid/complete
- Look for memory/stack issues in d_wccdsp.CPP (graphics display)

### Alternative Approach
If examples continue to fail, consider:
- Strip examples down to minimal hello1-level code
- Gradually add features from there
- Use strace/gdb equivalent in DOSBox-X to identify crash point

## Key Files

| File | Purpose |
|------|---------|
| scripts/build-zinc-ow2.sh | Rebuilds Zinc library from source |
| scripts/build-tutorials.sh | Builds working hello1/hello2/hello3 |
| examples/*/makefile | Example build configs (now fixed) |
| CLAUDE.md | Project documentation |
| vendor/zinc/LIB/OW2/D32_ZIL.LIB | OW2-compiled Zinc library (rebuilt) |

## Environment

- **Open Watcom 2.0** — $WATCOM env var should be set
- **Open Zinc** — in vendor/zinc/
- **DOSBox-X** — for testing (requires dosbox-x.conf with mouse enabled)
- **DOS 6.22** — emulated target OS version

## Commands to Rebuild

```bash
# Rebuild Zinc library
sh scripts/build-zinc-ow2.sh

# Rebuild tutorials
sh scripts/build-tutorials.sh

# Rebuild individual example
cd examples/hello-world
wmake clean
wmake

# Test in DOSBox-X
dosbox-x -conf examples/hello-world/dosbox-x.conf
```

---

**Last Commit:** fc7cdfb — Fix Open Zinc examples: rebuild library for OW2, fix makefiles, enable mouse
