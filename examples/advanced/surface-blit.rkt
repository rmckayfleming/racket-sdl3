#lang racket/base

;; Surface Blitting - demonstrates copying regions between surfaces
;;
;; - Basic surface blitting with blit-surface!
;; - Scaled blitting with blit-surface-scaled!
;; - Surface filling with fill-surface!
;; - Surface transformations: flip-surface!, scale-surface
;; - Compositing multiple surfaces together

(require racket/match
         racket/list
         sdl3)

(define window-width 800)
(define window-height 600)
(define window-title "SDL3 Racket - Surface Blitting")

;; Create a simple pattern surface (checkerboard)
(define (create-checkerboard-surface width height tile-size color1 color2)
  (define surf (make-surface width height #:format 'rgba32))
  (surface-fill-pixels! surf
    (lambda (x y)
      (define tx (quotient x tile-size))
      (define ty (quotient y tile-size))
      (if (even? (+ tx ty))
          (values (first color1) (second color1) (third color1) 255)
          (values (first color2) (second color2) (third color2) 255))))
  surf)

;; Create a gradient surface
(define (create-gradient-surface width height)
  (define surf (make-surface width height #:format 'rgba32))
  (surface-fill-pixels! surf
    (lambda (x y)
      (define r (quotient (* x 255) (max 1 (sub1 width))))
      (define b (quotient (* y 255) (max 1 (sub1 height))))
      (values r 100 b 255)))
  surf)

;; Create a circle surface
(define (create-circle-surface size color)
  (define surf (make-surface size size #:format 'rgba32))
  (define cx (/ size 2.0))
  (define cy (/ size 2.0))
  (define radius (/ size 2.0))
  (surface-fill-pixels! surf
    (lambda (x y)
      (define dx (- x cx))
      (define dy (- y cy))
      (define dist (sqrt (+ (* dx dx) (* dy dy))))
      (if (< dist radius)
          (values (first color) (second color) (third color) 255)
          (values 0 0 0 0))))  ; transparent outside circle
  surf)

(define (main)
  (sdl-init!)

  (define-values (window renderer)
    (make-window+renderer window-title window-width window-height))

  ;; Create source surfaces
  (printf "Creating source surfaces...~n")
  (define checker-surf (create-checkerboard-surface 100 100 10 '(255 50 50) '(50 50 255)))
  (define gradient-surf (create-gradient-surface 100 100))
  (define circle-surf (create-circle-surface 80 '(50 255 50)))

  ;; Create a large canvas surface to composite onto
  (printf "Creating canvas and compositing...~n")
  (define canvas (make-surface 300 200 #:format 'rgba32))

  ;; Fill canvas with a background color
  (fill-surface! canvas '(40 40 40))

  ;; Blit checkerboard at top-left
  (blit-surface! checker-surf canvas #:dst-rect '(10 10 0 0))

  ;; Blit gradient at top-right
  (blit-surface! gradient-surf canvas #:dst-rect '(120 10 0 0))

  ;; Blit circle in the middle-bottom (overlapping both)
  (blit-surface! circle-surf canvas #:dst-rect '(60 70 0 0))

  ;; Create scaled versions using blit-surface-scaled!
  (printf "Creating scaled composites...~n")
  (define scaled-canvas (make-surface 150 100 #:format 'rgba32))
  (fill-surface! scaled-canvas '(30 30 50))
  ;; Scale down the checkerboard to fit
  (blit-surface-scaled! checker-surf scaled-canvas
                        #:dst-rect '(10 10 60 60)
                        #:scale-mode 'nearest)
  ;; Scale down the gradient with linear filtering
  (blit-surface-scaled! gradient-surf scaled-canvas
                        #:dst-rect '(80 10 60 60)
                        #:scale-mode 'linear)

  ;; Demonstrate flip-surface!
  (printf "Creating flipped surfaces...~n")
  (define flip-h-surf (duplicate-surface gradient-surf))
  (flip-surface! flip-h-surf 'horizontal)

  (define flip-v-surf (duplicate-surface gradient-surf))
  (flip-surface! flip-v-surf 'vertical)

  (define flip-both-surf (duplicate-surface gradient-surf))
  (flip-surface! flip-both-surf 'horizontal)
  (flip-surface! flip-both-surf 'vertical)

  ;; Demonstrate scale-surface (creates a new surface)
  (printf "Creating scaled surface...~n")
  (define large-checker (scale-surface checker-surf 200 200 #:mode 'nearest))

  ;; Demonstrate fill-surface! with rectangles
  (printf "Creating filled rectangle pattern...~n")
  (define rect-surf (make-surface 120 80 #:format 'rgba32))
  (fill-surface! rect-surf '(60 60 60))  ; background
  (fill-surface! rect-surf '(255 0 0) #:rect '(10 10 30 30))   ; red
  (fill-surface! rect-surf '(0 255 0) #:rect '(45 10 30 30))   ; green
  (fill-surface! rect-surf '(0 0 255) #:rect '(80 10 30 30))   ; blue
  (fill-surface! rect-surf '(255 255 0) #:rect '(10 45 100 25)) ; yellow bar

  ;; Demonstrate clear-surface! (float colors)
  (printf "Creating cleared surface...~n")
  (define clear-surf (make-surface 100 60 #:format 'rgba32))
  (clear-surface! clear-surf 0.2 0.6 0.8)  ; light blue

  ;; Convert all to textures for display
  (define canvas-tex (surface->texture renderer canvas))
  (define scaled-canvas-tex (surface->texture renderer scaled-canvas))
  (define flip-h-tex (surface->texture renderer flip-h-surf))
  (define flip-v-tex (surface->texture renderer flip-v-surf))
  (define flip-both-tex (surface->texture renderer flip-both-surf))
  (define large-checker-tex (surface->texture renderer large-checker))
  (define rect-tex (surface->texture renderer rect-surf))
  (define clear-tex (surface->texture renderer clear-surf))
  (define gradient-tex (surface->texture renderer gradient-surf))

  (printf "~nReady! Press ESC or close window to exit.~n")

  ;; Main loop
  (let loop ([running? #t])
    (when running?
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
      (set-draw-color! renderer 25 25 25)
      (render-clear! renderer)

      ;; Row 1: Composited canvas and scaled version
      (render-texture! renderer canvas-tex 20 20)
      (render-debug-text! renderer 20 225 "blit-surface! composite")

      (render-texture! renderer scaled-canvas-tex 340 20)
      (render-debug-text! renderer 340 125 "blit-surface-scaled!")
      (render-debug-text! renderer 340 140 "(nearest & linear)")

      ;; Row 2: Flip demonstrations
      (render-texture! renderer gradient-tex 20 270)
      (render-debug-text! renderer 20 375 "Original")

      (render-texture! renderer flip-h-tex 130 270)
      (render-debug-text! renderer 130 375 "flip 'horizontal")

      (render-texture! renderer flip-v-tex 240 270)
      (render-debug-text! renderer 240 375 "flip 'vertical")

      (render-texture! renderer flip-both-tex 350 270)
      (render-debug-text! renderer 350 375 "flip h + v")

      ;; Row 2 continued: fill and clear
      (render-texture! renderer rect-tex 480 270)
      (render-debug-text! renderer 480 355 "fill-surface!")
      (render-debug-text! renderer 480 370 "(rectangles)")

      (render-texture! renderer clear-tex 620 270)
      (render-debug-text! renderer 620 335 "clear-surface!")
      (render-debug-text! renderer 620 350 "(float colors)")

      ;; Row 3: Large scaled surface
      (render-texture! renderer large-checker-tex 520 20)
      (render-debug-text! renderer 520 225 "scale-surface 2x")
      (render-debug-text! renderer 520 240 "(new surface)")

      ;; Info
      (set-draw-color! renderer 200 200 200)
      (render-debug-text! renderer 20 420 "Surface Blitting Functions:")
      (render-debug-text! renderer 20 440 "- blit-surface!: Copy surface region to another surface")
      (render-debug-text! renderer 20 460 "- blit-surface-scaled!: Copy with scaling (nearest/linear)")
      (render-debug-text! renderer 20 480 "- fill-surface!: Fill surface/rectangle with color")
      (render-debug-text! renderer 20 500 "- clear-surface!: Clear with float colors (0.0-1.0)")
      (render-debug-text! renderer 20 520 "- flip-surface!: Flip in place (horizontal/vertical)")
      (render-debug-text! renderer 20 540 "- scale-surface: Create new scaled surface")

      (render-debug-text! renderer 20 570 "Press ESC to exit")

      (render-present! renderer)
      (delay! 16)

      (loop still-running?)))

  ;; Cleanup (surfaces and textures cleaned up by custodian)
  (printf "Done!~n"))

(main)
