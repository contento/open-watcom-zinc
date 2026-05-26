# GitHub Copilot Instructions

## Project Context

This is a **DOS 32-bit extended** application written in **C++98**, built with **Open Watcom 2.0**, using the **Open Zinc** portable UI framework. The final binary runs on DOS 6.x (and DOSBox-X) via the DOS/4GW memory extender.

## Compiler & Language Rules

- **Compiler**: Open Watcom `wpp386` (C++) / `wcc386` (C). Do NOT suggest MSVC, GCC, or Clang extensions.
- **Standard**: C++98 only. No `auto`, no range-for, no lambdas, no `std::unique_ptr`, no `nullptr` (use `ZIL_NULLP(T)` or `NULL` instead).
- **Build system**: `wmake` (Open Watcom make). Syntax differs from GNU make — use `&` for line continuation, `.symbolic` for phony targets, `$+` not `$^`.
- **Memory model**: flat 32-bit (`-mf`). No `far`/`near`/`huge` pointers needed.

## Open Zinc API Conventions

- Windows derive from `UIW_WINDOW`; always call `Add()` to attach child controls.
- Controls: `UIW_PUSH_BUTTON`, `UIW_STRING`, `UIW_TEXT`, `UIW_INTEGER`, `UIW_COMBO_BOX`, `UIW_LIST`, `UIW_MENU`.
- Event handlers override `Event(const UI_EVENT &event)` and return `EVENT_TYPE`.
- Application class derives from `ZIL_APPLICATION`; the `Main()` method is the event loop.
- Use `ZIL_NULLP(UIW_WINDOW)` not `nullptr` or `NULL` when a typed null is needed.
- Do NOT use raw `new`/`delete` for Zinc objects that are `Add()`-ed — Zinc owns them.
- Include order: `<ui_win.hpp>` first, then other Zinc headers, then standard C headers.

## DOS/4GW Target Constraints

- No dynamic libraries — everything links statically.
- No POSIX threads, no sockets, no long file names (8.3 only on real DOS).
- File I/O: use standard C `fopen`/`fclose` or Zinc's `ZIL_FILE` wrappers.
- Avoid C++ exceptions (`-fno-exceptions` is default with Open Watcom for DOS targets).
- Stack size is limited — avoid large local arrays; prefer heap allocation.

## Naming & Style

- Class names: `PascalCase` (following Zinc convention: `UIW_WINDOW`-style for Zinc types).
- Local application classes: plain `PascalCase` (e.g., `DemoWindow`, `DemoApp`).
- Constants: `ALL_CAPS`.
- No trailing whitespace. Indent with 4 spaces (not tabs).
- No comments explaining *what* code does — only *why* if non-obvious.

## What to Avoid

- Do NOT suggest `std::cout` / `std::cin` in Zinc UI code — use Zinc widgets.
- Do NOT suggest `#pragma once` — use traditional include guards (`#ifndef MY_H`).
- Do NOT suggest C++11 or later features.
- Do NOT suggest Windows API, POSIX API, or any non-DOS-portable calls.
- Do NOT suggest dynamic/shared library linkage.
