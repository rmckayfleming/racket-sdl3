#lang racket/base

;; Basic Drawing - Shapes and Colors
;;
;; Demonstrates the fundamental drawing primitives:
;; - Setting colors
;; - Drawing rectangles (filled and outline)
;; - Drawing lines
;;
;; Press Escape to exit.

(require racket/match
         sdl3)

(define (main)
  (sdl-init!)

  (define-values (window renderer)
    (make-window+renderer "Basic Drawing" 800 600))

  (let loop ()
    (define quit?
      (for/or ([ev (in-events)])
        (match ev
          [(quit-event) #t]
          [(key-event 'down 'escape _ _ _) #t]
          [_ #f])))

    (unless quit?
      ;; Dark gray background
      (set-draw-color! renderer 40 40 40)
      (render-clear! renderer)

      ;; Red filled rectangle
      (set-draw-color! renderer 220 60 60)
      (fill-rect! renderer 100 100 150 100)

      ;; Green filled rectangle
      (set-draw-color! renderer 60 220 60)
      (fill-rect! renderer 325 100 150 100)

      ;; Blue filled rectangle
      (set-draw-color! renderer 60 60 220)
      (fill-rect! renderer 550 100 150 100)

      ;; Yellow outline rectangle
      (set-draw-color! renderer 220 220 60)
      (draw-rect! renderer 100 250 200 150)

      ;; Cyan outline rectangle
      (set-draw-color! renderer 60 220 220)
      (draw-rect! renderer 500 250 200 150)

      ;; White diagonal lines
      (set-draw-color! renderer 255 255 255)
      (draw-line! renderer 100 450 300 550)
      (draw-line! renderer 300 450 100 550)

      ;; Magenta lines making an X
      (set-draw-color! renderer 220 60 220)
      (draw-line! renderer 500 450 700 550)
      (draw-line! renderer 700 450 500 550)

      ;; Instructions
      (set-draw-color! renderer 150 150 150)
      (render-debug-text! renderer 10 10 "Basic Drawing Demo")
      (render-debug-text! renderer 10 25 "Press ESC to quit")

      (render-present! renderer)
      (delay! 16)
      (loop)))

  (renderer-destroy! renderer)
  (window-destroy! window))

(module+ main
  (main))
