#lang racket/base

;; Drawing Primitives Demo
;;
;; Demonstrates SDL3 drawing capabilities:
;;
;; Section 1: BUILT-IN PRIMITIVES
;; - Rectangles (filled and outline)
;; - Lines and polylines
;; - Points and point arrays
;;
;; Section 2: HARDWARE-ACCELERATED GEOMETRY
;; - Triangles with per-vertex colors
;; - Color gradient interpolation
;; - Indexed geometry for efficiency
;;
;; Controls:
;;   1 - Show basic primitives
;;   2 - Show colored triangles
;;   3 - Show indexed geometry
;;   4 - Show particle system
;;   Space - Reset particles (in particle mode)
;;   ESC - Quit

(require racket/match
         racket/format
         racket/math
         sdl3)

(define window-width 800)
(define window-height 600)
(define window-title "SDL3 Drawing Primitives Demo")

;; Demo modes
(define MODE-PRIMITIVES 1)
(define MODE-TRIANGLES 2)
(define MODE-INDEXED 3)
(define MODE-PARTICLES 4)

;; Particle system
(struct particle (x y vx vy r g b life) #:mutable)

(define particles '())
(define max-particles 200)

(define (make-random-particle)
  (particle (+ 400.0 (* 50 (- (random) 0.5)))
            (+ 300.0 (* 50 (- (random) 0.5)))
            (* 4.0 (- (random) 0.5))
            (* 4.0 (- (random) 0.5))
            (+ 0.5 (* 0.5 (random)))
            (+ 0.5 (* 0.5 (random)))
            (+ 0.5 (* 0.5 (random)))
            1.0))

(define (reset-particles!)
  (set! particles
    (for/list ([_ (in-range max-particles)])
      (make-random-particle))))

(define (update-particle! p dt)
  (set-particle-vy! p (+ (particle-vy p) (* 0.1 dt)))
  (set-particle-x! p (+ (particle-x p) (* (particle-vx p) dt)))
  (set-particle-y! p (+ (particle-y p) (* (particle-vy p) dt)))
  (set-particle-life! p (- (particle-life p) (* 0.01 dt)))
  (when (or (<= (particle-life p) 0) (> (particle-y p) 650))
    (define new-p (make-random-particle))
    (set-particle-x! p (particle-x new-p))
    (set-particle-y! p (particle-y new-p))
    (set-particle-vx! p (particle-vx new-p))
    (set-particle-vy! p (particle-vy new-p))
    (set-particle-r! p (particle-r new-p))
    (set-particle-g! p (particle-g new-p))
    (set-particle-b! p (particle-b new-p))
    (set-particle-life! p 1.0)))

;; Shape data for primitives demo
(define filled-rects '((50.0 80.0 100.0 80.0)
                       (170.0 80.0 100.0 80.0)
                       (290.0 80.0 100.0 80.0)))

(define outline-rects '((450.0 80.0 100.0 80.0)
                        (570.0 80.0 100.0 80.0)
                        (690.0 80.0 100.0 80.0)))

(define triangle '((400.0 180.0)
                   (300.0 320.0)
                   (500.0 320.0)
                   (400.0 180.0)))

(define star '((200.0 400.0)
               (240.0 500.0)
               (150.0 440.0)
               (250.0 440.0)
               (160.0 500.0)
               (200.0 400.0)))

(define grid-points
  (for*/list ([i (in-range 20)]
              [j (in-range 20)])
    (list (+ 550.0 (* i 4.0))
          (+ 380.0 (* j 4.0)))))

(define wave-points
  (for/list ([x (in-range 0 400 4)])
    (list (+ 200.0 (exact->inexact x))
          (+ 520.0 (* 30.0 (sin (* x 0.05)))))))

