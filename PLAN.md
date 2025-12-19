# Implementation Plan: Surface Operations & Hints

This document outlines the plan for implementing surface operations (CPU-side pixel manipulation) and the SDL hints API.

**Status:** Phase 5 (Surface I/O) is complete. See `TODO.md` for full implementation status.

## Goals

- Create and manipulate surfaces (CPU-side pixel buffers)
- Direct pixel read/write for procedural texture generation
- Blit surfaces together for software compositing
- Convert surfaces to textures for GPU rendering
- Configure SDL behavior via hints

**Showcase Example:** Interactive Mandelbrot set renderer with zoom/pan

---

## Current Repository Structure

```
racket-sdl3/
├── main.rkt          # Package entry point, re-exports safe.rkt
├── safe.rkt          # Aggregates all safe/* modules
├── raw.rkt           # Aggregates all raw/* modules
│
├── raw/              # Low-level FFI bindings by subsystem
│   ├── init.rkt, window.rkt, render.rkt, texture.rkt, surface.rkt
│   ├── events.rkt, keyboard.rkt, mouse.rkt, audio.rkt
│   ├── display.rkt, clipboard.rkt, dialog.rkt, timer.rkt
│   ├── image.rkt, ttf.rkt
│
├── safe/             # Idiomatic wrappers with custodian cleanup
│   ├── window.rkt, draw.rkt, texture.rkt, events.rkt
│   ├── keyboard.rkt, mouse.rkt, audio.rkt, display.rkt
│   ├── clipboard.rkt, dialog.rkt, timer.rkt
│   ├── image.rkt, ttf.rkt, collision.rkt
│
├── private/          # Implementation details
│   ├── lib.rkt, syntax.rkt, safe-syntax.rkt
│   ├── types.rkt, constants.rkt, enums.rkt
│
├── examples/         # Examples organized by concept
│   ├── basics/       # window.rkt, drawing.rkt, input.rkt, image.rkt
│   ├── window/       # controls.rkt, display-info.rkt, error-handling.rkt
│   ├── drawing/      # drawing.rkt, blend-modes.rkt
│   ├── textures/     # texture-transforms.rkt, render-target.rkt, screenshot.rkt, sprite-animation.rkt
│   ├── text/         # text.rkt
│   ├── input/        # keyboard.rkt, mouse.rkt, mouse-relative.rkt, mouse-scroll.rkt, buttons.rkt, custom-cursor.rkt
│   ├── animation/    # animation.rkt
│   ├── audio/        # audio.rkt
│   ├── advanced/     # collision.rkt, viewport.rkt, clipping.rkt, scaling.rkt, camera.rkt, wait-events.rkt
│   ├── dialogs/      # message-box.rkt
│   └── assets/       # Images for examples
│
└── demos/            # Complete demo applications
    ├── mini-paint.rkt
    └── keyboard-visual.rkt
```

---

## Phase 1: Surface Creation & Basics ✓ COMPLETE

Create, destroy, and query surfaces. These are the foundation for all surface operations.

### Raw Bindings (`raw/surface.rkt`)

```racket
;; Surface creation/destruction
SDL-CreateSurface          ; width height format -> surface
SDL-CreateSurfaceFrom      ; width height format pixels pitch -> surface
SDL-DuplicateSurface       ; surface -> surface
SDL-ConvertSurface         ; surface format -> surface

;; Surface utilities
SDL-LockSurface            ; surface -> bool
SDL-UnlockSurface          ; surface -> void
SDL-SetSurfaceRLE          ; surface enabled -> bool
SDL-SurfaceHasRLE          ; surface -> bool
```

### Types (`private/types.rkt` / `private/constants.rkt`)

```racket
;; Surface flags
SDL_SURFACE_PREALLOCATED   ; 0x00000001
SDL_SURFACE_LOCK_NEEDED    ; 0x00000002
SDL_SURFACE_LOCKED         ; 0x00000004
SDL_SURFACE_SIMD_ALIGNED   ; 0x00000008

;; Scale mode enum (for blitting)
_SDL_ScaleMode             ; already exists
SDL_SCALEMODE_NEAREST      ; already exists
SDL_SCALEMODE_LINEAR       ; already exists

;; Flip mode enum (already exists)
_SDL_FlipMode
SDL_FLIP_NONE, SDL_FLIP_HORIZONTAL, SDL_FLIP_VERTICAL

;; Additional pixel formats for surface creation
SDL_PIXELFORMAT_RGBA32     ; platform-specific RGBA
SDL_PIXELFORMAT_RGB24      ; 0x17101803
```

