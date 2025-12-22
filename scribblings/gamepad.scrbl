#lang scribble/manual

@(require (for-label racket/base
                     racket/contract
                     sdl3))

@title[#:tag "gamepad" #:style 'quiet]{Gamepads}

This section covers gamepad (game controller) support with standardized
button and axis names. For lower-level joystick access, see @secref{joystick}.

@section{Detection}

@defproc[(has-gamepad?) boolean?]{
  Returns @racket[#t] if any gamepads are connected.
}

@defproc[(get-gamepads) (listof exact-nonnegative-integer?)]{
  Returns a list of connected gamepad instance IDs.

  @codeblock|{
    (for ([id (get-gamepads)])
      (printf "Gamepad: ~a~n" (get-gamepad-name-for-id id)))
  }|
}

@defproc[(get-gamepad-count) exact-nonnegative-integer?]{
  Returns the number of connected gamepads.
}

@defproc[(is-gamepad? [instance-id exact-nonnegative-integer?]) boolean?]{
  Returns @racket[#t] if the given joystick instance ID is a gamepad.
}

@section{Opening and Closing}

@defproc[(open-gamepad [instance-id exact-nonnegative-integer?]) gamepad?]{
  Opens a gamepad by its instance ID.

  The gamepad is registered with the current custodian for automatic cleanup.

  @codeblock|{
    (define ids (get-gamepads))
    (when (pair? ids)
      (define gp (open-gamepad (car ids)))
      (printf "Opened: ~a~n" (gamepad-name gp)))
  }|
}

@defproc[(gamepad? [v any/c]) boolean?]{
  Returns @racket[#t] if @racket[v] is a gamepad.
}

@defproc[(gamepad-connected? [gp gamepad?]) boolean?]{
  Returns @racket[#t] if the gamepad is still connected.
}

@defproc[(gamepad-destroy! [gp gamepad?]) void?]{
  Closes a gamepad.

  Note: Gamepads are automatically closed when their custodian shuts down.
}

@section{Gamepad Information}

@defproc[(gamepad-name [gp gamepad?]) (or/c string? #f)]{
  Returns the gamepad name.
}

@defproc[(gamepad-path [gp gamepad?]) (or/c string? #f)]{
  Returns the device path.
}

@defproc[(gamepad-id [gp gamepad?]) exact-nonnegative-integer?]{
  Returns the instance ID.
}

@defproc[(gamepad-type [gp gamepad?]) symbol?]{
  Returns the gamepad type as a symbol.

  Values: @racket['unknown], @racket['standard], @racket['xbox360],
  @racket['xboxone], @racket['ps3], @racket['ps4], @racket['ps5],
  @racket['switch-pro], @racket['switch-joycon-left],
  @racket['switch-joycon-right], @racket['switch-joycon-pair].
}

@defproc[(gamepad-real-type [gp gamepad?]) symbol?]{
  Returns the actual hardware type (may differ from mapped type).
}

@defproc[(gamepad-vendor [gp gamepad?]) exact-nonnegative-integer?]{
  Returns the USB vendor ID.
}

@defproc[(gamepad-product [gp gamepad?]) exact-nonnegative-integer?]{
  Returns the USB product ID.
}

@defproc[(gamepad-serial [gp gamepad?]) (or/c string? #f)]{
  Returns the serial number.
}

@subsection{Info by ID (before opening)}

@defproc[(get-gamepad-name-for-id [instance-id exact-nonnegative-integer?]) (or/c string? #f)]{
  Returns the name of a gamepad before opening it.
}

@defproc[(get-gamepad-type-for-id [instance-id exact-nonnegative-integer?]) symbol?]{
  Returns the type of a gamepad before opening it.
}

@section{Buttons}

@defproc[(gamepad-button [gp gamepad?]
                         [button (or/c symbol? exact-nonnegative-integer?)]) boolean?]{
  Returns @racket[#t] if the button is pressed.

  Button symbols include:
  @itemlist[
    @item{@racket['south] (A on Xbox, Cross on PlayStation)}
    @item{@racket['east] (B on Xbox, Circle on PlayStation)}
    @item{@racket['west] (X on Xbox, Square on PlayStation)}
    @item{@racket['north] (Y on Xbox, Triangle on PlayStation)}
    @item{@racket['back], @racket['start], @racket['guide]}
    @item{@racket['left-stick], @racket['right-stick] (L3/R3)}
    @item{@racket['left-shoulder], @racket['right-shoulder] (LB/RB or L1/R1)}
    @item{@racket['dpad-up], @racket['dpad-down], @racket['dpad-left], @racket['dpad-right]}
  ]

  Platform-specific aliases are also supported:
  @itemlist[
    @item{Xbox: @racket['a], @racket['b], @racket['x], @racket['y]}
    @item{PlayStation: @racket['cross], @racket['circle], @racket['square], @racket['triangle]}
    @item{Shoulder: @racket['lb], @racket['rb], @racket['l1], @racket['r1]}
  ]

  @codeblock|{
    (when (gamepad-button gp 'south)
      (player-jump!))
  }|
}

@defproc[(gamepad-has-button? [gp gamepad?]
                              [button (or/c symbol? exact-nonnegative-integer?)]) boolean?]{
  Returns @racket[#t] if the gamepad has the specified button.
}

@section{Axes}

@defproc[(gamepad-axis [gp gamepad?]
                       [axis (or/c symbol? exact-nonnegative-integer?)]) exact-integer?]{
  Returns the current axis value.

  For sticks: -32768 to 32767 (centered at 0).
  For triggers: 0 to 32767.

  Axis symbols:
  @itemlist[
    @item{@racket['left-x], @racket['left-y] --- Left stick}
    @item{@racket['right-x], @racket['right-y] --- Right stick}
    @item{@racket['left-trigger], @racket['right-trigger] --- Triggers (LT/RT or L2/R2)}
  ]

  @codeblock|{
    (define lx (gamepad-axis gp 'left-x))
    (define ly (gamepad-axis gp 'left-y))
    (move-player! (/ lx 32768.0) (/ ly 32768.0))
  }|
}

@defproc[(gamepad-has-axis? [gp gamepad?]
                            [axis (or/c symbol? exact-nonnegative-integer?)]) boolean?]{
  Returns @racket[#t] if the gamepad has the specified axis.
}

@section{Button Labels}

For displaying button prompts that match the controller type.

@defproc[(gamepad-button-label [gp gamepad?]
                               [button (or/c symbol? exact-nonnegative-integer?)]) symbol?]{
  Returns the label for a button on the connected gamepad.

  Returns symbols like @racket['a], @racket['b], @racket['x], @racket['y]
  for Xbox, or @racket['cross], @racket['circle], @racket['square],
  @racket['triangle] for PlayStation.
}

@defproc[(gamepad-button-label-for-type [type symbol?]
                                        [button (or/c symbol? exact-nonnegative-integer?)]) symbol?]{
  Returns the label for a button on a specific controller type.
}

@section{Player Index}

@defproc[(gamepad-player-index [gp gamepad?]) exact-integer?]{
  Returns the player index (-1 if not set).
}

@defproc[(set-gamepad-player-index! [gp gamepad?]
                                    [index exact-integer?]) void?]{
  Sets the player index.
}

@section{Rumble}

@defproc[(gamepad-rumble! [gp gamepad?]
                          [low exact-nonnegative-integer?]
                          [high exact-nonnegative-integer?]
                          [duration-ms exact-nonnegative-integer? 0]) boolean?]{
  Starts a rumble effect.

  @racket[low] and @racket[high] are motor intensities (0-65535).
  @racket[duration-ms] is the duration in milliseconds (0 = infinite).

  @codeblock|{
    ;; Strong rumble for 200ms
    (gamepad-rumble! gp 65535 65535 200)
  }|
}

@defproc[(gamepad-rumble-triggers! [gp gamepad?]
                                   [left exact-nonnegative-integer?]
                                   [right exact-nonnegative-integer?]
                                   [duration-ms exact-nonnegative-integer? 0]) boolean?]{
  Starts a trigger rumble effect (Xbox-style controllers).
}

@section{LED}

@defproc[(gamepad-set-led! [gp gamepad?]
                           [r byte?] [g byte?] [b byte?]) boolean?]{
  Sets the LED color (if supported).
}

@section{Power}

@defproc[(gamepad-power-info [gp gamepad?]) (values symbol? exact-integer?)]{
  Returns the power state and battery percentage.

  Power states: @racket['unknown], @racket['on-battery], @racket['no-battery],
  @racket['charging], @racket['charged], @racket['error].

  Percentage is 0-100, or -1 if unknown.
}

@defproc[(gamepad-connection-state [gp gamepad?]) symbol?]{
  Returns the connection type.

  Values: @racket['unknown], @racket['wired], @racket['wireless], @racket['invalid].
}

@section{Type Conversions}

@defproc[(symbol->button [sym symbol?]) exact-nonnegative-integer?]{
  Converts a button symbol to its SDL constant.
}

@defproc[(button->symbol [btn exact-nonnegative-integer?]) symbol?]{
  Converts an SDL button constant to a symbol.
}

@defproc[(symbol->axis [sym symbol?]) exact-nonnegative-integer?]{
  Converts an axis symbol to its SDL constant.
}

@defproc[(axis->symbol [axis exact-nonnegative-integer?]) symbol?]{
  Converts an SDL axis constant to a symbol.
}

@defproc[(gamepad-type->symbol [type exact-nonnegative-integer?]) symbol?]{
  Converts an SDL gamepad type to a symbol.
}
