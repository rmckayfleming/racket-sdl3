#lang racket/base

;; Viewport Demo
;;
;; Demonstrates SDL3 viewports for split-screen rendering:
;; - Split the window into multiple independent regions
;; - Each viewport has its own coordinate system
;; - Same scene rendered in each quadrant with different backgrounds
;;
;; Use cases:
;; - Split-screen multiplayer games
;; - Picture-in-picture displays
;; - Mini-maps
;;
;; Press Escape to quit.

(require racket/match
         racket/math
         sdl3)

(define window-width 800)
(define window-height 600)

;; Draw a simple scene with shapes
(define (draw-scene renderer)
  ;; Red square
  (set-draw-color! renderer 220 60 60)
  (fill-rect! renderer 50 50 80 80)

  ;; Green square
  (set-draw-color! renderer 60 220 60)
  (fill-rect! renderer 150 50 80 80)

  ;; Blue square
  (set-draw-color! renderer 60 60 220)
  (fill-rect! renderer 250 50 80 80)

  ;; Yellow octagon
  (set-draw-color! renderer 220 220 60)
  (define cx 180)
  (define cy 200)
  (define r 60)
  (define points
    (for/list ([i (in-range 9)])
      (define angle (* i (/ (* 2 3.14159) 8)))
      (list (+ cx (* r (cos angle)))
            (+ cy (* r (sin angle))))))
  (draw-lines! renderer points)

  ;; Cyan diagonal lines
  (set-draw-color! renderer 60 220 220)
  (for ([i (in-range 0 300 20)])
    (draw-line! renderer i 300 (+ i 100) 150)))

;; Draw viewport demo - split screen into 4 quadrants
(define (draw-viewports renderer width height)
  (define half-w (quotient width 2))
  (define half-h (quotient height 2))

  ;; Clear the entire screen first
  (set-render-viewport! renderer #f)
  (set-draw-color! renderer 40 40 40)
  (render-clear! renderer)

  ;; Top-left viewport (red tint background)
  (set-render-viewport! renderer (make-rect 0 0 half-w half-h))
  (set-draw-color! renderer 60 30 30)
  (fill-rect! renderer 0 0 half-w half-h)
  (draw-scene renderer)

  ;; Top-right viewport (green tint background)
  (set-render-viewport! renderer (make-rect half-w 0 half-w half-h))
  (set-draw-color! renderer 30 60 30)
  (fill-rect! renderer 0 0 half-w half-h)
  (draw-scene renderer)

  ;; Bottom-left viewport (blue tint background)
  (set-render-viewport! renderer (make-rect 0 half-h half-w half-h))
  (set-draw-color! renderer 30 30 60)
  (fill-rect! renderer 0 0 half-w half-h)
  (draw-scene renderer)

  ;; Bottom-right viewport (gray background)
  (set-render-viewport! renderer (make-rect half-w half-h half-w half-h))
  (set-draw-color! renderer 50 50 50)
  (fill-rect! renderer 0 0 half-w half-h)
  (draw-scene renderer)

  ;; Reset viewport to full screen for UI
  (set-render-viewport! renderer #f)

  ;; Draw dividing lines
  (set-draw-color! renderer 255 255 255)
  (draw-line! renderer half-w 0 half-w height)
  (draw-line! renderer 0 half-h width half-h)

  ;; Draw title
  (set-draw-color! renderer 255 255 0)
  (render-debug-text! renderer 10 10 "VIEWPORT DEMO - Split screen into 4 viewports")
  (render-debug-text! renderer 10 25 "Each viewport renders the same scene independently")
  (render-debug-text! renderer 10 40 "Notice: coordinates reset to (0,0) in each viewport"))

(define (main)
  (sdl-init!)

  (define-values (window renderer)
    (make-window+renderer "SDL3 Viewport Demo" window-width window-height
                          #:window-flags 'resizable))

  (let loop ([running? #t])
    (when running?
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
        (draw-viewports renderer win-w win-h)

        ;; Draw instructions
        (set-draw-color! renderer 150 150 150)
        (render-debug-text! renderer 10 (- win-h 15) "Press ESC to quit")

        (render-present! renderer)
        (delay! 16)
        (loop #t))))

  (renderer-destroy! renderer)
  (window-destroy! window))

(module+ main
  (main))
