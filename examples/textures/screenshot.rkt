#lang racket/base

;; Screenshot Example - demonstrates image saving with IMG_SavePNG/JPG
;;
;; - Press S to save a PNG screenshot
;; - Press J to save a JPG screenshot
;; - Screenshots are saved to the current directory

(require racket/format
         racket/match
         sdl3)

(define window-width 800)
(define window-height 600)
(define window-title "SDL3 Racket - Screenshot Example")

;; Draw a colorful scene for the screenshot
(define (draw-scene! renderer ticks)
  ;; Background gradient effect using vertical lines
  (for ([x (in-range 0 window-width 4)])
    (define hue (modulo (+ x (quotient ticks 10)) 360))
    (define-values (r g b) (hsv->rgb hue 0.7 0.3))
    (set-draw-color! renderer r g b)
    (draw-line! renderer x 0 x window-height))

  ;; Draw some animated shapes
  (define cx (/ window-width 2))
  (define cy (/ window-height 2))

  ;; Rotating squares
  (for ([i (in-range 8)])
    (define angle (+ (* i 45) (/ ticks 20.0)))
    (define radius (+ 100 (* i 20)))
    (define size (- 60 (* i 5)))
    (define x (+ cx (* radius (cos (* angle (/ 3.14159 180))))))
    (define y (+ cy (* radius (sin (* angle (/ 3.14159 180))))))
    (define hue (modulo (+ (* i 45) (quotient ticks 5)) 360))
    (define-values (r g b) (hsv->rgb hue 1.0 1.0))
    (set-draw-color! renderer r g b)
    (fill-rect! renderer (- x (/ size 2)) (- y (/ size 2)) size size))

  ;; Center circle (drawn as filled rects to approximate)
  (set-draw-color! renderer 255 255 255)
  (for ([dy (in-range -50 51)])
    (define dx (sqrt (max 0 (- 2500 (* dy dy)))))
    (when (> dx 0)
      (draw-line! renderer (- cx dx) (+ cy dy) (+ cx dx) (+ cy dy))))

  ;; Instructions text area
  (set-draw-color! renderer 0 0 0 180)
  (fill-rect! renderer 10 10 200 60)
  (set-draw-color! renderer 255 255 255)
  (draw-rect! renderer 10 10 200 60))

;; Simple HSV to RGB conversion
(define (hsv->rgb h s v)
  (define c (* v s))
  (define h-prime (/ h 60.0))
  (define x (* c (- 1 (abs (- (- h-prime (* 2 (floor (/ h-prime 2)))) 1)))))
  (define m (- v c))
  (define-values (r1 g1 b1)
    (cond
      [(< h 60)  (values c x 0)]
      [(< h 120) (values x c 0)]
      [(< h 180) (values 0 c x)]
      [(< h 240) (values 0 x c)]
      [(< h 300) (values x 0 c)]
      [else      (values c 0 x)]))
  (values (inexact->exact (round (* 255 (+ r1 m))))
          (inexact->exact (round (* 255 (+ g1 m))))
          (inexact->exact (round (* 255 (+ b1 m))))))

;; Generate a unique filename with timestamp
(define (make-filename ext)
  (define now (current-seconds))
  (~a "screenshot-" now "." ext))

(define (main)
  (sdl-init!)

  (define-values (window renderer)
    (make-window+renderer window-title window-width window-height))

  (define screenshot-count 0)

  (let loop ([running? #t])
    (when running?
      (define ticks (current-ticks))

      ;; Process events
      (define-values (still-running? save-png? save-jpg?)
        (for/fold ([run? #t] [png? #f] [jpg? #f])
                  ([ev (in-events)]
                   #:break (not run?))
          (match ev
            [(or (quit-event) (window-event 'close-requested))
             (values #f #f #f)]
            [(key-event 'down 'escape _ _ _) (values #f #f #f)]

            [(key-event 'down 's _ _ _) (values run? #t jpg?)]

            [(key-event 'down 'j _ _ _) (values run? png? #t)]
            [_ (values run? png? jpg?)])))

      (when still-running?
        ;; Clear and draw scene
        (set-draw-color! renderer 0 0 0)
        (render-clear! renderer)
        (draw-scene! renderer ticks)
        (render-present! renderer)

        ;; Save screenshots if requested
        (when save-png?
          (define filename (make-filename "png"))
          (define surface (render-read-pixels renderer))
          (save-png! surface filename)
          (surface-destroy! surface)
          (set! screenshot-count (add1 screenshot-count))
          (printf "Saved PNG: ~a\n" filename))

        (when save-jpg?
          (define filename (make-filename "jpg"))
          (define surface (render-read-pixels renderer))
          (save-jpg! surface filename 90)
          (surface-destroy! surface)
          (set! screenshot-count (add1 screenshot-count))
          (printf "Saved JPG: ~a\n" filename))

        (delay! 16)
        (loop still-running?))))

  (printf "Total screenshots saved: ~a\n" screenshot-count)

  ;; Clean up
  (renderer-destroy! renderer)
  (window-destroy! window))

;; Run the example when executed directly
(module+ main
  (main))
