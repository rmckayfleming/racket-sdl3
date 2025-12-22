#lang racket/base

;; Mouse Wheel Scrolling Demo
;;
;; Demonstrates mouse wheel event handling with a scrollable virtual canvas.
;; - Scroll wheel moves viewport up/down
;; - Horizontal scroll (if supported) or Shift+scroll moves left/right
;; - Shows current scroll position and last wheel delta
;; - Press Escape or close window to quit
;;
;; This example uses the safe interface.

(require racket/match
         sdl3)

(define window-width 640)
(define window-height 480)

;; Virtual canvas size (larger than window)
(define canvas-width 1600)
(define canvas-height 1200)

;; Current scroll position (mutable)
(define scroll-x 0.0)
(define scroll-y 0.0)

;; Last wheel event info for display
(define last-wheel-x 0.0)
(define last-wheel-y 0.0)

;; Current modifier state (tracked from key events)
(define current-mod 0)

;; Scroll speed multiplier
(define scroll-speed 30.0)

;; Clamp scroll to valid range
(define (clamp-scroll!)
  (set! scroll-x (max 0.0 (min scroll-x (- canvas-width window-width))))
  (set! scroll-y (max 0.0 (min scroll-y (- canvas-height window-height)))))

;; Draw a colored grid pattern on the virtual canvas
(define (draw-canvas! renderer)
  ;; Draw grid cells with varying colors based on position
  (define cell-size 80)

  ;; Calculate visible range
  (define start-col (quotient (inexact->exact (floor scroll-x)) cell-size))
  (define start-row (quotient (inexact->exact (floor scroll-y)) cell-size))
  (define end-col (+ start-col (quotient window-width cell-size) 2))
  (define end-row (+ start-row (quotient window-height cell-size) 2))

  ;; Draw visible grid cells
  (for* ([row (in-range start-row (min end-row (quotient canvas-height cell-size)))]
         [col (in-range start-col (min end-col (quotient canvas-width cell-size)))])
    (define x (- (* col cell-size) scroll-x))
    (define y (- (* row cell-size) scroll-y))

    ;; Color based on position (creates a gradient pattern)
    (define r (modulo (* col 20) 256))
    (define g (modulo (* row 20) 256))
    (define b (modulo (* (+ col row) 15) 256))

    ;; Fill cell
    (set-draw-color! renderer r g b)
    (fill-rect! renderer x y (- cell-size 2) (- cell-size 2))

    ;; Draw cell border
    (set-draw-color! renderer 60 60 60)
    (draw-rect! renderer x y (- cell-size 2) (- cell-size 2))))

;; Draw scroll position indicator
(define (draw-scroll-info! renderer)
  ;; Draw a minimap in the corner showing viewport position
  (define map-w 100.0)
  (define map-h 75.0)
  (define map-x (- window-width map-w 10))
  (define map-y 10.0)

  ;; Minimap background
  (set-draw-color! renderer 40 40 40 200)
  (fill-rect! renderer map-x map-y map-w map-h)

  ;; Minimap border
  (set-draw-color! renderer 100 100 100)
  (draw-rect! renderer map-x map-y map-w map-h)

  ;; Viewport indicator
  (define vp-x (+ map-x (* (/ scroll-x canvas-width) map-w)))
  (define vp-y (+ map-y (* (/ scroll-y canvas-height) map-h)))
  (define vp-w (* (/ window-width canvas-width) map-w))
  (define vp-h (* (/ window-height canvas-height) map-h))

  (set-draw-color! renderer 255 200 100)
  (draw-rect! renderer vp-x vp-y vp-w vp-h)

  ;; Draw scroll delta indicator (shows last wheel movement)
  (define indicator-x 10.0)
  (define indicator-y 10.0)
  (define indicator-size 60.0)
  (define center-x (+ indicator-x (/ indicator-size 2)))
  (define center-y (+ indicator-y (/ indicator-size 2)))

  ;; Background
  (set-draw-color! renderer 40 40 40 200)
  (fill-rect! renderer indicator-x indicator-y indicator-size indicator-size)
  (set-draw-color! renderer 100 100 100)
  (draw-rect! renderer indicator-x indicator-y indicator-size indicator-size)

  ;; Cross showing wheel direction
  (set-draw-color! renderer 80 80 80)
  (draw-line! renderer center-x (+ indicator-y 5) center-x (- (+ indicator-y indicator-size) 5))
  (draw-line! renderer (+ indicator-x 5) center-y (- (+ indicator-x indicator-size) 5) center-y)

  ;; Arrow showing last scroll direction
  (when (or (not (zero? last-wheel-x)) (not (zero? last-wheel-y)))
    (define arrow-len 20.0)
    (define dx (* (if (> last-wheel-x 0) 1.0 (if (< last-wheel-x 0) -1.0 0.0)) arrow-len))
    (define dy (* (if (> last-wheel-y 0) -1.0 (if (< last-wheel-y 0) 1.0 0.0)) arrow-len))
    (set-draw-color! renderer 100 255 100)
    (draw-line! renderer center-x center-y (+ center-x dx) (+ center-y dy)))

  ;; Draw modifier indicators at bottom left
  (define mod-y (- window-height 30.0))
  (define mod-size 20.0)
  (define mod-spacing 25.0)

  ;; Shift indicator
  (if (mod-shift? current-mod)
      (set-draw-color! renderer 255 200 100)
      (set-draw-color! renderer 60 60 60))
  (fill-rect! renderer 10.0 mod-y mod-size mod-size)
  (set-draw-color! renderer 100 100 100)
  (draw-rect! renderer 10.0 mod-y mod-size mod-size)

  ;; Ctrl indicator
  (if (mod-ctrl? current-mod)
      (set-draw-color! renderer 100 200 255)
      (set-draw-color! renderer 60 60 60))
  (fill-rect! renderer (+ 10.0 mod-spacing) mod-y mod-size mod-size)
  (set-draw-color! renderer 100 100 100)
  (draw-rect! renderer (+ 10.0 mod-spacing) mod-y mod-size mod-size)

  ;; Alt indicator
  (if (mod-alt? current-mod)
      (set-draw-color! renderer 100 255 150)
      (set-draw-color! renderer 60 60 60))
  (fill-rect! renderer (+ 10.0 (* 2 mod-spacing)) mod-y mod-size mod-size)
  (set-draw-color! renderer 100 100 100)
  (draw-rect! renderer (+ 10.0 (* 2 mod-spacing)) mod-y mod-size mod-size)

  ;; Gui/Cmd indicator
  (if (mod-gui? current-mod)
      (set-draw-color! renderer 255 150 200)
      (set-draw-color! renderer 60 60 60))
  (fill-rect! renderer (+ 10.0 (* 3 mod-spacing)) mod-y mod-size mod-size)
  (set-draw-color! renderer 100 100 100)
  (draw-rect! renderer (+ 10.0 (* 3 mod-spacing)) mod-y mod-size mod-size))

