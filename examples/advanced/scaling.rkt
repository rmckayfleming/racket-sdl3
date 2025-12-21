#lang racket/base

;; Render Scale Demo
;;
;; Demonstrates SDL3 render scaling for resolution independence:
;; - Scale factor multiplies all coordinates and sizes
;; - Draw using logical coordinates, display at any size
;; - Useful for adapting to different screen densities
;;
;; Use cases:
;; - HiDPI/Retina display support
;; - Zoom in/out effects
;; - Resolution-independent game rendering
;;
;; Controls:
;;   +/= - Increase scale
;;   -   - Decrease scale
;;   ESC - Quit

(require racket/match
         racket/format
         sdl3)

(define window-width 800)
(define window-height 600)

;; Draw scale demo - show render scale effect
(define (draw-scale-demo renderer width height scale)
  ;; Reset scale temporarily for background and UI
  (set-render-scale! renderer 1.0 1.0)
  (set-draw-color! renderer 40 40 40)
  (render-clear! renderer)

  ;; Draw instructions (at normal scale)
  (set-draw-color! renderer 255 255 0)
  (render-debug-text! renderer 10 10 "SCALE DEMO - Render scale affects all coordinates")
  (render-debug-text! renderer 10 25 "+/- to change scale. Coordinates stay the same!")
  (render-debug-text! renderer 10 40 (~a "Current scale: " (~r scale #:precision 2) "x"))

  ;; Apply scale for the rest of the drawing
  (set-render-scale! renderer scale scale)

  ;; Draw a grid pattern (coordinates don't change, but visual size does)
  (set-draw-color! renderer 80 80 80)
  (for ([x (in-range 0 400 50)])
    (draw-line! renderer x 80 x 350))
  (for ([y (in-range 80 350 50)])
    (draw-line! renderer 0 y 400 y))

  ;; Draw shapes at fixed coordinates
  (set-draw-color! renderer 220 60 60)
  (fill-rect! renderer 50 100 50 50)

  (set-draw-color! renderer 60 220 60)
  (fill-rect! renderer 150 100 50 50)

  (set-draw-color! renderer 60 60 220)
  (fill-rect! renderer 250 100 50 50)

  ;; Draw coordinate labels
  (set-draw-color! renderer 255 255 255)
  (render-debug-text! renderer 50 160 "(50,100)")
  (render-debug-text! renderer 150 160 "(150,100)")
  (render-debug-text! renderer 250 160 "(250,100)")

  ;; Draw a larger shape with size label
  (set-draw-color! renderer 220 220 60)
  (fill-rect! renderer 100 200 100 100)
  (set-draw-color! renderer 40 40 40)
  (render-debug-text! renderer 110 240 "100x100")

  ;; Explanation at the bottom (in scaled coordinates)
  (set-draw-color! renderer 200 200 200)
  (render-debug-text! renderer 10 380 "All coordinates and sizes are multiplied by scale")
  (render-debug-text! renderer 10 395 "The 50x50 squares are drawn at the same coords")

  ;; Reset scale
  (set-render-scale! renderer 1.0 1.0))

(define (main)
  (sdl-init!)

  (define-values (window renderer)
    (make-window+renderer "SDL3 Render Scale Demo" window-width window-height
                          #:window-flags 'resizable))

  (let loop ([scale 1.0])
    ;; Get current window size
    (define-values (win-w win-h) (window-size window))

    ;; Handle events
    (define-values (quit? new-scale)
      (for/fold ([q? #f] [s scale])
                ([ev (in-events)]
                 #:break q?)
        (match ev
          [(or (quit-event) (window-event 'close-requested))
           (values #t s)]

          [(key-event 'down 'escape _ _ _)
           (values #t s)]
          [(key-event 'down (or 'equals 'kp-plus) _ _ _)
           (values #f (min 4.0 (+ s 0.25)))]
          [(key-event 'down 'minus _ _ _)
           (values #f (max 0.25 (- s 0.25)))]

          [_ (values #f s)])))

    (unless quit?
      (draw-scale-demo renderer win-w win-h new-scale)

      ;; Draw instructions (ensure at normal scale)
      (set-render-scale! renderer 1.0 1.0)
      (set-draw-color! renderer 150 150 150)
      (render-debug-text! renderer 10 (- win-h 15)
                          "Press +/- to change scale | ESC to quit")

      (render-present! renderer)
      (delay! 16)
      (loop new-scale)))

  (renderer-destroy! renderer)
  (window-destroy! window))

(module+ main
  (main))
