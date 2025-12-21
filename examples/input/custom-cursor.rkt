#lang racket/base

;; Custom Cursor Demo
;;
;; Demonstrates custom cursor rendering in SDL3:
;; - Hiding the system cursor
;; - Drawing a custom cursor sprite at mouse position
;; - Different cursor styles for different states
;; - Using system cursors for comparison
;;
;; Controls:
;;   1-5 - Select custom cursor style
;;   S - Toggle system cursor (show/hide for comparison)
;;   C - Cycle through system cursor types
;;   Left click - "Click" effect
;;   Escape - Quit

(require racket/match
         racket/format
         racket/math
         sdl3)

(define window-width 800)
(define window-height 600)
(define window-title "SDL3 Custom Cursor Demo")

(define pi 3.141592653589793)

;; Cursor styles
(define CURSOR-CROSSHAIR 1)
(define CURSOR-CIRCLE 2)
(define CURSOR-ARROW 3)
(define CURSOR-TARGET 4)
(define CURSOR-HAND 5)

(define current-style CURSOR-CROSSHAIR)
(define using-system-cursor? #f)
(define system-cursor-index 0)

(define system-cursor-types
  '(default text wait crosshair progress
    nwse-resize nesw-resize ew-resize ns-resize
    move not-allowed pointer))

;; Draw crosshair cursor
(define (draw-crosshair-cursor! renderer x y clicked?)
  (define size (if clicked? 12 15))
  (define gap 4)
  (define color-r (if clicked? 255 200))
  (define color-g (if clicked? 100 200))
  (define color-b (if clicked? 100 200))

  (set-draw-color! renderer color-r color-g color-b)
  ;; Horizontal lines
  (draw-line! renderer (- x size) y (- x gap) y)
  (draw-line! renderer (+ x gap) y (+ x size) y)
  ;; Vertical lines
  (draw-line! renderer x (- y size) x (- y gap))
  (draw-line! renderer x (+ y gap) x (+ y size))
  ;; Center dot
  (fill-rect! renderer (- x 1) (- y 1) 3 3))

;; Draw circle cursor
(define (draw-circle-cursor! renderer x y clicked?)
  (define radius (if clicked? 12.0 18.0))
  (define color-r (if clicked? 100 100))
  (define color-g (if clicked? 255 200))
  (define color-b (if clicked? 100 255))

  (set-draw-color! renderer color-r color-g color-b)
  ;; Draw circle as segments
  (define segments 24)
  (for ([i (in-range segments)])
    (define a1 (* i (/ (* 2 pi) segments)))
    (define a2 (* (+ i 1) (/ (* 2 pi) segments)))
    (draw-line! renderer
                (+ x (* radius (cos a1)))
                (+ y (* radius (sin a1)))
                (+ x (* radius (cos a2)))
                (+ y (* radius (sin a2)))))
  ;; Inner dot when clicked
  (when clicked?
    (fill-rect! renderer (- x 2) (- y 2) 5 5)))

;; Draw arrow cursor
(define (draw-arrow-cursor! renderer x y clicked?)
  (define scale (if clicked? 0.8 1.0))
  (define color-r (if clicked? 255 255))
  (define color-g (if clicked? 200 255))
  (define color-b (if clicked? 100 200))

  ;; Arrow pointing up-left (like default cursor)
  (set-draw-color! renderer 0 0 0)  ; Shadow
  (draw-line! renderer (+ x 1) (+ y 1) (+ x 1) (+ y 1 (* 20 scale)))
  (draw-line! renderer (+ x 1) (+ y 1) (+ x 1 (* 14 scale)) (+ y 1 (* 14 scale)))
  (draw-line! renderer (+ x 1) (+ y 1 (* 20 scale)) (+ x 1 (* 6 scale)) (+ y 1 (* 14 scale)))
  (draw-line! renderer (+ x 1 (* 6 scale)) (+ y 1 (* 14 scale)) (+ x 1 (* 8 scale)) (+ y 1 (* 14 scale)))
  (draw-line! renderer (+ x 1 (* 8 scale)) (+ y 1 (* 14 scale)) (+ x 1 (* 14 scale)) (+ y 1 (* 14 scale)))

  (set-draw-color! renderer color-r color-g color-b)  ; Main color
  (draw-line! renderer x y x (+ y (* 20 scale)))
  (draw-line! renderer x y (+ x (* 14 scale)) (+ y (* 14 scale)))
  (draw-line! renderer x (+ y (* 20 scale)) (+ x (* 6 scale)) (+ y (* 14 scale)))
  (draw-line! renderer (+ x (* 6 scale)) (+ y (* 14 scale)) (+ x (* 8 scale)) (+ y (* 14 scale)))
  (draw-line! renderer (+ x (* 8 scale)) (+ y (* 14 scale)) (+ x (* 14 scale)) (+ y (* 14 scale))))

