#lang scribble/manual

@(require (for-label racket/base
                     racket/contract
                     sdl3))

@title[#:tag "keyboard" #:style 'quiet]{Keyboard Functions}

This section covers keyboard input handling, including key state polling,
modifier detection, and text input.

@section{Keyboard State}

@defproc[(key-pressed? [key (or/c symbol? exact-nonnegative-integer?)]) boolean?]{
  Returns @racket[#t] if the specified key is currently pressed.

  The @racket[key] can be either:
  @itemlist[
    @item{A symbol like @racket['escape], @racket['space], @racket['w], @racket['left-shift]}
    @item{A raw SDL scancode constant like @tt{SDL_SCANCODE_W}}
  ]

  @codeblock|{
    (when (key-pressed? 'escape)
      (quit!))
    (when (key-pressed? 'w)
      (move-forward!))
  }|
}

@defproc[(get-keyboard-state) (vectorof boolean?)]{
  Returns a vector of boolean values representing the current state of all keys.
  Index into the vector using SDL scancode constants.

  This is useful for checking multiple keys efficiently in a game loop.
}

@defproc[(reset-keyboard!) void?]{
  Resets the keyboard state. This generates key-up events for all currently
  pressed keys, useful when regaining window focus.
}

@section{Modifier Keys}

@defproc[(get-mod-state) exact-nonnegative-integer?]{
  Returns the current modifier key state as a bitmask.
  Use @racket[mod-state-has?] to check for specific modifiers.
}

@defproc[(mod-state-has? [state exact-nonnegative-integer?]
                         [mod symbol?]) boolean?]{
  Returns @racket[#t] if the modifier state includes the specified modifier.

  Modifier symbols include:
  @itemlist[
    @item{@racket['shift] --- Either Shift key}
    @item{@racket['ctrl] --- Either Control key}
    @item{@racket['alt] --- Either Alt key}
    @item{@racket['gui] --- Either GUI/Command/Windows key}
    @item{@racket['left-shift], @racket['right-shift] --- Specific Shift keys}
    @item{@racket['left-ctrl], @racket['right-ctrl] --- Specific Control keys}
    @item{@racket['left-alt], @racket['right-alt] --- Specific Alt keys}
    @item{@racket['caps-lock], @racket['num-lock], @racket['scroll-lock] --- Lock keys}
  ]

  @codeblock|{
    (define mods (get-mod-state))
    (when (mod-state-has? mods 'ctrl)
      (printf "Control is held~n"))
  }|
}

@section{Keyboard Enumeration}

@defproc[(has-keyboard?) boolean?]{
  Returns @racket[#t] if a keyboard is available.
}

@defproc[(get-keyboards) (listof exact-nonnegative-integer?)]{
  Returns a list of keyboard device IDs.
}

@defproc[(get-keyboard-count) exact-nonnegative-integer?]{
  Returns the number of connected keyboards.
}

@defproc[(get-keyboard-name-for-id [id exact-nonnegative-integer?]) (or/c string? #f)]{
  Returns the name of the keyboard with the given ID, or @racket[#f] if not found.
}

@defproc[(get-keyboard-focus) (or/c window? #f)]{
  Returns the window that currently has keyboard focus, or @racket[#f] if none.
}

@section{Text Input}

Text input allows receiving Unicode text from the user, including IME
(Input Method Editor) support for non-Latin scripts.

@defproc[(start-text-input! [win window?]) void?]{
  Enables text input events for the specified window.

  Once enabled, @racket[text-input-event] will be generated when the user
  types text. This is separate from key events---key events give you raw
  key presses, while text input gives you the resulting characters
  (including those composed via dead keys or IME).

  @codeblock|{
    (start-text-input! win)
    ;; Now text-input-event will fire when user types
  }|
}

@defproc[(stop-text-input! [win window?]) void?]{
  Disables text input events for the specified window.

  Call this when you no longer need text input (e.g., when leaving a
  text field) to allow the IME to close.
}

@section{Key Symbol Conversion}

These functions convert between Racket symbols and SDL scancodes/keycodes.

@defproc[(symbol->scancode [sym symbol?]) (or/c exact-nonnegative-integer? #f)]{
  Converts a key symbol to its SDL scancode, or @racket[#f] if not recognized.

  Scancodes represent physical key positions on the keyboard, independent
  of the current keyboard layout.
}

@defproc[(scancode->symbol [scancode exact-nonnegative-integer?]) (or/c symbol? #f)]{
  Converts an SDL scancode to its key symbol, or @racket[#f] if not recognized.
}

@defproc[(symbol->keycode [sym symbol?]) (or/c exact-nonnegative-integer? #f)]{
  Converts a key symbol to its SDL keycode, or @racket[#f] if not recognized.

  Keycodes represent the logical key based on the current keyboard layout.
  For example, on a QWERTY layout the 'Q' position produces keycode for 'q',
  but on an AZERTY layout it produces keycode for 'a'.
}

@defproc[(keycode->symbol [keycode exact-nonnegative-integer?]) (or/c symbol? #f)]{
  Converts an SDL keycode to its key symbol, or @racket[#f] if not recognized.
}

@section{Low-Level Key Utilities}

These functions provide direct access to SDL's scancode and keycode APIs.

@defproc[(scancode-name [scancode exact-nonnegative-integer?]) string?]{
  Returns the human-readable name for a scancode.
}

@defproc[(scancode-from-name [name string?]) exact-nonnegative-integer?]{
  Returns the scancode for the given key name.
}

@defproc[(key-from-name [name string?]) exact-nonnegative-integer?]{
  Returns the keycode for the given key name.
}

@defproc[(key-from-scancode [scancode exact-nonnegative-integer?]) exact-nonnegative-integer?]{
  Converts a scancode to the corresponding keycode based on current layout.
}

@defproc[(scancode-from-key [keycode exact-nonnegative-integer?]) exact-nonnegative-integer?]{
  Converts a keycode to the corresponding scancode based on current layout.
}
