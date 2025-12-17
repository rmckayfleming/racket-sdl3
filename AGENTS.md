# AGENTS.md

## Build & Run

```bash
# Racket binary location
/opt/homebrew/bin/racket

# Compile a module
/opt/homebrew/bin/raco make <file.rkt>

# Run examples (in worktrees, use PLTCOLLECTS)
PLTCOLLECTS="$PWD:" /opt/homebrew/bin/racket examples/01-window.rkt
PLTCOLLECTS="$PWD:" /opt/homebrew/bin/racket examples/02-input.rkt

# Clear compiled cache (needed after changing types/structs)
rm -rf compiled private/compiled safe/compiled raw/compiled examples/compiled
```

## Project Structure

- `main.rkt` - Package entry point, re-exports safe.rkt
- `safe.rkt` - Aggregates all safe/* modules (idiomatic Racket API)
- `raw.rkt` - Aggregates all raw/* modules (C-style FFI)
- `raw/*.rkt` - Low-level FFI bindings by subsystem
- `safe/*.rkt` - Idiomatic wrappers with custodian cleanup
- `private/types.rkt` - C struct types and FFI type aliases
- `private/constants.rkt` - Flags and constant values
- `private/enums.rkt` - Keycodes and scancodes
- `private/lib.rkt` - Library loading (`define-sdl` macro)
- `examples/` - Example programs (01-window.rkt through 27-file-dialog.rkt)

## Naming Conventions

- FFI functions use hyphenated names: `SDL-Init`, `SDL-CreateWindow`
- C struct types use underscores: `_SDL_KeyboardEvent`
- Struct accessors use underscores: `SDL_KeyboardEvent-key`
- Constants match SDL3 names: `SDL_EVENT_QUIT`, `SDLK_ESCAPE`

## Adding New Bindings

1. Add types to `private/types.rkt`, constants to `private/constants.rkt`, or keycodes to `private/enums.rkt`
2. Add function binding to appropriate `raw/*.rkt` using `define-sdl`
3. Re-export from `raw.rkt` if needed
4. Clear compiled cache before testing

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

## SDL3 Notes

- SDL3 uses C99 `bool` (not int like SDL2)
- Event union is 128 bytes (`SDL_EVENT_SIZE`)
- Window flags are 64-bit, init flags are 32-bit
- Coordinates in mouse events are `float`, not `int`
