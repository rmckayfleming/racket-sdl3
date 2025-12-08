# Implementation Plan: Idiomatic Racket SDL3 Interface

This document outlines the plan for adding an idiomatic Racket layer on top of the raw FFI bindings.

## Goals

1. **Keep `raw.rkt`** - Power users can still access C-style bindings directly
2. **Add `safe.rkt`** - Idiomatic layer with:
   - Custodian-managed resources (automatic cleanup)
   - Racket structs for events (with `match` support)
   - Simpler APIs (fewer pointer manipulations)
   - Contracts for safety
3. **Update examples** one at a time to use the new interface

## Module Structure

```
sdl3/
├── raw.rkt              ; Existing C-style bindings (unchanged)
├── private/
│   ├── types.rkt        ; Existing (unchanged)
│   └── lib.rkt          ; Existing (unchanged)
├── safe.rkt             ; NEW: Idiomatic interface (re-exports all)
├── safe/
│   ├── window.rkt       ; NEW: Window & renderer management
│   ├── events.rkt       ; NEW: Event structs and polling
│   ├── draw.rkt         ; NEW: Drawing primitives
│   └── texture.rkt      ; NEW: Texture management (Phase 3)
├── image.rkt            ; Existing
└── ttf.rkt              ; Existing
```

---

## Phase 1: Window & Basic Loop (`hello-window.rkt`) - COMPLETED

### Files Created

- `safe/window.rkt` - Custodian-managed window and renderer
- `safe/events.rkt` - Event structs with match support, `poll-event`, `in-events`
- `safe/draw.rkt` - Basic drawing: `set-draw-color!`, `render-clear!`, `render-present!`, `delay!`
- `safe.rkt` - Re-exports all safe modules

### API Implemented

```racket
;; Initialization
(sdl-init! [flags])
(sdl-quit!)

;; Window (custodian-managed)
(make-window title width height #:flags #:custodian)
(make-renderer window #:name #:custodian)
(make-window+renderer title width height #:window-flags #:renderer-name #:custodian)
(window-destroy! window)
(renderer-destroy! renderer)
(window-set-title! window title)
(window-pixel-density window)

;; Events (structs work with match)
(poll-event)        ; returns #f or event struct
(in-events)         ; sequence for use with for

;; Event structs:
(quit-event)
(window-event type)           ; type: 'shown, 'hidden, 'close-requested, etc.
(key-event type key scancode mod repeat?)  ; type: 'down or 'up
(mouse-motion-event x y xrel yrel state)
(mouse-button-event type button x y clicks)
(text-input-event text)
(unknown-event type)

;; Drawing
(set-draw-color! renderer r g b [a])
(render-clear! renderer)
(render-present! renderer)
(delay! ms)
```

### Example Update

`hello-window.rkt`: **Reduced from 82 lines to 52 lines** (37% reduction)

Key improvements:
- No `ffi/unsafe` require
- No `malloc` for event buffer
- No `dynamic-wind` cleanup boilerplate
- No manual null checks
- Clean `match` on events with `for/or` and `in-events`

---

## Phase 2: Input Handling (`hello-input.rkt`) - COMPLETED

### Additions

- Added `key-name` function to `safe/events.rkt` (wraps `SDL-GetKeyName`)

### Example Update

`hello-input.rkt`: **Reduced from 127 lines to 89 lines** (30% reduction)

Key improvements:
- No `ffi/unsafe` require
- No `malloc` for event buffer
- No `dynamic-wind` cleanup
- Clean `match` on `key-event` and `mouse-motion-event` structs
- No manual event type casting (`event->keyboard`, `SDL_KeyboardEvent-key`, etc.)

---

## Phase 3: Image Loading (`hello-image.rkt`) - PENDING

### New File: `safe/texture.rkt`

```racket
(load-texture renderer path #:custodian)
(texture-size texture)  ; returns (values width height)
(render-texture! renderer texture x y #:src #:width #:height)
(destroy-texture! texture)
```

---

## Phase 4: Text Rendering (`hello-text.rkt`) - PENDING

### New File: `safe/ttf.rkt`

```racket
(open-font path size #:custodian)
(close-font! font)
(draw-text! renderer font text x y color)
(render-text font text color #:renderer #:mode)
```

---

## Phase 5: Shapes & Drawing (`hello-shapes.rkt`) - PENDING

### Additions to `safe/draw.rkt`

```racket
(draw-point! renderer x y)
(draw-points! renderer points)   ; accepts list of (x y) or (cons x y)
(draw-line! renderer x1 y1 x2 y2)
(draw-lines! renderer points)
(draw-rect! renderer x y w h)
(draw-rects! renderer rects)     ; accepts list of (x y w h)
(fill-rect! renderer x y w h)
(fill-rects! renderer rects)
```

---

## Phase 6: Animation (`hello-animation.rkt`) - PENDING

### Additions to `safe/draw.rkt`

```racket
(current-ticks)  ; wraps SDL-GetTicks
```

Mostly benefits from earlier phases.

---

## Phase 7: Mouse (`hello-mouse.rkt`) - PENDING

### New: `safe/mouse.rkt` or additions to `safe/events.rkt`

```racket
(get-mouse-state)  ; returns (values x y button-mask)
(mouse-button-pressed? mask button)
```

---

## Implementation Order

| Phase | Status | Files | Example |
|-------|--------|-------|---------|
| 1 | **DONE** | `safe/window.rkt`, `safe/events.rkt`, `safe/draw.rkt`, `safe.rkt` | `hello-window.rkt` |
| 2 | **DONE** | `safe/events.rkt` (added `key-name`) | `hello-input.rkt` |
| 3 | PENDING | `safe/texture.rkt` | `hello-image.rkt` |
| 4 | PENDING | `safe/ttf.rkt` | `hello-text.rkt` |
| 5 | PENDING | `safe/draw.rkt` (shapes) | `hello-shapes.rkt` |
| 6 | PENDING | (uses previous) | `hello-animation.rkt` |
| 7 | PENDING | `safe/mouse.rkt` | `hello-mouse.rkt` |

---

## Design Decisions (Confirmed)

1. **Custodian-managed resources** - Default to current-custodian, allow `#:custodian` override
2. **Event keys** - Keep integers for now, symbols can be added later
3. **Colors** - Separate args `(r g b [a])` with optional alpha defaulting to 255
4. **Rects** - Will accept lists `(x y w h)` for convenience (Phase 5)
5. **Module naming** - `sdl3/safe` for idiomatic, `sdl3/raw` for C-style
