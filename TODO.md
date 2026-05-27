# TODO — Open Watcom + Zinc DOS Demo

## Phase 1: Environment Setup

- [ ] **1.1** Install Open Watcom 2.0 on host machine
  - macOS: download `open-watcom-2_0-c-macosx-x64` from GitHub releases
  - Set `WATCOM` env var and add `$WATCOM/binl64` to `PATH`
  - Verify: `wpp386 --version`

- [ ] **1.2** Obtain Open Zinc source
  - Clone from the Open Zinc repository (or use a packaged release)
  - Compile for DOS/4GW target using Open Watcom
  - Set `ZINC_HOME` to the compiled Zinc root
  - Verify: `$ZINC_HOME/include/ui_win.hpp` exists and `$ZINC_HOME/lib/zinc32d.lib` is built

- [ ] **1.3** Install DOSBox-X on host
  - macOS: `brew install dosbox-x` or download from dosbox-x.com
  - Verify it launches: `dosbox-x --version`

- [ ] **1.4** Mount and test a minimal DOS environment in DOSBox-X
  - Confirm `dosbox-x.conf` (in this repo) boots correctly
  - Confirm `HIMEM.SYS` and `EMM386.EXE` equivalents are active for extended memory

## Phase 2: Build System

- [ ] **2.1** Verify `wmake` finds the makefile and reports correct flags
  - Run `wmake -n` (dry run) and inspect the command lines
  - Confirm `-bt=dos4g`, `-3`, `-mf` are present

- [ ] **2.2** Confirm Zinc headers resolve without errors
  - Add a `test_includes` target that only preprocesses `src/main.cpp`
  - Fix any missing include paths

- [ ] **2.3** Confirm Zinc library links without undefined symbols
  - Build `demo.exe` and check `wlink` output for unresolved externals

## Phase 3: Core Application

- [ ] **3.1** Hello World window
  - Minimal `DemoApp` + `DemoWindow` showing a title and static text label
  - Verify it compiles and runs in DOSBox-X without crashing

- [ ] **3.2** Add interactive controls
  - Push button that changes the text label (demonstrates event handling)
  - Input field (`UIW_STRING`) that echoes text into the label

- [ ] **3.3** Add a menu bar
  - `File` menu with `Exit` item
  - `Help` menu with `About` item showing a modal dialog

- [ ] **3.4** About dialog
  - Custom `UIW_WINDOW` subclass as a modal popup
  - Shows app name, version, target info ("DOS/4GW 386 Extended")
  - OK button closes it

## Phase 3b: WCC Graphics Mode (next demo target)

- [ ] **3b.1** Switch Zinc library build to WCC graphics display
  - In `scripts/build-zinc-ow2.sh`: compile `z_app.CPP` with `-dWCC` (not `-dZIL_TEXT_ONLY`)
  - Add `d_wccdsp` back to SOURCES in build script (`UI_WCC_DISPLAY` implementation)
  - Rebuild `vendor/zinc/LIB/OW2/D32_ZIL.LIB`
  - The `graph.lib` aliases already in the makefile cover all WCC display functions

- [ ] **3b.2** Target 640×480 16-color as baseline graphics mode
  - `_VRES16COLOR` — standard VGA, no VESA required, stable in DOSBox-X
  - If higher resolution needed: 800×600 with `machine=svga_s3` and `vesa_oldvbe=false` in DOSBox-X conf

- [ ] **3b.3** Verify WCC fallback path
  - `z_app.CPP` with `-dWCC` automatically falls back to `UI_TEXT_DISPLAY` if graphics init fails
  - Test on both graphics and text-mode DOSBox-X configs

## Phase 4: DOSBox-X Integration & Testing

- [ ] **4.1** Verify `demo.exe` launches from DOSBox-X via `run.bat`
  - Confirm DOS/4GW stub banner appears briefly then Zinc UI opens
  - Test with `core=dynamic` and `core=normal` in `dosbox-x.conf`

- [ ] **4.2** Keyboard navigation
  - Tab between controls works
  - Enter activates focused button
  - Alt+F opens File menu

- [ ] **4.3** Screen resolution / mode
  - Confirm text mode 80x25 renders correctly
  - (Optional) Try 80x50 if Zinc text driver supports it

- [ ] **4.4** Memory test
  - Run with `memsize=4` (4 MB) to confirm DOS/4GW extended memory usage is sane
  - No crashes or "out of memory" from Zinc allocator

## Phase 5: Polish & Documentation

- [ ] **5.1** Release build
  - Switch from `-d2` (debug) to `-d0 -s -os` (optimised, no debug)
  - Compare binary size

- [ ] **5.2** Update CLAUDE.md with any build lessons learned

- [ ] **5.3** Add a `BUILDING.md` with step-by-step instructions for a new developer

## Known Risks / Notes

- Current build uses `UI_TEXT_DISPLAY` (`-dZIL_TEXT_ONLY`). Switch to `UI_WCC_DISPLAY` (`-dWCC`) for graphics demos — see Phase 3b. The wlink alias directives in the makefile already cover both display modes.
- For WCC graphics: target 640×480 16-color (`_VRES16COLOR`) for stability; SVGA (800×600+) needs `vesa_oldvbe=false` in DOSBox-X conf.
- DOS/4GW is included with Open Watcom but check version — newer DOS4GW.EXE may need to be distributed alongside `demo.exe` on real DOS.
- Open Watcom's C++ exception support is off by default for DOS targets; Zinc does not use exceptions, so this is fine.
- Long file names are not available under plain DOS 6.x — all source files and output names must be 8.3.
