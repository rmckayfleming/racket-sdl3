#lang racket/base

;; Render Target Demo - demonstrates off-screen rendering to textures
;;
;; This example shows how to:
;; - Create a texture that can be used as a render target
;; - Draw to the texture once (caching complex drawing)
;; - Render the cached texture multiple times with different transforms
;;
;; Controls:
;;   R - Regenerate the pattern on the texture
;;   1 - Nearest neighbor scaling (pixelated)
;;   2 - Linear scaling (smooth)
;;   ESC - Quit

(require racket/match
         sdl3/safe)

(define window-width 800)
(define window-height 600)
(define window-title "SDL3 Render Target Demo")

;; Size of the off-screen texture
(define texture-size 128)

;; Draw a colorful pattern to the current render target
(define (draw-pattern! renderer size)
  ;; Clear to transparent
  (set-draw-color! renderer 0 0 0 0)
  (render-clear! renderer)

  ;; Draw a colorful grid pattern
  (define cell-size (/ size 8))
  (for* ([row (in-range 8)]
         [col (in-range 8)])
    (define x (* col cell-size))
    (define y (* row cell-size))
    ;; Alternating colors based on position
    (define r (+ 50 (* row 25)))
    (define g (+ 50 (* col 25)))
    (define b (+ 100 (* (+ row col) 10)))
    (set-draw-color! renderer r g b 255)
    (fill-rect! renderer x y cell-size cell-size))

  ;; Draw a circle-ish shape in the center
  (set-draw-color! renderer 255 255 100 255)
  (define center (/ size 2))
  (define radius (/ size 4))
  (for ([angle (in-range 0 360 10)])
    (define rad (* angle (/ 3.14159 180)))
    (define x (+ center (* radius (cos rad))))
    (define y (+ center (* radius (sin rad))))
    (fill-rect! renderer (- x 3) (- y 3) 6 6))

  ;; Draw border
  (set-draw-color! renderer 255 255 255 255)
  (draw-rect! renderer 0 0 size size))

(define (main)
  (sdl-init!)

  (define-values (window renderer)
    (make-window+renderer window-title window-width window-height
                          #:window-flags SDL_WINDOW_HIGH_PIXEL_DENSITY))

  ;; Create an off-screen texture that can be rendered to
  (define target-texture
    (create-texture renderer texture-size texture-size
                    #:access 'target    ; Enable use as render target
                    #:scale 'nearest))  ; Start with pixelated scaling

  ;; Enable alpha blending for the texture
  (set-texture-blend-mode! target-texture 'blend)

  ;; Draw the initial pattern to the texture
  (with-render-target renderer target-texture
    (draw-pattern! renderer texture-size))

  ;; Animation state
  (define start-time (SDL-GetTicks))

  (let loop ([running? #t]
             [current-scale 'nearest])
    (when running?
      ;; Handle events
      (define-values (still-running? new-scale)
        (for/fold ([run? #t] [scale current-scale])
                  ([ev (in-events)]
                   #:break (not run?))
          (match ev
            [(or (quit-event) (window-event 'close-requested))
             (values #f scale)]
            [(key-event 'down key _ _ _)
             (cond
               [(= key SDLK_ESCAPE) (values #f scale)]
               [(= key SDLK_R)
                ;; Regenerate the pattern
                (with-render-target renderer target-texture
                  (draw-pattern! renderer texture-size))
                (values run? scale)]
               [(= key SDLK_1)
                (texture-set-scale-mode! target-texture 'nearest)
                (values run? 'nearest)]
               [(= key SDLK_2)
                (texture-set-scale-mode! target-texture 'linear)
                (values run? 'linear)]
               [else (values run? scale)])]
            [_ (values run? scale)])))

      (when still-running?
        ;; Calculate animation time
        (define elapsed (/ (- (SDL-GetTicks) start-time) 1000.0))

        ;; Clear the window
        (set-draw-color! renderer 40 40 60)
        (render-clear! renderer)

        ;; Render the cached texture multiple times with different transforms
        ;; This demonstrates the performance benefit of render-to-texture:
        ;; The pattern is drawn once, then rendered many times efficiently

        ;; 1. Original size in top-left
        (render-texture! renderer target-texture 20 20)

        ;; 2. Scaled up 2x
        (render-texture! renderer target-texture 170 20
                         #:width (* texture-size 2)
                         #:height (* texture-size 2))

        ;; 3. Rotating version
        (define angle (* elapsed 45))  ; 45 degrees per second
        (render-texture! renderer target-texture 550 100
                         #:width (* texture-size 1.5)
                         #:height (* texture-size 1.5)
                         #:angle angle
                         #:center (cons (* texture-size 0.75) (* texture-size 0.75)))

        ;; 4. Multiple small copies in a row
        (for ([i (in-range 6)])
          (define x (+ 20 (* i 70)))
          (define y 350)
          (define scale (+ 0.3 (* 0.1 (sin (+ elapsed (* i 0.5))))))
          (define w (* texture-size scale))
          (define h (* texture-size scale))
          (render-texture! renderer target-texture x y
                           #:width w #:height h))

        ;; 5. Stretched versions
        (render-texture! renderer target-texture 500 350
                         #:width (* texture-size 2)
                         #:height (/ texture-size 2))

        (render-texture! renderer target-texture 500 430
                         #:width (/ texture-size 2)
                         #:height (* texture-size 1.5))

        ;; Draw UI text (simple rectangles as we don't have font in this example)
        (set-draw-color! renderer 255 255 255 200)

        ;; Scale mode indicator
        (set-draw-color! renderer
                         (if (eq? new-scale 'nearest) 255 100)
                         (if (eq? new-scale 'linear) 255 100)
                         100)
        (fill-rect! renderer 20 550 200 30)

        (set-draw-color! renderer 0 0 0)
        ;; Simple text indicator using rectangles
        ;; "1" or "2" to indicate mode
        (if (eq? new-scale 'nearest)
            (fill-rect! renderer 30 555 5 20)   ; "1"
            (begin
              (fill-rect! renderer 30 555 10 5)   ; "2" top
              (fill-rect! renderer 35 555 5 10)   ; "2" right-top
              (fill-rect! renderer 30 560 10 5)   ; "2" middle
              (fill-rect! renderer 25 560 5 10)   ; "2" left-bottom
              (fill-rect! renderer 25 570 15 5))) ; "2" bottom

        (render-present! renderer)
        (delay! 16)

        (loop still-running? new-scale))))

  ;; Clean up
  (texture-destroy! target-texture)
  (renderer-destroy! renderer)
  (window-destroy! window))

;; Run the example when executed directly
(module+ main
  (main))