;; Draw primitives demo
(define (draw-primitives-demo renderer)
  (set-draw-color! renderer 40 40 40)
  (render-clear! renderer)

  ;; Title
  (set-draw-color! renderer 255 255 0)
  (render-debug-text! renderer 10 10 "BASIC PRIMITIVES - Rectangles, lines, points")

  ;; Labels
  (set-draw-color! renderer 200 200 200)
  (render-debug-text! renderer 50 60 "Filled Rects")
  (render-debug-text! renderer 450 60 "Outline Rects")

  ;; Filled rectangles (red)
  (set-draw-color! renderer 220 60 60)
  (fill-rects! renderer filled-rects)

  ;; Outline rectangles (green)
  (set-draw-color! renderer 60 220 60)
  (draw-rects! renderer outline-rects)

  ;; Triangle (cyan)
  (set-draw-color! renderer 60 220 220)
  (draw-lines! renderer triangle)
  (set-draw-color! renderer 200 200 200)
  (render-debug-text! renderer 350 330 "Polyline")

  ;; Star (yellow)
  (set-draw-color! renderer 220 220 60)
  (draw-lines! renderer star)
  (set-draw-color! renderer 200 200 200)
  (render-debug-text! renderer 165 510 "Star")

  ;; Grid of points (white)
  (set-draw-color! renderer 255 255 255)
  (draw-points! renderer grid-points)
  (set-draw-color! renderer 200 200 200)
  (render-debug-text! renderer 550 360 "Point Grid")

  ;; Sine wave (magenta)
  (set-draw-color! renderer 220 60 220)
  (draw-points! renderer wave-points)
  (set-draw-color! renderer 200 200 200)
  (render-debug-text! renderer 350 560 "Sine Wave Points")

  ;; Single filled rect (blue)
  (set-draw-color! renderer 60 60 220)
  (fill-rect! renderer 50.0 350.0 80.0 60.0)
  (set-draw-color! renderer 200 200 200)
  (render-debug-text! renderer 50 415 "Single Rect")

  ;; Single line (orange)
  (set-draw-color! renderer 220 140 60)
  (draw-line! renderer 50.0 450.0 130.0 550.0)
  (set-draw-color! renderer 200 200 200)
  (render-debug-text! renderer 50 560 "Line"))

;; Draw colored triangles demo
(define (draw-triangles-demo renderer)
  (set-draw-color! renderer 30 30 40)
  (render-clear! renderer)

  (set-draw-color! renderer 255 255 0)
  (render-debug-text! renderer 10 10 "GEOMETRY - Per-vertex colors with smooth interpolation")

  ;; Triangle 1: Red-Green-Blue gradient
  (define tri1
    (list (make-vertex 200 100  1.0 0.0 0.0)
          (make-vertex 100 300  0.0 1.0 0.0)
          (make-vertex 300 300  0.0 0.0 1.0)))
  (render-geometry! renderer tri1)

  ;; Triangle 2: Cyan-Magenta-Yellow gradient
  (define tri2
    (list (make-vertex 500 100  0.0 1.0 1.0)
          (make-vertex 400 300  1.0 0.0 1.0)
          (make-vertex 600 300  1.0 1.0 0.0)))
  (render-geometry! renderer tri2)

  ;; Triangle 3: White center fading to transparent edges
  (define tri3
    (list (make-vertex 350 400  1.0 1.0 1.0 1.0)
          (make-vertex 250 550  1.0 1.0 1.0 0.2)
          (make-vertex 450 550  1.0 1.0 1.0 0.2)))
  (render-geometry! renderer tri3)

  ;; Triangle 4: Fire colors
  (define tri4
    (list (make-vertex 650 350  1.0 1.0 0.0)
          (make-vertex 550 550  1.0 0.0 0.0)
          (make-vertex 750 550  1.0 0.5 0.0)))
  (render-geometry! renderer tri4)

  ;; Labels
  (set-draw-color! renderer 200 200 200)
  (render-debug-text! renderer 150 320 "RGB Gradient")
  (render-debug-text! renderer 450 320 "CMY Gradient")
  (render-debug-text! renderer 300 560 "Alpha Fade")
  (render-debug-text! renderer 610 560 "Fire Colors"))

