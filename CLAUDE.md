# CLAUDE.md

## Quick Reference

- **Default API**: `(require sdl3)` → safe, idiomatic Racket interface
- **Low-level API**: `(require sdl3/raw)` → C-style FFI bindings
- Always prefer the safe API unless you need direct pointer access

## Build & Run

```bash
# Run examples directly (Racket auto-compiles as needed)
/opt/homebrew/bin/racket examples/01-window.rkt
/opt/homebrew/bin/racket examples/02-input.rkt
```

Racket automatically creates `compiled/` directories for bytecode caching. Usually this just works. If you hit strange errors after modifying types or structs (e.g., "identifier not found" for something you just added), clear the cache:

```bash
make clean
```

## Project Structure

```
racket-sdl3/
├── main.rkt          # Package entry point, re-exports safe.rkt
├── safe.rkt          # Aggregates all safe/* modules
├── raw.rkt           # Aggregates all raw/* modules
│
├── raw/              # Low-level FFI bindings by subsystem
│   ├── init.rkt      # SDL-Init, SDL-Quit, errors
│   ├── window.rkt    # Window management
│   ├── render.rkt    # Renderer and drawing primitives
│   ├── texture.rkt   # Texture management
│   ├── surface.rkt   # Surface operations
│   ├── events.rkt    # Event polling
│   ├── keyboard.rkt  # Keyboard functions
│   ├── mouse.rkt     # Mouse functions
│   ├── audio.rkt     # Audio device/stream
│   ├── display.rkt   # Display/monitor info
│   ├── clipboard.rkt # Clipboard access
│   ├── dialog.rkt    # File dialogs, message boxes
│   ├── timer.rkt     # Timing functions
│   ├── image.rkt     # SDL_image bindings
│   └── ttf.rkt       # SDL_ttf bindings
│
├── safe/             # Idiomatic wrappers with custodian cleanup
│   ├── window.rkt    # make-window, make-renderer
│   ├── draw.rkt      # set-draw-color!, render-clear!, fill-rect!
│   ├── texture.rkt   # load-texture, render-texture!
│   ├── events.rkt    # poll-event, in-events, match-friendly structs
│   ├── keyboard.rkt  # key-down?, key-pressed?
│   ├── mouse.rkt     # mouse-position, mouse-button-down?
│   ├── audio.rkt     # Audio wrappers
│   ├── display.rkt   # display-count, display-bounds
│   ├── clipboard.rkt # get-clipboard-text, set-clipboard-text!
│   ├── dialog.rkt    # open-file-dialog, save-file-dialog
│   ├── timer.rkt     # current-ticks, delay!
│   ├── image.rkt     # load-surface, save-png!, save-jpg!
│   └── ttf.rkt       # open-font, draw-text!
│
├── private/          # Implementation details
│   ├── lib.rkt       # Library loading, define-sdl macro
│   ├── syntax.rkt    # Error handling helpers
│   ├── safe-syntax.rkt # Resource wrapping macros
│   └── types.rkt     # C struct types and constants
│
└── examples/         # Example programs (01-window.rkt through 27-file-dialog.rkt)
```

## Architecture

| Layer | Purpose | Example |
|-------|---------|---------|
| `safe/` | Idiomatic Racket API with automatic resource cleanup | `(make-window "Title" 800 600)` |
| `raw/` | Direct FFI bindings, mirrors SDL3 C API | `(SDL-CreateWindow "Title" 800 600 0)` |
| `private/` | Implementation details, not for external use | Types, macros, library loading |

Safe wrappers use Racket's custodian system for automatic cleanup. When a custodian shuts down, all SDL resources registered with it are freed.

## Naming Conventions

### Raw Layer (C-style)
- FFI functions use hyphenated names: `SDL-Init`, `SDL-CreateWindow`
- C struct types use underscores: `_SDL_KeyboardEvent`
- Struct accessors use underscores: `SDL_KeyboardEvent-key`
- Constants match SDL3 names: `SDL_EVENT_QUIT`, `SDLK_ESCAPE`

### Safe Layer (Racket-style)
- Functions use kebab-case: `make-window`, `load-texture`
- Mutators end with `!`: `render-clear!`, `set-draw-color!`
- Predicates end with `?`: `window?`, `key-down?`
- Destructors: `window-destroy!`, `texture-destroy!` (usually not needed due to custodians)

## Adding New Bindings

### Adding a raw binding

1. Add types/constants to `private/types.rkt` with `provide`
2. Add function binding to appropriate `raw/*.rkt` using `define-sdl`
3. Re-export from `raw.rkt` if needed

### Adding a safe wrapper

1. Create resource struct with `define-sdl-resource` if managing a pointer
2. Wrap raw functions with error checking (raise Racket errors on failure)
3. Register cleanup with custodian via `register-custodian-shutdown`
4. Export from the appropriate `safe/*.rkt` module
5. Re-export from `safe.rkt`

## Common Patterns

### Minimal Window Example

```racket
#lang racket
(require sdl3)

(define win (make-window "Hello" 800 600))
(define ren (make-renderer win))

(let loop ()
  (for ([e (in-events)])
    (match e
      [(quit-event) (exit)]
      [_ (void)]))
  (set-draw-color! ren 50 50 50)
  (render-clear! ren)
  (render-present! ren)
  (loop))
```

### Event Loop with Input

```racket
(for ([e (in-events)])
  (match e
    [(quit-event) (set! running? #f)]
    [(key-event type _ _ sym _ _)
     (when (and (eq? type 'down) (eq? sym 'escape))
       (set! running? #f))]
    [(mouse-button-event type _ x y button _ _)
     (when (eq? type 'down)
       (printf "Click at ~a,~a~n" x y))]
    [_ (void)]))
```

## SDL3 Notes

- SDL3 uses C99 `bool` (not int like SDL2)
- Event union is 128 bytes (`SDL_EVENT_SIZE`)
- Window flags are 64-bit, init flags are 32-bit
- Coordinates in mouse events are `float`, not `int`

## SDL3 Reference Headers

When adding new bindings, refer to the SDL3 headers installed via Homebrew:

```
/opt/homebrew/include/SDL3/        # Core SDL3 headers
/opt/homebrew/include/SDL3_image/  # SDL3_image headers
/opt/homebrew/include/SDL3_ttf/    # SDL3_ttf headers
```

Key headers:
- `SDL3/SDL_video.h` - Window functions
- `SDL3/SDL_render.h` - Renderer and texture functions
- `SDL3/SDL_events.h` - Event types and structs
- `SDL3/SDL_keyboard.h` - Keyboard functions and keycodes
- `SDL3/SDL_mouse.h` - Mouse functions
- `SDL3/SDL_blendmode.h` - Blend mode constants

## Extension Libraries

| Library | Raw Access | Safe Access |
|---------|------------|-------------|
| SDL_image | `sdl3/raw/image` | `load-texture`, `load-surface` |
| SDL_ttf | `sdl3/raw/ttf` | `open-font`, `draw-text!` |

## Testing

Run examples to verify bindings work:

```bash
racket examples/01-window.rkt   # Basic window
racket examples/02-input.rkt    # Keyboard/mouse events
racket examples/04-image.rkt    # Image loading
racket examples/05-text.rkt     # TTF rendering
racket examples/15-repl.rkt     # Raw bindings (uses sdl3/raw)
```
