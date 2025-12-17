# Repository Restructuring Plan

This document outlines the plan for restructuring the racket-sdl3 repository to make the safe, idiomatic interface the default.

## Goals

1. **Make safe the default**: `(require sdl3)` gives the idiomatic Racket API
2. **Raw access via sdl3/raw**: Low-level C-style bindings for power users
3. **Consistent module structure**: Both raw/ and safe/ follow the same organization
4. **Move implementation details to private/**: Keep public directories clean

## Current Structure

```
racket-sdl3/
├── main.rkt          # Re-exports raw.rkt (PROBLEM: raw is default)
├── raw.rkt           # Monolithic 1,800-line FFI bindings
├── safe.rkt          # Aggregates safe/* modules
├── image.rkt         # Top-level oddity
├── ttf.rkt           # Top-level oddity
├── private/
│   ├── lib.rkt
│   ├── syntax.rkt
│   └── types.rkt     # Large 1,300-line file
├── safe/
│   ├── syntax.rkt    # Should be in private/
│   ├── window.rkt
│   ├── draw.rkt
│   ├── texture.rkt
│   ├── events.rkt
│   ├── keyboard.rkt
│   ├── mouse.rkt
│   ├── audio.rkt
│   ├── display.rkt
│   ├── clipboard.rkt
│   ├── dialog.rkt
│   ├── timer.rkt
│   └── ttf.rkt
└── examples/
```

## Target Structure

```
racket-sdl3/
├── main.rkt              # Re-exports safe.rkt (safe is default)
├── raw.rkt               # Aggregates all raw/* modules
├── safe.rkt              # Aggregates all safe/* modules
│
├── raw/                  # Low-level FFI bindings by subsystem
│   ├── init.rkt          # SDL-Init, SDL-Quit, version info
│   ├── window.rkt        # Window creation/management
│   ├── render.rkt        # Renderer, basic drawing
│   ├── texture.rkt       # Texture management
│   ├── surface.rkt       # Surface operations
│   ├── events.rkt        # Event polling and types
│   ├── keyboard.rkt      # Keyboard functions
│   ├── mouse.rkt         # Mouse functions
│   ├── audio.rkt         # Audio device/stream
│   ├── display.rkt       # Display/monitor info
│   ├── clipboard.rkt     # Clipboard access
│   ├── dialog.rkt        # File dialogs, message boxes
│   ├── timer.rkt         # Timing functions
│   ├── hints.rkt         # Configuration hints
│   ├── image.rkt         # SDL_image bindings (moved from top-level)
│   └── ttf.rkt           # SDL_ttf bindings (moved from top-level)
│
├── safe/                 # Idiomatic wrappers (parallel structure)
│   ├── window.rkt
│   ├── draw.rkt
│   ├── texture.rkt
│   ├── events.rkt
│   ├── keyboard.rkt
│   ├── mouse.rkt
│   ├── audio.rkt
│   ├── display.rkt
│   ├── clipboard.rkt
│   ├── dialog.rkt
│   ├── timer.rkt
│   ├── image.rkt         # New: safe surface loading/saving
│   └── ttf.rkt           # Updated requires
│
├── private/
│   ├── lib.rkt           # Library loading, define-sdl macro
│   ├── syntax.rkt        # Error handling helpers
│   ├── safe-syntax.rkt   # Resource wrapping macros (moved from safe/)
│   ├── types.rkt         # Struct definitions
│   ├── constants.rkt     # Flags and enum values (split from types)
│   └── enums.rkt         # Keycodes, scancodes (split from types)
│
└── examples/             # Update imports as needed
```

## Access Patterns After Restructuring

| Want | Require |
|------|---------|
| Safe API (default) | `sdl3` |
| All raw bindings | `sdl3/raw` |
| Specific raw module | `sdl3/raw/window` |
| Specific safe module | `sdl3/safe/window` |

---

## Phase 1: Move safe/syntax.rkt to private/

Low-risk change that establishes the pattern.

### Steps

1. Create `private/safe-syntax.rkt` with contents of `safe/syntax.rkt`
2. Update all `safe/*.rkt` files to require `"../private/safe-syntax.rkt"` instead of `"syntax.rkt"`
3. Delete `safe/syntax.rkt`
4. Test: `raco make safe.rkt && racket examples/01-window.rkt`

### Files Modified
- `private/safe-syntax.rkt` (new)
- `safe/window.rkt`
- `safe/draw.rkt`
- `safe/texture.rkt`
- `safe/display.rkt`
- `safe/dialog.rkt`
- `safe/syntax.rkt` (deleted)

---

## Phase 2: Split raw.rkt into raw/*.rkt

The largest mechanical change. Split the monolithic raw.rkt by SDL subsystem.

### Module Breakdown

Based on the current raw.rkt sections:

| New Module | Contents |
|------------|----------|
| `raw/init.rkt` | SDL-Init, SDL-Quit, SDL-WasInit, SDL-GetError, SDL-ClearError, version functions |
| `raw/window.rkt` | SDL-CreateWindow, SDL-DestroyWindow, SDL-GetWindowSize, SDL-SetWindowTitle, etc. |
| `raw/render.rkt` | SDL-CreateRenderer, SDL-DestroyRenderer, SDL-RenderClear, SDL-RenderPresent, SDL-SetRenderDrawColor, drawing primitives |
| `raw/texture.rkt` | SDL-CreateTexture, SDL-DestroyTexture, SDL-CreateTextureFromSurface, SDL-RenderTexture, etc. |
| `raw/surface.rkt` | SDL-CreateSurface, SDL-DestroySurface, SDL-BlitSurface, etc. |
| `raw/events.rkt` | SDL-PollEvent, SDL-WaitEvent, SDL-PushEvent, event type constants |
| `raw/keyboard.rkt` | SDL-GetKeyboardState, SDL-GetModState, scancode/keycode functions |
| `raw/mouse.rkt` | SDL-GetMouseState, SDL-WarpMouseInWindow, SDL-SetCursor, etc. |
| `raw/audio.rkt` | SDL-OpenAudioDevice, SDL-CloseAudioDevice, audio stream functions |
| `raw/display.rkt` | SDL-GetDisplays, SDL-GetDisplayBounds, display mode functions |
| `raw/clipboard.rkt` | SDL-GetClipboardText, SDL-SetClipboardText, etc. |
| `raw/dialog.rkt` | SDL-ShowOpenFileDialog, SDL-ShowSaveFileDialog, SDL-ShowMessageBox |
| `raw/timer.rkt` | SDL-GetTicks, SDL-Delay, performance counter functions |
| `raw/hints.rkt` | SDL-SetHint, SDL-GetHint |

### Steps

1. Create `raw/` directory
2. Create each `raw/*.rkt` module:
   - Copy relevant functions from current `raw.rkt`
   - Add appropriate requires (private/lib.rkt, private/types.rkt)
   - Add provides for all functions
3. Create new `raw.rkt` that re-exports all `raw/*.rkt` modules
4. Update `safe/*.rkt` files to require from `raw.rkt` (or specific raw modules)
5. Delete old raw.rkt content (it becomes the aggregator)
6. Test: `raco make raw.rkt && raco make safe.rkt`

### Dependencies Between raw/ Modules

Most raw modules are independent, but some share dependencies:
- All require `private/lib.rkt` and `private/types.rkt`
- `raw/render.rkt` may need window pointer types
- `raw/texture.rkt` needs renderer and surface pointer types

These dependencies are on types, not functions, so modules remain independent.

---

## Phase 3: Move image.rkt and ttf.rkt to raw/

Move the extension library bindings into the raw/ directory structure.

### Steps

1. Move `image.rkt` to `raw/image.rkt`
   - Update require paths (private/ becomes ../private/)
2. Move `ttf.rkt` to `raw/ttf.rkt`
   - Update require paths
3. Update `raw.rkt` aggregator to include image and ttf
4. Update `safe/texture.rkt` to require `"../raw/image.rkt"` or `"../raw.rkt"`
5. Update `safe/ttf.rkt` to require `"../raw/ttf.rkt"` or `"../raw.rkt"`
6. Test: `racket examples/04-image.rkt && racket examples/05-text.rkt`

---

## Phase 4: Create safe/image.rkt

Add a safe wrapper for image operations that aren't texture-related.

### New Module: safe/image.rkt

```racket
;; Surface loading with custodian cleanup
load-surface      ; path -> surface
surface?
surface-destroy!

;; Saving
save-png!         ; surface path -> void
save-jpg!         ; surface path quality -> void
```

### Steps

1. Create `safe/image.rkt` with surface wrapper struct
2. Implement `load-surface` using `IMG-Load` with custodian registration
3. Implement `save-png!` and `save-jpg!` wrappers
4. Update `safe.rkt` to require and re-export `safe/image.rkt`
5. Test with a new example or manual REPL test

---

## Phase 5: Flip main.rkt to safe

The actual "flip" - make safe the default interface.

### Steps

1. Update `main.rkt`:
   ```racket
   #lang racket/base
   (require "safe.rkt")
   (provide (all-from-out "safe.rkt"))
   ```
2. Update any examples using `(require sdl3)` expecting raw bindings
   - `examples/15-repl.rkt` uses raw - change to `(require sdl3/raw)`
3. Test all examples

---

## Phase 6: Update Examples and Documentation

Ensure everything works with the new structure.

### Steps

1. Run all examples, fix any broken imports
2. Update CLAUDE.md with new structure documentation
3. Update any doc comments referring to old structure

---

## Phase 7 (Optional): Split private/types.rkt

If types.rkt continues to grow, split it for maintainability.

### Proposed Split

| New Module | Contents |
|------------|----------|
| `private/types.rkt` | Struct definitions (_SDL_Point, _SDL_Rect, _SDL_Color, etc.) |
| `private/constants.rkt` | Init flags, window flags, event types, blend modes |
| `private/enums.rkt` | Keycodes, scancodes, other large enumerations |

### Steps

1. Create `private/constants.rkt` with flag definitions
2. Create `private/enums.rkt` with keycode/scancode tables
3. Update `private/types.rkt` to require and re-export (for backwards compat)
4. Update raw/ modules to require specific files as needed
5. Test everything

---

## Testing Strategy

After each phase:

1. Clear compiled cache: `rm -rf compiled private/compiled safe/compiled raw/compiled examples/compiled`
2. Compile aggregators: `raco make main.rkt raw.rkt safe.rkt`
3. Run example subset:
   - `racket examples/01-window.rkt` (basic)
   - `racket examples/02-input.rkt` (events)
   - `racket examples/04-image.rkt` (image loading)
   - `racket examples/05-text.rkt` (ttf)
   - `racket examples/15-repl.rkt` (raw bindings)

---

## Rollback Plan

If issues arise:
1. Git stash or branch before starting each phase
2. Each phase is independently revertible
3. The aggregator pattern (raw.rkt re-exporting raw/*) means external code keeps working

---

## Estimated Scope

| Phase | Files Changed | Risk |
|-------|---------------|------|
| 1. Move safe/syntax.rkt | ~7 | Low |
| 2. Split raw.rkt | ~20 | Medium (largest change) |
| 3. Move image.rkt, ttf.rkt | ~5 | Low |
| 4. Create safe/image.rkt | ~2 | Low |
| 5. Flip main.rkt | ~3 | Low |
| 6. Update docs/examples | ~5 | Low |
| 7. Split types.rkt | ~10 | Low (optional) |
