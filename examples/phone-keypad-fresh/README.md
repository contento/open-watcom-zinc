# Phone Keypad Example

A classic phone keypad (1-9, *, 0, #) interface built with **Open Watcom 2.0** and **Open Zinc** for DOS.

## What It Demonstrates

- **UI Layout**: 3×4 grid of buttons arranged like a traditional phone keypad
- **Open Zinc Basics**: Window creation, button layout, event handling
- **Text-Mode DOS**: Runs in text-only mode under DOS/4GW

## Building & Running

```bash
sh build.sh         # Compile (auto-sets WATCOM)
sh run.sh           # Build + launch in DOSBox-X (macOS/Linux)
```

Or manually:

```bash
sh build.sh           # debug build
sh build.sh release   # optimized build
sh build.sh clean     # remove generated files
```

## Features

- Click any button to see "Pressed: [digit]" in the display
- Click "Clear" to reset the display
- All 12 buttons functional (1-9, *, 0, #)
