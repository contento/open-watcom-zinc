# Phone Keypad Example

A classic phone keypad (1-9, *, 0, #) interface built with **Open Watcom 2.0** and **Open Zinc** for DOS.

## What It Demonstrates

- **UI Layout**: 3×4 grid of buttons arranged like a traditional phone keypad
- **Open Zinc Basics**: Window creation, button layout, event handling
- **Text-Mode DOS**: Runs in text-only mode under DOS/4GW

**Future enhancements:** accumulate digits on keypresses, clear button, T9 prediction (mapping digits to letters like on old mobile phones)

## Building

```bash
wmake           # debug build
wmake release   # optimized build
sh run.sh       # launch in DOSBox-X (macOS/Linux)
run.bat         # launch in DOSBox-X (Windows)
```

See [../hello-world/README.md](../hello-world/README.md) for general setup instructions.
