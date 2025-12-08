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
│   ├── color.rkt        ; NEW: Color utilities
│   └── texture.rkt      ; NEW: Texture management
├── image.rkt            ; Existing
└── ttf.rkt              ; Existing
```

---

## Phase 1: Window & Basic Loop (`hello-window.rkt`)

### New File: `safe/window.rkt`

**Core abstractions:**

```racket
;; Custodian-managed window
(define (make-window title width height
                     #:flags [flags 0]
                     #:custodian [cust (current-custodian)])
  ...)  ; Returns window, registers destroy with custodian

;; Custodian-managed renderer
(define (make-renderer window
                       #:name [name #f]
                       #:custodian [cust (current-custodian)])
  ...)

;; Simple init that raises proper exn:fail on error
(define (sdl-init! [flags SDL_INIT_VIDEO]) ...)

;; Higher-level: create both at once
(define (make-window+renderer title width height ...)
  (values window renderer))
```

**Benefits over raw:**
- No need for `dynamic-wind` cleanup - custodian handles it
- No null checks - raises exceptions with SDL error message
- Works with `call-with-custodian` for scoped cleanup

### New File: `safe/events.rkt`

**Event structs (transparent for `match`):**

```racket
(struct sdl-event () #:transparent)
(struct quit-event sdl-event () #:transparent)
(struct key-event sdl-event (type key scancode mod repeat?) #:transparent)
  ; type is 'down or 'up
  ; key is the keycode (integer for now, could be symbol later)
(struct mouse-motion-event sdl-event (x y xrel yrel state) #:transparent)
(struct mouse-button-event sdl-event (type button x y clicks) #:transparent)
  ; type is 'down or 'up
(struct text-input-event sdl-event (text) #:transparent)
(struct window-event sdl-event (type) #:transparent)
  ; type is 'shown, 'hidden, 'resized, 'close-requested, etc.

;; Poll returns #f or an event struct
(define (poll-event) ...)

;; Iterator for use with for loops
(define (in-events) ...)  ; sequence of events until none left
```

**Example usage:**

```racket
(for ([ev (in-events)])
  (match ev
    [(quit-event) (set! running? #f)]
    [(key-event 'down key _ _ _)
     #:when (= key SDLK_ESCAPE)
     (set! running? #f)]
    [_ (void)]))
```

### Update: `examples/hello-window.rkt`

**Before (81 lines):**
- Manual `malloc` for event buffer
- `dynamic-wind` for cleanup
- `ptr-ref` to read event type
- Manual null checks

**After (~40 lines):**
```racket
#lang racket/base
(require sdl3/safe)

(sdl-init!)

(define-values (window renderer)
  (make-window+renderer "SDL3 Racket - Hello Window" 800 600
                        #:flags SDL_WINDOW_RESIZABLE))

(let loop ()
  (for ([ev (in-events)])
    (match ev
      [(quit-event) (exit)]
      [_ (void)]))

  (set-draw-color! renderer 100 149 237)
  (render-clear! renderer)
  (render-present! renderer)
  (loop))
```

---

## Phase 2: Input Handling (`hello-input.rkt`)

### Additions to `safe/events.rkt`

- Ensure `key-event`, `mouse-motion-event`, `text-input-event` are complete
- Add key constants as symbols (optional, could keep integers)

### New File: `safe/draw.rkt`

```racket
;; Color as a single argument (r g b) or (r g b a)
(define (set-draw-color! renderer r g b [a 255]) ...)

;; Simple drawing
(define (render-clear! renderer) ...)
(define (render-present! renderer) ...)
```

### Update: `examples/hello-input.rkt`

**Key improvements:**
- `match` on events instead of type constants
- No `event->keyboard` casting
- No `SDL_KeyboardEvent-key` accessor

---

## Phase 3: Image Loading (`hello-image.rkt`)

### New File: `safe/texture.rkt`

```racket
;; Load texture with custodian management
(define (load-texture renderer path
                      #:custodian [cust (current-custodian)])
  ...)

;; Get texture size as values (no malloc)
(define (texture-size texture)
  (values width height))

;; Draw texture at position (simpler than raw)
(define (render-texture! renderer texture x y
                         #:src [src #f]
                         #:width [w #f]
                         #:height [h #f])
  ...)
```

### Update: `examples/hello-image.rkt`

**Key improvements:**
- No manual `malloc` for width/height pointers
- `load-texture` handles errors and cleanup
- Simpler `render-texture!` call

---

## Phase 4: Text Rendering (`hello-text.rkt`)

### New file or additions: `safe/ttf.rkt`

```racket
;; Custodian-managed font
(define (open-font path size
                   #:custodian [cust (current-custodian)])
  ...)

;; Render text to texture (handles surface->texture conversion)
(define (render-text font text color
                     #:renderer renderer
                     #:mode [mode 'blended])  ; 'solid, 'shaded, 'blended
  ...)

;; Or simpler: just draw text directly
(define (draw-text! renderer font text x y color) ...)
```

### Update: `examples/hello-text.rkt`

**Key improvements:**
- No manual surface->texture->destroy dance
- `draw-text!` is a single call
- Font auto-closes with custodian

---

## Phase 5: Shapes & Drawing (`hello-shapes.rkt`)

### Additions to `safe/draw.rkt`

```racket
;; Drawing with Racket data structures
(define (draw-point! renderer x y) ...)
(define (draw-points! renderer points) ...)  ; points is list of (x . y) or (list x y)

(define (draw-line! renderer x1 y1 x2 y2) ...)
(define (draw-lines! renderer points) ...)   ; connected lines

(define (draw-rect! renderer x y w h) ...)
(define (draw-rects! renderer rects) ...)    ; rects is list of (x y w h)

(define (fill-rect! renderer x y w h) ...)
(define (fill-rects! renderer rects) ...)
```

**Key insight:** Accept Racket lists/pairs, handle conversion to C arrays internally.

### Update: `examples/hello-shapes.rkt`

**Key improvements:**
- No `make-fpoint-array` / `make-frect-array` helpers
- Just pass lists directly

---

## Phase 6: Animation (`hello-animation.rkt`)

### Additions to `safe/window.rkt` or new `safe/time.rkt`

```racket
;; Already have SDL-GetTicks and SDL-Delay in raw
;; Could add:
(define (current-ticks) (SDL-GetTicks))
(define (delay! ms) (SDL-Delay ms))
```

This example mostly benefits from earlier phases (window, events, drawing).

### Update: `examples/hello-animation.rkt`

Uses: window, events, draw - should be cleaner with previous phases.

---

## Phase 7: Mouse (`hello-mouse.rkt`)

### Additions to `safe/events.rkt` or `safe/mouse.rkt`

```racket
;; Get mouse state without manual malloc
(define (mouse-state)
  (values x y button-mask))

;; Or structured:
(struct mouse-state (x y buttons) #:transparent)
(define (get-mouse-state) ...)

;; Button predicates
(define (mouse-button-pressed? state button) ...)
```

### Update: `examples/hello-mouse.rkt`

**Key improvements:**
- No `malloc` for x/y pointers
- Clean button state checking

---

## Implementation Order

| Phase | Files to Create/Modify | Example to Update |
|-------|------------------------|-------------------|
| 1 | `safe/window.rkt`, `safe/events.rkt`, `safe.rkt` | `hello-window.rkt` |
| 2 | `safe/draw.rkt` (basics) | `hello-input.rkt` |
| 3 | `safe/texture.rkt` | `hello-image.rkt` |
| 4 | `safe/ttf.rkt` | `hello-text.rkt` |
| 5 | `safe/draw.rkt` (shapes) | `hello-shapes.rkt` |
| 6 | (uses previous) | `hello-animation.rkt` |
| 7 | `safe/mouse.rkt` | `hello-mouse.rkt` |

---

## Design Decisions to Confirm

1. **Custodian vs explicit cleanup**: Default to custodian-managed, or provide both?
   - Recommendation: Default to current-custodian, allow override

2. **Event key representation**: Keep integer keycodes or add symbols?
   - Recommendation: Keep integers for now, symbols can be added later

3. **Color representation**: Separate args `(r g b a)` or struct/list?
   - Recommendation: Separate args with optional alpha (simpler, matches SDL)

4. **Rect representation**: Struct or list `(x y w h)`?
   - Recommendation: Accept lists for convenience, could add struct later

5. **Module naming**: `sdl3/safe` or `sdl3` with `sdl3/raw` for low-level?
   - Recommendation: `sdl3/safe` for now; could flip later when stable

---

## Testing Strategy

Each phase:
1. Implement the new safe module(s)
2. Update the corresponding example
3. Run the example to verify it works
4. Compare line count / complexity reduction

---

## Next Steps

Ready to begin Phase 1:
1. Create `safe/window.rkt` with `make-window`, `make-renderer`, `make-window+renderer`
2. Create `safe/events.rkt` with event structs and `poll-event` / `in-events`
3. Create `safe.rkt` that re-exports everything
4. Update `hello-window.rkt` to use the new interface
