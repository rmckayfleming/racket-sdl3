#lang scribble/manual

@(require (for-label racket/base
                     racket/contract
                     sdl3))

@title[#:tag "initialization" #:style 'quiet]{Initialization}

Before using any SDL3 functions, the library must be initialized.
The safe API provides both syntax forms and procedural functions.

@section{Initialization Syntax}

@defform[(with-sdl maybe-flags body ...)
         #:grammar ([maybe-flags (code:line)
                                  (code:line #:flags flags)])
         #:contracts ([flags (or/c symbol? (listof symbol?))])]{
  Initializes SDL, evaluates @racket[body] forms, then shuts down SDL.
  This is the recommended way to structure an SDL program.

  By default, initializes the video subsystem. Use @racket[#:flags] to
  initialize specific subsystems:
  @itemlist[
    @item{@racket['video] --- Video subsystem (default)}
    @item{@racket['audio] --- Audio subsystem}
    @item{@racket['events] --- Events subsystem}
    @item{@racket['joystick] --- Joystick subsystem}
    @item{@racket['gamepad] --- Gamepad subsystem}
    @item{@racket['camera] --- Camera subsystem}
  ]

  @codeblock|{
    (with-sdl
      (displayln "SDL is ready!")
      ;; ... your SDL code here ...
      )

    (with-sdl #:flags '(video audio)
      ;; Both video and audio are available
      )
  }|
}

@section{Initialization Functions}

@defproc[(sdl-init! [flags (or/c symbol? (listof symbol?)) 'video]) void?]{
  Initializes SDL with the specified subsystems. Raises an error if
  initialization fails.

  @racket[flags] can be a single symbol or a list of symbols. See
  @racket[with-sdl] for available flags.

  @codeblock|{
    (sdl-init!)              ; Initialize video only
    (sdl-init! 'audio)       ; Initialize audio only
    (sdl-init! '(video audio)) ; Initialize both
  }|
}

@defproc[(sdl-quit!) void?]{
  Shuts down all SDL subsystems. Call this when your program is done
  using SDL. If using @racket[with-sdl], this is called automatically.
}

@defproc[(sdl-init-subsystem! [flags (or/c symbol? (listof symbol?))]) void?]{
  Initializes additional subsystems after SDL has already been initialized.
  Useful for lazily initializing subsystems as needed.
}

@defproc[(sdl-quit-subsystem! [flags (or/c symbol? (listof symbol?))]) void?]{
  Shuts down specific subsystems while keeping others running.
}

@defproc[(sdl-was-init [flags exact-nonnegative-integer? 0]) exact-nonnegative-integer?]{
  Returns a bitmask of which subsystems are currently initialized.
  If @racket[flags] is 0, returns all initialized subsystems.
}

@defproc[(error-message) string?]{
  Returns the last SDL error message. Useful for debugging when an
  operation fails.
}

@section{Application Metadata}

@defproc[(set-app-metadata! [name string?]
                            [version string?]
                            [identifier string?]) void?]{
  Sets application metadata used by the operating system. Should be called
  before creating windows.

  @itemlist[
    @item{@racket[name] --- Human-readable application name}
    @item{@racket[version] --- Version string (e.g., @racket["1.0.0"])}
    @item{@racket[identifier] --- Unique identifier (e.g., @racket["com.example.myapp"])}
  ]
}

@defproc[(set-app-metadata-property! [name string?] [value string?]) void?]{
  Sets a specific metadata property. Use the @tt{SDL_PROP_APP_METADATA_*}
  constants for property names.
}

@defproc[(get-app-metadata-property [name string?]) (or/c string? #f)]{
  Gets a metadata property value, or @racket[#f] if not set.
}
