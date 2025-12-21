#lang racket/base

;; Camera Demo
;;
;; Demonstrates camera/scrolling techniques in SDL3:
;; - World larger than the visible window
;; - Camera follows player smoothly
;; - World coordinates vs screen coordinates
;; - Parallax background layers (optional)
;;
;; Controls:
;;   Arrow keys or WASD - Move player
;;   Space - Toggle smooth camera follow
;;   P - Toggle parallax effect
;;   Escape - Quit

(require racket/match
         racket/format
         racket/math
         sdl3)

(define window-width 800)
(define window-height 600)
(define window-title "SDL3 Camera Demo")

;; World dimensions (larger than window)
(define world-width 2400)
(define world-height 1800)

;; Player settings
(define player-size 40)
(define player-speed 300.0)  ; pixels per second

;; Camera smoothing (0 = instant, higher = smoother)
(define camera-smoothness 0.1)

;; Clamp value to range
(define (clamp v lo hi)
  (max lo (min hi v)))

;; Lerp (linear interpolation)
(define (lerp a b t)
  (+ a (* (- b a) t)))

;; World-to-screen coordinate conversion
(define (world->screen wx wy cam-x cam-y)
  (values (- wx cam-x) (- wy cam-y)))

;; Screen-to-world coordinate conversion
(define (screen->world sx sy cam-x cam-y)
  (values (+ sx cam-x) (+ sy cam-y)))

;; Draw a grid pattern in world coordinates
(define (draw-world-grid! renderer cam-x cam-y grid-size color-r color-g color-b [alpha 255])
  (set-draw-color! renderer color-r color-g color-b alpha)

  ;; Only draw visible portion of grid
  (define start-x (* (quotient (inexact->exact (floor cam-x)) grid-size) grid-size))
  (define start-y (* (quotient (inexact->exact (floor cam-y)) grid-size) grid-size))
  (define end-x (+ cam-x window-width grid-size))
  (define end-y (+ cam-y window-height grid-size))

  ;; Vertical lines
  (for ([wx (in-range start-x end-x grid-size)])
    (define-values (sx _) (world->screen wx 0 cam-x cam-y))
    (draw-line! renderer sx 0 sx window-height))

  ;; Horizontal lines
  (for ([wy (in-range start-y end-y grid-size)])
    (define-values (_ sy) (world->screen 0 wy cam-x cam-y))
    (draw-line! renderer 0 sy window-width sy)))

;; Draw world boundaries
(define (draw-world-bounds! renderer cam-x cam-y)
  (set-draw-color! renderer 255 100 100)
  (define-values (x1 y1) (world->screen 0 0 cam-x cam-y))
  (define-values (x2 y2) (world->screen world-width world-height cam-x cam-y))
  (draw-rect! renderer x1 y1 (- x2 x1) (- y2 y1))

  ;; Corner markers
  (define marker-size 20)
  (fill-rect! renderer x1 y1 marker-size marker-size)
  (fill-rect! renderer (- x2 marker-size) y1 marker-size marker-size)
  (fill-rect! renderer x1 (- y2 marker-size) marker-size marker-size)
  (fill-rect! renderer (- x2 marker-size) (- y2 marker-size) marker-size marker-size))

;; Draw some world objects (landmarks)
(define (draw-landmarks! renderer cam-x cam-y)
  ;; Large colored rectangles scattered around the world
  (define landmarks
    '((200 200 150 150 100 150 200)
      (800 400 200 100 200 100 150)
      (1500 300 100 200 150 200 100)
      (400 1000 180 180 200 150 100)
      (1200 900 120 160 100 200 150)
      (2000 500 200 200 150 100 200)
      (1800 1400 160 140 200 200 100)
      (600 1400 140 180 100 150 200)))

  (for ([landmark landmarks])
    (match-define (list wx wy w h r g b) landmark)
    (define-values (sx sy) (world->screen wx wy cam-x cam-y))
    ;; Only draw if visible
    (when (and (< sx window-width) (> (+ sx w) 0)
               (< sy window-height) (> (+ sy h) 0))
      (set-draw-color! renderer r g b)
      (fill-rect! renderer sx sy w h)
      ;; Outline
      (set-draw-color! renderer 255 255 255 100)
      (draw-rect! renderer sx sy w h))))

