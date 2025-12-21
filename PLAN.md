# Idiomatic API Plan

Goal: make the safe API feel like Racket while keeping the raw layer available.

See `safe/CONVENTIONS.md` for the target conventions.

## Current State Summary

The safe API has good foundations:
- Custodian-based resource management works
- Event structs are transparent and work with `match`
- Mouse buttons in events already use symbols (`'left`, `'middle`, `'right`)
- Gamepad axes/buttons use symbols (`'left-x`, `'south`)
- Basic rect/frect support with accessors

Main gaps:
- Keyboard input requires `SDL_SCANCODE_*` / `SDLK_*` constants
- Window/init flags require `SDL_*` constants
- Some APIs take raw pointers instead of safe wrapper objects
- No scoped resource helpers (`call-with-*`)
- `rect-line-intersection` returns a list instead of multiple values

## Phase 1: Symbol-Based Keyboard Input (High Priority) ✅ COMPLETE

This is the biggest friction point in examples.

### 1.1 Key Symbol Mapping ✅
- [x] Create bidirectional mapping between symbols and scancodes/keycodes
- [x] Handle letter keys: `'a` through `'z` (case-insensitive)
- [x] Handle number keys: `'0` through `'9`
- [x] Handle special keys: `'escape`, `'space`, `'return`, `'tab`, `'backspace`, `'delete`
- [x] Handle arrow keys: `'up`, `'down`, `'left`, `'right`
- [x] Handle modifier keys: `'left-shift`, `'right-shift`, `'left-ctrl`, `'right-ctrl`, `'left-alt`, `'right-alt`
- [x] Handle function keys: `'f1` through `'f12`
- [x] Handle navigation: `'home`, `'end`, `'page-up`, `'page-down`, `'insert`

### 1.2 Update Keyboard State API ✅
- [x] Modify `key-pressed?` to accept symbol or scancode
- [x] Modify `get-keyboard-state` to return procedure accepting symbol or scancode
- [x] Add `symbol->scancode` and `scancode->symbol` helpers
- [x] Add `symbol->keycode` and `keycode->symbol` helpers

### 1.3 Update Event Matching ✅
- [x] Modified `key-event` struct to provide key as symbol directly (not integer keycode)
- [x] Falls back to integer keycode for unknown keys
- [x] Enables clean pattern matching: `[(key-event 'down 'escape _ _ _) ...]`

### 1.4 Update Examples ✅
- [x] `examples/basics/input.rkt` - uses `(kbd 'w)`, `(kbd 'up)`, etc.
- [x] `examples/input/keyboard.rkt` - uses symbol-based matching
- [x] `examples/advanced/collision.rkt` - uses `(key-event 'down 'escape _ _ _)`
- [x] All 58 other examples and 3 demos updated to use symbol-based keys

## Phase 2: Symbol-Based Flags (Medium Priority)

### 2.1 Window Flags
- [ ] Create mapping: `'resizable` -> `SDL_WINDOW_RESIZABLE`, etc.
- [ ] Update `make-window` to accept `#:flags '(resizable high-pixel-density)`
- [ ] Supported symbols:
  - `'resizable`, `'fullscreen`, `'borderless`, `'hidden`
  - `'high-pixel-density`, `'always-on-top`, `'minimized`, `'maximized`
  - `'opengl`, `'vulkan`, `'metal`

### 2.2 Init Flags
- [ ] Update `sdl-init!` to accept symbols: `(sdl-init! '(video audio))`
- [ ] Mapping: `'video`, `'audio`, `'events`, `'joystick`, `'gamepad`, `'camera`

### 2.3 Hint Names
- [ ] Add symbol-based hint names: `'render-vsync`, `'app-name`
- [ ] Update `set-hint!` / `get-hint` to accept symbols or strings

## Phase 3: Object-Based Parameters (Medium Priority)

