#lang scribble/manual

@(require (for-label racket/base
                     racket/contract
                     sdl3))

@title[#:tag "display" #:style 'quiet]{Display Information}

This section covers display/monitor enumeration and information.

@section{Display Enumeration}

@defproc[(get-displays) (listof exact-nonnegative-integer?)]{
  Returns a list of display IDs for all connected monitors.

  @codeblock|{
    (for ([id (get-displays)])
      (printf "Display ~a: ~a~n" id (display-name id)))
  }|
}

@defproc[(primary-display) exact-nonnegative-integer?]{
  Returns the ID of the primary display.
}

@defproc[(display-name [display-id exact-nonnegative-integer?]) string?]{
  Returns the name of a display.
}

@section{Display Bounds}

@defproc[(display-bounds [display-id exact-nonnegative-integer?])
         (values exact-integer? exact-integer?
                 exact-integer? exact-integer?)]{
  Returns the desktop area represented by a display.

  Returns @racket[(values x y width height)] in screen coordinates.

  @codeblock|{
    (define-values (x y w h) (display-bounds (primary-display)))
    (printf "Primary display: ~ax~a at (~a, ~a)~n" w h x y)
  }|
}

@defproc[(display-usable-bounds [display-id exact-nonnegative-integer?])
         (values exact-integer? exact-integer?
                 exact-integer? exact-integer?)]{
  Returns the usable desktop area (excludes taskbar, dock, etc.).

  Returns @racket[(values x y width height)].
}

@section{Display Modes}

Display modes describe the resolution and refresh rate of a display.

@defproc[(current-display-mode [display-id exact-nonnegative-integer?]) cpointer?]{
  Returns the current display mode.

  The returned pointer is owned by SDL and should not be freed.
}

@defproc[(desktop-display-mode [display-id exact-nonnegative-integer?]) cpointer?]{
  Returns the desktop display mode (the mode at SDL initialization).

  The returned pointer is owned by SDL and should not be freed.
}

@defproc[(fullscreen-display-modes [display-id exact-nonnegative-integer?])
         (listof cpointer?)]{
  Returns all available fullscreen display modes for a display.
}

@defproc[(display-mode-resolution [mode cpointer?])
         (values exact-integer? exact-integer?)]{
  Returns the width and height of a display mode.

  @codeblock|{
    (define mode (current-display-mode (primary-display)))
    (define-values (w h) (display-mode-resolution mode))
    (printf "Current resolution: ~ax~a~n" w h)
  }|
}

@defproc[(display-mode-refresh-rate [mode cpointer?]) real?]{
  Returns the refresh rate of a display mode in Hz.
}

@section{Window-Display Relationship}

@defproc[(window-display [win window?]) exact-nonnegative-integer?]{
  Returns the display ID for the display containing the center of a window.
}

@defproc[(display-content-scale [display-id exact-nonnegative-integer?]) real?]{
  Returns the content scale factor for a display.

  This is 1.0 for standard displays, 2.0 for Retina/HiDPI displays.

  @codeblock|{
    (define scale (display-content-scale (primary-display)))
    (when (> scale 1.0)
      (printf "HiDPI display detected (scale: ~a)~n" scale))
  }|
}

@defproc[(window-display-scale [win window?]) real?]{
  Returns the display scale for a window.
}

@section{Display Mode Struct Accessors}

These functions access fields of the @tt{SDL_DisplayMode} struct:

@defproc[(SDL_DisplayMode-displayID [mode cpointer?]) exact-nonnegative-integer?]{
  Returns the display ID this mode belongs to.
}

@defproc[(SDL_DisplayMode-format [mode cpointer?]) exact-nonnegative-integer?]{
  Returns the pixel format.
}

@defproc[(SDL_DisplayMode-w [mode cpointer?]) exact-integer?]{
  Returns the width in pixels.
}

@defproc[(SDL_DisplayMode-h [mode cpointer?]) exact-integer?]{
  Returns the height in pixels.
}

@defproc[(SDL_DisplayMode-pixel_density [mode cpointer?]) real?]{
  Returns the pixel density (pixels per point).
}

@defproc[(SDL_DisplayMode-refresh_rate [mode cpointer?]) real?]{
  Returns the refresh rate in Hz.
}

@defproc[(SDL_DisplayMode-refresh_rate_numerator [mode cpointer?]) exact-integer?]{
  Returns the numerator of the exact refresh rate fraction.
}

@defproc[(SDL_DisplayMode-refresh_rate_denominator [mode cpointer?]) exact-integer?]{
  Returns the denominator of the exact refresh rate fraction.
}