### Safe Wrappers (`safe/surface.rkt` - new file)

```racket
;; Surface creation
(make-surface width height [format])  ; -> surface, default RGBA32
(duplicate-surface surface)           ; -> new surface copy
(convert-surface surface format)      ; -> new surface in new format

;; Surface queries
(surface-width surface)               ; -> int
(surface-height surface)              ; -> int
(surface-pitch surface)               ; -> int (bytes per row)
(surface-format surface)              ; -> pixel-format
(surface-pixels surface)              ; -> pointer (for direct access)

;; Resource management
(call-with-surface surface proc)      ; ensures cleanup
```

### Example: `examples/advanced/surface-basics.rkt`

Demonstrate surface creation:
- Create a surface programmatically
- Query its properties
- Convert to texture and display
- Show surface dimensions and format info

---

## Phase 2: Pixel Access ✓ COMPLETE

Read and write individual pixels. Essential for procedural generation.

### Raw Bindings (`raw/surface.rkt`)

```racket
;; Single pixel access
SDL-ReadSurfacePixel       ; surface x y r-ptr g-ptr b-ptr a-ptr -> bool
SDL-WriteSurfacePixel      ; surface x y r g b a -> bool
SDL-ReadSurfacePixelFloat  ; surface x y r-ptr g-ptr b-ptr a-ptr -> bool
SDL-WriteSurfacePixelFloat ; surface x y r g b a -> bool

;; Color mapping
SDL-MapSurfaceRGB          ; surface r g b -> uint32
SDL-MapSurfaceRGBA         ; surface r g b a -> uint32
```

### Safe Wrappers (`safe/surface.rkt`)

```racket
;; Pixel access (for small operations / correctness)
(surface-get-pixel surface x y)       ; -> (values r g b a)
(surface-set-pixel! surface x y r g b [a 255])

;; Color mapping for direct buffer access
(surface-map-rgb surface r g b)       ; -> uint32
(surface-map-rgba surface r g b a)    ; -> uint32

;; Bulk pixel access (for procedural generation)
(make-pixel-writer surface)           ; -> (lambda (x y r g b a) ...)
(make-pixel-reader surface)           ; -> (lambda (x y) (values r g b a))

;; Direct buffer access for maximum performance
(call-with-surface-pixels surface proc)
;; proc receives: pixels-pointer, width, height, pitch, bytes-per-pixel
;; Handles locking/unlocking automatically
```

### Example: `examples/advanced/pixel-access.rkt`

Demonstrate pixel manipulation:
- Draw a gradient by setting individual pixels
- Read pixels back and verify
- Show performance difference between single-pixel and bulk access
- Create a simple noise texture procedurally

---

## Phase 3: Mandelbrot Renderer ✓ COMPLETE

Build an interactive Mandelbrot set explorer as the showcase example.

### Demo: `demos/mandelbrot.rkt`

Full-featured Mandelbrot renderer:
- Generate fractal directly to surface pixels
- Convert surface to texture for display
- Interactive controls:
  - Arrow keys or click to pan
  - +/- or scroll wheel to zoom
  - R to reset view
  - C to cycle color palettes
  - S to save screenshot as PNG
- Display current coordinates and zoom level
- Smooth color gradients based on iteration count

Implementation approach:
1. Create surface at window resolution
2. Compute Mandelbrot iterations for each pixel
3. Map iteration counts to colors
4. Upload surface to texture
5. Render texture to screen
6. Re-render on pan/zoom

---

## Phase 4: Surface Blitting ✓ COMPLETE

Copy regions between surfaces. Useful for compositing and sprite sheets.

### Raw Bindings (`raw/surface.rkt`)

```racket
;; Basic blitting
SDL-BlitSurface            ; src srcrect dst dstrect -> bool
SDL-BlitSurfaceScaled      ; src srcrect dst dstrect scalemode -> bool

;; Filling
SDL-FillSurfaceRect        ; dst rect color -> bool
SDL-FillSurfaceRects       ; dst rects count color -> bool
SDL-ClearSurface           ; surface r g b a -> bool (float colors)

;; Transformations
SDL-FlipSurface            ; surface flip-mode -> bool
SDL-ScaleSurface           ; surface width height scalemode -> surface
```