;; Draw target cursor
(define (draw-target-cursor! renderer x y clicked?)
  (define outer-r (if clicked? 16.0 20.0))
  (define inner-r (if clicked? 8.0 10.0))
  (define color-r 255)
  (define color-g (if clicked? 50 100))
  (define color-b (if clicked? 50 100))

  (set-draw-color! renderer color-r color-g color-b)
  ;; Outer circle
  (define segments 24)
  (for ([i (in-range segments)])
    (define a1 (* i (/ (* 2 pi) segments)))
    (define a2 (* (+ i 1) (/ (* 2 pi) segments)))
    (draw-line! renderer
                (+ x (* outer-r (cos a1)))
                (+ y (* outer-r (sin a1)))
                (+ x (* outer-r (cos a2)))
                (+ y (* outer-r (sin a2)))))
  ;; Inner circle
  (for ([i (in-range segments)])
    (define a1 (* i (/ (* 2 pi) segments)))
    (define a2 (* (+ i 1) (/ (* 2 pi) segments)))
    (draw-line! renderer
                (+ x (* inner-r (cos a1)))
                (+ y (* inner-r (sin a1)))
                (+ x (* inner-r (cos a2)))
                (+ y (* inner-r (sin a2)))))
  ;; Cross lines
  (draw-line! renderer (- x outer-r 5) y (+ x outer-r 5) y)
  (draw-line! renderer x (- y outer-r 5) x (+ y outer-r 5)))

;; Draw hand cursor
(define (draw-hand-cursor! renderer x y clicked?)
  (define color-r (if clicked? 255 230))
  (define color-g (if clicked? 200 200))
  (define color-b (if clicked? 150 180))

  (set-draw-color! renderer color-r color-g color-b)
  ;; Simple pointing hand (index finger extended)
  ;; Finger
  (fill-rect! renderer (- x 2) (- y 15) 5 15)
  ;; Palm
  (fill-rect! renderer (- x 8) y 16 12)
  ;; Other fingers (curled)
  (fill-rect! renderer (- x 8) (- y 5) 4 8)
  (fill-rect! renderer (+ x 4) (- y 3) 4 6)

  ;; Outline
  (set-draw-color! renderer 100 80 60)
  (draw-rect! renderer (- x 2) (- y 15) 5 15)
  (draw-rect! renderer (- x 8) y 16 12))

;; Draw the current cursor style
(define (draw-custom-cursor! renderer x y clicked?)
  (case current-style
    [(1) (draw-crosshair-cursor! renderer x y clicked?)]
    [(2) (draw-circle-cursor! renderer x y clicked?)]
    [(3) (draw-arrow-cursor! renderer x y clicked?)]
    [(4) (draw-target-cursor! renderer x y clicked?)]
    [(5) (draw-hand-cursor! renderer x y clicked?)]))

;; Get style name
(define (style-name style)
  (case style
    [(1) "Crosshair"]
    [(2) "Circle"]
    [(3) "Arrow"]
    [(4) "Target"]
    [(5) "Hand"]
    [else "Unknown"]))

