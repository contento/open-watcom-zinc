# Contributing: Adding New Examples

## Structure

Each example is a self-contained folder under `examples/` with:

```
examples/new-example/
├── src/
│   └── main.cpp            ← your source code
├── makefile                ← copied from hello-world, edit TARGET name
├── dosbox-x.conf           ← symlink or copy from basic-demo
├── run.sh                  ← copied from hello-world, edit DEMO_EXE name
├── run.bat                 ← copied from basic-demo, edit demo.exe name
└── README.md               ← document the example
```

## Step by Step

### 1. Create the Directory

```bash
mkdir -p examples/my-example/src
```

### 2. Write Your Code

Create `examples/my-example/src/main.cpp`:

```cpp
#include <ui_win.hpp>

class MyWindow : public UIW_WINDOW {
public:
    MyWindow() : UIW_WINDOW(5, 2, 70, 20, WOF_BORDER) {
        *this + new UIW_TITLE("My Example");
        // Add your UI elements here
    }

    virtual EVENT_TYPE Event(const UI_EVENT &event) {
        // Handle events
        return UIW_WINDOW::Event(event);
    }
};

int UI_APPLICATION::Main(void) {
    windowManager->Add(new MyWindow);
    return (int)Control();
}
```

### 3. Copy & Customize Makefile

Copy from `examples/hello-world/makefile`:

```bash
cp examples/hello-world/makefile examples/my-example/makefile
```

Edit the `TARGET` variable:

```makefile
TARGET = myapp.exe    # change this
```

Keep everything else as-is; paths resolve correctly.

### 4. Copy Build/Run Scripts

```bash
cp examples/hello-world/dosbox-x.conf examples/my-example/
cp examples/hello-world/run.sh examples/my-example/
cp examples/hello-world/run.bat examples/my-example/
```

Edit `run.sh` and `run.bat` to replace the executable name:

**run.sh (line 7):**
```bash
DEMO_EXE="$SCRIPT_DIR/myapp.exe"    # change from hello.exe
```

**run.bat:**
```batch
REM Change demo.exe to your executable name
```

### 5. Write a README

Create `examples/my-example/README.md` documenting:
- What the example demonstrates
- Key code patterns
- How to build and run
- Next steps for learning

See `examples/hello-world/README.md` for a template.

### 6. Test

```bash
cd examples/my-example
wmake
sh run.sh    # or run.bat on Windows
```

The app should launch in DOSBox-X.

## Conventions

- **Keep examples focused** — each demo should teach one thing well
- **Order by complexity** — start with hello-world, progress to advanced features
- **Reuse infrastructure** — all examples share `vendor/`, `scripts/`, and `docs/`
- **C++98 code** — Open Watcom's C++11 support is incomplete; stick to C++98
- **Use Zinc objects** — never call DOS int 21h directly from UI code
- **Add a README** — document what learners will gain from the example

## Naming

Example directory names should:
- Be lowercase
- Use hyphens (not underscores)
- Be descriptive: `hello-world`, `text-menu`, `file-browser`, `graphics-demo`

## Shared Files

Do **not** duplicate:
- `vendor/zinc/` — shared library
- `vendor/watcom/` — shared compiler/linker
- `scripts/build-zinc-ow2.sh` — shared build script
- Anything in `docs/` — update the shared docs

These are maintained once in the root and referenced by all examples.

## Before Submitting

- [ ] Build succeeds: `wmake`
- [ ] Runs in DOSBox-X: `sh run.sh`
- [ ] README explains the example clearly
- [ ] Code follows C++98 conventions
- [ ] No unintended files committed (`.obj`, `.exe`, etc.)
- [ ] Makefile paths are relative (`../../vendor`, `../../scripts`)
