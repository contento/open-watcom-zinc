# Hello, World! — Open Watcom + Open Zinc Tutorial

A minimal tutorial application demonstrating basic Open Zinc UI development for DOS/4GW 386 extended mode.

## Overview

This example shows:
- Creating a simple `UIW_WINDOW` subclass
- Adding UI elements (title, prompts, buttons)
- Handling button events
- Building and running on DOSBox-X

## Building

```bash
cd examples/hello-world
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

### Define a Window Class

```cpp
class HelloWindow : public UIW_WINDOW {
public:
    enum { ID_BTN_EXIT = 100 };
    
    HelloWindow() : UIW_WINDOW(x, y, width, height, style) {
        // Add UI elements here with operator+
    }
    
    virtual EVENT_TYPE Event(const UI_EVENT &event) {
        // Handle events
    }
};
```

### Add UI Elements

```cpp
*this + new UIW_TITLE("Hello, World!")
     + new UIW_PROMPT(col, row, width, "Text")
     + new UIW_BUTTON(col, row, width, "Label", ..., callback_id);
```

### Handle Button Events

```cpp
case ID_BTN_EXIT:
    if (UI_WINDOW_OBJECT::eventManager)
        UI_WINDOW_OBJECT::eventManager->Put(UI_EVENT(L_EXIT));
    return (EVENT_TYPE)L_EXIT;
```

### Entry Point

```cpp
int UI_APPLICATION::Main(void) {
    windowManager->Add(new HelloWindow);
    return (int)Control();
}
```

## Next Steps

- Check `examples/basic-demo/` for a more advanced example with input fields and multiple buttons.
- See `docs/BUILDING.md` for detailed build instructions.
