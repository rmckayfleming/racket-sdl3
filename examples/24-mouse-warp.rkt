#lang racket/base

;; Mouse Warp & Capture Demo
;;
;; Demonstrates mouse warping and capture functionality:
;; - Warp mouse to window center on key press
;; - Show global vs window-relative coordinates
;; - Click and drag to draw lines
;;
;; About Mouse Capture:
;; SDL3 has "auto-capture" enabled by default - when you click and drag,
;; the window automatically receives mouse events even outside its bounds.
;; This means dragging outside the window works without any special code!
;;
;; The C key toggles SDL_CaptureMouse which disables/re-enables auto-capture.
;; With auto-capture OFF, dragging outside the window stops receiving events.
;; This is mainly useful if auto-capture causes problems for your app.
;;
;; Controls:
;; - Space: Warp mouse to window center
;; - C: Toggle auto-capture (ON by default)
;; - Click and drag: Draw lines (works outside window with auto-capture)
;; - Escape: Quit

(require racket/match
         racket/format
         racket/math
         sdl3/safe)

(define window-width 800)
(define window-height 600)

;; State
;; Auto-capture is ON by default in SDL3
(define auto-capture? #t)
(define dragging? #f)
(define last-x 0)
(define last-y 0)

;; Store drawn lines as (list x1 y1 x2 y2)
(define lines '())

;; Draw info panel
(define (draw-info! renderer local-x local-y global-x global-y buttons)
  ;; Background panel
  (set-draw-color! renderer 35 35 45)
  (fill-rect! renderer 10 10 350 130)
  (set-draw-color! renderer 60 60 70)
  (draw-rect! renderer 10 10 350 130)

  ;; Title
  (set-draw-color! renderer 150 150 150)
  (render-debug-text! renderer 20 18 "MOUSE WARP & CAPTURE DEMO")

  ;; Window coordinates
  (set-draw-color! renderer 100 200 100)
  (render-debug-text! renderer 20 40
                      (~a "Window: " (inexact->exact (round local-x))
                          ", " (inexact->exact (round local-y))))

  ;; Global coordinates
  (set-draw-color! renderer 100 200 255)
  (render-debug-text! renderer 20 55
                      (~a "Global: " (inexact->exact (round global-x))
                          ", " (inexact->exact (round global-y))))

  ;; Button state
  (set-draw-color! renderer 200 200 100)
  (render-debug-text! renderer 20 70
                      (~a "Buttons: " (if (mouse-button-pressed? buttons SDL_BUTTON_LMASK) "L " "")
                          (if (mouse-button-pressed? buttons SDL_BUTTON_MMASK) "M " "")
                          (if (mouse-button-pressed? buttons SDL_BUTTON_RMASK) "R" "")))

  ;; Auto-capture state
  (if auto-capture?
      (set-draw-color! renderer 100 200 100)
      (set-draw-color! renderer 255 100 100))
  (render-debug-text! renderer 20 85
                      (~a "Auto-capture: " (if auto-capture? "ON" "OFF")))

  ;; Dragging state
  (if dragging?
      (set-draw-color! renderer 255 200 100)
      (set-draw-color! renderer 100 100 100))
  (render-debug-text! renderer 20 100
                      (~a "Dragging: " (if dragging? "YES" "NO")))

  ;; Line count
  (set-draw-color! renderer 150 150 150)
  (render-debug-text! renderer 20 115
                      (~a "Lines: " (length lines))))

;; Draw instructions
(define (draw-instructions! renderer)
  (set-draw-color! renderer 35 35 45)
  (fill-rect! renderer 10 (- window-height 95) 320 85)
  (set-draw-color! renderer 60 60 70)
  (draw-rect! renderer 10 (- window-height 95) 320 85)

  (set-draw-color! renderer 150 150 150)
  (render-debug-text! renderer 20 (- window-height 87) "CONTROLS")
  (set-draw-color! renderer 120 120 120)
  (render-debug-text! renderer 20 (- window-height 70) "Space: Warp to center")
  (render-debug-text! renderer 20 (- window-height 55) "C: Toggle auto-capture")
  (render-debug-text! renderer 20 (- window-height 40) "Click+drag: Draw lines")
  (render-debug-text! renderer 20 (- window-height 25) "Escape: Quit"))

;; Draw center target
(define (draw-center-target! renderer)
  (define cx (/ window-width 2))
  (define cy (/ window-height 2))

  ;; Crosshair
  (set-draw-color! renderer 80 80 100)
  (draw-line! renderer (- cx 20) cy (+ cx 20) cy)
  (draw-line! renderer cx (- cy 20) cx (+ cy 20))

  ;; Circle approximation
  (for ([i (in-range 0 360 15)])
    (define r 15)
    (define x1 (+ cx (* r (cos (* i (/ pi 180))))))
    (define y1 (+ cy (* r (sin (* i (/ pi 180))))))
    (define x2 (+ cx (* r (cos (* (+ i 15) (/ pi 180))))))
    (define y2 (+ cy (* r (sin (* (+ i 15) (/ pi 180))))))
    (draw-line! renderer x1 y1 x2 y2)))

;; Draw all stored lines
(define (draw-lines! renderer)
  (set-draw-color! renderer 200 100 100)
  (for ([line (in-list lines)])
    (match-define (list x1 y1 x2 y2) line)
    (draw-line! renderer x1 y1 x2 y2)))

;; Draw cursor position indicator
(define (draw-cursor-indicator! renderer x y)
  (set-draw-color! renderer 255 255 255 128)
  (fill-rect! renderer (- x 3) (- y 3) 6 6))

(define (main)
  (sdl-init!)

  (define-values (window renderer)
    (make-window+renderer "SDL3 Mouse Warp Demo" window-width window-height))

  (printf "Mouse Warp & Capture Demo~n")
  (printf "=========================~n")
  (printf "Space: Warp mouse to window center~n")
  (printf "C: Toggle auto-capture (ON by default)~n")
  (printf "Click and drag to draw lines~n")
  (printf "(With auto-capture ON, dragging works outside window)~n")
  (printf "(With auto-capture OFF, drag stops at window edge)~n")
  (printf "Escape: Quit~n~n")

  (let loop ([running? #t])
    (when running?
      ;; Get mouse states
      (define-values (local-x local-y local-buttons) (get-mouse-state))
      (define-values (global-x global-y global-buttons) (get-global-mouse-state))

      ;; Process events
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
               [(= key SDLK_SPACE)
                ;; Warp to center
                (warp-mouse! window (/ window-width 2) (/ window-height 2))
                (printf "Warped mouse to center~n")
                run?]
               [(= key SDLK_C)
                ;; Toggle auto-capture
                ;; When auto-capture? is #t, we want capture enabled (pass #t)
                ;; When auto-capture? is #f, we want capture disabled (pass #f)
                (set! auto-capture? (not auto-capture?))
                (capture-mouse! auto-capture?)
                (printf "Auto-capture: ~a~n" (if auto-capture? "ON" "OFF"))
                run?]
               [else run?])]

            ;; Mouse button down - start dragging
            [(mouse-button-event 'down 'left x y _)
             (set! dragging? #t)
             (set! last-x x)
             (set! last-y y)
             run?]

            ;; Mouse button up - stop dragging
            [(mouse-button-event 'up 'left _ _ _)
             (set! dragging? #f)
             run?]

            ;; Mouse motion - draw line if dragging
            [(mouse-motion-event x y _ _ _)
             (when dragging?
               (set! lines (cons (list last-x last-y x y) lines))
               (set! last-x x)
               (set! last-y y))
             run?]

            [_ run?])))

      (when still-running?
        ;; Clear background
        (set-draw-color! renderer 30 30 35)
        (render-clear! renderer)

        ;; Draw everything
        (draw-center-target! renderer)
        (draw-lines! renderer)
        (draw-cursor-indicator! renderer local-x local-y)
        (draw-info! renderer local-x local-y global-x global-y local-buttons)
        (draw-instructions! renderer)

        (render-present! renderer)
        (delay! 16)
        (loop still-running?))))

  ;; Re-enable auto-capture before exit if we disabled it
  (unless auto-capture?
    (capture-mouse! #t))

  (printf "~nDone.~n")

  ;; Clean up
  (renderer-destroy! renderer)
  (window-destroy! window))

;; Run when executed directly
(module+ main
  (main))