;; Draw parallax background layer
(define (draw-parallax-layer! renderer cam-x cam-y parallax-factor size-range color)
  (match-define (list r g b) color)
  (set-draw-color! renderer r g b)

  ;; Offset based on parallax factor (0 = static, 1 = same as camera)
  (define offset-x (* cam-x parallax-factor))
  (define offset-y (* cam-y parallax-factor))

  ;; Draw a pattern of shapes
  (for* ([ix (in-range -1 (+ (quotient window-width 200) 2))]
         [iy (in-range -1 (+ (quotient window-height 200) 2))])
    (define base-x (+ (* ix 200) (modulo (* ix 137) 50)))
    (define base-y (+ (* iy 200) (modulo (* iy 89) 50)))
    (define sx (- base-x (modulo (inexact->exact (floor offset-x)) 200)))
    (define sy (- base-y (modulo (inexact->exact (floor offset-y)) 200)))
    (define size (+ (car size-range)
                    (modulo (+ (* ix 31) (* iy 17)) (- (cdr size-range) (car size-range)))))
    (fill-rect! renderer sx sy size size)))

;; Draw the player
(define (draw-player! renderer cam-x cam-y player-x player-y)
  (define-values (sx sy) (world->screen player-x player-y cam-x cam-y))

  ;; Shadow
  (set-draw-color! renderer 0 0 0 100)
  (fill-rect! renderer (+ sx 4) (+ sy 4) player-size player-size)

  ;; Body
  (set-draw-color! renderer 100 200 255)
  (fill-rect! renderer sx sy player-size player-size)

  ;; Outline
  (set-draw-color! renderer 255 255 255)
  (draw-rect! renderer sx sy player-size player-size)

  ;; Direction indicator (center dot)
  (set-draw-color! renderer 255 255 255)
  (fill-rect! renderer (+ sx 15) (+ sy 15) 10 10))

