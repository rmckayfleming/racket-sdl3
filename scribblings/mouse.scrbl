#lang scribble/manual

@(require (for-label racket/base
                     racket/contract
                     sdl3))

@title[#:tag "mouse" #:style 'quiet]{Mouse Functions}

This section covers mouse input handling, including mouse state polling,
cursor control, and relative mouse mode for FPS-style input.

@section{Mouse State}

@defproc[(get-mouse-state) (values real? real? exact-nonnegative-integer?)]{
  Returns the current mouse position and button state within the focused window.

  Returns three values:
  @itemlist[
    @item{@racket[x] --- The x coordinate relative to the window}
    @item{@racket[y] --- The y coordinate relative to the window}
    @item{@racket[buttons] --- A bitmask of pressed buttons}
  ]

  Use @racket[mouse-button-pressed?] to check individual buttons:

  @codeblock|{
    (define-values (x y buttons) (get-mouse-state))
    (when (mouse-button-pressed? buttons SDL_BUTTON_LMASK)
      (printf "Left button pressed at (~a, ~a)~n" x y))
  }|
}

@defproc[(get-global-mouse-state) (values real? real? exact-nonnegative-integer?)]{
  Returns the mouse position in global screen coordinates and button state.

  Returns three values:
  @itemlist[
    @item{@racket[x] --- The x coordinate in screen space}
    @item{@racket[y] --- The y coordinate in screen space}
    @item{@racket[buttons] --- A bitmask of pressed buttons}
  ]
}

@defproc[(get-relative-mouse-state) (values real? real? exact-nonnegative-integer?)]{
  Returns the relative mouse motion since the last call and button state.

  Returns three values:
  @itemlist[
    @item{@racket[dx] --- Relative motion in x direction}
    @item{@racket[dy] --- Relative motion in y direction}
    @item{@racket[buttons] --- A bitmask of pressed buttons}
  ]

  Useful for implementing mouse look in games.
}

@defproc[(mouse-button-pressed? [mask exact-nonnegative-integer?]
                                 [button exact-nonnegative-integer?]) boolean?]{
  Returns @racket[#t] if the specified button is pressed in the button mask.

  Button masks include:
  @itemlist[
    @item{@racket[SDL_BUTTON_LMASK] --- Left mouse button}
    @item{@racket[SDL_BUTTON_MMASK] --- Middle mouse button}
    @item{@racket[SDL_BUTTON_RMASK] --- Right mouse button}
    @item{@racket[SDL_BUTTON_X1MASK] --- Extra button 1}
    @item{@racket[SDL_BUTTON_X2MASK] --- Extra button 2}
  ]

  @codeblock|{
    (define-values (x y buttons) (get-mouse-state))
    (when (mouse-button-pressed? buttons SDL_BUTTON_LMASK)
      (handle-left-click x y))
    (when (mouse-button-pressed? buttons SDL_BUTTON_RMASK)
      (handle-right-click x y))
  }|
}

@section{Mouse Enumeration}

@defproc[(has-mouse?) boolean?]{
  Returns @racket[#t] if a mouse is available.
}

@defproc[(get-mice) (listof exact-nonnegative-integer?)]{
  Returns a list of mouse device instance IDs.
}

@defproc[(get-mouse-count) exact-nonnegative-integer?]{
  Returns the number of connected mice.
}

@defproc[(get-mouse-name-for-id [id exact-nonnegative-integer?]) (or/c string? #f)]{
  Returns the name of the mouse with the given instance ID, or @racket[#f] if not found.
}

@defproc[(get-mouse-focus) (or/c cpointer? #f)]{
  Returns the window that currently has mouse focus, or @racket[#f] if none.
}

@section{Mouse Warping}

@defproc[(warp-mouse! [win (or/c window? #f)] [x real?] [y real?]) void?]{
  Moves the mouse cursor to a position within a window.

  If @racket[win] is @racket[#f], uses the currently focused window.

  @codeblock|{
    ;; Move cursor to center of window
    (warp-mouse! win 400 300)
  }|
}

@defproc[(warp-mouse-global! [x real?] [y real?]) void?]{
  Moves the mouse cursor to a position in global screen coordinates.

  Note: This may not be supported on all platforms.
}

@section{Mouse Capture}

@defproc[(capture-mouse! [enabled? boolean?]) void?]{
  Enables or disables mouse capture.

  When enabled, the window receives mouse events even when the cursor
  is outside the window. This is useful for drag operations where you
  want to track the mouse even if it leaves the window.

  @codeblock|{
    ;; Start a drag operation
    (capture-mouse! #t)

    ;; ... handle drag ...

    ;; End the drag
    (capture-mouse! #f)
  }|
}

@section{Relative Mouse Mode}

Relative mouse mode is used for FPS-style input where the cursor is hidden
and mouse motion reports relative deltas rather than absolute positions.

@defproc[(set-relative-mouse-mode! [win window?] [on? boolean?]) void?]{
  Enables or disables relative mouse mode for a window.

  When enabled:
  @itemlist[
    @item{The cursor is hidden}
    @item{Mouse motion reports relative deltas instead of absolute positions}
    @item{The cursor is confined to the window}
  ]

  @codeblock|{
    ;; Enable FPS-style mouse look
    (set-relative-mouse-mode! win #t)

    ;; Handle mouse motion events for camera control
    ;; motion-event-xrel and motion-event-yrel give deltas
  }|
}

@defproc[(relative-mouse-mode? [win window?]) boolean?]{
  Returns @racket[#t] if relative mouse mode is enabled for the window.
}

@section{Cursor Visibility}

@defproc[(show-cursor!) void?]{
  Shows the mouse cursor.
}

@defproc[(hide-cursor!) void?]{
  Hides the mouse cursor.
}

@defproc[(cursor-visible?) boolean?]{
  Returns @racket[#t] if the cursor is currently visible.
}

@section{System Cursors}

SDL provides standard system cursors that you can use instead of the default
arrow cursor.

@defproc[(create-system-cursor [cursor-type (or/c symbol? exact-nonnegative-integer?)]) cpointer?]{
  Creates a system cursor of the specified type.

  Cursor type symbols include:
  @itemlist[
    @item{@racket['default] or @racket['arrow] --- Standard arrow cursor}
    @item{@racket['text] or @racket['ibeam] --- Text editing cursor}
    @item{@racket['wait] or @racket['hourglass] --- Wait/busy cursor}
    @item{@racket['crosshair] --- Crosshair cursor}
    @item{@racket['progress] --- Progress indicator}
    @item{@racket['pointer] or @racket['hand] --- Pointing hand (for links)}
    @item{@racket['move] --- Move/drag cursor}
    @item{@racket['not-allowed] or @racket['no] --- Not allowed cursor}
    @item{@racket['ew-resize] --- Horizontal resize}
    @item{@racket['ns-resize] --- Vertical resize}
    @item{@racket['nwse-resize] --- Diagonal resize (NW-SE)}
    @item{@racket['nesw-resize] --- Diagonal resize (NE-SW)}
    @item{@racket['n-resize], @racket['e-resize], etc. --- Edge resize cursors}
  ]

  The returned cursor must be freed with @racket[destroy-cursor!] when no longer needed.
}

@defproc[(set-cursor! [cursor (or/c cpointer? #f)]) void?]{
  Sets the active cursor. Pass @racket[#f] to reset to the default cursor.
}

@defproc[(destroy-cursor! [cursor cpointer?]) void?]{
  Destroys a cursor created with @racket[create-system-cursor].
}

@defform[(with-system-cursor cursor-type body ...)]{
  Temporarily uses a system cursor, then restores the previous cursor.

  @codeblock|{
    ;; Show crosshair while aiming
    (with-system-cursor 'crosshair
      (handle-aiming))

    ;; Show pointer when hovering over a button
    (when (mouse-over-button? x y)
      (with-system-cursor 'pointer
        (draw-button-hover)))
  }|
}

@section{Cursor Type Conversion}

@defproc[(symbol->system-cursor [sym symbol?]) exact-nonnegative-integer?]{
  Converts a cursor type symbol to its SDL constant.
  Raises an error if the symbol is not recognized.
}

@defproc[(system-cursor->symbol [id exact-nonnegative-integer?]) symbol?]{
  Converts an SDL system cursor constant to a symbol.
  Returns @racket['unknown] if not recognized.
}

@section{Mouse Button Constants}

These constants identify individual mouse buttons:

@defthing[SDL_BUTTON_LEFT exact-nonnegative-integer?]{Left mouse button (1).}
@defthing[SDL_BUTTON_MIDDLE exact-nonnegative-integer?]{Middle mouse button (2).}
@defthing[SDL_BUTTON_RIGHT exact-nonnegative-integer?]{Right mouse button (3).}
@defthing[SDL_BUTTON_X1 exact-nonnegative-integer?]{Extra button 1 (4).}
@defthing[SDL_BUTTON_X2 exact-nonnegative-integer?]{Extra button 2 (5).}

These constants are bitmasks for checking button state:

@defthing[SDL_BUTTON_LMASK exact-nonnegative-integer?]{Left button mask.}
@defthing[SDL_BUTTON_MMASK exact-nonnegative-integer?]{Middle button mask.}
@defthing[SDL_BUTTON_RMASK exact-nonnegative-integer?]{Right button mask.}
@defthing[SDL_BUTTON_X1MASK exact-nonnegative-integer?]{Extra button 1 mask.}
@defthing[SDL_BUTTON_X2MASK exact-nonnegative-integer?]{Extra button 2 mask.}