### 3.1 Dialog Window Parameter
- [ ] Update `show-message-box` to accept `window` struct directly
- [ ] Update `show-confirm-dialog` similarly
- [ ] Update `open-file-dialog`, `save-file-dialog`, `open-folder-dialog`
- [ ] Extract pointer internally: `(if (window? w) (window-ptr w) w)`

### 3.2 Other Pointer Parameters
- [ ] Audit all safe APIs for raw pointer parameters
- [ ] Update to accept wrapper structs where applicable

## Phase 4: Scoped Resource Helpers (Medium Priority)

### 4.1 Core Scoped Helpers
- [ ] Add `call-with-sdl` - initializes SDL, calls thunk, quits SDL
- [ ] Add `call-with-window` - creates window, calls proc, destroys window
- [ ] Add `call-with-renderer` - creates renderer, calls proc, destroys renderer
- [ ] Add `call-with-window+renderer` - combines window and renderer creation

### 4.2 Syntax Forms (Optional)
- [ ] Consider `with-sdl`, `with-window`, etc. macros for prettier syntax
- [ ] These would just wrap the `call-with-*` procedures

## Phase 5: Geometry Cleanup (Low Priority)

### 5.1 Line Intersection
- [ ] Change `rect-line-intersection` to return `(values x1 y1 x2 y2)` or `#f`
- [ ] Change `frect-line-intersection` similarly
- [ ] Update any code using the list return value

### 5.2 Rect Conversion Helpers
- [ ] Add `rect->values`: `(define-values (x y w h) (rect->values r))`
- [ ] Add `frect->values` similarly
- [ ] These supplement existing accessors for convenient destructuring

## Phase 6: Documentation and Examples (Final)

### 6.1 Example Updates
- [ ] Revise all `examples/basics/` to be idiomatic
- [ ] Revise all `examples/input/` to use symbol-based keys
- [ ] Revise all `examples/advanced/`
- [ ] Keep `examples/graphics/` using raw access (OpenGL/Vulkan/GPU need it)

### 6.2 README Updates
- [ ] Add "Idiomatic Usage" section
- [ ] Show before/after comparisons
- [ ] Link to CONVENTIONS.md

### 6.3 Validation
- [ ] Run all examples with `PLTCOLLECTS="$PWD:"`
- [ ] Verify no regressions
- [ ] Check that new symbol-based APIs work correctly

## Non-Goals

- **Backwards compatibility**: Examples are the only consumers; breaking changes are fine
- **Graphics API wrappers**: OpenGL/Vulkan/GPU examples intentionally use raw FFI
- **Complete constant coverage**: Focus on commonly-used constants first

## Implementation Notes

### Symbol-to-Scancode Mapping Strategy

SDL provides `SDL_GetScancodeFromName` but the name format doesn't match our symbol conventions. Options:

1. **Lookup table**: Explicit hash table mapping symbols to scancodes
   - Pro: Full control over symbol names
   - Con: Manual maintenance

2. **String conversion**: Convert symbol to string, adjust format, call SDL
   - Pro: Leverages SDL's mapping
   - Con: Some names don't convert cleanly (e.g., "Left Shift" vs `'left-shift`)

Recommended: Use a lookup table for common keys, fall back to SDL conversion for others.

### Key Symbol Naming

Follow these patterns:
- Letters: `'a`, `'b`, ..., `'z` (lowercase)
- Numbers: `'0`, `'1`, ..., `'9`
- Function keys: `'f1`, `'f2`, ..., `'f12`
- Modifiers: `'left-shift`, `'right-ctrl`, `'left-alt`, `'right-gui`
- Arrows: `'up`, `'down`, `'left`, `'right`
- Special: `'escape`, `'space`, `'return`, `'tab`, `'backspace`, `'delete`
- Navigation: `'home`, `'end`, `'page-up`, `'page-down`, `'insert`
- Keypad: `'kp-0`, `'kp-plus`, `'kp-enter`
