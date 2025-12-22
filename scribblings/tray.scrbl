#lang scribble/manual

@(require (for-label racket/base
                     racket/contract
                     sdl3))

@title[#:tag "tray" #:style 'quiet]{System Tray}

This section covers system tray icon support.

@section{Creating a Tray}

@defproc[(make-tray [icon (or/c surface? #f) #f]
                    [tooltip (or/c string? #f) #f]
                    [#:custodian cust custodian? (current-custodian)]) tray?]{
  Creates a system tray icon.

  @racket[icon] is an optional surface to use as the tray icon.
  @racket[tooltip] is optional tooltip text.

  @codeblock|{
    (define tray (make-tray))
    (set-tray-tooltip! tray "My Application")
  }|
}

@defproc[(tray? [v any/c]) boolean?]{
  Returns @racket[#t] if @racket[v] is a tray.
}

@defproc[(tray-ptr [tr tray?]) cpointer?]{
  Returns the underlying SDL tray pointer.
}

@defproc[(tray-destroy! [tr tray?]) void?]{
  Destroys a tray.

  Note: Trays are automatically destroyed when their custodian shuts down.
}

@defproc[(set-tray-icon! [tr tray?] [icon (or/c surface? #f)]) void?]{
  Sets the tray icon.
}

@defproc[(set-tray-tooltip! [tr tray?] [tooltip (or/c string? #f)]) void?]{
  Sets the tray tooltip text.
}

@section{Menus}

@defproc[(make-tray-menu [tr tray?]) tray-menu?]{
  Creates the root menu for a tray.
}

@defproc[(get-tray-menu [tr tray?]) (or/c tray-menu? #f)]{
  Gets the existing root menu for a tray.
}

@defproc[(tray-menu? [v any/c]) boolean?]{
  Returns @racket[#t] if @racket[v] is a tray menu.
}

@defproc[(tray-menu-ptr [menu tray-menu?]) cpointer?]{
  Returns the underlying SDL tray menu pointer.
}

@section{Menu Entries}

@defproc[(insert-tray-entry! [menu tray-menu?]
                             [label string?]
                             [#:position pos exact-integer? -1]
                             [#:type type (or/c 'button 'checkbox 'submenu) 'button]
                             [#:checked? checked? boolean? #f]
                             [#:disabled? disabled? boolean? #f]) tray-entry?]{
  Inserts an entry into a menu.

  @racket[pos] is the position (-1 = end).

  @racket[type] determines the entry type:
  @itemlist[
    @item{@racket['button] --- A clickable item}
    @item{@racket['checkbox] --- A toggleable item}
    @item{@racket['submenu] --- An item that opens a submenu}
  ]

  @codeblock|{
    (define menu (make-tray-menu tray))
    (define quit-entry (insert-tray-entry! menu "Quit"))
    (set-tray-entry-callback! quit-entry
      (lambda (entry)
        (exit)))
  }|
}

@defproc[(remove-tray-entry! [entry tray-entry?]) void?]{
  Removes an entry from its menu.
}

@defproc[(tray-entry? [v any/c]) boolean?]{
  Returns @racket[#t] if @racket[v] is a tray entry.
}

@defproc[(tray-entry-ptr [entry tray-entry?]) cpointer?]{
  Returns the underlying SDL tray entry pointer.
}

@defproc[(tray-entries [menu tray-menu?]) (listof tray-entry?)]{
  Returns all entries in a menu.
}

@section{Entry Properties}

@defproc[(tray-entry-label [entry tray-entry?]) (or/c string? #f)]{
  Returns the entry's label.
}

@defproc[(set-tray-entry-label! [entry tray-entry?] [label string?]) void?]{
  Sets the entry's label.
}

@defproc[(tray-entry-checked? [entry tray-entry?]) boolean?]{
  Returns @racket[#t] if the entry is checked (for checkbox entries).
}

@defproc[(set-tray-entry-checked! [entry tray-entry?] [checked? boolean?]) void?]{
  Sets whether the entry is checked.
}

@defproc[(tray-entry-enabled? [entry tray-entry?]) boolean?]{
  Returns @racket[#t] if the entry is enabled.
}

@defproc[(set-tray-entry-enabled! [entry tray-entry?] [enabled? boolean?]) void?]{
  Sets whether the entry is enabled.
}

@section{Entry Callbacks}

@defproc[(set-tray-entry-callback! [entry tray-entry?]
                                   [proc (or/c procedure? #f)]
                                   [#:userdata userdata any/c #f]) void?]{
  Sets the callback for when the entry is clicked.

  The callback can accept 1 or 2 arguments:
  @itemlist[
    @item{1 arg: @racket[(entry)]}
    @item{2 args: @racket[(entry userdata)]}
  ]

  Pass @racket[#f] to remove the callback.

  @codeblock|{
    (set-tray-entry-callback! entry
      (lambda (e)
        (printf "Entry clicked: ~a~n" (tray-entry-label e))))
  }|
}

@defproc[(click-tray-entry! [entry tray-entry?]) void?]{
  Programmatically clicks an entry.
}

@section{Submenus}

@defproc[(make-tray-submenu [entry tray-entry?]) tray-menu?]{
  Creates a submenu for a submenu-type entry.
}

@defproc[(tray-submenu [entry tray-entry?]) (or/c tray-menu? #f)]{
  Gets the existing submenu for an entry.
}

@defproc[(tray-menu-parent-entry [menu tray-menu?]) (or/c tray-entry? #f)]{
  Returns the parent entry of a submenu.
}

@defproc[(tray-menu-parent-tray [menu tray-menu?]) (or/c cpointer? #f)]{
  Returns the parent tray of a root menu.
}

@defproc[(tray-entry-parent [entry tray-entry?]) (or/c tray-menu? #f)]{
  Returns the parent menu of an entry.
}

@section{Updates}

@defproc[(update-trays!) void?]{
  Updates all trays.

  Call this periodically to ensure tray changes are reflected.
}
