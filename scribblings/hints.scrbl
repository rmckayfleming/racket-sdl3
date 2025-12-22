#lang scribble/manual

@(require (for-label racket/base
                     racket/contract
                     sdl3))

@title[#:tag "hints"]{Configuration Hints}

This section covers SDL configuration hints, which are variables that affect
SDL's behavior. Hints can be set before or during SDL initialization.

@section{Core Hint Operations}

@defproc[(set-hint! [name symbol?]
                    [value string?]
                    [priority (or/c 'default 'normal 'override) 'normal]) boolean?]{
  Sets a hint value.

  Priority levels:
  @itemlist[
    @item{@racket['default] --- Low priority, can be overridden by environment variables}
    @item{@racket['normal] --- Normal priority (default)}
    @item{@racket['override] --- High priority, overrides environment variables}
  ]

  Returns @racket[#t] if the hint was set.

  @codeblock|{
    (set-hint! 'render-vsync "1")
    (set-hint! 'app-name "My Game" 'override)
  }|
}

@defproc[(get-hint [name symbol?]) (or/c string? #f)]{
  Gets a hint value.

  Returns @racket[#f] if the hint is not set.
}

@defproc[(get-hint-boolean [name symbol?] [default boolean?]) boolean?]{
  Gets a hint as a boolean.

  Returns @racket[default] if the hint is not set.
}

@defproc[(reset-hint! [name symbol?]) void?]{
  Resets a hint to its default value.
}

@defproc[(reset-all-hints!) void?]{
  Resets all hints to their default values.
}

@section{Available Hint Names}

Hint names are specified as symbols:

@itemlist[
  @item{@racket['app-name] --- Application name (shown in audio controls, taskbar)}
  @item{@racket['app-id] --- Application ID (used by desktop compositors)}
  @item{@racket['render-driver] --- Renderer to use (@racket["opengl"], @racket["metal"], @racket["vulkan"], @racket["software"])}
  @item{@racket['render-vsync] --- Enable VSync (@racket["1"]) or disable (@racket["0"])}
  @item{@racket['video-allow-screensaver] --- Allow screensaver (@racket["1"]) or prevent (@racket["0"])}
  @item{@racket['framebuffer-acceleration] --- Framebuffer acceleration hint}
  @item{@racket['mouse-relative-mode-warp] --- Mouse relative mode warp behavior}
]

@section{Convenience Functions}

@defproc[(set-app-name! [name string?]) boolean?]{
  Sets the application name.

  Should be called before @racket[sdl-init!].

  @codeblock|{
    (set-app-name! "My Awesome Game")
    (sdl-init!)
  }|
}

@defproc[(set-app-id! [id string?]) boolean?]{
  Sets the application ID.

  Should be called before @racket[sdl-init!].
}

@defproc[(set-render-driver! [driver string?]) boolean?]{
  Sets the render driver to use.

  Should be called before creating a renderer.

  Common drivers: @racket["opengl"], @racket["metal"], @racket["vulkan"],
  @racket["software"].

  @codeblock|{
    ;; Force software rendering
    (set-render-driver! "software")
  }|
}

@defproc[(allow-screensaver! [enabled? boolean?]) boolean?]{
  Allows or prevents the screensaver from activating.

  @codeblock|{
    ;; Prevent screensaver during gameplay
    (allow-screensaver! #f)

    ;; Allow screensaver when paused
    (allow-screensaver! #t)
  }|
}
