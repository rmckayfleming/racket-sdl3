#lang racket/base

;; Hello Animation - SDL3 Racket Bindings Example
;;
;; Demonstrates time-based animation using SDL_GetTicks.
;; Shows bouncing ball, rotating shapes, and pulsing colors.
;; Press ESC or close the window to exit.

(require ffi/unsafe
         racket/math
         sdl3)

(define WINDOW_WIDTH 800)
(define WINDOW_HEIGHT 600)
(define WINDOW_TITLE "SDL3 Racket - Hello Animation")

(define PI 3.141592653589793)

(define (main)
  ;; Initialize SDL video subsystem
  (unless (SDL-Init SDL_INIT_VIDEO)
    (error 'main "Failed to initialize SDL: ~a" (SDL-GetError)))

  (define window #f)
  (define renderer #f)

  (dynamic-wind
    void
    (λ ()
      ;; Create window
      (set! window (SDL-CreateWindow WINDOW_TITLE
                                     WINDOW_WIDTH
                                     WINDOW_HEIGHT
                                     SDL_WINDOW_RESIZABLE))
      (unless window
        (error 'main "Failed to create window: ~a" (SDL-GetError)))

      ;; Create renderer
      (set! renderer (SDL-CreateRenderer window #f))
      (unless renderer
        (error 'main "Failed to create renderer: ~a" (SDL-GetError)))

      ;; Event buffer
      (define event-buf (malloc SDL_EVENT_SIZE))
      (define running? #t)

      ;; Animation state
      ;; Bouncing ball
      (define ball-x 400.0)
      (define ball-y 300.0)
      (define ball-vx 200.0)  ; pixels per second
      (define ball-vy 150.0)
      (define ball-radius 20.0)

      ;; Track time
      (define last-ticks (SDL-GetTicks))

      ;; Main loop
      (let loop ()
        (when running?
          ;; Calculate delta time
          (define current-ticks (SDL-GetTicks))
          (define dt (/ (- current-ticks last-ticks) 1000.0)) ; seconds
          (set! last-ticks current-ticks)

          ;; Poll all pending events
          (let poll-events ()
            (when (SDL-PollEvent event-buf)
              (define event-type (sdl-event-type event-buf))
              (cond
                [(= event-type SDL_EVENT_QUIT)
                 (set! running? #f)]
                [(= event-type SDL_EVENT_KEY_DOWN)
                 (define kb-event (event->keyboard event-buf))
                 (define key (SDL_KeyboardEvent-key kb-event))
                 (when (= key SDLK_ESCAPE)
                   (set! running? #f))])
              (poll-events)))

          (when running?
            ;; Update ball position
            (set! ball-x (+ ball-x (* ball-vx dt)))
            (set! ball-y (+ ball-y (* ball-vy dt)))

            ;; Bounce off walls
            (when (or (< ball-x ball-radius)
                      (> ball-x (- WINDOW_WIDTH ball-radius)))
              (set! ball-vx (- ball-vx))
              (set! ball-x (max ball-radius (min ball-x (- WINDOW_WIDTH ball-radius)))))
            (when (or (< ball-y ball-radius)
                      (> ball-y (- WINDOW_HEIGHT ball-radius)))
              (set! ball-vy (- ball-vy))
              (set! ball-y (max ball-radius (min ball-y (- WINDOW_HEIGHT ball-radius)))))

            ;; Time-based values for animations
            (define time-sec (/ current-ticks 1000.0))

            ;; Clear screen with dark background
            (SDL-SetRenderDrawColor renderer 20 20 30 255)
            (SDL-RenderClear renderer)

            ;; Draw bouncing ball (filled rectangle approximation)
            (define ball-rect (make-SDL_FRect (- ball-x ball-radius)
                                               (- ball-y ball-radius)
                                               (* 2 ball-radius)
                                               (* 2 ball-radius)))
            (SDL-SetRenderDrawColor renderer 255 100 100 255)
            (SDL-RenderFillRect renderer ball-rect)

            ;; Draw orbiting squares around center
            (define center-x 400.0)
            (define center-y 300.0)
            (define orbit-radius 150.0)
            (for ([i (in-range 6)])
              (define angle (+ (* time-sec 1.5) (* i (/ (* 2 PI) 6))))
              (define ox (+ center-x (* orbit-radius (cos angle))))
              (define oy (+ center-y (* orbit-radius (sin angle))))
              (define size 20.0)
              (define rect (make-SDL_FRect (- ox (/ size 2))
                                           (- oy (/ size 2))
                                           size size))
              ;; Color based on position in orbit
              (define r (exact-round (+ 128 (* 127 (cos angle)))))
              (define g (exact-round (+ 128 (* 127 (cos (+ angle (* 2 (/ PI 3))))))))
              (define b (exact-round (+ 128 (* 127 (cos (+ angle (* 4 (/ PI 3))))))))
              (SDL-SetRenderDrawColor renderer r g b 255)
              (SDL-RenderFillRect renderer rect))

            ;; Draw pulsing rectangle in corner
            (define pulse (+ 0.5 (* 0.5 (sin (* time-sec 3)))))
            (define pulse-size (+ 30 (* 20 pulse)))
            (define pulse-rect (make-SDL_FRect 50.0 50.0 pulse-size pulse-size))
            (define pulse-color (exact-round (* 255 pulse)))
            (SDL-SetRenderDrawColor renderer pulse-color pulse-color 255 255)
            (SDL-RenderFillRect renderer pulse-rect)

            ;; Draw spinning line
            (define spin-angle (* time-sec 2))
            (define spin-cx 650.0)
            (define spin-cy 100.0)
            (define spin-len 60.0)
            (define x1 (+ spin-cx (* spin-len (cos spin-angle))))
            (define y1 (+ spin-cy (* spin-len (sin spin-angle))))
            (define x2 (- spin-cx (* spin-len (cos spin-angle))))
            (define y2 (- spin-cy (* spin-len (sin spin-angle))))
            (SDL-SetRenderDrawColor renderer 100 255 100 255)
            (SDL-RenderLine renderer x1 y1 x2 y2)

            ;; Draw oscillating wave at bottom
            (SDL-SetRenderDrawColor renderer 100 200 255 255)
            (for ([x (in-range 0 800 4)])
              (define wave-y (+ 550.0
                               (* 20.0 (sin (+ (* x 0.02) (* time-sec 4))))
                               (* 10.0 (sin (+ (* x 0.05) (* time-sec 2))))))
              (SDL-RenderPoint renderer (exact->inexact x) wave-y))

            ;; Display FPS (approximate, via frame time)
            ;; We'll just draw a simple indicator bar
            (define fps-width (min 100.0 (if (> dt 0) (/ 1.0 dt) 60.0)))
            (define fps-rect (make-SDL_FRect 10.0 580.0 fps-width 10.0))
            (SDL-SetRenderDrawColor renderer 0 255 0 255)
            (SDL-RenderFillRect renderer fps-rect)

            ;; Present the rendered frame
            (SDL-RenderPresent renderer)

            ;; Small delay to cap frame rate roughly
            (SDL-Delay 16)

            (loop)))))

    ;; Cleanup
    (λ ()
      (when renderer
        (SDL-DestroyRenderer renderer))
      (when window
        (SDL-DestroyWindow window))
      (SDL-Quit))))

;; Run the main function
(main)
