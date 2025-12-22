#lang scribble/manual

@(require (for-label racket/base
                     racket/contract
                     sdl3))

@title[#:tag "dialog"]{Dialogs}

This section covers message boxes and file dialogs.

@section{Message Boxes}

@defproc[(show-message-box [title string?]
                           [message string?]
                           [#:type type (or/c 'info 'warning 'error) 'info]
                           [#:window window (or/c window? #f) #f]) boolean?]{
  Displays a simple message box.

  @racket[type] controls the icon displayed:
  @itemlist[
    @item{@racket['info] --- Information icon (default)}
    @item{@racket['warning] --- Warning icon}
    @item{@racket['error] --- Error icon}
  ]

  @racket[window] is an optional parent window.

  Returns @racket[#t] on success.

  @codeblock|{
    (show-message-box "Welcome" "Hello, World!")
    (show-message-box "Oops" "Something went wrong"
                      #:type 'error)
  }|
}

@defproc[(show-confirm-dialog [title string?]
                              [message string?]
                              [#:buttons buttons (or/c 'yes-no 'yes-no-cancel
                                                       'ok-cancel 'ok) 'yes-no]
                              [#:type type (or/c 'info 'warning 'error) 'info]
                              [#:window window (or/c window? #f) #f])
         (or/c 'yes 'no 'ok 'cancel #f)]{
  Displays a confirmation dialog with custom buttons.

  Button configurations:
  @itemlist[
    @item{@racket['yes-no] --- Yes/No buttons, returns @racket['yes] or @racket['no]}
    @item{@racket['yes-no-cancel] --- Yes/No/Cancel, returns @racket['yes], @racket['no], or @racket['cancel]}
    @item{@racket['ok-cancel] --- OK/Cancel, returns @racket['ok] or @racket['cancel]}
    @item{@racket['ok] --- Single OK button, returns @racket['ok]}
  ]

  Returns @racket[#f] on failure.

  @codeblock|{
    (define result (show-confirm-dialog "Save?" "Save changes before closing?"
                                        #:buttons 'yes-no-cancel))
    (case result
      [(yes) (save-and-close)]
      [(no) (close-without-saving)]
      [(cancel) (void)])  ; User canceled
  }|
}

@section{File Dialogs}

@defproc[(open-file-dialog [#:filters filters (listof (cons/c string? string?)) '()]
                           [#:default-path default-path (or/c string? #f) #f]
                           [#:allow-multiple? allow-multiple? boolean? #f]
                           [#:window window (or/c window? #f) #f])
         (or/c string? (listof string?) #f)]{
  Displays a file open dialog.

  @racket[filters] is a list of filter pairs: @racket[(cons name pattern)].
  Patterns use semicolons to separate extensions (e.g., @racket["png;jpg;gif"]).

  @racket[default-path] is the starting folder or file path.

  If @racket[allow-multiple?] is @racket[#t], returns a list of paths.
  Otherwise returns a single path string.

  Returns @racket[#f] if the user cancels.

  @codeblock|{
    ;; Single file selection
    (define file (open-file-dialog
                   #:filters '(("Images" . "png;jpg;gif")
                               ("All Files" . "*"))))
    (when file
      (load-image file))

    ;; Multiple file selection
    (define files (open-file-dialog
                    #:filters '(("Text Files" . "txt;md"))
                    #:allow-multiple? #t))
    (when files
      (for ([f files])
        (process-file f)))
  }|
}

@defproc[(save-file-dialog [#:filters filters (listof (cons/c string? string?)) '()]
                           [#:default-path default-path (or/c string? #f) #f]
                           [#:window window (or/c window? #f) #f])
         (or/c string? #f)]{
  Displays a file save dialog.

  @racket[filters] and @racket[default-path] work the same as @racket[open-file-dialog].

  Returns the selected path, or @racket[#f] if the user cancels.

  @codeblock|{
    (define path (save-file-dialog
                   #:filters '(("PNG Image" . "png"))
                   #:default-path "screenshot.png"))
    (when path
      (save-screenshot path))
  }|
}

@defproc[(open-folder-dialog [#:default-path default-path (or/c string? #f) #f]
                             [#:allow-multiple? allow-multiple? boolean? #f]
                             [#:window window (or/c window? #f) #f])
         (or/c string? (listof string?) #f)]{
  Displays a folder selection dialog.

  If @racket[allow-multiple?] is @racket[#t], returns a list of folder paths.
  Otherwise returns a single path string.

  Returns @racket[#f] if the user cancels.

  @codeblock|{
    (define folder (open-folder-dialog #:default-path "~"))
    (when folder
      (set-working-directory! folder))
  }|
}
