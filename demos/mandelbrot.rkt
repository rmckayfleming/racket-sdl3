#lang racket/base

;; Mandelbrot Set Explorer
;;
;; An interactive fractal renderer demonstrating surface pixel manipulation.
;; Uses surface-fill-pixels! for procedural texture generation.
;;
;; Controls:
;;   Arrow keys - Pan the view
;;   +/- or scroll wheel - Zoom in/out
;;   Click - Center view on clicked point
;;   R - Reset to default view
;;   C - Cycle color palettes
;;   S - Save screenshot as PNG
;;   I - Toggle info display
;;   ESC - Quit

(require racket/match
         racket/format
         racket/math
         racket/unsafe/ops
         sdl3)

(define window-width 800)
(define window-height 600)
(define window-title "Mandelbrot Set Explorer")

;; Maximum iterations for escape detection
(define max-iterations 256)

;; View state (complex plane coordinates)
(define default-center-x -0.5)
(define default-center-y 0.0)
(define default-zoom 1.0)  ; 1.0 means 4 units wide

;; Color palettes
(define palettes
  (vector
   ;; Classic blue-yellow
   (lambda (iter max-iter)
     (if (= iter max-iter)
         (values 0 0 0 255)  ; Black for points in the set
         (let* ([t (/ iter max-iter)]
                [r (exact-floor (* 255 (* 9 (- 1 t) t t t)))]
                [g (exact-floor (* 255 (* 15 (- 1 t) (- 1 t) t t)))]
                [b (exact-floor (* 255 (* 8.5 (- 1 t) (- 1 t) (- 1 t) t)))])
           (values (min 255 r) (min 255 g) (min 255 b) 255))))
   ;; Fire
   (lambda (iter max-iter)
     (if (= iter max-iter)
         (values 0 0 0 255)
         (let* ([t (/ iter max-iter)]
                [r (exact-floor (* 255 (min 1.0 (* t 3))))]
                [g (exact-floor (* 255 (max 0.0 (min 1.0 (- (* t 3) 1)))))]
                [b (exact-floor (* 255 (max 0.0 (- (* t 3) 2))))])
           (values r g b 255))))
   ;; Grayscale
   (lambda (iter max-iter)
     (if (= iter max-iter)
         (values 0 0 0 255)
         (let ([v (exact-floor (* 255 (/ iter max-iter)))])
           (values v v v 255))))
   ;; Rainbow
   (lambda (iter max-iter)
     (if (= iter max-iter)
         (values 0 0 0 255)
         (let* ([t (* 6.0 (/ iter max-iter))]
                [i (exact-floor t)]
                [f (- t i)]
                [q (- 1.0 f)])
           (case (modulo i 6)
             [(0) (values 255 (exact-floor (* 255 f)) 0 255)]
             [(1) (values (exact-floor (* 255 q)) 255 0 255)]
             [(2) (values 0 255 (exact-floor (* 255 f)) 255)]
             [(3) (values 0 (exact-floor (* 255 q)) 255 255)]
             [(4) (values (exact-floor (* 255 f)) 0 255 255)]
             [(5) (values 255 0 (exact-floor (* 255 q)) 255)]))))
   ;; Ocean
   (lambda (iter max-iter)
     (if (= iter max-iter)
         (values 0 0 0 255)
         (let* ([t (/ iter max-iter)]
                [r (exact-floor (* 255 (* t t)))]
                [g (exact-floor (* 255 t))]
                [b (exact-floor (* 255 (sqrt t)))])
           (values r g b 255))))))

(define palette-names
  (vector "Classic" "Fire" "Grayscale" "Rainbow" "Ocean"))

;; Compute Mandelbrot iteration count for a point
;; Uses unsafe operations for ~9x performance improvement
(define (mandelbrot-iterations cx cy max-iter)
  (let loop ([zx 0.0] [zy 0.0] [iter 0])
    (define zx2 (unsafe-fl* zx zx))
    (define zy2 (unsafe-fl* zy zy))
    (if (or (unsafe-fx>= iter max-iter)
            (unsafe-fl> (unsafe-fl+ zx2 zy2) 4.0))
        iter
        (let ([new-zx (unsafe-fl+ (unsafe-fl- zx2 zy2) cx)]
              [new-zy (unsafe-fl+ (unsafe-fl* 2.0 (unsafe-fl* zx zy)) cy)])
          (loop new-zx new-zy (unsafe-fx+ iter 1))))))

