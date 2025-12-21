#lang racket/base

;; Surface Basics - demonstrates surface creation and manipulation
;;
;; - Creates a surface programmatically
;; - Draws a gradient by directly accessing pixels
;; - Converts surface to texture for display
;; - Shows surface properties (dimensions, format, pitch)

(require racket/match
         ffi/unsafe
         sdl3)

(define window-width 640)
(define window-height 480)
(define window-title "SDL3 Racket - Surface Basics")

;; Create a gradient surface by writing pixels directly
(define (create-gradient-surface width height)
  (define surf (make-surface width height #:format 'rgba32))

  ;; Access the pixel buffer
  (call-with-locked-surface
   surf
   (lambda (s pixels w h pitch)
     ;; RGBA32 = 4 bytes per pixel
     (define bpp 4)
     (for ([y (in-range h)])
       (for ([x (in-range w)])
         ;; Calculate pixel offset
         (define offset (+ (* y pitch) (* x bpp)))
         ;; Create a gradient: red increases left-to-right, blue increases top-to-bottom
         (define r (quotient (* x 255) (max 1 (sub1 w))))
         (define g 100)  ; constant green
         (define b (quotient (* y 255) (max 1 (sub1 h))))
         (define a 255)  ; fully opaque
         ;; Write RGBA bytes (ABGR8888 on little-endian = R,G,B,A byte order in memory)
         (ptr-set! pixels _uint8 offset r)
         (ptr-set! pixels _uint8 (+ offset 1) g)
         (ptr-set! pixels _uint8 (+ offset 2) b)
         (ptr-set! pixels _uint8 (+ offset 3) a)))))
  surf)

;; Create a checkerboard pattern
(define (create-checkerboard-surface width height cell-size)
  (define surf (make-surface width height #:format 'rgba32))

  (call-with-locked-surface
   surf
   (lambda (s pixels w h pitch)
     (define bpp 4)
     (for ([y (in-range h)])
       (for ([x (in-range w)])
         (define offset (+ (* y pitch) (* x bpp)))
         ;; Alternate colors based on cell position
         (define cell-x (quotient x cell-size))
         (define cell-y (quotient y cell-size))
         (define is-white? (even? (+ cell-x cell-y)))
         (define c (if is-white? 220 40))
         (ptr-set! pixels _uint8 offset c)       ; R
         (ptr-set! pixels _uint8 (+ offset 1) c) ; G
         (ptr-set! pixels _uint8 (+ offset 2) c) ; B
         (ptr-set! pixels _uint8 (+ offset 3) 255))))) ; A
  surf)

(define (main)
  (sdl-init!)

  (define-values (window renderer)
    (make-window+renderer window-title window-width window-height))

  ;; Create surfaces
  (printf "Creating gradient surface...~n")
  (define gradient-surf (create-gradient-surface 200 150))

  (printf "Creating checkerboard surface...~n")
  (define checker-surf (create-checkerboard-surface 200 150 25))

  ;; Print surface properties
  (printf "~nGradient surface properties:~n")
  (printf "  Width: ~a~n" (surface-width gradient-surf))
  (printf "  Height: ~a~n" (surface-height gradient-surf))
  (printf "  Pitch: ~a bytes/row~n" (surface-pitch gradient-surf))
  (printf "  Format: ~a~n" (surface-format gradient-surf))

  (printf "~nCheckerboard surface properties:~n")
  (printf "  Width: ~a~n" (surface-width checker-surf))
  (printf "  Height: ~a~n" (surface-height checker-surf))
  (printf "  Pitch: ~a bytes/row~n" (surface-pitch checker-surf))
  (printf "  Format: ~a~n" (surface-format checker-surf))

  ;; Duplicate the gradient surface to test duplication
  (printf "~nDuplicating gradient surface...~n")
  (define gradient-copy (duplicate-surface gradient-surf))
  (printf "Duplicate width: ~a, height: ~a~n"
          (surface-width gradient-copy)
          (surface-height gradient-copy))

  ;; Convert surfaces to textures for rendering
  (printf "~nConverting surfaces to textures...~n")
  (define gradient-tex (surface->texture renderer gradient-surf))
  (define checker-tex (surface->texture renderer checker-surf))

  (printf "Ready! Press ESC or close window to exit.~n")
  (printf "Displaying: gradient (top-left), checkerboard (top-right)~n")

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

      ;; Clear screen with dark gray
      (set-draw-color! renderer 40 40 40)
      (render-clear! renderer)

      ;; Draw gradient texture (top-left)
      (render-texture! renderer gradient-tex 50 50)

      ;; Draw checkerboard texture (top-right)
      (render-texture! renderer checker-tex 300 50)

      ;; Draw labels using debug text
      (set-draw-color! renderer 255 255 255)
      (render-debug-text! renderer 50 220 "Gradient Surface")
      (render-debug-text! renderer 300 220 "Checkerboard Surface")

      ;; Show info
      (render-debug-text! renderer 50 280 "Surface Properties:")
      (render-debug-text! renderer 50 300
        (format "Format: ~a" (surface-format gradient-surf)))
      (render-debug-text! renderer 50 320
        (format "Size: ~ax~a" (surface-width gradient-surf) (surface-height gradient-surf)))
      (render-debug-text! renderer 50 340
        (format "Pitch: ~a bytes/row" (surface-pitch gradient-surf)))

      (render-debug-text! renderer 50 400 "Press ESC to exit")

      (render-present! renderer)

      ;; Small delay to not hog CPU
      (delay! 16)

      (loop still-running?)))

  ;; Cleanup (custodians handle this automatically, but explicit for clarity)
  (surface-destroy! gradient-surf)
  (surface-destroy! checker-surf)
  (surface-destroy! gradient-copy)
  (printf "Done!~n"))

(main)
