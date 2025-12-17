#lang racket/base

;; Idiomatic SDL_ttf helpers with custodian-based cleanup

(require ffi/unsafe
         ffi/unsafe/custodian
         "../raw.rkt"
         "../ttf.rkt"
         "texture.rkt"
         "window.rkt"
         "draw.rkt"
         "../private/safe-syntax.rkt")

(provide
 ;; Font management
 open-font
 close-font!
 font?
 font-ptr
 font-destroy!

 ;; Rendering
 render-text
 draw-text!)

;; ==========================================================================
;; Font wrapper struct
;; ==========================================================================

(define-sdl-resource font TTF-CloseFont)

;; ==========================================================================
;; Initialization
;; ==========================================================================

;; NOTE: TTF initialization uses module-level mutable state.
;; SDL_ttf (like SDL itself) is not thread-safe and should only be
;; called from the main thread. If you need to use fonts from multiple
;; threads, render all text on the main thread.

(define ttf-initialized? #f)
(define ttf-shutdown-registered? #f)
(define ttf-shutdown-token (vector 'sdl3-ttf-shutdown))

(define (ensure-ttf-initialized! #:custodian [cust (current-custodian)])
  (unless ttf-initialized?
    (unless (TTF-Init)
      (error 'open-font "Failed to initialize SDL_ttf: ~a" (SDL-GetError)))
    (set! ttf-initialized? #t)

    ;; Tear down SDL_ttf when the custodian shuts down
    (unless ttf-shutdown-registered?
      (register-custodian-shutdown
       ttf-shutdown-token
       (λ (_)
         (when ttf-initialized?
           (TTF-Quit)
           (set! ttf-initialized? #f)))
       cust
       #:at-exit? #t)
      (set! ttf-shutdown-registered? #t))))

;; ==========================================================================
;; Font Management
;; ==========================================================================

(define (open-font path size
                   #:custodian [cust (current-custodian)])
  (ensure-ttf-initialized! #:custodian cust)

  (define ptr (TTF-OpenFont path (exact->inexact size)))
  (unless ptr
    (error 'open-font "Failed to load font ~a: ~a" path (SDL-GetError)))
  (wrap-font ptr #:custodian cust))

;; Alias for consistency with other modules
(define close-font! font-destroy!)

;; ==========================================================================
;; Rendering
;; ==========================================================================

(define (render-text f text color
                     #:renderer [rend #f]
                     #:mode [mode 'blended]
                     #:custodian [cust (current-custodian)])
  (unless rend
    (error 'render-text "renderer is required"))

  (when (font-destroyed? f)
    (error 'render-text "font is closed"))

  (if (string=? text "")
      #f
      (let ()
        (define sdl-color (color->SDL_Color color))

        ;; Render text to a surface using the selected quality mode
        (define surface
          (case mode
            [(solid) (TTF-RenderText-Solid (font-ptr f) text 0 sdl-color)]
            [(blended) (TTF-RenderText-Blended (font-ptr f) text 0 sdl-color)]
            [else (error 'render-text "unsupported mode: ~a" mode)]))

        (unless surface
          (error 'render-text "Failed to render text: ~a" (SDL-GetError)))

        ;; Convert to a texture for rendering
        (define tex-ptr (SDL-CreateTextureFromSurface (renderer-ptr rend) surface))
        (SDL-DestroySurface surface)

        (unless tex-ptr
          (error 'render-text "Failed to create texture from text: ~a" (SDL-GetError)))

        (texture-from-pointer tex-ptr #:custodian cust))))

(define (draw-text! rend f text x y color
                    #:mode [mode 'blended]
                    #:custodian [cust (current-custodian)])
  (define tex (render-text f text color
                           #:renderer rend
                           #:mode mode
                           #:custodian cust))

  ;; Skip empty text
  (when tex
    (render-texture! rend tex x y)
    (texture-destroy! tex)))
