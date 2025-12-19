#lang racket/base

;; Surface I/O - demonstrates loading and saving BMP files
;;
;; - Load BMP files with load-bmp
;; - Save surfaces to BMP with save-bmp!
;; - Manipulate loaded surfaces (flip, scale, modify pixels)
;; - Display before/after comparison
;; - Also shows PNG/JPG loading/saving via SDL_image

(require racket/match
         racket/list
         racket/path
         sdl3)

(define window-width 800)
(define window-height 600)
(define window-title "SDL3 Racket - Surface I/O")

;; Create a colorful test pattern surface
(define (create-test-pattern width height)
  (define surf (make-surface width height #:format 'rgba32))
  (surface-fill-pixels! surf
    (lambda (x y)
      ;; Create a pattern with different colored quadrants
      (define half-w (quotient width 2))
      (define half-h (quotient height 2))
      (cond
        [(and (< x half-w) (< y half-h))
         ;; Top-left: red gradient
         (values (quotient (* x 255) half-w) 50 50 255)]
        [(and (>= x half-w) (< y half-h))
         ;; Top-right: green gradient
         (values 50 (quotient (* (- x half-w) 255) half-w) 50 255)]
        [(and (< x half-w) (>= y half-h))
         ;; Bottom-left: blue gradient
         (values 50 50 (quotient (* (- y half-h) 255) half-h) 255)]
        [else
         ;; Bottom-right: yellow gradient
         (define intensity (quotient (* (+ (- x half-w) (- y half-h)) 255)
                                     (+ half-w half-h)))
         (values intensity intensity 50 255)])))
  surf)

(define (main)
  (sdl-init!)

  (define-values (window renderer)
    (make-window+renderer window-title window-width window-height))

  ;; Create a test pattern and save it as BMP
  (printf "Creating test pattern...~n")
  (define original-surf (create-test-pattern 150 100))

  ;; Save to BMP
  (define bmp-path "/tmp/sdl3-test-pattern.bmp")
  (printf "Saving to BMP: ~a~n" bmp-path)
  (save-bmp! original-surf bmp-path)

  ;; Load it back
  (printf "Loading BMP back...~n")
  (define loaded-surf (load-bmp bmp-path))

  ;; Verify it loaded correctly
  (printf "Original: ~ax~a, Loaded: ~ax~a~n"
          (surface-width original-surf) (surface-height original-surf)
          (surface-width loaded-surf) (surface-height loaded-surf))

  ;; Create modified versions
  (printf "Creating modified versions...~n")

  ;; Flip horizontally
  (define flipped-surf (duplicate-surface loaded-surf))
  (flip-surface! flipped-surf 'horizontal)

  ;; Scale up 2x
  (define scaled-surf (scale-surface loaded-surf 300 200 #:mode 'nearest))

  ;; Modify pixels - invert colors
  (define inverted-surf (duplicate-surface loaded-surf))
  (for* ([y (in-range (surface-height inverted-surf))]
         [x (in-range (surface-width inverted-surf))])
    (define-values (r g b a) (surface-get-pixel inverted-surf x y))
    (surface-set-pixel! inverted-surf x y (- 255 r) (- 255 g) (- 255 b) a))

  ;; Save modified versions
  (define flipped-path "/tmp/sdl3-test-flipped.bmp")
  (define scaled-path "/tmp/sdl3-test-scaled.bmp")
  (define inverted-path "/tmp/sdl3-test-inverted.bmp")

  (save-bmp! flipped-surf flipped-path)
  (save-bmp! scaled-surf scaled-path)
  (save-bmp! inverted-surf inverted-path)
  (printf "Saved modified versions to /tmp/~n")

  ;; Also demonstrate PNG saving (via SDL_image)
  (define png-path "/tmp/sdl3-test-pattern.png")
  (save-png! original-surf png-path)
  (printf "Also saved as PNG: ~a~n" png-path)

  ;; Convert to textures for display
  (define original-tex (surface->texture renderer original-surf))
  (define loaded-tex (surface->texture renderer loaded-surf))
  (define flipped-tex (surface->texture renderer flipped-surf))
  (define scaled-tex (surface->texture renderer scaled-surf))
  (define inverted-tex (surface->texture renderer inverted-surf))

  (printf "~nReady! Press ESC or close window to exit.~n")
  (printf "Files saved to /tmp/sdl3-test-*.bmp and .png~n")

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
            [(key-event 'down key _ _ _)
             (if (= key SDLK_ESCAPE) #f run?)]
            [_ run?])))

      ;; Clear screen
      (set-draw-color! renderer 30 30 30)
      (render-clear! renderer)

      ;; Row 1: Original and loaded (should be identical)
      (render-texture! renderer original-tex 50 30)
      (render-debug-text! renderer 50 135 "Original")
      (render-debug-text! renderer 50 150 "(created)")

      (render-texture! renderer loaded-tex 220 30)
      (render-debug-text! renderer 220 135 "Loaded")
      (render-debug-text! renderer 220 150 "(from BMP)")

      ;; Show arrow between them
      (set-draw-color! renderer 100 255 100)
      (render-debug-text! renderer 205 70 ">")

      ;; Row 1 continued: Flipped
      (render-texture! renderer flipped-tex 390 30)
      (render-debug-text! renderer 390 135 "Flipped")
      (render-debug-text! renderer 390 150 "(horizontal)")

      ;; Row 1 continued: Inverted
      (render-texture! renderer inverted-tex 560 30)
      (render-debug-text! renderer 560 135 "Inverted")
      (render-debug-text! renderer 560 150 "(colors)")

      ;; Row 2: Scaled version
      (render-texture! renderer scaled-tex 50 200)
      (render-debug-text! renderer 50 405 "Scaled 2x (nearest)")

      ;; Info section
      (set-draw-color! renderer 200 200 200)
      (render-debug-text! renderer 400 200 "Surface I/O Functions:")
      (render-debug-text! renderer 400 220 "")
      (render-debug-text! renderer 400 240 "BMP (built-in SDL3):")
      (render-debug-text! renderer 400 260 "  load-bmp   - Load BMP file")
      (render-debug-text! renderer 400 280 "  save-bmp!  - Save to BMP file")
      (render-debug-text! renderer 400 300 "")
      (render-debug-text! renderer 400 320 "PNG/JPG (via SDL_image):")
      (render-debug-text! renderer 400 340 "  load-surface - Load any format")
      (render-debug-text! renderer 400 360 "  save-png!    - Save as PNG")
      (render-debug-text! renderer 400 380 "  save-jpg!    - Save as JPG")

      (render-debug-text! renderer 400 420 "Files saved to:")
      (render-debug-text! renderer 400 440 "  /tmp/sdl3-test-*.bmp")
      (render-debug-text! renderer 400 460 "  /tmp/sdl3-test-pattern.png")

      (render-debug-text! renderer 50 550 "Press ESC to exit")

      (render-present! renderer)
      (delay! 16)

      (loop still-running?)))

  ;; Cleanup (surfaces and textures cleaned up by custodian)
  (printf "Done!~n"))

(main)
