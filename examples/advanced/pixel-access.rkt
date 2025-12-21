#lang racket/base

;; Pixel Access - demonstrates reading and writing individual pixels
;;
;; - Uses surface-get-pixel and surface-set-pixel! for pixel operations
;; - Creates a gradient using the high-level pixel API
;; - Creates noise texture using bulk pixel access for performance
;; - Shows color mapping for direct buffer manipulation
;; - Demonstrates read-back of pixel values

(require racket/match
         racket/math
         sdl3)

(define window-width 640)
(define window-height 480)
(define window-title "SDL3 Racket - Pixel Access")

;; Create a gradient using the high-level surface-set-pixel! API
;; This is simple but slower for large surfaces
(define (create-gradient-high-level width height)
  (define surf (make-surface width height #:format 'rgba32))
  (for* ([y (in-range height)]
         [x (in-range width)])
    ;; Red increases left-to-right, blue increases top-to-bottom
    (define r (quotient (* x 255) (max 1 (sub1 width))))
    (define g 64)
    (define b (quotient (* y 255) (max 1 (sub1 height))))
    (surface-set-pixel! surf x y r g b))
  surf)

;; Create a noise pattern using surface-fill-pixels!
;; This is the recommended way to fill surfaces procedurally
(define (create-noise-surface width height)
  (define surf (make-surface width height #:format 'rgba32))
  (surface-fill-pixels! surf
    (lambda (x y)
      (define noise (random 256))
      (values noise noise noise 255)))
  surf)

;; Create a circle pattern using surface-fill-pixels!
(define (create-circle-surface width height)
  (define surf (make-surface width height #:format 'rgba32))
  (define cx (/ width 2.0))
  (define cy (/ height 2.0))
  (define max-r (min cx cy))
  (surface-fill-pixels! surf
    (lambda (x y)
      (define dx (- x cx))
      (define dy (- y cy))
      (define dist (sqrt (+ (* dx dx) (* dy dy))))
      (define intensity (max 0 (- 255 (exact-floor (* 255 (/ dist max-r))))))
      (values intensity 50 (- 255 intensity) 255)))
  surf)

;; Read back pixels and compute average color
(define (compute-average-color surf)
  (define w (surface-width surf))
  (define h (surface-height surf))
  (define-values (total-r total-g total-b)
    (for*/fold ([r 0] [g 0] [b 0])
               ([y (in-range 0 h 4)]  ; sample every 4th pixel for speed
                [x (in-range 0 w 4)])
      (define-values (pr pg pb pa) (surface-get-pixel surf x y))
      (values (+ r pr) (+ g pg) (+ b pb))))
  (define sample-count (* (quotient w 4) (quotient h 4)))
  (values (quotient total-r sample-count)
          (quotient total-g sample-count)
          (quotient total-b sample-count)))

(define (main)
  (sdl-init!)

  (define-values (window renderer)
    (make-window+renderer window-title window-width window-height))

  ;; Create surfaces using different methods
  (printf "Creating gradient using surface-set-pixel!...~n")
  (define gradient-surf (create-gradient-high-level 150 100))

  (printf "Creating noise using call-with-surface-pixels...~n")
  (define noise-surf (create-noise-surface 150 100))

  (printf "Creating circle pattern...~n")
  (define circle-surf (create-circle-surface 150 100))

  ;; Demonstrate pixel read-back
  (printf "~nReading pixels back from gradient surface:~n")
  (define-values (r0 g0 b0 a0) (surface-get-pixel gradient-surf 0 0))
  (printf "  Pixel at (0,0): R=~a G=~a B=~a A=~a~n" r0 g0 b0 a0)
  (define-values (r1 g1 b1 a1) (surface-get-pixel gradient-surf 149 99))
  (printf "  Pixel at (149,99): R=~a G=~a B=~a A=~a~n" r1 g1 b1 a1)

  ;; Demonstrate color mapping
  (printf "~nColor mapping demonstration:~n")
  (define red-pixel (surface-map-rgba gradient-surf 255 0 0 255))
  (printf "  Red (255,0,0,255) maps to: 0x~a~n" (number->string red-pixel 16))
  (define green-pixel (surface-map-rgba gradient-surf 0 255 0 255))
  (printf "  Green (0,255,0,255) maps to: 0x~a~n" (number->string green-pixel 16))

  ;; Compute average colors
  (printf "~nAverage colors (sampled):~n")
  (define-values (avg-r avg-g avg-b) (compute-average-color gradient-surf))
  (printf "  Gradient: R=~a G=~a B=~a~n" avg-r avg-g avg-b)

  ;; Convert to textures
  (define gradient-tex (surface->texture renderer gradient-surf))
  (define noise-tex (surface->texture renderer noise-surf))
  (define circle-tex (surface->texture renderer circle-surf))

  (printf "~nReady! Press ESC or close window to exit.~n")

  ;; Main loop
  (let loop ([running? #t])
    (when running?
      ;; Process events
      (define still-running?
        (for/fold ([run? #t])
                  ([ev (in-events)]
                   #:break (not run?))
          (match ev
            [(or (quit-event) (window-event 'close-requested))
             #f]
            [(key-event 'down 'escape _ _ _) #f]
            [(key-event 'down _ _ _ _) run?]
            [_ run?])))

      ;; Clear screen
      (set-draw-color! renderer 30 30 30)
      (render-clear! renderer)

      ;; Draw textures
      (render-texture! renderer gradient-tex 50 50)
      (render-texture! renderer noise-tex 240 50)
      (render-texture! renderer circle-tex 430 50)

      ;; Labels
      (set-draw-color! renderer 255 255 255)
      (render-debug-text! renderer 50 160 "surface-set-pixel!")
      (render-debug-text! renderer 50 175 "(Per-pixel writes)")

      (render-debug-text! renderer 240 160 "surface-fill-pixels!")
      (render-debug-text! renderer 240 175 "(Generator function)")

      (render-debug-text! renderer 430 160 "surface-fill-pixels!")
      (render-debug-text! renderer 430 175 "(Circle pattern)")

      ;; Info section
      (render-debug-text! renderer 50 220 "Pixel Access Functions:")
      (render-debug-text! renderer 50 240 "- surface-get-pixel: Read RGBA (0-255)")
      (render-debug-text! renderer 50 260 "- surface-set-pixel!: Write single pixel")
      (render-debug-text! renderer 50 280 "- surface-fill-pixels!: Fill with generator fn")
      (render-debug-text! renderer 50 300 "- surface-map-rgba: Map color to pixel value")

      (render-debug-text! renderer 50 340 "Sample pixel values:")
      (render-debug-text! renderer 50 360 (format "  Gradient (0,0): R=~a G=~a B=~a" r0 g0 b0))
      (render-debug-text! renderer 50 380 (format "  Gradient (149,99): R=~a G=~a B=~a" r1 g1 b1))

      (render-debug-text! renderer 50 420 "Press ESC to exit")

      (render-present! renderer)
      (delay! 16)

      (loop still-running?)))

  ;; Cleanup
  (surface-destroy! gradient-surf)
  (surface-destroy! noise-surf)
  (surface-destroy! circle-surf)
  (printf "Done!~n"))

(main)
