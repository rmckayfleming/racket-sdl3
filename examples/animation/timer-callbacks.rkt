#lang racket/base

;; Timer callbacks example - SDL3 idiomatic usage
;; Demonstrates using Racket's native threads for periodic updates
;; instead of SDL's legacy timer system.

(require racket/match
         sdl3)

(define window-width 640)
(define window-height 360)
(define window-title "SDL3 Racket - Native Racket Timers")

(define tick-count (box 0))

(define (main)
  (sdl-init!)

  (define-values (window renderer)
    (make-window+renderer window-title window-width window-height
                          #:window-flags 'resizable))

  ;; Start a Racket thread to handle periodic updates.
  ;; This is safer and more idiomatic than SDL_AddTimer.
  (define timer-thread
    (thread
     (lambda ()
       (let loop ()
         (sleep 0.5) ; 500ms
         (set-box! tick-count (add1 (unbox tick-count)))
         (loop)))))

  (let loop ([running? #t])
    (when running?
      (define ticks (unbox tick-count))
      (define still-running?
        (for/fold ([run? #t])
                  ([ev (in-events)]
                   #:break (not run?))
          (match ev
            [(or (quit-event) (window-event 'close-requested)) #f]
            [(key-event 'down 'escape _ _ _) #f]
            [_ run?])))

      (when still-running?
        (define bg (if (even? ticks) 30 60))
        (set-draw-color! renderer bg 20 40)
        (render-clear! renderer)

        (set-draw-color! renderer 240 240 240)
        (render-debug-text! renderer 20 20 (format "Timer ticks (Racket thread): ~a" ticks))
        (render-debug-text! renderer 20 40 "Press ESC or close the window to exit.")

        (render-present! renderer)
        (delay! 16)
        (loop still-running?))))

  (kill-thread timer-thread)
  (renderer-destroy! renderer)
  (window-destroy! window))

(module+ main
  (main))
