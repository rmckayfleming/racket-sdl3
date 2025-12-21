#lang racket/base

;; Surface Advanced Features - demonstrates color key, modulation, blend modes, and clipping
;;
;; - Color key for sprite transparency
;; - Color modulation (tinting) during blit operations
;; - Alpha modulation for fading effects
;; - Blend modes for compositing
;; - Clipping regions

(require racket/match
         racket/list
         sdl3)

(define window-width 800)
(define window-height 600)
(define window-title "SDL3 Racket - Surface Advanced Features")

;; Create a sprite surface with a solid background color
(define (create-sprite-surface size bg-color fg-color)
  (define surf (make-surface size size #:format 'rgba32))
  ;; Fill with background color
  (fill-surface! surf bg-color)
  ;; Draw a simple shape (diamond) in the foreground color
  (define half (quotient size 2))
  (for ([y (in-range size)])
    (define dy (abs (- y half)))
    (for ([x (in-range size)])
      (define dx (abs (- x half)))
      (when (< (+ dx dy) half)
        (surface-set-pixel! surf x y
                            (first fg-color)
                            (second fg-color)
                            (third fg-color)
                            255))))
  surf)

;; Create a gradient background surface
(define (create-gradient-background width height)
  (define surf (make-surface width height #:format 'rgba32))
  (surface-fill-pixels! surf
    (lambda (x y)
      (define r (quotient (* y 100) height))
      (define g (quotient (* y 100) height))
      (define b (+ 50 (quotient (* y 150) height)))
      (values r g b 255)))
  surf)

(define (main)
  (sdl-init!)

  (define-values (window renderer)
    (make-window+renderer window-title window-width window-height))

  ;; Create source sprite with magenta background (will be transparent)
  (printf "Creating sprites...~n")
  (define sprite-size 60)
  (define magenta-bg '(255 0 255))  ; Magenta will be the transparent color
  (define yellow-fg '(255 255 0))

  (define sprite1 (create-sprite-surface sprite-size magenta-bg yellow-fg))
  (define sprite2 (create-sprite-surface sprite-size magenta-bg '(0 255 255)))
  (define sprite3 (create-sprite-surface sprite-size magenta-bg '(255 128 0)))

  ;; Create a sprite without color key for comparison
  (define sprite-no-key (duplicate-surface sprite1))

  ;; Create gradient background
  (define bg-surf (create-gradient-background 180 120))

  ;; Demo 1: Color Key
  (printf "Setting up color key demo...~n")
  (define ck-canvas (make-surface 180 120 #:format 'rgba32))
  (blit-surface! bg-surf ck-canvas)

  ;; Blit sprite WITHOUT color key
  (define sprite-without-ck (duplicate-surface sprite1))
  (blit-surface! sprite-without-ck ck-canvas #:dst-rect '(10 30 0 0))

  ;; Set color key and blit sprite WITH color key
  (define sprite-with-ck (duplicate-surface sprite1))
  (set-surface-color-key! sprite-with-ck magenta-bg)
  (printf "  Color key set: ~a~n" (surface-has-color-key? sprite-with-ck))
  (blit-surface! sprite-with-ck ck-canvas #:dst-rect '(100 30 0 0))

  ;; Demo 2: Color Modulation (Tinting)
  (printf "Setting up color modulation demo...~n")
  (define cm-canvas (make-surface 280 120 #:format 'rgba32))
  (fill-surface! cm-canvas '(40 40 40))

  ;; Original sprite (with color key)
  (define cm-sprite1 (duplicate-surface sprite1))
  (set-surface-color-key! cm-sprite1 magenta-bg)
  (blit-surface! cm-sprite1 cm-canvas #:dst-rect '(10 30 0 0))

  ;; Red tinted sprite
  (define cm-sprite2 (duplicate-surface sprite1))
  (set-surface-color-key! cm-sprite2 magenta-bg)
  (set-surface-color-mod! cm-sprite2 255 100 100)  ; Red tint
  (blit-surface! cm-sprite2 cm-canvas #:dst-rect '(80 30 0 0))

  ;; Green tinted sprite
  (define cm-sprite3 (duplicate-surface sprite1))
  (set-surface-color-key! cm-sprite3 magenta-bg)
  (set-surface-color-mod! cm-sprite3 100 255 100)  ; Green tint
  (blit-surface! cm-sprite3 cm-canvas #:dst-rect '(150 30 0 0))

  ;; Blue tinted sprite
  (define cm-sprite4 (duplicate-surface sprite1))
  (set-surface-color-key! cm-sprite4 magenta-bg)
  (set-surface-color-mod! cm-sprite4 100 100 255)  ; Blue tint
  (blit-surface! cm-sprite4 cm-canvas #:dst-rect '(220 30 0 0))

  ;; Demo 3: Alpha Modulation (Fading)
  (printf "Setting up alpha modulation demo...~n")
  (define am-canvas (make-surface 350 120 #:format 'rgba32))
  (blit-surface! bg-surf am-canvas)
  (blit-surface! bg-surf am-canvas #:dst-rect '(180 0 0 0))

  ;; Different alpha levels (need blend mode for alpha to work)
  (for ([i (in-range 5)])
    (define am-sprite (duplicate-surface sprite1))
    (set-surface-color-key! am-sprite magenta-bg)
    (set-surface-blend-mode! am-sprite 'blend)
    (set-surface-alpha-mod! am-sprite (- 255 (* i 50)))  ; 255, 205, 155, 105, 55
    (blit-surface! am-sprite am-canvas #:dst-rect (list (+ 10 (* i 70)) 30 0 0)))

  ;; Demo 4: Blend Modes
  (printf "Setting up blend mode demo...~n")
  (define bm-canvas (make-surface 350 120 #:format 'rgba32))
  (blit-surface! bg-surf bm-canvas)
  (blit-surface! bg-surf bm-canvas #:dst-rect '(180 0 0 0))

  ;; Different blend modes
  (define blend-modes '(none blend add mod mul))
  (for ([mode blend-modes]
        [i (in-naturals)])
    (define bm-sprite (duplicate-surface sprite2))
    (set-surface-color-key! bm-sprite magenta-bg)
    (set-surface-blend-mode! bm-sprite mode)
    (blit-surface! bm-sprite bm-canvas #:dst-rect (list (+ 10 (* i 70)) 30 0 0)))

  ;; Demo 5: Clipping
  (printf "Setting up clipping demo...~n")
  (define clip-canvas (make-surface 200 120 #:format 'rgba32))
  (fill-surface! clip-canvas '(60 60 60))

  ;; Draw full sprite on left side
  (define clip-sprite1 (duplicate-surface sprite3))
  (set-surface-color-key! clip-sprite1 magenta-bg)
  (blit-surface! clip-sprite1 clip-canvas #:dst-rect '(20 30 0 0))

  ;; Set clip rect and draw sprite - only portion inside clip rect appears
  (set-surface-clip-rect! clip-canvas '(110 40 50 50))
  (define clip-sprite2 (duplicate-surface sprite3))
  (set-surface-color-key! clip-sprite2 magenta-bg)
  (blit-surface! clip-sprite2 clip-canvas #:dst-rect '(100 30 0 0))

  ;; Check clip rect
  (printf "  Clip rect: ~a~n" (surface-clip-rect clip-canvas))

  ;; Reset clip rect
  (set-surface-clip-rect! clip-canvas #f)

  ;; Convert all canvases to textures
  (define ck-tex (surface->texture renderer ck-canvas))
  (define cm-tex (surface->texture renderer cm-canvas))
  (define am-tex (surface->texture renderer am-canvas))
  (define bm-tex (surface->texture renderer bm-canvas))
  (define clip-tex (surface->texture renderer clip-canvas))

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

      ;; Row 1: Color Key demo
      (render-texture! renderer ck-tex 20 20)
      (render-debug-text! renderer 20 145 "Color Key (transparency)")
      (render-debug-text! renderer 20 160 "Left: no key  Right: magenta=transparent")

      ;; Row 1: Color Modulation demo
      (render-texture! renderer cm-tex 220 20)
      (render-debug-text! renderer 220 145 "Color Modulation (tinting)")
      (render-debug-text! renderer 220 160 "Original  Red  Green  Blue")

      ;; Row 2: Alpha Modulation demo
      (render-texture! renderer am-tex 20 200)
      (render-debug-text! renderer 20 325 "Alpha Modulation (fading)")
      (render-debug-text! renderer 20 340 "255  205  155  105  55")

      ;; Row 2: Blend Modes demo
      (render-texture! renderer bm-tex 400 200)
      (render-debug-text! renderer 400 325 "Blend Modes")
      (render-debug-text! renderer 400 340 "none blend add  mod  mul")

      ;; Row 3: Clipping demo
      (render-texture! renderer clip-tex 20 380)
      (render-debug-text! renderer 20 505 "Clipping Rectangle")
      (render-debug-text! renderer 20 520 "Left: full  Right: clipped to 50x50")

      ;; Info section
      (set-draw-color! renderer 200 200 200)
      (render-debug-text! renderer 300 400 "Phase 6 Functions:")
      (render-debug-text! renderer 300 420 "")
      (render-debug-text! renderer 300 440 "Color Key:")
      (render-debug-text! renderer 300 460 "  set-surface-color-key!")
      (render-debug-text! renderer 300 480 "  surface-has-color-key?")

      (render-debug-text! renderer 500 440 "Modulation:")
      (render-debug-text! renderer 500 460 "  set-surface-color-mod!")
      (render-debug-text! renderer 500 480 "  set-surface-alpha-mod!")

      (render-debug-text! renderer 300 510 "Blend Mode:")
      (render-debug-text! renderer 300 530 "  set-surface-blend-mode!")

      (render-debug-text! renderer 500 510 "Clipping:")
      (render-debug-text! renderer 500 530 "  set-surface-clip-rect!")

      (render-debug-text! renderer 20 570 "Press ESC to exit")

      (render-present! renderer)
      (delay! 16)

      (loop still-running?)))

  (printf "Done!~n"))

(main)
