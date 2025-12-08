#lang racket/base

;; Hello Window - SDL3 Racket Bindings Example
;;
;; Creates an 800x600 window with a cornflower blue background.
;; Close the window to exit.
;;
;; This example uses the idiomatic safe interface.

(require racket/match
         sdl3/safe)

(define window-width 800)
(define window-height 600)
(define window-title "SDL3 Racket - Hello Window")

;; Cornflower blue: R=100, G=149, B=237
(define bg-r 100)
(define bg-g 149)
(define bg-b 237)

(define (main)
  ;; Initialize SDL video subsystem
  (sdl-init!)

  ;; Create window and renderer (automatically cleaned up on exit)
  (define-values (window renderer)
    (make-window+renderer window-title window-width window-height
                          #:window-flags SDL_WINDOW_RESIZABLE))

  ;; Main loop
  (let loop ()
    (define quit?
      (for/or ([ev (in-events)])
        (match ev
          [(or (quit-event) (window-event 'close-requested)) #t]
          [_ #f])))

    (unless quit?
      ;; Set draw color to cornflower blue
      (set-draw-color! renderer bg-r bg-g bg-b)

      ;; Clear the screen
      (render-clear! renderer)

      ;; Present the rendered frame
      (render-present! renderer)

      (loop))))

;; Run the main function
(main)
