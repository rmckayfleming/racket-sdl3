#lang racket/base

;; Mouse Input Demo
;;
;; Demonstrates mouse input handling in SDL3:
;;
;; Section 1: TRACKING & BUTTONS
;; - Mouse position tracking with visual cursor
;; - Button state detection (left, middle, right)
;; - Trail effect showing mouse history
;;
;; Section 2: WARP & CAPTURE
;; - Warping mouse to specific positions
;; - Auto-capture for click-drag outside window
;; - Drawing lines with click-drag
;;
;; Controls:
;;   Mouse movement - Circle follows cursor
;;   Click buttons - Changes cursor color
;;   Left click + drag - Draw lines
;;   Space - Warp mouse to window center
;;   C - Toggle auto-capture (ON by default)
;;   Escape - Quit

(require racket/match
         racket/math
         racket/list
         racket/format
         sdl3)

(define window-width 800)
(define window-height 600)
(define window-title "SDL3 Mouse Input Demo")

(define pi 3.141592653589793)

;; State
(define auto-capture? #t)
(define dragging? #f)
(define last-x 0)
(define last-y 0)

;; Store drawn lines as (list x1 y1 x2 y2)
(define lines '())

;; Draw a filled circle with horizontal line slices
(define (draw-circle renderer cx cy radius)
  (for* ([dy (in-range (- radius) (add1 radius))])
    (define dx-max (sqrt (max 0 (- (* radius radius) (* dy dy)))))
    (when (> dx-max 0)
      (draw-line! renderer (- cx dx-max) (+ cy dy)
                  (+ cx dx-max) (+ cy dy)))))

;; Draw info panel
(define (draw-info! renderer local-x local-y buttons)
  (set-draw-color! renderer 35 35 45)
  (fill-rect! renderer 10 10 280 130)
  (set-draw-color! renderer 60 60 70)
  (draw-rect! renderer 10 10 280 130)

  ;; Title
  (set-draw-color! renderer 150 150 150)
  (render-debug-text! renderer 20 18 "MOUSE INPUT DEMO")

  ;; Position
  (set-draw-color! renderer 100 200 100)
  (render-debug-text! renderer 20 40
                      (~a "Position: " (inexact->exact (round local-x))
                          ", " (inexact->exact (round local-y))))

  ;; Button state
  (define left? (mouse-button-pressed? buttons SDL_BUTTON_LMASK))
  (define middle? (mouse-button-pressed? buttons SDL_BUTTON_MMASK))
  (define right? (mouse-button-pressed? buttons SDL_BUTTON_RMASK))

  (set-draw-color! renderer 200 200 100)
  (render-debug-text! renderer 20 55
                      (~a "Buttons: " (if left? "L " "") (if middle? "M " "") (if right? "R" "")))

  ;; Auto-capture state
  (if auto-capture?
      (set-draw-color! renderer 100 200 100)
      (set-draw-color! renderer 255 100 100))
  (render-debug-text! renderer 20 70
                      (~a "Auto-capture: " (if auto-capture? "ON" "OFF")))

  ;; Dragging state
  (if dragging?
      (set-draw-color! renderer 255 200 100)
      (set-draw-color! renderer 100 100 100))
  (render-debug-text! renderer 20 85
                      (~a "Dragging: " (if dragging? "YES" "NO")))

  ;; Line count
  (set-draw-color! renderer 150 150 150)
  (render-debug-text! renderer 20 100
                      (~a "Lines drawn: " (length lines)))

  ;; Trail size
  (render-debug-text! renderer 20 115 "Trail follows cursor"))

;; Draw instructions
(define (draw-instructions! renderer)
  (set-draw-color! renderer 35 35 45)
  (fill-rect! renderer 10 (- window-height 95) 320 85)
  (set-draw-color! renderer 60 60 70)
  (draw-rect! renderer 10 (- window-height 95) 320 85)

  (set-draw-color! renderer 150 150 150)
  (render-debug-text! renderer 20 (- window-height 87) "CONTROLS")
  (set-draw-color! renderer 120 120 120)
  (render-debug-text! renderer 20 (- window-height 70) "Move mouse: Circle follows cursor")
  (render-debug-text! renderer 20 (- window-height 55) "Click+drag: Draw lines")
  (render-debug-text! renderer 20 (- window-height 40) "Space: Warp to center")
  (render-debug-text! renderer 20 (- window-height 25) "C: Toggle auto-capture | ESC: Quit"))

;; Draw center target
(define (draw-center-target! renderer)
  (define cx (/ window-width 2))
  (define cy (/ window-height 2))

  (set-draw-color! renderer 80 80 100)
  (draw-line! renderer (- cx 20) cy (+ cx 20) cy)
  (draw-line! renderer cx (- cy 20) cx (+ cy 20))

  (for ([i (in-range 0 360 15)])
    (define r 15)
    (define x1 (+ cx (* r (cos (* i (/ pi 180))))))
    (define y1 (+ cy (* r (sin (* i (/ pi 180))))))
    (define x2 (+ cx (* r (cos (* (+ i 15) (/ pi 180))))))
    (define y2 (+ cy (* r (sin (* (+ i 15) (/ pi 180))))))
    (draw-line! renderer x1 y1 x2 y2)))

;; Draw all stored lines
(define (draw-lines! renderer)
  (set-draw-color! renderer 200 100 100)
  (for ([line (in-list lines)])
    (match-define (list x1 y1 x2 y2) line)
    (draw-line! renderer x1 y1 x2 y2)))

;; Draw button indicators at bottom
(define (draw-button-indicators! renderer left? middle? right?)
  (define indicator-y (- window-height 130))
  (define indicator-size 30.0)
  (define start-x (- window-width 130))

  (set-draw-color! renderer (if left? 255 80) (if left? 100 40) (if left? 100 40))
  (fill-rect! renderer start-x indicator-y indicator-size indicator-size)

  (set-draw-color! renderer (if middle? 100 40) (if middle? 255 80) (if middle? 100 40))
  (fill-rect! renderer (+ start-x 40) indicator-y indicator-size indicator-size)

  (set-draw-color! renderer (if right? 100 40) (if right? 100 40) (if right? 255 80))
  (fill-rect! renderer (+ start-x 80) indicator-y indicator-size indicator-size)

  ;; Labels
  (set-draw-color! renderer 200 200 200)
  (render-debug-text! renderer start-x (- indicator-y 12) "L   M   R"))

(define (main)
  (printf "Mouse Input Demo~n")
  (printf "================~n")
  (printf "Move mouse to see cursor following~n")
  (printf "Click and drag to draw lines~n")
  (printf "Space: Warp to center~n")
  (printf "C: Toggle auto-capture~n")
  (printf "Escape: Quit~n~n")

  (with-sdl
    (with-window+renderer window-title window-width window-height (window renderer)
      #:window-flags 'resizable
      (let loop ([trail '()] [max-trail 50] [running? #t])
    (when running?
      ;; Get mouse state
      (define-values (mx my buttons) (get-mouse-state))
      (define left? (mouse-button-pressed? buttons SDL_BUTTON_LMASK))
      (define middle? (mouse-button-pressed? buttons SDL_BUTTON_MMASK))
      (define right? (mouse-button-pressed? buttons SDL_BUTTON_RMASK))

      ;; Process events
      (define still-running?
        (for/fold ([run? #t])
                  ([ev (in-events)]
                   #:break (not run?))
          (match ev
            [(or (quit-event) (window-event 'close-requested)) #f]

            [(key-event 'down 'escape _ _ _) #f]
            [(key-event 'down 'space _ _ _)
             (warp-mouse! window (/ window-width 2) (/ window-height 2))
             run?]
            [(key-event 'down 'c _ _ _)
             (set! auto-capture? (not auto-capture?))
             (capture-mouse! auto-capture?)
             run?]

            ;; Mouse button down - start dragging
            [(mouse-button-event 'down 'left x y _)
             (set! dragging? #t)
             (set! last-x x)
             (set! last-y y)
             run?]

            ;; Mouse button up - stop dragging
            [(mouse-button-event 'up 'left _ _ _)
             (set! dragging? #f)
             run?]

            ;; Mouse motion - draw line if dragging
            [(mouse-motion-event x y _ _ _)
             (when dragging?
               (set! lines (cons (list last-x last-y x y) lines))
               (set! last-x x)
               (set! last-y y))
             run?]

            [_ run?])))

      (when still-running?
        ;; Trail update
        (define new-trail (cons (cons mx my) trail))
        (define trimmed-trail (if (> (length new-trail) max-trail)
                                  (take new-trail max-trail)
                                  new-trail))

        ;; Background
        (set-draw-color! renderer 20 20 30)
        (render-clear! renderer)

        ;; Draw center target
        (draw-center-target! renderer)

        ;; Draw stored lines
        (draw-lines! renderer)

        ;; Draw trail (fading circles)
        (for ([pos (in-list (reverse trimmed-trail))]
              [i (in-naturals)])
          (define alpha (/ i (max 1 max-trail)))
          (define trail-radius (+ 5 (* 15 alpha)))
          (set-draw-color! renderer 100 100 (inexact->exact (round (+ 100 (* 55 alpha)))))
          (draw-circle renderer (car pos) (cdr pos) trail-radius))

        ;; Cursor color from button state
        (define-values (r g b)
          (cond
            [(and left? right?) (values 255 255 0)]
            [left? (values 255 100 100)]
            [right? (values 100 100 255)]
            [middle? (values 100 255 100)]
            [else (values 255 255 255)]))

        ;; Cursor circles
        (set-draw-color! renderer r g b)
        (draw-circle renderer mx my 25.0)
        (set-draw-color! renderer (quotient r 2) (quotient g 2) (quotient b 2))
        (draw-circle renderer mx my 15.0)

        ;; Crosshair
        (set-draw-color! renderer r g b)
        (draw-line! renderer (- mx 30) my (- mx 10) my)
        (draw-line! renderer (+ mx 10) my (+ mx 30) my)
        (draw-line! renderer mx (- my 30) mx (- my 10))
        (draw-line! renderer mx (+ my 10) mx (+ my 30))

        ;; Draw UI
        (draw-info! renderer mx my buttons)
        (draw-instructions! renderer)
        (draw-button-indicators! renderer left? middle? right?)

        (render-present! renderer)
        (delay! 16)

        (loop trimmed-trail max-trail still-running?)))

    ;; Re-enable auto-capture before exit if we disabled it
    (unless auto-capture?
      (capture-mouse! #t)))))

  (printf "~nDone.~n"))

;; Run when executed directly
(module+ main
  (main))
