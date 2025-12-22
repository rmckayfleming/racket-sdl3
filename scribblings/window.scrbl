#lang scribble/manual

@(require (for-label racket/base
                     racket/contract
                     sdl3))

@title[#:tag "window" #:style 'quiet]{Windows and Renderers}

SDL3 applications display graphics through windows and renderers.
A @deftech{window} is an OS window that can display content.
A @deftech{renderer} is a 2D rendering context attached to a window.

@section{Creating Windows and Renderers}

@defform[(with-window+renderer title width height (win-id ren-id)
           maybe-window-flags body ...)
         #:grammar ([maybe-window-flags (code:line)
                                         (code:line #:window-flags flags)])
         #:contracts ([flags (or/c symbol? (listof symbol?))])]{
  Creates a window and renderer, binds them to @racket[win-id] and @racket[ren-id],
  evaluates @racket[body], then destroys both resources.

  This is the recommended way to create a window and renderer.

  Available window flags:
  @itemlist[
    @item{@racket['resizable] --- Window can be resized}
    @item{@racket['fullscreen] --- Fullscreen window}
    @item{@racket['high-pixel-density] --- High-DPI mode}
    @item{@racket['opengl] --- OpenGL rendering context}
  ]

  @codeblock|{
    (with-sdl
      (with-window+renderer "My Game" 800 600 (win ren)
        ;; win and ren are available here
        (render-clear! ren)
        (render-present! ren)))

    (with-window+renderer "Resizable" 800 600 (win ren)
      #:window-flags 'resizable
      ;; ...
      )

    (with-window+renderer "HiDPI" 800 600 (win ren)
      #:window-flags '(resizable high-pixel-density)
      ;; ...
      )
  }|
}

@defform[(with-window title width height win-id body ...)]{
  Creates a window without a renderer. Use this when you need a window
  but will create the renderer separately (e.g., for OpenGL contexts).
}

@defform[(with-renderer win ren-id body ...)]{
  Creates a renderer for an existing window.
}

@section{Window Functions}

@defproc[(make-window [title string?]
                      [width exact-positive-integer?]
                      [height exact-positive-integer?]
                      [#:flags flags (or/c symbol? (listof symbol?) #f) '()]
                      [#:custodian cust custodian? (current-custodian)])
         window?]{
  Creates a new window. The window is registered with @racket[cust] and
  will be destroyed when the custodian is shut down.

  Returns a @racket[window?] value.
}

@defproc[(window? [v any/c]) boolean?]{
  Returns @racket[#t] if @racket[v] is a window created by @racket[make-window].
}

@defproc[(window-destroy! [win window?]) void?]{
  Destroys a window. Usually not needed if using @racket[with-window] or
  custodian-based cleanup.
}

@subsection{Window Properties}

@defproc[(window-title [win window?]) string?]{
  Returns the window's title.
}

@defproc[(window-set-title! [win window?] [title string?]) void?]{
  Sets the window's title.
}

@defproc[(window-size [win window?]) (values exact-nonnegative-integer?
                                              exact-nonnegative-integer?)]{
  Returns the window's client area size as two values: width and height.

  @codeblock|{
    (define-values (w h) (window-size win))
    (printf "Window is ~ax~a~n" w h)
  }|
}

@defproc[(window-set-size! [win window?]
                           [width exact-positive-integer?]
                           [height exact-positive-integer?]) void?]{
  Sets the window's client area size.
}

@defproc[(window-position [win window?]) (values exact-integer? exact-integer?)]{
  Returns the window's position as two values: x and y.
}

@defproc[(window-set-position! [win window?]
                               [x exact-integer?]
                               [y exact-integer?]) void?]{
  Sets the window's position.
}

@defproc[(window-pixel-density [win window?]) real?]{
  Returns the pixel density scale factor. On high-DPI displays, this may
  be greater than 1.0.
}

@defproc[(window-id [win window?]) exact-nonnegative-integer?]{
  Returns the window's numeric ID.
}

@defproc[(window-from-id [id exact-nonnegative-integer?]) (or/c window? #f)]{
  Returns the window with the given ID, or @racket[#f] if not found.
}

@subsection{Window State}

@defproc[(show-window! [win window?]) void?]{
  Shows a hidden window.
}

@defproc[(hide-window! [win window?]) void?]{
  Hides a visible window.
}

@defproc[(raise-window! [win window?]) void?]{
  Raises the window above other windows and gives it input focus.
}

@defproc[(maximize-window! [win window?]) void?]{
  Maximizes the window.
}

@defproc[(minimize-window! [win window?]) void?]{
  Minimizes the window to the taskbar/dock.
}

@defproc[(restore-window! [win window?]) void?]{
  Restores a minimized or maximized window to its normal size.
}

@defproc[(window-fullscreen? [win window?]) boolean?]{
  Returns @racket[#t] if the window is in fullscreen mode.
}

@defproc[(window-set-fullscreen! [win window?] [fullscreen? boolean?]) void?]{
  Sets the window's fullscreen state.
}

@subsection{Window Decoration}

@defproc[(set-window-bordered! [win window?] [bordered? boolean?]) void?]{
  Sets whether the window has a border.
}

@defproc[(set-window-resizable! [win window?] [resizable? boolean?]) void?]{
  Sets whether the window can be resized by the user.
}

@defproc[(set-window-minimum-size! [win window?]
                                   [width exact-positive-integer?]
                                   [height exact-positive-integer?]) void?]{
  Sets the minimum allowed size for the window.
}

@defproc[(set-window-maximum-size! [win window?]
                                   [width exact-positive-integer?]
                                   [height exact-positive-integer?]) void?]{
  Sets the maximum allowed size for the window.
}

@defproc[(window-minimum-size [win window?]) (values exact-nonnegative-integer?
                                                      exact-nonnegative-integer?)]{
  Returns the minimum size as two values: width and height.
}

@defproc[(window-maximum-size [win window?]) (values exact-nonnegative-integer?
                                                      exact-nonnegative-integer?)]{
  Returns the maximum size as two values: width and height.
}

@subsection{Window Effects}

@defproc[(window-opacity [win window?]) real?]{
  Returns the window's opacity (0.0 = transparent, 1.0 = opaque).
}

@defproc[(set-window-opacity! [win window?] [opacity real?]) void?]{
  Sets the window's opacity. @racket[opacity] should be between 0.0 and 1.0.
}

@defproc[(flash-window! [win window?]
                        [operation (or/c 'cancel 'briefly 'until-focused) 'briefly])
         void?]{
  Flashes the window to get user attention.

  @itemlist[
    @item{@racket['briefly] --- Flash briefly (default)}
    @item{@racket['until-focused] --- Flash until the window gains focus}
    @item{@racket['cancel] --- Cancel any ongoing flash}
  ]
}

@defproc[(set-window-icon! [win window?] [surface any/c]) void?]{
  Sets the window icon from a surface.
}

@section{Renderer Functions}

@defproc[(make-renderer [win window?]
                        [#:name name (or/c string? #f) #f]
                        [#:custodian cust custodian? (current-custodian)])
         renderer?]{
  Creates a renderer for the given window. The renderer is registered with
  @racket[cust] and will be destroyed when the custodian is shut down.
}

@defproc[(renderer? [v any/c]) boolean?]{
  Returns @racket[#t] if @racket[v] is a renderer.
}

@defproc[(renderer-destroy! [ren renderer?]) void?]{
  Destroys a renderer. Usually not needed if using @racket[with-renderer] or
  custodian-based cleanup.
}

@defproc[(make-window+renderer [title string?]
                               [width exact-positive-integer?]
                               [height exact-positive-integer?]
                               [#:window-flags window-flags (or/c symbol? (listof symbol?)) '()]
                               [#:renderer-name renderer-name (or/c string? #f) #f]
                               [#:custodian cust custodian? (current-custodian)])
         (values window? renderer?)]{
  Creates a window and renderer in one call. Returns two values.

  @codeblock|{
    (define-values (win ren)
      (make-window+renderer "My App" 800 600))
  }|
}

@section{Functional Alternatives}

For users who prefer explicit callbacks over syntax forms:

@defproc[(call-with-sdl [proc (-> any)]
                        [#:flags flags (or/c symbol? (listof symbol?)) 'video])
         any]{
  Initializes SDL, calls @racket[proc], then shuts down SDL.
}

@defproc[(call-with-window [title string?]
                           [width exact-positive-integer?]
                           [height exact-positive-integer?]
                           [proc (-> window? any)]
                           [#:flags flags (or/c symbol? (listof symbol?)) '()])
         any]{
  Creates a window, calls @racket[proc] with it, then destroys the window.
}

@defproc[(call-with-renderer [win window?]
                             [proc (-> renderer? any)]
                             [#:name name (or/c string? #f) #f])
         any]{
  Creates a renderer, calls @racket[proc] with it, then destroys the renderer.
}

@defproc[(call-with-window+renderer [title string?]
                                    [width exact-positive-integer?]
                                    [height exact-positive-integer?]
                                    [proc (-> window? renderer? any)]
                                    [#:window-flags window-flags (or/c symbol? (listof symbol?)) '()]
                                    [#:renderer-name renderer-name (or/c string? #f) #f])
         any]{
  Creates a window and renderer, calls @racket[proc] with both, then destroys them.
}
