#lang racket/base

;; Window Size & Position Demo
;;
;; Demonstrates controlling window size, position, and fullscreen mode.
;;
;; Controls:
;;   Arrow keys - Move window (50 pixel steps)
;;   +/= - Increase window size
;;   -/_ - Decrease window size
;;   F - Toggle fullscreen
;;   C - Center window on screen
;;   R - Reset to original size and position
;;   ESC - Quit

(require racket/match
         racket/format
         sdl3/safe)

(define initial-width 800)
(define initial-height 600)
(define window-title "SDL3 Window Controls Demo")

(define font-path "/System/Library/Fonts/Supplemental/Arial.ttf")
(define base-font-size 18.0)

;; Movement and resize steps
(define move-step 50)
(define size-step 50)
(define min-size 200)

;; Key codes
(define SDLK_f 102)
(define SDLK_F 70)
(define SDLK_c 99)
(define SDLK_C 67)
(define SDLK_EQUALS 61)    ; = key (also + with shift)
(define SDLK_PLUS 43)      ; + on numpad
(define SDLK_MINUS 45)     ; - key

(define (main)
  (sdl-init!)

  (define-values (window renderer)
    (make-window+renderer window-title initial-width initial-height
                          #:window-flags SDL_WINDOW_RESIZABLE))

  ;; Scale font for high-DPI
  (define pixel-density (window-pixel-density window))
  (define font-size (* base-font-size pixel-density))
  (define font (open-font font-path font-size))

  ;; Store initial position for reset
  (define-values (init-x init-y) (window-position window))

  (let loop ([running? #t])
    (when running?
      ;; Get current window state
      (define-values (win-w win-h) (window-size window))
      (define-values (win-x win-y) (window-position window))
      (define fullscreen? (window-fullscreen? window))

      ;; Handle events
      (define still-running?
        (for/fold ([run? #t])
                  ([ev (in-events)]
                   #:break (not run?))
          (match ev
            [(or (quit-event) (window-event 'close-requested))
             #f]

            [(key-event 'down key _ _ _)
             (cond
               [(= key SDLK_ESCAPE) #f]

               ;; Arrow keys - move window
               [(= key SDLK_LEFT)
                (window-set-position! window (- win-x move-step) win-y)
                run?]
               [(= key SDLK_RIGHT)
                (window-set-position! window (+ win-x move-step) win-y)
                run?]
               [(= key SDLK_UP)
                (window-set-position! window win-x (- win-y move-step))
                run?]
               [(= key SDLK_DOWN)
                (window-set-position! window win-x (+ win-y move-step))
                run?]

               ;; +/= - increase size
               [(or (= key SDLK_EQUALS) (= key SDLK_PLUS))
                (window-set-size! window (+ win-w size-step) (+ win-h size-step))
                run?]

               ;; - decrease size
               [(= key SDLK_MINUS)
                (window-set-size! window
                                  (max min-size (- win-w size-step))
                                  (max min-size (- win-h size-step)))
                run?]

               ;; F - toggle fullscreen
               [(or (= key SDLK_f) (= key SDLK_F))
                (window-set-fullscreen! window (not fullscreen?))
                run?]

               ;; C - center window (approximate, assumes 1920x1080 display)
               [(or (= key SDLK_c) (= key SDLK_C))
                (window-set-position! window
                                      (quotient (- 1920 win-w) 2)
                                      (quotient (- 1080 win-h) 2))
                run?]

               ;; R - reset
               [(or (= key SDLK_r) (= key SDLK_R))
                (when fullscreen?
                  (window-set-fullscreen! window #f))
                (window-set-size! window initial-width initial-height)
                (window-set-position! window init-x init-y)
                run?]

               [else run?])]

            [_ run?])))

      (when still-running?
        ;; Re-fetch window state (may have changed)
        (define-values (curr-w curr-h) (window-size window))
        (define-values (curr-x curr-y) (window-position window))
        (define curr-fullscreen? (window-fullscreen? window))

        ;; Clear to dark background
        (set-draw-color! renderer 40 40 40)
        (render-clear! renderer)

        ;; Draw info text
        (draw-text! renderer font "Window Size & Position Demo"
                    20 20 '(255 255 255 255))

        (draw-text! renderer font "Arrows = Move | +/- = Resize | F = Fullscreen | C = Center | R = Reset"
                    20 50 '(180 180 180 255))

        ;; Show current values
        (define size-text (format "Size: ~a x ~a" curr-w curr-h))
        (define pos-text (format "Position: (~a, ~a)" curr-x curr-y))
        (define fs-text (format "Fullscreen: ~a" (if curr-fullscreen? "ON" "off")))

        (draw-text! renderer font size-text 20 120 '(255 255 0 255))
        (draw-text! renderer font pos-text 20 150 '(255 255 0 255))
        (draw-text! renderer font fs-text 20 180 '(255 255 0 255))

        ;; Draw a border to visualize window bounds
        (set-draw-color! renderer 100 100 255 255)
        (draw-rect! renderer 10 10 (- curr-w 20) (- curr-h 20))

        (render-present! renderer)
        (delay! 16)

        (loop still-running?))))

  (close-font! font))

;; Run the example
(main)