;; Render Mandelbrot set to a surface
;; Precomputes coordinate mapping for performance
(define (render-mandelbrot! surf center-x center-y zoom palette-fn)
  (define w (surface-width surf))
  (define h (surface-height surf))
  (define aspect (/ w h))
  (define half-width (* 2.0 (/ 1.0 zoom)))
  (define half-height (/ half-width aspect))
  (define min-x (exact->inexact (- center-x half-width)))
  (define max-x (exact->inexact (+ center-x half-width)))
  (define min-y (exact->inexact (- center-y half-height)))
  (define max-y (exact->inexact (+ center-y half-height)))
  ;; Precompute coordinate scaling factors
  (define x-scale (unsafe-fl/ (unsafe-fl- max-x min-x) (exact->inexact (sub1 w))))
  (define y-scale (unsafe-fl/ (unsafe-fl- max-y min-y) (exact->inexact (sub1 h))))

  (surface-fill-pixels! surf
    (lambda (px py)
      ;; Map pixel to complex plane using precomputed scale
      (define cx (unsafe-fl+ min-x (unsafe-fl* (exact->inexact px) x-scale)))
      (define cy (unsafe-fl+ min-y (unsafe-fl* (exact->inexact py) y-scale)))
      ;; Compute iterations and map to color
      (define iter (mandelbrot-iterations cx cy max-iterations))
      (palette-fn iter max-iterations))))

;; Convert screen coordinates to complex plane coordinates
(define (screen->complex px py center-x center-y zoom width height)
  (define aspect (/ width height))
  (define half-width (* 2.0 (/ 1.0 zoom)))
  (define half-height (/ half-width aspect))
  (define cx (+ (- center-x half-width) (* (/ px width) half-width 2)))
  (define cy (+ (- center-y half-height) (* (/ py height) half-height 2)))
  (values cx cy))

