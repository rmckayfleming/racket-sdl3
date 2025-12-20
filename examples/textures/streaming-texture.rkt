#lang racket/base

;; Streaming Texture Demo
;;
;; Demonstrates streaming textures with SDL_LockTexture and float color modulation.
;; Press Esc to quit.

(require ffi/unsafe
         racket/math
         racket/match
         sdl3)

(define window-width 800)
(define window-height 600)

(define tex-width 320)
(define tex-height 240)
(define bytes-per-pixel 4)

(define (fill-texture! tex tick-ms)
  (define t (modulo (quotient tick-ms 4) 256))
  (call-with-locked-texture
   tex
   (lambda (pixels w h pitch)
     (for* ([y (in-range h)]
            [x (in-range w)])
       (define base (+ (* y pitch) (* x bytes-per-pixel)))
       (define r (modulo (+ x t) 256))
       (define g (modulo (+ y (* 2 t)) 256))
       (define b (modulo (+ x y (* 3 t)) 256))
       (ptr-set! pixels _uint8 base r)
       (ptr-set! pixels _uint8 (+ base 1) g)
       (ptr-set! pixels _uint8 (+ base 2) b)
       (ptr-set! pixels _uint8 (+ base 3) 255)))
   #:rect #f))

(define (main)
  (sdl-init!)

  (define-values (window renderer)
    (make-window+renderer "SDL3 Streaming Texture" window-width window-height
                          #:window-flags SDL_WINDOW_RESIZABLE))

  (define tex
    (create-texture renderer tex-width tex-height
                    #:access 'streaming
                    #:format (symbol->pixel-format 'rgba8888)
                    #:scale 'nearest))

  (define running? #t)

  (let loop ()
    (when running?
      (for ([ev (in-events)])
        (match ev
          [(or (quit-event) (window-event 'close-requested))
           (set! running? #f)]
          [(key-event 'down key _ _ _)
           (when (= key SDLK_ESCAPE)
             (set! running? #f))]
          [_ (void)]))

      (define tick (current-ticks))
      (fill-texture! tex tick)

      (define pulse (+ 0.5 (* 0.5 (sin (/ tick 250.0)))))
      (texture-set-color-mod-float! tex pulse 1.0 (- 1.0 pulse))
      (texture-set-alpha-mod-float! tex 1.0)

      (set-draw-color! renderer 15 15 25)
      (render-clear! renderer)
      (render-texture! renderer tex 0 0 #:width window-width #:height window-height)
      (render-debug-text! renderer 20 20 "STREAMING TEXTURE (LOCK + FLOAT MOD)")
      (render-debug-text! renderer 20 40 "Press Esc to quit.")
      (render-present! renderer)

      (delay! 16)
      (loop))))

(main)
