#lang racket/base

;; Idiomatic window and renderer management with custodian-based cleanup

(require ffi/unsafe
         ffi/unsafe/custodian
         "../raw.rkt")

(provide
 ;; Initialization
 sdl-init!
 sdl-quit!

 ;; Window management
 make-window
 window?
 window-ptr
 window-destroy!
 window-set-title!
 window-pixel-density

 ;; Renderer management
 make-renderer
 renderer?
 renderer-ptr
 renderer-destroy!

 ;; Convenience
 make-window+renderer

 ;; Re-export common flags
 (all-from-out "../raw.rkt"))

;; ============================================================================
;; Window wrapper struct
;; ============================================================================

;; We wrap the raw pointer so we can track whether it's been destroyed
(struct window (ptr [destroyed? #:mutable])
  #:property prop:cpointer (λ (w) (window-ptr w)))

(struct renderer (ptr [destroyed? #:mutable])
  #:property prop:cpointer (λ (r) (renderer-ptr r)))

;; ============================================================================
;; Initialization
;; ============================================================================

(define (sdl-init! [flags SDL_INIT_VIDEO])
  (unless (SDL-Init flags)
    (error 'sdl-init! "Failed to initialize SDL: ~a" (SDL-GetError))))

(define (sdl-quit!)
  (SDL-Quit))

;; ============================================================================
;; Window Management
;; ============================================================================

(define (make-window title width height
                     #:flags [flags 0]
                     #:custodian [cust (current-custodian)])
  (define ptr (SDL-CreateWindow title width height flags))
  (unless ptr
    (error 'make-window "Failed to create window: ~a" (SDL-GetError)))

  (define win (window ptr #f))

  ;; Register destructor with custodian
  (register-custodian-shutdown
   win
   (λ (w)
     (unless (window-destroyed? w)
       (SDL-DestroyWindow (window-ptr w))
       (set-window-destroyed?! w #t)))
   cust
   #:at-exit? #t)

  win)

(define (window-destroy! win)
  (unless (window-destroyed? win)
    (SDL-DestroyWindow (window-ptr win))
    (set-window-destroyed?! win #t)))

(define (window-set-title! win title)
  (SDL-SetWindowTitle (window-ptr win) title))

(define (window-pixel-density win)
  (SDL-GetWindowPixelDensity (window-ptr win)))

;; ============================================================================
;; Renderer Management
;; ============================================================================

(define (make-renderer win
                       #:name [name #f]
                       #:custodian [cust (current-custodian)])
  (define ptr (SDL-CreateRenderer (window-ptr win) name))
  (unless ptr
    (error 'make-renderer "Failed to create renderer: ~a" (SDL-GetError)))

  (define rend (renderer ptr #f))

  ;; Register destructor with custodian
  (register-custodian-shutdown
   rend
   (λ (r)
     (unless (renderer-destroyed? r)
       (SDL-DestroyRenderer (renderer-ptr r))
       (set-renderer-destroyed?! r #t)))
   cust
   #:at-exit? #t)

  rend)

(define (renderer-destroy! rend)
  (unless (renderer-destroyed? rend)
    (SDL-DestroyRenderer (renderer-ptr rend))
    (set-renderer-destroyed?! rend #t)))

;; ============================================================================
;; Convenience Functions
;; ============================================================================

(define (make-window+renderer title width height
                              #:window-flags [window-flags 0]
                              #:renderer-name [renderer-name #f]
                              #:custodian [cust (current-custodian)])
  (define win (make-window title width height
                           #:flags window-flags
                           #:custodian cust))
  (define rend (make-renderer win
                              #:name renderer-name
                              #:custodian cust))
  (values win rend))
