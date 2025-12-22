#lang scribble/manual

@(require (for-label racket/base
                     racket/contract
                     sdl3))

@title[#:tag "timer" #:style 'quiet]{Timer Functions}

This section covers timing and delay functions for animation and frame timing.

@section{Time Queries}

@defproc[(current-ticks) exact-nonnegative-integer?]{
  Returns the number of milliseconds since SDL was initialized.
  Use this for timing and animation.
}

@defproc[(current-ticks-ns) exact-nonnegative-integer?]{
  Returns the number of nanoseconds since SDL was initialized.
  More precise than @racket[current-ticks] but still based on SDL's
  internal timer.
}

@defproc[(current-time-ns) exact-nonnegative-integer?]{
  Returns high-precision time in nanoseconds using the performance counter.
  More accurate than @racket[current-ticks-ns] for profiling and benchmarking.
}

@section{Delays}

@defproc[(delay! [ms real?]) void?]{
  Pauses execution for @racket[ms] milliseconds.

  Uses Racket's @racket[sleep] internally, which cooperates with the
  Racket thread scheduler and allows async FFI callbacks to run.
}

@defproc[(delay-ns! [ns real?]) void?]{
  Pauses execution for @racket[ns] nanoseconds.

  Like @racket[delay!] but accepts nanoseconds instead of milliseconds.
}

@defproc[(delay-precise! [ns exact-nonnegative-integer?]) void?]{
  Delays for @racket[ns] nanoseconds with busy-waiting for precision.

  More CPU-intensive but more accurate than @racket[delay-ns!].
  Good for frame timing where precise delays are needed.
}

@section{Performance Counter}

For advanced timing needs, these functions provide direct access to the
high-resolution performance counter.

@defproc[(performance-counter) exact-nonnegative-integer?]{
  Returns the raw performance counter value.

  Values are only meaningful relative to each other. Use
  @racket[performance-frequency] to convert to time units.
}

@defproc[(performance-frequency) exact-positive-integer?]{
  Returns the performance counter frequency (counts per second).

  Use this to convert performance counter differences to time:
  @codeblock|{
    (define start (performance-counter))
    ;; ... work ...
    (define end (performance-counter))
    (define elapsed-seconds
      (/ (- end start) (performance-frequency)))
  }|
}

@section{Timing Utilities}

@defform[(with-timing body ...)]{
  Executes @racket[body] and returns two values: the result of @racket[body]
  and the elapsed time in nanoseconds.

  Uses the high-precision performance counter for accurate measurement.

  @codeblock|{
    (define-values (result elapsed-ns)
      (with-timing
        (some-expensive-computation)))
    (printf "Took ~a ns~n" elapsed-ns)
  }|
}

@section{Time Unit Constants}

These constants are provided for convenience when working with time values:

@defthing[NS_PER_SECOND exact-positive-integer? #:value 1000000000]{
  Nanoseconds per second.
}

@defthing[NS_PER_MS exact-positive-integer? #:value 1000000]{
  Nanoseconds per millisecond.
}

@defthing[NS_PER_US exact-positive-integer? #:value 1000]{
  Nanoseconds per microsecond.
}

@defthing[MS_PER_SECOND exact-positive-integer? #:value 1000]{
  Milliseconds per second.
}
