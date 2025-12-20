#lang racket/base

;; Timer callbacks example - SDL3 idiomatic usage
;; Demonstrates SDL_AddTimer with a lightweight callback.

(require racket/match
         sdl3)

(define window-width 640)
(define window-height 360)
(define window-title "SDL3 Racket - Timer Callbacks")

(define tick-count (box 0))

(define (main)
  (sdl-init!)

  (define-values (window renderer)
    (make-window+renderer window-title window-width window-height
                          #:window-flags SDL_WINDOW_RESIZABLE))

  (define timer
    (add-timer 500
               (lambda (_timer interval)
                 (set-box! tick-count (add1 (unbox tick-count)))
                 interval)))

  (let loop ([running? #t])
    (when running?
      (define ticks (unbox tick-count))
      (define still-running?
        (for/fold ([run? #t])
                  ([ev (in-events)]
                   #:break (not run?))
          (match ev
            [(or (quit-event) (window-event 'close-requested)) #f]
            [(key-event 'down key _ _ _) (if (= key SDLK_ESCAPE) #f run?)]
            [_ run?])))

      (when still-running?
        (define bg (if (even? ticks) 30 60))
        (set-draw-color! renderer bg 20 40)
        (render-clear! renderer)

        (set-draw-color! renderer 240 240 240)
        (render-debug-text! renderer 20 20 (format "Timer ticks: ~a" ticks))
        (render-debug-text! renderer 20 40 "Press ESC or close the window to exit.")

        (render-present! renderer)
        (delay! 16)
        (loop still-running?))))

  (remove-timer! timer)
  (renderer-destroy! renderer)
  (window-destroy! window))

(module+ main
  (main))