### Safe Wrappers (`safe/surface.rkt`)

```racket
;; Blitting
(blit-surface! src dst [src-rect #f] [dst-rect #f])
(blit-surface-scaled! src dst [src-rect #f] [dst-rect #f]
                      [scale-mode 'nearest])

;; Filling
(fill-surface! surface color [rect #f])     ; color as (list r g b) or (list r g b a)
(clear-surface! surface r g b [a 1.0])      ; float colors

;; Transformations
(flip-surface! surface mode)                ; 'horizontal, 'vertical, or 'both
(scale-surface surface width height [mode 'nearest])  ; -> new surface
```

### Example: `examples/advanced/surface-blit.rkt`

Demonstrate blitting operations:
- Load/create multiple surfaces
- Blit sprites onto a background
- Scale surfaces up/down
- Flip surfaces horizontally/vertically
- Composite multiple layers

---

## Phase 5: Surface I/O ✓ COMPLETE

Load and save surfaces from/to files.

### Raw Bindings (`raw/surface.rkt`)

```racket
;; BMP file I/O (built into SDL3)
SDL-LoadBMP                ; filename -> surface
SDL-SaveBMP                ; surface filename -> bool
```

### Safe Wrappers (`safe/surface.rkt`)

```racket
;; File I/O
(load-bmp path)            ; -> surface (error on failure)
(save-bmp surface path)    ; -> bool

;; Note: PNG/JPG loading via SDL_image already exists in safe/image.rkt
;; load-surface uses IMG_Load under the hood
```

### Example: `examples/advanced/surface-io.rkt`

Demonstrate surface I/O:
- Load a BMP file
- Manipulate it (flip, scale, modify pixels)
- Save the result
- Display before/after comparison

---

## Phase 6: Advanced Surface Operations

Additional surface features for complete coverage.

### Raw Bindings (`raw/surface.rkt`)

```racket
;; Color key (transparency)
SDL-SetSurfaceColorKey     ; surface enabled key -> bool
SDL-GetSurfaceColorKey     ; surface key-ptr -> bool
SDL-SurfaceHasColorKey     ; surface -> bool

;; Color/alpha modulation
SDL-SetSurfaceColorMod     ; surface r g b -> bool
SDL-GetSurfaceColorMod     ; surface r-ptr g-ptr b-ptr -> bool
SDL-SetSurfaceAlphaMod     ; surface alpha -> bool
SDL-GetSurfaceAlphaMod     ; surface alpha-ptr -> bool

;; Blend mode
SDL-SetSurfaceBlendMode    ; surface blendmode -> bool
SDL-GetSurfaceBlendMode    ; surface blendmode-ptr -> bool

;; Clipping
SDL-SetSurfaceClipRect     ; surface rect -> bool
SDL-GetSurfaceClipRect     ; surface rect -> bool
```

### Safe Wrappers (`safe/surface.rkt`)

```racket
;; Color key
(set-surface-color-key! surface color)      ; color as (list r g b) or #f to disable
(surface-color-key surface)                 ; -> (list r g b) or #f
(surface-has-color-key? surface)            ; -> bool

;; Modulation
(set-surface-color-mod! surface r g b)
(surface-color-mod surface)                 ; -> (values r g b)
(set-surface-alpha-mod! surface alpha)
(surface-alpha-mod surface)                 ; -> alpha

;; Blend mode
(set-surface-blend-mode! surface mode)      ; 'none, 'blend, 'add, 'mod
(surface-blend-mode surface)                ; -> symbol

;; Clipping
(set-surface-clip-rect! surface rect)       ; rect as (list x y w h) or #f
(surface-clip-rect surface)                 ; -> (list x y w h)
```

### Example: `examples/advanced/surface-advanced.rkt`

Demonstrate advanced features:
- Color key for sprite transparency
- Alpha blending between surfaces
- Color modulation effects
- Clipping regions

---

## Phase 7: Hints API

SDL hints for runtime configuration.

### Raw Bindings (`raw/hints.rkt` - new file)

```racket
;; Hint management
SDL-SetHint                ; name value -> bool
SDL-SetHintWithPriority    ; name value priority -> bool
SDL-GetHint                ; name -> string/null
SDL-GetHintBoolean         ; name default -> bool
SDL-ResetHint              ; name -> bool
SDL-ResetHints             ; -> void
```

### Types (`private/constants.rkt`)

