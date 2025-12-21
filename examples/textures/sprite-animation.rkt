#lang racket/base

;; Sprite Animation Demo
;;
;; Demonstrates frame-based sprite animation in SDL3:
;; - Animated sprite with multiple frames
;; - Time-based frame advancement (independent of FPS)
;; - Variable animation speed
;; - Programmatically generated sprite sheet
;;
;; Controls:
;;   Left/Right - Move sprite
;;   Up/Down - Adjust animation speed
;;   Space - Toggle animation pause
;;   R - Reverse animation direction
;;   Escape - Quit

(require racket/match
         racket/format
         racket/math
         sdl3)

(define window-width 800)
(define window-height 600)
(define window-title "SDL3 Sprite Animation Demo")

;; Animation parameters
(define frame-count 8)
(define frame-size 64)
(define default-frame-duration 100)  ; milliseconds per frame

;; Create a procedural sprite sheet with colored frames
;; Each frame shows a "walking" stick figure in different poses
(define (create-sprite-sheet renderer)
  (define sheet-width (* frame-count frame-size))
  (define sheet-height frame-size)

  ;; Create texture as render target
  (define sheet (create-texture renderer sheet-width sheet-height
                                 #:access 'target))

  ;; Draw frames to the texture
  (with-render-target renderer sheet
    ;; Clear to transparent
    (set-draw-color! renderer 0 0 0 0)
    (render-clear! renderer)

    ;; Draw each frame
    (for ([i (in-range frame-count)])
      (define x (* i frame-size))
      (define cx (+ x (/ frame-size 2)))  ; center x
      (define cy (/ frame-size 2))         ; center y

      ;; Frame-specific animation phase (0 to 2pi)
      (define phase (* i (/ (* 2 pi) frame-count)))

      ;; Body color cycles through hues
      (define hue (/ i frame-count))
      (define r (inexact->exact (round (+ 128 (* 127 (cos (* hue 2 pi)))))))
      (define g (inexact->exact (round (+ 128 (* 127 (cos (+ (* hue 2 pi) (/ (* 2 pi) 3))))))))
      (define b (inexact->exact (round (+ 128 (* 127 (cos (+ (* hue 2 pi) (/ (* 4 pi) 3))))))))

      ;; Draw head (circle approximated with rect for simplicity)
      (set-draw-color! renderer r g b)
      (fill-rect! renderer (- cx 8) (- cy 25) 16 16)

      ;; Draw body
      (fill-rect! renderer (- cx 4) (- cy 8) 8 20)

      ;; Draw legs (animated based on phase)
      (define leg-swing (* 8 (sin phase)))
      (define leg1-x (+ cx leg-swing))
      (define leg2-x (- cx leg-swing))
      (set-draw-color! renderer (max 0 (- r 50)) (max 0 (- g 50)) (max 0 (- b 50)))
      (fill-rect! renderer (- leg1-x 3) (+ cy 12) 6 15)
      (fill-rect! renderer (- leg2-x 3) (+ cy 12) 6 15)

      ;; Draw arms (animated opposite to legs)
      (define arm-swing (* 6 (sin (+ phase pi))))
      (set-draw-color! renderer r g b)
      (fill-rect! renderer (- cx 12) (- cy 5 arm-swing) 6 12)
      (fill-rect! renderer (+ cx 6) (- cy 5 (- arm-swing)) 6 12)

      ;; Frame number indicator
      (set-draw-color! renderer 255 255 255)
      (render-debug-text! renderer (+ x 4) (+ cy 25) (~a i))))

  sheet)

(define (main)
  (sdl-init!)

  (define-values (window renderer)
    (make-window+renderer window-title window-width window-height))

  ;; Create sprite sheet
  (define sprite-sheet (create-sprite-sheet renderer))

  ;; Enable blending for transparency
  (set-blend-mode! renderer 'blend)

  ;; Animation state
  (let loop ([sprite-x (/ window-width 2.0)]
             [current-frame 0]
             [frame-time 0]
             [frame-duration default-frame-duration]
             [paused? #f]
             [reversed? #f]
             [last-ticks (current-ticks)]
             [running? #t])
    (when running?
      (define now (current-ticks))
      (define dt (- now last-ticks))

      ;; Process events
      (define-values (new-x new-duration new-paused? new-reversed? still-running?)
        (for/fold ([x sprite-x]
                   [dur frame-duration]
                   [pause? paused?]
                   [rev? reversed?]
                   [run? #t])
                  ([ev (in-events)]
                   #:break (not run?))
          (match ev
            [(or (quit-event) (window-event 'close-requested))
             (values x dur pause? rev? #f)]

            [(key-event 'down 'escape _ _ _)
             (values x dur pause? rev? #f)]

            [(key-event 'down 'left _ _ _)
             (values (max 50 (- x 20)) dur pause? rev? run?)]

            [(key-event 'down 'right _ _ _)
             (values (min (- window-width 50) (+ x 20)) dur pause? rev? run?)]

            [(key-event 'down 'up _ _ _)
             (values x (max 20 (- dur 20)) pause? rev? run?)]

            [(key-event 'down 'down _ _ _)
             (values x (min 500 (+ dur 20)) pause? rev? run?)]

            [(key-event 'down 'space _ _ _)
             (values x dur (not pause?) rev? run?)]

            [(key-event 'down 'r _ _ _)
             (values x dur pause? (not rev?) run?)]

            [_ (values x dur pause? rev? run?)])))

      (when still-running?
        ;; Update animation
        (define new-frame-time
          (if new-paused?
              frame-time
              (+ frame-time dt)))

        ;; Advance frame if enough time has passed
        (define frames-to-advance (quotient new-frame-time new-duration))
        (define remaining-time (remainder new-frame-time new-duration))

        (define next-frame
          (if new-reversed?
              (modulo (- current-frame frames-to-advance) frame-count)
              (modulo (+ current-frame frames-to-advance) frame-count)))

        ;; Clear background
        (set-draw-color! renderer 30 30 40)
        (render-clear! renderer)

        ;; Draw ground
        (set-draw-color! renderer 60 80 60)
        (fill-rect! renderer 0 (- window-height 80) window-width 80)

        ;; Draw sprite at larger scale
        (define scale 3.0)
        (define sprite-w (* frame-size scale))
        (define sprite-h (* frame-size scale))
        (define sprite-y (- window-height 80 sprite-h))

        (render-texture! renderer sprite-sheet
                         (- new-x (/ sprite-w 2)) sprite-y
                         #:width sprite-w
                         #:height sprite-h
                         #:src-x (* next-frame frame-size)
                         #:src-y 0
                         #:src-w frame-size
                         #:src-h frame-size
                         #:flip (if new-reversed? 'horizontal 'none))

        ;; Draw sprite sheet preview at bottom
        (set-draw-color! renderer 40 40 50)
        (fill-rect! renderer 144 16 (+ (* frame-count frame-size) 16) (+ frame-size 16))
        (render-texture! renderer sprite-sheet 152 24)

        ;; Highlight current frame in preview
        (set-draw-color! renderer 255 255 0)
        (draw-rect! renderer (+ 152 (* next-frame frame-size)) 24 frame-size frame-size)

        ;; UI info
        (set-draw-color! renderer 255 255 255)
        (render-debug-text! renderer 20 20 "SPRITE ANIMATION DEMO")

        (set-draw-color! renderer 180 180 180)
        (render-debug-text! renderer 20 40
                            (~a "Frame: " next-frame "/" frame-count
                                "  Speed: " new-duration "ms/frame"
                                "  FPS: " (inexact->exact (round (/ 1000.0 new-duration)))))

        (render-debug-text! renderer 20 55
                            (~a "State: "
                                (if new-paused? "PAUSED " "PLAYING ")
                                (if new-reversed? "(REVERSED)" "(FORWARD)")))

        ;; Controls help
        (set-draw-color! renderer 120 120 120)
        (render-debug-text! renderer 20 (- window-height 30)
                            "Left/Right: Move | Up/Down: Speed | Space: Pause | R: Reverse | ESC: Quit")

        (render-present! renderer)
        (delay! 16)

        (loop new-x next-frame remaining-time new-duration
              new-paused? new-reversed? now still-running?))))

  ;; Clean up
  (texture-destroy! sprite-sheet)
  (renderer-destroy! renderer)
  (window-destroy! window))

;; Run when executed directly
(module+ main
  (main))
