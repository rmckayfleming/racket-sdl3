#lang racket/base

;; Drop Events Demo
;;
;; Drag files or text into the window to see drop events.
;; Press Esc to quit.

(require racket/match
         racket/format
         sdl3)

(define window-width 720)
(define window-height 480)

(define (fmt-num n)
  (if (number? n)
      (number->string (inexact->exact (round n)))
      "n/a"))

(define (main)
  (sdl-init!)

  (define-values (window renderer)
    (make-window+renderer "SDL3 Drop Events" window-width window-height
                          #:window-flags SDL_WINDOW_RESIZABLE))

  (define running? #t)
  (define last-type 'none)
  (define last-data #f)
  (define last-source #f)
  (define last-x #f)
  (define last-y #f)

  (let loop ()
    (when running?
      (for ([ev (in-events)])
        (match ev
          [(or (quit-event) (window-event 'close-requested))
           (set! running? #f)]
          [(key-event 'down key _ _ _)
           (when (= key SDLK_ESCAPE)
             (set! running? #f))]
          [(drop-event type x y source data)
           (set! last-type type)
           (set! last-data data)
           (set! last-source source)
           (set! last-x x)
           (set! last-y y)
           (printf "Drop event: ~a ~a~n"
                   type
                   (if data data ""))]
          [_ (void)]))

      (set-draw-color! renderer 20 20 30)
      (render-clear! renderer)

      (set-draw-color! renderer 200 200 220)
      (render-debug-text! renderer 20 20 "DROP EVENTS")
      (render-debug-text! renderer 20 40 "Drag files or text into this window.")
      (render-debug-text! renderer 20 60 "Press Esc to quit.")

      (render-debug-text! renderer 20 100
                          (format "Type: ~a" last-type))
      (render-debug-text! renderer 20 120
                          (format "Data: ~a" (or last-data "n/a")))
      (render-debug-text! renderer 20 140
                          (format "Source: ~a" (or last-source "n/a")))
      (render-debug-text! renderer 20 160
                          (format "Position: ~a, ~a"
                                  (fmt-num last-x)
                                  (fmt-num last-y)))

      (render-present! renderer)
      (loop))))

(main)
