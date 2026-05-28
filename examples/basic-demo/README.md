# Basic Demo — Open Watcom + Open Zinc

A feature-rich demonstration application showcasing Open Zinc UI components and event handling for DOS/4GW 386 extended mode.

## Overview

This example demonstrates:
- Multiple UI components (buttons, text input, labels, menus)
- Menu bar with File and Help menus
- Modal dialogs
- Event handling and message passing
- String input and dynamic text output
- Stateful button interactions (click counter)

## Features

- **Click Counter**: Buttons that track how many times they've been clicked
- **Text Input**: Type into an input field and echo the text back
- **Modal Dialog**: About dialog reachable from the Help menu
- **Menu Bar**: File menu (Exit) and Help menu (About)
- **Debug Logging**: All major events logged to DEBUG.LOG

## Building

```bash
cd examples/basic-demo
wmake              # Debug build
wmake release      # Optimized build
wmake clean        # Remove generated files
```

## Running

### On macOS / Linux

```bash
sh run.sh          # Build and launch in DOSBox-X
sh run.sh -s       # Drop to DOS prompt only
sh run.sh --help   # Show usage
```

### On Windows

```batch
run.bat            # Build and launch in DOSBox-X
run.bat -s         # Drop to DOS prompt only
```

## Key Code Patterns

### Menu Creation

```cpp
UIW_PULL_DOWN_ITEM *fileMenu = new UIW_PULL_DOWN_ITEM("&File");
*fileMenu + new UIW_POP_UP_ITEM("E&xit", ..., callback_id);
*this + fileMenu;
```

### String Input Field

```cpp
inputField = new UIW_STRING(col, row, width, initial_value, max_len, flags, style);
ZIL_ICHAR *text = inputField->DataGet();
```

### Dynamic Text Output

```cpp
outputLabel = new UIW_TEXT(col, row, width, lines, initial_text);
outputLabel->DataSet(new_text);
outputLabel->Event(UI_EVENT(S_REDISPLAY));
```

### Modal Dialog

```cpp
class AboutDialog : public UIW_WINDOW {
    AboutDialog() : UIW_WINDOW(x, y, w, h, style, WOAF_MODAL) { ... }
};

// Show it
windowManager->Add(new AboutDialog);
```

## Debugging

Debug output is written to `DEBUG.LOG` in the current directory. After running the demo, check this file to see the order of events and function calls.

## Next Steps

- Start with `examples/hello-world/` for a simpler introduction to Zinc.
- See `docs/BUILDING.md` for detailed build instructions.
- Check Open Zinc documentation for the full API reference.
