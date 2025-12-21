#lang racket/base

;; Idiomatic system tray helpers

(require ffi/unsafe
         "../raw.rkt"
         "../private/constants.rkt"
         "../private/safe-syntax.rkt"
         "image.rkt")

(provide
 ;; Tray resource
 tray?
 tray-ptr
 tray-destroy!

 ;; Tray creation
 make-tray
 set-tray-icon!
 set-tray-tooltip!

 ;; Menu/entry wrappers
 tray-menu?
 tray-menu-ptr
 tray-entry?
 tray-entry-ptr

 ;; Menus and submenus
 make-tray-menu
 get-tray-menu
 make-tray-submenu
 tray-submenu
 tray-menu-parent-entry
 tray-menu-parent-tray
 tray-entry-parent
 tray-entries

 ;; Entries
 insert-tray-entry!
 remove-tray-entry!
 tray-entry-label
 set-tray-entry-label!
 tray-entry-checked?
 set-tray-entry-checked!
 tray-entry-enabled?
 set-tray-entry-enabled!
 set-tray-entry-callback!
 click-tray-entry!

 ;; Updates
 update-trays!)

;; ============================================================================
;; Tray Resource
;; ============================================================================

(define-sdl-resource tray SDL-DestroyTray)

;; ============================================================================
;; Menu/Entry Wrapper Structs
;; ============================================================================