(define (main)
  (printf "Mandelbrot Set Explorer~n")
  (printf "Controls: Arrows=Pan, +/-/Scroll=Zoom, Click=Center, R=Reset, C=Colors, S=Save~n")
  (flush-output)

  (with-sdl
    (with-window+renderer window-title window-width window-height (window renderer)
      ;; Create surface for rendering
      (define surf (make-surface window-width window-height #:format 'rgba32))

      ;; View state
      (define center-x default-center-x)
      (define center-y default-center-y)
      (define zoom default-zoom)
      (define palette-idx 0)
      (define show-info? #t)
      (define needs-render? #t)

      ;; Texture for display
      (define tex #f)

      ;; Main loop
      (let loop ([running? #t])
    (when running?
      ;; Re-render if needed
      (when needs-render?
        (printf "Rendering at (~a, ~a) zoom=~a...~n"
                (~r center-x #:precision 6)
                (~r center-y #:precision 6)
                (~r zoom #:precision 2))
        (flush-output)
        (define palette-fn (vector-ref palettes palette-idx))
        (render-mandelbrot! surf center-x center-y zoom palette-fn)
        ;; Update texture
        (when tex (texture-destroy! tex))
        (set! tex (surface->texture renderer surf))
        (set! needs-render? #f)
        (printf "Done.~n")
        (flush-output))

      ;; Process events
      (define-values (still-running? new-render?)
        (for/fold ([run? #t] [render? #f])
                  ([ev (in-events)]
                   #:break (not run?))
          (match ev
            [(or (quit-event) (window-event 'close-requested))
             (values #f render?)]

            [(key-event 'down 'escape _ _ _)
             (values #f render?)]

            ;; Pan with arrow keys
            [(key-event 'down 'left _ _ _)
             (define pan-amount (/ 0.2 zoom))
             (set! center-x (- center-x pan-amount))
             (values run? #t)]
            [(key-event 'down 'right _ _ _)
             (define pan-amount (/ 0.2 zoom))
             (set! center-x (+ center-x pan-amount))
             (values run? #t)]
            [(key-event 'down 'up _ _ _)
             (define pan-amount (/ 0.2 zoom))
             (set! center-y (- center-y pan-amount))
             (values run? #t)]
            [(key-event 'down 'down _ _ _)
             (define pan-amount (/ 0.2 zoom))
             (set! center-y (+ center-y pan-amount))
             (values run? #t)]

            ;; Zoom with +/-
            [(key-event 'down (or 'equals 'kp-plus) _ _ _)
             (set! zoom (* zoom 1.5))
             (values run? #t)]
            [(key-event 'down (or 'minus 'kp-minus) _ _ _)
             (set! zoom (max 0.1 (/ zoom 1.5)))
             (values run? #t)]

            ;; Reset view
            [(key-event 'down 'r _ _ _)
             (set! center-x default-center-x)
             (set! center-y default-center-y)
             (set! zoom default-zoom)
             (printf "View reset~n")
             (values run? #t)]

            ;; Cycle palettes
            [(key-event 'down 'c _ _ _)
             (set! palette-idx (modulo (+ palette-idx 1) (vector-length palettes)))
             (printf "Palette: ~a~n" (vector-ref palette-names palette-idx))
             (values run? #t)]

            ;; Toggle info
            [(key-event 'down 'i _ _ _)
             (set! show-info? (not show-info?))
             (values run? render?)]

            ;; Save screenshot
            [(key-event 'down 's _ _ _)
             (define filename (format "mandelbrot-~a.png" (current-seconds)))
             (save-png! surf filename)
             (printf "Saved: ~a~n" filename)
             (values run? render?)]

            [(key-event 'down _ _ _ _)
             (values run? render?)]

            ;; Click to center on point
            [(mouse-button-event 'down 'left mx my _)
             (define-values (cx cy)
               (screen->complex mx my center-x center-y zoom window-width window-height))
             (set! center-x cx)
             (set! center-y cy)
             (printf "Centered on (~a, ~a)~n" (~r cx #:precision 6) (~r cy #:precision 6))
             (values run? #t)]

            ;; Scroll to zoom
            [(mouse-wheel-event _ wy _ _ _)
             (cond
               [(> wy 0)
                (set! zoom (* zoom 1.2))
                (values run? #t)]
               [(< wy 0)
                (set! zoom (max 0.1 (/ zoom 1.2)))
                (values run? #t)]
               [else (values run? render?)])]

            [_ (values run? render?)])))

      (when still-running?
        (set! needs-render? (or needs-render? new-render?))

        ;; Draw
        (set-draw-color! renderer 0 0 0)
        (render-clear! renderer)

        ;; Draw fractal
        (when tex
          (render-texture! renderer tex 0 0))

        ;; Draw info overlay
        (when show-info?
          ;; Semi-transparent background for text
          (set-draw-color! renderer 0 0 0 180)
          (fill-rect! renderer 5 5 300 90)

          (set-draw-color! renderer 255 255 255)
          (render-debug-text! renderer 10 10
            (format "Center: ~a, ~a"
                    (~r center-x #:precision 8)
                    (~r center-y #:precision 8)))
          (render-debug-text! renderer 10 25
            (format "Zoom: ~ax" (~r zoom #:precision 2)))
          (render-debug-text! renderer 10 40
            (format "Palette: ~a (C to change)" (vector-ref palette-names palette-idx)))
          (render-debug-text! renderer 10 55
            "Arrows=Pan +/-=Zoom Click=Center")
          (render-debug-text! renderer 10 70
            "R=Reset S=Save I=Toggle info"))

        (render-present! renderer)
        (delay! 16)

        (loop still-running?)))

      ;; Cleanup
      (when tex (texture-destroy! tex))
      (surface-destroy! surf)
      (printf "Goodbye!~n")))))

(module+ main
  (main))
