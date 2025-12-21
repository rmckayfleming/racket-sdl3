#lang racket/base

;; Hello Animation - SDL3 idiomatic example
;; Demonstrates time-based animation using current-ticks.

(require racket/match
         racket/math
         sdl3)

(define window-width 800)
(define window-height 600)
(define window-title "SDL3 Racket - Hello Animation")

(define (clamp v lo hi)
  (max lo (min v hi)))

(define (main)
  (sdl-init!)

  (define-values (window renderer)
    (make-window+renderer window-title window-width window-height
                          #:window-flags SDL_WINDOW_RESIZABLE))

  (let loop ([ball-x 400.0] [ball-y 300.0]
             [ball-vx 200.0] [ball-vy 150.0]
             [ball-radius 20.0]
             [last-ticks (current-ticks)]
             [running? #t])
    (when running?
      (define now (current-ticks))
      (define dt (/ (- now last-ticks) 1000.0))
      (define time-sec (/ now 1000.0))

      ;; Process events
      (define still-running?
        (for/fold ([run? #t])
                  ([ev (in-events)]
                   #:break (not run?))
          (match ev
            [(or (quit-event) (window-event 'close-requested)) #f]
            [(key-event 'down 'escape _ _ _) #f]
            [_ run?])))

      (when still-running?
        ;; Integrate ball motion
        (define next-x (+ ball-x (* ball-vx dt)))
        (define next-y (+ ball-y (* ball-vy dt)))
        (define next-vx ball-vx)
        (define next-vy ball-vy)

        (when (or (< next-x ball-radius)
                  (> next-x (- window-width ball-radius)))
          (set! next-vx (- next-vx))
          (set! next-x (clamp next-x ball-radius (- window-width ball-radius))))

        (when (or (< next-y ball-radius)
                  (> next-y (- window-height ball-radius)))
          (set! next-vy (- next-vy))
          (set! next-y (clamp next-y ball-radius (- window-height ball-radius))))

        ;; Wave points for the bottom oscillation
        (define wave-points
          (for/list ([x (in-range 0 window-width 4)])
            (list (exact->inexact x)
                  (+ 550.0
                     (* 20.0 (sin (+ (* x 0.02) (* time-sec 4))))
                     (* 10.0 (sin (+ (* x 0.05) (* time-sec 2))))))))

        ;; Clear and draw
        (set-draw-color! renderer 20 20 30)
        (render-clear! renderer)

        ;; Bouncing ball (drawn as filled rect)
        (set-draw-color! renderer 255 100 100)
        (fill-rect! renderer (- next-x ball-radius) (- next-y ball-radius)
                    (* 2 ball-radius) (* 2 ball-radius))

        ;; Orbiting squares with cycling colors
        (define center-x 400.0)
        (define center-y 300.0)
        (define orbit-radius 150.0)
        (for ([i (in-range 6)])
          (define angle (+ (* time-sec 1.5) (* i (/ (* 2 pi) 6))))
          (define ox (+ center-x (* orbit-radius (cos angle))))
          (define oy (+ center-y (* orbit-radius (sin angle))))
          (define size 20.0)
          (define r (exact-round (+ 128 (* 127 (cos angle)))))
          (define g (exact-round (+ 128 (* 127 (cos (+ angle (* 2 (/ pi 3))))))))
          (define b (exact-round (+ 128 (* 127 (cos (+ angle (* 4 (/ pi 3))))))))
          (set-draw-color! renderer r g b)
          (fill-rect! renderer (- ox (/ size 2)) (- oy (/ size 2)) size size))

        ;; Pulsing square
        (define pulse (+ 0.5 (* 0.5 (sin (* time-sec 3)))))
        (define pulse-size (+ 30 (* 20 pulse)))
        (define pulse-color (exact-round (* 255 pulse)))
        (set-draw-color! renderer pulse-color pulse-color 255)
        (fill-rect! renderer 50.0 50.0 pulse-size pulse-size)

        ;; Spinning line
        (define spin-angle (* time-sec 2))
        (define spin-cx 650.0)
        (define spin-cy 100.0)
        (define spin-len 60.0)
        (set-draw-color! renderer 100 255 100)
        (draw-line! renderer
                    (+ spin-cx (* spin-len (cos spin-angle)))
                    (+ spin-cy (* spin-len (sin spin-angle)))
                    (- spin-cx (* spin-len (cos spin-angle)))
                    (- spin-cy (* spin-len (sin spin-angle))))

        ;; Oscillating wave
        (set-draw-color! renderer 100 200 255)
        (draw-points! renderer wave-points)

        ;; FPS indicator bar
        (define fps-width (min 100.0 (if (> dt 0) (/ 1.0 dt) 60.0)))
        (set-draw-color! renderer 0 255 0)
        (fill-rect! renderer 10.0 580.0 fps-width 10.0)

        (render-present! renderer)
        (delay! 16)

        (loop next-x next-y next-vx next-vy ball-radius now still-running?))))

  ;; Clean up (important for REPL usage)
  (renderer-destroy! renderer)
  (window-destroy! window))

;; Run the example when executed directly
(module+ main
  (main))
