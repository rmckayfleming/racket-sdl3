#lang racket/base

;; Mouselook Example - demonstrates relative mouse mode for FPS-style input
;;
;; - Click to capture mouse (relative mode)
;; - Escape to release mouse
;; - Mouse movement rotates a virtual "camera"
;; - Shows dx/dy values and accumulated rotation

(require racket/format
         racket/match
         sdl3)

(define window-width 800)
(define window-height 600)
(define window-title "SDL3 Racket - Mouselook (FPS Mouse)")

;; Camera state
(define yaw 0.0)    ; horizontal rotation in degrees
(define pitch 0.0)  ; vertical rotation in degrees
(define sensitivity 0.2)

;; Last frame's deltas for display
(define last-dx 0.0)
(define last-dy 0.0)

;; Draw a simple crosshair
(define (draw-crosshair! renderer cx cy size)
  (set-draw-color! renderer 255 255 255)
  (draw-line! renderer (- cx size) cy (+ cx size) cy)
  (draw-line! renderer cx (- cy size) cx (+ cy size)))

;; Draw a horizon line that rotates with yaw
(define (draw-horizon! renderer cx cy yaw-angle)
  (define radians (* yaw-angle (/ 3.14159 180.0)))
  (define len 300)
  (define dx (* len (cos radians)))
  (define dy (* len (sin radians)))
  (set-draw-color! renderer 100 150 255)
  (draw-line! renderer (- cx dx) (- cy dy) (+ cx dx) (+ cy dy)))

;; Draw pitch indicator (line that moves up/down)
(define (draw-pitch-indicator! renderer cx cy pitch-angle)
  (define offset (* pitch-angle 2.0))  ; scale for visibility
  (set-draw-color! renderer 255 200 100)
  (draw-line! renderer (- cx 50) (- cy offset) (+ cx 50) (- cy offset)))

;; Draw info text as colored rectangles (no TTF)
(define (draw-info-panel! renderer captured?)
  ;; Background panel
  (set-draw-color! renderer 0 0 0 200)
  (fill-rect! renderer 10 10 280 120)
  (set-draw-color! renderer 100 100 100)
  (draw-rect! renderer 10 10 280 120)

  ;; Status indicator
  (if captured?
      (begin
        (set-draw-color! renderer 50 200 50)
        (fill-rect! renderer 20 20 15 15))  ; green = captured
      (begin
        (set-draw-color! renderer 200 50 50)
        (fill-rect! renderer 20 20 15 15))) ; red = not captured

  ;; Yaw/pitch bars
  (set-draw-color! renderer 100 150 255)
  (define yaw-normalized (- yaw (* 360 (floor (/ yaw 360)))))  ; float-safe modulo
  (define yaw-bar-width (* (abs yaw-normalized) 0.5))
  (fill-rect! renderer 20 50 (min 250 yaw-bar-width) 10)

  (set-draw-color! renderer 255 200 100)
  (define pitch-bar-width (+ 125 (* pitch 1.5)))
  (fill-rect! renderer 20 70 (max 0 (min 250 pitch-bar-width)) 10)

  ;; Delta indicators
  (set-draw-color! renderer 150 150 150)
  (define dx-bar (+ 125 (* last-dx 5)))
  (define dy-bar (+ 125 (* last-dy 5)))
  (fill-rect! renderer 20 90 (max 0 (min 250 dx-bar)) 8)
  (fill-rect! renderer 20 102 (max 0 (min 250 dy-bar)) 8))

(define (main)
  (with-sdl
    (with-window+renderer window-title window-width window-height (window renderer)
      (define captured? #f)
      (define cx (/ window-width 2.0))
      (define cy (/ window-height 2.0))

      (let loop ([running? #t])
    (when running?
      ;; Process events
      (define-values (still-running? do-capture? do-release?)
        (for/fold ([run? #t] [capture? #f] [release? #f])
                  ([ev (in-events)]
                   #:break (not run?))
          (match ev
            [(or (quit-event) (window-event 'close-requested))
             (values #f #f #f)]
            [(key-event 'down 'escape _ _ _)
             (if captured?
                 (values run? #f #t)  ; release on escape if captured
                 (values #f #f #f))]  ; quit on escape if not captured
            [(key-event 'down _ _ _ _)
             (values run? capture? release?)]
            [(mouse-button-event 'down _ _ _ _)
             (if (not captured?)
                 (values run? #t #f)
                 (values run? capture? release?))]
            [_ (values run? capture? release?)])))

      (when still-running?
        ;; Handle mouse capture/release
        (when do-capture?
          (set-relative-mouse-mode! window #t)
          (set! captured? #t))

        (when do-release?
          (set-relative-mouse-mode! window #f)
          (set! captured? #f))

        ;; Get relative mouse motion when captured
        (when captured?
          (define-values (buttons dx dy) (get-relative-mouse-state))
          (set! last-dx dx)
          (set! last-dy dy)
          ;; Update camera angles
          (set! yaw (+ yaw (* dx sensitivity)))
          (set! pitch (max -89.0 (min 89.0 (+ pitch (* dy sensitivity))))))

        ;; Render
        (set-draw-color! renderer 20 25 35)
        (render-clear! renderer)

        ;; Draw horizon (affected by yaw)
        (draw-horizon! renderer cx cy yaw)

        ;; Draw pitch indicator
        (draw-pitch-indicator! renderer cx cy pitch)

        ;; Draw crosshair at center
        (draw-crosshair! renderer cx cy 20)

        ;; Draw info panel
        (draw-info-panel! renderer captured?)

        ;; Draw outer ring that shows yaw direction
        (set-draw-color! renderer 80 80 120)
        (for ([angle (in-range 0 360 30)])
          (define rad (* (+ angle yaw) (/ 3.14159 180.0)))
          (define r 250)
          (define x (+ cx (* r (cos rad))))
          (define y (+ cy (* r (sin rad))))
          (fill-rect! renderer (- x 3) (- y 3) 6 6))

        (render-present! renderer)
        (delay! 16)

        (loop still-running?))))

      ;; Make sure to release mouse before cleanup
      (when (relative-mouse-mode? window)
        (set-relative-mouse-mode! window #f)))))

;; Run the example when executed directly
(module+ main
  (main))
