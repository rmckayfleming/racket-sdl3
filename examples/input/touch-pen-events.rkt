#lang racket/base

;; Touch and Pen Input Demo
;;
;; Demonstrates touch and pen input handling in SDL3:
;;
;; TOUCH INPUT:
;; - Multi-touch finger tracking
;; - Shows touch position, pressure, and movement
;; - Each finger gets a unique color
;;
;; PEN INPUT (tablets/stylus):
;; - Pen proximity detection (in/out)
;; - Pen position and pressure
;; - Pen tilt and rotation (if supported)
;; - Eraser detection
;; - Pen button states
;;
;; NOTE: This demo requires a touch screen or graphics tablet.
;; On a standard mouse/keyboard system, you will only see the
;; UI but no touch/pen events (mouse events are handled separately).
;;
;; Controls:
;;   Touch - Shows finger positions with pressure circles
;;   Pen/Stylus - Shows pen state with pressure visualization
;;   C - Clear the canvas
;;   Escape - Quit

(require racket/match
         racket/hash
         racket/format
         racket/list
         sdl3)

(define window-width 800)
(define window-height 600)
(define window-title "SDL3 Touch & Pen Input Demo")

;; State for tracking active fingers (finger-id -> (list x y pressure color))
(define active-fingers (make-hash))

;; Assign colors to fingers
(define finger-colors
  (vector (list 255 100 100)   ; red
          (list 100 255 100)   ; green
          (list 100 100 255)   ; blue
          (list 255 255 100)   ; yellow
          (list 255 100 255)   ; magenta
          (list 100 255 255)   ; cyan
          (list 255 180 100)   ; orange
          (list 180 100 255)   ; purple
          (list 100 180 100)   ; dark green
          (list 200 200 200))) ; white

(define next-color-index 0)

(define (get-next-color)
  (define c (vector-ref finger-colors (modulo next-color-index (vector-length finger-colors))))
  (set! next-color-index (add1 next-color-index))
  c)

