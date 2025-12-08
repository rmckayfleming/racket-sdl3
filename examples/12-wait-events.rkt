#lang racket/base

;; Blocking Event Handling Demo
;;
;; Demonstrates CPU-efficient event handling using wait-event-timeout.
;; Unlike a polling loop that constantly checks for events, this approach
;; blocks until an event arrives (or timeout expires), freeing the CPU.
;;
;; - Uses wait-event-timeout with 1000ms timeout
;; - Shows "Idle update" when timeout occurs (no events for 1 second)
;; - Displays event type and timestamp for each event
;; - Press Escape or close window to quit
;;
;; This example uses the idiomatic safe interface.

(require racket/match
         sdl3/safe)

(define window-width 640)
(define window-height 480)

;; State
(define last-event-info "Waiting for events...")
(define idle-count 0)
(define event-count 0)

(define (format-event ev)
  (match ev
    [(quit-event)
     "QUIT"]
    [(window-event type)
     (format "WINDOW: ~a" type)]
    [(key-event type key _ _ repeat?)
     (format "KEY ~a: ~a~a"
             type
             (key-name key)
             (if repeat? " (repeat)" ""))]
    [(mouse-motion-event x y _ _ _)
     (format "MOUSE MOTION: (~a, ~a)"
             (inexact->exact (round x))
             (inexact->exact (round y)))]
    [(mouse-button-event type button x y clicks)
     (format "MOUSE ~a: button ~a at (~a, ~a) clicks=~a"
             type button
             (inexact->exact (round x))
             (inexact->exact (round y))
             clicks)]
    [(text-input-event text)
     (format "TEXT: ~s" text)]
    [(unknown-event type)
     (format "UNKNOWN: type=~a" type)]))

(define (main)
  ;; Initialize SDL video subsystem
  (sdl-init!)

  ;; Create window and renderer
  (define-values (window renderer)
    (make-window+renderer "SDL3 Wait Events Demo" window-width window-height))

  (printf "Wait Events Demo~n")
  (printf "================~n")
  (printf "Using wait-event-timeout (1000ms) for CPU-efficient event handling.~n")
  (printf "Move mouse, press keys, or wait to see idle updates.~n")
  (printf "Press Escape to quit.~n~n")

  ;; Main loop using blocking wait
  (let loop ([running? #t])
    (when running?
      ;; Wait for event with 1 second timeout
      ;; This blocks the process until an event arrives or timeout expires
      (define ev (wait-event-timeout 1000))

      (define still-running?
        (cond
          ;; Timeout - no events for 1 second
          [(not ev)
           (set! idle-count (add1 idle-count))
           (set! last-event-info (format "Idle update #~a" idle-count))
           (printf "~a~n" last-event-info)
           #t]

          ;; Got an event
          [else
           (set! event-count (add1 event-count))
           (set! last-event-info (format "#~a: ~a" event-count (format-event ev)))
           (printf "~a~n" last-event-info)

           ;; Check for quit conditions
           (match ev
             [(or (quit-event) (window-event 'close-requested))
              #f]
             [(key-event 'down key _ _ _)
              (not (= key SDLK_ESCAPE))]
             [_ #t])]))

      ;; Render current state
      (when still-running?
        ;; Dark background
        (set-draw-color! renderer 30 30 40)
        (render-clear! renderer)

        ;; Could render text here showing last-event-info if we had text support
        ;; For now, just show a visual indicator

        ;; Draw a pulsing circle to show the app is alive
        (define pulse (+ 100 (inexact->exact (round (* 50 (sin (/ (current-ticks) 500.0)))))))
        (set-draw-color! renderer pulse pulse (+ pulse 50))

        ;; Draw a simple cross in the center
        (draw-line! renderer
                    (- (/ window-width 2) 20) (/ window-height 2)
                    (+ (/ window-width 2) 20) (/ window-height 2))
        (draw-line! renderer
                    (/ window-width 2) (- (/ window-height 2) 20)
                    (/ window-width 2) (+ (/ window-height 2) 20))

        (render-present! renderer)
        (loop still-running?))))

  (printf "~nExiting. Processed ~a events with ~a idle timeouts.~n"
          event-count idle-count))

;; Run
(main)
