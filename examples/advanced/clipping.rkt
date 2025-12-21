#lang racket/base

;; Clipping Rectangle Demo
;;
;; Demonstrates SDL3 clipping rectangles to constrain drawing:
;; - All drawing is clipped to a rectangular region
;; - Content outside the clip rect is not rendered
;; - Clip rect moves to show the effect dynamically
;;
;; Use cases:
;; - Scrollable content areas
;; - UI panels with overflow handling
;; - Reveal/mask effects
;;
;; Press Escape to quit.

(require racket/match
         racket/format
         racket/math
         sdl3)

(define window-width 800)
(define window-height 600)

;; Draw clipping demo - show content being clipped
(define (draw-clipping-demo renderer width height frame)
  ;; Clear background
  (set-draw-color! renderer 40 40 40)
  (render-clear! renderer)

  ;; Draw instruction text (not clipped)
  (set-draw-color! renderer 255 255 0)
  (render-debug-text! renderer 10 10 "CLIPPING DEMO - Drawing is constrained to clip rectangle")
  (render-debug-text! renderer 10 25 "The red rectangle shows the clip area boundary")
  (render-debug-text! renderer 10 40 "Everything outside is clipped (not rendered)")

  ;; Calculate animated clip rectangle
  (define clip-x (+ 150 (* 100 (sin (* frame 0.02)))))
  (define clip-y (+ 150 (* 50 (cos (* frame 0.03)))))
  (define clip-w 300)
  (define clip-h 200)

  ;; Draw clip area outline (before clipping is enabled)
  (set-draw-color! renderer 200 60 60)
  (draw-rect! renderer clip-x clip-y clip-w clip-h)

  ;; Enable clipping
  (set-render-clip-rect! renderer (make-rect (exact-floor clip-x)
                                              (exact-floor clip-y)
                                              clip-w clip-h))

  ;; Draw lots of content that will be clipped
  ;; Grid of colored squares
  (for* ([x (in-range 0 width 40)]
         [y (in-range 80 height 40)])
    (define color-shift (+ x y frame))
    (set-draw-color! renderer
                     (modulo (+ 100 (quotient color-shift 3)) 256)
                     (modulo (+ 150 (quotient color-shift 5)) 256)
                     (modulo (+ 200 (quotient color-shift 7)) 256))
    (fill-rect! renderer x y 30 30))

  ;; Draw diagonal lines across entire screen (will be clipped)
  (set-draw-color! renderer 255 255 255)
  (for ([i (in-range 0 1000 30)])
    (draw-line! renderer i 50 (- i 200) height))

  ;; Disable clipping
  (set-render-clip-rect! renderer #f)

  ;; Show clip rect info
  (set-draw-color! renderer 200 200 200)
  (render-debug-text! renderer 10 (- height 45)
                       (~a "Clip rect: (" (exact-floor clip-x) ", " (exact-floor clip-y)
                           ") size: " clip-w "x" clip-h))
  (render-debug-text! renderer 10 (- height 30)
                       "Use set-render-clip-rect! to enable, pass #f to disable"))

(define (main)
  (sdl-init!)

  (define-values (window renderer)
    (make-window+renderer "SDL3 Clipping Demo" window-width window-height
                          #:window-flags SDL_WINDOW_RESIZABLE))

  (let loop ([frame 0])
    ;; Get current window size
    (define-values (win-w win-h) (window-size window))

    ;; Handle events
    (define quit?
      (for/or ([ev (in-events)])
        (match ev
          [(or (quit-event) (window-event 'close-requested)) #t]
          [(key-event 'down (== (symbol->keycode 'escape)) _ _ _) #t]
          [_ #f])))

    (unless quit?
      (draw-clipping-demo renderer win-w win-h frame)

      ;; Draw instructions
      (set-draw-color! renderer 150 150 150)
      (render-debug-text! renderer 10 (- win-h 15) "Press ESC to quit")

      (render-present! renderer)
      (delay! 16)
      (loop (+ frame 1))))

  (renderer-destroy! renderer)
  (window-destroy! window))

(module+ main
  (main))
