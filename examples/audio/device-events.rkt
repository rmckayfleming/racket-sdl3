#lang racket/base

;; Audio Device Events Demo
;;
;; Shows audio device add/remove/format-change events.
;; Press Esc to quit.

(require racket/match
         racket/format
         sdl3)

(define window-width 720)
(define window-height 360)

(define (main)
  (sdl-init! '(video audio))

  (define-values (window renderer)
    (make-window+renderer "SDL3 Audio Device Events" window-width window-height
                          #:window-flags 'resizable))

  (define running? #t)
  (define last-type 'none)
  (define last-which #f)
  (define last-recording? #f)

  (let loop ()
    (when running?
      (for ([ev (in-events)])
        (match ev
          [(or (quit-event) (window-event 'close-requested))
           (set! running? #f)]
          [(key-event 'down 'escape _ _ _)
           (set! running? #f)]
          [(audio-device-event type which recording?)
           (set! last-type type)
           (set! last-which which)
           (set! last-recording? recording?)
           (printf "Audio device event: ~a id=~a recording?=~a~n"
                   type which recording?)]
          [_ (void)]))

      (set-draw-color! renderer 20 20 30)
      (render-clear! renderer)

      (set-draw-color! renderer 200 200 220)
      (render-debug-text! renderer 20 20 "AUDIO DEVICE EVENTS")
      (render-debug-text! renderer 20 40 "Plug/unplug audio devices to see events.")
      (render-debug-text! renderer 20 60 "Press Esc to quit.")

      (render-debug-text! renderer 20 100
                          (format "Last event: ~a" last-type))
      (render-debug-text! renderer 20 120
                          (format "Device ID: ~a" (or last-which "n/a")))
      (render-debug-text! renderer 20 140
                          (format "Recording: ~a" (if last-recording? "yes" "no")))

      (render-present! renderer)
      (loop))))

(main)