(define (main)
  (sdl-init!)

  (define-values (window renderer)
    (make-window+renderer window-title window-width window-height))

  (set-blend-mode! renderer 'blend)

  ;; Initial state
  (define start-x (/ world-width 2.0))
  (define start-y (/ world-height 2.0))

  (let loop ([player-x start-x]
             [player-y start-y]
             [cam-x (- start-x (/ window-width 2.0))]
             [cam-y (- start-y (/ window-height 2.0))]
             [smooth-camera? #t]
             [parallax? #t]
             [last-ticks (current-ticks)]
             [running? #t])
    (when running?
      (define now (current-ticks))
      (define dt (/ (- now last-ticks) 1000.0))

      ;; Get keyboard state for smooth movement
      (define keys (get-keyboard-state))

      ;; Calculate movement (keys now accepts symbols)
      (define move-x
        (+ (if (or (keys 'right)
                   (keys 'd)) 1 0)
           (if (or (keys 'left)
                   (keys 'a)) -1 0)))
      (define move-y
        (+ (if (or (keys 'down)
                   (keys 's)) 1 0)
           (if (or (keys 'up)
                   (keys 'w)) -1 0)))

      ;; Update player position
      (define new-player-x
        (clamp (+ player-x (* move-x player-speed dt))
               0 (- world-width player-size)))
      (define new-player-y
        (clamp (+ player-y (* move-y player-speed dt))
               0 (- world-height player-size)))

      ;; Process events
      (define-values (new-smooth? new-parallax? still-running?)
        (for/fold ([smooth? smooth-camera?]
                   [para? parallax?]
                   [run? #t])
                  ([ev (in-events)]
                   #:break (not run?))
          (match ev
            [(or (quit-event) (window-event 'close-requested))
             (values smooth? para? #f)]

            [(key-event 'down 'escape _ _ _)
             (values smooth? para? #f)]
            [(key-event 'down 'space _ _ _)
             (values (not smooth?) para? run?)]
            [(key-event 'down 'p _ _ _)
             (values smooth? (not para?) run?)]

            [_ (values smooth? para? run?)])))

      (when still-running?
        ;; Calculate target camera position (centered on player)
        (define target-cam-x (- (+ new-player-x (/ player-size 2)) (/ window-width 2)))
        (define target-cam-y (- (+ new-player-y (/ player-size 2)) (/ window-height 2)))

        ;; Clamp target to world bounds
        (define clamped-target-x (clamp target-cam-x 0 (- world-width window-width)))
        (define clamped-target-y (clamp target-cam-y 0 (- world-height window-height)))

        ;; Update camera (smooth or instant)
        (define new-cam-x
          (if new-smooth?
              (lerp cam-x clamped-target-x camera-smoothness)
              clamped-target-x))
        (define new-cam-y
          (if new-smooth?
              (lerp cam-y clamped-target-y camera-smoothness)
              clamped-target-y))

        ;; Draw background
        (set-draw-color! renderer 20 25 35)
        (render-clear! renderer)

        ;; Draw parallax layers (back to front)
        (when new-parallax?
          (draw-parallax-layer! renderer new-cam-x new-cam-y 0.1 '(10 . 30) '(30 35 45))
          (draw-parallax-layer! renderer new-cam-x new-cam-y 0.3 '(15 . 40) '(40 45 55))
          (draw-parallax-layer! renderer new-cam-x new-cam-y 0.5 '(8 . 20) '(50 55 65)))

        ;; Draw world grid
        (draw-world-grid! renderer new-cam-x new-cam-y 100 60 65 75)

        ;; Draw landmarks
        (draw-landmarks! renderer new-cam-x new-cam-y)

        ;; Draw world boundaries
        (draw-world-bounds! renderer new-cam-x new-cam-y)

        ;; Draw player
        (draw-player! renderer new-cam-x new-cam-y new-player-x new-player-y)

        ;; UI overlay
        (set-draw-color! renderer 30 30 40 200)
        (fill-rect! renderer 10 10 300 100)

        (set-draw-color! renderer 255 255 255)
        (render-debug-text! renderer 20 18 "CAMERA DEMO")

        (set-draw-color! renderer 180 180 180)
        (render-debug-text! renderer 20 35
                            (~a "World: " (inexact->exact (round new-player-x))
                                ", " (inexact->exact (round new-player-y))))
        (render-debug-text! renderer 20 50
                            (~a "Camera: " (inexact->exact (round new-cam-x))
                                ", " (inexact->exact (round new-cam-y))))
        (render-debug-text! renderer 20 65
                            (~a "Smooth: " (if new-smooth? "ON" "OFF")
                                " | Parallax: " (if new-parallax? "ON" "OFF")))

        ;; Mini-map
        (define mini-scale 0.05)
        (define mini-x (- window-width 140))
        (define mini-y 10)
        (define mini-w (* world-width mini-scale))
        (define mini-h (* world-height mini-scale))

        ;; Mini-map background
        (set-draw-color! renderer 40 45 55)
        (fill-rect! renderer mini-x mini-y mini-w mini-h)

        ;; Mini-map viewport
        (set-draw-color! renderer 100 150 255 150)
        (fill-rect! renderer
                    (+ mini-x (* new-cam-x mini-scale))
                    (+ mini-y (* new-cam-y mini-scale))
                    (* window-width mini-scale)
                    (* window-height mini-scale))

        ;; Mini-map player
        (set-draw-color! renderer 255 100 100)
        (fill-rect! renderer
                    (+ mini-x (* new-player-x mini-scale))
                    (+ mini-y (* new-player-y mini-scale))
                    4 4)

        ;; Mini-map border
        (set-draw-color! renderer 100 100 100)
        (draw-rect! renderer mini-x mini-y mini-w mini-h)

        ;; Controls
        (set-draw-color! renderer 120 120 120)
        (render-debug-text! renderer 20 (- window-height 20)
                            "WASD/Arrows: Move | Space: Toggle smooth | P: Parallax | ESC: Quit")

        (render-present! renderer)
        (delay! 16)

        (loop new-player-x new-player-y new-cam-x new-cam-y
              new-smooth? new-parallax? now still-running?))))

  (renderer-destroy! renderer)
  (window-destroy! window))

;; Run when executed directly
(module+ main
  (main))
