#lang scribble/manual

@(require (for-label racket/base
                     racket/contract
                     sdl3))

@title[#:tag "joystick" #:style 'quiet]{Joysticks}

This section covers low-level joystick access. For a higher-level API with
standardized button names, see @secref{gamepad}.

@section{Detection}

@defproc[(has-joystick?) boolean?]{
  Returns @racket[#t] if any joysticks are connected.
}

@defproc[(get-joysticks) (listof exact-nonnegative-integer?)]{
  Returns a list of connected joystick instance IDs.
}

@defproc[(get-joystick-count) exact-nonnegative-integer?]{
  Returns the number of connected joysticks.
}

@section{Opening and Closing}

@defproc[(open-joystick [instance-id exact-nonnegative-integer?]) joystick?]{
  Opens a joystick by its instance ID.

  The joystick is registered with the current custodian for automatic cleanup.
}

@defproc[(joystick? [v any/c]) boolean?]{
  Returns @racket[#t] if @racket[v] is a joystick.
}

@defproc[(joystick-connected? [joy joystick?]) boolean?]{
  Returns @racket[#t] if the joystick is still connected.
}

@defproc[(joystick-destroy! [joy joystick?]) void?]{
  Closes a joystick.

  Note: Joysticks are automatically closed when their custodian shuts down.
}

@section{Joystick Information}

@defproc[(joystick-name [joy joystick?]) (or/c string? #f)]{
  Returns the joystick name.
}

@defproc[(joystick-path [joy joystick?]) (or/c string? #f)]{
  Returns the device path.
}

@defproc[(joystick-id [joy joystick?]) exact-nonnegative-integer?]{
  Returns the instance ID.
}

@defproc[(joystick-type [joy joystick?]) symbol?]{
  Returns the joystick type.

  Values: @racket['unknown], @racket['gamepad], @racket['wheel],
  @racket['arcade-stick], @racket['flight-stick], @racket['dance-pad],
  @racket['guitar], @racket['drum-kit], @racket['arcade-pad], @racket['throttle].
}

@defproc[(joystick-vendor [joy joystick?]) exact-nonnegative-integer?]{
  Returns the USB vendor ID.
}

@defproc[(joystick-product [joy joystick?]) exact-nonnegative-integer?]{
  Returns the USB product ID.
}

@defproc[(joystick-serial [joy joystick?]) (or/c string? #f)]{
  Returns the serial number.
}

@subsection{Info by ID (before opening)}

@defproc[(get-joystick-name-for-id [instance-id exact-nonnegative-integer?]) (or/c string? #f)]{
  Returns the name of a joystick before opening it.
}

@defproc[(get-joystick-type-for-id [instance-id exact-nonnegative-integer?]) symbol?]{
  Returns the type of a joystick before opening it.
}

@section{Capabilities}

@defproc[(joystick-num-axes [joy joystick?]) exact-nonnegative-integer?]{
  Returns the number of axes.
}

@defproc[(joystick-num-buttons [joy joystick?]) exact-nonnegative-integer?]{
  Returns the number of buttons.
}

@defproc[(joystick-num-hats [joy joystick?]) exact-nonnegative-integer?]{
  Returns the number of hat switches (D-pads).
}

@defproc[(joystick-num-balls [joy joystick?]) exact-nonnegative-integer?]{
  Returns the number of trackballs.
}

@section{Reading State}

@defproc[(joystick-axis [joy joystick?]
                        [axis-index exact-nonnegative-integer?]) exact-integer?]{
  Returns the current value of an axis (-32768 to 32767).
}

@defproc[(joystick-button [joy joystick?]
                          [button-index exact-nonnegative-integer?]) boolean?]{
  Returns @racket[#t] if the button is pressed.
}

@defproc[(joystick-hat [joy joystick?]
                       [hat-index exact-nonnegative-integer?]) symbol?]{
  Returns the current hat position as a symbol.

  Values: @racket['centered], @racket['up], @racket['down], @racket['left],
  @racket['right], @racket['up-right], @racket['up-left], @racket['down-right],
  @racket['down-left].
}

@defproc[(joystick-ball [joy joystick?]
                        [ball-index exact-nonnegative-integer?])
         (values exact-integer? exact-integer?)]{
  Returns the trackball delta since the last call.

  Returns @racket[(values dx dy)].
}

@section{Hat Value Conversion}

@defproc[(hat-value->symbol [v exact-nonnegative-integer?]) symbol?]{
  Converts an SDL hat value to a direction symbol.
}

@defproc[(hat-value->list [v exact-nonnegative-integer?]) (listof symbol?)]{
  Converts an SDL hat value to a list of active directions.

  For compound directions (like up-right), returns @racket['(up right)].
}

@section{Player Index}

@defproc[(joystick-player-index [joy joystick?]) exact-integer?]{
  Returns the player index (-1 if not set).
}

@defproc[(set-joystick-player-index! [joy joystick?]
                                     [index exact-integer?]) void?]{
  Sets the player index.
}

@section{Rumble}

@defproc[(joystick-rumble! [joy joystick?]
                           [low exact-nonnegative-integer?]
                           [high exact-nonnegative-integer?]
                           [duration-ms exact-nonnegative-integer? 0]) boolean?]{
  Starts a rumble effect.

  @racket[low] and @racket[high] are motor intensities (0-65535).
  @racket[duration-ms] is the duration in milliseconds (0 = infinite).
}

@defproc[(joystick-rumble-triggers! [joy joystick?]
                                    [left exact-nonnegative-integer?]
                                    [right exact-nonnegative-integer?]
                                    [duration-ms exact-nonnegative-integer? 0]) boolean?]{
  Starts a trigger rumble effect (Xbox-style controllers).
}

@section{LED}

@defproc[(joystick-set-led! [joy joystick?]
                            [r byte?] [g byte?] [b byte?]) boolean?]{
  Sets the LED color (if supported).
}

@section{Power}

@defproc[(joystick-power-info [joy joystick?]) (values symbol? exact-integer?)]{
  Returns the power state and battery percentage.

  Power states: @racket['unknown], @racket['on-battery], @racket['no-battery],
  @racket['charging], @racket['charged], @racket['error].

  Percentage is 0-100, or -1 if unknown.
}

@defproc[(joystick-connection-state [joy joystick?]) symbol?]{
  Returns the connection type.

  Values: @racket['unknown], @racket['wired], @racket['wireless], @racket['invalid].
}

@section{Type Conversion}

@defproc[(joystick-type->symbol [type exact-nonnegative-integer?]) symbol?]{
  Converts an SDL joystick type to a symbol.
}