;; Draw indexed quad demo
(define (draw-indexed-demo renderer frame)
  (set-draw-color! renderer 30 30 40)
  (render-clear! renderer)

  (set-draw-color! renderer 255 255 0)
  (render-debug-text! renderer 10 10 "INDEXED GEOMETRY - 4 vertices, 6 indices = 2 triangles")

  ;; Animate colors
  (define t (* frame 0.03))
  (define r1 (* 0.5 (+ 1.0 (sin t))))
  (define g1 (* 0.5 (+ 1.0 (sin (+ t 2.0)))))
  (define b1 (* 0.5 (+ 1.0 (sin (+ t 4.0)))))

  ;; Define 4 vertices for a quad
  (define vertices
    (list (make-vertex 200 150  r1 0.2 0.2)
          (make-vertex 600 150  0.2 g1 0.2)
          (make-vertex 600 450  0.2 0.2 b1)
          (make-vertex 200 450  0.8 0.8 0.2)))

  (define indices '(0 1 2  0 2 3))
  (render-geometry! renderer vertices #:indices indices)

  ;; Draw vertex labels
  (set-draw-color! renderer 255 255 255)
  (render-debug-text! renderer 180 130 "V0 (0,1,2)")
  (render-debug-text! renderer 605 150 "V1")
  (render-debug-text! renderer 605 450 "V2")
  (render-debug-text! renderer 150 450 "V3 (0,2,3)")

  ;; Explanation
  (set-draw-color! renderer 200 200 200)
  (render-debug-text! renderer 10 500 "4 vertices define corners, 6 indices define 2 triangles")
  (render-debug-text! renderer 10 515 "Triangle 1: V0-V1-V2 | Triangle 2: V0-V2-V3")
  (render-debug-text! renderer 10 530 "This is more efficient than specifying 6 vertices"))

;; Draw particle system demo
(define (draw-particles-demo renderer)
  (set-draw-color! renderer 10 10 20)
  (render-clear! renderer)

  (set-draw-color! renderer 255 255 0)
  (render-debug-text! renderer 10 10 "PARTICLE SYSTEM - Many triangles rendered efficiently")
  (render-debug-text! renderer 10 25 "Press SPACE to reset particles")

  ;; Update particles
  (for ([p (in-list particles)])
    (update-particle! p 1.0))

  ;; Build vertex list for all particles
  (define size 8.0)
  (define all-vertices
    (for/fold ([verts '()])
              ([p (in-list particles)])
      (define x (particle-x p))
      (define y (particle-y p))
      (define r (particle-r p))
      (define g (particle-g p))
      (define b (particle-b p))
      (define a (particle-life p))
      (append verts
              (list (make-vertex x (- y size) r g b a)
                    (make-vertex (- x size) (+ y size) r g b a)
                    (make-vertex (+ x size) (+ y size) r g b a)))))

  ;; Render all particles in one call
  (when (not (null? all-vertices))
    (render-geometry! renderer all-vertices))

  ;; Show particle count
  (set-draw-color! renderer 200 200 200)
  (render-debug-text! renderer 10 (- window-height 30)
                       (~a "Particles: " (length particles)
                           " | Triangles: " (length particles)
                           " | Vertices: " (* 3 (length particles)))))

(define (main)
  (sdl-init!)

  (define-values (window renderer)
    (make-window+renderer window-title window-width window-height
                          #:window-flags SDL_WINDOW_RESIZABLE))

  ;; Initialize particles
  (reset-particles!)

  (let loop ([running? #t]
             [mode MODE-PRIMITIVES]
             [frame 0])
    (when running?
      ;; Handle events
      (define-values (still-running? new-mode)
        (for/fold ([run? #t] [m mode])
                  ([ev (in-events)]
                   #:break (not run?))
          (match ev
            [(or (quit-event) (window-event 'close-requested))
             (values #f m)]

            [(key-event 'down key _ _ _)
             (cond
               [(= key SDLK_ESCAPE) (values #f m)]
               [(= key SDLK_1) (values run? MODE-PRIMITIVES)]
               [(= key SDLK_2) (values run? MODE-TRIANGLES)]
               [(= key SDLK_3) (values run? MODE-INDEXED)]
               [(= key SDLK_4) (values run? MODE-PARTICLES)]
               [(= key SDLK_SPACE)
                (when (= m MODE-PARTICLES) (reset-particles!))
                (values run? m)]
               [else (values run? m)])]

            [_ (values run? m)])))

      (when still-running?
        ;; Draw based on mode
        (case new-mode
          [(1) (draw-primitives-demo renderer)]
          [(2) (draw-triangles-demo renderer)]
          [(3) (draw-indexed-demo renderer frame)]
          [(4) (draw-particles-demo renderer)])

        ;; Draw mode selector
        (set-draw-color! renderer 150 150 150)
        (render-debug-text! renderer 10 (- window-height 15)
                             "Press 1=Primitives | 2=Triangles | 3=Indexed | 4=Particles | ESC=Quit")

        (render-present! renderer)
        (delay! 16)

        (loop still-running? new-mode (+ frame 1)))))

  (renderer-destroy! renderer)
  (window-destroy! window))

;; Run the example when executed directly
(module+ main
  (main))
