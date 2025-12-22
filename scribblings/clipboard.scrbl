#lang scribble/manual

@(require (for-label racket/base
                     racket/contract
                     sdl3))

@title[#:tag "clipboard"]{Clipboard}

This section covers system clipboard access.

@section{Clipboard Operations}

@defproc[(clipboard-text) (or/c string? #f)]{
  Gets text from the system clipboard.

  Returns the clipboard text as a string, or @racket[#f] if the clipboard
  is empty or doesn't contain text.

  @codeblock|{
    (define text (clipboard-text))
    (when text
      (printf "Clipboard contains: ~a~n" text))
  }|
}

@defproc[(set-clipboard-text! [text string?]) #t]{
  Sets the system clipboard text.

  Returns @racket[#t] on success.

  @codeblock|{
    (set-clipboard-text! "Hello from SDL3!")
  }|
}

@defproc[(clipboard-has-text?) boolean?]{
  Returns @racket[#t] if the clipboard contains text.

  @codeblock|{
    (when (clipboard-has-text?)
      (define text (clipboard-text))
      (handle-paste text))
  }|
}