(define (main)
  (printf "Scroll Demo~n")
  (printf "===========~n")
  (printf "Use mouse wheel to scroll the virtual canvas.~n")
  (printf "Hold Shift + scroll for horizontal scrolling.~n")
  (printf "Canvas size: ~ax~a, Window: ~ax~a~n" canvas-width canvas-height window-width window-height)
  (printf "Press Escape to quit.~n~n")

  (with-sdl
    (with-window+renderer "SDL3 Scroll Demo - Use Mouse Wheel" window-width window-height (window renderer)
      (let loop ([running? #t])
    (when running?
      ;; Process events
      (define still-running?
        (for/fold ([run? #t])
                  ([ev (in-events)]
                   #:break (not run?))
          (match ev
            ;; Quit
            [(or (quit-event) (window-event 'close-requested))
             #f]

            ;; Key events - track modifiers and handle escape
            [(key-event 'down 'escape _ mod _)
             (set! current-mod mod) #f]
            [(key-event _ _ _ mod _)
             ;; Update modifier state from key event
             (set! current-mod mod) run?]

            ;; Mouse wheel - main scrolling logic
            [(mouse-wheel-event wx wy direction mx my)
             ;; Store for display
             (set! last-wheel-x wx)
             (set! last-wheel-y wy)

             ;; Apply direction (flipped means natural scrolling)
             (define mult (if (eq? direction 'flipped) -1.0 1.0))
             (define dx (* wx scroll-speed mult))
             (define dy (* wy scroll-speed mult))

             ;; Check if shift is held for horizontal scrolling
             (define shift? (mod-shift? current-mod))

             ;; Horizontal scroll from wheel X, or Shift+wheel Y
             (when (not (zero? wx))
               (set! scroll-x (+ scroll-x dx)))
             (when (and shift? (not (zero? wy)))
               ;; Shift+vertical scroll = horizontal scroll
               (set! scroll-x (- scroll-x dy)))

             ;; Vertical scroll (only when shift not held)
             (when (and (not shift?) (not (zero? wy)))
               ;; Invert Y because positive wheel = scroll up = decrease scroll-y
               (set! scroll-y (- scroll-y dy)))

             (clamp-scroll!)
             (printf "Wheel: dx=~a dy=~a dir=~a shift=~a pos=(~a,~a) scroll=(~a,~a)~n"
                     wx wy direction shift?
                     (inexact->exact (round mx)) (inexact->exact (round my))
                     (inexact->exact (round scroll-x)) (inexact->exact (round scroll-y)))
             run?]

            [_ run?])))

      (when still-running?
        ;; Clear background
        (set-draw-color! renderer 20 20 30)
        (render-clear! renderer)

        ;; Draw the scrollable canvas
        (draw-canvas! renderer)

        ;; Draw scroll info overlay
        (draw-scroll-info! renderer)

        (render-present! renderer)
        (delay! 16)
        (loop still-running?))))))

  (printf "~nFinal scroll position: (~a, ~a)~n"
          (inexact->exact (round scroll-x))
          (inexact->exact (round scroll-y))))

;; Run when executed directly
(module+ main
  (main))