;; Pen state
(define pen-active? #f)
(define pen-in-proximity? #f)
(define pen-x 0.0)
(define pen-y 0.0)
(define pen-pressure 0.0)
(define pen-xtilt 0.0)
(define pen-ytilt 0.0)
(define pen-rotation 0.0)
(define pen-eraser? #f)
(define pen-buttons 0)
(define pen-id 0)

;; Canvas for drawing
(define draw-points '())
(define max-points 2000)

;; Draw a filled circle with horizontal line slices
(define (draw-circle renderer cx cy radius)
  (define r-int (inexact->exact (round radius)))
  (for ([dy (in-range (- r-int) (add1 r-int))])
    (define dx-max (sqrt (max 0 (- (* radius radius) (* dy dy)))))
    (when (> dx-max 0)
      (draw-line! renderer (- cx dx-max) (+ cy dy)
                  (+ cx dx-max) (+ cy dy)))))

;; Draw info panel
(define (draw-info! renderer)
  (set-draw-color! renderer 35 35 45)
  (fill-rect! renderer 10 10 250 180)
  (set-draw-color! renderer 60 60 70)
  (draw-rect! renderer 10 10 250 180)

  ;; Title
  (set-draw-color! renderer 150 150 150)
  (render-debug-text! renderer 20 18 "TOUCH & PEN INPUT DEMO")

  ;; Touch info
  (set-draw-color! renderer 100 200 100)
  (render-debug-text! renderer 20 40
                      (~a "Active fingers: " (hash-count active-fingers)))

  ;; Pen info
  (set-draw-color! renderer 200 200 100)
  (render-debug-text! renderer 20 58
                      (~a "Pen proximity: " (if pen-in-proximity? "YES" "NO")))
  (render-debug-text! renderer 20 73
                      (~a "Pen active: " (if pen-active? "YES" "NO")))

  (when pen-in-proximity?
    (set-draw-color! renderer 150 200 255)
    (render-debug-text! renderer 20 88
                        (~a "Pen pos: " (inexact->exact (round pen-x))
                            ", " (inexact->exact (round pen-y))))
    (render-debug-text! renderer 20 103
                        (~a "Pressure: " (~r pen-pressure #:precision 2)))
    (render-debug-text! renderer 20 118
                        (~a "Tilt: " (~r pen-xtilt #:precision 1)
                            ", " (~r pen-ytilt #:precision 1)))
    (render-debug-text! renderer 20 133
                        (~a "Rotation: " (~r pen-rotation #:precision 1)))
    (set-draw-color! renderer (if pen-eraser? 255 100) 100 (if pen-eraser? 100 150))
    (render-debug-text! renderer 20 148
                        (~a "Eraser: " (if pen-eraser? "YES" "NO"))))

  (set-draw-color! renderer 120 120 120)
  (render-debug-text! renderer 20 168 (~a "Draw points: " (length draw-points))))

;; Draw instructions
(define (draw-instructions! renderer)
  (set-draw-color! renderer 35 35 45)
  (fill-rect! renderer 10 (- window-height 65) 300 55)
  (set-draw-color! renderer 60 60 70)
  (draw-rect! renderer 10 (- window-height 65) 300 55)

  (set-draw-color! renderer 150 150 150)
  (render-debug-text! renderer 20 (- window-height 57) "CONTROLS")
  (set-draw-color! renderer 120 120 120)
  (render-debug-text! renderer 20 (- window-height 40) "Touch/Pen: Draw on canvas")
  (render-debug-text! renderer 20 (- window-height 25) "C: Clear canvas | ESC: Quit"))

;; Draw all stored draw points
(define (draw-canvas! renderer)
  (for ([pt (in-list draw-points)])
    (match-define (list x y pressure r g b) pt)
    (define radius (+ 2 (* pressure 15)))
    (set-draw-color! renderer r g b)
    (draw-circle renderer x y radius)))

;; Draw active finger touches
(define (draw-fingers! renderer)
  (for ([(id finger-data) (in-hash active-fingers)])
    (match-define (list x y pressure color) finger-data)
    (match-define (list r g b) color)
    (define radius (+ 10 (* pressure 40)))

    ;; Outer circle
    (set-draw-color! renderer r g b)
    (draw-circle renderer x y radius)

    ;; Inner circle
    (set-draw-color! renderer (quotient r 2) (quotient g 2) (quotient b 2))
    (draw-circle renderer x y (* radius 0.5))

    ;; Finger ID label
    (set-draw-color! renderer 255 255 255)
    (render-debug-text! renderer (+ x radius 5) (- y 4)
                        (~a "F" (modulo id 10)))))

;; Draw pen cursor and visualization
(define (draw-pen! renderer)
  (when pen-in-proximity?
    ;; Pressure-based circle
    (define radius (+ 5 (* pen-pressure 30)))

    ;; Pen color: red for eraser, blue for pen
    (if pen-eraser?
        (set-draw-color! renderer 255 100 100)
        (set-draw-color! renderer 100 150 255))

    (draw-circle renderer pen-x pen-y radius)

    ;; Tilt visualization (line showing tilt direction)
    (when (or (not (zero? pen-xtilt)) (not (zero? pen-ytilt)))
      (define tilt-scale 1.0) ; pixels per degree
      (define tx (+ pen-x (* pen-xtilt tilt-scale)))
      (define ty (+ pen-y (* pen-ytilt tilt-scale)))
      (set-draw-color! renderer 255 255 100)
      (draw-line! renderer pen-x pen-y tx ty))

    ;; Pen active indicator
    (when pen-active?
      (set-draw-color! renderer 100 255 100)
      (draw-rect! renderer (- pen-x radius 2) (- pen-y radius 2)
                  (+ (* radius 2) 4) (+ (* radius 2) 4)))))

(define (main)
  (sdl-init!)

  (define-values (window renderer)
    (make-window+renderer window-title window-width window-height
                          #:window-flags SDL_WINDOW_RESIZABLE))

  (printf "Touch & Pen Input Demo~n")
  (printf "======================~n")
  (printf "Touch screen or use a graphics tablet~n")
  (printf "C: Clear canvas~n")
  (printf "Escape: Quit~n~n")

  (let loop ([running? #t])
    (when running?
      ;; Process events
      (define still-running?
        (for/fold ([run? #t])
                  ([ev (in-events)]
                   #:break (not run?))
          (match ev
            [(or (quit-event) (window-event 'close-requested)) #f]

            [(key-event 'down key _ _ _)
             (cond
               [(= key SDLK_ESCAPE) #f]
               [(= key SDLK_C)
                (set! draw-points '())
                run?]
               [else run?])]

            ;; Touch finger down
            [(touch-finger-event 'down touch-id finger-id x y dx dy pressure)
             (define screen-x (* x window-width))
             (define screen-y (* y window-height))
             (define color (get-next-color))
             (hash-set! active-fingers finger-id (list screen-x screen-y pressure color))
             (printf "Finger DOWN: id=~a pos=(~a, ~a) pressure=~a~n"
                     finger-id (round screen-x) (round screen-y) (~r pressure #:precision 2))
             run?]

            ;; Touch finger up
            [(touch-finger-event 'up touch-id finger-id x y dx dy pressure)
             (hash-remove! active-fingers finger-id)
             (printf "Finger UP: id=~a~n" finger-id)
             run?]

            ;; Touch finger motion
            [(touch-finger-event 'motion touch-id finger-id x y dx dy pressure)
             (define screen-x (* x window-width))
             (define screen-y (* y window-height))
             (define existing (hash-ref active-fingers finger-id #f))
             (define color (if existing (list-ref existing 3) (get-next-color)))
             (hash-set! active-fingers finger-id (list screen-x screen-y pressure color))
             ;; Add to draw points
             (match-define (list r g b) color)
             (define new-point (list screen-x screen-y pressure r g b))
             (set! draw-points (cons new-point draw-points))
             (when (> (length draw-points) max-points)
               (set! draw-points (take draw-points max-points)))
             run?]

            ;; Touch finger canceled
            [(touch-finger-event 'canceled _ finger-id _ _ _ _ _)
             (hash-remove! active-fingers finger-id)
             (printf "Finger CANCELED: id=~a~n" finger-id)
             run?]

            ;; Pen proximity in
            [(pen-proximity-event 'in which)
             (set! pen-in-proximity? #t)
             (set! pen-id which)
             (printf "Pen PROXIMITY IN: id=~a~n" which)
             run?]

            ;; Pen proximity out
            [(pen-proximity-event 'out which)
             (set! pen-in-proximity? #f)
             (printf "Pen PROXIMITY OUT: id=~a~n" which)
             run?]

            ;; Pen motion
            [(pen-motion-event which pen-state x y)
             (set! pen-x x)
             (set! pen-y y)
             (set! pen-buttons pen-state)
             run?]

            ;; Pen touch down (pen on surface)
            [(pen-touch-event 'down which pen-state x y eraser?)
             (set! pen-active? #t)
             (set! pen-x x)
             (set! pen-y y)
             (set! pen-eraser? eraser?)
             (set! pen-buttons pen-state)
             (printf "Pen DOWN: pos=(~a, ~a) eraser=~a~n"
                     (round x) (round y) eraser?)
             run?]

            ;; Pen touch up (pen lifted)
            [(pen-touch-event 'up which pen-state x y eraser?)
             (set! pen-active? #f)
             (set! pen-x x)
             (set! pen-y y)
             (printf "Pen UP: pos=(~a, ~a)~n" (round x) (round y))
             run?]

            ;; Pen button events
            [(pen-button-event type which pen-state x y button)
             (set! pen-x x)
             (set! pen-y y)
             (set! pen-buttons pen-state)
             (printf "Pen BUTTON ~a: button=~a pos=(~a, ~a)~n"
                     type button (round x) (round y))
             run?]

            ;; Pen axis events (pressure, tilt, rotation, etc.)
            [(pen-axis-event which pen-state x y axis value)
             (set! pen-x x)
             (set! pen-y y)
             (set! pen-buttons pen-state)
             (case axis
               [(pressure) (set! pen-pressure value)]
               [(xtilt) (set! pen-xtilt value)]
               [(ytilt) (set! pen-ytilt value)]
               [(rotation) (set! pen-rotation value)]
               [else (void)])
             ;; Add to draw points when pen is active
             (when pen-active?
               (define r (if pen-eraser? 200 100))
               (define g 150)
               (define b (if pen-eraser? 100 200))
               (define new-point (list x y pen-pressure r g b))
               (set! draw-points (cons new-point draw-points))
               (when (> (length draw-points) max-points)
                 (set! draw-points (take draw-points max-points))))
             run?]

            [_ run?])))

      (when still-running?
        ;; Background
        (set-draw-color! renderer 20 20 30)
        (render-clear! renderer)

        ;; Draw canvas (stored points)
        (draw-canvas! renderer)

        ;; Draw active finger touches
        (draw-fingers! renderer)

        ;; Draw pen visualization
        (draw-pen! renderer)

        ;; Draw UI
        (draw-info! renderer)
        (draw-instructions! renderer)

        (render-present! renderer)
        (delay! 16)

        (loop still-running?))))

  (printf "~nDone.~n")

  (renderer-destroy! renderer)
  (window-destroy! window))

;; Run when executed directly
(module+ main
  (main))
