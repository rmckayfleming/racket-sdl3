#lang scribble/manual

@(require (for-label racket/base
                     racket/contract
                     racket/match
                     sdl3))

@title[#:tag "events" #:style 'quiet]{Events}

SDL3 communicates user input and system notifications through events.
The safe API provides transparent Racket structs that work seamlessly
with @racket[match].

@section{Polling Events}

@defproc[(in-events) sequence?]{
  Returns a sequence of all pending events. Use with @racket[for] to
  process events each frame:

  @codeblock|{
    (for ([ev (in-events)])
      (match ev
        [(quit-event) (exit)]
        [(key-event 'down 'escape _ _ _) (exit)]
        [_ (void)]))
  }|
}

@defproc[(poll-event) (or/c sdl-event? #f)]{
  Returns the next pending event, or @racket[#f] if none are available.
  Prefer @racket[in-events] for typical event loops.
}

@defproc[(wait-event) sdl-event?]{
  Blocks until an event is available, then returns it.
  Useful for applications that don't need continuous rendering.
}

@defproc[(wait-event-timeout [timeout exact-nonnegative-integer?])
         (or/c sdl-event? #f)]{
  Blocks until an event is available or @racket[timeout] milliseconds
  have passed. Returns @racket[#f] on timeout.
}

@defproc[(should-quit?) boolean?]{
  Returns @racket[#t] if a quit event is pending (without consuming it).
}

@section{Event Types}

All event structs are transparent and can be used with @racket[match].
Field names follow a consistent pattern for easy pattern matching.

@subsection{Application Events}

@defstruct*[quit-event () #:transparent]{
  Sent when the user requests to quit (e.g., closes the window,
  presses Cmd+Q on macOS).

  @codeblock|{
    (match ev
      [(quit-event) (set! running? #f)]
      ...)
  }|
}

@subsection{Window Events}

@defstruct*[window-event ([type symbol?]) #:transparent]{
  Sent when a window's state changes.

  The @racket[type] field indicates what happened:
  @itemlist[
    @item{@racket['close-requested] --- User requested window close}
    @item{@racket['shown] --- Window became visible}
    @item{@racket['hidden] --- Window was hidden}
    @item{@racket['exposed] --- Window needs redrawing}
    @item{@racket['moved] --- Window was moved}
    @item{@racket['resized] --- Window was resized}
    @item{@racket['minimized] --- Window was minimized}
    @item{@racket['maximized] --- Window was maximized}
    @item{@racket['restored] --- Window was restored}
    @item{@racket['focus-gained] --- Window gained keyboard focus}
    @item{@racket['focus-lost] --- Window lost keyboard focus}
    @item{@racket['mouse-enter] --- Mouse entered window}
    @item{@racket['mouse-leave] --- Mouse left window}
  ]

  @codeblock|{
    (match ev
      [(window-event 'close-requested) (set! running? #f)]
      [(window-event 'resized) (handle-resize)]
      ...)
  }|
}

@subsection{Keyboard Events}

@defstruct*[key-event ([type (or/c 'down 'up)]
                       [key symbol?]
                       [scancode exact-nonnegative-integer?]
                       [mod exact-nonnegative-integer?]
                       [repeat? boolean?])
            #:transparent]{
  Sent when a key is pressed or released.

  @itemlist[
    @item{@racket[type] --- @racket['down] for key press, @racket['up] for release}
    @item{@racket[key] --- Key symbol (e.g., @racket['a], @racket['space], @racket['escape])}
    @item{@racket[scancode] --- Physical key code (keyboard-layout independent)}
    @item{@racket[mod] --- Modifier key bitmask (use @racket[mod-shift?], etc.)}
    @item{@racket[repeat?] --- @racket[#t] if this is a key repeat event}
  ]

  Common key symbols include: @racket['a] through @racket['z],
  @racket['0] through @racket['9], @racket['space], @racket['escape],
  @racket['return], @racket['backspace], @racket['tab], @racket['up],
  @racket['down], @racket['left], @racket['right], @racket['f1] through @racket['f12].

  @codeblock|{
    (match ev
      ;; Simple key matching
      [(key-event 'down 'escape _ _ _) (exit)]
      [(key-event 'down 'space _ _ _) (fire-bullet!)]

      ;; With modifiers
      [(key-event 'down 's _ mod _)
       #:when (mod-ctrl? mod)
       (save-file!)]

      ;; Ignore key repeats
      [(key-event 'down 'w _ _ #f) (start-moving)]
      [(key-event 'up 'w _ _ _) (stop-moving)]
      ...)
  }|
}

@defproc[(key-name [key symbol?]) string?]{
  Returns a human-readable name for a key symbol.

  @codeblock|{
    (key-name 'escape)  ; => "Escape"
    (key-name 'space)   ; => "Space"
  }|
}

@subsubsection{Modifier Key Predicates}

These predicates check if modifier keys are held in a @racket[key-event]'s
@racket[mod] field:

@defproc[(mod-shift? [mod exact-nonnegative-integer?]) boolean?]{
  Returns @racket[#t] if Shift is held.
}

@defproc[(mod-ctrl? [mod exact-nonnegative-integer?]) boolean?]{
  Returns @racket[#t] if Control is held.
}

@defproc[(mod-alt? [mod exact-nonnegative-integer?]) boolean?]{
  Returns @racket[#t] if Alt/Option is held.
}

@defproc[(mod-gui? [mod exact-nonnegative-integer?]) boolean?]{
  Returns @racket[#t] if the GUI key (Cmd on macOS, Windows key on Windows) is held.
}

@subsection{Text Input Events}

@defstruct*[text-input-event ([text string?]) #:transparent]{
  Sent when text is entered. Use this for text input fields instead of
  @racket[key-event], as it handles international keyboards, IME, etc.

  Must be enabled with @racket[start-text-input!] first.

  @codeblock|{
    (match ev
      [(text-input-event txt)
       (set! input-string (string-append input-string txt))]
      ...)
  }|
}

@subsection{Mouse Events}

@defstruct*[mouse-motion-event ([x real?]
                                [y real?]
                                [xrel real?]
                                [yrel real?]
                                [state exact-nonnegative-integer?])
            #:transparent]{
  Sent when the mouse moves.

  @itemlist[
    @item{@racket[x], @racket[y] --- Current mouse position}
    @item{@racket[xrel], @racket[yrel] --- Relative motion since last event}
    @item{@racket[state] --- Button state bitmask}
  ]
}

@defstruct*[mouse-button-event ([type (or/c 'down 'up)]
                                [button (or/c 'left 'middle 'right symbol?)]
                                [x real?]
                                [y real?]
                                [clicks exact-nonnegative-integer?])
            #:transparent]{
  Sent when a mouse button is pressed or released.

  @itemlist[
    @item{@racket[type] --- @racket['down] or @racket['up]}
    @item{@racket[button] --- @racket['left], @racket['middle], @racket['right], or a number for extra buttons}
    @item{@racket[x], @racket[y] --- Mouse position}
    @item{@racket[clicks] --- Click count (1 for single, 2 for double-click, etc.)}
  ]

  @codeblock|{
    (match ev
      [(mouse-button-event 'down 'left x y 1)
       (handle-click x y)]
      [(mouse-button-event 'down 'left x y 2)
       (handle-double-click x y)]
      ...)
  }|
}

@defstruct*[mouse-wheel-event ([x real?]
                               [y real?]
                               [direction symbol?]
                               [mouse-x real?]
                               [mouse-y real?])
            #:transparent]{
  Sent when the mouse wheel is scrolled.

  @itemlist[
    @item{@racket[x], @racket[y] --- Scroll amounts (y is typically vertical scroll)}
    @item{@racket[direction] --- @racket['normal] or @racket['flipped]}
    @item{@racket[mouse-x], @racket[mouse-y] --- Mouse position}
  ]
}

@subsection{Gamepad Events}

@defstruct*[gamepad-button-event ([type (or/c 'down 'up)]
                                  [which exact-nonnegative-integer?]
                                  [button symbol?])
            #:transparent]{
  Sent when a gamepad button is pressed or released.

  @itemlist[
    @item{@racket[type] --- @racket['down] or @racket['up]}
    @item{@racket[which] --- Gamepad instance ID}
    @item{@racket[button] --- Button symbol (e.g., @racket['a], @racket['b], @racket['start])}
  ]
}

@defstruct*[gamepad-axis-event ([which exact-nonnegative-integer?]
                                [axis symbol?]
                                [value real?])
            #:transparent]{
  Sent when a gamepad axis moves.

  @itemlist[
    @item{@racket[which] --- Gamepad instance ID}
    @item{@racket[axis] --- Axis symbol (e.g., @racket['leftx], @racket['lefty])}
    @item{@racket[value] --- Axis value (-1.0 to 1.0)}
  ]
}

@defstruct*[gamepad-device-event ([type (or/c 'added 'removed)]
                                  [which exact-nonnegative-integer?])
            #:transparent]{
  Sent when a gamepad is connected or disconnected.
}

@subsection{Joystick Events}

@defstruct*[joy-axis-event ([which exact-nonnegative-integer?]
                            [axis exact-nonnegative-integer?]
                            [value real?])
            #:transparent]{
  Sent when a joystick axis moves.
}

@defstruct*[joy-button-event ([type (or/c 'down 'up)]
                              [which exact-nonnegative-integer?]
                              [button exact-nonnegative-integer?])
            #:transparent]{
  Sent when a joystick button is pressed or released.
}

@defstruct*[joy-hat-event ([which exact-nonnegative-integer?]
                           [hat exact-nonnegative-integer?]
                           [value exact-nonnegative-integer?])
            #:transparent]{
  Sent when a joystick hat switch moves.
}

@defstruct*[joy-device-event ([type (or/c 'added 'removed)]
                              [which exact-nonnegative-integer?])
            #:transparent]{
  Sent when a joystick is connected or disconnected.
}

@subsection{Touch Events}

@defstruct*[touch-finger-event ([type (or/c 'down 'up 'motion)]
                                [touch-id exact-nonnegative-integer?]
                                [finger-id exact-nonnegative-integer?]
                                [x real?]
                                [y real?]
                                [dx real?]
                                [dy real?]
                                [pressure real?])
            #:transparent]{
  Sent for touch input.

  @itemlist[
    @item{@racket[x], @racket[y] --- Normalized position (0.0 to 1.0)}
    @item{@racket[dx], @racket[dy] --- Normalized motion delta}
    @item{@racket[pressure] --- Touch pressure (0.0 to 1.0)}
  ]
}

@subsection{Drop Events}

@defstruct*[drop-event ([type (or/c 'file 'text 'begin 'complete 'position)]
                        [x real?]
                        [y real?]
                        [source string?]
                        [data (or/c string? #f)])
            #:transparent]{
  Sent when files or text are dropped onto the window.

  For @racket['file] type, @racket[data] contains the file path.
  For @racket['text] type, @racket[data] contains the dropped text.
}

@subsection{Clipboard Events}

@defstruct*[clipboard-event ([owner? boolean?]
                             [mime-types (listof string?)])
            #:transparent]{
  Sent when the clipboard contents change.
}

@subsection{Audio/Camera Device Events}

@defstruct*[audio-device-event ([type (or/c 'added 'removed)]
                                [which exact-nonnegative-integer?]
                                [recording? boolean?])
            #:transparent]{
  Sent when an audio device is connected or disconnected.
}

@defstruct*[camera-device-event ([type (or/c 'added 'removed 'approved 'denied)]
                                 [which exact-nonnegative-integer?])
            #:transparent]{
  Sent when a camera device state changes.
}

@subsection{Unknown Events}

@defstruct*[unknown-event ([type exact-nonnegative-integer?]) #:transparent]{
  Used for event types not yet supported by the safe API.
  The @racket[type] field contains the raw SDL event type constant.
}

@section{Event Handling Patterns}

@subsection{Basic Event Loop}

@codeblock|{
(let loop ()
  (define quit?
    (for/or ([ev (in-events)])
      (match ev
        [(quit-event) #t]
        [(key-event 'down 'escape _ _ _) #t]
        [_ #f])))

  (unless quit?
    ;; Update and render
    (render-frame!)
    (loop)))
}|

@subsection{Event-Driven vs State Polling}

Use @bold{event-driven} input for:
@itemlist[
  @item{Discrete actions (menu selection, firing a weapon)}
  @item{Text input}
  @item{Detecting specific key presses}
]

Use @bold{state polling} (see @secref["keyboard"]) for:
@itemlist[
  @item{Smooth continuous movement}
  @item{Checking if a key is currently held}
]

Many games use both: events for actions, polling for movement.
