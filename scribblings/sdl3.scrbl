#lang scribble/manual

@(require (for-label racket/base
                     racket/contract
                     sdl3)
          scribble/core
          scribble/html-properties)

@title{SDL3: Racket Bindings for SDL3}
@author{Ryan McKay-Fleming}

@defmodule[sdl3]

This library provides Racket bindings for @hyperlink["https://libsdl.org/"]{SDL3},
the Simple DirectMedia Layer. SDL3 is a cross-platform library for creating
windows, rendering graphics, handling input, playing audio, and more.

@section[#:tag "overview"]{Overview}

The @racketmodname[sdl3] library provides two layers:

@itemlist[
  @item{@bold{Safe API} (@racketmodname[sdl3]) --- Idiomatic Racket interface with
        automatic resource management via custodians, symbol-based flags, and
        match-friendly event structs.}

  @item{@bold{Raw API} (@tt{sdl3/raw}) --- Direct FFI bindings that
        mirror the C API. Function names follow the pattern @tt{SDL-FunctionName}.}
]

Most users should use the safe API. The raw API is available for advanced use
cases requiring direct pointer access.

@section[#:tag "quick-start"]{Quick Start}

Here's a minimal SDL3 program that creates a window:

@codeblock|{
#lang racket/base
(require racket/match sdl3)

(with-sdl
  (with-window+renderer "Hello SDL3" 800 600 (win ren)
    (let loop ()
      (define quit?
        (for/or ([ev (in-events)])
          (match ev
            [(quit-event) #t]
            [(key-event 'down 'escape _ _ _) #t]
            [_ #f])))
      (unless quit?
        (set-draw-color! ren 100 149 237)
        (render-clear! ren)
        (render-present! ren)
        (loop)))))
}|

@section[#:tag "resource-management"]{Resource Management}

SDL3 resources (windows, renderers, textures, fonts, etc.) require explicit
cleanup. The safe API provides two approaches:

@subsection{Automatic Cleanup with Syntax Forms}

The recommended approach uses syntax forms that automatically clean up resources:

@itemlist[
  @item{@racket[with-sdl] --- Initialize SDL, run body, quit SDL}
  @item{@racket[with-window] --- Create window, run body, destroy window}
  @item{@racket[with-renderer] --- Create renderer, run body, destroy renderer}
  @item{@racket[with-window+renderer] --- Create both, run body, destroy both}
]

These forms use Racket's @tech[#:doc '(lib "scribblings/reference/reference.scrbl")]{custodian}
system to ensure resources are freed even if an exception occurs.

@subsection{Manual Management}

For more control, use the constructor and destructor functions directly:

@codeblock|{
(sdl-init!)
(define win (make-window "Title" 800 600))
(define ren (make-renderer win))
;; ... use win and ren ...
(renderer-destroy! ren)
(window-destroy! win)
(sdl-quit!)
}|

@; ============================================================================
@; Core
@; ============================================================================

@include-section["initialization.scrbl"]
@include-section["window.scrbl"]
@include-section["timer.scrbl"]
@include-section["hints.scrbl"]
@include-section["properties.scrbl"]

@; ============================================================================
@; Graphics
@; ============================================================================

@include-section["drawing.scrbl"]
@include-section["texture.scrbl"]
@include-section["image.scrbl"]
@include-section["ttf.scrbl"]
@include-section["collision.scrbl"]

@; ============================================================================
@; Input
@; ============================================================================

@include-section["events.scrbl"]
@include-section["keyboard.scrbl"]
@include-section["mouse.scrbl"]
@include-section["gamepad.scrbl"]
@include-section["joystick.scrbl"]

@; ============================================================================
@; Media
@; ============================================================================

@include-section["audio.scrbl"]
@include-section["camera.scrbl"]

@; ============================================================================
@; System
@; ============================================================================

@include-section["display.scrbl"]
@include-section["clipboard.scrbl"]
@include-section["dialog.scrbl"]
@include-section["tray.scrbl"]

@; ============================================================================
@; Advanced Graphics
@; ============================================================================

@include-section["gl.scrbl"]
@include-section["vulkan.scrbl"]
@include-section["gpu.scrbl"]