```racket
;; Hint priority
_SDL_HintPriority
SDL_HINT_DEFAULT           ; 0
SDL_HINT_NORMAL            ; 1
SDL_HINT_OVERRIDE          ; 2

;; Common hint names (as strings)
SDL_HINT_RENDER_VSYNC              ; "SDL_RENDER_VSYNC"
SDL_HINT_RENDER_DRIVER             ; "SDL_RENDER_DRIVER"
SDL_HINT_VIDEO_ALLOW_SCREENSAVER   ; "SDL_VIDEO_ALLOW_SCREENSAVER"
SDL_HINT_APP_NAME                  ; "SDL_APP_NAME"
SDL_HINT_APP_ID                    ; "SDL_APP_ID"
```

### Safe Wrappers (`safe/hints.rkt` - new file)

```racket
;; Hint access
(set-hint! name value)              ; -> bool
(set-hint! name value priority)     ; with priority: 'default, 'normal, 'override
(get-hint name)                     ; -> string or #f
(get-hint-boolean name default)     ; -> bool
(reset-hint! name)                  ; -> bool
(reset-all-hints!)                  ; -> void

;; Convenience for common hints
(set-render-driver! driver)         ; "opengl", "metal", "vulkan", etc.
(set-app-name! name)
(allow-screensaver! enabled?)
```

### Example: `examples/window/hints.rkt`

Demonstrate hints API:
- Set app name hint before init
- Query available render drivers
- Toggle vsync via hint
- Show effect of various hints

---

## Implementation Order

| Step | Phase | Files to Create/Modify | Deliverable |
|------|-------|------------------------|-------------|
| 1 | Phase 1 | `private/constants.rkt`, `raw/surface.rkt`, `safe/surface.rkt` | Surface creation |
| 2 | Phase 2 | `raw/surface.rkt`, `safe/surface.rkt` | Pixel access |
| 3 | Phase 3 | `demos/mandelbrot.rkt` | Mandelbrot renderer |
| 4 | Phase 4 | `raw/surface.rkt`, `safe/surface.rkt` | Blitting |
| 5 | Phase 5 | `raw/surface.rkt`, `safe/surface.rkt` | BMP I/O |
| 6 | Phase 6 | `raw/surface.rkt`, `safe/surface.rkt` | Advanced features |
| 7 | Phase 7 | `raw/hints.rkt`, `safe/hints.rkt` | Hints API |

---

## Dependencies Between Phases

```
Phase 1 (Creation) ──┬──► Phase 2 (Pixels) ──► Phase 3 (Mandelbrot)
                     │
                     ├──► Phase 4 (Blitting)
                     │
                     ├──► Phase 5 (I/O)
                     │
                     └──► Phase 6 (Advanced)

Phase 7 (Hints) ─────► Independent
```

Phases 1-2 must come first. Phase 3 (Mandelbrot) requires pixel access.
Phases 4-6 can be done in any order after Phase 1.
Phase 7 (Hints) is completely independent.

---

## Function Counts

| Phase | Raw Functions | Safe Wrappers | Types/Constants |
|-------|---------------|---------------|-----------------|
| Phase 1 | 6 | 8 | ~10 |
| Phase 2 | 6 | 6 | 0 |
| Phase 3 | 0 | 0 | 0 (example only) |
| Phase 4 | 6 | 6 | 0 |
| Phase 5 | 2 | 2 | 0 |
| Phase 6 | 10 | 10 | 0 |
| Phase 7 | 6 | 8 | ~5 |
| **Total** | **36** | **40** | **~15** |

---

## Testing Strategy

After each phase:
1. Clear compiled cache: `make clean`
2. Compile: `PLTCOLLECTS="$PWD:" raco make safe/surface.rkt`
3. Run the phase's example program
4. Verify existing examples still work

---

## Performance Considerations

For the Mandelbrot renderer and other pixel-intensive operations:
- Use `call-with-surface-pixels` for direct buffer access
- Avoid per-pixel function calls in tight loops
- Consider using Racket's `unsafe` operations for inner loops
- Surface-to-texture upload is the main bottleneck; minimize texture recreation

## Pixel Format Selection

- Use `SDL_PIXELFORMAT_RGBA32` for cross-platform compatibility
- This maps to `RGBA8888` on little-endian (most systems)
- For direct pixel manipulation, know your byte order:
  - RGBA8888: R at lowest address
  - ARGB8888: A at lowest address (sometimes faster on some GPUs)
