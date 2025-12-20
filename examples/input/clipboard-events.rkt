#lang racket/base

;; Clipboard Events Demo
;;
;; Press C to set clipboard text from this app.
;; Copy text in another app to trigger updates.
;; Press Esc to quit.

(require racket/match
         racket/format
         racket/string
         sdl3)

(define window-width 720)
(define window-height 360)

(define (mime-types->string types)
  (if (null? types)
      "none"
      (string-join types ", ")))

(define (main)
  (sdl-init!)

  (define-values (window renderer)
    (make-window+renderer "SDL3 Clipboard Events" window-width window-height
                          #:window-flags SDL_WINDOW_RESIZABLE))

  (define running? #t)
  (define last-event "Waiting for clipboard updates...")
  (define last-text #f)

  (let loop ()
    (when running?
      (for ([ev (in-events)])
        (match ev
          [(or (quit-event) (window-event 'close-requested))
           (set! running? #f)]
          [(key-event 'down key _ _ _)
           (cond
             [(= key SDLK_ESCAPE) (set! running? #f)]
             [(= key SDLK_C)
              (define text (format "Clipboard set at ~a" (current-seconds)))
              (set-clipboard-text! text)
              (set! last-text text)]
             [else (void)])]
          [(clipboard-event owner? mime-types)
           (set! last-event
                 (format "owner?: ~a | mime types: ~a"
                         owner?
                         (mime-types->string mime-types)))
           (set! last-text (clipboard-text))]
          [_ (void)]))

      (set-draw-color! renderer 20 20 30)
      (render-clear! renderer)

      (set-draw-color! renderer 200 200 220)
      (render-debug-text! renderer 20 20 "CLIPBOARD EVENTS")
      (render-debug-text! renderer 20 40 "Press C to set clipboard text.")
      (render-debug-text! renderer 20 60 "Copy text in another app to trigger updates.")
      (render-debug-text! renderer 20 80 "Press Esc to quit.")

      (render-debug-text! renderer 20 120 last-event)
      (render-debug-text! renderer 20 140
                          (format "Clipboard text: ~a" (or last-text "n/a")))

      (render-present! renderer)
      (loop))))

(main)