(struct tray-menu (ptr)
  #:property prop:cpointer (λ (m) (tray-menu-ptr m)))

(struct tray-entry (ptr)
  #:property prop:cpointer (λ (e) (tray-entry-ptr e)))

(define (wrap-tray-menu ptr)
  (and ptr (tray-menu ptr)))

(define (wrap-tray-entry ptr)
  (and ptr (tray-entry ptr)))

(define (surface->ptr who icon)
  (cond
    [(not icon) #f]
    [(surface? icon) (surface-ptr icon)]
    [(cpointer? icon) icon]
    [else (error who "expected surface, pointer, or #f, got: ~a" icon)]))

;; ============================================================================
;; Tray Creation
;; ============================================================================

(define (make-tray [icon #f] [tooltip #f]
                   #:custodian [cust (current-custodian)])
  (define icon-ptr (surface->ptr 'make-tray icon))
  (define ptr (SDL-CreateTray icon-ptr tooltip))
  (unless ptr
    (error 'make-tray "failed to create tray: ~a" (SDL-GetError)))
  (wrap-tray ptr #:custodian cust))

(define (set-tray-icon! tr icon)
  (SDL-SetTrayIcon (tray-ptr tr) (surface->ptr 'set-tray-icon! icon)))

(define (set-tray-tooltip! tr tooltip)
  (SDL-SetTrayTooltip (tray-ptr tr) tooltip))

;; ============================================================================
;; Menus and Submenus
;; ============================================================================

(define (make-tray-menu tr)
  (define ptr (SDL-CreateTrayMenu (tray-ptr tr)))
  (unless ptr
    (error 'make-tray-menu "failed to create tray menu: ~a" (SDL-GetError)))
  (wrap-tray-menu ptr))

(define (get-tray-menu tr)
  (wrap-tray-menu (SDL-GetTrayMenu (tray-ptr tr))))

(define (make-tray-submenu entry)
  (define ptr (SDL-CreateTraySubmenu (tray-entry-ptr entry)))
  (unless ptr
    (error 'make-tray-submenu "failed to create tray submenu: ~a" (SDL-GetError)))
  (wrap-tray-menu ptr))

(define (tray-submenu entry)
  (wrap-tray-menu (SDL-GetTraySubmenu (tray-entry-ptr entry))))

(define (tray-menu-parent-entry menu)
  (wrap-tray-entry (SDL-GetTrayMenuParentEntry (tray-menu-ptr menu))))

;; Returns a raw tray pointer (no custodian wrapper).
(define (tray-menu-parent-tray menu)
  (SDL-GetTrayMenuParentTray (tray-menu-ptr menu)))

(define (tray-entry-parent entry)
  (wrap-tray-menu (SDL-GetTrayEntryParent (tray-entry-ptr entry))))

(define (tray-entries menu)
  (define-values (ptr count) (SDL-GetTrayEntries (tray-menu-ptr menu)))
  (cond
    [(not ptr) '()]
    [else
     (for/list ([i (in-range count)]
                #:when (ptr-ref ptr _pointer i))
       (wrap-tray-entry (cast (ptr-ref ptr _pointer i) _pointer _SDL_TrayEntry-pointer)))]))

;; ============================================================================
;; Entry Helpers
;; ============================================================================

(define (tray-entry-flags type checked? disabled?)
  (define base
    (case type
      [(button) SDL_TRAYENTRY_BUTTON]
      [(checkbox) SDL_TRAYENTRY_CHECKBOX]
      [(submenu) SDL_TRAYENTRY_SUBMENU]
      [else (error 'insert-tray-entry! "invalid entry type: ~a" type)]))
  (bitwise-ior
   base
   (if checked? SDL_TRAYENTRY_CHECKED 0)
   (if disabled? SDL_TRAYENTRY_DISABLED 0)))

(define (insert-tray-entry! menu label
                            #:position [pos -1]
                            #:type [type 'button]
                            #:checked? [checked? #f]
                            #:disabled? [disabled? #f])
  (define flags (tray-entry-flags type checked? disabled?))
  (define ptr (SDL-InsertTrayEntryAt (tray-menu-ptr menu) pos label flags))
  (unless ptr
    (error 'insert-tray-entry! "failed to insert tray entry: ~a" (SDL-GetError)))
  (wrap-tray-entry ptr))

(define (remove-tray-entry! entry)
  (unregister-tray-entry-callback! (tray-entry-ptr entry))
  (SDL-RemoveTrayEntry (tray-entry-ptr entry)))

(define (tray-entry-label entry)
  (SDL-GetTrayEntryLabel (tray-entry-ptr entry)))

(define (set-tray-entry-label! entry label)
  (SDL-SetTrayEntryLabel (tray-entry-ptr entry) label))

(define (tray-entry-checked? entry)
  (SDL-GetTrayEntryChecked (tray-entry-ptr entry)))

(define (set-tray-entry-checked! entry checked?)
  (SDL-SetTrayEntryChecked (tray-entry-ptr entry) checked?))

(define (tray-entry-enabled? entry)
  (SDL-GetTrayEntryEnabled (tray-entry-ptr entry)))

(define (set-tray-entry-enabled! entry enabled?)
  (SDL-SetTrayEntryEnabled (tray-entry-ptr entry) enabled?))

;; ============================================================================
;; Entry Callbacks
;; ============================================================================

;; Keep callbacks reachable to avoid GC while active.
(define active-tray-entry-callbacks (make-hasheq))

(define (register-tray-entry-callback! entry-ptr cb)
  (hash-set! active-tray-entry-callbacks entry-ptr cb))

(define (unregister-tray-entry-callback! entry-ptr)
  (hash-remove! active-tray-entry-callbacks entry-ptr))

(define (make-tray-entry-callback who proc userdata)
  (cond
    [(procedure-arity-includes? proc 2)
     (lambda (_userdata entry-ptr)
       (proc (wrap-tray-entry entry-ptr) userdata))]
    [(procedure-arity-includes? proc 1)
     (lambda (_userdata entry-ptr)
       (proc (wrap-tray-entry entry-ptr)))]
    [else
     (error who "callback must accept 1 or 2 arguments, got: ~a"
            (procedure-arity proc))]))

(define noop-tray-entry-callback
  (make-tray-entry-callback 'set-tray-entry-callback!
                            (lambda (_entry) (void))
                            #f))

(define (set-tray-entry-callback! entry proc #:userdata [userdata #f])
  (define entry-ptr (tray-entry-ptr entry))
  (cond
    [(not proc)
     (unregister-tray-entry-callback! entry-ptr)
     (register-tray-entry-callback! entry-ptr noop-tray-entry-callback)
     (SDL-SetTrayEntryCallback entry-ptr noop-tray-entry-callback #f)]
    [else
     (define cb (make-tray-entry-callback 'set-tray-entry-callback! proc userdata))
     (register-tray-entry-callback! entry-ptr cb)
     (SDL-SetTrayEntryCallback entry-ptr cb #f)]))

(define (click-tray-entry! entry)
  (SDL-ClickTrayEntry (tray-entry-ptr entry)))

;; ============================================================================
;; Updates
;; ============================================================================

(define (update-trays!)
  (SDL-UpdateTrays))
