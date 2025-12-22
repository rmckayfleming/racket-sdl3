# SDL3 Racket Bindings
[📖 **Documentation**](https://ryan.mckayfleming.com/racket-sdl3/)

Racket bindings for SDL3, providing both a safe idiomatic interface and low-level FFI access.

## Installation

```bash
raco pkg install sdl3
```

Requires SDL3, SDL3_image, and SDL3_ttf libraries installed on your system.

## Quick Start

Run an example to verify everything works:

```bash
racket examples/basics/window.rkt
```

## Tutorial

This tutorial is designed to be followed interactively. Start a REPL in the project directory:

```bash
racket
```

### 1. Creating a Window

The most basic SDL3 program creates a window. Use `with-sdl` and `with-window+renderer` for automatic resource management:

```racket
(require sdl3 racket/match)

(with-sdl
  (with-window+renderer "Hello SDL3" 800 600 (win ren)
    ;; Your code here - window and renderer are automatically cleaned up
    (set-draw-color! ren 100 149 237)  ; Cornflower blue
    (render-clear! ren)
    (render-present! ren)
    (delay! 2000)))  ; Show for 2 seconds
```

See: [examples/basics/window.rkt](examples/basics/window.rkt)

### 2. Drawing Shapes

```racket
(require sdl3 racket/match)

(with-sdl
  (with-window+renderer "Shapes" 800 600 (win ren)
    ;; Dark background
    (set-draw-color! ren 30 30 40)
    (render-clear! ren)

    ;; Red filled rectangle
    (set-draw-color! ren 255 0 0)
    (fill-rect! ren 50 50 200 150)

    ;; Green rectangle outline
    (set-draw-color! ren 0 255 0)
    (draw-rect! ren 300 50 200 150)

    ;; Blue line
    (set-draw-color! ren 0 0 255)
    (draw-line! ren 50 300 750 400)

    (render-present! ren)
    (delay! 3000)))
```

See: [examples/basics/drawing.rkt](examples/basics/drawing.rkt)

### 3. Handling Events

SDL3 programs use an event loop. Use `for/or` with `in-events` to process events:

```racket
(require sdl3 racket/match)

(with-sdl
  (with-window+renderer "Events" 800 600 (win ren)
    (let loop ()
      ;; Process all pending events, check for quit
      (define quit?
        (for/or ([ev (in-events)])
          (match ev
            [(quit-event) #t]
            [(key-event 'down 'escape _ _ _) #t]
            [(key-event 'down key _ _ _)
             (printf "Key pressed: ~a~n" (key-name key))
             #f]
            [(mouse-button-event 'down 'left x y _)
             (printf "Click at ~a, ~a~n" x y)
             #f]
            [_ #f])))

      (unless quit?
        (set-draw-color! ren 50 50 50)
        (render-clear! ren)
        (render-present! ren)
        (delay! 16)
        (loop)))))
```

See: [examples/input/keyboard.rkt](examples/input/keyboard.rkt)

### 4. Loading Images

Load and display images with SDL3_image:

```racket
(require sdl3 racket/match)

(with-sdl
  (with-window+renderer "Image" 800 600 (win ren)
    ;; Load a texture from file
    (define tex (load-texture ren "examples/assets/racket-logo.png"))

    ;; Get texture dimensions
    (define-values (w h) (texture-size tex))
    (printf "Texture size: ~a x ~a~n" w h)

    ;; Draw it centered
    (set-draw-color! ren 30 30 30)
    (render-clear! ren)
    (render-texture! ren tex (/ (- 800 w) 2) (/ (- 600 h) 2))
    (render-present! ren)
    (delay! 3000)

    (texture-destroy! tex)))
```

See: [examples/basics/image.rkt](examples/basics/image.rkt)

### 5. Rendering Text

Render text with SDL3_ttf:

```racket
(require sdl3 racket/match)

(with-sdl
  (with-window+renderer "Text" 800 600 (win ren)
    ;; Open a font (adjust path for your system)
    (define font (open-font "/System/Library/Fonts/Helvetica.ttc" 48.0))

    ;; Render text to a texture (efficient for static text)
    (define tex (render-text font "Hello, SDL3!" '(255 255 255 255) #:renderer ren))

    (set-draw-color! ren 0 0 0)
    (render-clear! ren)
    (render-texture! ren tex 50 50)

    ;; Or use draw-text! for simple one-off rendering
    (draw-text! ren font "Dynamic text!" 50 150 '(0 255 0 255))

    (render-present! ren)
    (delay! 3000)

    (texture-destroy! tex)
    (close-font! font)))
```

See: [examples/text/text.rkt](examples/text/text.rkt)

### 6. Animation

Use `current-ticks` for time-based animation:

```racket
(require sdl3 racket/match racket/math)

(with-sdl
  (with-window+renderer "Animation" 800 600 (win ren)
    (let loop ([last-ticks (current-ticks)])
      (define now (current-ticks))
      (define dt (/ (- now last-ticks) 1000.0))  ; Delta time in seconds
      (define t (/ now 1000.0))                   ; Total time in seconds

      ;; Check for quit
      (define quit?
        (for/or ([ev (in-events)])
          (match ev
            [(quit-event) #t]
            [(key-event 'down 'escape _ _ _) #t]
            [_ #f])))

      (unless quit?
        ;; Calculate position using sine wave
        (define x (+ 400 (* 200 (cos t))))
        (define y (+ 300 (* 100 (sin (* 2 t)))))

        ;; Draw
        (set-draw-color! ren 20 20 30)
        (render-clear! ren)
        (set-draw-color! ren 255 100 100)
        (fill-rect! ren (- x 25) (- y 25) 50 50)
        (render-present! ren)

        (delay! 16)
        (loop now)))))
```

See: [examples/animation/animation.rkt](examples/animation/animation.rkt)

### 7. Keyboard State Polling

For smooth continuous input (like game movement), poll the keyboard state:

```racket
(require sdl3 racket/match)

(with-sdl
  (with-window+renderer "Movement" 800 600 (win ren)
    (define x 400.0)
    (define y 300.0)
    (define speed 5.0)

    (let loop ()
      ;; Get current keyboard state
      (define kbd (get-keyboard-state))

      ;; Check for quit events
      (define quit?
        (for/or ([ev (in-events)])
          (match ev
            [(quit-event) #t]
            [(key-event 'down 'escape _ _ _) #t]
            [_ #f])))

      (unless quit?
        ;; Move with WASD or arrow keys (symbols)
        (when (or (kbd 'w) (kbd 'up))    (set! y (- y speed)))
        (when (or (kbd 's) (kbd 'down))  (set! y (+ y speed)))
        (when (or (kbd 'a) (kbd 'left))  (set! x (- x speed)))
        (when (or (kbd 'd) (kbd 'right)) (set! x (+ x speed)))

        ;; Draw
        (set-draw-color! ren 30 30 40)
        (render-clear! ren)
        (set-draw-color! ren 100 200 255)
        (fill-rect! ren (- x 20) (- y 20) 40 40)
        (render-present! ren)

        (delay! 16)
        (loop)))))
```

See: [examples/basics/input.rkt](examples/basics/input.rkt)

## Examples

See [examples/README.md](examples/README.md) for a complete guide to all examples, organized by topic with a suggested learning path.

Quick start:
- [examples/basics/](examples/basics/) - Start here: window, drawing, input, images
- [examples/advanced/](examples/advanced/) - Surfaces, pixel access, collision
- [demos/](demos/) - Complete applications

## API Overview

### Resource Management

Use `with-sdl` and `with-window+renderer` for automatic cleanup:
- `(with-sdl body ...)` - Initialize SDL, run body, clean up
- `(with-sdl #:flags '(video audio) body ...)` - Initialize with specific subsystems
- `(with-window+renderer title w h (win ren) body ...)` - Create window and renderer

For manual management:
- `(sdl-init!)` - Initialize SDL
- `(sdl-quit!)` - Shutdown SDL
- `(make-window title width height)` - Create a window
- `(make-renderer window)` - Create a renderer for a window
- `(make-window+renderer title width height)` - Create both at once (returns two values)

### Drawing

- `(set-draw-color! renderer r g b [a])` - Set drawing color
- `(render-clear! renderer)` - Clear the screen
- `(render-present! renderer)` - Display the rendered frame
- `(fill-rect! renderer x y w h)` - Draw filled rectangle
- `(draw-rect! renderer x y w h)` - Draw rectangle outline
- `(draw-line! renderer x1 y1 x2 y2)` - Draw line
- `(draw-point! renderer x y)` - Draw point
- `(draw-points! renderer points)` - Draw multiple points
- `(draw-lines! renderer points)` - Draw connected lines
- `(render-debug-text! renderer x y text)` - Draw debug text (built-in font)

### Textures

- `(load-texture renderer path)` - Load image as texture
- `(render-texture! renderer texture x y [#:angle] [#:flip] [#:width] [#:height])` - Draw texture
- `(texture-size texture)` - Get texture dimensions (returns two values)
- `(texture-set-color-mod! texture r g b)` - Tint texture
- `(texture-set-alpha-mod! texture alpha)` - Set texture transparency
- `(create-texture renderer w h #:access #:format)` - Create empty texture
- `(surface->texture renderer surface)` - Convert surface to texture
- `(texture-destroy! texture)` - Free texture

### Surfaces

- `(make-surface width height #:format)` - Create empty surface
- `(load-surface path)` - Load image as surface
- `(surface-width surface)` - Get width
- `(surface-height surface)` - Get height
- `(surface-get-pixel surface x y)` - Read pixel (returns r g b a)
- `(surface-set-pixel! surface x y r g b)` - Write pixel
- `(surface-fill-pixels! surface proc)` - Fill with generator function
- `(surface-destroy! surface)` - Free surface

### Text

- `(open-font path size)` - Load a TTF font
- `(draw-text! renderer font text x y color)` - Draw text directly
- `(render-text font text color #:renderer ren)` - Render text to texture
- `(close-font! font)` - Free font

### Events

- `(in-events)` - Sequence of pending events (use with `for`)
- `(poll-event)` - Get next event or #f

Event types (use with `match`):
- `(quit-event)` - Window close or quit requested
- `(key-event state key scancode mod repeat)` - Keyboard (state is `'down` or `'up`, key is symbol)
- `(mouse-button-event state button x y clicks)` - Mouse button
- `(mouse-motion-event x y xrel yrel buttons)` - Mouse movement
- `(mouse-wheel-event x y direction)` - Scroll wheel
- `(window-event type)` - Window state changes
- `(text-input-event text)` - Text input

### Input State

- `(get-keyboard-state)` - Returns function: `(kbd 'key-symbol)` -> boolean
- `(get-mouse-state)` - Get mouse position and buttons
- `(get-mod-state)` - Get modifier key state
- `(key-name keycode)` - Get human-readable key name

### Timing

- `(current-ticks)` - Milliseconds since SDL init
- `(delay! ms)` - Sleep for milliseconds

### Collision

- `(make-rect x y w h)` - Create a rectangle
- `(rect-x rect)`, `(rect-y rect)`, `(rect-w rect)`, `(rect-h rect)` - Accessors
- `(rects-intersect? a b)` - Check if rectangles overlap
- `(rect-intersection a b)` - Get intersection rectangle or #f

### Audio

- `(open-audio-device)` - Open default audio device
- `(load-wav path)` - Load WAV file (returns spec, data, length)
- `(make-audio-stream spec)` - Create audio stream
- `(bind-audio-stream! device stream)` - Bind stream to device
- `(play-audio! stream data length)` - Queue audio data
- `(resume-audio-device! device)` - Start playback
- `(pause-audio-device! device)` - Pause playback

## Low-Level Access

For direct SDL3 C API access:

```racket
(require sdl3/raw)
```

This provides C-style function names like `SDL-CreateWindow`, `SDL-RenderPresent`, etc.

## License

MIT