(define (main)
  (sdl-init!)

  (define-values (window renderer)
    (make-window+renderer window-title window-width window-height))

  ;; Hide the system cursor initially
  (hide-cursor!)

  ;; Current system cursor (for toggling)
  (define current-system-cursor #f)

  (let loop ([running? #t])
    (when running?
      ;; Get mouse state
      (define-values (mx my buttons) (get-mouse-state))
      (define clicked? (mouse-button-pressed? buttons SDL_BUTTON_LMASK))

      ;; Process events
      (define still-running?
        (for/fold ([run? #t])
                  ([ev (in-events)]
                   #:break (not run?))
          (match ev
            [(or (quit-event) (window-event 'close-requested)) #f]

            [(key-event 'down 'escape _ _ _) #f]
            [(key-event 'down '1 _ _ _)
             (set! current-style CURSOR-CROSSHAIR) run?]
            [(key-event 'down '2 _ _ _)
             (set! current-style CURSOR-CIRCLE) run?]
            [(key-event 'down '3 _ _ _)
             (set! current-style CURSOR-ARROW) run?]
            [(key-event 'down '4 _ _ _)
             (set! current-style CURSOR-TARGET) run?]
            [(key-event 'down '5 _ _ _)
             (set! current-style CURSOR-HAND) run?]
            ;; Toggle system cursor
            [(key-event 'down 's _ _ _)
             (set! using-system-cursor? (not using-system-cursor?))
             (if using-system-cursor?
                 (show-cursor!)
                 (hide-cursor!))
             run?]
            ;; Cycle system cursor types
            [(key-event 'down 'c _ _ _)
             (set! system-cursor-index
                   (modulo (+ system-cursor-index 1) (length system-cursor-types)))
             (when current-system-cursor
               (destroy-cursor! current-system-cursor))
             (set! current-system-cursor
                   (create-system-cursor (list-ref system-cursor-types system-cursor-index)))
             (set-cursor! current-system-cursor)
             run?]

            [_ run?])))

      (when still-running?
        ;; Clear background with pattern
        (set-draw-color! renderer 30 35 45)
        (render-clear! renderer)

        ;; Draw grid pattern to make cursor movement more visible
        (set-draw-color! renderer 40 45 55)
        (for ([x (in-range 0 window-width 50)])
          (draw-line! renderer x 0 x window-height))
        (for ([y (in-range 0 window-height 50)])
          (draw-line! renderer 0 y window-width y))

        ;; Draw some shapes to interact with
        (set-draw-color! renderer 80 100 150)
        (fill-rect! renderer 100 150 150 100)
        (set-draw-color! renderer 150 80 100)
        (fill-rect! renderer 300 200 120 120)
        (set-draw-color! renderer 100 150 80)
        (fill-rect! renderer 500 150 180 80)

        ;; Draw header
        (set-draw-color! renderer 40 40 50)
        (fill-rect! renderer 10 10 380 110)

        (set-draw-color! renderer 255 255 255)
        (render-debug-text! renderer 20 18 "CUSTOM CURSOR DEMO")

        (set-draw-color! renderer 180 180 180)
        (render-debug-text! renderer 20 35 (~a "Current style: " (style-name current-style)))
        (render-debug-text! renderer 20 50 (~a "System cursor: " (if using-system-cursor? "VISIBLE" "HIDDEN")))

        (when using-system-cursor?
          (render-debug-text! renderer 20 65
                              (~a "System type: " (list-ref system-cursor-types system-cursor-index))))

        (render-debug-text! renderer 20 80 (~a "Mouse: " (inexact->exact (round mx))
                                                ", " (inexact->exact (round my))))
        (render-debug-text! renderer 20 95 (~a "Clicked: " (if clicked? "YES" "NO")))

        ;; Draw style selector
        (set-draw-color! renderer 40 40 50)
        (fill-rect! renderer (- window-width 200) 10 190 130)

        (set-draw-color! renderer 200 200 100)
        (render-debug-text! renderer (- window-width 190) 18 "CURSOR STYLES:")

        (for ([i (in-range 1 6)])
          (if (= i current-style)
              (set-draw-color! renderer 100 255 100)
              (set-draw-color! renderer 150 150 150))
          (render-debug-text! renderer (- window-width 190) (+ 18 (* i 17))
                              (~a i " - " (style-name i))))

        ;; Instructions
        (set-draw-color! renderer 100 100 120)
        (render-debug-text! renderer 20 (- window-height 50)
                            "1-5: Select cursor style | S: Toggle system cursor")
        (render-debug-text! renderer 20 (- window-height 35)
                            "C: Cycle system cursor type | Click: See effect | ESC: Quit")

        ;; Draw custom cursor (only if system cursor is hidden)
        (unless using-system-cursor?
          (draw-custom-cursor! renderer mx my clicked?))

        (render-present! renderer)
        (delay! 16)

        (loop still-running?))))

  ;; Clean up
  (when current-system-cursor
    (destroy-cursor! current-system-cursor))

  ;; Restore system cursor before exit
  (show-cursor!)

  (renderer-destroy! renderer)
  (window-destroy! window))

;; Run when executed directly
(module+ main
  (main))
